# Lab 2: RV64 内核线程调度

## 实验目的

* 了解线程概念，并学习线程相关结构体，并实现线程的初始化功能
* 了解如何使用时钟中断来实现线程的调度
* 了解线程切换原理，并实现线程的切换
* 掌握简单的线程调度算法，并完成简单调度算法的实现

## 实验环境

* Environment in previous labs

## 背景知识
### 前言

在 lab1 中，我们利用 trap 赋予了 OS 与软件，硬件的交互能力。但是目前我们的 OS 还不具备多进程调度以及并发执行的能力。在本次实验中，我们将利用时钟中断，来实现多进程的调度以使得多个进程/线程并发执行。

### 进程与线程

**源代码**经编译器一系列处理（编译、链接、优化等）后得到的可执行文件，我们称之为**程序（Program）**。而通俗地说，**进程**就是正在运行并使用计算机资源的程序。**进程**与**程序**的不同之处在于，**进程**是一个动态的概念，其不仅需要将其运行的程序的代码/数据等加载到内存空间中，还需要拥有自己的**运行栈**。同时一个**进程**可以对应一个或多个**线程**，**线程**之间往往具有相同的代码，共享一块内存，但是却有不同的 CPU 执行状态。

!!! note "在本次实验中，为了简单起见，我们采用 **single-threaded process** 模型，即**一个进程**对应**一个线程**，进程与线程不做明显区分"

### 线程相关属性

在不同的操作系统中，为每个线程所保存的信息都不同。在这里，我们提供一种基础的实现，每个线程会包括：

* 线程 ID：用于唯一确认一个线程；
* 运行栈：每个线程都必须有一个独立的运行栈，保存运行时的数据；
* 执行上下文：当线程不在执行状态时，我们需要保存其上下文（其实就是**状态寄存器**的值），这样之后才能够将其恢复，继续运行；
* 运行时间片：为每个线程分配的运行时间；
* 优先级：在优先级相关调度时，配合调度算法，来选出下一个执行的线程。

### 线程切换流程图
```
           Process 1         Operating System            Process 2
               +
               |                                            X
 P1 executing  |                                            X
               |                                            X
               v Timer Interrupt Trap                       X
               +---------------------->                     X
                                      +                     X
               X                  do_timer()                X
               X                      +                     X
               X                  schedule()                X
               X                      +                     X
               X              save state to PCB1            X
               X                      +                     X
               X           restore state from PCB2          X
               X                      +                     X
               X                      |                     X
               X                      v Timer Interrupt Ret
               X                      +--------------------->
               X                                            |
               X                                            |  P2 executing
               X                                            |
               X                       Timer Interrupt Trap v
               X                      <---------------------+
               X                      +
               X                  do_timer()
               X                      +
               X                  schedule()
               X                      +
               X              save state to PCB2
               X                      +
               X           restore state from PCB1
               X                      +
               X                      |
                 Timer Interrupt Ret  v
               <----------------------+
               |
 P1 executing  |
               |
               v
```

* 在每次处理时钟中断时，操作系统首先会将当前线程的运行剩余时间减少一个单位，之后根据调度算法来确定是继续运行还是调度其他线程来执行；
* 在进程调度时，操作系统会遍历所有可运行的线程，按照一定的调度算法选出下一个执行的线程，最终将选择得到的线程与当前线程切换；
* 在切换的过程中，首先我们需要保存当前线程的执行上下文，再将将要执行线程的上下文载入到相关寄存器中，至此我们就完成了线程的调度与切换。

## 实验步骤

### 准备工程

此次实验基于 lab1 同学所实现的代码进行。

!!! tip "每次 lab 都要记得留存该次的代码作为备份，建议使用 git 进行本地管理（注意不要上传到公开 repo）"

