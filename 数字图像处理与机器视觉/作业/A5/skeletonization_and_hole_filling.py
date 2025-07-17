import cv2
import numpy as np
import matplotlib.pyplot as plt
from skimage.morphology import skeletonize
from scipy.ndimage import binary_fill_holes

# Binary image
img = cv2.imread('CaiXukun.png', cv2.IMREAD_GRAYSCALE)
_, binary = cv2.threshold(img, 150, 255, cv2.THRESH_BINARY)
kernel = cv2.getStructuringElement(cv2.MORPH_RECT, (5, 5))

# boolean transform
binary_bool = binary > 0

invert = np.invert(binary)

closing = cv2.morphologyEx(invert, cv2.MORPH_CLOSE, kernel)

filled = binary_fill_holes(closing)

# skeletonization
skeleton = skeletonize(filled)

# plotting
fig, ax = plt.subplots(1, 4, figsize=(12, 4))

ax[0].imshow(img, cmap='gray')
ax[0].set_title('Original')
ax[0].axis('off')

ax[1].imshow(binary, cmap='gray')
ax[1].set_title('Binary')
ax[1].axis('off')

ax[2].imshow(filled, cmap='gray')
ax[2].set_title('Hole Filled')
ax[2].axis('off')

ax[3].imshow(skeleton, cmap='gray')
ax[3].set_title('Skeletonized')
ax[3].axis('off')

plt.tight_layout()
plt.show()
