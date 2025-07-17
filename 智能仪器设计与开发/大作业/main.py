import tkinter as tk
from tkinter import messagebox
from serial_comm import SerialComm

CELL_SIZE = 60
ROWS, COLS = 6, 8

# 氢氧化钠和水的预设路径（要求起始位置严格按照PPT）
PATH_1_NaOH = [(5,2),(4,2),(3,2)]
PATH_2_NaOH = [(5,2),(5,3),(5,4),(4,4),(3,4)]
PATH_3_NaOH = [(5,2),(5,3),(5,4),(5,5),(5,6),(4,6),(3,6)]

PATH_1_Water = [(5,8),(4,8),(3,8)]
PATH_2_Water = [(5,7),(5,6),(4,6),(3,6)]
PATH_3_Water = [(5,6),(5,5),(5,4),(4,4),(3,4)]

# 预设初始位置（可自定义修改）
PRESET_PHENOLPHTHALEIN = [(1,2),(1,4),(1,6),(1,8)]
PRESET_WATER = [(6,6),(6,7),(6,8)]
PRESET_NAOH = [(6,1),(6,2),(6,3)]
PRESET_END = [(3,2),(3,4),(3,6),(3,8)]

colors = {
    "酚酞": "red",
    "水": "green",
    "氢氧化钠": "blue",
    "当前": "orange",
    "初始化": "white"
}

