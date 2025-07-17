import cv2
import numpy as np

import matplotlib.pyplot as plt

def motion_blur_psf(length, angle):
    """Generate motion blur point spread function (PSF)."""
    psf = np.zeros((length, length))
    center = length // 2
    # 计算起点终点坐标
    angle = np.deg2rad(angle)
    dx = np.cos(angle) * center
    dy = np.sin(angle) * center
    x0, y0 = int(center - dx), int(center - dy)
    x1, y1 = int(center + dx), int(center + dy)
    cv2.line(psf, (x0, y0), (x1, y1), 1, thickness=1)
    return psf / psf.sum()

def add_gaussian_noise(image, mean=0, std=10, noise_level = 0.3):
    """Adding Gaussian noise to the image."""
    if image.dtype == np.uint8:
        noise = np.random.normal(mean, std, image.shape)
        noisy_image = image.astype(np.float32) + noise_level * noise
        return np.clip(noisy_image, 0, 255).astype(np.uint8)
    else:
        return image + noise_level * np.random.normal(mean, std, image.shape)

# def atmospheric_turbulence_psf(shape, k):
#     """Shape: tuple like (rows, cols)"""
#     u = np.fft.fftfreq(shape[0], d=1/shape[0])
#     v = np.fft.fftfreq(shape[1], d=1/shape[1])
#     U, V = np.meshgrid(v, u)
#     H = np.exp(-k * (U**2 + V**2)**(5/6))
#     h = np.fft.ifft2(H)
#     return h

# 修改后的PSF生成：
def atmospheric_turbulence_psf(shape, k):
    u = np.fft.fftfreq(shape[0], d=1.0)
    v = np.fft.fftfreq(shape[1], d=1.0)
    U, V = np.meshgrid(u, v, indexing='ij')
    r = np.sqrt(U**2 + V**2)
    
    # Kolmogorov湍流模型
    H = np.exp(-k * (r**2)**(5/6)) 
    
    # 保证直流分量=1
    H = H / H.max()
    
    # 生成PSF并确保实数性
    h = np.fft.ifft2(H).real
    h = h / h.sum()  # 归一化总能量=1
    return h

def apply_psf(image, psf):
    """Apply PSF to degrade the image."""
    image_fft = np.fft.fft2(image)
    psf_fft = np.fft.fft2(psf, s=image.shape)
    degraded_fft = image_fft * psf_fft
    degraded = np.fft.ifft2(degraded_fft)
    return np.abs(degraded)

def inverse_filter(degraded, psf):
    """Restore image using inverse filtering."""
    degraded_fft = np.fft.fft2(degraded)
    psf_fft = np.fft.fft2(psf, s=degraded.shape)
    restored_fft = degraded_fft / (psf_fft + 1e-8)
    restored = np.fft.ifft2(restored_fft)
    return np.abs(restored)

def wiener_filter(degraded, psf, K=0.001):
    """Restore image using Wiener filtering."""
    h, w = degraded.shape
    ph, pw = psf.shape

    if (ph, pw) != (h, w):
        psf_padded = np.zeros((h, w))
        top = (h - ph) // 2
        left = (w - pw) // 2
        psf_padded[top:top+ph, left:left+pw] = psf
    else:
        psf_padded = psf.copy()

    psf_padded = np.fft.ifftshift(psf_padded)

    degraded_fft = np.fft.fft2(degraded)
    psf_fft = np.fft.fft2(psf_padded)
    psf_conj = np.conj(psf_fft)
    restored_fft = (psf_conj / (np.abs(psf_fft)**2 + K)) * degraded_fft
    restored = np.fft.ifft2(restored_fft)
    return np.abs(restored)


if __name__ == "__main__":
    # Load image
    image = cv2.imread('Evil_Neuro_portrait_4.jpeg', cv2.IMREAD_GRAYSCALE)

    # Simulate motion blur
    motion_psf = motion_blur_psf(100, 50)
    motion_blurred = apply_psf(image, motion_psf)

    # Add Gaussian white noise
    motion_blurred_noisy = add_gaussian_noise(motion_blurred)

    # Simulate atmospheric turbulence
    turbulence_psf = atmospheric_turbulence_psf(image.shape, 500)
    turbulence_blurred = apply_psf(image, turbulence_psf)

    turbulence_blurred_noisy = add_gaussian_noise(turbulence_blurred)

    # Restore images
    motion_restored_inverse = inverse_filter(motion_blurred_noisy, motion_psf)
    motion_restored_wiener = wiener_filter(motion_blurred_noisy, motion_psf)

    turbulence_restored_inverse = inverse_filter(turbulence_blurred_noisy, turbulence_psf)
    turbulence_restored_wiener = wiener_filter(turbulence_blurred_noisy, np.fft.fftshift(turbulence_psf))

    # Display results
    plt.figure(figsize=(12, 8))
    plt.subplot(2, 3, 1), plt.title("Original Image"), plt.imshow(image, cmap='gray')
    plt.subplot(2, 3, 2), plt.title("Motion Blurred"), plt.imshow(motion_blurred_noisy, cmap='gray')
    plt.subplot(2, 3, 3), plt.title("Motion Restored (Inverse)"), plt.imshow(motion_restored_inverse, cmap='gray')
    plt.subplot(2, 3, 4), plt.title("Motion Restored (Wiener)"), plt.imshow(motion_restored_wiener, cmap='gray')
    plt.subplot(2, 3, 5), plt.title("Turbulence Blurred"), plt.imshow(turbulence_blurred_noisy, cmap='gray')
    plt.subplot(2, 3, 6), plt.title("Turbulence Restored (Wiener)"), plt.imshow(turbulence_restored_wiener, cmap='gray')
    plt.tight_layout()
    plt.show()