//===========================================================================
//
//  ����޸ģ�2020��3��25�� 
//  ���δ�����2020��3��21�գ�����<<�������ר��>>�γ̽�ѧ
//
//===========================================================================
#include "graphics.h"
#include "extgraph.h"
#include "imgui.h"

void display()
{
	double x = 1.0; //��λ��Ӣ��
	double y = 1.0; //��λ��Ӣ��
	double w = 2.0; //��λ��Ӣ��
	double h = GetFontHeight() * 2; //��λ��Ӣ��
	// draw a square
	SetPenColor("Blue");
	drawLabel(x, y, "ɵ�ư��Բ�");
	// draw ����Ķ���
	drawRectangle(x, y += h*1.2, w, h, 0);
	SetPenColor("Red"); 
	drawBox(x, y += h*1.2, w, h, 0, "�����������", 'C', "Green");
	SetPenColor("Light Gray"); 
	drawBox(x, y += h*1.2, w, h, 1, "�������������ô��", 'L', "Green");
}

void Main()
{
	SetWindowTitle("�������Ҳ������˸���");
	InitGraphics();

	display();
}