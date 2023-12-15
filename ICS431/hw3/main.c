#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/wait.h>
#include <unistd.h>

#define MAX_COMMAND_LENGTH 1024
#define MAX_ARGS 64

int main() {
    char input[MAX_COMMAND_LENGTH];
    char *commands[MAX_ARGS];
    int i, status;

    printf("enter your command(s):\n");
    if (fgets(input, sizeof(input), stdin) == NULL) {
        perror("fgets");
        return 1;
    }

    
    input[strcspn(input, "\n")] = 0;

    
    i = 0;
    commands[i] = strtok(input, ";");
    while (commands[i] != NULL) {
        commands[++i] = strtok(NULL, ";");
    }

    
    for (int j = 0; j < i; ++j) {
        pid_t pid = fork();
        if (pid == -1) {
            perror("fork");
            exit(1);
        } else if (pid == 0) { 
            printf("\ncommand : %s\n", commands[j]);

            char *argv[MAX_ARGS];
            int k = 0;
            argv[k] = strtok(commands[j], " ");
            while (argv[k] != NULL) {
                argv[++k] = strtok(NULL, " ");
            }

            
            if (execvp(argv[0], argv) == -1) {
                perror("execvp");
                exit(1);
            }
            exit(0);
        } else { 
            waitpid(pid, &status, 0); 
        }
    }

    return 0;
}
