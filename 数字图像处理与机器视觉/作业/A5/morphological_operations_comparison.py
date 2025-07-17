import cv2
import numpy as np
import matplotlib.pyplot as plt

# Binary image
image = cv2.imread('Example_binary.png', cv2.IMREAD_GRAYSCALE)
_, binary = cv2.threshold(image, 127, 255, cv2.THRESH_BINARY)

# structure
kernel1 = cv2.getStructuringElement(cv2.MORPH_RECT, (5, 5))      # rectangle
kernel2 = cv2.getStructuringElement(cv2.MORPH_ELLIPSE, (5, 5))   # ellipse
kernel3 = cv2.getStructuringElement(cv2.MORPH_CROSS, (5, 5))     # cross

kernels = {'Rect': kernel1, 'Ellipse': kernel2, 'Cross': kernel3}
operations = ['Erosion', 'Dilation', 'Opening', 'Closing']

# execute morphological operations
fig, axes = plt.subplots(len(kernels), len(operations)+1, figsize=(12, 8))
for i, (kname, kernel) in enumerate(kernels.items()):
    axes[i][0].imshow(binary, cmap='gray')
    axes[i][0].set_title(f'Original - {kname}')
    axes[i][0].axis('off')

    erosion = cv2.erode(binary, kernel)
    dilation = cv2.dilate(binary, kernel)
    opening = cv2.morphologyEx(binary, cv2.MORPH_OPEN, kernel)
    closing = cv2.morphologyEx(binary, cv2.MORPH_CLOSE, kernel)

    results = [erosion, dilation, opening, closing]
    for j, result in enumerate(results):
        axes[i][j+1].imshow(result, cmap='gray')
        axes[i][j+1].set_title(operations[j])
        axes[i][j+1].axis('off')

plt.tight_layout()
plt.show()
