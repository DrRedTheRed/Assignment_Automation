//===========================================================================
//

//  ��ⷽ���Ӣ�ı��������ɡ���Ϊ�Ϲ���û��ʱ��дע�͡�
// 
//===========================================================================

#define FILEPATH "product.txt"

#include<time.h>
#include<string.h>

#include "graphics.h"
#include "extgraph.h"
#include "strlib.h"
#include "imgui.h"
#include "simpio.h"

typedef enum {
	MainMenu,
	Plane,
	Train,
	Ryokou,
	Hotel
}TheDisplay;

typedef enum {
	Login,
	Usage,
	Personal
}Interface;

typedef enum {
	Hangzhou,
	Shanghai,
	Beijing,
	Guangzhou,
	Nanjing,
	Suzhou,
	Tianjin
}City;

TheDisplay TheOneOnDisplay = MainMenu ;

Interface TheInterface = Login;

typedef struct {
	char year[100];
	char month[3];
	char day[3];
}Date1;//�ѱ�

//��Ʒ��������(����product.c)
struct Date
{
	int year;
	int month;
	int day;
};

struct Product
{
	int order;
	char name[50];	//����
	char place[10];	//�ص�
	char detail[100];	//��ϸ��Ϣ
	int number;	//��������
	int price;	//���۽��
	struct Date date;	//��������
};


struct Trace {
	char name[50];
	char place[50];
	int year;
	int month;
	int day;
	struct Trace* Next;
	struct Trace* Before;
};


//����ڵ�����
struct Node
{
	struct Product data;
	struct Node* pNext;
};

//���������
struct Node* pList = NULL;	//��������
struct Product products[100] = { 0 };	//�����ṹ������洢��Ʒ����
char line[100];	//��sscanf��ȡ
int count = 0;	//�Զ�ȡ�Ľṹ����м���

//Ԥ���б�
struct Node* pOrder;

//��������
struct Node* searchList;

//�����б�
struct Node* rankList;



//�ⲿ������

extern int administrator_mode;

extern char id[200];

//��̬������

static int PrevInt = 1;
static int TotalInt = 10;


static char Cityname[50] = "Beijing";
static City TheCity = Hangzhou;
static City TheCityStart;

//��ʼ��չʾʱ��
static Date1 DateStart, DateEnd, DateStartMemory, DateEndMemory, DateStartRes, DateEndRes;

//ȫ�ֱ�����

int PrevInt2 = 1;
int TotalInt2 = 10;

string CityName[] = { "Hangzhou","Shanghai","Beijing","Guangzhou","Nanjing","Suzhou","Tianjin" };




//Display�����

void Display();

void DisplayUsage();

/*void DisplayBox();*/

void DisplayMenuList(double WindowHeight,double WindowWidth);

void DiplayStatus(double WindowHeight);

void DisplayPlane();
void DisplayTrain();
void DisplayRyokou();
void DisplayRyokouAllSpot();
void DisplayRyoKouHotSpot();
void DisplaySearch();
void DisplayRyokouSeries(struct Node *headNode);//������
void displayReservation(struct Node* headNode);
void DisplayHotel();

void SwapPages();
void SwapPages2();
void ShowDetail(string detail, string number, string price, string date);


//�ص���������
void MouseEventProcess(int x,int y,int button ,int event)
{
	uiGetMouse(x,y,button,event);
	Display();
}

void KeyboardEventProcess(int key,int event)
{
	uiGetKeyboard(key,event);
	Display();
}

void CharEventProcess(char ch)
{
	uiGetChar(ch);
	Display();
}

typedef enum
{
	BoxTimer
} MyTimer;

//���๦��

int IsValidDate(int year, int month, int day);
int IsValidOrder(int StartYear, int StartMonth, int StartDay, int EndYear, int EndMonth, int EndDay);

void SavePlaneTicket();
void RefreshTicket();

void SaveHotel();
void RefreshHotel();

//�����Ǻ���ʵ������

void Display() 
{
	DisplayClear();

	switch (TheInterface)
	{
		case Login:
			DisplayLogin(); //��login.c
			break;
		case Usage:
			DisplayUsage();
			break;
		case Personal:
			DisplayUser();
			break;
	}

}

//������

