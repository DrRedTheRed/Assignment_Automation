import time
import random
import math
import copy

BOARD_SIZE = 8 #棋盘行数与列数
PLAYER_NUM = -1 #在board中代表玩家的数字
COMPUTER_NUM = 1 #在board中代表带电脑的数字
MAX_THINK_TIME = 5  #电脑的最大思考时间
# 表示棋盘坐标点的8个不同方向坐标，比如方向坐标[0][1]则表示坐标点的正上方。
direction = [(-1, 0), (-1, 1), (0, 1), (1, 1), (1, 0), (1, -1), (0, -1), (-1, -1)]
BLACK_NUM = -1 #代表黑棋的数字
WHITE_NUM = 1 #代表白棋的数字
PATHROOT = [] #节点树

#蒙特卡洛算法部分：

# 返回棋子数
def countTile(board,tile):
    stones = 0
    negstones = 0
    for i in range(0, BOARD_SIZE):
        for j in range(0, BOARD_SIZE):
            if board[i][j] == tile:
                stones+=1
            elif board[i][j] == -tile:
                negstones+=1

    return stones,negstones

# 返回一个颜色棋子可落子位置
def possible_positions(board, tile): 
    positions = []
    for i in range(0, BOARD_SIZE):
        for j in range(0, BOARD_SIZE):
            if board[i][j] != 0:
                continue
            if isok(board, tile, i, j):
                positions.append((i, j))
    return positions

#检测对应位置是否在棋盘
def isOnBoard(x, y): 
    return x >= 0 and x <= 7 and y >= 0 and y <= 7

#检测该位置是否可以落子
def isok(board,tile,i,j): 
    change = -tile
    if(board[i][j]!=0):
        return False
    for xdirection, ydirection in direction:
        x, y = i, j
        x += xdirection
        y += ydirection
        if isOnBoard(x, y) and board[x][y] == change: #该点朝一dirction方向相邻一个棋子，且相邻的棋子为可以被翻转的数字
            # 一直走到出界或不是对方棋子的位置
            while board[x][y] == change:
                x += xdirection
                y += ydirection
                if not isOnBoard(x, y):
                    break
            # 出界了，则直接进行下一个方向的查找
            if not isOnBoard(x, y):
                continue
            # 是自己的棋子，中间的所有棋子都要翻转
            if board[x][y] == tile:
                return True
    return False

# 是否是合法走法，如果合法返回需要翻转的棋子列表
def updateBoard(board, tile, i, j):
    change = -tile
    need_turn = [] # 要被翻转的棋子
    for xdirection, ydirection in direction:
        x, y = i, j
        x += xdirection
        y += ydirection
        if isOnBoard(x, y) and board[x][y] == change: #该点朝一dirction方向相邻一个棋子，且相邻的棋子为可以被翻转的数字
            # 一直走到出界或不是对方棋子的位置
            while board[x][y] == change:
                x += xdirection
                y += ydirection
                if not isOnBoard(x, y):
                    break
            # 出界了，则直接进行下一个方向的查找
            if not isOnBoard(x, y):
                continue
            # 是自己的棋子，中间的所有棋子都要翻转
            if board[x][y] == tile:
                while True:
                    x -= xdirection
                    y -= ydirection
                    # 回到了起点则结束
                    if x == i and y == j:
                        break
                    # 需要翻转的棋子
                    need_turn.append([x, y])
    # 翻转棋子
    board[i][j] = tile
    for x, y in need_turn:
        board[x][y] = tile
    return len(need_turn)


# 上面的代码用于返回要被翻转的棋子个数，这里的代码用于将更新后的棋盘输出
def updateAIBoard(board, tile, i, j):
    change = -tile
    need_turn = [] # 要被翻转的棋子
    for xdirection, ydirection in direction:
        x, y = i, j
        x += xdirection
        y += ydirection
        if isOnBoard(x, y) and board[x][y] == change: #该点朝一dirction方向相邻一个棋子，且相邻的棋子为可以被翻转的数字
            # 一直走到出界或不是对方棋子的位置
            while board[x][y] == change:
                x += xdirection
                y += ydirection
                if not isOnBoard(x, y):
                    break
            # 出界了，则直接进行下一个方向的查找
            if not isOnBoard(x, y):
                continue
            # 是自己的棋子，中间的所有棋子都要翻转
            if board[x][y] == tile:
                while True:
                    x -= xdirection
                    y -= ydirection
                    # 回到了起点则结束
                    if x == i and y == j:
                        break
                    # 需要翻转的棋子
                    need_turn.append([x, y])
    # 翻转棋子
    board[i][j] = tile
    for x, y in need_turn:
        board[x][y] = tile
    return board


