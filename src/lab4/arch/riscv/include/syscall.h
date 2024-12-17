#ifndef __SYSCALL_H__
#define __SYSCALL_H__

#include "proc.h"
#include "defs.h"
#include <stddef.h>



uint64_t sys_write(unsigned int fd, const char* buf, size_t count);
uint64_t sys_getpid();

#endif