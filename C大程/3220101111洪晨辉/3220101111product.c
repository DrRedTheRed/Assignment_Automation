//===========================================================================
//
//  旅游产品的相关操作
//
//  通过链表操作实现
// 
//===========================================================================


#include<stdio.h>
#include<stdlib.h>
#include<string.h>


#define FILEPATH "product.txt"


//产品数据类型
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

struct Node* createList();	//创建一个链表
struct Node* createNode(struct Product* pData);	//创建一个链表节点
void addNode(struct Node* headNode, struct Product* pData);	//表头插入节点
struct Node* searchNode(struct Node* headNode, char* name);	//根据名称查找节点
void deleteNode(struct Node* headNode, char* name);	//根据名称删除节点
void deleteNode2(struct Node* headNode, int number);	//根据销售数量删除节点（用于热门产品的排序）
void deleteList(struct Node* headNode);	//删除整个链表
int totalNode(struct Node* headNode);  //计算链表节点个数


void refreshProduct();//刷新产品
void addProduct();	//添加旅游产品
void deleteProduct();	//删除旅游产品（管理员）
void deleteProductOrder(struct Node *prderNode); //删除旅游产品（个人中心预定）
void searchProduct();  //根据名称查找产品
void rankProduct();  //根据销售数量提供 TOP10 热门产品
void orderProduct();	//根据用户预定生成预定产品单



//外部函数
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
	
	//打开文件
	fp = fopen(FILEPATH, "w");	//覆盖原文件

	struct Node* pTemp = pList->pNext;
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

