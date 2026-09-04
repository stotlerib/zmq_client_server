#include <stdio.h>
#include <string.h>
#include <unistd.h>
#include <time.h>
#include <zmq.h>

#define BUFFER_SIZE 256

int main(int argument_count, char **arguments)
{
    const char *path = "/tmp/zmq_client_server_0";
    if (argument_count > 1)
    {
        path = arguments[1];
    }

    char socket_path[BUFFER_SIZE];
    snprintf(socket_path, sizeof(socket_path), "ipc://%s", path);

    void *context = zmq_ctx_new();
    if (!context)
    {
        fprintf(stderr, "Error: failed to initialize ZMQ context (%s)\n", zmq_strerror(zmq_errno()));
        return 1;
    }

    void *socket = zmq_socket(context, ZMQ_PUB);
    if (!socket)
    {
        zmq_ctx_destroy(context);
        fprintf(stderr, "Error: failed to create ZMQ socket (%s)\n", zmq_strerror(zmq_errno()));
        return 1;
    }

    unlink(socket_path);

    if (zmq_bind(socket, socket_path) != 0)
    {
        zmq_close(socket);
        zmq_ctx_destroy(context);
        fprintf(stderr, "Error: failed to bind ZMQ socket (%s)\n", zmq_strerror(zmq_errno()));
        return 1;
    }

    printf("Server is running and bound to %s\n\n", socket_path);
    printf("Type 'send' to send the message\n");
    printf("Type 'exit' to quit\n");

    while (1)
    {
        char input_buffer[BUFFER_SIZE];

        if (fgets(input_buffer, sizeof(input_buffer), stdin) == NULL)
        {
            break;
        }

        input_buffer[strcspn(input_buffer, "\n")] = '\0';

        if (strcmp(input_buffer, "exit") == 0)
        {
            break;
        }

        if (strcmp(input_buffer, "send") == 0)
        {
            char time_buffer[64];
            time_t time_seconds = time(NULL);
            struct tm *time_info = localtime(&time_seconds);
            strftime(time_buffer, sizeof(time_buffer), "%Y-%m-%d %H:%M:%S", time_info);

            char message[BUFFER_SIZE];
            snprintf(message, sizeof(message), "Current time: %s", time_buffer);

            if (zmq_send(socket, message, strlen(message), 0) < 0)
            {
                fprintf(stderr, "Failed to send message: %s\n", zmq_strerror(zmq_errno()));
            }
            else
            {
                printf("Message sent\n");
            }
        }
    }

    zmq_close(socket);
    zmq_ctx_destroy(context);
    unlink(socket_path);

    return 0;
}