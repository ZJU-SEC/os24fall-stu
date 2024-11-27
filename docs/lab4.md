# Lab 4: RV64 用户态程序

## 实验目的

* 创建**用户态进程**，并完成内核态与用户态的转换
* 正确设置用户进程的**用户态栈**和**内核态栈**，并在异常处理时正确切换
* 补充异常处理逻辑，完成指定的**系统调用**（SYS_WRITE, SYS_GETPID）功能
* 实现用户态 ELF 程序的解析和加载

## 实验环境

* Environment in previous labs

## 背景知识

### 用户模式和内核模式

处理器存在两种不同的模式：**用户模式**（U-Mode）和**内核模式**（S-Mode）。

- 在用户模式下，执行代码无法直接访问硬件，必须委托给系统提供的接口才能访问硬件或内存；
- 在内核模式下，执行代码对底层硬件具有完整且不受限制的访问权限，它可以执行任何 CPU 指令并引用任何内存地址。

处理器根据处理器上运行的代码类型在这两种模式之间切换。应用程序以用户模式运行，而核心操作系统组件以内核模式运行。

### 目标
在 [Lab3](./lab3.md) 中，我们启用了**虚拟内存**，这为进程间地址空间相互隔离打下了基础。然而，我们当时只创建了内核线程，它们共用了地址空间（共用一个内核页表 `swapper_pg_dir`）。在本次实验中，我们将引入**用户态进程**：

- 当启动用户态应用程序时，内核将为该应用程序创建一个进程，并提供了专用虚拟地址空间等资源
    - 每个应用程序的虚拟地址空间是私有的，一个应用程序无法更改属于另一个应用程序的数据
    - 每个应用程序都是独立运行的，如果一个应用程序崩溃，其他应用程序和操作系统将不会受到影响
- 用户态应用程序可访问的虚拟地址空间是受限的
    - 在用户态下，应用程序无法访问内核的虚拟地址，防止其修改关键操作系统数据
    - 当用户态程序需要访问关键资源的时候，可以通过**系统调用**来完成用户态程序与操作系统之间的互动

### 系统调用约定

**系统调用**是用户态应用程序请求内核服务的一种方式。在 RISC-V 中，我们使用 `ecall` 指令进行系统调用，当执行这条指令时，处理器会提升特权模式，跳转到异常处理函数，处理这条系统调用。