void DisplayUsage()
{
	DisplayClear();
	
	int nothing;

	//��������
	double WindowHeight = GetWindowHeight();
	double WindowWidth = GetWindowWidth();//do not drag
	
	//�ؼ���С������
	double BoxHeight = WindowHeight / 4.0;
	double BoxWidth = WindowWidth / 4.0;

	//λ�ñ���������
	double BoxX = WindowWidth / 2.0 - BoxWidth / 2.0;
	double BoxY = WindowHeight / 2.0 - BoxHeight / 2.0;

	SetPenColor("Blue");
	if (button(GenUIID(0), WindowWidth - 1.5, 0.1, 1.4, GetFontHeight()*2, "�һ���������֢")) exit(-1);

	SetPenColor("Blue");
	drawBox(BoxX,BoxY,BoxWidth,BoxHeight,0,"ԭ����Ҳ��ԭ��","c","Green");

	MovePen(WindowWidth / 2.0 - 1.6, WindowHeight / 2.0 - BoxHeight / 2.0 - GetFontHeight()* 2.0);
	
	SetPenColor("Cyan");
	DrawTextString("�������ѣ��벻Ҫ��ͼ��ק���ڡ�����Ը���");

	MovePen(0.1,  GetFontHeight()*3);
	SetPenColor("Red");
	DrawTextString("��ǰ���棺");

	DisplayMenuList(WindowHeight,WindowWidth);

	/*�����ǹ�<*��Ϣ��ɾ��*>�ο�������
	* 
	double x = 1.0; //��λ��Ӣ��
	double y = 1.0; //��λ��Ӣ��
	double w = 2.0; //��λ��Ӣ��
	double h = GetFontHeight() * 2; //��λ��Ӣ��
	// ������ť

	DisplayClear();


	SetPenColor("Blue");
	drawBox(0,0,1,1,0,"hey","c","Brown");

	button(GenUIID(0), x, y + h * 1.2, w, h, "��ֻ��һ�����Ժ���");
	if (button(GenUIID(0), x, y, w, h, "Quit"))
	{
		exit(-1);
	}

	//�����ı���
	static char str[80] = "Please Click and Edit";
	textbox(GenUIID(0),x,y+h * 2.4,w,h,str,sizeof(str));

	//�����˵�

	char* menuListFile[] = { "File",
	"Open | Ctrl-O",
	"Close",
	"Exit | Ctrl-E"
	};

	int selection;
	double wsub = 2.0;


	selection = menuList(GenUIID(0),x+w*1.2,y + h*3.6,w,wsub, h ,menuListFile,sizeof(menuListFile)/sizeof(menuListFile[0]));
	if (selection == 3) exit(-1);

	static int show_more_buttons = 0;
	static int enable_rotation = 0;

	char* menuListTool[] = { "Tool",
	"Triangle",
	"Circle",
	"Stop Rotation | Ctrl-T" };
	// ���ö�̬�ɱ�˵���ǩ
	menuListTool[3] = enable_rotation ?
		"Stop Rotation  | Ctrl-T" :
		"Start Rotation | Ctrl-T";

	selection = menuList(GenUIID(0), x + w*2.2, y+h*3.6, w, wsub, h,
		menuListTool, sizeof(menuListTool) /
		sizeof(menuListTool[0]));

	if (selection == 3)
		enable_rotation = !enable_rotation;

	DisplayBox();
	*/
}

