import numpy as np
from scipy import stats

# 示例数据
#data = np.array([4040, 2990, 2964, 3245, 3026, 3633, 3387, 4136, 3595, 3194, 3714, 2831, 3845, 3410, 3004])

# 计算均值和标准误差
xbar = 803
ybar = 938
s_1 = 75
s_2 = 102
n = 100

# 置信水平（例如95%）
confidence_level = 0.95
alpha = 1 - confidence_level

# 计算分布临界值
z1 = stats.norm.ppf(1-alpha/2)
z2 = stats.norm.ppf(1-alpha)

# 置信区间(双侧)
ci_upper = xbar - ybar + z1 * np.sqrt((s_1**2/n) + (s_2**2/n))
ci_lower = xbar - ybar - z1 * np.sqrt((s_1**2/n) + (s_2**2/n))
print(f"95%置信区间: {ci_lower:.2f},{ci_upper:.2f}")

# 置信区间(下侧)
ci_lower_one_sided = xbar - ybar - z2 * np.sqrt((s_1**2/n) + (s_2**2/n))
print(f"95%单侧置信区间: {ci_lower_one_sided:.2f}")
