#ifndef __MM_H__
#define __MM_H__

#include "stdint.h"

struct run {
    struct run *next;
};

void mm_init();

void *kalloc();
void kfree(void *);

struct buddy {
  uint64_t size;
  uint64_t *bitmap; 
};

void buddy_init();
uint64_t buddy_alloc(uint64_t);
void buddy_free(uint64_t);

void *alloc_pages(uint64_t);
void *alloc_page();
void free_pages(void *);

#endif