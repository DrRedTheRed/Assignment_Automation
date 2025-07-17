import os
import numpy as np
import jieba as jb
import jieba.analyse
import torch
import torch.nn as nn
from torch.utils import data

# 设备选择：优先使用 GPU，若不可用则使用 CPU
device = torch.device('cuda:0' if torch.cuda.is_available() else 'cpu')

# 作者列表及相关映射字典初始化
int2author = ['LX', 'MY', 'QZS', 'WXB', 'ZAL']
author_num = len(int2author)
author2int = {author: i for i, author in enumerate(int2author)}

# 数据集初始化及加载
dataset_init = []
data_path = 'dataset/'
for file in os.listdir(data_path):
    if not os.path.isdir(file) and not file.startswith('.'):  # 排除隐藏文件和文件夹
        file_path = os.path.join(data_path, file)
        try:
            with open(file_path, 'r', encoding='UTF-8') as f:
                for line in f.readlines():
                    dataset_init.append((line, author2int[file[:-4]]))
        except UnicodeDecodeError:
            print(f"文件 {file_path} 编码错误，无法读取，请检查编码。")

# 词频统计及特征提取
str_full = [''] * author_num
for sentence, label in dataset_init:
    str_full[label] += sentence

words = set()
for text in str_full:
    words.update(jb.analyse.extract_tags(text, topK=800, withWeight=False))

int2word = list(words)
word_num = len(int2word)
word2int = {word: i for i, word in enumerate(int2word)}

features = torch.zeros((len(dataset_init), word_num))
labels = torch.zeros(len(dataset_init))
for i, (sentence, author_idx) in enumerate(dataset_init):
    feature = torch.zeros(word_num, dtype=torch.float)
    for word in jb.lcut(sentence):
        if word in words:
            feature[word2int[word]] += 1
    if feature.sum():
        feature /= feature.sum()
        features[i] = feature
        labels[i] = author_idx
    else:
        labels[i] = 5  # 无法识别作者标记为 5

dataset = data.TensorDataset(features, labels)

# 数据集划分与加载器创建
valid_split = 0.3
train_size = int((1 - valid_split) * len(dataset))
valid_size = len(dataset) - train_size
train_dataset, test_dataset = torch.utils.data.random_split(dataset, [train_size, valid_size])
train_loader = data.DataLoader(train_dataset, batch_size=32, shuffle=True)
valid_loader = data.DataLoader(test_dataset, batch_size=1000, shuffle=True)

# 模型构建与初始化
model = nn.Sequential(
    nn.Linear(word_num, 512),
    nn.ReLU(),
    nn.Linear(512, 1024),
    nn.ReLU(),
    nn.Linear(1024, 6)
).to(device)

# 损失函数与优化器定义
loss_fn = nn.CrossEntropyLoss()
optimizer = torch.optim.Adam(model.parameters(), lr=1e-4)
best_acc = 0
best_model = model.state_dict()

# 训练循环
for epoch in range(40):
    valid_acc = 0
    for b_x, b_y in train_loader:
        b_x, b_y = b_x.to(device), b_y.to(device)
        out = model(b_x)
        loss = loss_fn(out, b_y.long())
        optimizer.zero_grad()
        loss.backward()
        optimizer.step()
        del out
    with torch.no_grad():
        correct_num = 0
        total_num = 0
        for b_x, b_y in valid_loader:
            b_x, b_y = b_x.to(device), b_y.to(device)
            out = model(b_x)
            _, predicted = torch.max(out.data, 1)
            total_num += b_y.size(0)
            correct_num += (predicted == b_y).sum().item()
            del out
        valid_acc = correct_num / total_num
    if valid_acc > best_acc:
        best_acc = valid_acc
        best_model = model.state_dict()
        torch.save({
            'word2int': word2int,
            'int2author': int2author,
            'model': best_model,
            }, 'results/test_model.pth')
    print(f'epoch:{epoch} | valid_acc:{valid_acc:.4f}')
