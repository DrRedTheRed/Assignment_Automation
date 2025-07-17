# Write the path to the IK folder here
# For example, the IK folder is in your Documents folder
import sys
import getpass
import scipy.spatial.transform

sys.path.append(f"E:/study/robot/simulation1/IK")

import IK
import numpy as np

# import sim

####################################
### You Can Write Your Code Here ###
####################################


def sysCall_init():
    sim = require('sim')
    doSomeInit()
    '''
    逆运动学求解器求得的各组解如下，
    group1:
    [1.04691599, 0.5432342, 0.53145443, -0.55151197, 0.52390861, 0.69854057], 
    [1.04691599, 1.05168991, -0.53145443, 0.00294118, 0.52390861, 0.69854057]
    group2:
    [1.57152579, 0.460517090, 0.660833891, -0.0745121879, 0.523635156, 0.00132213667], 
    [1.57152579, 1.09236787, -0.660833891, 0.615304812, 0.523635156, 0.00132213667]
    group3:
    [0.63810904, 0.78999758, 1.34326213, -1.31694923, -0.01049602, 0.01012841], 
    group4:
    [-0.06591846, 0.82735641, 0.82452922, -1.08013166, 0.05459678, -0.03619458],
    group5:
    [-0.7356519, 1.10250937, 1.05320703, -0.87536181, 0.07485627, -0.01280543], 
    '''
    self.q0 = np.zeros(6)
    self.joint_angles = np.array([1.04691599,1.05168991,-0.53145443,0.00294118,0.52390861,0.69854057]) #用上述求得的解一一替换，得到对应位姿


def sysCall_actuation():
    endEffectorHandle = sim.getObject('/Robot/SuctionCup/SuctionCup_end')
    position = sim.getObjectPosition(endEffectorHandle, -1) 
    orientation = sim.getObjectOrientation(endEffectorHandle, -1) 

    print("Position: ", position[0], position[1], position[2])

    print("Orientation: ", orientation[0], orientation[1], orientation[2])

    
    t = sim.getSimulationTime()
    q = self.q0
    state = False
    # robot takes 5s to move from q0 to q1.
    if t < 5:
        q = trajPlaningDemo(self.q0, self.joint_angles, t, 5)
    elif t < 10:
        q = self.joint_angles
    elif t > 10:
        sim.pauseSimulation()

    runState = move(q, state)

    if not runState:
        sim.pauseSimulation()

####################################################
### You Don't Have to Change the following Codes ###
####################################################


def doSomeInit():
    self.Joint_limits = (
        np.array(
            [[-200, -90, -120, -150, -150, -180], [200, 90, 120, 150, 150, 180]]
        ).transpose()
        / 180
        * np.pi
    )
    self.Vel_limits = np.array([100, 100, 100, 100, 100, 100]) / 180 * np.pi
    self.Acc_limits = np.array([500, 500, 500, 500, 500, 500]) / 180 * np.pi

    self.lastPos = np.zeros(6)
    self.lastVel = np.zeros(6)
    self.sensorVel = np.zeros(6)

    self.robotHandle = sim.getObject("/Robot")
    self.suctionHandle = sim.getObject("/Robot/SuctionCup")
    self.jointHandles = []
    for i in range(6):
        self.jointHandles.append(sim.getObject("/Robot/Joint" + str(i + 1)))
    sim.writeCustomStringData(self.suctionHandle, "activity", "off")
    sim.writeCustomStringData(self.robotHandle, "error", "0")

    self.dataPos = []
    self.dataVel = []
    self.dataAcc = []
    self.graphPos = sim.getObject("/Robot/DataPos")
    self.graphVel = sim.getObject("/Robot/DataVel")
    self.graphAcc = sim.getObject("/Robot/DataAcc")
    color = [[1, 0, 0], [0, 1, 0], [0, 0, 1], [1, 1, 0], [1, 0, 1], [0, 1, 1]]
    for i in range(6):
        self.dataPos.append(
            sim.addGraphStream(self.graphPos, "Joint" + str(i + 1), "deg", 0, color[i])
        )
        self.dataVel.append(
            sim.addGraphStream(
                self.graphVel, "Joint" + str(i + 1), "deg/s", 0, color[i]
            )
        )
        self.dataAcc.append(
            sim.addGraphStream(
                self.graphAcc, "Joint" + str(i + 1), "deg/s2", 0, color[i]
            )
        )


