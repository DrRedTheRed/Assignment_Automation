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

static int tracecount = 0;//�������������¼����10��ʱ���ж��ٸ������¼,����inittrace();�ã��������Ǹ�������һ����
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

//����ڵ�����
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


//�ⲿ����
//Ԥ���б�
extern struct Node* pOrder;

/*display*/

void inittrace()
{
	/*product�ṹ����product.c�е�struct project�������Ϊȫ�ֱ���*/
	/*
	* struct Product
	{
		int order;
		char name[50];	//����
		char place[10];	//�ص�
		char detail[100];	//��ϸ��Ϣ
		int number;	//��������
		int price;	//���۽��
		struct Date date;	//��������
	};
	*/
	/*��Ҫ��ʾ����Ϣ�ȱ�����linklist�к����*/
	/*����product��ֻ��Ҫname,place����������*/
	/*���ڻ�Ʊ����Ʊ����Ҫ��ʼ�㣬�յ㣬Ʊ�ۣ�*/
	
	

	//
	/*��¼ʱ����10����ʷ��¼���������ں������,�ڵ�¼ʱ��Ҫ����*/
	FILE* fp;
	char line[1000];

	strcpy(IDtrace, id);
	strcat(IDtrace, "trace"); /*id ���û���Ĭ���˺�*/
	strcat(IDtrace, ".txt");

	/*�������ʱ����ʷ��ȡ�ͼ���*/
	if ((fp = fopen(IDtrace, "r")) == NULL)/*�ļ���ȡ*/
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
			//��ȡ�ļ�����������
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
	/*���β�Ʒ��������detail����*/

}


void displaytrace()
{
	for (int i = 0; i < tracecount; i++)
	{
		drawLabel(5 * x, 5 * y - 0.5 * i, str[i]);/*���*/
	}
}

void createtrace(struct Node* traceNode)
{
	TraceLinklist p, q = NULL, r = NULL;

	strcpy(IDtrace, id);
	strcat(IDtrace, "trace"); /*id ���û���Ĭ���˺�*/
	strcat(IDtrace, ".txt");

	/*���º󴴽��½ڵ�p���潫p��������*/
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
	/*���洢10����ʷ��¼*/

	FILE* ffp;/*���º󴴽��ļ����洢��Ϣ���ļ�*/
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
		//��ȡ�ļ�����������
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
		/*ɾ����һ���ڵ�q��Head ��Ϊԭ�ڶ����ڵ�*/
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
		char buffer[1000];	//��sprintf��ȡ

		while (pTemp)
		{	//������д���ļ�

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
	//���β�ƷԤ����������һ��һ��
	//�� �ɻ�ƱԤ��
	//Ԥ�������ݶ�Ϊ

	FILE* fp;

	char IDorder[200];

	strcpy(IDorder, id);
	strcat(IDorder, "order"); //id ���û���Ĭ���˺�
	strcat(IDorder, ".txt");
	//�������ʱ����ʷ��ȡ�ͼ���
	if ((fp = fopen(IDorder, "a+")) == NULL)//�ļ���ȡ
	{
		fp = fopen(IDorder, "w");
	}


	fprintf(fp, "%s %s %s %d %d %d %d %d\n", (orderNode->data).name, (orderNode->data).place, (orderNode->data).detail,
		(orderNode->data).number, (orderNode->data).price,(orderNode->data).date.year, (orderNode->data).date.month, (orderNode->data).date.day);//�浽�ļ�


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
	strcat(IDorder, "order"); //id ���û���Ĭ���˺�
	strcat(IDorder, ".txt");

	//���ļ�
	fp = fopen(IDorder, "w");	//����ԭ�ļ�

	struct Node* pTemp = pOrder->pNext;
	char buffer[100];	//��sprintf��ȡ

	while (pTemp)
	{	//������д���ļ�


		sprintf(buffer, "%s %s %s %d %d %d %d %d\n", (pTemp->data).name, (pTemp->data).place, (pTemp->data).detail,
			(pTemp->data).number, (pTemp->data).price, (pTemp->data).date.year,
			(pTemp->data).date.month, (pTemp->data).date.day);
		fputs(buffer, fp);
		pTemp = pTemp->pNext;
	}

	//�ر��ļ�
	fclose(fp);





}

