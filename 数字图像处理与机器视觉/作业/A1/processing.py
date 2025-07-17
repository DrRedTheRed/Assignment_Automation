import cv2

def resize_image(image_path, scale):
    
    image = cv2.imread(image_path)
    if image is None:
        print("无法读取图像，请检查路径！")
        return
    
    height, width = image.shape[:2]
    
    new_size = (int(width * scale), int(height * scale))
    
    resized_image = cv2.resize(image, new_size, interpolation=cv2.INTER_LINEAR)
    
    cv2.imshow("Original Image", image)
    cv2.imshow("Resized Image", resized_image)
    
    cv2.waitKey(0)
    cv2.destroyAllWindows()

def play_video(video_path,scale = 0.4):
    cap = cv2.VideoCapture(video_path)
    
    if not cap.isOpened():
        print("无法打开视频文件，请检查路径！")
        return
    
    while True:
        ret, frame = cap.read()
        
        if not ret:
            print("视频播放结束或读取错误！")
            break
        
        # 获取原始尺寸
        height, width = frame.shape[:2]
        
        # 计算缩放后的尺寸
        new_width = int(width * scale)
        new_height = int(height * scale)
        
        # 进行缩放
        resized_frame = cv2.resize(frame, (new_width, new_height), interpolation=cv2.INTER_AREA)

        cv2.imshow("Video Playback", resized_frame)
        
        if cv2.waitKey(25) & 0xFF == ord('q'):
            break
    
    cap.release()
    cv2.destroyAllWindows()

def process_image(image_path):
    image = cv2.imread(image_path)
    if image is None:
        print("无法读取图像，请检查路径！")
        return
    
    cropped = image[200:650, 200:650]
    
    flipped = cv2.flip(cropped, 0)
    
    converted = cv2.cvtColor(flipped, cv2.COLOR_BGR2GRAY)
    
    cv2.imshow("Processed Image", converted)
    cv2.waitKey(0)
    cv2.destroyAllWindows()

import cv2
import numpy as np
import matplotlib.pyplot as plt

def plot_histogram(image, title, subplot_position):
    plt.subplot(1, 3, subplot_position)
    hist_values, _ = np.histogram(image.ravel(), 256, [0, 256])  # Extract histogram values
    hist_values = hist_values.astype(float) / hist_values.sum()  # Normalize
    plt.plot(hist_values, color='black')
    plt.title(title)

def histogram_equalization(image_path):
    img = cv2.imread(image_path, cv2.IMREAD_GRAYSCALE)
    
    equalized_img = cv2.equalizeHist(img)
    
    plt.figure(figsize=(10, 4))
    plot_histogram(img, "Original Histogram", 1)
    plot_histogram(equalized_img, "Equalized Histogram", 2)
    plt.show()
    
    cv2.imshow('Original Image', img)
    cv2.imshow('Equalized Image', equalized_img)
    cv2.waitKey(0)
    cv2.destroyAllWindows()

def histogram_matching(source_path, reference_path):
    source = cv2.imread(source_path, cv2.IMREAD_GRAYSCALE)
    reference = cv2.imread(reference_path, cv2.IMREAD_GRAYSCALE)
    
    source_hist, _ = np.histogram(source.ravel(), 256, [0, 256])
    reference_hist, _ = np.histogram(reference.ravel(), 256, [0, 256])
    
    source_cdf = np.cumsum(source_hist).astype(float) / source_hist.sum()
    reference_cdf = np.cumsum(reference_hist).astype(float) / reference_hist.sum()
    
    lookup_table = np.interp(source_cdf, reference_cdf, np.arange(256))
    
    matched = cv2.LUT(source, lookup_table.astype(np.uint8))
    
    cv2.imshow('Source Image', source)
    cv2.imshow('Reference Image', reference)
    cv2.imshow('Matched Image', matched)
    cv2.waitKey(0)
    cv2.destroyAllWindows()
    
    plt.figure(figsize=(15, 5))
    #plt.subplot(1, 3, 1)
    plot_histogram(source, "Source Histogram", 1)
    #plt.subplot(1, 3, 2)
    plot_histogram(reference, "Reference Histogram", 2)
    #plt.subplot(1, 3, 3)
    plot_histogram(matched, "Matched Histogram", 3)
    plt.show()

# 运行示例
image_path = "image.png"
video_path = "video.mp4"

#resize_image("FujiUmi.jpeg", 0.1)

#histogram_equalization(image_path)

histogram_matching("Shizuoka.jpeg", "FujiUmi.jpeg")

#enhance_image(image_path)
 
#resize_image(image_path, 0.1)

#process_image("FujiUmi.jpeg")

#play_video(video_path)

