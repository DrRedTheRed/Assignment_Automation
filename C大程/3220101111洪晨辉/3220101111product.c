//===========================================================================
//
//  ���β�Ʒ����ز���
//
//  ͨ���������ʵ��
// 
//===========================================================================


#include<stdio.h>
#include<stdlib.h>
#include<string.h>


#define FILEPATH "product.txt"


//��Ʒ��������
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

struct Node* createList();	//����һ������
struct Node* createNode(struct Product* pData);	//����һ������ڵ�
void addNode(struct Node* headNode, struct Product* pData);	//��ͷ����ڵ�
struct Node* searchNode(struct Node* headNode, char* name);	//�������Ʋ��ҽڵ�
void deleteNode(struct Node* headNode, char* name);	//��������ɾ���ڵ�
void deleteNode2(struct Node* headNode, int number);	//������������ɾ���ڵ㣨�������Ų�Ʒ������
void deleteList(struct Node* headNode);	//ɾ����������
int totalNode(struct Node* headNode);  //��������ڵ����


void refreshProduct();//ˢ�²�Ʒ
void addProduct();	//������β�Ʒ
void deleteProduct();	//ɾ�����β�Ʒ������Ա��
void deleteProductOrder(struct Node *prderNode); //ɾ�����β�Ʒ����������Ԥ����
void searchProduct();  //�������Ʋ��Ҳ�Ʒ
void rankProduct();  //�������������ṩ TOP10 ���Ų�Ʒ
void orderProduct();	//�����û�Ԥ������Ԥ����Ʒ��



//�ⲿ����
extern struct Node* pList;
extern struct Node* searchList;
extern struct Node* rankList;
extern struct Node* pOrder;


struct Node* createList()
{
	struct Node* headNode = (struct Node*) malloc(sizeof(struct Node));
	if (headNode == NULL) return NULL;

	headNode->pNext = NULL;

	return headNode;
}


struct Node* createNode(struct Product* pData)
{
	struct Node* pNew = (struct Node*) malloc(sizeof(struct Node));
	if (pNew == NULL) return NULL;



	strcpy(pNew->data.name, pData->name);
	strcpy(pNew->data.place, pData->place);
	strcpy(pNew->data.detail, pData->detail);
	pNew->data.number = pData->number;
	pNew->data.price = pData->price;
	pNew->data.date.year = pData->date.year;
	pNew->data.date.month = pData->date.month;
	pNew->data.date.day = pData->date.day;

	(pNew->pNext) = NULL;

	return pNew;
}


