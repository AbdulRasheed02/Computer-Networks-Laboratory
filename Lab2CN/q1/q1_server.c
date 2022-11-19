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
#define PORT 8200

struct sockaddr_in srv;

int stack[100];
int top = -1;

void push(int x)
{
    stack[++top] = x;
}

int pop()
{
    return stack[top--];
}

int evalPostfix(char *exp)
{
    char *e;
    int n1, n2, n3;
    e = exp;
    int i = 0;
    while (e[i] != '\0')
    {
        if (isdigit(e[i]))
        {
            int num = 0;
            while (isdigit(e[i]))
            {
                num = num * 10 + (int)(e[i] - '0');
                i++;
            }
            i--;
            push(num);
        }
        else if (e[i] != ' ')
        {
            n1 = pop();
            n2 = pop();
            switch (e[i])
            {
            case '+':
                n3 = n1 + n2;
                break;
            case '-':
                n3 = n2 - n1;
                break;
            case '*':
                n3 = n1 * n2;
                break;

            case '/':
                n3 = (int)n2 / n1;
                break;
            }
            push(n3);
        }
        i++;
    }
    // printf("\nThe result of expression %s  =  %d\n\n", exp, pop());
    return pop();
}

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
    nClient = accept(nSocket, (struct sockaddr *)&srv, &addrlen);
    if (nClient < 0)
    {
        printf("Error 4\n");
        return -1;
    }

    char postFixExp[1024] = {0};

    while (1)
    {
        memset(postFixExp, 0, 1024);
        nRet = recv(nClient, postFixExp, sizeof(postFixExp), 0);
        printf("Received Postfix Expression: %s", postFixExp);
        int ans = evalPostfix(postFixExp);
        send(nClient, &ans, sizeof(int), 0);
    }

    close(nClient);
    shutdown(nSocket, SHUT_RDWR);

    return 0;
}
