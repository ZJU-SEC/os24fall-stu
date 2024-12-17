#include "mm.h"
#include "defs.h"
#include "proc.h"
#include "stdlib.h"
#include "printk.h"
#include "string.h"
#include "elf.h"

extern void __dummy();
extern uint64_t swapper_pg_dir[512];
extern char _sramdisk[];
extern char _eramdisk[];

struct task_struct *idle;           // idle process
struct task_struct *current;        // 指向当前运行线程的 task_struct
struct task_struct *task[NR_TASKS]; // 线程数组，所有的线程都保存在此

// void task_init() {
//     srand(2024);

//     // 1. 调用 kalloc() 为 idle 分配一个物理页
//     // 2. 设置 state 为 TASK_RUNNING;
//     // 3. 由于 idle 不参与调度，可以将其 counter / priority 设置为 0
//     // 4. 设置 idle 的 pid 为 0
//     // 5. 将 current 和 task[0] 指向 idle

//     /* YOUR CODE HERE */
//     idle = (struct task_struct *)kalloc();
//     idle->state = TASK_RUNNING;
//     idle->counter = idle->priority = 0;
//     idle->pid = 0;
//     current = task[0] = idle;

//     // 1. 参考 idle 的设置，为 task[1] ~ task[NR_TASKS - 1] 进行初始化
//     // 2. 其中每个线程的 state 为 TASK_RUNNING, 此外，counter 和 priority 进行如下赋值：
//     //     - counter  = 0;
//     //     - priority = rand() 产生的随机数（控制范围在 [PRIORITY_MIN, PRIORITY_MAX] 之间）
//     // 3. 为 task[1] ~ task[NR_TASKS - 1] 设置 thread_struct 中的 ra 和 sp
//     //     - ra 设置为 __dummy（见 4.2.2）的地址
//     //     - sp 设置为该线程申请的物理页的高地址

//     /* YOUR CODE HERE */
//     for(int i = 1; i < NR_TASKS; i++)
//     {
//         task[i] = (struct task_struct *)kalloc();
//         task[i]->state = TASK_RUNNING;
//         task[i]->counter = 0;
//         task[i]->priority = rand() % (PRIORITY_MAX - PRIORITY_MIN + 1) + PRIORITY_MIN;
//         task[i]->pid = i;
//         task[i]->thread.ra = (uint64_t)__dummy;
//         task[i]->thread.sp = (uint64_t)task[i] + PGSIZE;

//         //将 sepc 设置为 USER_START
//         task[i]->thread.sepc = USER_START;
//         //配置 sstatus 中的 SPP、SPIE、SUM
//         //SPP（使得 sret 返回至 U-Mode）为0
//         //SPIE（使得 sret 时开启中断）为1
//         //SUM（使得 sret 时开启用户态）为1
//         uint64_t pre_sstatus = (0<<8)|(1<<5)|(1<<18);
//         task[i]->thread.sstatus = pre_sstatus;
//         //将 sscratch 设置为 U-Mode 的 sp，其值为 USER_END
//         task[i]->thread.sscratch = USER_END;

//         //对于每个进程，创建属于它自己的页表
//         task[i]->pgd = (uint64_t *)alloc_page();
//         //将内核页表 swapper_pg_dir 复制到每个进程的页表中
//         for(int j = 0; j < 512; j++)
//         {
//             task[i]->pgd[j] = swapper_pg_dir[j];
//         }

//         //拷贝二进制文件置进程专用的物理内存
//         uint64_t size = PGROUNDUP((uint64_t)_eramdisk - (uint64_t)_sramdisk) / PGSIZE;
//         uint64_t mem_copy = alloc_pages(size);
//         for (int j = 0; j < _eramdisk - _sramdisk; ++j) 
//             ((char *)mem_copy)[j] = _sramdisk[j];

//         //将 uapp 所在的页面映射到每个进程的页表中
//         create_mapping(task[i]->pgd, USER_START, (uint64_t)mem_copy - PA2VA_OFFSET,
//             size*PGSIZE, 0b11111);
        