void DisplayMenuList(double WindowHeight, double WindowWidth)
{
	//�ؼ���С������
	double menuListWidth = WindowWidth / 5.0 ;
	double menuListHeight = GetFontHeight() * 2 ;

	//�ؼ�λ��������
	double menuListBasicX = 0;
	double menuListBasicY = WindowHeight - 0.5;

	//�û�����

	string JoinIdForDisplay =  Concat("��ӭ,",id);

	char* menuListUser[] = { " �û����� ",
	JoinIdForDisplay,
	" �ҵ� ",
	" ע�� "
	};

	int SelectionUser = 0 ;

	SelectionUser = menuList(GenUIID(0), WindowWidth - menuListWidth / 1.5, menuListBasicY, menuListWidth / 1.5, menuListWidth / 1.5, menuListHeight,
		menuListUser, sizeof(menuListUser) / sizeof(menuListUser[0]));

	if (SelectionUser == 3) 
	{
		TheInterface = Login;
	}
	else if ( SelectionUser == 2 )
	{
		TheInterface = Personal;
	}


	//��Ʊ
	char* menuListPlane[] = { " ��Ʊ ",
	" ��ʾ "
	};

	menuListPlane[1] = ( TheOneOnDisplay == Plane ) ?
		"�ص����˵�" :
		"��ʾ";

	int SelectionPlane;

	SelectionPlane = menuList(GenUIID(0), menuListBasicX, menuListBasicY, menuListWidth, menuListWidth / 1.02, menuListHeight, 
		menuListPlane, sizeof(menuListPlane)/sizeof(menuListPlane[0]));

	if (SelectionPlane && (TheOneOnDisplay != Plane)) {
		TheOneOnDisplay = Plane;
	}
	else if(SelectionPlane && (TheOneOnDisplay == Plane))
	{
		TheOneOnDisplay = MainMenu;
	}

	if (TheOneOnDisplay == Plane)
	{
		DisplayPlane(WindowHeight);
	}

	//��Ʊ
	char* menuListTrain[] = { " ��Ʊ ",
	" ��ʾ"
	};

	menuListTrain[1] = (TheOneOnDisplay == Train) ?
		"�ص����˵�" :
		"��ʾ";

	int SelectionTrain = 0;

	SelectionTrain = menuList(GenUIID(0), menuListBasicX + menuListWidth, menuListBasicY, menuListWidth, menuListWidth / 1.02, menuListHeight,
		menuListTrain, sizeof(menuListTrain) / sizeof(menuListTrain[0]));

	if (SelectionTrain && (TheOneOnDisplay != Train)) {
		TheOneOnDisplay = Train;
	}
	else if(SelectionTrain && (TheOneOnDisplay == Train))
	{
		TheOneOnDisplay = MainMenu;
	}

	if (TheOneOnDisplay == Train)
	{
		DisplayTrain();
	}

	//����
	char* menuListRyokou[] = { " ���� ",
	" �˳� | Ctrl-E"
	};

	menuListRyokou[1] = (TheOneOnDisplay ==Ryokou) ?
		"�ص����˵�" :
		"��ʾ";

	int SelectionRyokou = 0;

	SelectionRyokou = menuList(GenUIID(0), menuListBasicX + menuListWidth * 2, menuListBasicY, menuListWidth, menuListWidth / 1.02, menuListHeight,
		menuListRyokou, sizeof(menuListRyokou) / sizeof(menuListRyokou[0]));

	if (SelectionRyokou && (TheOneOnDisplay != Ryokou)) {
		TheOneOnDisplay = Ryokou;
	}
	else if (SelectionRyokou && (TheOneOnDisplay == Ryokou))
	{
		TheOneOnDisplay = MainMenu;
	}

	if (TheOneOnDisplay == Ryokou)
	{
		DisplayRyokou();
	}

	//�Ƶ�
	char* menuListHotel[] = { " �Ƶ� ",
	" �˳� | Ctrl-E"
	};

	menuListHotel[1] = (TheOneOnDisplay == Hotel) ?
		"�ص����˵�" :
		"��ʾ";

	int SelectionHotel = 0;

	SelectionHotel = menuList(GenUIID(0), menuListBasicX + menuListWidth * 3, menuListBasicY, menuListWidth, menuListWidth / 1.02, menuListHeight,
		menuListHotel, sizeof(menuListHotel) / sizeof(menuListHotel[0]));

	if (SelectionHotel && (TheOneOnDisplay != Hotel)) {
		TheOneOnDisplay = Hotel;
	}
	else if (SelectionHotel && (TheOneOnDisplay == Hotel))
	{
		TheOneOnDisplay = MainMenu;
	}

	if (TheOneOnDisplay == Hotel)
	{
		DisplayHotel();
	}

	DiplayStatus(WindowHeight);
}

void DiplayStatus(double WindowHeight)
{
	MovePen(GetWindowWidth() * 0.8 + 0.45, WindowHeight - 0.35);
	SetPenColor("Orange");

	if ( administrator_mode )
	{
		drawBox(GetWindowWidth() * 0.8 + 0.3, WindowHeight - 0.4,0.2,0.2,1,"A","c","White");
	}
	else
	{
		SetPenSize(6);
		DrawArc(0.15,0,360);
		SetPenColor("Red");
		SetPointSize(6);
		MovePen(GetWindowWidth() * 0.8 + 0.25, WindowHeight - 0.4);
		SetPointSize(1);
		DrawTextString("P");
		SetPenSize(1);
	}

	MovePen(0, WindowHeight * (1.0 - 1.0 / 4.0) - GetFontHeight() * 2);

	SetPenColor("Gray");
	SetPointSize(20);
	SetFont("KaitiSC");
	char Status[90];
	
	switch (TheOneOnDisplay)
	{
		case Plane:
			strcpy(Status,"��Ʊ");
			break;
		case Train:
			strcpy(Status, "��Ʊ");
			break;
		case Ryokou:
			strcpy(Status, "����");
			break;
		case Hotel:
			strcpy(Status, "�Ƶ�");
			break;
		case MainMenu:
			strcpy(Status, "���˵�");
			break;
	}

	drawLabel(0.1, GetFontHeight(), Status);
	SetPointSize(1);

}

