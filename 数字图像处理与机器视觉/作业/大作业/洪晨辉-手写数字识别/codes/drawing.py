import numpy as np
from mpl_toolkits.mplot3d import Axes3D
import matplotlib.pyplot as plt
from scipy.stats import chisquare

def plot_3d_surface():
    X = np.linspace(0.1, 0.9, 5)
    Y = np.linspace(2, 10, 5)
    X, Y = np.meshgrid(X, Y)
    Z = np.array([80.39,82.05,83.34,83.36,79.28,
                82.36,83.57,81.8,78.43,66.97,
                82.54,79.99,75.88,65.57,51.2,
                76.81,69.41,60.77,49.99,33.65,
                65.78,54.27,42.72,30.96,23.85])
    Z = Z.reshape(X.shape)

    fig = plt.figure()
    ax = fig.add_subplot(111, projection='3d')
    ax.plot_surface(X, Y, Z, cmap='viridis')

    ax.set_xlabel('Threshold')
    ax.set_ylabel('Number of Samples')
    ax.set_zlabel('Percentage (%)')
    ax.set_title('3D Surface Plot of Accuracy')

    plt.show()

from statsmodels.stats.proportion import proportions_ztest

def plot_2d():
    # 你的观测数据
    labels = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9]
    values = [6, 9, 10, 10, 10, 8 ,9, 9, 5, 10]

    # 绘制条形图
    plt.figure()
    plt.bar(labels, values, color='skyblue')
    plt.xlabel('Category')
    plt.ylabel('The number of true samples')
    plt.title('Characteristics of True Samples in Method 3')
    plt.show()

    # Proportions Z-test
    n_success = sum(values)  # 观测成功数
    n_total = 100            # 总样本数
    p_random = 0.1           # 随机猜测成功率

    stat, p_value = proportions_ztest(count=n_success, nobs=n_total, value=p_random, alternative='larger')

    print(f"Total correct: {n_success}/{n_total} ({n_success/n_total:.2%})")
    print(f"Z statistic: {stat:.4f}")
    print(f"P-value: {p_value:.4e}")

    if p_value < 0.05:
        print("Result: The method is significantly better than random guessing (reject null hypothesis).")
    else:
        print("Result: Cannot reject the null hypothesis — the method may not be better than random guessing.")

def pair_t_test():
    from scipy import stats

    data2 = [1, 9, 10, 7, 9, 3, 8, 9, 8, 8]
    data1 = [6, 9, 10, 10, 10, 8 ,9, 9, 5, 10]
    t_stat, p_value = stats.ttest_rel(data1, data2)
    return t_stat, p_value

if __name__ == "__main__":
    # plot_3d_surface()
    # plot_2d()
    t_stat, p_value = pair_t_test()

    print(f"Paired t-test statistic: {t_stat:.4f}, p-value: {p_value:.4e}")
    if p_value < 0.05:
        print("Result: The two methods are significantly different (reject null hypothesis).")
    else:
        print("Result: Cannot reject the null hypothesis — the two methods may not be significantly different.")
