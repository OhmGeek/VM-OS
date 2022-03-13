#include <stdlib.h>
#include <stdio.h>
#include <errno.h>
#include <string.h>
#include <unistd.h>
#include <sys/stat.h>
#include <sys/mount.h>
#include <sys/wait.h>
#include <net/if.h>

void spinwait()
{
    // TODO handle signals, acpi events
    while (1)
    {
        sleep(10);
        wait(0);
    }
}

// A helper method to run a command, and direct stdout to the VM output.
void run(char *cmd)
{
    FILE *fp;
    char path[1035];
    // Run the command, redirect output
    fp = popen(cmd, "r");
    if (fp == NULL)
    {
        printf("Failed to run command \n");
        exit(1);
    }

    while (fgets(path, sizeof(path), fp) != NULL)
    {
        printf("%s", path);
    }

    pclose(fp);
}
// Now the main part of the show...
// For now we endlessly print stuff.
int main()
{
    printf("Starting VM-OS! \n");

    // Remount root read/write
    mount("", "/", "", MS_REMOUNT, "discard");
    // Create top level directories
    mkdir("/dev", S_IRWXU | S_IRWXG | S_IROTH | S_IXOTH);
    mkdir("/dev/pts", S_IRWXU | S_IRWXG | S_IROTH | S_IXOTH);
    mount("devpts", "/dev/pts", "devpts", 0, "");

    mkdir("/dev/hugepages", S_IRWXU | S_IRWXG | S_IROTH | S_IXOTH);
    mkdir("/dev/mqueue", S_IRWXU | S_IRWXG | S_IROTH | S_IXOTH);
    mount("mqueue", "/dev/mqueue", "mqueue", 0, "");

    mkdir("/dev/kernel", S_IRWXU | S_IRWXG | S_IROTH | S_IXOTH);
    mkdir("/dev/kernel/debug", S_IRWXU | S_IRWXG | S_IROTH | S_IXOTH);
    mount("debugfs", "/dev/kernel/debug", "debugfs", 0, "");

    mkdir("/proc", S_IRWXU | S_IRWXG | S_IROTH | S_IXOTH);
    mount("proc", "/proc", "proc", 0, "");

    mkdir("/proc/sys", S_IRWXU | S_IRWXG | S_IROTH | S_IXOTH);
    mkdir("/proc/sys/fs", S_IRWXU | S_IRWXG | S_IROTH | S_IXOTH);
    mkdir("/proc/sys/fs/binfmt_misc", S_IRWXU | S_IRWXG | S_IROTH | S_IXOTH);

    mkdir("/proc/sys", S_IRWXU | S_IRWXG | S_IROTH | S_IXOTH);

    mkdir("/tmp", S_IRWXU | S_IRWXG | S_IROTH | S_IXOTH);
    mount("tmpfs", "/tmp", "tmpfs", 0, "");

    mkdir("/sys", S_IRWXU | S_IRWXG | S_IROTH | S_IXOTH);
    mount("sysfs", "/sys", "sysfs", 0, "");

    mkdir("/sys/fs", S_IRWXU | S_IRWXG | S_IROTH | S_IXOTH);
    mkdir("/sys/fs/cgroup", S_IRWXU | S_IRWXG | S_IROTH | S_IXOTH);
    mount("cgroup", "/sys/fs/cgroup", "cgroup2", 0, "");

    // -L indicates the location of seabios
    // -nic none disables networking support (for now) as we don't have network support (yet)
    run("/bin/qemu-system-x86_64 -nographic -nic none -L /usr/share/bios/ 2>&1");
    spinwait();
}