Linux 中 RISC-V 相关的系统调用可以在 [`include/uapi/asm-generic/unistd.h`](https://elixir.bootlin.com/linux/v6.11/source/include/uapi/asm-generic/unistd.h) 中找到，[syscall(2)](https://man7.org/linux/man-pages/man2/syscall.2.html) 手册页上对 RISC-V 架构上的调用说明进行了总结，系统调用参数使用 a0 - a5，系统调用号使用 a7，系统调用的返回值会被保存到 a0, a1 中。

### `sstatus[SUM]` 与 `PTE[U]`

- 当页表项 `PTE[U]` 置 0 时，该页表项对应的内存页为内核页，U-Mode 下的代码*无法*访问
- 当页表项 `PTE[U]` 置 1 时，该页表项对应的内存页为用户页，S-Mode 下的代码*无法*访问

如果想让 S 特权级下的程序能够访问用户页，需要对 `sstatus[SUM]` 位置 1。

!!! tip "但是无论什么样的情况下，用户页中的指令对于 S-Mode 而言都是无法执行的"

### 用户态栈与内核态栈

当用户态程序进行系统调用陷入内核处理时，内核态程序也需要使用栈空间，而这肯定不能和用户态使用同一个栈，所以我们需要为用户态程序和内核态程序分别分配栈空间，并在异常处理的过程中对栈进行切换。

### ELF 程序

ELF（Executable and Linkable Format）是当今被广泛使用的应用程序格式。例如当我们运行 `gcc <some-name>.c` 后产生的 `a.out` 输出文件的格式就是 ELF。

```text
$ cat hello.c
#include <stdio.h>

int main() {
    printf("hello, world\n");
    return 0;
}
$ gcc hello.c
$ file a.out
a.out: ELF 64-bit LSB pie executable, x86-64, version 1 (SYSV), dynamically linked, 
interpreter /lib64/ld-linux-x86-64.so.2, BuildID[sha1]=dd33139196142abd22542134c20d85c571a78b0c, 
for GNU/Linux 3.2.0, not stripped
```

将程序封装成 ELF 格式的意义包括以下几点：

- ELF 文件可以包含将程序正确加载入内存的元数据（metadata）
- ELF 文件在运行时可以由加载器（loader）将动态链接在程序上的动态链接库（shared library）正确地从硬盘或内存中加载
- ELF 文件包含的重定位信息可以让该程序继续和其他可重定位文件和库再次链接，构成新的可执行文件

为了简化实验步骤，我们使用的是静态链接的程序，不会涉及链接动态链接库的内容。

## 实验步骤
### 准备工程
此次实验基于 lab3 同学所实现的代码进行。

* 需要修改 `vmlinux.lds`，将用户态程序 `uapp` 加载至 `.data` 段：
    ```lds title="arch/riscv/kernel/vmlinux.lds" linenums="45"
        .data : ALIGN(0x1000) {
            _sdata = .;
    
            *(.sdata .sdata*)
            *(.data .data.*)
            
            _edata = .;
    
            . = ALIGN(0x1000);
            _sramdisk = .;
            *(.uapp .uapp*)
            _eramdisk = .;
            . = ALIGN(0x1000);
        } >ramv AT>ram
    ```

!!! tip 
    如果你要使用 `_sramdisk` 这个符号，可以在代码里这样来声明它：`#!c extern char _sramdisk[]`，这样就可以像一个字符数组一样来访问这块内存的内容，例如，程序的第一个字节就是 `_sramdisk[0]`。

* 需要修改 `defs.h`，在 `defs.h` **添加**如下内容：
    ```c
    #define USER_START (0x0000000000000000) // user space start virtual address
    #define USER_END (0x0000004000000000) // user space end virtual address
    ```

* 从本仓库同步以下文件和文件夹，并按照下面的位置来放置这些新文件：
    ```
    .
    ├── arch
    │   └── riscv
    │       ├── Makefile    # 添加了链接 uapp 的部分
    │       ├── include
    │       │   └── mm.h    # 修改为了 buddy system
    │       └── kernel
    │           └── mm.c    # 修改为了 buddy system
    ├── include
    │   └── elf.h           # 来自 musl libc
    └── user
        ├── Makefile
        ├── getpid.c        # 用户态程序
        ├── link.lds
        ├── printf.c        # 类似 printk
        ├── start.S         # 用户态程序入口
        ├── stddef.h
        ├── stdio.h
        ├── syscall.h
        └── uapp.S          # 提取二进制内容
    ```

    !!! tip "关于 buddy system"
        值得注意的是，我们在 `mm` 中添加了 buddy system，但是也保证了原来调用的 `kalloc` 和 `kfree` 的兼容。你应该无需修改原先使用了 `kalloc` 的相关代码，如果出现兼容性问题可以联系助教。为了减小大家的工作量，我们替大家实现了 buddy system，大家也可以直接使用这些函数来管理内存：

        ```c
        void *alloc_pages(uint64_t nrpages);    // 分配 nrpages 个页
        void *alloc_page();         // 分配一个页，即 alloc_pages(1)
        void free_pages(void *va);  // 释放 va 开始的内存
        ```

* 修改**根目录**下的 Makefile, 将 `user` 文件夹下的内容纳入工程管理

    !!! note
        在根目录下 `make` 会生成 `user/uapp.o`（这个会被链接到 vmlinux 中）`user/uapp.elf` `user/uapp.bin`，以及我们最终测试使用的 ELF 可执行文件 `user/uapp`。
        
        通过 `objdump` 我们可以看到 uapp 使用 ecall 来调用 SYSCALL（在 U-Mode 下使用 ecall 会触发 `environment-call-from-U-mode` 异常），从而将控制权交给处在 S-Mode 的 OS，由内核来处理相关异常：
        
        ```
        0000000000000004 <getpid>:
           4:   fe010113            add sp,sp,-32
           8:   00813c23            sd  s0,24(sp)
           c:   02010413            add s0,sp,32
          10:   fe843783            ld  a5,-24(s0)
          14:   0ac00893            li  a7,172
          18:   00000073            ecall               <- SYS_GETPID                        
        ...
        
        0000000000000f70 <printf>:
        ...
        1030:   00070513            mv  a0,a4
        1034:   00068593            mv  a1,a3
        1038:   00060613            mv  a2,a2
        103c:   00000073            ecall               <- SYS_WRITE
        ...
        ```

在本次实验中，我们首先会将用户态程序 strip 成纯二进制文件来运行。这种情况下，用户程序运行的第一条指令位于二进制文件的开始位置, 也就是说 `_sramdisk` 处的指令就是我们要执行的第一条指令。我们将运行纯二进制文件作为第一步，在确认用户态的纯二进制文件能够运行后，我们再将存储到内存中的用户程序文件换为 ELF 来进行执行。


### 创建用户态进程
#### 结构体更新

* 本次实验只需要创建 4 个用户态进程，修改 `proc.h` 中的 `NR_TASKS` 即可
* 由于创建用户态进程要对 `sepc`, `sstatus`, `sscratch` 做设置，我们需要将其加入 `thread_struct` 中
* 由于多个用户态进程需要保证相对隔离，因此不可以共用页表，我们需要为每个用户态进程都创建一个页表并记录在 `task_struct` 中，可以参考的修改如下：
    ```c title="arch/riscv/kernel/proc.c"
    struct thread_struct {
        uint64_t ra;
        uint64_t sp;                     
        uint64_t s[12];
        uint64_t sepc, sstatus, sscratch; 
    };
    
    struct task_struct {
        uint64_t state;
        uint64_t counter;
        uint64_t priority;
        uint64_t pid;
    
        struct thread_struct thread;
        uint64_t *pgd;  // 用户态页表
    };
    ```

#### 修改 `task_init()`

* 对于每个进程，初始化我们刚刚在 `thread_struct` 中添加的三个变量，具体而言：
    * 将 `sepc` 设置为 `USER_START`
    * 配置 `sstatus` 中的 `SPP`（使得 sret 返回至 U-Mode）、`SUM`（S-Mode 可以访问 User 页面）
    * 将 `sscratch` 设置为 U-Mode 的 sp，其值为 `USER_END` （将用户态栈放置在 user space 的最后一个页面）
* 对于每个进程，创建属于它自己的页表：
    * 为了避免 U-Mode 和 S-Mode 切换的时候切换页表，我们将内核页表 `swapper_pg_dir` 复制到每个进程的页表中
    * 对于每个进程，分配一块新的内存地址，将 `uapp` 二进制文件内容**拷贝**过去，之后再将其所在的页面映射到对应进程的页表中

    !!! tip
        在程序运行过程中，有部分数据不在栈上，而在初始化的过程中就已经被分配了空间（比如我们的 `uapp` 中的全局变量 `counter`）。所以，二进制文件需要先被拷贝到一块新的、供某个进程专用的内存之后再进行映射，来防止所有的进程共享数据，造成预期外的进程间相互影响。

        那么应该如何进行拷贝呢？很简单，先计算所需的页数（`uapp` 的大小除以 PGSIZE 后**向上取整**），调用 `alloc_pages()` 函数，再将 `uapp` memcpy 过去。

* 设置用户态栈，对每个用户态进程，其拥有两个栈：
    - 用户态栈：我们可以申请一个空的页面来作为用户态栈，并映射到进程的页表中
    - 内核态栈；在 lab3 中已经设置好了，就是 `thread.sp`

```
                PHY_START                                                                PHY_END
                     new allocated memory            allocated space end
                   │         │                                │                                                 │
                   ▼         ▼                                ▼                                                 ▼
       ┌───────────┬─────────┬────────────────────────────────┬─────────────────────────────────────────────────┐
 PA    │           │         │ uapp (copied from _sramdisk)   │                                                 │
       └───────────┴─────────┴────────────────────────────────┴─────────────────────────────────────────────────┘
                             ▲                                ▲
       ┌─────────────────────┘                                │
       │            (map)                                     │
       │                        ┌─────────────────────────────┘
       │                        │
       │                        │
       ├────────────────────────┼───────────────────────────────────────────────────────────────────┬────────────┐
 VA    │           UAPP         │                                                                   │u mode stack│
       └────────────────────────┴───────────────────────────────────────────────────────────────────┴────────────┘
       ▲                                                                                                         ▲
       │                                                                                                         │

   USER_START                                                                                                USER_END

```

### 修改 `__switch_to`

在前面新增了 sepc、sstatus、sscratch 之后，需要将这些变量在切换进程时保存在栈上，因此需要更新 `__switch_to` 中的逻辑，同时需要增加切换页表的逻辑。在切换了页表之后，需要通过 `sfence.vma` 来刷新 TLB 和 ICache。

!!! tip "关于切换页表"
    切换页表的逻辑分为两步，一个是写 `satp`，一个是刷新 TLB，我们用 `task_struct` 上的 `pgd` 保存了下一个用户进程的页表的虚拟地址，需要通过一些变换得到 PPN，加上 MODE 写入 `satp`。

    可以参考 [lab3 中 satp 寄存器](https://zju-sec.github.io/os24fall-stu/lab3/#satp)部分。

### 更新中断处理逻辑

与 ARM 架构不同的是，RISC-V 中只有一个栈指针寄存器 `sp`，因此需要我们来完成用户栈与内核栈的切换。

由于我们的用户态进程运行在 U-Mode 下，使用的运行栈也是用户栈，因此当触发异常时，我们首先要对栈进行切换（从用户栈切换到内核栈）。同理，当我们完成了异常处理，从 S-Mode 返回至 U-Mode 时，也需要进行栈切换（从内核栈切换到用户栈）。

#### 修改 `__dummy`

在我们初始化线程时，`thread_struct.sp` 保存了内核态栈 sp，`thread_struct.sscratch` 保存了用户态栈 sp，因此在 `__dummy` 进入用户态模式的时候，我们需要切换这两个栈，只需要交换对应的寄存器的值即可。

#### 修改 `_traps`

同理，在 `_traps` 的首尾我们都需要做类似的操作，进入 trap 的时候需要切换到内核栈，处理完成后需要再切换回来。

注意如果是内核线程（没有用户栈）触发了异常，则不需要进行切换。（内核线程的 `sp` 永远指向的内核栈，且 `sscratch` 为 0）

#### 修改 `trap_handler`

`uapp` 使用 `ecall` 会产生 Environment Call from U-mode，而且处理系统调用的时候还需要寄存器的值，因此我们需要在 `trap_handler()` 里面进行捕获。修改 `trap_handler()` 如下：

```c
void trap_handler(uint64_t scause, uint64_t sepc, struct pt_regs *regs) {
    ...
}
```

在 `_traps` 中我们将寄存器的内容**连续**的保存在内核栈上，因此我们可以将这一段看做一个叫做 `pt_regs` 的结构体。我们可以从这个结构体中取到相应的寄存器的值（比如 `syscall` 中我们需要从 a0 ~ a7 寄存器中取到参数）。这个结构体中的值也可以按需添加，同时需要在 `_traps` 中存入对应的寄存器值以供使用，示例如下图：

```
    High Addr ───►  ┌─────────────┐
                    │   sstatus   │
                    │             │
                    │     sepc    │
                    │             │
                    │     x31     │
                    │             │
                    │      .      │
                    │      .      │
                    │      .      │
                    │             │
                    │     x1      │
                    │             │
                    │     x0      │
 sp (pt_regs)  ──►  ├─────────────┤
                    │             │
                    │             │
                    │             │
                    │             │
                    │             │
                    │             │
                    │             │
                    │             │
                    │             │
    Low  Addr ───►  └─────────────┘
```

请同学自己补充 `struct pt_regs`的定义，以及在 `trap_handler` 中补充处理 syscall 的逻辑。

### 添加系统调用

本次实验要求的系统调用函数原型以及具体功能如下：

* 64 号系统调用 `#!c sys_write(unsigned int fd, const char* buf, size_t count)` 该调用将用户态传递的字符串打印到屏幕上，此处 `fd` 为标准输出即 `1`，`buf` 为用户需要打印的起始地址，`count` 为字符串长度，返回打印的字符数；
* 172 号系统调用 `sys_getpid()` 该调用从 `current` 中获取当前的 pid 放入 a0 中返回，无参数

同学们需要：

* 增加 `syscall.c`, `syscall.h` 文件，并在其中实现 `getpid()` 以及 `write()` 逻辑
* 系统调用的返回参数放置在 `a0` 中（不可以直接修改寄存器，应该修改 regs 中保存的内容）
* 针对系统调用这一类异常，我们需要手动完成 `sepc + 4`

### 调整时钟中断

接下来我们需要修改 head.S 以及 start_kernel：

* 在之前的 lab 中，在 OS boot 之后，我们需要等待一个时间片，才会进行调度，我们现在更改为 OS boot 完成之后立即调度 uapp 运行
    * 即在 `start_kernel()` 中，`test()` 之前调用 `schedule()`
* 将 `head.S` 中设置 sstatus.SIE 的逻辑注释掉，确保 schedule 过程不受中断影响

!!! note "关于 SIE 与 SPIE"
    这里保持 sstatus.SIE 为 0 可以在 S 态禁用中断来防止被时钟中断打断。曾经我们让大家在用户态进程初始化的时候设置 sstatus.SPIE 使得进入用户态进程后 sstatus.SIE 自动被置为 sstatus.SPIE 的值（即 1），这样在用户态进程中可以接收到时钟中断。但是 [RISC-V Privileged Spec](https://github.com/riscv/riscv-isa-manual/releases/download/20240411/priv-isa-asciidoc.pdf) 第 3.1.6.1 节写道：

    > When a hart is executing in privilege mode *x*, interrupts are globally enabled when *x*IE=1 and globally disabled when *x*IE=0. ... Interrupts for higher-privilege modes, *y*>*x*, are always globally enabled regardless of the setting of the global *y*IE bit for the higher-privilege mode.

    也就是说 CPU 在用户态 *x*=U 运行的时候，不论高特权级（*y*=S）的 SIE 位是否为 1，都会全局开启高特权级的中断。所以在用户态不管 sstatus.SIE 如何设置，都会始终接收到 S 态的时钟中断，因此之前对于 sstatus.SPIE 的设置并无必要。

### 测试纯二进制文件

由于加入了一些新的 .c 文件，可能需要修改一些 Makefile 文件，请同学自己尝试修改，使项目可以编译并运行。

??? success "输出示例"
    ```
    ...buddy_init done!
    ...mm_init done!
    ...task_init done!
    2024 ZJU Operating System
    SET [PID = 1 PRIORITY = 7 COUNTER = 7]
    SET [PID = 2 PRIORITY = 10 COUNTER = 10]
    SET [PID = 3 PRIORITY = 4 COUNTER = 4]
    SET [PID = 4 PRIORITY = 1 COUNTER = 1]

    switch to [PID = 2 COUNTER = 10]
    [U-MODE] pid: 2, sp is 0000003fffffffe0, this is print No.1
    [U-MODE] pid: 2, sp is 0000003fffffffe0, this is print No.2
    
    switch to [PID = 1 COUNTER = 7]
    [U-MODE] pid: 1, sp is 0000003fffffffe0, this is print No.1
    
    switch to [PID = 3 COUNTER = 4]
    [U-MODE] pid: 3, sp is 0000003fffffffe0, this is print No.1
    
    switch to [PID = 4 COUNTER = 1]
    [U-MODE] pid: 4, sp is 0000003fffffffe0, this is print No.1
    SET [PID = 1 PRIORITY = 7 COUNTER = 7]
    SET [PID = 2 PRIORITY = 10 COUNTER = 10]
    SET [PID = 3 PRIORITY = 4 COUNTER = 4]
    SET [PID = 4 PRIORITY = 1 COUNTER = 1]
    
    switch to [PID = 2 COUNTER = 10]
    [U-MODE] pid: 2, sp is 0000003fffffffe0, this is print No.3
    
    switch to [PID = 1 COUNTER = 7]
    [U-MODE] pid: 1, sp is 0000003fffffffe0, this is print No.2
    
    switch to [PID = 3 COUNTER = 4]
    [U-MODE] pid: 3, sp is 0000003fffffffe0, this is print No.2
    ...
    
    ```

### 添加 ELF 解析与加载
#### ELF 格式

ELF 文件中包含了将程序加载到内存所需的信息，可以参考[这个链接](https://blog.csdn.net/u014358031/article/details/143691591)

当我们通过 `readelf` 来查看一个 ELF 可执行文件的时候，我们可以读到被包含在 ELF Header 中的信息：

??? abstract "`readelf -a -W uapp`"
    ```plaintext
    $ readelf -a -W uapp
    ELF Header:
    Magic:   7f 45 4c 46 02 01 01 00 00 00 00 00 00 00 00 00 
    Class:                             ELF64
    Data:                              2's complement, little endian
    Version:                           1 (current)
    OS/ABI:                            UNIX - System V
    ABI Version:                       0
    Type:                              EXEC (Executable file)
    Machine:                           RISC-V
    Version:                           0x1
    Entry point address:               0x100e8
    Start of program headers:          64 (bytes into file)
    Start of section headers:          6040 (bytes into file)
    Flags:                             0x0
    Size of this header:               64 (bytes)
    Size of program headers:           56 (bytes)
    Number of program headers:         3
    Size of section headers:           64 (bytes)
    Number of section headers:         9
    Section header string table index: 8

    Section Headers:
    [Nr] Name              Type            Address          Off    Size   ES Flg Lk Inf Al
    [ 0]                   NULL            0000000000000000 000000 000000 00      0   0  0
    [ 1] .text             PROGBITS        00000000000100e8 0000e8 00106c 00  AX  0   0  4
    [ 2] .rodata           PROGBITS        0000000000011158 001158 000081 00   A  0   0  8
    [ 3] .bss              NOBITS          00000000000121e0 0011d9 0003f0 00  WA  0   0  8
    [ 4] .comment          PROGBITS        0000000000000000 0011d9 00001f 01  MS  0   0  1
    [ 5] .riscv.attributes RISCV_ATTRIBUTES 0000000000000000 0011f8 00004e 00      0   0  1
    [ 6] .symtab           SYMTAB          0000000000000000 001248 0003d8 18      7  24  8
    [ 7] .strtab           STRTAB          0000000000000000 001620 000129 00      0   0  1
    [ 8] .shstrtab         STRTAB          0000000000000000 001749 000049 00      0   0  1
    Key to Flags:
    W (write), A (alloc), X (execute), M (merge), S (strings), I (info),
    L (link order), O (extra OS processing required), G (group), T (TLS),
    C (compressed), x (unknown), o (OS specific), E (exclude),
    D (mbind), p (processor specific)
    
    There are no section groups in this file.
    
    Program Headers:
    Type           Offset   VirtAddr           PhysAddr           FileSiz  MemSiz   Flg Align
    RISCV_ATTRIBUT 0x0011f8 0x0000000000000000 0x0000000000000000 0x00004e 0x000000 R   0x1
    LOAD           0x0000e8 0x00000000000100e8 0x00000000000100e8 0x0010f1 0x0024e8 RWE 0x8
    GNU_STACK      0x000000 0x0000000000000000 0x0000000000000000 0x000000 0x000000 RW  0x10
    
    Section to Segment mapping:
    Segment Sections...
    00     .riscv.attributes 
    01     .text .rodata .bss 
    02     
    
    There is no dynamic section in this file.
    
    There are no relocations in this file.
    
    The decoding of unwind sections for machine type RISC-V is not currently supported.
    
    Symbol table '.symtab' contains 41 entries:
    Num:    Value          Size Type    Bind   Vis      Ndx Name
        0: 0000000000000000     0 NOTYPE  LOCAL  DEFAULT  UND 
        1: 00000000000100e8     0 SECTION LOCAL  DEFAULT    1 .text
        2: 0000000000011158     0 SECTION LOCAL  DEFAULT    2 .rodata
        3: 00000000000121e0     0 SECTION LOCAL  DEFAULT    3 .bss
        4: 0000000000000000     0 SECTION LOCAL  DEFAULT    4 .comment
        5: 0000000000000000     0 SECTION LOCAL  DEFAULT    5 .riscv.attributes
        6: 0000000000000000     0 FILE    LOCAL  DEFAULT  ABS start.o
        7: 00000000000100e8     0 NOTYPE  LOCAL  DEFAULT    1 $xrv64i2p1_m2p0_a2p1_f2p2_d2p2_zicsr2p0_zifencei2p0_zmmul1p0
        8: 0000000000000000     0 FILE    LOCAL  DEFAULT  ABS getpid.c
        9: 00000000000100ec    52 FUNC    LOCAL  DEFAULT    1 getpid
        10: 00000000000100ec     0 NOTYPE  LOCAL  DEFAULT    1 $xrv64i2p1_m2p0_a2p1_f2p2_d2p2_zicsr2p0_zifencei2p0_zmmul1p0
        11: 0000000000010120     0 NOTYPE  LOCAL  DEFAULT    1 $xrv64i2p1_m2p0_a2p1_f2p2_d2p2_zicsr2p0_zifencei2p0_zmmul1p0
        12: 0000000000000000     0 FILE    LOCAL  DEFAULT  ABS printf.c
        13: 00000000000101a4     0 NOTYPE  LOCAL  DEFAULT    1 $xrv64i2p1_m2p0_a2p1_f2p2_d2p2_zicsr2p0_zifencei2p0_zmmul1p0
        14: 000000000001020c     0 NOTYPE  LOCAL  DEFAULT    1 $xrv64i2p1_m2p0_a2p1_f2p2_d2p2_zicsr2p0_zifencei2p0_zmmul1p0
        15: 000000000001026c     0 NOTYPE  LOCAL  DEFAULT    1 $xrv64i2p1_m2p0_a2p1_f2p2_d2p2_zicsr2p0_zifencei2p0_zmmul1p0
        16: 00000000000104d8   136 FUNC    LOCAL  DEFAULT    1 puts_wo_nl
        17: 00000000000104d8     0 NOTYPE  LOCAL  DEFAULT    1 $xrv64i2p1_m2p0_a2p1_f2p2_d2p2_zicsr2p0_zifencei2p0_zmmul1p0
        18: 0000000000010560   776 FUNC    LOCAL  DEFAULT    1 print_dec_int
        19: 0000000000010560     0 NOTYPE  LOCAL  DEFAULT    1 $xrv64i2p1_m2p0_a2p1_f2p2_d2p2_zicsr2p0_zifencei2p0_zmmul1p0
        20: 0000000000010868     0 NOTYPE  LOCAL  DEFAULT    1 $xrv64i2p1_m2p0_a2p1_f2p2_d2p2_zicsr2p0_zifencei2p0_zmmul1p0
        21: 00000000000111b0    17 OBJECT  LOCAL  DEFAULT    2 upperxdigits.1
        22: 00000000000111c8    17 OBJECT  LOCAL  DEFAULT    2 lowerxdigits.0
        23: 0000000000011058     0 NOTYPE  LOCAL  DEFAULT    1 $xrv64i2p1_m2p0_a2p1_f2p2_d2p2_zicsr2p0_zifencei2p0_zmmul1p0
        24: 0000000000011058   252 FUNC    GLOBAL DEFAULT    1 printf
        25: 00000000000129d9     0 NOTYPE  GLOBAL DEFAULT  ABS __global_pointer$
        26: 0000000000010868  2032 FUNC    GLOBAL DEFAULT    1 vprintfmt
        27: 00000000000121d9     0 NOTYPE  GLOBAL DEFAULT    2 __SDATA_BEGIN__
        28: 000000000001020c    96 FUNC    GLOBAL DEFAULT    1 isspace
        29: 000000000001026c   620 FUNC    GLOBAL DEFAULT    1 strtol
        30: 00000000000121e4     4 OBJECT  GLOBAL DEFAULT    3 tail
        31: 00000000000100e8     0 NOTYPE  GLOBAL DEFAULT    1 _start
        32: 00000000000121e8  1000 OBJECT  GLOBAL DEFAULT    3 buffer
        33: 00000000000125d0     0 NOTYPE  GLOBAL DEFAULT    3 __BSS_END__
        34: 00000000000121e0     4 OBJECT  GLOBAL DEFAULT    3 counter
        35: 00000000000121d9     0 NOTYPE  GLOBAL DEFAULT    3 __bss_start
        36: 0000000000010120   132 FUNC    GLOBAL DEFAULT    1 main
        37: 00000000000101a4   104 FUNC    GLOBAL DEFAULT    1 putc
        38: 00000000000121d9     0 NOTYPE  GLOBAL DEFAULT    2 __DATA_BEGIN__
        39: 00000000000121d9     0 NOTYPE  GLOBAL DEFAULT    2 _edata
        40: 00000000000125d0     0 NOTYPE  GLOBAL DEFAULT    3 _end
    
    No version information found in this file.
    Attribute Section: riscv
    File Attributes
    Tag_RISCV_stack_align: 16-bytes
    Tag_RISCV_arch: "rv64i2p1_m2p0_a2p1_f2p2_d2p2_zicsr2p0_zifencei2p0_zmmul1p0"
    ```

其中包含了两种将程序分块的粒度，Segment 和 Section，我们以 segment 为粒度将程序加载进内存中。可以看到，给出的样例程序包含了三个 segment，这里我们只关注 Type 为 LOAD 的 segment，LOAD 表示它们需要在开始运行前被加载进内存中，这是我们在初始化进程的时候需要执行的工作。

而 section 代表了更细分的语义，比如 `.text` 一般包含了程序的指令，`.rodata` 是只读的全局变量等，大家可以自行 Google 来学习更多相关内容。

#### ELF 文件解析

首先我们需要将 `uapp.S` 中的 payload 给换成我们的 ELF 文件：

```asm title="user/uapp.S" linenums="1"
.section .uapp

.incbin "uapp"
```
这时候从 `_sramdisk` 开始的数据就变成了名为 `uapp` 的 ELF 文件，也就是说 `_sramdisk` 处 32-bit 的数据不再是我们需要执行第一条指令了，而是 ELF Header 的开始。

这时候就需要你对 `task_init` 中的初始化步骤进行修改。我们给出了 ELF 相关的结构体定义（见 `elf.h`），大家可以直接使用。你可能会使用到的结构体或者域如下：

```c
typedef struct {
  unsigned char	e_ident[EI_NIDENT]; // magic number，判断是否是 Ehdr，固定为 7f 45 4c 46 02 01 01 00 00 00 00 00 00 00 00 00
  Elf64_Half	e_type;
  Elf64_Half	e_machine;
  Elf64_Word	e_version;
  Elf64_Addr	e_entry;        // 程序的第一条指令被存储的用户态虚拟地址
  Elf64_Off	e_phoff;            // ELF 文件包含的 Segment 数组（Phdr）相对于 Ehdr 的偏移量
  Elf64_Off	e_shoff;
  Elf64_Word	e_flags;
  Elf64_Half	e_ehsize;
  Elf64_Half	e_phentsize;
  Elf64_Half	e_phnum;        // ELF 文件包含的 Segment 的数量
  Elf64_Half	e_shentsize;
  Elf64_Half	e_shnum;
  Elf64_Half	e_shstrndx;
} Elf64_Ehdr;

typedef struct {
  Elf64_Word	p_type;     // Segment 的类型
  Elf64_Word	p_flags;    // Segment 的权限（包括了读、写和执行）
  Elf64_Off	p_offset;       // Segment 在文件中相对于 Ehdr 的偏移量
  Elf64_Addr	p_vaddr;    // Segment 起始的用户态虚拟地址
  Elf64_Addr	p_paddr;
  Elf64_Xword	p_filesz;   // Segment 在文件中占的大小
  Elf64_Xword	p_memsz;    // Segment 在内存中占的大小
  Elf64_Xword	p_align;
} Elf64_Phdr;   // 存储了程序各个 Segment 相关的 metadata
                // 你可以将 _sramdisk + e_phoff 强制转化为此类型，就会指向第一个 Phdr
```

我们可以按照这些信息，从 _sramdisk 开始的 ELF 文件中**拷贝**内容到我们开辟的内存中。

其中相对文件偏移 `p_offset` 指出相应 segment 的内容从 ELF 文件的第 `p_offset` 字节开始，在文件中的大小为 `p_filesz`，它需要被分配到以 `p_vaddr` 为首地址的虚拟内存位置，在内存中它占用大小为 `p_memsz`。也就是说，这个 segment 使用的内存就是 `[p_vaddr, p_vaddr + p_memsz)` 这一连续区间，然后将 segment 的内容从ELF文件中读入到这一内存区间，并将 `[p_vaddr + p_filesz, p_vaddr + p_memsz)` 对应的物理区间清零。（本段内容引用自[南京大学 PA](https://nju-projectn.github.io/ics-pa-gitbook/ics2022/3.3.html)）

你也可以参考[这篇 blog](https://www.gabriel.urdhr.fr/2015/01/22/elf-linking/) 中关于**静态**链接程序的载入过程来进行你的载入。

这里有不少例子可以举，为了避免同学们在实验中花太多时间，我们告诉大家可以怎么找到实验中这些相关变量：（注意以下的 `_sramdisk` 类型使用的是 `char*`，如果你在使用其他类型，需要根据你使用的类型去调整针对指针的算数运算）

* `#!c Elf64_Ehdr *ehdr = (Elf64_Ehdr *)_sramdisk`，从地址 _sramdisk 开始，便是我们要找的 Ehdr
* `#!c Elf64_Phdr *phdrs = (Elf64_Phdr *)(_sramdisk + ehdr->phoff)`，是一个 Phdr 数组，其中的每个元素都是一个 `Elf64_Phdr`
* `#!c phdrs + 1` 是指向第二个 Phdr 的指针
* `#!c phdrs->p_type == PT_LOAD`，说明这个 Segment 的类型是 LOAD，需要在初始化时被加载进内存

剩下的域的用法我们希望同学们通过阅读 `man elf` 命令或在网上搜索。大家可以参考以下的代码来将程序 load 进入内存。

```c
void load_program(struct task_struct *task) {
    Elf64_Ehdr *ehdr = (Elf64_Ehdr *)_sramdisk;
    Elf64_Phdr *phdrs = (Elf64_Phdr *)(_sramdisk + ehdr->e_phoff);
    for (int i = 0; i < ehdr->e_phnum; ++i) {
        Elf64_Phdr *phdr = phdrs + i;
        if (phdr->p_type == PT_LOAD) {
            // alloc space and copy content
          	// do mapping
          	// code...
        }
    }
    task->thread.sepc = ehdr->e_entry;
}
```

!!! tip
    需要注意的是，因为虚拟内存和物理内存的映射是按页为单位的，如果 `e_entry` 并没有按页对齐的话，需要在拷贝的时候考虑 offset 的问题。

## 思考题

1. 我们在实验中使用的用户态线程和内核态线程的对应关系是怎样的？（一对一，一对多，多对一还是多对多）
2. 系统调用返回为什么不能直接修改寄存器？
3. 针对系统调用，为什么要手动将 sepc + 4？
4. 为什么 Phdr 中，`p_filesz` 和 `p_memsz` 是不一样大的，它们分别表示什么？
5. 为什么多个进程的栈虚拟地址可以是相同的？用户有没有常规的方法知道自己栈所在的物理地址？

## 实验任务与要求

- 请各位同学独立完成作业，任何抄袭行为都将使本次作业判为 0 分。
- 在学在浙大中提交：
    - 整个工程代码的压缩包（提交之前请使用 `make clean` 清除所有构建产物）
    - pdf 格式的实验报告：
        - 记录实验过程并截图（4.1-4.3），并对每一步的命令以及结果进行必要的解释；
        - 记录遇到的问题和心得体会；
        - 完成思考题。

!!! tip "关于实验报告内容要求，可见：[常见问题及解答 - 实验提交要求](faq.md#_2)"
