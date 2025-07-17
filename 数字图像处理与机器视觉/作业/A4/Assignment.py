import ImageRecovery as ir
import numpy as np
import cv2 as cv
import matplotlib.pyplot as plt
from skimage.restoration import richardson_lucy

noisy = cv.imread('monkey.jpg', cv.IMREAD_GRAYSCALE)

gaussian_denoised = cv.GaussianBlur(noisy, (5, 5), 1)
#gaussian_denoised = noisy.copy()

nl_denoised = cv.fastNlMeansDenoising(noisy, h=1, templateWindowSize=19, searchWindowSize=21)

motion_psf = ir.motion_blur_psf(31, -11)
motion_restored_wiener = ir.wiener_filter(gaussian_denoised, motion_psf, K=0.005)

motion_psf2 = ir.motion_blur_psf(31, -11)
denoised_float = nl_denoised.astype(np.float64) / 255.0
motion_restored = richardson_lucy(denoised_float , motion_psf2, num_iter=30)
motion_restored = np.clip(motion_restored, 0, 1)  
motion_restored = (motion_restored * 255).astype(np.uint8)

plt.figure(figsize=(8, 7))
plt.subplot(2, 2, 1)
plt.title("NLmeans Image")
plt.imshow(nl_denoised, cmap='gray')
plt.subplot(2, 2, 2)
plt.title("Gaussian Denoised")
plt.imshow(gaussian_denoised, cmap='gray')
plt.subplot(2, 2, 3)
plt.title("Motion Restored (Wiener)")
plt.imshow(motion_restored_wiener, cmap='gray')
plt.subplot(2, 2, 4)
plt.title("Motion Restored (Richardson-Lucy)")
plt.imshow(motion_restored, cmap='gray')
plt.show()