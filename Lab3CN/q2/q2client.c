#include <stdio.h>
#include <sys/socket.h>
#include <arpa/inet.h>
#include <netinet/in.h>
#include <sys/stat.h>
#include <sys/types.h>
#include <unistd.h>
#include <ctype.h>
#include <string.h>
#define PORT 8080

struct sockaddr_in client;

int main()
{
    int nSocket = socket(AF_INET, SOCK_STREAM, 0);
    if (nSocket < 0)
    {
        printf("Error\n");
        return -1;
    }

    client.sin_family = AF_INET;
    client.sin_port = htons(PORT);
    client.sin_addr.s_addr = inet_addr("127.0.0.1");

    int nRet = connect(nSocket, (struct sockaddr *)&client, sizeof(client));
    if (nRet < 0)
    {
        printf("Error\n");
        return -1;
    }

    char msg[1024] = {1};

    while (strncmp("exit",msg,4)!=0)
    {
        memset(msg, 0, 1024);
        fgets(msg, 1023, stdin);
        send(nSocket, msg, sizeof(msg), 0);
    }

    close(nSocket);
    return 0;
}