//         //申请一个空的页面来作为用户态栈
//         uint64_t u_stack = (uint64_t)alloc_page();
//         //将用户态栈映射到每个进程的页表中
//         create_mapping(task[i]->pgd, USER_END - PGSIZE, 
//             u_stack - PA2VA_OFFSET, PGSIZE, 0b11111);
//     }
//     /*//thread到task_struck的偏移量
//     printk("offset_thread_to_task_struct=%d\n", offsetof(struct task_struct, thread));
//     //ra到thread_struct的偏移量
//     printk("offset_ra_to_thread_struct=%d\n", offsetof(struct thread_struct, ra));
//     //sp到thread_struct的偏移量
//     printk("offset_sp_to_thread_struct=%d\n", offsetof(struct thread_struct, sp));
//     //s到thread_struct的偏移量
//     printk("offset_s_to_thread_struct=%d\n", offsetof(struct thread_struct, s));
//     //sepc到thread_struct的偏移量
//     printk("offset_sepc_to_thread_struct=%d\n", offsetof(struct thread_struct, sepc));
//     //sstatus到thread_struct的偏移量
//     printk("offset_sstatus_to_thread_struct=%d\n", offsetof(struct thread_struct, sstatus));
//     //sscratch到thread_struct的偏移量
//     printk("offset_sscratch_to_thread_struct=%d\n", offsetof(struct thread_struct, sscratch));
//     //pgd到task_struct的偏移量
//     printk("offset_pgd_to_task_struct=%d\n", offsetof(struct task_struct, pgd));*/
    

//     printk("...task_init done!\n");
// }

void load_program(struct task_struct *task) {
    // 获取ELF文件头
    Elf64_Ehdr *ehdr = (Elf64_Ehdr *)_sramdisk;
    // 获取ELF进程文件头序列首元素（e_phoff：ELF程序文件头数组相对ELF文件头的偏移地址）
    Elf64_Phdr *phdrs = (Elf64_Phdr *)(_sramdisk + ehdr->e_phoff);
    //e_phnum:ELF 文件包含的 Segment 的数量
    for (int i = 0; i < ehdr->e_phnum; ++i) {
        Elf64_Phdr *phdr = phdrs + i;
        if (phdr->p_type == PT_LOAD) {
            // alloc space and copy content
            //从 p_vaddr 到 p_vaddr + p_memsz 区间分配内存空间

            //没有按页对齐的话，需要在拷贝的时候考虑 offset 
            uint64_t true_vaddr = PGROUNDDOWN(phdr->p_vaddr);
            uint64_t offset = (uint64_t)(phdr->p_vaddr) - true_vaddr; 
            uint64_t size = PGROUNDUP(phdr->p_memsz + offset) / PGSIZE;
            uint64_t true_mem_copy = alloc_pages(size);
            uint64_t mem_copy = true_mem_copy + offset;//从mem_copy+offset开始拷贝(0填充)
            //segment_start
            uint64_t seg_start = (uint64_t)_sramdisk + phdr->p_offset;
            for (int j = 0; j < phdr->p_memsz; ++j)
                ((char*)(mem_copy))[j] = ((char *)seg_start)[j];
            //将 [p_vaddr + p_filesz, p_vaddr + p_memsz) 对应的物理区间清零
            memset((void *)(mem_copy + phdr->p_filesz), 0, phdr->p_memsz - phdr->p_filesz);
            // do mapping
            // p_flags:Segment 的权限（包括了读、写和执行）RWE
            uint64_t perm = 0b10001 | ((4 & phdr->p_flags) >> 1) | ((2 & phdr->p_flags) << 1) | ((phdr->p_flags & 1) << 3);//U X W R V
                
            create_mapping(task->pgd, true_vaddr, true_mem_copy - PA2VA_OFFSET,
                phdr->p_memsz + offset, perm);
        }
    }
    task->thread.sepc = ehdr->e_entry;
    //配置 sstatus 中的 SPP、SPIE、SUM
    uint64_t pre_sstatus = (0<<8)|(1<<5)|(1<<18);
    task->thread.sstatus = pre_sstatus;
    //将 sscratch 设置为 U-Mode 的 sp，其值为 USER_END
    task->thread.sscratch = USER_END;
}

void task_init() {
    srand(2024);

    idle = (struct task_struct *)kalloc();
    idle->state = TASK_RUNNING;
    idle->counter = idle->priority = 0;
    idle->pid = 0;
    current = task[0] = idle;

    for(int i = 1; i < NR_TASKS; i++)
    {
        task[i] = (struct task_struct *)kalloc();
        task[i]->state = TASK_RUNNING;
        task[i]->counter = 0;
        task[i]->priority = rand() % (PRIORITY_MAX - PRIORITY_MIN + 1) + PRIORITY_MIN;
        task[i]->pid = i;
        task[i]->thread.ra = (uint64_t)__dummy;
        task[i]->thread.sp = (uint64_t)task[i] + PGSIZE;
        //对于每个进程，创建属于它自己的页表
        task[i]->pgd = (uint64_t *)alloc_page();
        //将内核页表 swapper_pg_dir 复制到每个进程的页表中
        for(int j = 0; j < 512; j++)
        {
            task[i]->pgd[j] = swapper_pg_dir[j];
        }

        load_program(task[i]);
    
        uint64_t u_stack = (uint64_t)alloc_page();
        //将用户态栈映射到每个进程的页表中
        create_mapping(task[i]->pgd, USER_END - PGSIZE, 
            u_stack - PA2VA_OFFSET, PGSIZE, 0b11111);
    }
    printk("...task_init done!\n");
}


