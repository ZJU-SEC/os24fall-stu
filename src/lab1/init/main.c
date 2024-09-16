#include "printk.h"
#include "sbi.h"

extern void test();

int start_kernel() {
    printk("2024");
    printk(" ZJU Operating System\n");

    test(); // DO NOT DELETE !!!

    return 0;
}