void addProduct()
{
	 FILE* fp;
	struct Product temp;

	printf("输入旅游产品的名称:\n");
	scanf("%s", temp.name);	//输入旅游产品的名称
	printf("输入旅游产品的地点:\n");
	scanf("%s", temp.place);	//输入旅游产品的地点
	printf("输入旅游产品的详细信息:\n");
	scanf("%s", temp.detail);	//输入旅游产品的详细信息
	printf("输入旅游产品的销售数量:\n");
	scanf("%d", &temp.number);	//输入旅游产品的销售数量
	printf("输入旅游产品的销售金额:\n");
	scanf("%d", &temp.price);	//输入旅游产品的销售金额
	printf("输入旅游产品的销售年:\n");
	scanf("%d", &temp.date.year);	//
	printf("输入旅游产品的销售月:\n");
	scanf("%d", &temp.date.month);	//输入旅游产品的销售日期
	printf("输入旅游产品的销售日期:\n");
	scanf("%d", &temp.date.day);	//

	addNode(  pList, &temp);


	int UpperLimit = totalNode(pList);
	struct Node* pCurrent = pList->pNext;

	for (int i = 1; i <= UpperLimit; i++) {

		(pCurrent->data).order = i;
		pCurrent = pCurrent->pNext;

	}

	//打开文件
	 fp = fopen(FILEPATH, "w");	//覆盖原文件

	struct Node* pTemp = pList->pNext;
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


void deleteProduct()
{
	//打开文件
	FILE* fp;

	struct Product temp;
	scanf("%s", temp.name);	//输入要删除的旅游产品的名称

	deleteNode(pList, temp.name);

	int UpperLimit = totalNode(pList);
	struct Node* pCurrent = pList->pNext;

	for (int i = 1; i <= UpperLimit; i++) {

		(pCurrent->data).order = i;
		pCurrent = pCurrent->pNext;

	}
	
	//打开文件
	fp = fopen(FILEPATH, "w");	//覆盖原文件

	struct Node* pTemp = pList->pNext;
	char buffer[1000];	//供sprintf读取

	while (pTemp)
	{	//把链表写进文件


		sprintf(buffer, "%s %s %s %d %d %d %d %d\n", pTemp->data.name, pTemp->data.place, pTemp->data.detail,
			pTemp->data.number, pTemp->data.price, pTemp->data.date.year,
			pTemp->data.date.month, pTemp->data.date.day);
		fputs(buffer, fp);
		pTemp = pTemp->pNext;
	}

	//关闭文件
	fclose(fp);

}

void deleteProductOrder(struct Node* orderNode)
{
	//打开文件
	FILE* fp;

	struct Product temp;

	deleteNode(pOrder, (orderNode->data).name);

	int UpperLimit = totalNode(pOrder);
	struct Node* pCurrent = pOrder->pNext;

	for (int i = 1; i <= UpperLimit; i++) {

		(pCurrent->data).order = i;
		pCurrent = pCurrent->pNext;

	}

	//打开文件
	fp = fopen(FILEPATH, "w");	//覆盖原文件

	struct Node* pTemp = pOrder->pNext;
	char buffer[1000];	//供sprintf读取

	while (pTemp)
	{	//把链表写进文件


		sprintf(buffer, "%s %s %s %d %d %d %d %d\n", pTemp->data.name, pTemp->data.place, pTemp->data.detail,
			pTemp->data.number, pTemp->data.price, pTemp->data.date.year,
			pTemp->data.date.month, pTemp->data.date.day);
		fputs(buffer, fp);
		pTemp = pTemp->pNext;
	}

	//关闭文件
	fclose(fp);

}

void searchProduct()
{
	free(searchList->pNext);//为了内存请把这个改掉
	searchList->pNext = NULL;
	
	//打开文件
	FILE* fp;

	char namae[1000];
	struct Node *temp;
	temp = (struct Node*)malloc(sizeof(struct Node));
	temp = pList;
	scanf("%s", namae);	//输入要查找的旅游产品的名称

	while ( temp != NULL )	//筛选出符合查找名称的产品并将节点存入新链表
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
	
	
	//打开文件
	fp = fopen("target.txt", "w");	//不再打开原文件，防止丢失

	struct Node* pTemp = searchList->pNext;
	char buffer[1000];	//供sprintf读取

	while (pTemp)
	{	//把链表写进文件


		sprintf(buffer, "%s %s %s %d %d %d %d %d\n", pTemp->data.name, pTemp->data.place, pTemp->data.detail,
													pTemp->data.number, pTemp->data.price, pTemp->data.date.year,
													pTemp->data.date.month, pTemp->data.date.day);
		fputs(buffer, fp);
		pTemp = pTemp->pNext;
	}

	//关闭文件
	fclose(fp);

}


void rankProduct()
{
	free(rankList->pNext);
	rankList->pNext = NULL;

	//打开文件
	FILE* fp = fopen(FILEPATH, "r");

	struct Node* pReishi = NULL;	//创建链表
	struct Product products[100];	//创建结构体数组存储产品数据
	char line[100];	//供sscanf读取
	int count = 0;	//对读取的结构体进行计数

	pReishi = (struct Node*)malloc(sizeof(struct Node));
	pReishi->pNext = NULL;

	if (fp)
	{
		//读取文件并存至链表
		while (count < 100 && fgets(line, 100, fp) != NULL)
		{
			sscanf(line, "%s %s %s %d %d %d %d %d", products[count].name, products[count].place, products[count].detail,
				&products[count].number, &products[count].price, &products[count].date.year,
				&products[count].date.month, &products[count].date.day);

			addNode(pReishi, &products[count]);	//表头插入节点

			count++;

		}


		//关闭文件
		fclose(fp);
	}

	int a[11];

	struct Node* pRun;
	pRun = (struct Node*)malloc(sizeof(struct Node));
	pRun = pReishi;

	for (int i = 0; i < 10; i++)	//筛选出销售数量TOP10热门产品并将节点存入新链表
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
	
	//打开文件
	fp = fopen("top.txt", "w");	//不再打开原文件，防止丢失

	struct Node* pTemp = rankList->pNext;
	char buffer[1000];	//供sprintf读取

	while (pTemp)
	{	//把链表写进文件


		sprintf(buffer, "%s %s %s %d %d %d %d %d\n", pTemp->data.name, pTemp->data.place, pTemp->data.detail,
			pTemp->data.number, pTemp->data.price, pTemp->data.date.year,
			pTemp->data.date.month, pTemp->data.date.day);
		fputs(buffer, fp);
		pTemp = pTemp->pNext;
	}

	fclose(fp);

	deleteList(pReishi);	//删除链表

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


