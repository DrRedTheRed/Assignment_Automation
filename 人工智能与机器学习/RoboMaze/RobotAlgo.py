# 导入相关包 
import os
import random
import numpy as np
from Maze import Maze
from Runner import Runner
from QRobot import QRobot
from ReplayDataSet import ReplayDataSet
from torch_py.MinDQNRobot import MinDQNRobot as TorchRobot # PyTorch版本
from keras_py.MinDQNRobot import MinDQNRobot as KerasRobot # Keras版本
import matplotlib.pyplot as plt


import numpy as np
class SearchTree(object):

    def __init__(self, loc=(), action='', parent=None):
        """
        初始化搜索树节点对象
        :param loc: 新节点的机器人所处位置
        :param action: 新节点的对应的移动方向
        :param parent: 新节点的父辈节点
        """

        self.loc = loc  # 当前节点位置
        self.to_this_action = action  # 到达当前节点的动作
        self.parent = parent  # 当前节点的父节点
        self.children = []  # 当前节点的子节点

    def add_child(self, child):
        """
        添加子节点
        :param child:待添加的子节点
        """
        self.children.append(child)

    def is_leaf(self):
        """
        判断当前节点是否是叶子节点
        """
        return len(self.children) == 0


def expand(maze, is_visit_m, node):
    """
    拓展叶子节点，即为当前的叶子节点添加执行合法动作后到达的子节点
    :param maze: 迷宫对象
    :param is_visit_m: 记录迷宫每个位置是否访问的矩阵
    :param node: 待拓展的叶子节点
    """
    move_map = {
        'u': (-1, 0),  # up
        'r': (0, +1),  # right
        'd': (+1, 0),  # down
        'l': (0, -1),  # left
    }
    can_move = maze.can_move_actions(node.loc)
    for a in can_move:
        new_loc = tuple(node.loc[i] + move_map[a][i] for i in range(2))
        if not is_visit_m[new_loc]:
            child = SearchTree(loc=new_loc, action=a, parent=node)
            node.add_child(child)


def back_propagation(node):
    """
    回溯并记录节点路径
    :param node: 待回溯节点
    :return: 回溯路径
    """
    path = []
    while node.parent is not None:
        path.insert(0, node.to_this_action)
        node = node.parent
    return path


def my_search(maze):

    start = maze.sense_robot()
    root = SearchTree(loc=start)
    stack = [root]
    h, w, _ = maze.maze_data.shape
    is_visit_m = np.zeros((h, w), dtype=np.int32)  # 标记迷宫的各个位置是否被访问过
    # 用于记录找到的路径
    path = []  
    while True:
        # 从栈中取出最后一个节点作为当前节点
        current_node = stack[-1]
        # 标记当前节点位置已访问
        is_visit_m[current_node.loc] = 1  
        # 如果当前节点位置是迷宫的目的地
        if current_node.loc == maze.destination:  
            path = back_propagation(current_node)
            break
        # 初始化当前节点的子节点列表
        current_node.children=[]
        expand(maze, is_visit_m, current_node)

        if current_node.is_leaf():
            # 从栈中移除当前节点
            stack.pop(-1)
        else:
            # 将当前节点的所有子节点添加到栈中
            for child in current_node.children:
                stack.append(child)
               
    return path

import os
import random
import numpy as np
import torch
from QRobot import QRobot
from ReplayDataSet import ReplayDataSet
from torch_py.MinDQNRobot import MinDQNRobot as TorchRobot
import matplotlib.pyplot as plt


class Robot(TorchRobot):
    def __init__(self, maze):
        super().__init__(maze)
        # 设迷宫奖励，负向强化目的地奖励以突出目标重要性
        maze.set_reward({"hit_wall": 10., "destination": -maze.maze_size ** 2 * 10, "default": 1.})
        self.maze = maze
        self.epsilon = 0
        # 建全图视野加速学习决策
        self.memory.build_full_view(maze)
        self.train()

    def train(self):
        # 持续训练直至成功出迷宫
        while True:
            self._learn(batch=len(self.memory))
            self.reset()
            for _ in range(self.maze.maze_size ** 2):
                action, reward = self.test_update()
                if reward == self.maze.reward["destination"]:
                    return

    def train_update(self):
        # 依状态选动作获奖励
        state = self.sense_state()
        action = self._choose_action(state)
        reward = self.maze.move_robot(action)
        return action, reward

    def test_update(self):
        # 转状态为张量算 Q 值选动作获奖励
        state = np.array(self.sense_state(), dtype=np.int16)
        state = torch.from_numpy(state).float().to(self.device)
        with torch.no_grad():
            q_value = self.eval_model(state).cpu().data.numpy()
        action = self.valid_action[np.argmin(q_value).item()]
        reward = self.maze.move_robot(action)
        return action, reward