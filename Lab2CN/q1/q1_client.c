#include <stdio.h>
// Library for Socket programming
#include <sys/socket.h>
// defines sockaddr_in structure
#include <arpa/inet.h>
// contains constants and structures needed for internet domain addresses
#include <netinet/in.h>
// contains constructs that facilitate getting information about files attributes.
#include <sys/stat.h>
// contains a number of basic derived types that should be used whenever appropriate
#include <sys/types.h>
#include <unistd.h>
#include <ctype.h>
#include <string.h>
#define PORT 8080

struct sockaddr_in client;

int main()
{

    // Intialising Socket.
    int nSocket = socket(AF_INET, SOCK_STREAM, 0);
    if (nSocket < 0)
    {
        printf("Error\n");
        return -1;
    }

    // Intialising sockaddr struct

    // AF_INET is for TCP AND UDP
    client.sin_family = AF_INET;
    client.sin_port = htons(PORT);
    // Shpuld connect to IP of machine
    client.sin_addr.s_addr = inet_addr("127.0.0.1");

    // Now socket can send messages.
    int nRet = connect(nSocket, (struct sockaddr *)&client, sizeof(client));
    if (nRet < 0)
    {
        printf("Error\n");
        return -1;
    }

    char postFixExp[1024] = {0};
    int temp = 1;

    while (temp)
    {
        memset(postFixExp, 0, 1024);
        printf("Enter Postfix Expression: ");
        fgets(postFixExp, 1023, stdin);
        send(nSocket, postFixExp, sizeof(postFixExp), 0);
        int result;
        nRet = recv(nSocket, &result, sizeof(int), 0);
        printf("Result: %d \n", result);
        printf("Do you want to continue?\n");
        scanf("%d", &temp);

        int nextchar;
        do
        {
            nextchar = getchar();
        } while (nextchar != '\n' && nextchar != EOF);
    }

    close(nSocket);
    return 0;
}