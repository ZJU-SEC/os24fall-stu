#ifndef __UNISTD_H__
#define __UNISTD_H__

#include "stddef.h"
#include "stdint.h"

#define AT_FDCWD    -100 
#define O_RDONLY    0x0001
#define O_WRONLY    0x0002
#define O_RDWR      0x0003

#define SEEK_SET    0x0000
#define SEEK_CUR    0x0001
#define SEEK_END    0x0002

int open(char *filename, int flags);
int write(int fd, const void *buf, uint64_t count);
int read(int fd, void *buf, uint64_t count);
int close(int fd);
int lseek(int fd, int offset, int whence);

#endif