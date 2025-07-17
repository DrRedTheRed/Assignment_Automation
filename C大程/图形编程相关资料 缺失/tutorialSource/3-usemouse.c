/**************************************************************

1. 跟踪鼠标的位置
   在鼠标处显示一个文本box

***************************************************************/

#include "graphics.h"
#include "extgraph.h"
#include "imgui.h"

double label_x = 1.0;
double label_y = 1.0;

double mouse_x = 0, mouse_y = 0;


void display()
{
	double w = 2.0;
	double h = GetFontHeight() * 2;
	// 清除屏幕
	DisplayClear();
	// draw a square
	SetPenColor("Blue");
	drawLabel(label_x, label_y, "Lable is Here");
	
	//draw a rect/box to trace the mouse
	//drawRectangle(mouse_x, mouse_y, w, h, 0);
	SetPenColor("Light Gray");
	drawBox(mouse_x, mouse_y, w, h, 1, "This box follows the mouse", 'L', "Red");
}

typedef enum {
	LabelTimer,
	BoxTimer,
} MyTimer;

void mytimer(int  timerID)
{
	switch (timerID)
	{
	case LabelTimer:
		label_x += 0.5;
		if (label_x > 5.0) label_x = 1.0;
		display();
		break;
	}
}

void myMouseEvent (int x, int y, int button, int event)
{
	mouse_x = ScaleXInches(x);
	mouse_y = ScaleYInches(y);
	display();
}

void Main()
{
	SetWindowTitle("演示鼠标使用方法");
	InitGraphics();

	registerTimerEvent(mytimer);
	startTimer(LabelTimer, 100);

	registerMouseEvent(myMouseEvent);

	display();
}
