#include <windows.h>
#include <winuser.h>
#include "graphics.h"
#include "extgraph.h"
#include "imgui.h"
#include "strlib.h"
#include "linkedlist.h"
#include<stdlib.h>
#include<string.h>
#include<stdio.h>
/*declare*/
void inittrace();
void displaytrace();/*viewing history*/
void createtrace(struct Node* traceNode);
void createreservation(struct Node* orderNode);/*reserved production*/
void initreservation();



extern char id[200];

static double x = 1.0;
static double y = 1.1;
static double w = 1.5;/*the length of button and label*/
static double h = 0.5;/*The height of button and label*/
static char Name[80] = "";/*initially, it is your ID*/
static char Moral[80] = ""; 
static char Name_new[80] = "";/*_new :temporarily store the information you has entered*/
static char Moral_new[80] = "";

static int tracecount = 0;//用来数当浏览记录不到10的时候，有多少个浏览记录,仅供inittrace();用，和下面那个东西不一样的
static int count = 0;
static int total = 0;

char IDtrace[200];
char str[10][1000];

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
struct Trace { 
		char name[50];
		char place[50];
		int year;
		int month;
		int day;
		struct Trace* Next;
		struct Trace* Before;
	};


//产品数据类型(来自product.c)
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

//链表节点类型
struct Node
{
	struct Product data;
	struct Node* pNext;
};


typedef struct Trace* TraceLinklist;
TraceLinklist Head = NULL, Tail = NULL;


static int size = sizeof(struct Trace);
typedef enum{
	Homepage,
	Information,
	Trace,
	Reservation
}state;


//外部变量
//预定列表
extern struct Node* pOrder;

/*display*/

void inittrace()
{
	/*product结构采用product.c中的struct project，将其变为全局变量*/
	/*
	* struct Product
	{
		int order;
		char name[50];	//名称
		char place[10];	//地点
		char detail[100];	//详细信息
		int number;	//销售数量
		int price;	//销售金额
		struct Date date;	//销售日期
	};
	*/
	/*需要显示的信息先被存在linklist中后输出*/
	/*对于product，只需要name,place，销售日期*/
	/*对于机票，火车票，需要起始点，终点，票价？*/
	
	

	//
	/*登录时加载10条历史记录到链表用于后续输出,在登录时就要生成*/
	FILE* fp;
	char line[1000];

	strcpy(IDtrace, id);
	strcat(IDtrace, "trace"); /*id 是用户的默认账号*/
	strcat(IDtrace, ".txt");

	/*进入界面时的历史读取和加载*/
	if ((fp = fopen(IDtrace, "r")) == NULL)/*文件读取*/
	{
		fp = fopen(IDtrace, "w");
	}

	tracecount = 0;

	for (int i = 1; i <= 10; i++)
	{
		TraceLinklist p, q = NULL, r = NULL;
		p = (struct Trace*)malloc(size);

		if (fp) 
		{
			//读取文件并存至链表
			if ( fgets(line, 1000, fp) )
			{
				sscanf(line, "%s %s %d %d %d\n", p->name,p->place,&p->year,&p->month,&p->day);


				tracecount++;

				strcpy(str[i - 1], p->name); strcat(str[i - 1], " "); strcat(str[i - 1], p->place); strcat(str[i - 1], " ");
				strcat(str[i - 1], IntegerToString(p->year)); strcat(str[i - 1], "-"); strcat(str[i - 1], IntegerToString(p->month)); strcat(str[i - 1], "-"); strcat(str[i - 1], IntegerToString(p->day));
			}


		}





	}

	if (fclose(fp))
	{
		printf("Can not close the File!\n");
		exit(0);
	}
	/*旅游产品主界面点击detail生成*/

}


void displaytrace()
{
	for (int i = 0; i < tracecount; i++)
	{
		drawLabel(5 * x, 5 * y - 0.5 * i, str[i]);/*输出*/
	}
}

