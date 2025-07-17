//===========================================================================
//
//  最近修改：2020年3月25日 
//  初次创建：2020年3月21日，用于<<程序设计专题>>课程教学
//
//===========================================================================
#include "graphics.h"
#include "extgraph.h"
#include "imgui.h"

void display()
{
	double x = 1.0; //单位是英寸
	double y = 1.0; //单位是英寸
	double w = 2.0; //单位是英寸
	double h = GetFontHeight() * 2; //单位是英寸
	// draw a square
	SetPenColor("Blue");
	drawLabel(x, y, "傻逼吧卧槽");
	// draw 更多的东西
	drawRectangle(x, y += h*1.2, w, h, 0);
	SetPenColor("Red"); 
	drawBox(x, y += h*1.2, w, h, 0, "东西不讲清楚", 'C', "Green");
	SetPenColor("Light Gray"); 
	drawBox(x, y += h*1.2, w, h, 1, "你他妈的让我怎么做", 'L', "Green");
}

void Main()
{
	SetWindowTitle("胡兰青我操你妈了个逼");
	InitGraphics();

	display();
}