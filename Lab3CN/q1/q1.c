#include <stdio.h>
#include <sys/socket.h>
#include <netdb.h>
#include <string.h>
#include <stdlib.h>
#include <arpa/inet.h>
#include <ctype.h>
#include <unistd.h>

int main()
{
	char hostname[100];
	printf("Enter IP Address: \n");
	gets(hostname);
	
	int start,end;
	printf("Start Port: ");
	scanf("%d" , &start);
	printf("End Port: ");
	scanf("%d" , &end);

	struct sockaddr_in sa;
	strncpy((char*)&sa , "" , sizeof sa);
	sa.sin_family = AF_INET;
	sa.sin_addr.s_addr = inet_addr(hostname);
	
	//Start the port scan loop
	printf("Starting the portscan loop : \n");
	for(int i = start ; i <= end ; i++) 
	{
		sa.sin_port = htons(i);
		int sock = socket(AF_INET , SOCK_STREAM , 0);
		//Connect using that socket and sockaddr structure
		int nRet = connect(sock , (struct sockaddr*)&sa , sizeof sa);
		
		if( nRet < 0 )
		{
			printf("Port %d: Not Open\n",i);
		}
		//connected
		else
		{
			printf("Port %d: Open\n",i);
		}
		close(sock);
	}
	return 0;
}