void DisplayPlane()
{
	/*MovePen(1, 2);
	SetPenColor("Violet");
	SetPenSize(3);
	DrawLine(3,3);
	SetPenSize(1);*/

	typedef enum
	{
		Start,
		End,
		Confirm
	}State;

	static double SquareButton = 0.05;
	static double TextBoxWidth = 1, TextBoxHeight = 0.5;

	static State state = Start;

	static char start[100],stop[100];



	static int  displayline = 0;;

	
	string Status[] = {"���","�յ�","ȷ��"};
	double CityCordinate[7][2] = {
		6.2,2.6, 
		6.5,3,
		5.7,5,
		4,1,
		6,3.1,
	    6.3,3.2,
		5.9,4.8
	};

	drawLabel(0.5, 4.7, "���");
	drawLabel(0.5, 3.7, "�յ�");

	//һ��ѳ���
	if (button(GenUIID(0), 6.2, 2.6, SquareButton, SquareButton, "����"))
	{
		TheCity = Hangzhou;
	}

	if (button(GenUIID(0), 6.5, 3, SquareButton, SquareButton, "�Ϻ�"))
	{
		TheCity = Shanghai;
	}

	if (button(GenUIID(0), 5.7, 5, SquareButton, SquareButton, "����"))
	{
		TheCity = Beijing;
	}

	if (button(GenUIID(0), 4, 1, SquareButton, SquareButton, "����"))
	{
		TheCity = Guangzhou;
	}

	if (button(GenUIID(0), 6, 3.1, SquareButton, SquareButton, "�Ͼ�"))
	{
		TheCity = Nanjing;
	}

	if (button(GenUIID(0), 6.3, 3.2, SquareButton, SquareButton, "����"))
	{
		TheCity = Suzhou;
	}

	if (button(GenUIID(0), 5.9, 4.8, SquareButton, SquareButton, "���"))
	{
		TheCity = Tianjin;
	}

	if (button(GenUIID(0), 1, 2, TextBoxWidth, TextBoxHeight, Status[state]))
	{
		switch (state)
		{
			case Start:
				strcpy(start, CityName[TheCity]);
				displayline = -1;
				state++;
				break;
			case End:
				strcpy(stop, CityName[TheCity]);
				displayline = 1;
				state++;
				break;
			case Confirm:
				state = Start;
				SavePlaneTicket();
				displayline = 0;
				break;
		}


	}

	textbox(GenUIID(0), 1, 4.5, TextBoxWidth, TextBoxHeight, start, 100);
	textbox(GenUIID(0), 1, 3.5, TextBoxWidth, TextBoxHeight, stop, 100);

	if (displayline == 1)
	{
		MovePen(CityCordinate[TheCityStart][0] + SquareButton / 2.0, CityCordinate[TheCityStart][1] + SquareButton / 2.0);
		SetPenSize(3);
		SetPenColor("Blue");
		DrawLine(CityCordinate[TheCity][0] - CityCordinate[TheCityStart][0], CityCordinate[TheCity][1] - CityCordinate[TheCityStart][1]);
		SetPenSize(1);
	}
	if (displayline == -1)
	{
		TheCityStart = TheCity;
		displayline = 0;
	}

	char ticket[1000] = "���Ԥ��:";
	

	strcat(ticket, CityName[TheCityStart]);
	strcat(ticket, "---------->");
	strcat(ticket, CityName[TheCity]);


	SetPointSize(25);
	SetPenColor("Red");
	MovePen(1,0.5);
	DrawTextString(ticket);
	SetPointSize(1);
}

void DisplayTrain()
{
	SetPenColor("Gray");
	SetPointSize(40);
	drawBox(1.5,1,5,4,1,"ǰ��������Ժ�����̽����","c","Blue");
	SetPointSize(1);
}


void DisplayRyokou()
{

	typedef enum {
		HotSpot,
		Domestic,
		Abroad,
		AllSpot,
		Search
	}RyokouKind;

	static RyokouKind TheRyokouKind = AllSpot;

	if (button(GenUIID(0), GetWindowWidth() - 1.2, 4, 1, 0.4, "���ž���")) {
		rankProduct();
		TheRyokouKind = HotSpot;
	}

	if (button(GenUIID(0), GetWindowWidth() - 1.2, 3.5, 1, 0.4, "����")) {
		TheRyokouKind = Domestic;
	}

	if (button(GenUIID(0), GetWindowWidth() - 1.2, 3, 1, 0.4, "����"))
	{
		TheRyokouKind = Abroad;
	}

	if (button(GenUIID(0), GetWindowWidth() - 1.2, 2.5, 1, 0.4, "ȫ��"))
	{
		TheRyokouKind = AllSpot;
	}

	if ( administrator_mode )
	{
		if (button(GenUIID(0), GetWindowWidth() - 1.2, 2, 1, 0.4, "���"))
		{
			InitConsole();
			addProduct();
			FreeConsole();
		}
	}

	if (administrator_mode)
	{
		if (button(GenUIID(0), GetWindowWidth() - 1.2, 1.5, 1, 0.4, "ɾ��"))
		{
			InitConsole();
			deleteProduct();
			FreeConsole();
		}
	}

	if (button(GenUIID(0), GetWindowWidth() - 1.2, 4.5, 1, 0.4, "����"))
	{
		TheRyokouKind = Search;
		InitConsole();
		searchProduct();
		FreeConsole();
		
	}

	switch (TheRyokouKind) {
		case HotSpot:
			DisplayRyoKouHotSpot();
			break;
		case Domestic:break;
		case Abroad:break;
		case AllSpot:
			DisplayRyokouAllSpot();
			break;
		case Search:
			DisplaySearch();
			break;
	}

}

void DisplayRyoKouHotSpot()
{
	DisplayRyokouSeries(rankList);
	SwapPages();
}

void DisplayRyokouAllSpot()
{
	DisplayRyokouSeries(pList);
	SwapPages();
}

