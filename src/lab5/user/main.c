#include "syscall.h"
#include "stdio.h"

#define WAIT_TIME 0x4FFFFFFF

static inline long getpid() {
    long ret;
    asm volatile ("li a7, %1\n"
                  "ecall\n"
                  "mv %0, a0\n"
                : "+r" (ret) 
                : "i" (SYS_GETPID));
    return ret;
}

static inline long fork() {
    long ret;
    asm volatile ("li a7, %1\n"
                  "ecall\n"
                  "mv %0, a0\n"
                : "+r" (ret)
                : "i" (SYS_CLONE));
  return ret;
}

void wait(unsigned int n) {
    for (unsigned int i = 0; i < n; i++);
}


/*************** Test Page Fault Handler ***************/
/* PFH main #1 */
#if defined(PFH1)
int counter = 0;

int main() {
    register void *current_sp __asm__("sp");
    while (1) {
        printf("[U-MODE] pid: %ld, sp is %p, this is print No.%d\n", getpid(), current_sp, ++counter);
        for (unsigned int i = 0; i < 0x4FFFFFFF; i++);
    }
    return 0;
}

/* PFH main #2 */
#elif defined(PFH2)
char global_placeholder[0x1000];
unsigned long global_increment = 0;

int main() {
    while (1) {
        printf("[U-MODE] pid: %ld, increment: %ld\n", getpid(), global_increment++);
        wait(WAIT_TIME);
    }
}

/*************** Test Fork ***************/
/* Fork main #1 */
#elif defined(FORK1)
int global_variable = 0;

int main() {
    int pid;

    pid = fork();

    if (pid == 0) {
        while (1) {
            printf("[U-CHILD] pid: %ld is running! global_variable: %d\n", getpid(), global_variable++);
            wait(WAIT_TIME);
        } 
    } else {
        while (1) {
            printf("[U-PARENT] pid: %ld is running! global_variable: %d\n", getpid(), global_variable++);
            wait(WAIT_TIME);
        } 
    }
    return 0;
}

/* Fork main #2 */
#elif defined(FORK2)
int global_variable = 0;
char placeholder[8192];

int main() {
    int pid;

    for (int i = 0; i < 3; i++) {
        printf("[U] pid: %ld is running! global_variable: %d\n", getpid(), global_variable++);
    }

    placeholder[4096] = 'Z';
    placeholder[4097] = 'J';
    placeholder[4098] = 'U';
    placeholder[4099] = ' ';
    placeholder[4100] = 'O';
    placeholder[4101] = 'S';
    placeholder[4102] = ' ';
    placeholder[4103] = 'L';
    placeholder[4104] = 'a';
    placeholder[4105] = 'b';
    placeholder[4106] = '5';
    placeholder[4107] = '\0';

    pid = fork();

    if (pid == 0) {
        printf("[U-CHILD] pid: %ld is running! Message: %s\n", getpid(), &placeholder[4096]);
        while (1) {
            printf("[U-CHILD] pid: %ld is running! global_variable: %d\n", getpid(), global_variable++);
            wait(WAIT_TIME);
        } 
    } else {
        printf("[U-PARENT] pid: %ld is running! Message: %s\n", getpid(), &placeholder[4096]);
        while (1) {
            printf("[U-PARENT] pid: %ld is running! global_variable: %d\n", getpid(), global_variable++);
            wait(WAIT_TIME);
        } 
    }
    return 0;
}

/* Fork main #3 */
#elif defined(FORK3)
int global_variable = 0;

int main() {

    printf("[U] pid: %ld is running! global_variable: %d\n", getpid(), global_variable++);
    fork();
    fork();

    printf("[U] pid: %ld is running! global_variable: %d\n", getpid(), global_variable++);
    fork();

    while(1) {
        printf("[U] pid: %ld is running! global_variable: %d\n", getpid(), global_variable++);
        wait(WAIT_TIME);
    }
}

#else

int main() {
    printf("No test function specified.\n");
    while(1);
    return 0;
}

#endif
