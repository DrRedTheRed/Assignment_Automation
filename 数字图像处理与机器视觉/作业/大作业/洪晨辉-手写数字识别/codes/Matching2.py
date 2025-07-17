import torch
from torchvision import datasets, transforms
from PIL import Image
import os
import numpy as np
import matplotlib.pyplot as plt

def extract_feature(img_tensor):
    img_tensor = img_tensor.squeeze()
    feature = []
    for i in range(0, 28, 4):
        for j in range(0, 28, 4):
            block = img_tensor[i:i+4, j:j+4]
            count = torch.sum(block > 0.3).item()  # 阈值
            bit = 1 if count > 4 else 0
            feature.append(bit)
    return torch.tensor(feature, dtype=torch.float32)

def build_template_library(train_dataset, save_path="train_features.pt"):
    if os.path.exists(save_path):
        print("已检测到缓存，正在加载模板库...")
        data = torch.load(save_path)
        features = torch.tensor(data['features']) if isinstance(data['features'], np.ndarray) else data['features']
        labels = torch.tensor(data['labels']) if isinstance(data['labels'], np.ndarray) else data['labels']
        return features, labels
    print("第一次运行，正在提取模板库特征...")
    features = []
    labels = []
    for img, label in train_dataset:
        f = extract_feature(img)
        features.append(f)
        labels.append(label)
    features = torch.stack(features)
    labels = torch.tensor(labels)
    torch.save({'features': features.cpu(), 'labels': labels.cpu()}, save_path)
    return features, labels


def predict_label(test_feature, template_features, template_labels):
    distances = torch.norm(template_features - test_feature, dim=1)
    min_index = torch.argmin(distances)
    return template_labels[min_index].item(), distances[min_index].item()

def load_custom_image(path):
    image = Image.open(path).convert('L').resize((28, 28))
    transform = transforms.Compose([
        transforms.ToTensor(),
        transforms.Lambda(lambda x: 1.0 - x),
    ])
    return transform(image)

def show_digit_feature_examples(dataset):
    shown = set()
    fig, axes = plt.subplots(2, 5, figsize=(12, 5))
    for img, label in dataset:
        if label not in shown:
            f = extract_feature(img)
            ax = axes[label // 5][label % 5]
            ax.imshow(f.view(7, 7), cmap='gray', vmin=0, vmax=1)
            ax.set_title(f"Digit {label}")
            ax.axis('off')
            shown.add(label)
        if len(shown) == 10:
            break
    plt.tight_layout()
    plt.show()

def process_and_predict_images_in_batches(image_folder, template_features, template_labels):
    for digit in range(10):  # 分10轮
        fig, axes = plt.subplots(1, 10, figsize=(20, 3))
        print(f"📢 当前轮次：数字 {digit} 的 10 张图")
        for i in range(10):  # 每轮显示10张图
            img_path = os.path.join(image_folder, f"{digit}.{i}.png")
            ax = axes[i]
            if os.path.exists(img_path):
                img_tensor = load_custom_image(img_path)
                test_feature = extract_feature(img_tensor)
                predicted_label, predicted_distance = predict_label(test_feature, template_features, template_labels)
                
                ax.imshow(img_tensor.squeeze(), cmap='gray')
                ax.set_title(f"GT:{digit}\nPred:{predicted_label}", fontsize=10)
            else:
                ax.set_facecolor('lightgray')
                ax.set_title(f"Missing\n{digit}.{i}.png", fontsize=8)
            ax.axis('off')
        plt.tight_layout()
        plt.show()
        input("按回车键继续到下一轮...")  # 手动控制每轮，按回车继续

def predict_custom_image(custom_img_path, template_features, template_labels):
    """预测自定义图像的标签"""
    if os.path.exists(custom_img_path):
        img_tensor = load_custom_image(custom_img_path)
        test_feature = extract_feature(img_tensor)
        predicted_label, predicted_distance = predict_label(test_feature, template_features, template_labels)
        print(f"预测结果：{predicted_label}, 距离：{predicted_distance:.4f}")

        distances = torch.norm(template_features - test_feature, dim=1)
        min_index = torch.argmin(distances)
        matched_feature = template_features[min_index]
        matched_label = template_labels[min_index]

        fig, axes = plt.subplots(1, 3, figsize=(12, 4))
        axes[0].imshow(img_tensor.squeeze(), cmap='gray')
        axes[0].set_title("test_image")
        axes[1].imshow(test_feature.view(7, 7), cmap='gray', vmin=0, vmax=1)
        axes[1].set_title("feature_image")
        axes[2].imshow(matched_feature.view(7, 7), cmap='gray', vmin=0, vmax=1)
        axes[2].set_title(f"matched_feature_image\n(label={matched_label.item()})")
        for ax in axes:
            ax.axis('off')
        plt.tight_layout()
        plt.show()
    else:
        print(f"未找到自定义图像：{custom_img_path}")

def main():
    transform = transforms.Compose([
        transforms.ToTensor()
    ])
    mnist_train = datasets.MNIST(root='../data', train=True, download=True, transform=transform)

    template_features, template_labels = build_template_library(mnist_train)

    print("正在显示0~9的特征图像...")
    raw_train = datasets.MNIST(root='../data', train=True, download=True, transform=transforms.ToTensor())
    show_digit_feature_examples(raw_train)

    print("正在批量预测 hand_written/0.x -> 9.x 中的自定义图像...")
    image_folder = "hand_written"
    process_and_predict_images_in_batches(image_folder, template_features, template_labels)

    print("正在预测自定义图像...")
    custom_img_path = 'hand_written/8.5.png'
    predict_custom_image(custom_img_path, template_features, template_labels)

    

if __name__ == '__main__':
    main()
