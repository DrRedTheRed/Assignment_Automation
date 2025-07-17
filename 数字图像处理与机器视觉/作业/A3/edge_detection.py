import cv2
import numpy as np

from skimage import segmentation, color

import matplotlib.pyplot as plt

def edge_detection(image_path, low_threshold, high_threshold):
    # Read the image
    image = cv2.imread(image_path, cv2.IMREAD_GRAYSCALE)
    if image is None:
        raise FileNotFoundError(f"Image not found at {image_path}")

    # Apply Gaussian Blur to reduce noise
    blurred_image = cv2.GaussianBlur(image, (5, 5),0.5)

    # Apply Canny edge detection
    edges = cv2.Canny(blurred_image, low_threshold, high_threshold, apertureSize=3, L2gradient=True)

    return edges

def Hough_transform(edges, threshold=20):
    # Perform Hough Line Transform
    lines = cv2.HoughLinesP(edges, 1, 22.5 * np.pi / 180, threshold, minLineLength=20, maxLineGap=5)

    # Create a blank image to draw lines
    line_image = np.zeros_like(edges)

    if lines is not None:
        for line in lines:
            x1, y1, x2, y2 = line[0]
            cv2.line(line_image, (x1, y1), (x2, y2), 255, 2)

    return line_image

def Segmentation_Felzenszwalb(image_path):
    # Read the image
    image = cv2.imread(image_path)
    if image is None:
        raise FileNotFoundError(f"Image not found at {image_path}")

    # Convert to grayscale
    gray_image = cv2.cvtColor(image, cv2.COLOR_BGR2GRAY)

    segmented_image = segmentation.felzenszwalb(gray_image, scale=3000, sigma=0.5, min_size=1000)

    return segmented_image

if __name__ == "__main__":
    # Path to the input image
    image_path = "image3.png"  # Replace with your image path

    # Canny edge detection thresholds
    low_threshold = 90
    high_threshold = 200

    # Perform edge detection
    edges = edge_detection(image_path, low_threshold, high_threshold)

    if image_path is None:
        raise ValueError("Please provide a valid image path.")
    elif image_path == "image1.png":
        # Display the result
        plt.figure(figsize=(8, 6))
        plt.subplot(1, 2, 1)
        plt.imshow(cv2.cvtColor(cv2.imread(image_path), cv2.COLOR_BGR2RGB))
        plt.title("Original Image")
        plt.subplot(1, 2, 2)
        plt.imshow(edges, cmap='gray')
        plt.title("Canny Edge Detection")
        plt.show()
    elif image_path == "image2.png":
        # Perform Hough Transform
        line_image = Hough_transform(edges)

        # Display the Hough Transform result
        plt.figure(figsize=(8, 6))
        plt.subplot(1, 2, 1)
        plt.imshow(edges, cmap='gray')
        plt.title("Canny Edge Detection")
        plt.subplot(1, 2, 2)
        plt.imshow(line_image, cmap='gray')
        plt.title("Hough Transform Lines")
        plt.show()
    elif image_path == "image3.png":
        segmented_image = Segmentation_Felzenszwalb(image_path)

        # Display the segmentation result
        plt.figure(figsize=(8, 6))
        plt.subplot(1, 2, 1)
        plt.imshow(cv2.cvtColor(cv2.imread(image_path), cv2.COLOR_BGR2RGB))
        plt.title("Original Image")
        plt.subplot(1, 2, 2)
        plt.imshow(segmented_image)
        plt.title("Felzenszwalb Segmentation")
        #plt.axis("off")
        plt.show()
    else:
        raise ValueError("Invalid image path. Please provide 'image1.png', 'image2.png', or 'image3.png'.")    