void refreshProduct()
{
	FILE* fp;
	
	//���ļ�
	fp = fopen(FILEPATH, "w");	//����ԭ�ļ�

	struct Node* pTemp = pList->pNext;
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

void addProduct()
{
	 FILE* fp;
	struct Product temp;

	printf("�������β�Ʒ������:\n");
	scanf("%s", temp.name);	//�������β�Ʒ������
	printf("�������β�Ʒ�ĵص�:\n");
	scanf("%s", temp.place);	//�������β�Ʒ�ĵص�
	printf("�������β�Ʒ����ϸ��Ϣ:\n");
	scanf("%s", temp.detail);	//�������β�Ʒ����ϸ��Ϣ
	printf("�������β�Ʒ����������:\n");
	scanf("%d", &temp.number);	//�������β�Ʒ����������
	printf("�������β�Ʒ�����۽��:\n");
	scanf("%d", &temp.price);	//�������β�Ʒ�����۽��
	printf("�������β�Ʒ��������:\n");
	scanf("%d", &temp.date.year);	//
	printf("�������β�Ʒ��������:\n");
	scanf("%d", &temp.date.month);	//�������β�Ʒ����������
	printf("�������β�Ʒ����������:\n");
	scanf("%d", &temp.date.day);	//

	addNode(  pList, &temp);


	int UpperLimit = totalNode(pList);
	struct Node* pCurrent = pList->pNext;

	for (int i = 1; i <= UpperLimit; i++) {

		(pCurrent->data).order = i;
		pCurrent = pCurrent->pNext;

	}

	//���ļ�
	 fp = fopen(FILEPATH, "w");	//����ԭ�ļ�

	struct Node* pTemp = pList->pNext;
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


void deleteProduct()
{
	//���ļ�
	FILE* fp;

	struct Product temp;
	scanf("%s", temp.name);	//����Ҫɾ�������β�Ʒ������

	deleteNode(pList, temp.name);

	int UpperLimit = totalNode(pList);
	struct Node* pCurrent = pList->pNext;

	for (int i = 1; i <= UpperLimit; i++) {

		(pCurrent->data).order = i;
		pCurrent = pCurrent->pNext;

	}
	
	//���ļ�
	fp = fopen(FILEPATH, "w");	//����ԭ�ļ�

	struct Node* pTemp = pList->pNext;
	char buffer[1000];	//��sprintf��ȡ

	while (pTemp)
	{	//������д���ļ�


		sprintf(buffer, "%s %s %s %d %d %d %d %d\n", pTemp->data.name, pTemp->data.place, pTemp->data.detail,
			pTemp->data.number, pTemp->data.price, pTemp->data.date.year,
			pTemp->data.date.month, pTemp->data.date.day);
		fputs(buffer, fp);
		pTemp = pTemp->pNext;
	}

	//�ر��ļ�
	fclose(fp);

}

void deleteProductOrder(struct Node* orderNode)
{
	//���ļ�
	FILE* fp;

	struct Product temp;

	deleteNode(pOrder, (orderNode->data).name);

	int UpperLimit = totalNode(pOrder);
	struct Node* pCurrent = pOrder->pNext;

	for (int i = 1; i <= UpperLimit; i++) {

		(pCurrent->data).order = i;
		pCurrent = pCurrent->pNext;

	}

	//���ļ�
	fp = fopen(FILEPATH, "w");	//����ԭ�ļ�

	struct Node* pTemp = pOrder->pNext;
	char buffer[1000];	//��sprintf��ȡ

	while (pTemp)
	{	//������д���ļ�


		sprintf(buffer, "%s %s %s %d %d %d %d %d\n", pTemp->data.name, pTemp->data.place, pTemp->data.detail,
			pTemp->data.number, pTemp->data.price, pTemp->data.date.year,
			pTemp->data.date.month, pTemp->data.date.day);
		fputs(buffer, fp);
		pTemp = pTemp->pNext;
	}

	//�ر��ļ�
	fclose(fp);

}

void searchProduct()
{
	free(searchList->pNext);//Ϊ���ڴ��������ĵ�
	searchList->pNext = NULL;
	
	//���ļ�
	FILE* fp;

	char namae[1000];
	struct Node *temp;
	temp = (struct Node*)malloc(sizeof(struct Node));
	temp = pList;
	scanf("%s", namae);	//����Ҫ���ҵ����β�Ʒ������

	while ( temp != NULL )	//ɸѡ�����ϲ������ƵĲ�Ʒ�����ڵ����������
	{
		temp = searchNode(temp, namae);
		if (temp == NULL) break;
		addNode(searchList, &(temp->data));
		temp = temp->pNext;
	}

	int UpperLimit = totalNode(searchList);
	struct Node* pCurrent = searchList->pNext;

	for (int i = 1; i <= UpperLimit; i++) {

		(pCurrent->data).order = i;
		pCurrent = pCurrent->pNext;

	}
	
	
	//���ļ�
	fp = fopen("target.txt", "w");	//���ٴ�ԭ�ļ�����ֹ��ʧ

	struct Node* pTemp = searchList->pNext;
	char buffer[1000];	//��sprintf��ȡ

	while (pTemp)
	{	//������д���ļ�


		sprintf(buffer, "%s %s %s %d %d %d %d %d\n", pTemp->data.name, pTemp->data.place, pTemp->data.detail,
													pTemp->data.number, pTemp->data.price, pTemp->data.date.year,
													pTemp->data.date.month, pTemp->data.date.day);
		fputs(buffer, fp);
		pTemp = pTemp->pNext;
	}

	//�ر��ļ�
	fclose(fp);

}


void rankProduct()
{
	free(rankList->pNext);
	rankList->pNext = NULL;

	//���ļ�
	FILE* fp = fopen(FILEPATH, "r");

	struct Node* pReishi = NULL;	//��������
	struct Product products[100];	//�����ṹ������洢��Ʒ����
	char line[100];	//��sscanf��ȡ
	int count = 0;	//�Զ�ȡ�Ľṹ����м���

	pReishi = (struct Node*)malloc(sizeof(struct Node));
	pReishi->pNext = NULL;

	if (fp)
	{
		//��ȡ�ļ�����������
		while (count < 100 && fgets(line, 100, fp) != NULL)
		{
			sscanf(line, "%s %s %s %d %d %d %d %d", products[count].name, products[count].place, products[count].detail,
				&products[count].number, &products[count].price, &products[count].date.year,
				&products[count].date.month, &products[count].date.day);

			addNode(pReishi, &products[count]);	//��ͷ����ڵ�

			count++;

		}


		//�ر��ļ�
		fclose(fp);
	}

	int a[11];

	struct Node* pRun;
	pRun = (struct Node*)malloc(sizeof(struct Node));
	pRun = pReishi;

	for (int i = 0; i < 10; i++)	//ɸѡ����������TOP10���Ų�Ʒ�����ڵ����������
	{
		if (pRun->pNext == NULL)
		{
			break;
		}

		a[i] = pRun->pNext->data.number;

		while (pRun->pNext->pNext)
		{
			if (a[i] <= pRun->pNext->pNext->data.number) a[i] = pRun->pNext->pNext->data.number;
			pRun = pRun->pNext;
		}

		pRun = pReishi;

		while (pRun->pNext)
		{
			if (pRun->pNext->data.number == a[i]) addNode(rankList,pRun->pNext);
			pRun = pRun->pNext;

		}

		pRun = pReishi;

		deleteNode2(pRun, a[i]);

	}

	int UpperLimit = totalNode(rankList);
	struct Node* pCurrent = rankList->pNext;

	for (int i = 1; i <= UpperLimit; i++) {

		(pCurrent->data).order = i;
		pCurrent = pCurrent->pNext;

	}
	
	//���ļ�
	fp = fopen("top.txt", "w");	//���ٴ�ԭ�ļ�����ֹ��ʧ

	struct Node* pTemp = rankList->pNext;
	char buffer[1000];	//��sprintf��ȡ

	while (pTemp)
	{	//������д���ļ�


		sprintf(buffer, "%s %s %s %d %d %d %d %d\n", pTemp->data.name, pTemp->data.place, pTemp->data.detail,
			pTemp->data.number, pTemp->data.price, pTemp->data.date.year,
			pTemp->data.date.month, pTemp->data.date.day);
		fputs(buffer, fp);
		pTemp = pTemp->pNext;
	}

	fclose(fp);

	deleteList(pReishi);	//ɾ������

}


void orderProduct(struct Node* headNode, struct Product* pData)
{
	addNode(headNode,pData);

	int UpperLimit = totalNode(headNode);
	struct Node* pCurrent = headNode->pNext;

	for (int i = 1; i <= UpperLimit; i++) {

		(pCurrent->data).order = i;
		pCurrent = pCurrent->pNext;

	}


}


void addNode(struct Node* headNode, struct Product* pData)
{
	struct Node* newNode = createNode(pData);

	struct Node* pRear;

	pRear = (struct Node*)malloc(sizeof(struct Node));

	pRear = headNode;

	while ( pRear->pNext != NULL )
	{
		pRear = pRear->pNext;
	}
	pRear->pNext = newNode;

}


struct Node* searchNode(struct Node* headNode, char* name)
{
	struct Node* pMove = headNode->pNext;

	if (pMove == NULL) return NULL;

	while (strcmp(pMove->data.name, name))
	{
		pMove = pMove->pNext;
		if (pMove == NULL) break;
	}

	return pMove;
}


void deleteNode(struct Node* headNode, char* name)
{
	struct Node* curNode = headNode->pNext;
	struct Node* frontNode = headNode;
	
	if (curNode == NULL) return;

	while (strcmp(curNode->data.name, name))
	{
		frontNode = curNode;
		curNode = frontNode->pNext;
		if (curNode == NULL) return;

	}

	frontNode->pNext = curNode->pNext;
	
	free(curNode);

}


void deleteNode2(struct Node* headNode, int number)
{
	struct Node* curNode = headNode->pNext;
	struct Node* frontNode = headNode;

	if (curNode == NULL) return;

	while (curNode != NULL)
	{
		if (curNode->data.number != number)
		{
			frontNode = curNode;
			curNode = frontNode->pNext;

		}

		if (curNode->data.number == number)
		{
			frontNode->pNext = curNode->pNext;

			free(curNode);

			curNode = frontNode->pNext;
		}

	}
	

	

}


void deleteList(struct Node* headNode)
{
	struct Node* posNode = headNode->pNext;
	struct Node* tmp;

	headNode->pNext = NULL;

	while(posNode)
		{
		tmp = posNode->pNext;
		free(posNode);
		posNode = tmp;
		}

}


int totalNode(struct Node* headNode)
{
	int num = 0;

	struct Node* pCurrent = headNode;
	while ( pCurrent->pNext )
	{
		num++;
		pCurrent = pCurrent->pNext;
	}

	return num;

}


