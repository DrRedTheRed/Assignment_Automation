import tkinter as tk
from tkinter import filedialog
import cv2
import numpy as np
import matplotlib.pyplot as plt
from matplotlib.backends.backend_tkagg import FigureCanvasTkAgg

def apply_filter():
    global img, ax1, ax2, canvas
    if img is None:
        return
    
    kernel_size = int(kernel_slider.get())
    sigma = float(sigma_slider.get())
    mode = filter_mode.get()
    
    if mode == "Spatial Highpass":
        # 空域高通滤波
        lowpass = cv2.GaussianBlur(img, (kernel_size, kernel_size), sigma)
        highpass = cv2.subtract(img, lowpass)
        #result = cv2.addWeighted(img, 1.5, highpass, -0.5, 0)
        result = highpass
    else:
        # 频域高通滤波
        dft = np.fft.fft2(img)
        dft_shifted = np.fft.fftshift(dft)
        rows, cols = img.shape
        x = np.arange(cols) - cols // 2
        y = np.arange(rows) - rows // 2
        X, Y = np.meshgrid(x, y)
        D = np.sqrt(X**2 + Y**2)
        cutoff = sigma * 10  # 转换为适当的尺度
        H = 1 - np.exp(-(D**2 / (2 * (cutoff**2))))
        filtered_dft = dft_shifted * H
        idft_shifted = np.fft.ifftshift(filtered_dft)
        result = np.abs(np.fft.ifft2(idft_shifted))
    
    result = cv2.normalize(result, None, 0, 255, cv2.NORM_MINMAX).astype(np.uint8)
    
    ax2.clear()
    ax2.imshow(result, cmap='gray')
    ax2.set_title("Filtered Image")
    ax2.axis("off")
    canvas.draw()

def open_image():
    global img, ax1, ax2, canvas

    print('Opening image...')

    file_path = filedialog.askopenfilename()
    
    if not file_path:  # 如果用户没有选择文件，直接返回
        return
    
    img = cv2.imread(file_path, cv2.IMREAD_GRAYSCALE)
    
    if img is None:  # 读取失败，弹窗提示
        tk.messagebox.showerror("Error", "Failed to load image. Please select a valid image file.")
        return
    
    ax1.clear()
    ax1.imshow(img, cmap='gray')
    ax1.set_title("Original Image")
    ax1.axis("off")
    canvas.draw()
    
    apply_filter()  # 只有成功读取图片后才执行滤波


root = tk.Tk()
root.title("Image Highpass Filter GUI")

frame = tk.Frame(root)
frame.pack(side=tk.LEFT, padx=10, pady=10)

fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(6, 3))
canvas = FigureCanvasTkAgg(fig, master=frame)
canvas.get_tk_widget().pack()

btn_open = tk.Button(root, text="Open Image", command=open_image)
btn_open.pack()

kernel_slider = tk.Scale(root, from_=3, to=101, resolution=2, orient=tk.HORIZONTAL, label="Kernel Size")
kernel_slider.set(5)
kernel_slider.pack()

sigma_slider = tk.Scale(root, from_=0.1, to=40, resolution=0.1, orient=tk.HORIZONTAL, label="Sigma")
sigma_slider.set(0.3)
sigma_slider.pack()

filter_mode = tk.StringVar(value="Spatial Highpass")
tk.Radiobutton(root, text="Spatial Highpass", variable=filter_mode, value="Spatial Highpass").pack()
tk.Radiobutton(root, text="Frequency Highpass", variable=filter_mode, value="Frequency Highpass").pack()

btn_apply = tk.Button(root, text="Apply Filter", command=apply_filter)
btn_apply.pack()

img = None
root.mainloop()
