import numpy as np
import matplotlib.pyplot as plt
from scipy.stats import multinomial

n, p = 10, [0.2, 0.3, 0.5]  # 3个类别
x = np.arange(0, n+1)
X, Y = np.meshgrid(x, x)
Z = n - X - Y  # X+Y+Z=n

valid = (Z >= 0) & (Z <= n)
pmf_values = np.zeros_like(X, dtype=float)
for i in x:
    for j in x:
        if valid[i,j]:
            pmf_values[i,j] = multinomial.pmf([i,j,n-i-j], n, p)

fig = plt.figure(figsize=(10,6))
ax = fig.add_subplot(111, projection='3d')
ax.bar3d(X[valid], Y[valid], np.zeros_like(Z[valid]), 
        1, 1, pmf_values[valid], shade=True)
ax.set_xlabel('X1'); ax.set_ylabel('X2'); ax.set_zlabel('Probability')
plt.title(f"Multinomial PMF (n={n}, p={p})")
plt.show()