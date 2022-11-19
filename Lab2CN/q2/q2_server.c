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

struct sockaddr_in srv;

int main()
{

    // Intialising Socket.
    int nSocket = socket(AF_INET, SOCK_STREAM, 0);
    if (nSocket < 0)
    {
        printf("Error 1\n");
        return -1;
    }

    // Intialising sockaddr struct

    // AF_INET is for TCP AND UDP
    srv.sin_family = AF_INET;
    srv.sin_port = htons(PORT);
    // INADDR_ANY gets the hosts IP address automatically
    srv.sin_addr.s_addr = INADDR_ANY;

    // Binding socket to port (Now it is a listener socket)
    int nRet = bind(nSocket, (struct sockaddr *)&srv, sizeof(srv));
    if (nRet < 0)
    {
        printf("Error 2\n");
        return -1;
    }
    // Listening to request from client. Second parameter is queue size.
    nRet = listen(nSocket, 5);
    if (nRet < 0)
    {
        printf("Error 3\n");
        return -1;
    }

    int nClient = 0;
    socklen_t addrlen = sizeof srv;
    pid_t childpid;
    char buffer[1024] = {0};

    while (1)
    {
        nClient = accept(nSocket, (struct sockaddr *)&srv, &addrlen);
        if (nClient < 0)
        {
            printf("Error 4\n");
            return -1;
        }
        printf("Connection accepted\n");

        if ((childpid = fork()) == 0)
        {
            close(nSocket);

            while (1)
            {
                memset(buffer, 0, sizeof(buffer));
                recv(nClient, buffer, 1024, 0);
                printf("Received Word: %s\n", buffer);
                char reverse[1024];
                int i, j, count = 0;
                while (buffer[count] != '\0')
                    count++;
                j = count - 1;

                for (i = 0; i < count; i++)
                {
                    reverse[i] = buffer[j];
                    j--;
                }
                reverse[i] = '\0';
                printf("Reversed Word: %s\n", reverse);
                send(nClient, reverse, strlen(reverse), 0);
            }
        }
    }

    close(nClient);
    shutdown(nSocket, SHUT_RDWR);

    return 0;
}