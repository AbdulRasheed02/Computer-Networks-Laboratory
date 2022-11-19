#include<iostream>
#include<vector>
#include<algorithm>
#include<stdio.h>
#include<stdlib.h>
#include<arpa/inet.h>
#include<netinet/in.h>
#include<sys/stat.h>
#include<sys/types.h>
#include<unistd.h>
#include<ctype.h>
#include<string.h>
#include <iostream>
#include <fstream>
#include <sstream>
#include <array>
using namespace std;

#define PORT 8002
struct sockaddr_in srv;

vector<string> divideFile() {

    ifstream fin("large_file.txt");
    vector<string> chunks(10,"");

    if (!fin) {
        cout << "Error opening the file.\n" << endl;
        exit(1);
    }

    fin.seekg(0, ios::end);
    int size = fin.tellg();
    fin.seekg(0, ios::beg);
    int chunksize = size / 10;

    for (int i = 0; i < 9; ++i) {
        char buffer[chunksize + 1];
        fin.read(buffer, chunksize);
        chunks[i] = string(buffer, chunksize);
    }
    int rest = size - 9 * chunksize;
    char buffer[rest + 1];
    fin.read(buffer, rest);
    chunks[9] = string(buffer, rest);
    fin.close();
    return chunks;
}

int main(){

	int nSocket=socket(AF_INET,SOCK_STREAM,0);
	if(nSocket<0){
		printf("Socket not intialised\n");
		return -1;
	}
	printf("Socket intialised\n");
	

	srv.sin_family = AF_INET;
	srv.sin_port = htons(PORT);
	srv.sin_addr.s_addr = INADDR_ANY;
	
	int nRet = bind(nSocket, (struct sockaddr *)&srv, sizeof(srv));
	if (nRet < 0)
	{
		printf("Binding Error\n");
		return -1;
	}
	printf("Binding Successful\n");
	   
	nRet = listen(nSocket, 5);
	if (nRet < 0)
	{
		printf("Listening Error\n");
		return -1;
	}
	printf("Server is Listening\n");
	
	int nClient = 0;
    	socklen_t addrlen = sizeof(srv);
    	nClient = accept(nSocket, (struct sockaddr *)&srv, &addrlen);
    	if (nClient < 0)
    	{
        	printf("Client Error\n");
        	return -1;
    	}
    	printf("Client Connected\n");

	vector<string> dividedFile=divideFile();

	for(int i=0;i<5;i++){
		int chunkNo;
		nRet = recv(nClient, &chunkNo, sizeof(chunkNo),0);
		printf("CLient has request for Chunk %d\n",chunkNo);
		send(nClient, &chunkNo, sizeof(int),0);
		send(nClient,dividedFile[chunkNo].c_str(),sizeof(dividedFile[chunkNo]),0);
		printf("Sent Chunk %d to client.\n\n",chunkNo); 	
	}
	printf("Client Disconnected\n");
	
	close(nClient);
	shutdown(nSocket,SHUT_RDWR);
	
	return 0;
}
