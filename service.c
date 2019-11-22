#include <string.h>
#include <stdio.h>
#include <sys/stat.h>
#include <stdlib.h>

#define USERS_FOLDER "users/"

int user_exist(char *name)
{
    int n = strlen(USERS_FOLDER) + strlen(name) + 1;
    char path[n];
    path[0] = '\x00';

    strcat(path, USERS_FOLDER);
    strcat(path, name);

    puts(path);

    struct stat buff;
    if(stat(path, &buff) == 0)
    {
        return 1;
    }
    return 0;
}
void registration(char *name, char *password)
{
    if(user_exist(name) == 1)
    {
        printf("Choose another login");
    } 
    else {
        printf("Success");

    }
}


int main(void)
{
    char name[255];
    char password[255];

    printf("enter <login> <password>");
    fgets(name, 255, stdin);
    fgets(password, 255, stdin);

    registration(name, password);

return 0;
}