def trajPlaningDemo(start, end, t, time):
    """Quintic Polynomial: x = k5*t^5 + k4*t^4 + k3*t^3 + k2*t^2 + k1*t + k0
    :param start: Start point
    :param end: End point
    :param t: Current time
    :param time: Expected time spent
    :return: The value of the current time in this trajectory planning
    """
    if t < time:
        tMatrix = np.matrix(
            [
                [0, 0, 0, 0, 0, 1],
                [time**5, time**4, time**3, time**2, time, 1],
                [0, 0, 0, 0, 1, 0],
                [5 * time**4, 4 * time**3, 3 * time**2, 2 * time, 1, 0],
                [0, 0, 0, 2, 0, 0],
                [20 * time**3, 12 * time**2, 6 * time, 2, 0, 0],
            ]
        )

        xArray = []
        for i in range(len(start)):
            xArray.append([start[i], end[i], 0, 0, 0, 0])
        xMatrix = np.matrix(xArray).T

        kMatrix = tMatrix.I * xMatrix

        timeVector = np.matrix([t**5, t**4, t**3, t**2, t, 1]).T
        x = (kMatrix.T * timeVector).T.A[0]

    else:
        x = end

    return x


# def sysCall_sensing():
#     # put your sensing code here
#     if sim.readCustomStringData(self.robotHandle, "error") == "1":
#         return
#     for i in range(6):
#         pos = sim.getJointPosition(self.jointHandles[i])
#         if i == 0:
#             if pos < -160 / 180 * np.pi:
#                 pos += 2 * np.pi
#         vel = sim.getJointVelocity(self.jointHandles[i])
#         acc = (vel - self.sensorVel[i]) / sim.getSimulationTimeStep()
#         if pos < self.Joint_limits[i, 0] or pos > self.Joint_limits[i, 1]:
#             print("Error: Joint" + str(i + 1) + " Position Out of Range!")
#             sim.writeCustomStringData(self.robotHandle, "error", "1")
#             return

#         if abs(vel) > self.Vel_limits[i]:
#             print("Error: Joint" + str(i + 1) + " Velocity Out of Range!")
#             sim.writeCustomStringData(self.robotHandle, "error", "1")
#             return

#         if abs(acc) > self.Acc_limits[i]:
#             print("Error: Joint" + str(i + 1) + " Acceleration Out of Range!")
#             sim.writeCustomStringData(self.robotHandle, "error", "1")
#             return

#         sim.setGraphStreamValue(self.graphPos, self.dataPos[i], pos * 180 / np.pi)
#         sim.setGraphStreamValue(self.graphVel, self.dataVel[i], vel * 180 / np.pi)
#         sim.setGraphStreamValue(self.graphAcc, self.dataAcc[i], acc * 180 / np.pi)
#         self.sensorVel[i] = vel


def move(q, state):
    # if sim.readCustomStringData(self.robotHandle, "error") == "1":
    #     return
    for i in range(6):
        if q[i] < self.Joint_limits[i, 0] or q[i] > self.Joint_limits[i, 1]:
            print("move(): Joint" + str(i + 1) + " Position Out of Range!")
            return False
        if (
            abs(q[i] - self.lastPos[i]) / sim.getSimulationTimeStep()
            > self.Vel_limits[i]
        ):
            print("move(): Joint" + str(i + 1) + " Velocity Out of Range!")
            return False
        if (
            abs(self.lastVel[i] - (q[i] - self.lastPos[i]))
            / sim.getSimulationTimeStep()
            > self.Acc_limits[i]
        ):
            print("move(): Joint" + str(i + 1) + " Acceleration Out of Range!")
            return False

    self.lastPos = q
    self.lastVel = q - self.lastPos

    for i in range(6):
        sim.setJointTargetPosition(self.jointHandles[i], q[i])

    if state:
        sim.writeCustomStringData(self.suctionHandle, "activity", "on")
    else:
        sim.writeCustomStringData(self.suctionHandle, "activity", "off")

    return True