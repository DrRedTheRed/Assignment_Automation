import os
import numpy as np
import torch
from torchvision import datasets, transforms
from sklearn.metrics import accuracy_score
from tqdm import tqdm

transform = transforms.Compose([
    transforms.ToTensor()
])
train_dataset = datasets.MNIST(root='../data', train=True, download=True, transform=transform)
test_dataset = datasets.MNIST(root='../data', train=False, download=True, transform=transform)

def extract_feature(image_tensor):
    """
    将 28x28 图像划分为 7x7 小块，每块 4x4，生成 49 维 0/1 特征向量。
    """
    image = image_tensor.squeeze().numpy()
    feature = []
    for i in range(0, 28, 4):
        for j in range(0, 28, 4):
            block = image[i:i+4, j:j+4]
            threshold = (block > 0.3).sum()
            feature.append(1 if threshold > 4 else 0)
    return np.array(feature)

train_feature_file = './train_features.pt'

if os.path.exists(train_feature_file):
    print("加载已有模板库...")
    data = torch.load(train_feature_file)
    train_features = data['features']
    train_labels = data['labels']
else:
    print("提取训练集特征并保存模板库...")
    train_features = []
    train_labels = []
    for i in tqdm(range(len(train_dataset)), desc="Extracting train features"):
        img, label = train_dataset[i]
        vec = extract_feature(img)
        train_features.append(vec)
        train_labels.append(label)
    train_features = np.array(train_features)
    train_labels = np.array(train_labels)

    torch.save({
        'features': train_features,
        'labels': train_labels
    }, train_feature_file)
    print(f"模板库已保存到 {train_feature_file}")

test_features = []
test_labels = []
predicted_labels = []

for i in tqdm(range(len(test_dataset)), desc="Matching test samples"):
    img, label = test_dataset[i]
    vec = extract_feature(img)
    test_features.append(vec)
    test_labels.append(label)

    distances = np.linalg.norm(train_features - vec, axis=1)
    min_index = np.argmin(distances)
    predicted_labels.append(train_labels[min_index])

accuracy = accuracy_score(test_labels, predicted_labels)
print(f"匹配准确率：{accuracy * 100:.2f}%")

