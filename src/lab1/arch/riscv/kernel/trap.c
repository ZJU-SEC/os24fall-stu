#include "stdint.h"
#include "printk.h"

extern void clock_set_next_event();

void trap_handler(uint64_t scause, uint64_t sepc) {
    // 通过 `scause` 判断trap类型
    if (scause >> 63){ 
        // 如果是interrupt 判断是否是timer interrupt
        if (scause % 8 == 5) { 
            // 如果是timer interrupt 则打印输出相关信息, 并通过 `clock_set_next_event()` 设置下一次时钟中断
            printk("[S] Supervisor Mode Timer Interrupt\n"); 
            clock_set_next_event();
        }
    }
    // `clock_set_next_event()` 见 4.3.4 节
    // 其他interrupt / exception 可以直接忽略
}