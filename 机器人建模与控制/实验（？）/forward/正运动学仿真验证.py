# Write the path to the IK folder here
# For example, the IK folder is in your Documents folder
import sys
import getpass

sys.path.append(f"E:/study/robot/simulation1/IK")

import IK
import numpy as np

# import sim

####################################
### You Can Write Your Code Here ###
####################################


def sysCall_init():
    sim = require("sim")
    # initialization the simulation
    doSomeInit()  # must have

    # using the codes, you can obtain the poses and positions of four blocks
    # pointHandles = []
    # for i in range(2):
    #     pointHandles.append(
    #         sim.getObject("/Platform1/Cuboid" + str(i + 1) + "/SuckPoint")
    #     )
    # for i in range(2):
    #     pointHandles.append(
    #         sim.getObject("/Platform1/Prism" + str(i + 1) + "/SuckPoint")
    #     )
    # # get the pose of Cuboid/SuckPoint
    # for i in range(4):
    #     print(sim.getObjectPose(pointHandles[i], -1))

    P = np.pi
    self.q0 = np.zeros(6)
    self.q1 = np.array([P / 6, 0, P / 6, 0, P / 3, 0])
    self.q2 = np.array([P / 6, P / 6, P / 3, 0, P / 3, P / 6])
    self.q3 = np.array([P / 2, 0, P / 2, -P / 3, P / 3, P / 6])
    self.q4 = np.array([-P / 6, -P / 6, -P / 3, 0, P / 12, P / 2])
    self.q5 = np.array([P / 12, P / 12, P / 12, P / 12, P / 12, P / 12])


def sysCall_actuation():
    endEffectorHandle = sim.getObject('/Robot/SuctionCup/SuctionCup_visiable')  
    endEffectorPose = sim.getObjectPose(endEffectorHandle, -1) 
    pose_str = f"Position: ({endEffectorPose[0]:.3f}, {endEffectorPose[1]:.3f}, {endEffectorPose[2]:.3f}) | " \
           f"Orientation: ({endEffectorPose[3]:.3f}, {endEffectorPose[4]:.3f}, {endEffectorPose[5]:.3f}, {endEffectorPose[6]:.3f})"
    sim.addStatusbarMessage(pose_str)  

    t = sim.getSimulationTime()
    q = self.q0
    state = False
    # robot takes 5s to move from q0 to q1.
    if t < 5:
        q = trajPlaningDemo(self.q0, self.q1, t, 5)
    elif t < 10:
        q = self.q1
    elif t < 15:
        q = trajPlaningDemo(self.q1, self.q2, t - 10, 5)
    elif t < 20:
        q = self.q2
    elif t < 25:
        q = trajPlaningDemo(self.q2, self.q3, t - 20, 5)
    elif t < 30:
        q = self.q3
    elif t < 35:
        q = trajPlaningDemo(self.q3, self.q4, t - 30, 5)
    elif t < 40:
        q = self.q4
    elif t < 45:
        q = trajPlaningDemo(self.q4, self.q5, t - 40, 5)
    elif t > 50:
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