class MicrofluidicApp:
    def __init__(self, root):
        self.root = root
        self.root.title("Route Planning")
        self.canvas = tk.Canvas(root, width=COLS * CELL_SIZE, height=ROWS * CELL_SIZE, bg="white")
        self.canvas.grid(row=0, column=0, rowspan=20)

        self.grid_data = [[None for _ in range(COLS)] for _ in range(ROWS)]
        self.cell_ids = [[None for _ in range(COLS)] for _ in range(ROWS)]
        self.cell_levels = [[None for _ in range(COLS)] for _ in range(ROWS)]
        self.cell_text_ids = [[None for _ in range(COLS)] for _ in range(ROWS)]
        self.fixed_cells = [[False for _ in range(COLS)] for _ in range(ROWS)] # 用于标记是否为固定位置

        self.draw_grid()

        # 初始化串口通信
        # self.serial = SerialComm()
        # self.serial.connect()

        self.create_controls()

    def draw_grid(self):
        for r in range(ROWS):
            for c in range(COLS):
                x0 = c * CELL_SIZE
                y0 = r * CELL_SIZE
                x1 = x0 + CELL_SIZE
                y1 = y0 + CELL_SIZE
                rect = self.canvas.create_rectangle(x0, y0, x1, y1, outline="black", fill="white")
                self.cell_ids[r][c] = rect
                # 初始为空电平显示
                text = self.canvas.create_text((x0 + x1) / 2, (y0 + y1) / 2, text="", fill="gray70", font=("Arial", 14))
                self.cell_text_ids[r][c] = text

    def create_controls(self):
        tk.Label(self.root, text="地图尺寸").grid(row=0, column=1, pady=5)
        tk.Label(self.root, text="列").grid(row=1, column=1)
        self.entry_cols = tk.Entry(self.root, width=5)
        self.entry_cols.insert(0, str(COLS))
        self.entry_cols.grid(row=1, column=2)

        tk.Label(self.root, text="行").grid(row=2, column=1)
        self.entry_rows = tk.Entry(self.root, width=5)
        self.entry_rows.insert(0, str(ROWS))
        self.entry_rows.grid(row=2, column=2)

        tk.Label(self.root, text="设置位置").grid(row=3, column=1, pady=5)
        tk.Label(self.root, text="列").grid(row=4, column=1)
        self.set_col = tk.Entry(self.root, width=5)
        self.set_col.insert(0, "1")
        self.set_col.grid(row=4, column=2)

        tk.Label(self.root, text="行").grid(row=5, column=1)
        self.set_row = tk.Entry(self.root, width=5)
        self.set_row.insert(0, "1")
        self.set_row.grid(row=5, column=2)

        # 操作按钮
        tk.Button(self.root, text="更改酚酞位置", command=lambda: self.set_cell("酚酞")).grid(row=6, column=1, columnspan=2, pady=2)
        tk.Button(self.root, text="更改水位置", command=lambda: self.set_cell("水")).grid(row=7, column=1, columnspan=2, pady=2)
        tk.Button(self.root, text="更改氢氧化钠位置", command=lambda: self.set_cell("氢氧化钠")).grid(row=8, column=1, columnspan=2, pady=2)
        tk.Button(self.root, text="设定预设初始位置", command=self.set_presets).grid(row=9, column=1, columnspan=2, pady=2)
        tk.Button(self.root, text="初始化当前位置", command=lambda: self.set_cell("初始化")).grid(row=10, column=1, columnspan=2, pady=2)
        tk.Button(self.root, text="重置地图", command=self.reset_grid).grid(row=11, column=1, columnspan=2, pady=2)
        tk.Button(self.root, text="开始任务三", command=self.start_planning).grid(row=12, column=1, columnspan=2, pady=2)

        # 电平控制
        tk.Label(self.root, text="设定电平").grid(row=13, column=1, pady=5)
        self.level_var = tk.StringVar(value="h")
        tk.Radiobutton(self.root, text="高电平", variable=self.level_var, value="h").grid(row=14, column=1, columnspan=2)
        tk.Radiobutton(self.root, text="低电平", variable=self.level_var, value="l").grid(row=15, column=1, columnspan=2)
        tk.Button(self.root, text="设置电极电平", command=self.send_level_command).grid(row=16, column=1, columnspan=2, pady=5)

    def set_cell(self, cell_type):
        try:
            r = int(self.set_row.get()) - 1
            c = int(self.set_col.get()) - 1
            if 0 <= r < ROWS and 0 <= c < COLS:
                color = colors.get(cell_type, "white")
                self.canvas.itemconfig(self.cell_ids[r][c], fill=color)

                electrode_id = r * COLS + c + 1
                if cell_type == "初始化":
                    self.canvas.itemconfig(self.cell_ids[r][c], fill="white")
                    self.canvas.itemconfig(self.cell_text_ids[r][c], text="L")
                    # self.serial.send_command(f"{electrode_id}l")
                    self.cell_levels[r][c] = "L"
                    self.fixed_cells[r][c] = False  # 清除固定标记
                else:
                    self.canvas.itemconfig(self.cell_text_ids[r][c], text="H")
                    # self.serial.send_command(f"{electrode_id}h")
                    self.cell_levels[r][c] = "H"
                    self.fixed_cells[r][c] = True  # 标记为固定格子


            else:
                messagebox.showerror("错误", "输入坐标超出范围！")
        except ValueError:
            messagebox.showerror("错误", "请输入有效的数字！")


    def reset_grid(self):
        for r in range(ROWS):
            for c in range(COLS):
                self.canvas.itemconfig(self.cell_ids[r][c], fill="white")
                self.canvas.itemconfig(self.cell_text_ids[r][c], text="L")
                # self.serial.send_command(f"{r * COLS + c + 1}l")
                self.cell_levels[r][c] = "L"
                self.fixed_cells[r][c] = False  # 清除所有固定标记

    def start_planning(self):
        import time

        def activate_path(path, repeat=1):
            for _ in range(repeat):
                for r, c in path:
                    self.set_all_low()
                    # 转换为 0-based 索引
                    r_idx, c_idx = r - 1, c - 1
                    if 0 <= r_idx < ROWS and 0 <= c_idx < COLS:
                        electrode_id = r_idx * COLS + c_idx + 1
                        # self.serial.send_command(f"{electrode_id}h")
                        self.canvas.itemconfig(self.cell_ids[r_idx][c_idx], fill="orange")
                        self.canvas.itemconfig(self.cell_text_ids[r_idx][c_idx], text="H")
                        self.cell_levels[r_idx][c_idx] = "H"
                        self.root.update()
                        time.sleep(1)

        def parse_path(data):
            return list(data)

        # 为防止阻塞 UI 可用 threading 或 after 改进（这里用简单同步示例）
        self.set_all_low()
        activate_path(parse_path(PATH_1_NaOH), repeat=3)
        activate_path(parse_path(PATH_2_NaOH), repeat=2)
        activate_path(parse_path(PATH_3_Water), repeat=1)
        activate_path(parse_path(PATH_3_NaOH), repeat=1)
        activate_path(parse_path(PATH_2_Water), repeat=2)
        activate_path(parse_path(PATH_1_Water), repeat=3)

        # >>> 移动酚酞 <<<
        final_paths = [
            [(1,2),(2,2),(3,2)],
            [(1,4),(2,4),(3,4)],
            [(1,6),(2,6),(3,6)],
            [(1,8),(2,8),(3,8)]
        ]
        for path in final_paths:
            activate_path(path, repeat=1)

        messagebox.showinfo("完成", "路径规划完毕。")

    def set_all_low(self):
        for r in range(ROWS):
            for c in range(COLS):
                if self.fixed_cells[r][c]:  # 跳过固定格子
                    continue
                electrode_id = r * COLS + c + 1
                # self.serial.send_command(f"{electrode_id}l")
                self.canvas.itemconfig(self.cell_ids[r][c], fill="white")
                self.canvas.itemconfig(self.cell_text_ids[r][c], text="L")
                self.cell_levels[r][c] = "L"
        self.root.update()

    def send_level_command(self):
        # try:
        #     r = int(self.set_row.get()) - 1
        #     c = int(self.set_col.get()) - 1
        #     if not (0 <= r < ROWS and 0 <= c < COLS):
        #         messagebox.showerror("错误", "坐标超出范围！")
        #         return
        #     electrode_id = r * COLS + c + 1
        #     level = self.level_var.get()
        #     command = f"{electrode_id}{level}"
        #     self.serial.send_command(command)

        #     # 更新电平显示
        #     self.cell_levels[r][c] = level.upper()
        #     self.canvas.itemconfig(self.cell_text_ids[r][c], text=level.upper())
        # except ValueError:
        #     messagebox.showerror("错误", "请输入有效数字！")
        return

    def set_presets(self):
        def apply_presets(preset_list, cell_type):
            for r, c in preset_list:
                r_idx, c_idx = r - 1, c - 1
                if 0 <= r_idx < ROWS and 0 <= c_idx < COLS:
                    color = colors.get(cell_type, "white")
                    electrode_id = r_idx * COLS + c_idx + 1
                    self.canvas.itemconfig(self.cell_ids[r_idx][c_idx], fill=color)
                    self.canvas.itemconfig(self.cell_text_ids[r_idx][c_idx], text="H")
                    # self.serial.send_command(f"{electrode_id}h")
                    self.cell_levels[r_idx][c_idx] = "H"
                    self.fixed_cells[r_idx][c_idx] = True

        apply_presets(PRESET_PHENOLPHTHALEIN, "酚酞")
        apply_presets(PRESET_WATER, "水")
        apply_presets(PRESET_NAOH, "氢氧化钠")
        apply_presets(PRESET_END, "当前")
        messagebox.showinfo("提示", "已设定预设初始位置。")

if __name__ == "__main__":
    root = tk.Tk()
    app = MicrofluidicApp(root)
    root.mainloop()