void DisplaySearch()
{
	DisplayRyokouSeries(searchList);
	SwapPages();
}


void DisplayRyokouSeries(struct Node * headNode)
{
	//��̬������
	static int OnShow = 0;
	static char detail[1000];
	static char number[1000];
	static char price[1000];
	static char date[1000];

	double BoxWidth = 2;
	double BoxHeight = 1.5;

	double ButtonWidth = 0.8;
	double ButtonHeight = GetFontHeight() * 2;

	static int total;
	total = totalNode(headNode);

	struct Node* justForReading;
	justForReading = headNode;

	for (int k = 0 ; k < (PrevInt-1) * 6; k++ )
	{
		justForReading = justForReading->pNext;
	}

	for (int i = 0; i < 2; i++) {

		for (int j = 0; j < 3; j++) {

			double BoxX = 0.2 + ((0.2 + BoxWidth) * j);
			double BoxY = 3.5 - (BoxHeight * 1.5) * i;

			int CurrentOrder = (i * 3 + j) + (PrevInt - 1) * 6 ;

			if (CurrentOrder + 1 > total) break;

			SetPenColor("Light Gray");

			justForReading = justForReading->pNext;

			drawBox(BoxX, BoxY, BoxWidth, BoxHeight, 1, (justForReading->data).name, "c", "Red");


			if (!administrator_mode)
			{
				if (button(GenUIID(CurrentOrder), BoxX, BoxY - ButtonHeight * 1.2, ButtonWidth, ButtonHeight, "Ԥ��"))
				{
					createreservation(justForReading);
					orderProduct(pOrder, &(justForReading->data));

					int UpperLimit = totalNode(pOrder);
					struct Node* pCurrent = pOrder->pNext;

					for (int i = 1; i <= UpperLimit; i++) {

						(pCurrent->data).order = i;
						pCurrent = pCurrent->pNext;

					}

					justForReading->data.number++;

					refreshProduct();//ˢ�²�Ʒ����
					
					TotalInt2 = (UpperLimit / 4) + 1;

				}
			}

			if (button(GenUIID(CurrentOrder), BoxX + ButtonWidth * 1.2, BoxY - ButtonHeight * 1.2, ButtonWidth, ButtonHeight, "��Ϣ"))
			{
				createtrace(justForReading);
				OnShow = !OnShow;
				strcpy(detail, justForReading->data.detail);
				strcpy(number,IntegerToString(justForReading->data.number));
				strcpy(price,IntegerToString(justForReading->data.price));
				strcpy(date, IntegerToString(justForReading->data.date.year));
				strcat(date, "-");
				strcat(date, IntegerToString(justForReading->data.date.month));
				strcat(date, "-");
				strcat(date, IntegerToString(justForReading->data.date.day));

			}

			if (OnShow == 1)
			{
				ShowDetail(detail,number,price,date);

				if (button(GenUIID(0), 5, 4, 0.5, 0.5, "X"))
				{
					OnShow = 0;
				}

			}
		}

	}


}

void displayReservation(struct Node* headNode)
{


	//��̬������
	static int OnShow = 0;
	static char detail[1000];
	static char number[1000];
	static char price[1000];
	static char date[1000];

	double BoxWidth = 2;
	double BoxHeight = 1.5;

	double ButtonWidth = 0.8;
	double ButtonHeight = GetFontHeight() * 2;

	static int total;
	total = totalNode(headNode);

	struct Node* justForReading;
	justForReading = headNode;

	static int theOneToDelete = -1;

	for (int k = 0; k < (PrevInt2 - 1) * 4; k++)
	{
		justForReading = justForReading->pNext;
	}

	for (int i = 0; i < 2; i++) {

		for (int j = 0; j < 2; j++) {

			double BoxX = 3 + ((0.2 + BoxWidth) * j);
			double BoxY = 3.5 - (BoxHeight * 1.5) * i;

			int CurrentOrder = (i * 2 + j) + (PrevInt2 - 1) * 4;

			if (CurrentOrder + 1 > total) break;

			SetPenColor("Light Gray");

			justForReading = justForReading->pNext;

			drawBox(BoxX, BoxY, BoxWidth, BoxHeight, 1, (justForReading->data).name, "c", "Red");



			if (button(GenUIID(CurrentOrder), BoxX, BoxY - ButtonHeight * 1.2, ButtonWidth, ButtonHeight, "ɾ��"))
			{
				theOneToDelete = CurrentOrder+1 ;

				justForReading->data.number -- ;
				refreshProduct();
			}


			if (button(GenUIID(CurrentOrder), BoxX + ButtonWidth * 1.2, BoxY - ButtonHeight * 1.2, ButtonWidth, ButtonHeight, "��Ϣ"))
			{
				OnShow = !OnShow;
				strcpy(detail, justForReading->data.detail);
				strcpy(number, IntegerToString(justForReading->data.number));
				strcpy(price, IntegerToString(justForReading->data.price));
				strcpy(date, IntegerToString(justForReading->data.date.year));
				strcat(date, "-");
				strcat(date, IntegerToString(justForReading->data.date.month));
				strcat(date, "-");
				strcat(date, IntegerToString(justForReading->data.date.day));
			}

			if (OnShow == 1)
			{
				ShowDetail(detail,number,price,date);

				if (button(GenUIID(0), 5, 4, 0.5, 0.5, "X"))
				{
					OnShow = 0;
				}

			}
		}

	}

	if (theOneToDelete != -1)
	{
		justForReading = headNode->pNext;
		while (justForReading && justForReading->data.order != theOneToDelete )
		{
			justForReading = justForReading->pNext;
		}
		deleteProductOrder(justForReading);
		initreservation();


		int UpperLimit = totalNode(pOrder);
		struct Node* pCurrent = pOrder->pNext;

		for (int i = 1; i <= UpperLimit; i++) {

			(pCurrent->data).order = i;
			pCurrent = pCurrent->pNext;

		}

		TotalInt2 = (UpperLimit / 4) + 1;

		theOneToDelete = -1;
	}
	

}

