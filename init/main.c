#include <stdio.h>
#include <unistd.h>

// For now we endlessly print stuff.
int main()
{
    while (1)
    {
        printf("This is a test \n");
        sleep(1);
    }
}