def updatePathRoot(i,j):
    global PATHROOT
    for n_tuple in PATHROOT:
        #找到最佳路径中此节点对应的子节点
        parent, t_playout, reward, t_childrens = n_tuple
        if i == parent[0] and j == parent[1]:
            PATHROOT = t_childrens
            break

# 蒙特卡洛树搜索
def mctsNextPosition(board,ucb_c,playerNum): #棋盘、ucb公式中常数c的值
    def ucb(node_tuple, t): #t为进行循环的次数
        #  返回各个结点用于进行ucb算法的值
        name, nplayout, reward, childrens = node_tuple #四个值分别对应 落点位置、模拟对局次数 、赢的次数、子节点

        if nplayout == 0: #避免意外情况
            nplayout = 1

        if t == 0:#避免意外情况
            t = 1
        #reward 是赢的次数 nplayout是模拟对局次数,cval是常数
        return (reward / nplayout) + ucb_c * math.sqrt(math.log(t) / nplayout)

    def find_playout(tep_board, tile, depth=0): #对tep_board进行了系列随机落点后，返回最终结果胜负
        def eval_board(tep_board): #比较二者的棋子数目，判断胜负
            tileNum,negTilenum = countTile(tep_board,playerNum)
            if tileNum > negTilenum:
                #tile代表的棋胜
                return True
                #tile代表的棋负
            return False

        while(depth<120):#进行最多120次递归后返回结果
            turn_positions = possible_positions(tep_board, tile)
            if len(turn_positions) == 0: #如果没位置下棋，切换到对手回合
                tile = -tile
                neg_turn_positions = possible_positions(tep_board, tile)

                if len(neg_turn_positions) == 0: #对方也没位置下棋，结束游戏
                    return eval_board(tep_board)
                else:
                    turn_positions = neg_turn_positions

            temp = turn_positions[random.randrange(0, len(turn_positions))] # 随机放置一个棋子
            updateBoard(tep_board, tile, temp[0], temp[1])
            # 转换轮次
            tile = -tile
            depth+=1

        return eval_board(tep_board)

    #扩展结点,返回tep_board的子节点数组
    def expand(tep_board, tile):
        positions = possible_positions(tep_board, tile)
        result = []
        for temp in positions:
            result.append((temp, 0, 0, []))
        return result

    def find_path(root):
        current_path = []
        child = root
        parent_playout = 0
        for item in child: #计算父节点遍历过的次数
            name, nplayout, reward, childrens = item
            parent_playout+=nplayout
        isMCTSTurn = True

        while True:
            if len(child) == 0: #无可落子的位置,直接结束
                break
            maxidxlist = [0]
            cidx = 0
            if isMCTSTurn:
                maxval = -1
            else:
                maxval = 2

            for n_tuple in child:  #对每一个可落子的位置进行最大最小搜索
                #实现最大最小搜索，电脑选择最大值，玩家选择最小值
                if isMCTSTurn:
                    #ucb返回各个结点的值，之后就依靠这个值来进行最大最小算法
                    cval = ucb(n_tuple, parent_playout)

                    if cval >= maxval:
                        # 获取子结点中值最大的一项,并记录其id(即cidx)
                        if cval == maxval:
                            maxidxlist.append(cidx)
                        else:
                            maxidxlist = [cidx]
                            maxval = cval
                else:
                    cval = ucb(n_tuple, parent_playout)

                    if cval <= maxval:
                        #获取子节点中值最小的一项
                        if cval == maxval:
                            maxidxlist.append(cidx)
                        else:
                            maxidxlist = [cidx]
                            maxval = cval

                cidx += 1

            # 从最值结点中随机选择一处落子
            maxidx = maxidxlist[random.randrange(0, len(maxidxlist))]
            parent, t_playout, reward, t_childrens = child[maxidx]
            current_path.append(parent)
            parent_playout = t_playout
            # 选择子节点进入下一次循环
            child = t_childrens
            isMCTSTurn = not (isMCTSTurn)

        # 返回根据最大最小规则选择出来的一条路径
        return current_path

    global PATHROOT #节点树
    if len(PATHROOT) == 0:
        PATHROOT = expand(board,playerNum)
        for index, rootChild in enumerate(PATHROOT):
            current_board =  copy.deepcopy(board) #current_board记录在某处落子后的棋盘
            parent, t_playout, reward, t_childrens = rootChild
            updateBoard(current_board, playerNum, parent[0] , parent[1]) #对落子于此处的棋盘进行随机落子，使得能对其使用ucb算法（避免除以0的情况）
            t_playout =10
            reward = 0
            for i in range(1,21):
                current_board2 = copy.deepcopy(current_board) #current_board2是用来进行随机落点判断胜负的临时表盘
                isWon = find_playout(current_board2, -playerNum) #tile表示下一步谁执行
                if(isWon):
                    reward+=1
            PATHROOT[index] = (parent,t_playout,reward,t_childrens)
    #记时，防止循环时间过长
    start_time = time.time()
    slectTime = 0 #选择过程耗费的时间
    expendTime = 0#扩展过程耗费的时间
    simulationTime = 0 #模拟过程耗费的时间
    BackTime = 0 #回溯过程耗费的时间

    simulationTimes = 0
    looptime = 0

    for loop in range(0, 30): #总的遍历
        looptime += 1
        current_board =  copy.deepcopy(board) #current_board记录在某处落子后的棋盘
        # 思考最大时间限制
        if (time.time() - start_time) >= MAX_THINK_TIME:
            break

        # current_path是一个放置棋子的位置列表，根据此列表进行后续操作
        tempStartTime = time.time() #选择过程
        current_path = find_path(PATHROOT) # find_path返回:ucb算法基于root蕴含的信息,获取的最佳路径(从头结点开始的，最佳子节点在各级child数组中的index数组)，
        tempEndTime = time.time()
        slectTime += tempEndTime-tempStartTime

        tile = playerNum
        for temp in current_path:
            #将通过ucb算法得到的路径整合到一个初始棋盘中
            updateBoard(current_board, tile, temp[0], temp[1]) #最终current_board为根据路径落子得到的棋盘
            tile = -tile

        #扩展与模拟过程
        child = PATHROOT
        randomTime = 0 #进行随机落子的盘数
        rewardSum = 0 #胜利总次数
        for temp in current_path:
            #遍历最佳路径
            idx = 0
            for n_tuple in child:
                #找到最佳路径中此节点对应的子节点
                parent, t_playout, reward, t_childrens = n_tuple
                if temp[0] == parent[0] and temp[1] == parent[1]:
                    break
                idx += 1

            if temp[0] == parent[0] and temp[1] == parent[1]:
                if len(t_childrens) == 0:
                    #找到路径的叶子结点，进行拓展
                    tempStartTime = time.time()
                    t_childrens = expand(current_board, tile) #扩展过程
                    tempEndTime = time.time()
                    expendTime += tempEndTime-tempStartTime
                    randomTime = len(t_childrens) *10 #进行随机落子的盘数
                    rewardSum = 0 #胜利总次数
                    tempStartTime = time.time() #模拟过程
                    for index, rootChild in enumerate(t_childrens):#对落子于此处的棋盘进行随机落子，使得能对其使用ucb算法（避免除以0的情况）
                        child_board =  copy.deepcopy(current_board) #current_board记录在某处落子后的棋盘
                        child_parent, child_playout, reward, child_childrens = rootChild
                        tempTile = tile
                        tempNegTile = -tempTile
                        updateBoard(child_board, tempTile, child_parent[0] , child_parent[1])
                        child_playout =10
                        reward = 0
                        for i in range(1,21):
                            current_board2 = copy.deepcopy(child_board) #current_board2是用来进行随机落点判断胜负的临时表盘
                            simulationTimes+=1
                            isWon = find_playout(current_board2, tempNegTile) #tile表示下一步谁执行
                            if(isWon):
                                reward+=1
                        rewardSum+=reward
                        t_childrens[index] = (child_parent,child_playout,reward,child_childrens)
                    tempEndTime = time.time()
                    simulationTime += tempEndTime-tempStartTime
                #应用修改到本体
                child[idx] = (parent, t_playout, reward, t_childrens)
            #继续处理子结点
            child = t_childrens

        if randomTime!=0:
            tempStartTime = time.time() #反向传播过程
            child = PATHROOT
            for temp in current_path:
                #遍历最佳路径
                idx = 0
                for n_tuple in child:
                    #找到最佳路径中此节点对应的子节点
                    parent, t_playout, reward, t_childrens = n_tuple
                    if temp[0] == parent[0] and temp[1] == parent[1]:
                        break
                    idx += 1

                if temp[0] == parent[0] and temp[1] == parent[1]:
                    #找到了对应的结点，修改场数与胜利数
                    t_playout += randomTime
                    reward += rewardSum

                    #应用修改到本体
                    child[idx] = (parent, t_playout, reward, t_childrens)
                #继续处理子结点
                child = t_childrens
            tempEndTime = time.time()
            BackTime += tempEndTime-tempStartTime

    max_avg_reward = -1
    mt_result = (0, 0)
    for n_tuple in PATHROOT:
        parent, t_playout, reward, t_childrens = n_tuple

        if (t_playout > 0) and (reward / t_playout > max_avg_reward):
            mt_result = parent
            max_avg_reward = reward / t_playout
            
    print(mt_result)
    return mt_result


