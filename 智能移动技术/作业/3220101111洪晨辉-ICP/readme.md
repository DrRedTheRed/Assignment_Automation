Dr.Red 2025.4.15

### 组织结构：
#### 代码
- **icp_mine_acc.m ->累计算法，最好，请以此评判**
- icp_mine_no_acc.m ->相邻帧算法
- icp_point_to_line.m ->累计点对线算法，废案
- rmse.m ->打酱油的，用来计算RMSE和最大误差

#### 图图
- ICP_results ->相邻帧算法结果
- ICP_results_acc ->累计算法结果
- ICP_results_p2l ->累计点对线算法结果

#### 变量
- robot_tf_true_a.mat ->累计算法真值（由pcregistericp提供）
- robot_tf_true_na.mat ->相邻帧算法真值（同理。请务必以这个评判相邻帧算法，不然太作弊了）
- robot_tf_acc.mat ->累计算法值
- robot_tf_no_acc.mat ->相邻帧算法值
- robot_tf_r2l.mat ->累计点对线算法值

#### 报告
- 报告。