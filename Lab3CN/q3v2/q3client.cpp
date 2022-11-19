#include <stdio.h>
#include <vector>
#include <algorithm>
#include <sys/socket.h>
#include <arpa/inet.h>
#include <netinet/in.h>
#include <sys/stat.h>
#include <sys/types.h>
#include <unistd.h>
#include <ctype.h>
#include<string.h>
#include <string>
#include <fstream>
#define PORTA 8001
#define PORTB 8002
using namespace std;

int main(){

	int nSocket=socket(AF_INET,SOCK_STREAM,0);
	if(nSocket<0){
		printf("Socket not intialised\n");
		return -1;
	}
	printf("Socket intialised\n");
	
	struct sockaddr_in client;
	client.sin_family = AF_INET;
	client.sin_port = htons(PORTA);
	client.sin_addr.s_addr = inet_addr("127.0.0.1");
	
	int nRet = connect(nSocket, (struct sockaddr *)&client, sizeof(client));
	if (nRet < 0)
	{
		printf("Connection Error\n");
		return -1;
	}
	printf("Succesfully connected to Server 1\n\n");

	vector<int> chunks;
	vector<string> file(10,"");
	char buffer[10000]={0};
	for(int i=0;i<5;i++){
		int chunkNo;
		memset(buffer,0,10000);
		nRet = recv(nSocket, &chunkNo, sizeof(chunkNo),0);
		nRet = recv(nSocket, buffer, sizeof(buffer),0);
		string temp (buffer);
		file[chunkNo]=temp;
		chunks.push_back(chunkNo);
		printf("Chunk %d received from Server 1.\n",chunkNo);
	}
	printf("\n");
	
	int nSocketB=socket(AF_INET,SOCK_STREAM,0);
	if(nSocketB<0){
		printf("Socket not intialised\n");
		return -1;
	}
	
	struct sockaddr_in clientB;
	clientB.sin_family = AF_INET;
	clientB.sin_port = htons(PORTB);
	clientB.sin_addr.s_addr = inet_addr("127.0.0.1");
	
	nRet = connect(nSocketB, (struct sockaddr *)&clientB, sizeof(clientB));
	if (nRet < 0)
	{
		printf("Connection Error\n");
		return -1;
	}
	printf("Succesfully connected to Server 2\n\n");
	
	for(int i=0;i<5;i++){
		int reqChunk;
		memset(buffer,0,10000);
		for(int j=1;j<=10;j++){
			if(find(chunks.begin(),chunks.end(),j)==chunks.end()){
				reqChunk=j;
				break;
			}
		}
		
		printf("Requesting for Chunk %d\n",reqChunk);
		send(nSocketB, &reqChunk, sizeof(int),0);
		nRet = recv(nSocketB, &reqChunk, sizeof(int),0);
		nRet = recv(nSocketB, buffer, sizeof(buffer),0);
		printf("Received Chunk %d from Server 2.\n\n",reqChunk);
		chunks.push_back(reqChunk); 	
		string temp (buffer);
		file[reqChunk]=temp;
		chunks.push_back(reqChunk);
	}
	
	ofstream fout("target.txt");
	for (auto data: file) {
		fout << data;
	}
	fout.close();
	
	close(nSocket);
	close(nSocketB);	
	return 0;
}
