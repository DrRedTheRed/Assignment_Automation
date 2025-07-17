import numpy as np
import cv2

import matplotlib.pyplot as plt

import numpy as np
import cv2
import matplotlib.pyplot as plt

def fft_image(image_path):
    # 读取图片并转换为灰度图
    img = cv2.imread(image_path, cv2.IMREAD_GRAYSCALE).astype(np.float32)
    if img is None:
        raise ValueError("Image not found or unable to read.")

    # 进行傅立叶变换
    f = np.fft.fft2(img)
    fshift = np.fft.fftshift(f)

    # 计算幅频图（取对数）
    magnitude_spectrum = 20 * np.log(np.abs(fshift) + 1)

    # 计算相位谱
    phase_spectrum = np.angle(fshift)  # [-π, π]

    # 归一化相位谱到 0-255 以便保存
    phase_spectrum_norm = (phase_spectrum + np.pi) / (2 * np.pi) * 255

    # 显示结果
    plt.figure(figsize=(12, 6))
    plt.subplot(1, 3, 1)
    plt.title("Original Grayscale Image")
    plt.imshow(img, cmap='gray')


    plt.subplot(1, 3, 2)
    plt.title("Magnitude Spectrum")
    plt.imshow(magnitude_spectrum, cmap='gray')

    plt.subplot(1, 3, 3)
    plt.title("Phase Spectrum")
    plt.imshow(phase_spectrum, cmap='gray')

    plt.tight_layout()
    plt.show()

    return magnitude_spectrum, phase_spectrum_norm  # 返回归一化后的相位

def save_spectrum_images(magnitude, phase, mag_path='magnitude.png', phase_path='phase.png'):
    # 归一化幅度图保存
    magnitude_norm = cv2.normalize(magnitude, None, 0, 255, cv2.NORM_MINMAX)
    cv2.imwrite(mag_path, magnitude_norm.astype(np.uint8))

    cv2.imwrite(phase_path, phase.astype(np.uint8)) #相位图已在前面归一化

def combine_magnitude_and_phase(magnitude_image_path, phase_image_path):
    # 读取并转换为浮点数
    mag_img = cv2.imread(magnitude_image_path, cv2.IMREAD_GRAYSCALE).astype(np.float32)
    phase_img = cv2.imread(phase_image_path, cv2.IMREAD_GRAYSCALE).astype(np.float32)

    if mag_img is None or phase_img is None:
        raise ValueError("One or both images not found or unable to read.")

    # 反归一化幅度图
    mag_img = mag_img / 255 * (np.max(mag_img) - np.min(mag_img)) + np.min(mag_img)
    magnitude = np.exp(mag_img / 20) - 1  # 逆对数变换

    # 反归一化相位图
    phase = (phase_img / 255) * 2 * np.pi - np.pi

    # 结合幅度和相位
    combined = magnitude * np.exp(1j * phase)

    # 进行逆傅立叶变换
    f_ishift = np.fft.ifftshift(combined)
    img_reconstructed = np.fft.ifft2(f_ishift)
    img_reconstructed = np.abs(img_reconstructed)

    # 归一化
    img_reconstructed = (img_reconstructed - np.min(img_reconstructed)) / (np.max(img_reconstructed) - np.min(img_reconstructed)) * 255
    img_reconstructed = img_reconstructed.astype(np.uint8)

    # 显示结果
    plt.figure(figsize=(6, 6))
    plt.title("Reconstructed Image")
    plt.imshow(img_reconstructed, cmap='gray')
    plt.axis('off')
    plt.show()

if __name__ == "__main__":
    # 替换为你的图片路径
    image_path1 = 'image1.webp'
    image_path2 = 'image2.webp'

    magnitude_path1 = 'magnitude1.png'
    phase_path1 = 'phase1.png'
    magnitude_path2 = 'magnitude2.png'
    phase_path2 = 'phase2.png'

    # 计算幅频图和相频图
    #magnitude1, phase1 = fft_image(image_path1)
    #magnitude2, phase2 = fft_image(image_path2)
    # 保存幅频图和相频图
    #save_spectrum_images(magnitude1, phase1, magnitude_path1, phase_path1)
    #save_spectrum_images(magnitude2, phase2, magnitude_path2, phase_path2)
    # 结合幅频图和相频图
    combine_magnitude_and_phase(magnitude_path1, phase_path2)
    combine_magnitude_and_phase(magnitude_path2, phase_path1)