import serial
import threading
import time

class SerialComm:
    def __init__(self, port='/dev/cu.usbmodem21101', baudrate=9600, timeout=1):
        self.port = port
        self.baudrate = baudrate
        self.timeout = timeout
        self.ser = None
        self.running = False

    def connect(self):
        try:
            self.ser = serial.Serial(self.port, self.baudrate, timeout=self.timeout)
            time.sleep(2)
            self.running = True
            print(f"✅ 串口已连接：{self.port}")
            threading.Thread(target=self.listen, daemon=True).start()
            return True
        except Exception as e:
            print(f"❌ 串口连接失败：{e}")
            return False

    def listen(self):
        while self.running and self.ser:
            try:
                if self.ser.in_waiting > 0:
                    line = self.ser.readline().decode('utf-8', errors='ignore').strip()
                    if line:
                        print(f"[Arduino 返回] {line}")
            except Exception as e:
                print(f"[监听错误] {e}")
                break

    def send_command(self, cmd: str):
        if self.ser:
            self.ser.write((cmd + '\n').encode())
            print(f"[已发送] {cmd}")
        else:
            print("[错误] 串口未连接")

    def close(self):
        self.running = False
        if self.ser:
            self.ser.close()
            print("串口已关闭")
