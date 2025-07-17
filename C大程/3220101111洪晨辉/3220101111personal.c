//===========================================================================
//
// 
//===========================================================================


#include <windows.h>
#include <winuser.h>
#include "graphics.h"
#include "extgraph.h"
#include "imgui.h"
#include "linkedlist.h"
#include<stdlib.h>
#include<string.h>
#include<Stdio.h>
/*declare*/

typedef enum {
	Login,
	Usage,
	Personal
}Interface;

struct Trace {
	char name[50];
	char place[50];
	int year;
	int month;
	int day;
	struct Trace* Next;
	struct Trace* Before;
};


struct Date
{
	int year;
	int month;
	int day;
};

struct Product
{
	int order;
	char name[50];	//名称
	char place[10];	//地点
	char detail[100];	//详细信息
	int number;	//销售数量
	int price;	//销售金额
	struct Date date;	//销售日期
};

struct Node
{
	struct Product data;
	struct Node* pNext;
};

typedef struct Trace* TraceLinklist;

extern Interface TheInterface;
extern TraceLinklist Head, Tail, p, q, r;

extern struct Node* pOrder;
extern char id[200];

void InitUser();
void DisplayUser();
void displayhomepage();
void displayreset();

static double x = 1.0;
static double y = 1.3;
static double w = 1.5;/*the length of button and label*/
static double h = 0.5;/*The height of button and label*/
static char Name[80] = "";/*initially, it is your ID*/
static char Moral[80] = ""; 
static char Name_new[80] = "";/*_new :temporarily store the information you has entered*/
static char Moral_new[80] = "";
static struct birthday {
	char year[10];
	char month[10];
	char day[10];
}birth;
static char bir[30] = "";
static struct location {
	char province[20];
	char city[20];
	char county[20];
}locate;
static char loc[60] = "";
static char Sex[20] = "";
static char Sex_new[20] = "";
typedef enum{
	Homepage,
	Information,
	Trace,
	Reservation
}state;
state Thestate = Homepage;
/*display*/
void DisplayUser()
{
	DisplayClear();

	button(GenUIID(0), x, 4 * y, w, h, "个人主页");
	button(GenUIID(0), x, 3 * y, w, h, "设置个人信息");
	button(GenUIID(0), x, 2 * y, w, h, "我的浏览");
	button(GenUIID(0) ,x, y, w, h, "我的预定");
	if (button(GenUIID(0), x, 4 * y, w, h, "个人主页"))
	{
		InitUser();
		Thestate = Homepage;
	}
	if (button(GenUIID(0), x, 3 * y, w, h, "设置个人信息")) Thestate = Information;
	if (button(GenUIID(0), x, 2 * y, w, h, "我的浏览"))
	{
		inittrace();
		Thestate = Trace;
	}
	if (button(GenUIID(0), x, y, w, h, "我的预定"))
	{
		initreservation();
		Thestate = Reservation;
	}
	switch (Thestate)
	{
	case Homepage:
		displayhomepage();
		break;
	case Information:
		displayreset();
		break;
	case Trace:
		displaytrace();
		break;
	case Reservation:
		displayReservation(pOrder);
		SwapPages2();
		break;

	}
	if (Thestate != Information)
	{	
		
		strcpy(Moral_new, Moral);
		strcpy(Name_new, Name);
		strcpy(Sex_new, Sex);
	}
	
	if ( button(GenUIID(0),0.2,0.2,1.8,0.5,"返回主页") ) {

		TheInterface = Usage;

	}

}
void displayhomepage()
{
	SetPointSize(20);
	drawLabel(4 * x - 1, 4 * y, "昵称"); drawLabel(4 * x - 1, 3.2 * y, "座右铭"); drawLabel(4 * x - 1 , 2.4 * y, "性别"); drawLabel(4 * x - 1, 1.6 * y, "生日"); drawLabel(4 * x - 1, 0.8 * y, "所在地区");
	drawLabel(5 * x - 1, 4 * y, Name);
	drawLabel(5 * x - 1, 3.2 * y, Moral);
	drawLabel(5 * x - 1, 2.4 * y, Sex);
	drawLabel(5 * x - 1, 1.6 * y, bir);
	drawLabel(5 * x - 1, 0.8* y, loc);
	
}
void displayreset()
{	
	SetPointSize(20);
	drawLabel(4 * x - 1, 4 * y, "昵称"); drawLabel(4 * x - 1, 3.2 * y, "座右铭"); drawLabel(4 * x - 1, 2.4 * y, "性别"); drawLabel(4 * x - 1, 1.6 * y, "生日"); drawLabel(4 * x - 1, 0.8 * y, "所在地区");
	textbox(GenUIID(0), 5 * x - 1, 4 * y, w, h, Name_new, sizeof(Name_new));
	textbox(GenUIID(0), 5 * x - 1, 3.2 * y, w, h,Moral_new, sizeof(Moral_new));
	textbox(GenUIID(0), 5 * x - 1, 2.4 * y, w, h, Sex_new, sizeof(Sex_new));
	textbox(GenUIID(0), 5 * x - 1, 1.6 * y, 0.6 * w, h, birth.year, sizeof(birth.year));
	drawLabel(5.3 * x - 1, 1.4 * y, "(年份)");
	textbox(GenUIID(0), 6 * x - 1, 1.6 * y, 0.6 * w, h, birth.month, sizeof(birth.month));
	drawLabel(6.3 * x - 1, 1.4 * y, "(月份)");
	textbox(GenUIID(0), 7 * x - 1, 1.6 * y , 0.6 * w, h, birth.day, sizeof(birth.day));
	drawLabel(7.3 * x - 1, 1.4 * y, "(日期)");
	textbox(GenUIID(0), 5 * x - 1, 0.8 * y, 0.6 * w, h, locate.province, sizeof(locate.province));
	drawLabel(5.3 * x - 1, 0.6 * y, "(省份)");
	textbox(GenUIID(0), 6 * x - 1, 0.8 * y, 0.6 * w, h, locate.city, sizeof(locate.city));
	drawLabel(6.3 * x - 1, 0.6 * y, "(市)");
	textbox(GenUIID(0), 7 * x - 1, 0.8 * y, 0.6 * w, h, locate.county, sizeof(locate.county));
	drawLabel(7.3 * x - 1, 0.6 * y, "(区/县)");
	if (button(GenUIID(0), 7.5 * x - 1.5, 4 * y, w, h, "保存"))
	{
		FILE* fp;

		char IDinfo[100];
		strcpy(IDinfo,id);
		strcat(IDinfo,"info.txt");

		fp = fopen(IDinfo,"w");

		fprintf(fp, "%s %s %s %s %s %s %s %s %s\n", Name_new, Moral_new, Sex_new, birth.year, birth.month, birth.day, locate.province, locate.city, locate.county);

		fclose(fp);

		strcpy(Moral, "");strcat(Moral, Moral_new);
		strcpy(Name, "");strcat(Name, Name_new);
		strcpy(Sex , "");strcat(Sex, Sex_new);
		strcpy(bir , "");
		strcat(bir, birth.year); strcat(bir, "-"); strcat(bir, birth.month); strcat(bir, "-"); strcat(bir, birth.day);
		strcpy(loc, "");
		strcat(loc, locate.province); strcat(loc, "-"); strcat(loc,locate.city); strcat(loc, "-"); strcat(loc, locate.county);
	}
	if (button(GenUIID(0), 7.5 * x - 1.5,3.5 * y, w, h,"放弃更改"))
	{
		strcpy(Moral_new, Moral);
		strcpy(Name_new, Name);
		strcpy(Sex_new, Sex);
	}
}

void InitUser()
{
	FILE* fp;

	char IDinfo[100];
	strcpy(IDinfo, id);
	strcat(IDinfo, "info.txt");

	if ( (fp = fopen(IDinfo,"r")) == NULL )
	{
		fp = fopen(IDinfo, "w");
	}
	


	fscanf(fp, "%s %s %s %s %s %s %s %s %s\n", Name_new, Moral_new, Sex_new, birth.year, birth.month, birth.day, locate.province, locate.city, locate.county);

	fclose(fp);

	strcpy(Moral, ""); strcat(Moral, Moral_new);
	strcpy(Name, ""); strcat(Name, Name_new);
	strcpy(Sex, ""); strcat(Sex, Sex_new);
	strcpy(bir, "");
	strcat(bir, birth.year); strcat(bir, "-"); strcat(bir, birth.month); strcat(bir, "-"); strcat(bir, birth.day);
	strcpy(loc, "");
	strcat(loc, locate.province); strcat(loc, "-"); strcat(loc, locate.city); strcat(loc, "-"); strcat(loc, locate.county);


}