void DisplayHotel()
{

	static int Init = 0;
	static int Changed = 0;
	static int Failed = 0;

	if (!Init) {

		time_t CurrentTime, CurrentTimePlus;

		CurrentTime = time(NULL);

		CurrentTimePlus = time(NULL);

		CurrentTimePlus += 86400;

		struct tm* pCurrentTime = localtime(&CurrentTime); /*��̱ʼǣ��ǳ��Ƽ�����ô��д������localtime����ָ���ͬ��
		�������ÿɵ��º�һֵ����ǰһֵ�������ֲunix��localtimes_r();*/

		strcpy(DateStart.year, IntegerToString((pCurrentTime->tm_year) + 1900));
		strcpy(DateStart.month, IntegerToString((pCurrentTime->tm_mon) + 1));
		strcpy(DateStart.day, IntegerToString((pCurrentTime->tm_mday)));

		struct tm* pCurrentTimePlus = localtime(&CurrentTimePlus);

		strcpy(DateEnd.year, IntegerToString((pCurrentTimePlus->tm_year) + 1900));
		strcpy(DateEnd.month, IntegerToString((pCurrentTimePlus->tm_mon) + 1));
		strcpy(DateEnd.day, IntegerToString((pCurrentTimePlus->tm_mday)));

		Init++;
	}

	if ( !Changed ) 
	{
		memcpy(&DateStartMemory, &DateStart, sizeof(DateStart));
		memcpy(&DateEndMemory, &DateEnd, sizeof(DateEnd));
	}

	SetPenColor("Gray");
	drawRectangle(0.3,3,4.5,2,1);

	SetPenColor("Blue");
	MovePen(0.3, 3.1 + GetFontHeight() * 1.1);
	DrawTextString("For Chinese cities, Enter Standard Pinyin Name of a city");
	MovePen(0.3, 3.1);
	DrawTextString("eg.Beijing instead of 'Peking',Urumuqi instead of 'Wulumuqi'");

	textbox(GenUIID(0), 0.5, 4, 1.5, GetFontHeight() * 2, Cityname, 50);

	textbox(GenUIID(0), 2.1, 4.5, 1, GetFontHeight() * 2, DateStart.year, 5);
	textbox(GenUIID(0), 3.2, 4.5, 0.5, GetFontHeight() * 2, DateStart.month, 5);
	textbox(GenUIID(0), 3.8, 4.5, 0.5, GetFontHeight() * 2, DateStart.day, 5);

	textbox(GenUIID(0), 2.1, 3.5, 1, GetFontHeight() * 2, DateEnd.year, 5);
	textbox(GenUIID(0), 3.2, 3.5, 0.5, GetFontHeight() * 2, DateEnd.month, 5);
	textbox(GenUIID(0), 3.8, 3.5, 0.5, GetFontHeight() * 2, DateEnd.day, 5);

	Changed = 1;

	if (button(GenUIID(0), 0.5, 3.5, 0.8, GetFontHeight() * 2, "ȷ��",  10)) {

		if ( 
			IsValidDate(StringToInteger(DateStart.year), StringToInteger(DateStart.month), StringToInteger(DateStart.day)) && 
			IsValidDate(StringToInteger(DateEnd.year), StringToInteger(DateEnd.month), StringToInteger(DateEnd.day)) &&
			IsValidOrder(StringToInteger(DateStart.year), StringToInteger(DateStart.month), StringToInteger(DateStart.day), StringToInteger(DateEnd.year), StringToInteger(DateEnd.month), StringToInteger(DateEnd.day) )
			)
		{
			memcpy(&DateStartMemory, &DateStart, sizeof(DateStart));
			memcpy(&DateEndMemory, &DateEnd, sizeof(DateEnd));
			memcpy(&DateStartRes, &DateStart, sizeof(DateStart));
			memcpy(&DateEndRes, &DateEnd, sizeof(DateEnd));

			SaveHotel();
			Failed = 0;
		}
		else
		{
			memcpy(&DateStart, &DateStartMemory, sizeof(DateStart));
			memcpy(&DateEnd, &DateEndMemory, sizeof(DateEnd));
			Failed = 1;
		}

		Changed = 0;

	}

	if ( Failed ) 
	{
		MovePen(5, 4);
		SetPenColor("Red");
		SetPointSize(40);
		DrawTextString("FUCK NO");
		SetPointSize(1);
		SetPenColor("Blue");
	}

	
	drawLabel(0.5,2.5,"���Ԥ��:");

	MovePen(0.7,2);
	SetPenColor("Red");
	SetPointSize(20);
	DrawTextString(Cityname);
	SetPointSize(10);

	char  StartDate[1000] = "";

	strcpy(StartDate, DateStartRes.year);
	strcat(StartDate, "-");
	strcat(StartDate, DateStartRes.month);
	strcat(StartDate, "-");
	strcat(StartDate, DateStartRes.day);

	char  EndDate[1000] = "";

	strcpy(EndDate, DateEndRes.year);
	strcat(EndDate, "-");
	strcat(EndDate, DateEndRes.month);
	strcat(EndDate, "-");
	strcat(EndDate, DateEndRes.day);

	MovePen(1.3,2.25);
	DrawTextString(StartDate);

	MovePen(1.3, 1.75);
	DrawTextString(EndDate);

	SetPointSize(1);
}

