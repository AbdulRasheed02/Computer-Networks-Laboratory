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

struct sockaddr_in srv;

int main()
{
  
    int nSocket = socket(AF_INET, SOCK_STREAM, 0);
    if (nSocket < 0)
    {
        printf("Error 1\n");
        return -1;
    }

    srv.sin_family = AF_INET;
    srv.sin_port = htons(PORT);
    srv.sin_addr.s_addr = INADDR_ANY;

    int nRet = bind(nSocket, (struct sockaddr *)&srv, sizeof(srv));
    if (nRet < 0)
    {
        printf("Error 2\n");
        return -1;
    }
    nRet = listen(nSocket, 5);
    if (nRet < 0)
    {
        printf("Error 3\n");
        return -1;
    }

    int nClient = 0;
    socklen_t addrlen = sizeof srv;
    nClient = accept(nSocket, (struct sockaddr *)&srv, &addrlen);
    if (nClient < 0)
    {
        printf("Error 4\n");
        return -1;
    }

    char msg[1024] = {0};

    while (strncmp("exit",msg,4)!=0)
    {
        memset(msg, 0, 1024);
        nRet = recv(nClient, msg, sizeof(msg), 0);
        printf("Message Received from Client: %s", msg);
    }

    printf("Client stopped communication\n.");
    close(nClient);
    shutdown(nSocket, SHUT_RDWR);

    return 0;
}
