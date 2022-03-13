#include <stdio.h>
#include <unistd.h>
#include <stdlib.h>

void spinwait() {
    // TODO handle signals, acpi events
    while (1) {
        sleep(10);
        wait(0);
    }
}

// A helper method to run a command, and direct stdout to the VM output.
void run(char* cmd) {
    FILE *fp;
    char path[1035];
    // Run the command, redirect output
    fp = popen(cmd, "r");
    if (fp == NULL) {
        printf("Failed to run command \n");
        exit(1);
    }

    while (fgets(path, sizeof(path), fp) != NULL) {
        printf("%s", path);
    }

    pclose(fp);
}
// Now the main part of the show...
// For now we endlessly print stuff.
int main()
{
    printf("Starting VM-OS! \n");
    run("/bin/ls");
    run("/bin/qemu-system-x86_64 -accel kvm -nographic 2>&1");
    spinwait();
}
