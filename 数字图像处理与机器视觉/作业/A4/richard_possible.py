import numpy as np
import matplotlib.pyplot as plt
from skimage import color, data, restoration, img_as_float
import cv2

image = img_as_float(data.camera())  # skimage_default image

def motion_blur_psf(length, angle):
    psf = np.zeros((length, length))
    center = length // 2
    angle = np.deg2rad(angle)
    dx = np.cos(angle) * center
    dy = np.sin(angle) * center
    x0, y0 = int(center - dx), int(center - dy)
    x1, y1 = int(center + dx), int(center + dy)
    cv2.line(psf, (x0, y0), (x1, y1), 1, thickness=1)
    return psf / psf.sum()

psf = motion_blur_psf(31, -11)

blurred = cv2.filter2D(image, -1, psf)

blurred = np.clip(blurred + np.random.normal(0, 0.1, image.shape), 0, 1)

#blurred = (blurred * 255).astype(np.uint8)

#nl_denoised = cv2.fastNlMeansDenoising(blurred, h=5, templateWindowSize=19, searchWindowSize=21)

#nl_denoised_clipped = np.clip(nl_denoised, 0, 255)

#nl_denoised_smoothed = cv2.GaussianBlur(nl_denoised_clipped, (3,3), 0.5)

#nl_denoised_float = nl_denoised_smoothed.astype(np.float32) / 255.0

deconvolved_rl = restoration.richardson_lucy(blurred, psf, num_iter=30)

fig, ax = plt.subplots(1, 3, figsize=(12, 5))
ax[0].imshow(image, cmap='gray')
ax[0].set_title('Original')
ax[1].imshow(blurred, cmap='gray')
ax[1].set_title('Blurred')
ax[2].imshow(deconvolved_rl, cmap='gray')
ax[2].set_title('Restored with RL')
for a in ax:
    a.axis('off')
plt.show()
