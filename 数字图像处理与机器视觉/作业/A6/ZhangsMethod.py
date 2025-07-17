import cv2
import numpy as np
import glob
import os

chessboard_size = (8, 6)
square_size = 30  # mm

objp = np.zeros((chessboard_size[0]*chessboard_size[1], 3), np.float32)
objp[:, :2] = np.mgrid[0:chessboard_size[0], 0:chessboard_size[1]].T.reshape(-1, 2)
objp *= square_size

objpoints = []
imgpoints = []

images = glob.glob('calibration_images/*.ppm')

print(f"找到图像数量: {len(images)}")

for fname in images:
    img = cv2.imread(fname)
    if img is None:
        print(f"无法读取图像: {fname}")
        continue
    gray = cv2.cvtColor(img, cv2.COLOR_BGR2GRAY)
    ret, corners = cv2.findChessboardCorners(gray, chessboard_size, None)

    print(f"{os.path.basename(fname)}: 找到角点？ {ret}")

    if ret:
        objpoints.append(objp)
        corners2 = cv2.cornerSubPix(gray, corners, (11, 11), (-1, -1),
                                    (cv2.TERM_CRITERIA_EPS + cv2.TERM_CRITERIA_MAX_ITER, 30, 0.001))
        imgpoints.append(corners2)

cv2.destroyAllWindows()

if len(objpoints) > 0:
    ret, mtx, dist, rvecs, tvecs = cv2.calibrateCamera(objpoints, imgpoints, gray.shape[::-1], None, None)
    print("相机内参矩阵:\n", mtx)
    print("畸变系数:\n", dist.ravel())

    for i, (rvec, tvec) in enumerate(zip(rvecs, tvecs)):
        R, _ = cv2.Rodrigues(rvec)
        print(f"\n--- 图像 {i+1} 的外参 ---")
        print("旋转向量 rvec:\n", rvec.ravel())
        print("旋转矩阵 R:\n", R)
        print("平移向量 t:\n", tvec.ravel())

    import matplotlib.pyplot as plt

    total_error = 0
    mean_errors = []

    for i in range(len(objpoints)):
        imgpoints2, _ = cv2.projectPoints(objpoints[i], rvecs[i], tvecs[i], mtx, dist)
        error = cv2.norm(imgpoints[i], imgpoints2, cv2.NORM_L2) / len(imgpoints2)
        mean_errors.append(error)
        total_error += error

    print("\n==============================")
    print(f"平均反投影误差: {total_error / len(objpoints):.4f} 像素")

    plt.figure(figsize=(10, 4))
    plt.bar(range(1, len(mean_errors)+1), mean_errors)
    plt.xlabel('ImageLabel')
    plt.ylabel('Average projection error (pixel)')
    plt.title('The projection error for each image')
    plt.grid(True)
    plt.tight_layout()
    plt.show()

    # === save txt ===
    with open("camera_calibration_result.txt", "w") as f:
        f.write("=== 相机内参矩阵 (Camera Matrix) ===\n")
        for row in mtx:
            f.write("  " + "  ".join(f"{val:.6f}" for val in row) + "\n")

        f.write("\n=== 畸变系数 (Distortion Coefficients) ===\n")
        f.write("  " + "  ".join(f"{val:.6f}" for val in dist.ravel()) + "\n")

        for i, (rvec, tvec) in enumerate(zip(rvecs, tvecs)):
            R, _ = cv2.Rodrigues(rvec)
            f.write(f"\n=== 图像 {i+1} 的外参 ===\n")
            f.write("旋转向量 rvec:\n")
            f.write("  " + "  ".join(f"{val:.6f}" for val in rvec.ravel()) + "\n")
            f.write("旋转矩阵 R:\n")
            for row in R:
                f.write("  " + "  ".join(f"{val:.6f}" for val in row) + "\n")
            f.write("平移向量 tvec:\n")
            f.write("  " + "  ".join(f"{val:.6f}" for val in tvec.ravel()) + "\n")

else:
    print("没有足够的有效图像用于标定。")
