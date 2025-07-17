import numpy as np
from scipy import stats

def chi2_distribution_value(x,df):
    """
    返回自由度为df的t分布在x处的cdf值。
    """
    return stats.chi2.cdf(x,df)

print( chi2_distribution_value(6.247, 15))