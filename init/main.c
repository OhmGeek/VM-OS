#define _XOPEN_SOURCE 700

#include <fcntl.h>
#include <unistd.h>
#include <stdlib.h>

#include <stdio.h>
#include <errno.h>
#include <string.h>
#include <unistd.h>
#include <sys/stat.h>
#include <sys/mount.h>
#include <sys/wait.h>
#include <net/if.h>
#include <sys/reboot.h>
#include <string.h>

void spinwait()
{
    // TODO handle signals, acpi events
    while (1)
    {
        sleep(10);
        wait(0);
    }
}

void create_passwd_file()
{
    //
    FILE *fp;
    fp = fopen("/etc/passwd", "w+");
    if (fp == NULL)
    {
        printf("Failed to create passwd file.");
        exit(1);
    }
    fputs("root:x:0:0:root:/root:/bin/sh\n", fp);
    fclose(fp);
}

void create_groups()
{
    // Create groups file
    FILE *fp;
    fp = fopen("/etc/group", "w+");
    if (fp == NULL)
    {
        printf("Failed to create group file.");
        exit(1);
    }
    fputs("root:x:0:\n", fp);
    fputs("weston-launch:x:16:\n", fp);
    fclose(fp);
}

// A helper method to run a command, and direct stdout to the VM output.
void run_with_stdout(char *cmd)
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

void terminate_system()
{
    reboot(RB_POWER_OFF);
}

// Now the main part of the show...
// For now we endlessly print stuff.
int main()
{
    printf("Starting VM-OS! \n");

    // Remount root read/write
    mount("", "/", "", MS_REMOUNT, "");
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
    mkdir("/tmp/.xdg", S_IRWXU | S_IRWXG | S_IROTH | S_IXOTH);
    mkdir("/sys", S_IRWXU | S_IRWXG | S_IROTH | S_IXOTH);
    mount("sysfs", "/sys", "sysfs", 0, "");

    mkdir("/sys/fs", S_IRWXU | S_IRWXG | S_IROTH | S_IXOTH);
    mkdir("/sys/fs/cgroup", S_IRWXU | S_IRWXG | S_IROTH | S_IXOTH);
    mount("cgroup", "/sys/fs/cgroup", "cgroup2", 0, "");

    // Create configuration directory
    mkdir("/etc", S_IRWXU | S_IRWXG | S_IROTH | S_IXOTH);

    // 1. As we're running this without systemd (ew), we need to create users/groups manually. See https://bugs.gentoo.org/479468.
    create_passwd_file();
    create_groups();

    // Print the current tty as we will eventually use this for weston. For now hard code. Note: we should remove this later.
    system("/bin/tty");

    // For the main block, we create a new process which runs all.
    pid_t child = fork();
    if (child == -1)
    {
        printf("Couldn't create fork");
        exit(1);
    }
    else
    {
        system("/bin/qemu-system-x86_64 -m 512m -nographic -nic none -cdrom /opt/images/*.iso -L /usr/share/bios/ 2>&1");
    }

    while (1)
    {
        sleep(1);
        wait(0);
    }

    spinwait();
    // terminate_system();
    return 0;
}