void SwapPages()
{


	if (button(GenUIID(0), GetWindowWidth() / 2.0 - 0.8, 0.2, 0.4, 0.4, "<")) {
		PrevInt--;
	}

	if (button(GenUIID(0), GetWindowWidth() / 2.0 + 0.8, 0.2, 0.4, 0.4, ">")) {
		PrevInt++;
	}

	if (PrevInt <= 0) {
		PrevInt = TotalInt;
	}
	else if (PrevInt > TotalInt)
	{
		PrevInt = 1;
	}

	MovePen(GetWindowWidth() / 2.0, 0.35);
	SetPointSize(30);
	SetFont("Times");
	SetPenColor("Black");
	DrawTextString(IntegerToString(PrevInt));
	DrawTextString("/");
	DrawTextString(IntegerToString(TotalInt));
	SetFont("default");
	SetPointSize(1);

}

void SwapPages2()
{


	if (button(GenUIID(0), GetWindowWidth() / 2.0 - 0.8, 0.2, 0.4, 0.4, "<")) {
		PrevInt2--;
	}

	if (button(GenUIID(0), GetWindowWidth() / 2.0 + 0.8, 0.2, 0.4, 0.4, ">")) {
		PrevInt2++;
	}

	if (PrevInt2 <= 0) {
		PrevInt2 = TotalInt2;
	}
	else if (PrevInt2 > TotalInt2)
	{
		PrevInt2 = 1;
	}

	MovePen(GetWindowWidth() / 2.0, 0.35);
	SetPointSize(30);
	SetFont("Times");
	SetPenColor("Black");
	DrawTextString(IntegerToString(PrevInt2));
	DrawTextString("/");
	DrawTextString(IntegerToString(TotalInt2));
	SetFont("default");
	SetPointSize(1);

}

void ShowDetail(string detail,string number,string price,string date)
{

	SetPenColor("Gray");
	drawBox(2,1,4,4,1,detail,"c", "Blue");

	SetPenColor("Blue");

	drawLabel(3,2.3,"��������");
	drawLabel(3,2.0,"�۸�");
	drawLabel(3,1.7,"��������");

	drawLabel(3.8,2.3,number);
	drawLabel(3.8,2.0,price);
	drawLabel(3.8,1.7,date);
	
}

void Main()
{
	SetWindowTitle("���ι���ϵͳ");
	SetWindowSize(8, 6);
	InitGraphics();
	InitGUI();

	//���ļ�������ԭ������
	FILE* fp = fopen(FILEPATH, "r");

	pList = (struct Node*)malloc(sizeof(struct Node));
	(pList->pNext) = NULL;

	rankList = (struct Node*)malloc(sizeof(struct Node));
	(rankList->pNext) = NULL;

	if (fp)
	{
		//��ȡ�ļ�����������
		while (count < 100 && fgets(line, 100, fp) != NULL)
		{
			sscanf(line, "%s %s %s %d %d %d %d %d", &products[count].name, &products[count].place, &products[count].detail,
				&products[count].number, &products[count].price, &products[count].date.year,
				&products[count].date.month, &products[count].date.day);

			

			addNode(pList, &products[count]);	//����ڵ�

			count++;

		}


		//�ر��ļ�
		fclose(fp);
	}

	int UpperLimit = totalNode(pList);
	struct Node* pCurrent = pList->pNext;

	for (int i = 1; i <= UpperLimit; i++) {

		( pCurrent->data ).order = i;
		pCurrent = pCurrent->pNext;

	}

	TotalInt =  ( UpperLimit / 6 ) + 1;


	//������������
	searchList = (struct Node*)malloc(sizeof(struct Node));
	searchList->pNext = NULL;


	registerMouseEvent(MouseEventProcess);
	registerKeyboardEvent(KeyboardEventProcess);
	registerCharEvent(CharEventProcess);
	//registerTimerEvent(myTimer);

	//startTimer(BoxTimer,300);
}



