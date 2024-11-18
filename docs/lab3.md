# Lab 3: RV64 虚拟内存管理

## 实验目的

* 学习虚拟内存的相关知识，实现物理地址到虚拟地址的切换
* 了解 RISC-V 架构中 SV39 分页模式，实现虚拟地址到物理地址的映射，并对不同的段进行相应的权限设置

## 实验环境

* Environment in previous labs

## 背景知识

### 前言

在 Lab2 中我们赋予了操作系统对多个线程调度以及并发执行的能力，由于目前这些线程都是内核线程，因此他们可以共享运行空间，即运行不同线程对空间的修改是相互可见的。但是如果我们需要线程相互**隔离**，以及在多线程的情况下更加**高效**的使用内存，就必须引入**虚拟内存**这个概念。

虚拟内存可以为正在运行的进程提供独立的内存空间，制造一种每个进程的内存都是独立的假象。同时虚拟内存到物理内存的映射也包含了对内存的访问权限，方便内核完成权限检查。

在本次实验中，我们需要关注内核如何**开启虚拟地址**以及通过设置页表来实现**地址映射**和**权限控制**。

### Kernel 的虚拟内存布局

```
start_address             end_address
    0x0                  0x3fffffffff
     │                        │
┌────┘                  ┌─────┘
↓        256G           ↓                                
┌───────────────────────┬──────────┬────────────────┐
│      User Space       │    ...   │  Kernel Space  │
└───────────────────────┴──────────┴────────────────┘
                                   ↑      256G      ↑
                      ┌────────────┘                │ 
                      │                             │
              0xffffffc000000000           0xffffffffffffffff
                start_address                  end_address
```
通过上图我们可以看到 RV64 将 `0x0000004000000000` 以下的虚拟空间作为 `user space`。将 `0xffffffc000000000` 及以上的虚拟空间作为 `kernel space`。由于我们还未引入用户态程序，目前我们只需要关注 `kernel space`。