* 从本仓库 src/lab2 同步以下代码：

    ```
    .
    ├── arch
    │   └── riscv
    │       ├── include
    │       │   ├── mm.h
    │       │   └── proc.h
    │       └── kernel
    │           ├── mm.c        # 一个简单的物理内存管理接口
    │           └── proc.c      # 本次实验的重点部分，进行线程的管理
    ├── include
    │   ├── stdlib.h            # rand 及 srand 在这里（与 C 语言 stdlib.h 一致）
    │   └── string.h            # memset 在这里（与 C 语言 string.h 一致）
    └── lib
        ├── rand.c              # rand 和 srand 的实现（参考 musl libc）
        └── string.c            # memset 的实现
    ```

* `arch/riscv/include/defs.h` 与 `arch/riscv/kernel/head.S` 的修改：
    - 本实验中中我们需要一些物理内存管理的接口，在此我们提供了 `kalloc` 接口（见`mm.c`）给大家，调用 `kalloc` 即可申请一个 4KiB 的物理页；
    - 由于引入了简单的物理内存管理，需要在 `_start` 的适当位置调用 `mm_init` 函数来初始化内存管理系统；
    - 在初始化时需要用一些自定义的宏，因此需要在 `defs.h` 中添加如下内容：
        ```c
        #define PHY_START 0x0000000080000000
        #define PHY_SIZE 128 * 1024 * 1024 // 128 MiB，QEMU 默认内存大小
        #define PHY_END (PHY_START + PHY_SIZE)

        #define PGSIZE 0x1000 // 4 KiB
        #define PGROUNDUP(addr) ((addr + PGSIZE - 1) & (~(PGSIZE - 1)))
        #define PGROUNDDOWN(addr) (addr & (~(PGSIZE - 1)))
        ```
    - 添加/修改上述文件代码之后，先运行一下确保工程可以正常运行，之后再开始进行本次试验；
* 本次试验中中需要同学需要修改并完善以下文件：
    - `arch/riscv/kernel/proc.c`
    - `arch/riscv/kernel/head.S`
    - `arch/riscv/kernel/entry.S`
    - `arch/riscv/kernel/trap.c`
    - `Makefile`

#### `proc.h` 数据结构定义

```c title="arch/riscv/include/proc.h" linenums="4"
#include "stdint.h"

#ifdef TEST_SCHED
#define NR_TASKS (1 + 4)    // 测试时线程数量
#else
#define NR_TASKS (1 + 31)   // 用于控制最大线程数量（idle 线程 + 31 内核线程）
#endif

#define TASK_RUNNING 0      // 为了简化实验，所有的线程都只有一种状态

#define PRIORITY_MIN 1
#define PRIORITY_MAX 10

/* 线程状态段数据结构 */
struct thread_struct {
    uint64_t ra;
    uint64_t sp;
    uint64_t s[12];
};

/* 线程数据结构 */
struct task_struct {
    uint64_t state;     // 线程状态
    uint64_t counter;   // 运行剩余时间
    uint64_t priority;  // 运行优先级 1 最低 10 最高
    uint64_t pid;       // 线程 id

    struct thread_struct thread;
};

/* 线程初始化，创建 NR_TASKS 个线程 */
void task_init();

/* 在时钟中断处理中被调用，用于判断是否需要进行调度 */
void do_timer();

/* 调度程序，选择出下一个运行的线程 */
void schedule();

/* 线程切换入口函数 */
void switch_to(struct task_struct *next);

/* dummy funciton: 一个循环程序，循环输出自己的 pid 以及一个自增的局部变量 */
void dummy();
```

### 线程调度功能实现
#### 线程初始化

