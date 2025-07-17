import cv2
import numpy as np
import matplotlib.pyplot as plt
from sklearn.cluster import MiniBatchKMeans
from sklearn.svm import SVC
from sklearn.metrics import accuracy_score, confusion_matrix
from torchvision.datasets import MNIST
import torchvision.transforms as transforms
import torch
from tqdm import tqdm
import seaborn as sns

sift = cv2.SIFT_create()

transform = transforms.Compose([
    transforms.ToTensor(),
    transforms.Normalize((0.5,), (0.5,))
])

train_dataset = MNIST(root='../data', train=True, download=True, transform=transform)
test_dataset = MNIST(root='../data', train=False, download=True, transform=transform)

# 提取 SIFT 描述子
def extract_sift_descriptors(img_tensor):
    img_np = img_tensor.squeeze().numpy() * 255
    img_np = img_np.astype(np.uint8)
    keypoints, descriptors = sift.detectAndCompute(img_np, None)
    return descriptors

print("Extracting SIFT descriptors from training set...")
all_descriptors = []

n_train_samples = 10000

for i in tqdm(range(n_train_samples)):
    img, label = train_dataset[i]
    descriptors = extract_sift_descriptors(img)
    if descriptors is not None:
        all_descriptors.append(descriptors)

all_descriptors = np.vstack(all_descriptors)
print(f"Total descriptors shape: {all_descriptors.shape}")

# KMeans 聚类
n_clusters = 200
print(f"Clustering descriptors with KMeans (n_clusters={n_clusters})...")
kmeans = MiniBatchKMeans(n_clusters=n_clusters, batch_size=10000, verbose=1)
kmeans.fit(all_descriptors)

# BoVW 直方图
def compute_bovw_histogram(descriptors, kmeans_model, n_clusters):
    if descriptors is None:
        return np.zeros(n_clusters)
    
    words = kmeans_model.predict(descriptors)
    histogram, _ = np.histogram(words, bins=np.arange(n_clusters + 1))
    histogram = histogram.astype(float)
    # L2归一化
    histogram /= np.linalg.norm(histogram) + 1e-7
    return histogram

print("Generating BoVW histograms for training set...")
X_train = []
y_train = []

for i in tqdm(range(n_train_samples)):
    img, label = train_dataset[i]
    descriptors = extract_sift_descriptors(img)
    histogram = compute_bovw_histogram(descriptors, kmeans, n_clusters)
    X_train.append(histogram)
    y_train.append(label)

X_train = np.array(X_train)
y_train = np.array(y_train)

print("Training SVM classifier...")
svm = SVC(kernel='rbf', C=100, gamma=0.01)
svm.fit(X_train, y_train)

print("Testing on test set...")

X_test = []
y_test = []

for i in tqdm(range(len(test_dataset))):
    img, label = test_dataset[i]
    descriptors = extract_sift_descriptors(img)
    histogram = compute_bovw_histogram(descriptors, kmeans, n_clusters)
    X_test.append(histogram)
    y_test.append(label)

X_test = np.array(X_test)
y_test = np.array(y_test)

# 预测 + 评估
y_pred = svm.predict(X_test)
acc = accuracy_score(y_test, y_pred)
print(f"Accuracy on test set: {acc * 100:.2f}%")

# 混淆矩阵
cm = confusion_matrix(y_test, y_pred)
plt.figure(figsize=(10, 8))
sns.heatmap(cm, annot=True, fmt="d", cmap="Blues")
plt.title("Confusion Matrix (BoVW + SVM)")
plt.xlabel("Predicted")
plt.ylabel("True")
plt.show()