#if TEST_SCHED
#define MAX_OUTPUT ((NR_TASKS - 1) * 10)
char tasks_output[MAX_OUTPUT];
int tasks_output_index = 0;
char expected_output[] = "2222222222111111133334222222222211111113";
#include "sbi.h"
#endif

void dummy() {
    uint64_t MOD = 1000000007;
    uint64_t auto_inc_local_var = 0;
    int last_counter = -1;
    while (1) {
        if ((last_counter == -1 || current->counter != last_counter) && current->counter > 0) {
            if (current->counter == 1) {
                --(current->counter);   // forced the counter to be zero if this thread is going to be scheduled
            }                           // in case that the new counter is also 1, leading the information not printed.
            last_counter = current->counter;
            auto_inc_local_var = (auto_inc_local_var + 1) % MOD;
            printk("[PID = %d] is running. auto_inc_local_var = %d\n", current->pid, auto_inc_local_var);
            #if TEST_SCHED
            tasks_output[tasks_output_index++] = current->pid + '0';
            if (tasks_output_index == MAX_OUTPUT) {
                for (int i = 0; i < MAX_OUTPUT; ++i) {
                    if (tasks_output[i] != expected_output[i]) {
                        printk("\033[31mTest failed!\033[0m\n");
                        printk("\033[31m    Expected: %s\033[0m\n", expected_output);
                        printk("\033[31m    Got:      %s\033[0m\n", tasks_output);
                        sbi_system_reset(SBI_SRST_RESET_TYPE_SHUTDOWN, SBI_SRST_RESET_REASON_NONE);
                    }
                }
                printk("\033[32mTest passed!\033[0m\n");
                printk("\033[32m    Output: %s\033[0m\n", expected_output);
                sbi_system_reset(SBI_SRST_RESET_TYPE_SHUTDOWN, SBI_SRST_RESET_REASON_NONE);
            }
            #endif
        }
    }
}

extern void __switch_to(struct task_struct *prev, struct task_struct *next);

void switch_to(struct task_struct *next) {
    //判断下一个执行的线程 next 与当前的线程 current 是否为同一个线程
    //如果是同一个线程，则无需做任何处理，否则调用 __switch_to 进行线程切换
    if (next != current) {
        struct task_struct *prev = current;
        current = next;
        printk("\nswitch to [PID = %d PRIORITY = %d COUNTER = %d]\n",next->pid, next->priority, next->counter);
        __switch_to(prev, next);
    }
    else {
        return;
    }
}

void do_timer() {
    // 1. 如果当前线程是 idle 线程或当前线程时间片耗尽则直接进行调度
    // 2. 否则对当前线程的运行剩余时间减 1，若剩余时间仍然大于 0 则直接返回，否则进行调度
    // YOUR CODE HERE
    if(current == idle || current->counter == 0)
        schedule();
    else {
        current->counter--;
        if(current->counter > 0)
            return;
        else 
            schedule();
    }
}

void schedule() {
    //如果所有线程 counter 都为 0，则令所有线程 counter = priority
    int flag = 0;
    for(int i = 1; i < NR_TASKS; i++)
    {
        if(task[i]->counter != 0)
        {
            flag = 1;
            break;
        }
    }
    if(flag == 0)
    {
        printk("\n");
        for(int i = 1; i < NR_TASKS; i++)
        {
            task[i]->counter = task[i]->priority;
            printk("SET [PID = %d PRIORITY = %d COUNTER = %d]\n", task[i]->pid, task[i]->priority, task[i]->counter);
        }
            
    }
    //调度时选择 counter 最大的线程运行
    int max = 0;
    int next = 0;
    for(int i = 1; i < NR_TASKS; i++)
    {
        if(task[i]->counter > max)
        {
            max = task[i]->counter;
            next = i;
        }
    }
    
    switch_to(task[next]);
}