#ifndef __MM_H__
#define __MM_H__

#include "stdint.h"

struct run {
    struct run *next;
};

void mm_init();

void *kalloc();
void kfree(void *);

#endif
