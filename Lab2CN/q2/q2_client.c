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

    char word[1024] = {0};

    while (1)
    {
        memset(word, 0, 1024);
        printf("Word to be Reversed: ");
        scanf("%s", &word[0]);
        send(nSocket, word, sizeof(word), 0);
        nRet = recv(nSocket, &word, sizeof(word), 0);
        printf("Reversed Word: %s\n", word);
    }

    close(nSocket);
    return 0;
}