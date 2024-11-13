# 常见问题及解答
<!-- - [常见问题及解答](#常见问题及解答)
  - [1 为什么我把 Linux 源码放在共享文件夹或 wsl2 的 `/mnt` 下编译不出来？](#1-为什么我把-linux-源码放在共享文件夹或-wsl2-的-mnt-下编译不出来)
  - [2 为什么 QEMU & GDB 使用 `si` 单指令调试遇到模式切换时无法正常执行？](#2-为什么-qemu--gdb-使用-si-单指令调试遇到模式切换时无法正常执行)
  - [3 为什么我不能在 GDB 中使用 `next` 或者 `finish` ?](#3-为什么我不能在-gdb-中使用-next-或者-finish-)
  - [4 为什么我在内核中添加了 debug 信息，但是还是没法使用 `next` 或者 `finish` ?](#4-为什么我在内核中添加了-debug-信息但是还是没法使用-next-或者-finish-)
  - [5  为什么我在 `start_kernel` 处不能正常使用断点？](#5--为什么我在-start_kernel-处不能正常使用断点)
  - [6 为什么 Lab1 中提示 `riscv64-elf-unknown-gcc: No such file or directory` ?](#6-为什么-lab1-中提示-riscv64-elf-unknown-gcc-no-such-file-or-directory-)
  - [7 为什么 Lab1 中我的 C 语言函数的参数无法正确传入？](#7-为什么-lab1-中我的-c-语言函数的参数无法正确传入)
  - [8 为什么我把 `puti` 的参数类型替换成 `uint64` 还是只能打印出 32bits 的值？](#8-为什么我把-puti-的参数类型替换成-uint64-还是只能打印出-32bits-的值)
  - [9 为什么我的 QEMU 会 “卡住”？](#9-为什么我的-QEMU-会-“卡住”？)
  - [10 为什么我在设置 `satp` 后导致了 `gdb-multiarch` 的 `segmentation fault` ?](#10-为什么我在设置-satp-后导致了-gdb-multiarch-的-segmentation-fault)
  - [11 -->

!!! warning "首先需要明确的是，本次实验中的所有操作都不应该经由 Windows 中的文件系统，请直接在**虚拟机或 Linux 物理机**中直接完成。"

!!! warning "禁止直接 fork 本课程的 github 仓库"
    本课程要求同学们严格遵循诚信守则，禁止同学之间互相抄袭实验代码。如需建立私人 github 仓库，请将本课程仓库 clone 到本地之后，上传到自己的 private repo。禁止直接 fork 本课程的 github 仓库或直接将本课程实验相关内容上传到任何 public repo。

## 实验提交要求

实验提交时需要同时提交代码压缩包和实验报告两个文件。

实验报告要求上传 pdf 文件，其中需要包含以下内容：

- 实验内容及简要原理介绍
- 实验具体过程与代码实现
- 实验结果与分析
- 实验中遇到的问题及解决方法
- 思考题与心得体会
- 对实验指导的建议（可选）

!!! tip 
    - 在代码实现部分重点展示设计思路和核心部分代码即可，不需要大段粘贴代码
        - 如要展示代码，需以非纯文本的形式展示（需要使用代码块）
    - 思考题占有一定的分值，需要认真回答
    - 请保持实验报告清晰、简洁

## 为什么我把 Linux 源码放在共享文件夹或 wsl2 的 `/mnt` 下编译不出来？

这种情况下，Linux 在使用 Windows 上的文件系统。请使用 `wget` 等工具将 Linux 源码下载至容器内目录**而非共享目录或 `/mnt` 目录下的任何位置**，然后执行编译。

## 为什么 QEMU & GDB 使用 `si` 单指令调试遇到模式切换时无法正常执行？

在遇到诸如 `mret`, `sret` 等指令造成的模式切换时，`si` 指令会失效，可能表现为程序开始不停跑，影响对程序运行行为的判断。

一个解决方法是在程序**预期跳转**的位置打上断点，断点不会受到模式切换的影响，比如：

```bash
(gdb) i r sepc    
sepc        0x8000babe
(gdb) b * 0x8000babe
Breakpoint 1 at 0x8000babe
(gdb) si    # 或者使用 c
Breakpoint 1, 0x000000008000babe in _never_gonna_give_you_up ()
...
```

这样就可以看到断点被触发，可以继续调试了。

## 为什么我不能在 GDB 中使用 `next` 或者 `finish` ?

这两条命令都依赖在内核中添加的调试信息，可以通过 `menuconfig` 进行配置添加。我们在实验中没有对这部分内容作要求，可以自行 Google 探索。

## 为什么我在内核中添加了 debug 信息，但是还是没法使用 `next` 或者 `finish` ?

可能你在配置内核时已经添加了调试信息，但是并没有在**QEMU运行的其他部分**添加。例如 SRAM 中对 `march` 进行配置的过程，以及 opensbi 中的所有部分，都缺少调试信息。所以才无法按照函数的层级进行调试。我们在实验中没有对这部分内容作要求，可以自行 Google 探索。

## 为什么 Lab1 中我的 C 语言函数的参数无法正确传入？

确认自己是否在 `head.S` 里的 `_start` 函数中正确设置了 `sp`，正常情况下它的值应该是 `0x8020XXXX`。未设置或设置错 `sp` 会使栈上的值不正确且无法写入。

!!! tip 
    注意检查是否将 `head.S` 里的 `.section` 改为 `.text.init`，如果不改的话 `_traps` 和 `_start` 都在 `.text.entry` 段，此时 `_traps` 会被放置到 `0x80200000` 处，导致其先于 `_start` 执行；而此时还未设置 `sp`，故传参时会出现混乱（具体表现为 `trap_handler` 的所有参数均显示 `2^64-1`）。

## 不会找 Lab1 的 syscall table 怎么办？

主要有两种方法，一种是安装该架构的交叉编译工具链并编译得到预处理产物，另一种则是在某些文件中直接就有现成的 syscall table. 无论选用哪种方法都要善用搜索，查找系统调用具体放在哪个文件中。可以参考[这篇文章](https://unix.stackexchange.com/questions/421750/where-do-you-find-the-syscall-table-for-linux)。

!!! tip 
    或许可以直接去 `arch` 对应架构文件夹下搜索关键词？

## 如何升级到 Ubuntu 24.04

请按照 [How to upgrade - Ubuntu](https://ubuntu.com/server/docs/how-to-upgrade-your-release) 或 [DebianUpgrade - Debian Wiki](https://wiki.debian.org/DebianUpgrade) 的说明进行升级，所需命令概括如下（使用两种方式之一即可）：

- 使用 Ubuntu 特有的 `do-release-upgrade` 命令：

    ```shell
    sudo apt update
    sudo apt upgrade
    sudo apt full-upgrade
    sudo do-release-upgrade
    ```

- 使用 Debian 标准的升级流程：

    ```shell
    sudo apt-get update
    sudo apt-get upgrade
    sudo apt-get full-upgrade
    # 修改 APT 源
    sudo apt-get clean
    sudo apt-get update
    sudo apt-get upgrade
    sudo apt-get full-upgrade
    sudo apt-get autoremove
    ```

升级完成后，务必尽快重启，不论是物理机还是虚拟机（WSL、Docker）。

## 不知道如何计算 Lab3 建立映射时所需的虚拟地址 `va` 和大小 `sz`？

在 `vmlinux.lds` 中有 `_stext`, `_srodata` 等符号，可以在代码里这样来声明它：`extern char _stext[]`，这样就可以通过 `_stext` 获得其所在虚拟地址 `va`，并且可以通过两个段的开头符号做减法获得段的大小 `sz`。

<!--
## 为什么我的 QEMU 会 “卡住”？

`qemu-system` 本身作为一个模拟器，是不会直接卡死的，如果你在 `si` 或者 `c` 后，QEMU 看起来失去了响应，那么极有可能是程序运行到了意想不到的地方。例如在写入 `satp` 后，如果部分 bit 没有成功设置，那么可能会直接跳进 `trap`。而且在前面的实验中我们也发现了，在发生特权级切换或者发生陷入时，`si` 是有可能无法触发的，这种情况下就需要你在程序可能到达的地方都打上断点来暂停 QEMU 的执行了。

## 为什么我在设置 `satp` 后导致了 `gdb-multiarch` 的 `segmentation fault` ?

因为 `satp` 或者各级页表项设置有问题。比如检查一下我们之前一直忽略的页表项里 U-bit 设置好了没有。

## 为什么在 `vmlinux.lds.S` 中会 `#include "types.h"`?

因为我们实验代码存在一些历史限制没来得及修改，在 `vmlinux.lds.S` 中有 `#include "defs.h"`，然后之前又没有提醒同学不要在 `defs.h` 里面添加东西，导致在 `defs.h`中添加的内容阻碍了 `vmlinux.lds` 的正确生成。一个可行的做法是将 `defs.h` 中除了宏定义以外的部分全部去除（包括宏include），然后将这些去掉的部分添加到其他的头文件里以供使用。

## `uapp` 明明已经在内存里了，为什么还要被拷贝一次才能运行？

因为我们在实验中不准备引入磁盘驱动，所以将内存的一部分作为 `ramdisk`, 也就是说有一段内存被我们当成了硬盘。这段内存就是从 `uapp_start`  到 `uapp_end` 的空间，所以我们需要像操作磁盘一样操作这段内存。在运行磁盘上的程序前，我们需要将其拷贝到我们为程序分配的内存空间中，并依照 Elf Header 的要求映射到用户能访问的地址空间。这时候用户就能访问我们从磁盘拷贝到内存中的数据和代码了。

## 为什么我 `sret` 到用户程序的第一条指令时会 Instruction Page Fault?

大概率是因为没有设置好页表项里的 U-bit, 详细可以读一下 Privileged Spec. 也有可能你没有将内存映射到正确的位置上。

## `uapp` 要怎么拷贝到内存里？是要我们直接实现 VMA 和 `mmap` 吗？

只要一个一个字节地将内容复制到我们使用 `alloc_pages` 或者 `kalloc` 开辟的内存中即可，VMA 和 `mmap` 将在 Lab6 或之后才会引入，暂时不用同学们实现。 -->
