#include "mm.h"
#include "defs.h"
#include "string.h"
#include "printk.h"

extern char _ekernel[];

struct {
    struct run *freelist;
} kmem;

void *kalloc() {
    struct run *r;

    r = kmem.freelist;
    kmem.freelist = r->next;
    
    memset((void *)r, 0x0, PGSIZE);
    return (void *)r;
}

void kfree(void *addr) {
    struct run *r;

    // PGSIZE align 
    *(uintptr_t *)&addr = (uintptr_t)addr & ~(PGSIZE - 1);

    memset(addr, 0x0, (uint64_t)PGSIZE);

    r = (struct run *)addr;
    r->next = kmem.freelist;
    kmem.freelist = r;

    return;
}

void kfreerange(char *start, char *end) {
    char *addr = (char *)PGROUNDUP((uintptr_t)start);
    for (; (uintptr_t)(addr) + PGSIZE <= (uintptr_t)end; addr += PGSIZE) {
        kfree((void *)addr);
    }
}

void mm_init(void) {
    kfreerange(_ekernel, (char *)PHY_END);
    printk("...mm_init done!\n");
}
