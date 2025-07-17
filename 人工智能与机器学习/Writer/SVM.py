import os
import jieba as jb
import jieba.analyse
import numpy as np
import pickle
import time
from sklearn.model_selection import train_test_split
from sklearn.svm import SVC


def load_dataset(path):
    """
    加载数据集并转换为指定格式
    :param path: 数据集路径
    :return: 数据集列表[(句子, 作者标签), ]，作者到索引的字典，索引到作者的列表
    """
    int2author = ['LX', 'MY', 'QZS', 'WXB', 'ZAL']
    author_num = len(int2author)
    author2int = {author: i for i, author in enumerate(int2author)}

    dataset_init = []
    for file in os.listdir(path):
        if not os.path.isdir(file) and not file.startswith('.'):
            with open(os.path.join(path, file), 'r', encoding='UTF-8') as f:
                for line in f.readlines():
                    dataset_init.append((line, author2int[file[:-4]]))
    return dataset_init, author2int, int2author


def generate_word_features(dataset_init, author_num):
    """
    生成词特征矩阵和标签数组
    :param dataset_init: 初始数据集
    :param author_num: 作者数量
    :return: 特征矩阵，标签数组，单词到索引字典，索引到单词列表
    """
    # 将片段组合在一起后进行词频统计
    str_full = ['' for _ in range(author_num)]
    for sentence, label in dataset_init:
        str_full[label] += sentence

    # 词频特征统计，取出各个作家前 200 的词
    words = set()
    for label, text in enumerate(str_full):
        for word in jb.analyse.extract_tags(text, topK=200, withWeight=False):
            words.add(word)

    int2word = list(words)
    word_num = len(int2word)
    word2int = {word: i for i, word in enumerate(int2word)}

    features = np.zeros((len(dataset_init), word_num))
    labels = np.zeros(len(dataset_init))
    for i, (sentence, author_idx) in enumerate(dataset_init):
        feature = np.zeros(word_num, dtype=np.float)
        for word in jb.lcut(sentence):
            if word in words:
                feature[word2int[word]] += 1
        if feature.sum():
            feature /= feature.sum()
            features[i] = feature
            labels[i] = author_idx
        else:
            labels[i] = 5  # 表示识别不了作者
    return features, labels, word2int, int2word


def train_svms(X_train, X_test, y_train, y_test, int2author):
    """
    为每个作者训练 SVM 模型并评估
    :param X_train: 训练特征集
    :param X_test: 测试特征集
    :param y_train: 训练标签集
    :param y_test: 测试标签集
    :param int2author: 索引到作者的列表
    :return: SVM 模型列表
    """
    start = time.time()
    svm_lst = []
    for i in range(len(int2author)):
        svm_i = SVC(probability=True)
        y_train_i = [1 if j == i else 0 for j in y_train]
        y_test_i = [1 if j == i else 0 for j in y_test]
        print('training svm for', int2author[i])
        svm_i.fit(X_train, y_train_i)
        print('score:', svm_i.score(X_test, y_test_i))
        svm_lst.append(svm_i)

        end = time.time()
        print('Fitting time: {:.2f} s'.format(end - start))
        start = end
    return svm_lst


if __name__ == "__main__":
    # 加载数据集
    dataset_init, author2int, int2author = load_dataset('dataset/')
    # 生成词特征
    features, labels, word2int, int2word = generate_word_features(dataset_init, len(int2author))
    # 划分训练集和测试集
    X_train, X_test, y_train, y_test = train_test_split(features, labels, test_size=0.1)
    # 训练 SVM 模型
    svm_lst = train_svms(X_train, X_test, y_train, y_test, int2author)
    # 保存模型
    with open('results/svm_model.pkl', 'wb') as f:
        pickle.dump((int2author, word2int, svm_lst), f)
    print('saved model!')