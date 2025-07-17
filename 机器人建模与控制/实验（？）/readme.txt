simulation1/
│
├── README.txt             # 项目说明文档
├── forward/               # 正运动学文件夹
│   ├── calc正运动学.ipynb  # 计算各组关节角对应的末端位姿
│   ├── 正运动学仿真验证.py  # 放在Robot3_forward.ttt中的代码，每隔5s运动到一组正运动学解对应的位姿处，并停留5s，用于验证
│   └── Robot3_forward.ttt # 正运动学仿真验证
│
├── inverse/                # 逆运动学文件夹
│   ├── calc逆运动学.py      # 自己编写的逆运动学求解器
│   ├── 逆运动学仿真验证.py  # 放在Robot3_inverse.ttt中的代码，更换self.joint_angles数组为各组解，机械臂将到达关节角对应位置，输出末端位姿
│   ├── Robot3_inverse.ttt  # 逆运动学仿真验证
│   └── image               # 仿真结果
│
└── IK                  # 默认的逆运动学求解器