void createtrace(struct Node* traceNode)
{
	TraceLinklist p, q = NULL, r = NULL;

	strcpy(IDtrace, id);
	strcat(IDtrace, "trace"); /*id 是用户的默认账号*/
	strcat(IDtrace, ".txt");

	/*按下后创建新节点p并存将p插入链表*/
	p = (struct Trace*)malloc(size);
	p->year = (traceNode->data.date).year;
	p->month = (traceNode->data.date).month;
	p->day = (traceNode->data.date).day;
	strcpy(p->name, (traceNode->data).name);
	strcpy(p->place, (traceNode->data).place);
	p->Next = NULL;

	if (Head == NULL)
	{
		Head = p;
	}
	else
	{
		Tail->Next = p;
	}
	Tail = p;
	p->Next = NULL;
	/*最多存储10个历史记录*/

	FILE* ffp;/*按下后创建文件并存储信息至文件*/
	if ((ffp = fopen(IDtrace, "a+")) == NULL)
	{
		printf("File open error!\n");
		exit(0);
	}
	fprintf(ffp, "%s %s %d %d %d\n", p->name, p->place, p->year, p->month, p->day);
	if (fclose(ffp))
	{
		printf("Can not close the File!\n");
		exit(0);
	}

	if ((ffp = fopen(IDtrace, "r")) == NULL)
	{
		printf("File open error!\n");
		exit(0);
	}

	char line[200];
	if (ffp)
	{
		//读取文件并存至链表
		while (fgets(line, 100, ffp))
		{
			count++;
		}

	}
	if (fclose(ffp))
	{
		printf("Can not close the File!\n");
		exit(0);
	}


	if (count > 10)
	{
		count--;
		/*删除第一个节点q，Head 变为原第二个节点*/
		q = Head;
		Head = Head->Next;
		q->Next = NULL;
		free(q);

		if ((ffp = fopen(IDtrace, "w")) == NULL)
		{
			printf("File open error!\n");
			exit(0);
		}

		TraceLinklist pTemp = Head;
		char buffer[1000];	//供sprintf读取

		while (pTemp)
		{	//把链表写进文件

			sprintf(buffer, "%s %s %d %d %d\n", pTemp->name, pTemp->place,
				pTemp->year,pTemp->month, pTemp->day);
			fputs(buffer, ffp);
			pTemp = pTemp->Next;

		}

		if (fclose(ffp))
		{
			printf("Can not close the File!\n");
			exit(0);
		}

	}


	count = 0;

}


void createreservation(struct Node* orderNode)
{
	//旅游产品预定，和上面一摸一样
	//火车 飞机票预定
	//预定链表暂定为

	FILE* fp;

	char IDorder[200];

	strcpy(IDorder, id);
	strcat(IDorder, "order"); //id 是用户的默认账号
	strcat(IDorder, ".txt");
	//进入界面时的历史读取和加载
	if ((fp = fopen(IDorder, "a+")) == NULL)//文件读取
	{
		fp = fopen(IDorder, "w");
	}


	fprintf(fp, "%s %s %s %d %d %d %d %d\n", (orderNode->data).name, (orderNode->data).place, (orderNode->data).detail,
		(orderNode->data).number, (orderNode->data).price,(orderNode->data).date.year, (orderNode->data).date.month, (orderNode->data).date.day);//存到文件


	if (fclose(fp))
	{
		printf("Can not close the File!\n");
		exit(0);
	}

}

void initreservation()
{
	FILE* fp;
	struct Product temp;

	int UpperLimit = totalNode(pOrder);
	struct Node* pCurrent = pOrder->pNext;

	for (int i = 1; i <= UpperLimit; i++) {

		(pCurrent->data).order = i;
		pCurrent = pCurrent->pNext;

	}


	char IDorder[200];

	strcpy(IDorder, id);
	strcat(IDorder, "order"); //id 是用户的默认账号
	strcat(IDorder, ".txt");

	//打开文件
	fp = fopen(IDorder, "w");	//覆盖原文件

	struct Node* pTemp = pOrder->pNext;
	char buffer[100];	//供sprintf读取

	while (pTemp)
	{	//把链表写进文件


		sprintf(buffer, "%s %s %s %d %d %d %d %d\n", (pTemp->data).name, (pTemp->data).place, (pTemp->data).detail,
			(pTemp->data).number, (pTemp->data).price, (pTemp->data).date.year,
			(pTemp->data).date.month, (pTemp->data).date.day);
		fputs(buffer, fp);
		pTemp = pTemp->pNext;
	}

	//关闭文件
	fclose(fp);





}