int IsValidDate(int year, int month, int day) {

	if (month < 1 || month>12) {
		return 0;
	}
	else if (month == 1 || month == 3 || month == 5 || month == 7 || month == 8 || month == 10 || month == 12) {
		if (day >= 1 && day <= 31) {
			return 1;
		}
		else {
			return 0;
		}
	}
	else if (month == 4 || month == 6 || month == 9 || month == 11) {
		if (day >= 1 && day <= 30) {
			return 1;
		}
		else {
			return 0;
		}
	}                                     //ǰ���Ѿ��ж����Ƿ�Ϊ���»���С�£���ʣ�¶��·ݣ�����Ҫ�ж��Ƿ�Ϊ���ꡣ
	else if ((year % 100 != 0 && year % 4 == 0) || year % 400 == 0) {
		if (day >= 1 && day <= 29) {
			return 1;
		}
		else {
			return 0;
		}
	}
	else {
		if (day >= 1 && day <= 28) {
			return 1;
		}
		else {
			return 0;
		}
	}
	return 0;
}

int IsValidOrder(int StartYear, int StartMonth, int StartDay, int EndYear, int EndMonth, int EndDay)
{
	int Valid = 1;
	time_t CurrentTime;
	Date1 Today;


	CurrentTime = time(NULL);
	struct tm* pCurrentTime = localtime(&CurrentTime); 

	strcpy(Today.year, IntegerToString((pCurrentTime->tm_year) + 1900));
	strcpy(Today.month, IntegerToString((pCurrentTime->tm_mon) + 1));
	strcpy(Today.day, IntegerToString((pCurrentTime->tm_mday)));

	if ( StartYear > EndYear )
	{
		Valid = 0;
	}

	if (StartYear == EndYear && StartMonth > EndMonth )
	{
		Valid = 0;
	}

	if (StartYear == EndYear && StartMonth == EndMonth && StartDay > EndDay )
	{
		Valid = 0;
	}

	if ( StringToInteger(Today.year) > StartYear)
	{
		Valid = 0;
	}

	if (StartYear == StringToInteger(Today.year) && StringToInteger(Today.month) > StartMonth)
	{
		Valid = 0;
	}

	if (StartYear == StringToInteger(Today.year) && StartMonth == StringToInteger(Today.month) && StringToInteger(Today.day) > StartDay )
	{
		Valid = 0;
	}

	return Valid;
}

void SavePlaneTicket()
{
	FILE* fp;


	char IDplane[200];

	strcpy(IDplane, id);
	strcat(IDplane, "PlaneTicket.txt");

	fp = fopen(IDplane, "w");

	char buffer[1000];

	sprintf(buffer, "%d %d", TheCityStart, TheCity);
	fputs(buffer, fp);

	fclose(fp);

}

void RefreshTicket()
{
	FILE* fp;


	char IDplane[200];

	strcpy(IDplane, id);
	strcat(IDplane, "PlaneTicket.txt");

	if ( (fp = fopen(IDplane,"r")) == NULL)
	{
		fp = fopen(IDplane, "w");
	}

	char buffer[1000];



	if ( fgets(buffer, 100, fp) != NULL)
	{
		sscanf(buffer,"%d %d", &TheCityStart, &TheCity);
	}

	fclose(fp);

}

void SaveHotel()
{
	FILE* fp;


	char IDhotel[200];

	strcpy(IDhotel, id);
	strcat(IDhotel, "Hotel.txt");

	fp = fopen(IDhotel, "w");

	char buffer[1000];

	sprintf(buffer, "%s %s %s %s %s %s %s", Cityname, DateStartRes.year, DateStartRes.month, DateStartRes.day, DateEndRes.year, DateEndRes.month, DateEndRes.day);
	fputs(buffer, fp);

	fclose(fp);

}

void RefreshHotel()
{
	FILE* fp;


	char IDhotel[200];

	strcpy(IDhotel, id);
	strcat(IDhotel, "Hotel.txt");

	if ((fp = fopen(IDhotel, "r")) == NULL)
	{
		fp = fopen(IDhotel, "w");
	}

	char buffer[1000];

	if (fgets(buffer, 100, fp) != NULL)
	{
		sscanf(buffer, "%s %s %s %s %s %s %s", Cityname, DateStartRes.year, DateStartRes.month, DateStartRes.day, DateEndRes.year, DateEndRes.month, DateEndRes.day);
	}


	fclose(fp);

}