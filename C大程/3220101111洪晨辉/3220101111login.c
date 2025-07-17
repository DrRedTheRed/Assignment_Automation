//===========================================================================
//
//
//	��¼����
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


typedef enum
{
	None,
	IdNumberWrong,
	IdUsed,
	PasswordWrong
}ErrorState;


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

struct Node
{
	struct Product data;
	struct Node* pNext;
};


extern struct Node* pOrder;

static int setmode = 0;/*judge if in the setting mode, if so, return 1*/


/*all kinds of failure and eMoTionaL DAmaGe. by HCH*/
static ErrorState errorstate = None;


char id[200];/*initially it belongs to DisplayLogin, but for Usage displaying purpose I shift it here. by.HCH*/

int administrator_mode = 0;/*judge if your are the administrator, if so, return 1 and store your information in "administrator.txt"*/

typedef enum {
	Login,
	Usage,
	Personal
}Interface;

extern Interface TheInterface;

extern int TotalInt2;

void DisplayLogin();
int checkUserexisting(char *id,char *password);/*ע��ʱ�ж�id�Ƿ��Ѿ����ڣ����򷵻�1*/
void drawthelabel();/*��ʼ������ͼ*/

void DisplayLogin()
{
	DisplayClear();
	drawthelabel();
	static  char password[200];
	textbox(GenUIID(0), 4, 3, 1.5, 0.5, id, sizeof(id));
	textbox(GenUIID(0), 4, 2, 1.5, 0.5, password, sizeof(password));
	button(GenUIID(0), 2.5, 0.8, 1, 0.5, "��¼"); 
	button(GenUIID(0), 4, 0.8, 1, 0.5, "ע��");
	if(button(GenUIID(0), 5, 5, 1.5, 0.5, administrator_mode ? "����Աģʽ" : "������ģʽ"))
	{
		administrator_mode = !administrator_mode;
	}
	if(button(GenUIID(0), 4, 0.8, 1, 0.5, "ע��"))
	{

		FILE* fp;
		if (strlen(id) != 6) errorstate = IdNumberWrong;
		else
		{
			if (checkUserexisting(&id, &password) == 1) errorstate = IdUsed;
			else
			{
				errorstate = None;
				if (administrator_mode)
				{
					if ((fp = fopen("administrator.txt", "a+")) == NULL)
					{
						printf("File open error!\n");
						exit(0);
					}
				}
				else
				{
					if ((fp = fopen("user.txt", "a+")) == NULL)
					{
						printf("File open error!\n");
						exit(0);
					}
				}
				fprintf(fp, "%s %s\n", id, password);
				if (fclose(fp))
				{
					printf("Can not close the File!\n");
					exit(0);
				}
					
			}
		}
	}
	if (button(GenUIID(0), 2.5, 0.8, 1, 0.5, "��¼"))
	{	
		if (checkUserexisting(&id,&password) == 1)
		{
			//������ĳ�ʼ�����Ǵ����￪ʼ��

			errorstate = None;
			TheInterface = Usage;
			//���ļ�
			char IDorder[200];

			strcpy(IDorder, id);
			strcat(IDorder, "order"); //id ���û���Ĭ���˺�
			strcat(IDorder, ".txt");

			FILE* fp = fopen(IDorder, "r");

			struct Product products[100];	//�����ṹ������洢��Ʒ����
			char line[100];	//��sscanf��ȡ
			int count = 0;	//�Զ�ȡ�Ľṹ����м���

			pOrder = (struct Node*)malloc(sizeof(struct Node));
			pOrder->pNext = NULL;

			if (fp)
			{
				//��ȡ�ļ�����������
				while (count < 100 && fgets(line, 100, fp) != NULL)
				{
					sscanf(line, "%s %s %s %d %d %d %d %d", products[count].name, products[count].place, products[count].detail,
						&products[count].number, &products[count].price, &products[count].date.year,
						&products[count].date.month, &products[count].date.day);

					addNode(pOrder, &products[count]);	//��ͷ����ڵ�

					count++;

				}


				//�ر��ļ�
				fclose(fp);
			}
			
			int UpperLimit = totalNode(pOrder);
			struct Node* pCurrent = pOrder->pNext;

			for (int i = 1; i <= UpperLimit; i++) {

				(pCurrent->data).order = i;
				pCurrent = pCurrent->pNext;

			}

			TotalInt2 = (UpperLimit / 4) + 1;




			inittrace();
			InitUser();

			RefreshTicket();
			RefreshHotel();
		}
		else errorstate = PasswordWrong;
	}
	if (button(GenUIID(0), 5.5, 0.8, 1, 0.5, "�˳�"))  exit(-1);

	if (errorstate  == IdNumberWrong)
	{
		SetPenColor("Blue");
		drawLabel(4, 0.5, "����˺�Ӧ��Ϊ6λ���֣�");
	}

	if (errorstate == IdUsed)
	{
		SetPenColor("Blue");
		drawLabel(4, 0.5, "����˺��Ѿ���ʹ�ã�");
	}
	if (errorstate == PasswordWrong)
	{
		SetPenColor("Blue");
		drawLabel(4, 0.5, "����˺Ż����������");
	}
}


void drawthelabel()
{
	SetPenColor("Blue");
	static char results[200] = "";
	static char str1[80] = "��������˺�";
	drawLabel(2.4, 3.2, str1);
	static char str2[80] = "�����������";
	drawLabel(1.9, 2.2, str2);
	SetPointSize(40);
	static char str3[80] = "��ӭ���������й���ϵͳ��";
	drawLabel(2.2, 4.6, str3);
	SetPointSize(10);
}

int checkUserexisting(char *id,char* password)
{
	FILE* p1,*p2;/*p1 is the pointer to administrator.txt,p2 is user.txt's*/
	char user[30], user1[30], pwd[10];
	int check = 0;
	strcpy(user, id);
	strcpy(pwd, password);/*copy*/
	strcat(user, " "); 
	strcat(user, pwd); /*connecting*/
	strcat(user,"\n");
	int a = 9;
	if ((p2 = fopen("user.txt", "a+")) == NULL)
	{
			printf("File open error!\n");
			exit(0);
	}
	while (!feof(p2))
	{
		fgets(user1, 30, p2);
		if (strcmp(user, user1) == 0)
		{
			check = 1;
			break;
		}
	}
	if (fclose(p2))
	{
		printf("Can not close the File!\n");
		exit(0);
	}

	if ((p1 = fopen("administrator.txt", "a+")) == NULL)
	{
		printf("File open error!\n");
		exit(0);
	}
	while (!feof(p1))
	{
		fgets(user1, 30, p1);
		if (strcmp(user, user1) == 0)
		{
			check = 1;
			break;
		}
	}
	if (fclose(p1))
	{
		printf("Can not close the File!\n");
		exit(0);
	}
	return check;
}
