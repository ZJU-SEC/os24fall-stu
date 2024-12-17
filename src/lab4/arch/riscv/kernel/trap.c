#include "stdint.h"
#include "printk.h"
#include "syscall.h"

extern void clock_set_next_event();

struct pt_regs{ 
    uint64_t x[32]; 
    uint64_t sepc; 
    uint64_t sstatus; 
};

void trap_handler(uint64_t scause, uint64_t sepc, struct pt_regs *regs) {
    // 通过 `scause` 判断trap类型
    if (scause >> 63){ 
        // 如果是interrupt 判断是否是timer interrupt
        if (scause % 8 == 5) { 
            // 如果是timer interrupt 则打印输出相关信息, 并通过 `clock_set_next_event()` 设置下一次时钟中断
            //printk("[S] Supervisor Mode Timer Interrupt\n"); 
            clock_set_next_event();
            do_timer();
        }
    }
    // `clock_set_next_event()` 见 4.3.4 节
    // 其他interrupt / exception 可以直接忽略

    else if(scause == 8)
    {
        //system call

        //sys_write
        //uint64_t sys_write(unsigned int fd, const char* buf, size_t count)
        if(regs->x[17] == 64)
        {
            regs->x[10] = sys_write((unsigned int)regs->x[10], (const char *)regs->x[11], (size_t)regs->x[12]);
        }
        //sys_getpid
        else if(regs->x[17] == 172)
        {
            regs->x[10] = sys_getpid();
        }
        regs->sepc += 4;
    }
}
