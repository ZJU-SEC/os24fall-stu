#include "unistd.h"
#include "syscall.h"

int write(int fd, const void *buf, uint64_t count) {
    char temp_buf[count + 1];
    for (int i = 0; i < count; i++) {
        temp_buf[i] = ((char*)buf)[i];
    }
    temp_buf[count] = 0;

    long syscall_ret;
    asm volatile ("li a7, %1\n"
                  "mv a0, %2\n"
                  "mv a1, %3\n"
                  "mv a2, %4\n"
                  "ecall\n"
                  "mv %0, a0\n"
                  : "+r" (syscall_ret)
                  : "i" (SYS_WRITE), "r" ((int64_t)fd), "r" (&temp_buf), "r" (count));
    return syscall_ret;
}

int read(int fd, void *buf, uint64_t count) {
    long syscall_ret;
    asm volatile ("li a7, %1\n"
                  "mv a0, %2\n"
                  "mv a1, %3\n"
                  "mv a2, %4\n"
                  "ecall\n"
                  "mv %0, a0\n"
                  : "+r" (syscall_ret)
                  : "i" (SYS_READ), "r" ((int64_t)fd), "r" (buf), "r" (count));
    return syscall_ret;   
}

int sys_openat(int dfd, char *filename, int flags) {
    long syscall_ret;
    asm volatile ("li a7, %1\n"
                  "mv a0, %2\n"
                  "mv a1, %3\n"
                  "mv a2, %4\n"
                  "ecall\n"
                  "mv %0, a0\n"
                  : "+r" (syscall_ret)
                  : "i" (SYS_OPENAT), "r" ((int64_t)dfd), "r" (filename), "r" ((int64_t)flags));
    return syscall_ret;   
}

int open(char *filename, int flags) {
    return sys_openat(AT_FDCWD, filename, flags);
}

int close(int fd) {
    long syscall_ret;
    asm volatile ("li a7, %1\n"
                  "mv a0, %2\n"
                  "ecall\n"
                  "mv %0, a0\n"
                  : "+r" (syscall_ret)
                  : "i" (SYS_CLOSE), "r" ((int64_t)fd));
    return syscall_ret;
}

int lseek(int fd, int offset, int whence) {
    long syscall_ret;
    asm volatile ("li a7, %1\n"
                  "mv a0, %2\n"
                  "mv a1, %3\n"
                  "mv a2, %4\n"
                  "ecall\n"
                  "mv %0, a0\n"
                  : "+r" (syscall_ret)
                  : "i" (SYS_LSEEK), "r" ((int64_t)fd), "r" ((int64_t)offset), "r" ((int64_t)whence));
    return syscall_ret;
}