* 在初始化线程的时候，我们参考 [Linux v0.11 中的实现](https://elixir.bootlin.com/linux/0.11/source/kernel/fork.c#L93)为每个线程分配一个 4 KiB 的物理页，我们将 `task_struct` 存放在该页的低地址部分，将线程的栈指针 `sp` 指向该页的高地址。具体内存布局如下图所示：
    ```
                        ┌─────────────┐◄─── High Address
                        │             │
                        │    stack    │
                        │             │
                        │             │
                  sp ──►├──────┬──────┤
                        │      │      │
                        │      ▼      │
                        │             │
                        │             │
                        │             │
                        │             │
        4KiB Page       │             │
                        │             │
                        │             │
                        │             │
                        ├─────────────┤
                        │             │
                        │             │
                        │ task_struct │
                        │             │
                        │             │
                        └─────────────┘◄─── Low Address
    ```
* 当我们的 OS 运行起来的时候，其本身就是一个线程（idle 线程），但是我们并没有为它设计好 `task_struct`，所以第一步我们要：
    - 为 `idle` 设置好 `task_struct` 的内容；
    - 将 `current`，`task[0]` 都指向 `idle`；
* 为了方便起见，我们将 `task[1]` ~ `task[NR_TASKS - 1]` 全部初始化，这里和 `idle` 设置的区别在于要为这些线程设置 `thread_struct` 中的 `ra` 和 `sp`，具体见代码：
    ```c title="arch/riscv/kernel/proc.c" linenums="7"
    extern void __dummy();

    struct task_struct *idle;           // idle process
    struct task_struct *current;        // 指向当前运行线程的 task_struct
    struct task_struct *task[NR_TASKS]; // 线程数组，所有的线程都保存在此

    void task_init() {
        srand(2024);

        // 1. 调用 kalloc() 为 idle 分配一个物理页
        // 2. 设置 state 为 TASK_RUNNING;
        // 3. 由于 idle 不参与调度，可以将其 counter / priority 设置为 0
        // 4. 设置 idle 的 pid 为 0
        // 5. 将 current 和 task[0] 指向 idle

        /* YOUR CODE HERE */

        // 1. 参考 idle 的设置，为 task[1] ~ task[NR_TASKS - 1] 进行初始化
        // 2. 其中每个线程的 state 为 TASK_RUNNING, 此外，counter 和 priority 进行如下赋值：
        //     - counter  = 0;
        //     - priority = rand() 产生的随机数（控制范围在 [PRIORITY_MIN, PRIORITY_MAX] 之间）
        // 3. 为 task[1] ~ task[NR_TASKS - 1] 设置 thread_struct 中的 ra 和 sp
        //     - ra 设置为 __dummy（见 4.2.2）的地址
        //     - sp 设置为该线程申请的物理页的高地址

        /* YOUR CODE HERE */

        printk("...task_init done!\n");
    }
    ```

    !!! tip "Debug 提示"
        1. 修改 `proc.h` 中的 `NR_TASKS` 为一个比较小的值，比如 5，这样除去 `task[0]`（idle），只需要初始化 4 个线程，方便调试；
        2. 注意以上的修改只是为了在做实验的过程中方便调试，最后一定记住要修改回去！！！

* 在 `arch/riscv/kernel/head.S` 中合适位置处调用 `task_init()` 进行线程初始化。

#### `__dummy` 与 `dummy` 的实现

* `task[1]` ~ `task[NR_TASKS - 1]` 都运行同一段代码 `dummy()` 我们在 `proc.c` 中定义了这个函数：
    ```c title="arch/riscv/kernel/proc.c（除去 TEST_SCHED 之外的部分）"
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
            }
        }
    }
    ```
    
    !!! tip "Debug 提示：可以用 printk 打印更多的信息"

* 当线程在运行时，由于时钟中断的触发，会将当前运行线程的上下文环境保存在栈上；当线程再次被调度时，会将上下文从栈上恢复，但是当我们创建一个新的线程，此时线程的栈为空，当这个线程被调度时，是没有上下文需要被恢复的，所以我们需要为线程**第一次调度**提供一个特殊的返回函数 `__dummy`：
    -  在 `arch/riscv/kernel/entry.S` 中添加函数 `__dummy`：
        - 在 `__dummy` 中将 sepc 设置为 `dummy()` 的地址，并使用 `sret` 从 S 模式中返回；
        ```asm title="arch/riscv/kernel/entry.S"
            .extern dummy
            .globl __dummy
        __dummy:
            # YOUR CODE HERE
        ```

#### 实现线程切换

* 判断下一个执行的线程 `next` 与当前的线程 `current` 是否为同一个线程，如果是同一个线程，则无需做任何处理，否则调用 `__switch_to` 进行线程切换：
    ```c title="arch/riscv/kernel/proc.c"
    extern void __switch_to(struct task_struct *prev, struct task_struct *next);

    void switch_to(struct task_struct *next) {
        // YOUR CODE HERE
    }
    ```
* 在 `entry.S` 中实现线程上下文切换 `__switch_to`：
    - `__switch_to` 接受两个 `task_struct` 指针作为参数；
    - 保存当前线程的 `ra`，`sp`，`s0~s11` 到当前线程的 `thread_struct` 中；
    - 将下一个线程的 `thread_struct` 中的相关数据载入到 `ra`，`sp`，`s0~s11` 中进行恢复：
    ```asm title="arch/riscv/kernel/entry.S"
        .globl __switch_to
    __switch_to:
        # save state to prev process
        # YOUR CODE HERE

        # restore state from next process
        # YOUR CODE HERE

        ret
    ```

    !!! tip "Debug 提示"
        - 在 `NR_TASKS = 1+1` 时，可以尝试是否可以从 idle 正确切换到 process 1
        - 注意在切换过程中的 pc 变化，且注意 `current` 的更新

#### 实现调度入口函数

* 实现 `do_timer()` 函数，并在 `trap.c` 时钟中断处理函数中调用：
    ```c title="arch/riscv/kernel/proc.c"
    void do_timer() {
        // 1. 如果当前线程是 idle 线程或当前线程时间片耗尽则直接进行调度
        // 2. 否则对当前线程的运行剩余时间减 1，若剩余时间仍然大于 0 则直接返回，否则进行调度

        // YOUR CODE HERE
    }
    ```

#### 线程调度算法实现

本次实验我们需要参考 [Linux v0.11 调度算法代码](https://elixir.bootlin.com/linux/0.11/source/kernel/sched.c#L122)实现一个优先级调度算法，具体逻辑如下：

- `task_init` 的时候随机为各个线程赋予了优先级
- 调度时选择 `counter` 最大的线程运行
- 如果所有线程 `counter` 都为 0，则令所有线程 `counter = priority`
    - 即优先级越高，运行的时间越长，且越先运行
    - 设置完后需要重新进行调度
- 最后通过 `switch_to` 切换到下一个线程

```c title="arch/riscv/kernel/proc.c"
void schedule() {
    // YOUR CODE HERE
}
```

!!! tip "Debug 提示：可以先将 `NR_TASKS` 改为较小的值，调用 `printk` 将所有线程的信息打印出来"

### 编译及测试

- 由于加入了一些新的 .c 文件，可能需要修改一些 Makefile 文件，请同学自己尝试修改，使项目可以编译并运行；
- 为了验证算法正确性，本次实验加入了一个测试样例（在 4 个线程的情况下的 pid 输出）
    - 测试会在编译时定义了 `TEST_SCHED` 且值不为 0 的情况下进行（[Conditional inclusion](https://en.cppreference.com/w/c/preprocessor/conditional)），所以需要修改 Makefile：
        ```makefile
        TEST_SCHED	:=	0
        CFLAG	:=	$(CF) $(INCLUDE) -DTEST_SCHED=$(TEST_SCHED)
        ```
    - 这样 `make TEST_SCHED=1 run` 的情况下就会给编译加上 `-DTEST_SCHED=1` 的选项，从而进行测试

一切均正常实现后得到的结果应该如下：

??? success "`make TEST_SCHED=1 run` 的正确输出"
    ```text
    ...mm_init done!
    ...task_init done!
    2024 ZJU Operating System

    SET [PID = 1 PRIORITY = 7 COUNTER = 7]
    SET [PID = 2 PRIORITY = 10 COUNTER = 10]
    SET [PID = 3 PRIORITY = 4 COUNTER = 4]
    SET [PID = 4 PRIORITY = 1 COUNTER = 1]

    switch to [PID = 2 PRIORITY = 10 COUNTER = 10]
    [PID = 2] is running. auto_inc_local_var = 1
    [PID = 2] is running. auto_inc_local_var = 2
    [PID = 2] is running. auto_inc_local_var = 3
    [PID = 2] is running. auto_inc_local_var = 4
    [PID = 2] is running. auto_inc_local_var = 5
    [PID = 2] is running. auto_inc_local_var = 6
    [PID = 2] is running. auto_inc_local_var = 7
    [PID = 2] is running. auto_inc_local_var = 8
    [PID = 2] is running. auto_inc_local_var = 9
    [PID = 2] is running. auto_inc_local_var = 10

    switch to [PID = 1 PRIORITY = 7 COUNTER = 7]
    [PID = 1] is running. auto_inc_local_var = 1
    [PID = 1] is running. auto_inc_local_var = 2
    [PID = 1] is running. auto_inc_local_var = 3
    [PID = 1] is running. auto_inc_local_var = 4
    [PID = 1] is running. auto_inc_local_var = 5
    [PID = 1] is running. auto_inc_local_var = 6
    [PID = 1] is running. auto_inc_local_var = 7

    switch to [PID = 3 PRIORITY = 4 COUNTER = 4]
    [PID = 3] is running. auto_inc_local_var = 1
    [PID = 3] is running. auto_inc_local_var = 2
    [PID = 3] is running. auto_inc_local_var = 3
    [PID = 3] is running. auto_inc_local_var = 4

    switch to [PID = 4 PRIORITY = 1 COUNTER = 1]
    [PID = 4] is running. auto_inc_local_var = 1

    SET [PID = 1 PRIORITY = 7 COUNTER = 7]
    SET [PID = 2 PRIORITY = 10 COUNTER = 10]
    SET [PID = 3 PRIORITY = 4 COUNTER = 4]
    SET [PID = 4 PRIORITY = 1 COUNTER = 1]

    switch to [PID = 2 PRIORITY = 10 COUNTER = 10]
    [PID = 2] is running. auto_inc_local_var = 11
    [PID = 2] is running. auto_inc_local_var = 12
    [PID = 2] is running. auto_inc_local_var = 13
    [PID = 2] is running. auto_inc_local_var = 14
    [PID = 2] is running. auto_inc_local_var = 15
    [PID = 2] is running. auto_inc_local_var = 16
    [PID = 2] is running. auto_inc_local_var = 17
    [PID = 2] is running. auto_inc_local_var = 18
    [PID = 2] is running. auto_inc_local_var = 19
    [PID = 2] is running. auto_inc_local_var = 20

    switch to [PID = 1 PRIORITY = 7 COUNTER = 7]
    [PID = 1] is running. auto_inc_local_var = 8
    [PID = 1] is running. auto_inc_local_var = 9
    [PID = 1] is running. auto_inc_local_var = 10
    [PID = 1] is running. auto_inc_local_var = 11
    [PID = 1] is running. auto_inc_local_var = 12
    [PID = 1] is running. auto_inc_local_var = 13
    [PID = 1] is running. auto_inc_local_var = 14

    switch to [PID = 3 PRIORITY = 4 COUNTER = 4]
    [PID = 3] is running. auto_inc_local_var = 5
    Test passed!
        Output: 2222222222111111133334222222222211111113
    ```

如果最后输出了 `Test failed!` 则说明你的 `counter` 赋值或者调度算法的实现有问题，`Got` 的实际输出为每个时钟中断间隔内正在运行的线程 `pid` 值。

??? success "`make run` 的输出样例"
    31 个内核线程的输出，可以自行检查运行逻辑是否正确。
    ```text
    ...mm_init done!
    ...task_init done!
    2024 ZJU Operating System

    SET [PID = 1 PRIORITY = 7 COUNTER = 7]
    SET [PID = 2 PRIORITY = 10 COUNTER = 10]
    SET [PID = 3 PRIORITY = 4 COUNTER = 4]
    SET [PID = 4 PRIORITY = 1 COUNTER = 1]
    SET [PID = 5 PRIORITY = 4 COUNTER = 4]
    SET [PID = 6 PRIORITY = 7 COUNTER = 7]
    SET [PID = 7 PRIORITY = 5 COUNTER = 5]
    SET [PID = 8 PRIORITY = 10 COUNTER = 10]
    SET [PID = 9 PRIORITY = 1 COUNTER = 1]
    SET [PID = 10 PRIORITY = 9 COUNTER = 9]
    SET [PID = 11 PRIORITY = 6 COUNTER = 6]
    SET [PID = 12 PRIORITY = 9 COUNTER = 9]
    SET [PID = 13 PRIORITY = 6 COUNTER = 6]
    SET [PID = 14 PRIORITY = 6 COUNTER = 6]
    SET [PID = 15 PRIORITY = 5 COUNTER = 5]
    SET [PID = 16 PRIORITY = 8 COUNTER = 8]
    SET [PID = 17 PRIORITY = 1 COUNTER = 1]
    SET [PID = 18 PRIORITY = 5 COUNTER = 5]
    SET [PID = 19 PRIORITY = 3 COUNTER = 3]
    SET [PID = 20 PRIORITY = 7 COUNTER = 7]
    SET [PID = 21 PRIORITY = 7 COUNTER = 7]
    SET [PID = 22 PRIORITY = 3 COUNTER = 3]
    SET [PID = 23 PRIORITY = 3 COUNTER = 3]
    SET [PID = 24 PRIORITY = 3 COUNTER = 3]
    SET [PID = 25 PRIORITY = 4 COUNTER = 4]
    SET [PID = 26 PRIORITY = 3 COUNTER = 3]
    SET [PID = 27 PRIORITY = 9 COUNTER = 9]
    SET [PID = 28 PRIORITY = 1 COUNTER = 1]
    SET [PID = 29 PRIORITY = 9 COUNTER = 9]
    SET [PID = 30 PRIORITY = 10 COUNTER = 10]
    SET [PID = 31 PRIORITY = 3 COUNTER = 3]

    switch to [PID = 2 PRIORITY = 10 COUNTER = 10]
    [PID = 2] is running. auto_inc_local_var = 1
    [PID = 2] is running. auto_inc_local_var = 2
    [PID = 2] is running. auto_inc_local_var = 3
    [PID = 2] is running. auto_inc_local_var = 4
    [PID = 2] is running. auto_inc_local_var = 5
    [PID = 2] is running. auto_inc_local_var = 6
    [PID = 2] is running. auto_inc_local_var = 7
    [PID = 2] is running. auto_inc_local_var = 8
    [PID = 2] is running. auto_inc_local_var = 9
    [PID = 2] is running. auto_inc_local_var = 10

    switch to [PID = 8 PRIORITY = 10 COUNTER = 10]
    [PID = 8] is running. auto_inc_local_var = 1
    [PID = 8] is running. auto_inc_local_var = 2
    [PID = 8] is running. auto_inc_local_var = 3
    [PID = 8] is running. auto_inc_local_var = 4
    [PID = 8] is running. auto_inc_local_var = 5
    [PID = 8] is running. auto_inc_local_var = 6
    [PID = 8] is running. auto_inc_local_var = 7
    [PID = 8] is running. auto_inc_local_var = 8
    [PID = 8] is running. auto_inc_local_var = 9
    [PID = 8] is running. auto_inc_local_var = 10

    switch to [PID = 30 PRIORITY = 10 COUNTER = 10]
    [PID = 30] is running. auto_inc_local_var = 1
    [PID = 30] is running. auto_inc_local_var = 2
    [PID = 30] is running. auto_inc_local_var = 3
    [PID = 30] is running. auto_inc_local_var = 4
    [PID = 30] is running. auto_inc_local_var = 5
    [PID = 30] is running. auto_inc_local_var = 6
    [PID = 30] is running. auto_inc_local_var = 7
    [PID = 30] is running. auto_inc_local_var = 8
    [PID = 30] is running. auto_inc_local_var = 9
    [PID = 30] is running. auto_inc_local_var = 10

    switch to [PID = 10 PRIORITY = 9 COUNTER = 9]
    [PID = 10] is running. auto_inc_local_var = 1
    [PID = 10] is running. auto_inc_local_var = 2
    [PID = 10] is running. auto_inc_local_var = 3
    [PID = 10] is running. auto_inc_local_var = 4
    [PID = 10] is running. auto_inc_local_var = 5
    ```

### 更丰富的输出

从本次实验开始，实验代码会越来越复杂起来，kernel 的输出或者调试信息也会越来越多。为了方便大家清晰地观察程序输出更方便地进行调试，这里给大家提供一些输出的技巧。在 `printk.h` 中可以加入如下的宏定义：

```c title="include/printk.h"
#define RED "\033[31m"
#define GREEN "\033[32m"
#define YELLOW "\033[33m"
#define BLUE "\033[34m"
#define PURPLE "\033[35m"
#define DEEPGREEN "\033[36m"
#define CLEAR "\033[0m"

#define Log(format, ...) \
    printk("\33[1;35m[%s,%d,%s] " format "\33[0m\n", \
        __FILE__, __LINE__, __func__, ## __VA_ARGS__)
```

这样比如使用 `#!c printk(RED "test: %d\n" CLEAR, 1);` 就可以输出红色的 `test: 1`。这个用法是 ANSI 转义序列，更多用法可以看 [wikipedia 中对 ANSI 转义序列的介绍](https://zh.wikipedia.org/wiki/ANSI%E8%BD%AC%E4%B9%89%E5%BA%8F%E5%88%97)。

另外使用 `Log` 宏来代替 `printk` 可以实现带颜色的输出，并且在输出前附带该 `Log` 所在的文件名、行号、函数名，更方便调试，并且使用方法和 `printk` 完全一致。

我们在评判实验的时候不会关注输出的格式，所以各位同学可以放心大胆地在代码里使用带颜色的输出或者 `Log` 来方便自己调试与观察。

## 思考题

1. 在 RV64 中一共有 32 个通用寄存器，为什么 `__switch_to` 中只保存了 14 个？
2. 阅读并理解 `arch/riscv/kernel/mm.c` 代码，尝试说明 `mm_init` 函数都做了什么，以及在 `kalloc` 和 `kfree` 的时候内存是如何被管理的。
3. 当线程第一次调用时，其 `ra` 所代表的返回点是 `__dummy`，那么在之后的线程调用中 `__switch_to` 中，`ra` 保存/恢复的函数返回点是什么呢？请同学用 gdb 尝试追踪一次完整的线程切换流程，并关注每一次 `ra` 的变换（需要截图）。
4. 请尝试分析并画图说明 kernel 运行到输出第两次 `switch to [PID ...` 的时候内存中存在的全部函数帧栈布局。
    - 可通过 gdb 调试使用 `backtrace` 等指令辅助分析，注意分析第一次时钟中断触发后的 `pc` 和 `sp` 的变化。

## 实验任务与要求

- 请各位同学独立完成作业，任何抄袭行为都将使本次作业判为 0 分。
- 在学在浙大中提交：
    - 整个工程代码的压缩包（提交之前请使用 `make clean` 清除所有构建产物）
    - pdf 格式的实验报告：
        - 记录实验过程并截图（4.1-4.3），并对每一步的命令以及结果进行必要的解释；
        - 记录遇到的问题和心得体会；
        - 完成思考题。

!!! tip "关于实验报告内容要求，可见：[常见问题及解答 - 实验提交要求](faq.md#_2)"
