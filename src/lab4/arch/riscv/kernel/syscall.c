#include "syscall.h"
#include <stdint.h>
#include <stddef.h>
#include "proc.h"

extern struct task_struct *current;

uint64_t sys_write(unsigned int fd, const char* buf, size_t count)
{
    //标准输出
    if(fd == 1){
        for(size_t i = 0; i < count; i++){
            //将buf中的字符一个个输出
            printk("%c", buf[i]); 
        }
        return count;
    }
    else{
        return -1;
    }
}

uint64_t sys_getpid()
{
    return current->pid;
}