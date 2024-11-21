#include "printk.h"
#include "defs.h"

extern void test();

int start_kernel() {
    printk("2024");
    printk(" ZJU Operating System\n");
    //uint64_t cr;
    //cr = csr_read(sstatus);
    //asm volatile("mv a6,%[cr]"::[cr]"r"(cr));
    //int cw = 30;
    //csr_write(sscratch, cw);
    test();
    return 0;
}