本次实验使用的虚拟内存布局为 RISC-V Linux Kernel v5.16 前 Sv39 的内存布局，具体的虚拟内存布局可以参考 [Linux v5.15 文档](https://elixir.bootlin.com/linux/v5.15/source/Documentation/riscv/vm-layout.rst)。

!!! note "在 `RISC-V Linux Kernel Space` 中有一段虚拟地址空间中的区域被称为 `direct mapping area`，为了方便访问内存，内核会预先把所有物理内存都映射至这一块区域，这种映射也被称为 `linear mapping`，因为该映射方式就是在物理地址上添加一个偏移，使得 `VA = PA + PA2VA_OFFSET`。在 RISC-V Linux Kernel 中这一段区域为 `0xffffffe000000000 ~ 0xffffffff00000000`，共 124 GB"


### RISC-V Sv39 分页模式

!!! warning "同 lab1，对于本部分知识的学习不可跳过阅读 sepc 这一步骤"
    RISC-V 虚拟内存相关的内容在 [RISC-V Privileged Spec](https://github.com/riscv/riscv-isa-manual/releases/download/20240411/priv-isa-asciidoc.pdf) 中。

    其中第 10.1.11 节介绍了 satp 寄存器，10.2.1 节中包括了本实验中会用到的一条新指令 sfence.vma 的介绍，10.3-10.6 节分别介绍了 Sv32、Sv39、Sv48、Sv57，其中 Sv32 为精讲，后三者均同理带过。所以需要同学们详细阅读第 10.1.11 节和第 10.3、10.4 节。

#### `satp` 寄存器

satp（Supervisor Address Translation and Protection Register）是 RISC-V 中控制虚拟内存分页模式的寄存器，其结构如下：

```text
 63      60 59                  44 43                                0
┌──────────┬──────────────────────┬───────────────────────────────────┐
│   MODE   │         ASID         │                PPN                │
└──────────┴──────────────────────┴───────────────────────────────────┘
```

* MODE 字段的取值如下图：
```text
                        RV 64
┌─────────┬────────┬───────────────────────────────────────┐
│  Value  │  Name  │  Description                          │
├─────────┼────────┼───────────────────────────────────────┤
│    0    │ Bare   │ No translation or protection          │
│  1 - 7  │ ---    │ Reserved for standard use             │
│    8    │ Sv39   │ Page-based 39 bit virtual addressing  │ <-- 我们使用的 mode
│    9    │ Sv48   │ Page-based 48 bit virtual addressing  │
│    10   │ Sv57   │ Page-based 57 bit virtual addressing  │
│    11   │ Sv64   │ Page-based 64 bit virtual addressing  │
│ 12 - 13 │ ---    │ Reserved for standard use             │
│ 14 - 15 │ ---    │ Reserved for standard use             │
└─────────┴────────┴───────────────────────────────────────┘
```

* ASID (Address Space Identifier)：此次实验中直接置 0 即可
* PPN (Physical Page Number)：顶级页表的物理页号。我们的物理页的大小为 4KB， `PA >> 12 == PPN`

!!! tip "具体介绍请阅读 [RISC-V Privileged Spec](https://github.com/riscv/riscv-isa-manual/releases/download/20240411/priv-isa-asciidoc.pdf) 的第 10.1.11 节"

#### Sv39 虚拟地址和物理地址
```text
 38        30 29        21 20        12 11                           0
┌────────────┬────────────┬────────────┬──────────────────────────────┐
│   VPN[2]   │   VPN[1]   │   VPN[0]   │          page offset         │
└────────────┴────────────┴────────────┴──────────────────────────────┘
                        Sv39 virtual address
```

```text
 55                30 29        21 20        12 11                           0
┌────────────────────┬────────────┬────────────┬──────────────────────────────┐
│       PPN[2]       │   PPN[1]   │   PPN[0]   │          page offset         │
└────────────────────┴────────────┴────────────┴──────────────────────────────┘
                            Sv39 physical address
```

- Sv39 模式定义物理地址有 56 位，虚拟地址有 64 位
    - 虚拟地址的 64 位只有低 39 位有效，其 63-39 位为 0 时代表 user space address，为 1 时代表 kernel space address
- Sv39 支持三级页表结构，`VPN[2] VPN[1] VPN[0]` (Virtual Page Number) 分别代表每级页表的**虚拟页号**，`PPN[2] PPN[1] PPN[0]` (Physical Page Number) 分别代表每级页表的**物理页号**，物理地址和虚拟地址的低 12 位表示页内偏移（page offset）

!!! tip "具体介绍请阅读 [RISC-V Privileged Spec](https://github.com/riscv/riscv-isa-manual/releases/download/20240411/priv-isa-asciidoc.pdf) 的第 10.4.1 节"


#### Sv39 页表项

```text
 63      54 53        28 27        19 18        10 9   8 7 6 5 4 3 2 1 0
┌──────────┬────────────┬────────────┬────────────┬─────┬─┬─┬─┬─┬─┬─┬─┬─┐
│ Reserved │   PPN[2]   │   PPN[1]   │   PPN[0]   │ RSW │D│A│G│U│X│W│R│V│
└──────────┴────────────┴────────────┴────────────┴─────┴─┴─┴─┴─┴─┴─┴─┴─┘
                                                     │   │ │ │ │ │ │ │ │
                                                     │   │ │ │ │ │ │ │ └──── V - Valid
                                                     │   │ │ │ │ │ │ └────── R - Readable
                                                     │   │ │ │ │ │ └──────── W - Writable
                                                     │   │ │ │ │ └────────── X - Executable
                                                     │   │ │ │ └──────────── U - User
                                                     │   │ │ └────────────── G - Global
                                                     │   │ └──────────────── A - Accessed
                                                     │   └────────────────── D - Dirty (0 in page directory)
                                                     └────────────────────── Reserved for supervisor software
```

一些常用的位的含义如下：

* V：有效位，当 V = 0，访问该 PTE 会产生 Page Fault
* R：R = 1 该页可读
* W：W = 1 该页可写
* X：X = 1 该页可执行
* U，G，A，D，RSW 本次实验中设置为 0 即可

此外，需要注意，当 RWX 三位均为 0 时，该页表项不为叶子节点，而是指向下一级页表的页表项。具体可见 [RISC-V Privileged Spec](https://github.com/riscv/riscv-isa-manual/releases/download/20240411/priv-isa-asciidoc.pdf) 的第 10.3.1 节

!!! tip "具体介绍请阅读 [RISC-V Privileged Spec](https://github.com/riscv/riscv-isa-manual/releases/download/20240411/priv-isa-asciidoc.pdf) 的第 10.4.1 节"

!!! warning "如果你在使用 spike 工具链，由于 spike 对于页表项的检查更为严格，所以需要你仔细阅读 spec 的第 10.3.1 节完成对 A 和 D 两位的设置才能正常运行"

#### Sv39 虚拟地址转换

虚拟地址转化为物理地址流程图如下，具体描述见 [RISC-V Privileged Spec](https://github.com/riscv/riscv-isa-manual/releases/download/20240411/priv-isa-asciidoc.pdf) 的第 10.3.2 节对于 Sv32 模式的描述并类推至 Sv39：

```text
                                Virtual Address                                     Physical Address

                          9             9            9              12          55        12 11       0
   ┌────────────────┬────────────┬────────────┬─────────────┬────────────────┐ ┌────────────┬──────────┐
   │                │   VPN[2]   │   VPN[1]   │   VPN[0]    │     OFFSET     │ │     PPN    │  OFFSET  │
   └────────────────┴────┬───────┴─────┬──────┴──────┬──────┴───────┬────────┘ └────────────┴──────────┘
                         │             │             │              │                 ▲          ▲
                         │             │             │              │                 │          │
                         │             │             │              │                 │          │
┌────────────────────────┘             │             │              │                 │          │
│                                      │             │              │                 │          │
│                                      │             │              └─────────────────│──────────┘
│    ┌─────────────────┐               │             │                                │
│511 │                 │  ┌────────────┘             │                                │
│    │                 │  │                          │                                │
│    │                 │  │     ┌─────────────────┐  │                                │
│    │                 │  │ 511 │                 │  │                                │
│    │                 │  │     │                 │  │                                │
│    │                 │  │     │                 │  │     ┌─────────────────┐        │
│    │   44       10   │  │     │                 │  │ 511 │                 │        │
│    ├────────┬────────┤  │     │                 │  │     │                 │        │
└───►│   PPN  │  flags │  │     │                 │  │     │                 │        │
     ├────┬───┴────────┤  │     │   44       10   │  │     │                 │        │
     │    │            │  │     ├────────┬────────┤  │     │                 │        │
     │    │            │  └────►│   PPN  │  flags │  │     │                 │        │
     │    │            │        ├────┬───┴────────┤  │     │   44       10   │        │
     │    │            │        │    │            │  │     ├────────┬────────┤        │
   1 │    │            │        │    │            │  └────►│   PPN  │  flags │        │
     │    │            │        │    │            │        ├────┬───┴────────┤        │
   0 │    │            │        │    │            │        │    │            │        │
     └────┼────────────┘      1 │    │            │        │    │            │        │
     ▲    │                     │    │            │        │    └────────────┼────────┘
     │    │                   0 │    │            │        │                 │
     │    └────────────────────►└────┼────────────┘      1 │                 │
     │                               │                     │                 │
 ┌───┴────┐                          │                   0 │                 │
 │  satp  │                          └────────────────────►└─────────────────┘
 └────────┘
```

## 实验步骤
### 准备工程
此次实验基于 lab3 同学所实现的代码进行。

* 需要修改 `defs.h`，在 `defs.h` **添加**如下内容：
    ```c
    #define OPENSBI_SIZE (0x200000)
    
    #define VM_START (0xffffffe000000000)
    #define VM_END (0xffffffff00000000)
    #define VM_SIZE (VM_END - VM_START)
    
    #define PA2VA_OFFSET (VM_START - PHY_START)
    ```
* 从本仓库同步 `vmlinux.lds` 代码，并按照以下步骤将这些文件正确放置。
    ```
    .
    └── arch
        └── riscv
            └── kernel
                └── vmlinux.lds
    ```
    - 新的链接脚本中的 `ramv` 代表 `VMA` (Virtual Memory Address) 即虚拟地址，`ram` 则代表 `LMA` (Load Memory Address)，即我们 OS image 被 load 的地址，可以理解为物理地址
    - 使用以上的 vmlinux.lds 进行编译之后，得到的 `System.map` 以及 `vmlinux` 中的符号采用的都是虚拟地址，方便之后 debug

### 关于 PIE

在开始实验开启虚拟地址之前，我们还需要对 Makefile 进行一些修改来防止后面运行/调试出现问题。如果大家观察过之前的 lab 编译后再经过 objdump 反汇编的结果，你可能会发现 head.S 的第一句设置栈的汇编代码被翻译成了“奇怪”的东西：

```asm
    la sp, boot_stack_top
    80200000:	00003117          	auipc	sp,0x3
    80200004:	02013103          	ld	sp,32(sp) # 80203020 <_GLOBAL_OFFSET_TABLE_+0x18>
```

你可能好奇过这里为什么要吧 `boot_stack_top` 的地址 ld 出来，而且是从哪里 ld 出来的。答案 objdump 的注释已经给出了，是从一个叫 `_GLOBAL_OFFSET_TABLE_` 的地方取出来的，这也就是你可能听说过的 GOT 表（全局偏移表），有了它就可以实现 PIE（位置无关执行）了，在每次取地址的时候，只要通过 GOT 表来取，就可以使得即使代码被放在不同地址执行，也可以取到正确的地址。

当然，在我们实现 kernel 的时候，所有的地址都是不变的，代码也始终会被 load 到 0x80200000 的地方，因此这个 PIE 对我们并没有作用。相反，在本次试验中它还会有副作用，因为 GOT 表里的地址都是最终的虚拟地址，所以在 kernel 启用虚拟地址之前，一切从 GOT 表取出的地址都是错的，这种情况下需要手动给 `la` 得到的地址减去 `PA2VA_OFFSET` 才能得到正确的物理地址。

为了避免这种情况，我们可以直接关掉 PIE，只需要在 Makefile 的 `CF` 中加一个 `-fno-pie` 就可以强制不编译出 PIE 的代码。在这种情况下第一句的汇编代码会被编译成：

```asm
    la sp, boot_stack_top
    80200000:	00005117          	auipc	sp,0x5
    80200004:	00010113          	mv	sp,sp
```

它直接使用 `auipc` 根据目标基于当前 pc 的偏移就能计算出正确的地址，而且这种代码不管是否启用了虚拟地址，都是有效的。因此在实验开始前，请同学们在 Makefile 中加上 `-fno-pie`。

### 开启虚拟内存映射

在 RISC-V 中开启虚拟地址被分为了两步：`setup_vm` 以及 `setup_vm_final`，下面将介绍相关的具体实现。

#### `setup_vm` 的实现

* 将 0x80000000 开始的 1GB 区域进行两次映射，其中一次是等值映射（PA == VA），另一次是将其映射到 `direct mapping area`（使得 `PA + PV2VA_OFFSET == VA`），如下图所示：
  ```text
  Physical Address
  -------------------------------------------
                       | OpenSBI | Kernel |
  -------------------------------------------
                       ↑
                  0x80000000
                       ├───────────────────────────────────────────────────┐
                       |                                                   |
  Virtual Address      ↓                                                   ↓
  -----------------------------------------------------------------------------------------------
                       | OpenSBI | Kernel |                                | OpenSBI | Kernel |
  -----------------------------------------------------------------------------------------------
                       ↑                                                   ↑
                  0x80000000                                       0xffffffe000000000
  ```
* 完成上述映射之后，通过 `relocate` 函数，完成对 `satp` 的设置，以及跳转到对应的虚拟地址
* 至此我们已经完成了虚拟地址的开启，之后我们运行的代码也都将在虚拟地址上运行

```c title="arch/riscv/kernel/vm.c"
/* early_pgtbl: 用于 setup_vm 进行 1GiB 的映射 */
uint64_t early_pgtbl[512] __attribute__((__aligned__(0x1000)));

void setup_vm() {
    /* 
     * 1. 由于是进行 1GiB 的映射，这里不需要使用多级页表 
     * 2. 将 va 的 64bit 作为如下划分： | high bit | 9 bit | 30 bit |
     *     high bit 可以忽略
     *     中间 9 bit 作为 early_pgtbl 的 index
     *     低 30 bit 作为页内偏移，这里注意到 30 = 9 + 9 + 12，即我们只使用根页表，根页表的每个 entry 都对应 1GiB 的区域
     * 3. Page Table Entry 的权限 V | R | W | X 位设置为 1
    **/
}
```

```asm title="arch/riscv/kernel/head.S"
_start:
    ...
    call setup_vm
    call relocate
    ...


relocate:
    # set ra = ra + PA2VA_OFFSET
    # set sp = sp + PA2VA_OFFSET (If you have set the sp before)
   
    ###################### 
    #   YOUR CODE HERE   #
    ######################

    # need a fence to ensure the new translations are in use
    sfence.vma zero, zero

    # set satp with early_pgtbl
    
    ###################### 
    #   YOUR CODE HERE   #
    ######################
		
    ret

    .section .bss.stack
    .globl boot_stack
boot_stack:
    ...
```

经过 `setup_vm` 设置了一级页表之后，整个 kernel 启动后应该可以直接运行在虚拟地址上了，不过在 `task_init` 中 `kalloc` 的时候可能会出现错误，因为 `mm_init` 中我们释放的内存是 `_ekernel ~ PHY_END`，在进入虚拟地址后 `PHY_END` 还是物理地址，会导致实际上没有内存被释放，`kalloc` 没有可用的空间。因此需要修改 `arch/riscv/kernel/mm.c` 的 `mm_init` 函数，将结束地址调整为虚拟地址，才能正常运行。

??? note "对 `sfence.vma` 和 `fence.i` 语义的详细说明"

    在 10 月 30 日的 commit 中，去除了 `fence.i`，并调整了 `sfence.vma` 的顺序，与 Linux 内核源码保持一致，以避免同学们阅读内核源码时产生困惑。同学们可能会好奇其中的具体原理，这里简单说明一下。

    首先看 RISC-V Privileged Spec 中对 `sfence.vma` 的描述：

    > It is specified as **a fence rather than a TLB flush** to provide cleaner semantics with respect to which instructions are affected by the flush operation and to support a wider variety of dynamic caching structures and memory-management schemes.

    接下来看 [Linux 内核源码（v5.2.21）](https://elixir.bootlin.com/linux/v5.2.21/source/arch/riscv/kernel/head.S#L89)：

    ```asm
    /*
	 * Load trampoline page directory, which will cause us to trap to
	 * stvec if VA != PA, or simply fall through if VA == PA.  We need a
	 * full fence here because setup_vm() just wrote these PTEs and we need
	 * to ensure the new translations are in use.
	 */
    sfence.vma
	csrw CSR_SATP, a0
    ```

    与实验指导的初版代码相比，这里有三个问题：为什么要在 `csrw satp` 之前加一个 `sfence.vma`？为什么后面不需要加 `sfence.vma`？为什么不需要 `fence.i`？

    1. 第一个问题由上面代码段的注释解答：`csrw satp` **前**的 `sfence.vma` 主要是**为了保证新的页表项生效**而设置的一个 fence，而没有用到其刷新 TLB 的功能，毕竟这里才刚刚启用 MMU。那么为什么要保证页表项生效呢？这涉及思考题 2 的答案，在此按下不表。
    2. 第二个问题由 RISC-V Privileged Spec 10.3 节中的一段话解答：
    
        > Changing `satp.MODE` **from `Bare` to other modes and vice versa also takes effect immediately**, without the need to execute an `sfence.vma` instruction.

        也就是说，启用或关闭分页模式时的操作立即生效，不需要额外的 `sfence.vma`。

    3. 第三个问题由 [Linux 内核源码 `local_flush_tlb_all`](https://elixir.bootlin.com/linux/v5.2.21/source/arch/riscv/include/asm/tlbflush.h#L14) 中的注释解答：

        ```c
        /*
        * Flush entire local TLB.  'sfence.vma' implicitly fences with the instruction
        * cache as well, so a 'fence.i' is not necessary.
        */
        static inline void local_flush_tlb_all(void)
        {
            __asm__ __volatile__ ("sfence.vma" : : : "memory");
        }
        ```

        也就是说，`sfence.vma` 会**隐式地刷新指令缓存**，因此不需要额外的 `fence.i`。

        你可能会好奇什么时候才会使用 `fence.i`。在 Linux 源码中搜索，可以发现主要用在进程调度。因为需要让新进程的指令替换掉旧进程的缓存，此时会显式使用 `fence.i`。

    [SFENCE.VMA Before or After SATP Write · Issue #226 · riscv/riscv-isa-manual](https://github.com/riscv/riscv-isa-manual/issues/226) 中 RISC-V 开发者对 `sfence.vma` 和 `csrw satp` 顺序做了一些讨论：

    > - **`sfence.vma` before `csrw satp` may be necessary**: The concern is, what if the mapping for the instruction immediately after SFENCE.VMA has been modified? In the Linux kernel, this mapping is fixed (regardless of address space) so the concern does not apply.
    > - **`sfence.vma` after `csrw satp` is definitely necessary**: In general, you need to SFENCE after you've recycled an ASID. Since we don't use ASIDs in the Linux kernel yet, every context switch is effectively an ASID reuse, **hence the full TLB flush**.

    根据上述解释，在 `setup_vm_final` 中第二次切换 satp 时，其后必须要设置 `sfence.vma`，否则可能命中旧页表。但是你会发现，即使去掉 `sfence.vma`，实验依然可以正常运行。更进一步地，我们可以设计下面的代码：

    ```c
    void setup_vm_final() {
        ...
        // create old TLB entry
        asm volatile("li t0, 0x80200000");
        asm volatile("ld t1, 0(t0)");
        // set satp with swapper_pg_dir
        csr_write(satp, ...); // your code
        // try to hit old TLB entry
        asm volatile("li t0, 0x80200000");
        asm volatile("ld t1, 0(t0)");
        ...
    }
    ```

    第二个 `ld` 将失败，说明 TLB 已经被刷新了，并不符合预期。原因是 QEMU、spike 这类模拟器会在写 SATP 时立即刷新 TLB 来避免泄漏无效的缓存映射。不过 RISC-V 的标准中并未强制规定这一点，所以为了兼容性考虑，我们还是需要在写 `satp` 后使用 `sfence.vma` 来保证在任何平台上都可以正确运行。

!!! tip "调试小寄巧"

    - 在设置好 `satp` 寄存器之前，我们只可以使用**物理地址**来打断点
        - 因为符号表、`vmlinux.lds` 里面记录的函数名的地址都是虚拟地址
        - 在设置好 `satp` 之前，这样子打断点，会与真实的地址相差一个 `PA2VA_OFFSET`
        - 你可以在目录下编译生成的 `vmlinux.asm` 中找到所有代码的虚拟地址，然后将其转换成物理地址，再使用 `b *<addr>` 命令设置断点
    - 设置 satp 之后，才可以使用虚拟地址打断点，同时之前设置的物理地址断点也会失效，需要删除

!!! warning "旧版本 QEMU（7.0 以前）对于指令缓存等处理有 bug，会导致刷新了缓存但实际上并没有作用，可能会导致调试过程中出现困惑，或者使得代码以灵车的方式跑了起来，因此请同学们务必保证自己使用的 QEMU 足够新（8.2.2 及以上），否则请参考 lab0/lab1 文档进行更新"

#### `setup_vm_final` 的实现

由于 `setup_vm_final` 中需要申请页面来建立多级页表，我们需要先调用 `mm_init` 来完成内存管理初始化，同时如上一节所讲，需要注意将 `mm_init` 中 `kfreerange` 的结束地址调整为虚拟地址。

接下来 `setup_vm_final` 需要完成对所有物理内存 (128M) 的映射，并设置正确的权限，具体的映射关系如下：

```text
Physical Address
     PHY_START                           PHY_END
         ↓                                  ↓
--------------------------------------------------------
         | OpenSBI | Kernel |               |
--------------------------------------------------------
         ↑                                  ↑
    0x80000000                              └────────────────────────┐
         └────────────────────────┐                                  |
                                  |                                  |
                               VM_START                              |
Virtual Address                   ↓                                  ↓
-------------------------------------------------------------------------
                                  |         | Kernel |               |
-------------------------------------------------------------------------
                                  ↑
                          0xffffffe000000000
```

* 不再需要进行等值映射
* 不再需要为 OpenSBI 创建映射，因为 OpenSBI 运行在 M 态，直接使用物理地址
* 采用三级页表映射
* 在 head.S 中 适当的位置调用 `setup_vm_final`
* <font color="#ff0000">请不要修改 create_mapping 的函数声明，并注意阅读下方对参数的描述。该函数会被用于测试实验的正确性。</font>

```c title="arch/riscv/kernel/vm.c"
/* swapper_pg_dir: kernel pagetable 根目录，在 setup_vm_final 进行映射 */
uint64_t swapper_pg_dir[512] __attribute__((__aligned__(0x1000)));

void setup_vm_final() {
    memset(swapper_pg_dir, 0x0, PGSIZE);

    // No OpenSBI mapping required

    // mapping kernel text X|-|R|V
    create_mapping(...);

    // mapping kernel rodata -|-|R|V
    create_mapping(...);
    
    // mapping other memory -|W|R|V
    create_mapping(...);
    
    // set satp with swapper_pg_dir

    // YOUR CODE HERE

    // flush TLB
    asm volatile("sfence.vma zero, zero");
    return;
}


/* 创建多级页表映射关系 */
/* 不要修改该接口的参数和返回值 */
void create_mapping(uint64_t *pgtbl, uint64_t va, uint64_t pa, uint64_t sz, uint64_t perm) {
    /*
     * pgtbl 为根页表的基地址
     * va, pa 为需要映射的虚拟地址、物理地址
     * sz 为映射的大小，单位为字节
     * perm 为映射的权限（即页表项的低 8 位）
     * 
     * 创建多级页表的时候可以使用 kalloc() 来获取一页作为页表目录
     * 可以使用 V bit 来判断页表项是否存在
    **/
}
```
### 编译及测试

由于加入了一些新的 .c 文件，可能需要修改一些Makefile文件，请同学自己尝试修改，使项目可以编译并运行

??? success "输出示例"
    ```bash
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
    ...
    
    ```

## 思考题

1. 验证 `.text`，`.rodata` 段的属性是否成功设置，给出截图。
2. 为什么我们在 `setup_vm` 中需要做等值映射？在 Linux 中，是不需要做等值映射的，请探索一下不在 `setup_vm` 中做等值映射的方法。你需要回答以下问题：
    - 本次实验中如果不做等值映射，会出现什么问题，原因是什么；
    - 简要分析 [Linux v5.2.21](https://elixir.bootlin.com/linux/v5.2.21/source) 或之后的版本中的内核启动部分（直至 `init/main.c` 中 `start_kernel` 开始之前），特别是设置 satp 切换页表附近的逻辑；
    - 回答 Linux 为什么可以不进行等值映射，它是如何在无等值映射的情况下让 pc 从物理地址跳到虚拟地址；
    - Linux v5.2.21 中的 `trampoline_pg_dir` 和 `swapper_pg_dir` 有什么区别，它们分别是在哪里通过 satp 设为所使用的页表的；
    - 尝试修改你的 kernel，使得其可以像 Linux 一样不需要等值映射。

    !!! tip "Hint"
        你需要特别关注 pc 的变化以及某些指令对于 pc 的影响等。

        虽然 Linux 是一个非常庞大的项目，但是同学们也不需要有畏难情绪，启动部分的结构和我们自己实现的结构其实非常类似（arch/riscv/kernel/head.S 之类的），如果遇到完全没听说过的指令或者代码（比如 setup_vm 中的 pmd 相关的东西等）可以暂时跳过，不认识的地方对于我们要分析的主要逻辑也基本没有什么大影响。

## 实验任务与要求

- 请各位同学独立完成作业，任何抄袭行为都将使本次作业判为 0 分。
- 在学在浙大中提交：
    - 整个工程代码的压缩包（提交之前请使用 `make clean` 清除所有构建产物）
    - pdf 格式的实验报告：
        - 记录实验过程并截图（4.1-4.3），并对每一步的命令以及结果进行必要的解释；
        - 记录遇到的问题和心得体会；
        - 完成思考题。

!!! tip "关于实验报告内容要求，可见：[常见问题及解答 - 实验提交要求](faq.md#_2)"
