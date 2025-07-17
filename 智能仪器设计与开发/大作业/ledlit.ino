#include <Adafruit_MCP23X17.h>

// 定义6个MCP23017实例
Adafruit_MCP23X17 mcp[6];

// 电极配置结构体
struct ElectrodeConfig {
  uint8_t mcpIndex;  // 使用的MCP索引(0-5)
  uint8_t pinA;      // A引脚(0-15)
  uint8_t pinB;      // B引脚(0-15)
};

// 定义所有电极的配置（48个电极，编号1-48）
const ElectrodeConfig electrodeConfigs[49] = {
  {}, // 0号不用
  // MCP0 (地址0) 的电极1-8
  {0, 0, 8},  // 电极1: PA0(Pin0)和PB0(Pin8)
  {0, 1, 9},  // 电极2: PA1(Pin1)和PB1(Pin9)
  {0, 2, 10}, // 电极3: PA2(Pin2)和PB2(Pin10)
  {0, 3, 11}, // 电极4: PA3(Pin3)和PB3(Pin11)
  {0, 4, 12}, // 电极5: PA4(Pin4)和PB4(Pin12)
  {0, 5, 13}, // 电极6: PA5(Pin5)和PB5(Pin13)
  {0, 6, 14}, // 电极7: PA6(Pin6)和PB6(Pin14)
  {0, 7, 15}, // 电极8: PA7(Pin7)和PB7(Pin15)
  
  // MCP1 (地址1) 的电极9-16
  {1, 0, 8},  // 电极9
  {1, 1, 9},  // 电极10
  {1, 2, 10}, // 电极11
  {1, 3, 11}, // 电极12
  {1, 4, 12}, // 电极13
  {1, 5, 13}, // 电极14
  {1, 6, 14}, // 电极15
  {1, 7, 15}, // 电极16
  
  // 继续为MCP2-5定义电极...
  // MCP2 (地址2) 的电极17-24
  {2, 0, 8},  // 电极17
  {2, 1, 9},  // 电极18
  {2, 2, 10}, // 电极19
  {2, 3, 11}, // 电极20
  {2, 4, 12}, // 电极21
  {2, 5, 13}, // 电极22
  {2, 6, 14}, // 电极23
  {2, 7, 15}, // 电极24
  
  // MCP3 (地址3) 的电极25-32
  {3, 0, 8},  // 电极25
  {3, 1, 9},  // 电极26
  {3, 2, 10}, // 电极27
  {3, 3, 11}, // 电极28
  {3, 4, 12}, // 电极29
  {3, 5, 13}, // 电极30
  {3, 6, 14}, // 电极31
  {3, 7, 15}, // 电极32
  
  // MCP4 (地址4) 的电极33-40
  {4, 0, 8},  // 电极33
  {4, 1, 9},  // 电极34
  {4, 2, 10}, // 电极35
  {4, 3, 11}, // 电极36
  {4, 4, 12}, // 电极37
  {4, 5, 13}, // 电极38
  {4, 6, 14}, // 电极39
  {4, 7, 15}, // 电极40
  
  // MCP5 (地址5) 的电极41-48
  {5, 0, 8},  // 电极41
  {5, 1, 9},  // 电极42
  {5, 2, 10}, // 电极43
  {5, 3, 11}, // 电极44
  {5, 4, 12}, // 电极45
  {5, 5, 13}, // 电极46
  {5, 6, 14}, // 电极47
  {5, 7, 15}  // 电极48
};

void setup() {
  Serial.begin(9600);
  while (!Serial);
  Serial.println("MCP23017 电极阵列控制");

  // 初始化所有MCP23017 (使用不同的I2C地址)
  for (int i = 0; i < 6; i++) {
    mcp[i].begin(i+1); // 地址1-6
    
    // 设置所有引脚为输出
    for (int pin = 0; pin < 16; pin++) {
      mcp[i].pinMode(pin, OUTPUT);
      mcp[i].digitalWrite(pin, LOW); // 初始化为低电平
    }
  }

  Serial.println("请输入例如 '13h' 或 '13l'（设置编号为13的电极为高电平或低电平）");
  Serial.println("有效电极编号: 1-48");
  while (Serial.available()) Serial.read();  // 清空串口缓冲区
}

void loop() {
  if (Serial.available()) {
    String input = Serial.readStringUntil('\n');
    input.trim();  // 去掉换行符、空格

    if (input.length() < 2) {
      Serial.println("格式错误，正确格式如：13h 或 13l");
      return;
    }

    char action = input.charAt(input.length() - 1);  // 获取最后一个字符
    int electrodeNum = input.substring(0, input.length() - 1).toInt();  // 获取前面数字

    if (electrodeNum < 1 || electrodeNum > 48 || (action != 'h' && action != 'l')) {
      Serial.println("格式错误或范围不合法（1-48 + h/l）");
      return;
    }

    // 设置电极状态
    setElectrode(electrodeNum, action == 'h');
    
    Serial.print("设置第 ");
    Serial.print(electrodeNum);
    Serial.print(" 号电极为 ");
    Serial.println(action == 'h' ? "高电平" : "低电平");
  }
}

// 设置电极状态
void setElectrode(int electrodeNum, bool high) {
  if (electrodeNum < 1 || electrodeNum > 48) return;
  
  const ElectrodeConfig& config = electrodeConfigs[electrodeNum];
  
  if (high) {
    // 设置A为低，B为高
    mcp[config.mcpIndex].digitalWrite(config.pinA, LOW);
    mcp[config.mcpIndex].digitalWrite(config.pinB, HIGH);
  } else {
    // 设置A为高，B为低
    mcp[config.mcpIndex].digitalWrite(config.pinA, HIGH);
    mcp[config.mcpIndex].digitalWrite(config.pinB, LOW);
  }
}