#形式化输出格式转换部分：

#将输入的棋盘转换为算法可以识别的0，1，-1字典形式
def convert_board(board):
    AIboard = {}
    for row_index in range(8):
        AIboard[row_index] = {}  # 先为每一行创建一个空字典，用于存放该行各列的棋子对应值
        for col_index in range(8):
            element = board[row_index][col_index]
            if element == '.':
                AIboard[row_index][col_index] = 0
            elif element == 'X':
                AIboard[row_index][col_index] = -1
            elif element == 'O':
                AIboard[row_index][col_index] = 1
    return AIboard

#将算法输出的坐标转换为如G6的字符串输出
def coordinate_to_label(coord):
    # 定义列的字母映射
    columns = {0: 'A', 1: 'B', 2: 'C', 3: 'D', 4: 'E', 5: 'F', 6: 'G', 7: 'H'}
    
    # 解析坐标，获取列和行的索引
    col_index, row_index = coord
    
    # 获取列的字母
    row_letter = columns[row_index]
    
    result = row_letter + str(col_index + 1)
    # 构建输出的标签格式，如 "G6"
    return result

        
        
class AIPlayer:
    """
    AI 玩家
    """
    

    def __init__(self, color):
        """
        玩家初始化
        :param color: 下棋方，'X' - 黑棋，'O' - 白棋
        """
        #初始化上次棋盘记录
        self.last_AIboard = None
        #初始化玩家执黑or执白
        self.color = color
    


    def get_move(self, board):
        """
        根据当前棋盘状态获取最佳落子位置
        :param board: 棋盘
        :return: action 最佳落子位置, e.g. 'A1'
        """

        if self.color == 'X':
            PLAYER_NUM = 1
            COMPUTER_NUM = -1
        else:
            PLAYER_NUM = -1
            COMPUTER_NUM = 1

        if self.color == 'X':
            player_name = '黑棋'
        else:
            player_name = '白棋'
        print("请等一会，对方 {}-{} 正在思考中...".format(player_name, self.color))

        # 将传入的board转换为算法可识别的格式
        AIboard = convert_board(board)
    
        if self.last_AIboard is not None:
            # 用于记录旧AIboard中-1的位置（坐标形式，如 (row, col)）
            old_minus_ones_positions = []
            # 用于记录新AIboard中-1的位置（坐标形式，如 (row, col)）
            new_minus_ones_positions = []
            # 统计旧AIboard中-1的数量
            old_minus_ones_count = 0
            # 统计新AIboard中-1的数量
            new_minus_ones_count = 0
            for row in range(len(self.last_AIboard)):
                for col in range(len(self.last_AIboard[row])):
                    if self.last_AIboard[col][row] == 0:
                        old_minus_ones_count += 1
                        old_minus_ones_positions.append((row, col))
            for row in range(len(AIboard)):
                for col in range(len(AIboard[row])):
                    if AIboard[col][row] == 0:
                        new_minus_ones_count += 1
                        new_minus_ones_positions.append((row, col))

            # 找出缺少的 -1 在字典中的具体行列数（即那些在旧AIboard中是-1但在新AIboard中不是的位置）
            missing_minus_ones_positions = [pos for pos in old_minus_ones_positions if pos not in new_minus_ones_positions]
            for pos in missing_minus_ones_positions:
                updateBoard(self.last_AIboard, PLAYER_NUM, pos[1], pos[0])
                updatePathRoot(pos[1], pos[0])  # 更新pathRoot

        # 获取此时机器可以落子的结点
        mcts_possibility = len(possible_positions(AIboard, COMPUTER_NUM))
        print(possible_positions(AIboard, COMPUTER_NUM))
        # 判断机器是否有棋可下
        if mcts_possibility == 0:
            return None  # 如果没位置可下，返回None表示无合适走法


        # 根据mcts算法获取落子位置
        stone_pos = mctsNextPosition(AIboard, 0.7, COMPUTER_NUM)
        updateBoard(AIboard, COMPUTER_NUM, stone_pos[0], stone_pos[1])
        AIboard = updateAIBoard(AIboard, COMPUTER_NUM, stone_pos[0], stone_pos[1])
        updatePathRoot(stone_pos[0], stone_pos[1])  # 更新pathRoot
        # 这里可以根据需求决定是否返回格式化后的位置字符串，如果需要可调用coordinate_to_label函数转换
        action = coordinate_to_label(stone_pos)
        
        self.last_AIboard = AIboard  # 更新保存的上次的操作后的棋盘

        return action
