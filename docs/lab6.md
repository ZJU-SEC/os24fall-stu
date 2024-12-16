# Lab6: VFS & FAT32 文件系统

!!! abstract "本实验为 bonus，不做硬性要求"

## 实验目的

* 为用户态的 Shell 提供 `read` 和 `write` syscall 的实现（完成该部分的所有实现方得 60 分）
* 实现 FAT32 文件系统的基本功能，并对其中的文件进行读写（完成该部分的所有实现方得 40 分）

## 实验环境

* Environment in previous labs

## 背景知识

### VFS

虚拟文件系统（Virtual File System，VFS）或虚拟文件系统交换机是位于更具体的文件系统之上的抽象层。VFS 的目的是允许客户端应用程序以统一的方式访问不同类型的具体文件系统。例如，可以使用 VFS 透明地访问本地和网络存储设备，而客户机应用程序不会注意到其中的差异。它可以用来弥合 Windows、macOS 等不同操作系统所使用的文件系统之间的差异，这样应用程序就可以访问这些类型的本地文件系统上的文件，而不必知道它们正在访问什么类型的文件系统。

VFS 指定内核和具体文件系统之间的接口（或“协议”）。因此，只需完成协议，就可以很容易地向内核添加对新文件系统类型的支持。协议可能会随着版本的不同而不兼容地改变，这将需要重新编译具体的文件系统支持，并且可能在重新编译之前进行修改，以允许它与新版本的操作系统一起工作；或者操作系统的供应商可能只对协议进行向后兼容的更改，以便为操作系统的给定版本构建的具体文件系统支持将与操作系统的未来版本一起工作。

### VirtIO

VirtIO 是一个开放标准，它定义了一种协议，用于不同类型的驱动程序和设备之间的通信。在 QEMU 上我们可以基于 VirtIO 使用许多模拟出来的外部设备，在本次实验中我们使用 VirtIO 模拟存储设备，并在其上构建文件系统。

!!! note "本次实验中涉及 VirtIO 的部分已经为大家实现好了，同学们只需要调用相关函数即可"

### MBR

主引导记录（Master Boot Record，MBR），又叫做主引导扇区，是计算机开机后访问硬盘时所必须要读取的首个扇区，它在硬盘上位于第一个扇区。在深入讨论主引导扇区内部结构的时候，有时也将其开头的 446 字节内容特指为“主引导记录”（MBR），其后是 4 个 16 字节的“磁盘分区表”（DPT），以及 2 字节的结束标志（55AA）。因此，在使用“主引导记录”（MBR）这个术语的时候，需要根据具体情况判断其到底是指整个主引导扇区，还是主引导扇区的前 446 字节。

### FAT32

文件分配表（File Allocation Table，FAT），是一种由微软发明并拥有部分专利的文件系统，供 MS-DOS 使用，也是所有非 NT 核心的 Windows 系统使用的文件系统。最早的 FAT 文件系统直接使用扇区号来作为存储的索引，但是这样做的缺点是显然易见的：当磁盘的大小不断扩大，存储扇区号的位数越来越多，越发占用存储空间。以 32 位扇区号的文件系统为例，如果磁盘的扇区大小为 512B，那么文件系统能支持的最大磁盘大小仅为 2TB。

所以在 FAT32 中引入的新的存储管理单位“簇”，一个簇包含一个或多个扇区，文件系统中记录的索引不再为扇区号，而是**簇号**，以此来支持更大的存储设备。你可以参考这些资料来学习 FAT32 文件系统的标准与实现：

- [FAT32文件系统？盘它！](https://www.youtube.com/watch?v=YfDU6g0CmZE&t=344s)
- [Microsoft FAT Specification](https://academy.cba.mit.edu/classes/networking_communications/SD/FAT.pdf)

!!! note "上述两个材料对于完成本次实验非常关键，希望同学们仔细阅读"
    - [FAT32文件系统？盘它！](https://www.youtube.com/watch?v=YfDU6g0CmZE&t=344s) 里提到的“块”可以对标本次实验里的“扇区”（sector）
        - `fat32_init` 函数里各种参数的计算方式可以参考本视频；
    - [Microsoft FAT Specification](https://academy.cba.mit.edu/classes/networking_communications/SD/FAT.pdf) 是本次实验参考的标准，`fat32_bpb` `fat32_dir_entry` 等结构体各个字段的含义，可以直接参考本材料，例如：
        - Page 7 讲解了 `fat32_bpb`，在 `fat32_init` 中用得上；
        - Page 23 处讲解了 `fat32_dir_entry`，在文件操作函数中用得上。

## 实验步骤

本次实验的内容分为两个部分：

- Shell：实现 VFS，编写虚拟文件设备 stdin, stdout, stderr 的读写操作；
- FAT32：实现 FAT32 文件系统的读写操作。

!!! note "本实验中不涉及 fork 的实现和缺页异常，只需要完成 Lab4 即可开始本实验（当然，本实验也兼容 Lab5）"

### 准备工作

!!! tip "代码与调试建议"
    框架代码中可能会使用到 `Log` `Err` 宏或者其他你可能未定义的东西，如果编译时出现报错可以自行补充，如果有不清楚的奇怪报错可以询问助教。

    在本次实验中，以往实验的部分可能会变得完全不重要，因为本次实验中只需要考虑文件系统和系统调用，所以你可以选择将原来调试用的 Log 宏禁用，以减少输出，比如在根目录下的 Makefile 中：

    ```Makefile
    LOG		:= 1
    CFLAG	:= ... -DLOG=$(LOG)
    ```

    然后在 `include/printk.h` 中：

    ```c title="include/printk.h"
    #if LOG
    #define Log(format, ...) \
        printk("\33[1;35m[%s,%d,%s] " format "\33[0m\n", \
            __FILE__, __LINE__, __func__, ## __VA_ARGS__)
    #else
    #define Log(format, ...);
    #endif
    ```

    这样在 `make run LOG=0` 时就不会输出 Log 信息了。

此次实验基于 lab4/5 同学所实现的代码进行。

* 从仓库同步以下文件：
    ```text
    src/lab6
      ├── disk.img.zip  // FAT32 磁盘镜像，需解压
      ├── fs
      │   ├── Makefile
      │   ├── fat32.c   // FAT32 文件系统实现
      │   ├── fs.c      // 供系统内核使用的文件系统相关函数实现
      │   ├── mbr.c     // MBR 初始化（无需修改）
      │   ├── vfs.c     // VFS 实现
      │   └── virtio.c  // VirtIO 驱动（无需修改）
      ├── include
      │   ├── fat32.h   // FAT32 相关数据结构与函数声明
      │   ├── fs.h      // 供系统内核使用的文件系统相关数据结构及函数声明
      │   ├── mbr.h     // MBR 相关数据结构与函数声明（无需关注）
      │   ├── vfs.h     // VFS 操作函数声明
      │   └── virtio.h  // VirtIO 驱动相关数据结构与函数声明（无需关注）
      └── user              // 用户态程序部分不需同学们修改，所以这里给出完整的代码
          ├── Makefile      // 未作修改
          ├── link.lds      // 未作修改
          ├── main.c    // nish 用户态程序（需要阅读）
          ├── printf.c      // 未作修改
          ├── start.S       // 未作修改
          ├── stddef.h      // 未作修改
          ├── stdint.h      // 同步了内核的 stdint.h
          ├── stdio.h       // 未作修改
          ├── string.c      // 新文件，添加了 strlen
          ├── string.h      // 新文件，添加了 strlen
          ├── syscall.h     // 更新了系统调用号
          ├── uapp.S        // 未作修改
          ├── unistd.c  // 系统调用实现（需要阅读）
          └── unistd.h
    ```
* 同时需要修改 proc.h/c，在初始化时只创建一个用户态进程
* 因为加了一个根目录下的 fs 文件夹，所以需要在 `arch/riscv/Makefile` 里面添加相关编译产物来进行链接：
    ```Makefile title="arch/riscv/Makefile" linenums="3"
    ${LD} -T kernel/vmlinux.lds kernel/*.o ../../init/*.o ../../lib/*.o ../../fs/*.o ../../user/uapp.o -o ../../vmlinux 
    ```


### Shell: 与内核进行交互

我们为大家提供了用户态程序 "nish" (Not Implemented SHell) 来与我们在实验中完成的 kernel 进行交互。它提供了简单的用户交互和文件读写功能，有如下的命令：

```bash
echo [string]   # 将 string 输出到 stdout
cat [path]      # 将路径为 path 的文件的内容输出到 stdout
edit [path] [offset] [string] # 将路径为 path 的文件，偏移量为 offset 的部分开始，写为 string
```

我们在启动一个用户态程序（包括 nish）时默认打开了三个文件，`stdin`，`stdout` 和 `stderr`，他们对应的 file descriptor 分别为 `0`，`1`，`2`。在 nish 启动时，会首先向 `stdout` 和 `stderr` 分别写入一段内容作为测试：

```c title="user/main.c" linenums="134"
write(1, "hello, stdout!\n", 15);
write(2, "hello, stderr!\n", 15);
```

而在这之前，我们也曾处理过 write 系统调用，不过当时是根据 stdin 的 fd 来特判的。接下来在本次实验中我们会将这一操作包装为文件系统的操作。

#### 文件系统抽象

我们在 `include/fs.h` 中定义了文件系统的数据结构：

```c title="include/fs.h" linenums="31"
struct file {   // Opened file in a thread.
    uint32_t opened;    // 文件是否打开
    uint32_t perms;     // 文件的读写权限
    int64_t cfo;        // 当前文件指针偏移量
    uint32_t fs_type;   // 文件系统类型

    union {
        struct fat32_file fat32_file;   // 后续 FAT32 文件系统的文件需要的额外信息
    };

    int64_t (*lseek) (struct file *file, int64_t offset, uint64_t whence);  // 文件指针操作
    int64_t (*write) (struct file *file, const void *buf, uint64_t len);    // 写文件
    int64_t (*read)  (struct file *file, void *buf, uint64_t len);          // 读文件

    char path[MAX_PATH_LENGTH]; // 文件路径
};

struct files_struct {
    struct file fd_array[MAX_FILE_NUMBER];
};
```

可以看出我们为每个文件都保存了三个函数指针，这样针对不同文件的同一操作就可以调用到不同函数了。同时为了方便实现，我们直接通过数组来保存 file 结构体，默认情况下会创建 `MAX_FILE_NUMBER=16` 个可用的文件描述符。

接下来需要同学们修改 proc.h，为进程 task_struct 结构体添加一个指向文件表的指针：

```c title="arch/riscv/include/proc.h"
struct task_struct {
    ...
    struct files_struct *files;
};
```

#### stdout/err/in 初始化

在 `fs/fs.c` 文件中，我们定义了一个函数 `file_init`：

```c title="fs/fs.c" linenums="8"
struct files_struct *file_init() {
    // todo: alloc pages for files_struct, and initialize stdin, stdout, stderr
    struct files_struct *ret = NULL;
    return ret;
}
```

这个函数需要大家在 proc.c 中的 `task_init` 函数中为每个进程调用，创建文件表并保存在 task struct 中。

在这个函数中，你需要：

- 根据 `files_struct` 的大小分配页空间
- 为 stdin、stdout、stderr 赋值，比如 stdin 你可以：
    ```c 
    ret->fd_array[0].opened = 1;
    ret->fd_array[0].perms = FILE_READABLE;
    ret->fd_array[0].cfo = 0;
    ret->fd_array[0].lseek = NULL;
    ret->fd_array[0].write = NULL;
    ret->fd_array[0].read = ...;
    ```
    - 这里的 read / write 函数可以留到等下来实现
- 保证其他未使用的文件的 `opened` 字段为 0

#### 处理 stdout/err 的写入

正如 4.2 开头所说，用户态程序在开始的时候会通过 `write` 函数来向内核发起 syscall 进行测试。在捕获到 write 的 syscall 之后，我们就可以查找对应的 fd，并通过对应的 write 函数调用来进行输出了。一个参考实现如下：

```c
int64_t sys_write(uint64_t fd, const char *buf, uint64_t len) {
    int64_t ret;
    struct file *file = &(current->files->fd_array[fd]);
    if (file->opened == 0) {
        printk("file not opened\n");
        return ERROR_FILE_NOT_OPEN;
    } else {
        // check perms and call write function of file
    }
    return ret;
}

void do_syscall(struct pt_regs* regs) {
    switch (regs->a7) {
        case SYS_WRITE:
            regs->a0 = sys_write(regs->a0, (const char *)regs->a1, regs->a2);
            break;
        case SYS_GETPID:
            regs->a0 = current->pid;
            break;
        case SYS_CLONE:
            regs->a0 = do_fork(regs);
            break;
        default:
            Err("not support syscall id = %d", regs->a7);
    }
    regs->sepc += 4;
}
```

对于 stdout 和 stderr 的输出，我们直接通过 `printk` 进行串口输出即可：

```c title="fs/vfs.c" linenums="22"
int64_t stdout_write(struct file *file, const void *buf, uint64_t len) {
    char to_print[len + 1];
    for (int i = 0; i < len; i++) {
        to_print[i] = ((const char *)buf)[i];
    }
    to_print[len] = 0;
    return printk(to_print);
}

int64_t stderr_write(struct file *file, const void *buf, uint64_t len) {
    // todo
}
```

实现好后，你应该已经能够打印出输出了：

```text
2024 ZJU Operating System
hello, stdout!
hello, stderr!
SHELL >
```

#### 处理 stdin 的读取

此时 nish 已经打印出命令行等待输入命令以进行交互了，但是还需要读入从终端输入的命令才能够与人进行交互，所以我们要实现 `stdin` 以获取键盘键入的内容。

对于输入的读取就是对于 fd=0 的 stdin 文件进行 read 操作，所以需要我们实现 vfs.c 中的 stdin_read 函数。而对于终端的输入，我们需要通过 sbi 来完成，需要大家在 `arch/riscv/include/sbi.h` 中添加函数：

```c title="arch/riscv/include/sbi.h"
struct sbiret sbi_debug_console_read(uint64_t num_bytes, uint64_t base_addr_lo, uint64_t base_addr_hi);
```

并在 sbi.c 中进行实现（eid 和 `console_write_byte` 一样为 `0x4442434e`，fid 为 1）。其中参数 `num_bytes` 为读取的字节数，`base_addr_lo` 和 `base_addr_hi` 为写入的目的地址（`base_addr_hi` 在 64 位架构中不会用到）。

接下来在 vfs.c 中我们为大家定义了函数 `uart_getchar()`，因为 `sbi_debug_console_read` 是非阻塞的，所以我们需要一个函数来不断进行读取，直到读到了有效字符，然后在 `stdin_read` 中只需要这样读取 `len` 个字符就好了。

!!! note "关于 read 阻塞的说明"
    同学们可以发现我们这里实现的 `read` 其实是完全阻塞的，即读取到了 `len` 个字符才会返回，实际上这只是简化的操作。

    实际情况下 `read` 只会在没有任何输入的情况下阻塞，一旦可以读到数据，则不论是否达到 `len` 都会立即返回，但本次实验中不考虑这种情况即可。

完成了 `stdin_read` 后，还需要捕获 63 号系统调用 read，来和 write 一样类似处理即可。

全部完成后，你应该就可以在 nish 中使用 `echo` 命令了：

```text
SHELL > echo "test"
test
```

??? tip "为什么我觉得写的完全没问题但是没法读入"
    有些同学可能已经顺利进入了 `sbi_debug_console_read` 和 `sbi_ecall` 中，但是传给 `sbi_ecall` 的参数正确也不能获取输入。这时候你需要检查一下 vmlinux.asm 中生成的 `sbi_ecall` 的汇编，这可能是你的实现长久以来就有问题但一直没触发。比如你可能会在 ecall 前看到：

    ```asm
    00078893          	mv	a7,a5
    00070813          	mv	a6,a4
    00068513          	mv	a0,a3
    00060593          	mv	a1,a2
    00058613          	mv	a2,a1
    00050693          	mv	a3,a0
    00080713          	mv	a4,a6
    00088793          	mv	a5,a7
    00000073          	ecall
    ```

    你会发现在你的内联汇编生成出了非预期的指令序列（比如 a5->a7->a5，这样 a5 的值就被覆盖了），这可能是你在内联汇编的最后一个破坏描述部分没有说明 a0-a7 是会被破坏的（即让编译器不要使用 a0-a7 作为临时变量），你需要再参考相关文档进行修改。

### FAT32：持久存储

在本次实验中我们仅需实现 FAT32 文件系统中很小一部分功能，我们为实验中的测试做如下限制：

* 文件名长度小于等于 8 个字符，并且不包含后缀名和字符 `.` .
* 不包含目录的实现，所有文件都保存在磁盘根目录 `/fat32/` 下。
* 不涉及磁盘上文件的创建和删除。
* 不涉及文件大小的修改。

#### 准备工作
##### 利用 VirtIO 为 QEMU 添加虚拟存储

我们为大家准备了一个 FAT32 的磁盘映像，其中包含了一个 MBR 分区表以及一个存储有一些文件的 FAT32 分区，需要大家解压 `src/lab6/disk.img.zip` 得到 `disk.img` 并放在根目录下。

接下来可以使用如下的命令来启动 QEMU，这会将磁盘连接到 QEMU 的一个 VirtIO 接口上，构成一个 `virtio-blk-device`：

```Makefile
run: all
	@echo Launch qemu...
	@qemu-system-riscv64 -nographic -machine virt -kernel vmlinux -bios default \
		-global virtio-mmio.force-legacy=false \
		-drive file=disk.img,if=none,format=raw,id=hd0 \
		-device virtio-blk-device,drive=hd0

debug: all
	@echo Launch qemu for debug...
	@qemu-system-riscv64 -nographic -machine virt -kernel vmlinux -bios default \
		-global virtio-mmio.force-legacy=false \
		-drive file=disk.img,if=none,format=raw,id=hd0 \
		-device virtio-blk-device,drive=hd0 -S -s
```

VirtIO 所需的驱动我们已经为大家编写完成了，在 `fs/virtio.c` 中给出，为了正常使用这部分外设，还需要在 `setup_vm_final` 中添加对 VritIO 外设的映射：

```c title="arch/riscv/kernel/vm.c"
create_mapping(swapper_pg_dir, io_to_virt(VIRTIO_START), VIRTIO_START, VIRTIO_SIZE * VIRTIO_COUNT, PTE_W | PTE_R | PTE_V);
```

##### 初始化 VirtIO 与 MBR

除了 VirtIO，我们还为大家实现了读取 MBR 这一磁盘初始化过程。该过程会搜索磁盘中存在的分区，然后对分区进行初步的初始化。

这两部分分别需要使用 `virtio_dev_init()` 和 `mbr_init()` 进行初始化，需要在 `head.S` 中 `task_init` 结束后调用。

#### 初始化 FAT32 分区

在 FAT32 分区的第一个扇区中存储了关于这个分区的元数据，首先需要读取并解析这些元数据。我们提供了两个数据结构的定义，`fat32_bpb` 为 FAT32 BIOS Parameter Block 的简写。这是一个物理扇区，其中对应的是这个分区的元数据。首先需要将该扇区的内容读到一个 `fat32_bpb` 数据结构中进行解析。

`fat32_volume` 是用来存储我们后续代码中需要用到的元数据的，需要根据 `fat32_bpb` 中的数据来进行计算并初始化。

!!! note "为了简单起见，本次实验中每个簇都只包含 1 个扇区。所以你的代码可能会以各种灵车的方式跑起来，但是你仍需要对簇和扇区有所区分，并在报告里有所体现。"

```c title="fs/fat32.c" linenums="26"
void fat32_init(uint64_t lba, uint64_t size) {
    virtio_blk_read_sector(lba, (void*)&fat32_header);  // 从第 lba 个扇区读取 FAT32 BPB
    fat32_volume.first_fat_sec = /* to calculate */;    // 记录第一个 FAT 表所在的扇区号
    fat32_volume.sec_per_cluster = /* to calculate */;  // 每个簇的扇区数
    fat32_volume.first_data_sec = /* to calculate */;   // 记录第一个数据簇所在的扇区号
    fat32_volume.fat_sz = /* to calculate */;           // 记录每个 FAT 表占的扇区数（并未用到）
}
```

!!! tip "指导与调试建议"
    为了完成这一部分，你需要了解 FAT32 中扇区的排列方式与用途。
    
    即 `lba` 扇区为 BPB，这之后紧接着的是一些保留扇区，然后是第一个 FAT 表所在的扇区（这个表会占很多个扇区，需要从 bpb 读取），接下来是第二个 FAT 表所在的扇区（为第一个 FAT 表的备份），然后接下来是数据区。

    在得到这些之后，你可以尝试从 `fat32_volume.first_fat_sec` 读取一个扇区到 `fat32_buf` 中，如果正确的话，开头四个字节应该是 `F8FFFF0F`。

!!! tip "物理层面读写扇区的原语"
    - 出于实验难度的考虑，物理层面通过 virtio 读写扇区的驱动函数已经写好；
        - `virtio_blk_read_sector` 可以将扇区号对应的扇区读入到一个 buffer 内；
        - `virtio_blk_write_sector` 可以将一个 buffer 的内容写入到特定扇区号的扇区里；
    - 不论是 `openat` `read` `write` `lseek`，都可能需要调用这两个函数，来完成跟扇区内容的交互；

!!! tip "更多调试建议"
    你可以使用 16 进制文件查看软件打开 `disk.img` 文件，来查看其中的内容，每个扇区的大小都为 `VIRTIO_BLK_SECTOR_SIZE`。

    虽然文件中大部分内容都为 0，但是你可以搜索得到一些有意义的部分：

    - 字符串 `mkfs.fat`，这八个字节是 bpb 中的 oem 代号，即 `fat32_bpb->oem_name`；
        - 根据这个位置，你可以找到 BPB 的开始位置；
    - 字节序列 `F8 FF FF 0F`，这是 FAT 表的开头，也是第一个 FAT 项的内容；
    - 字符串 `EMAIL`，这是我们要读取的文件的名字，它会在数据区开头的根目录扇区中出现，标志着一个短文件名目录项的开始；
        - 你可能会看到有其他的目录项，你可以不用管它们，在本次实验中不会用到；
    - 字符串 `From`，这是要读取的文件内容的开头，它也会处于一个扇区的开头。

#### 完善系统调用

在读取文件之前，首先需要打开对应的文件，这需要实现 `openat` syscall，调用号为 56。你需要寻找一个空闲的文件描述符，然后调用 `file_open` 函数来初始化这个文件描述符。

!!! note "关于判断文件系统类型"
    我们使用最简单的判别文件系统的方式，文件前缀为 `/fat32/` 的即是本次 FAT32 文件系统中的文件，例如，在 `nish` 中我们尝试读取文件，使用的命令是 `cat /fat32/$FILENAME`. `file_open` 会根据前缀决定是否调用 `fat32_open_file` 函数（后面实现）。

    注意因为我们的文件一定在 FAT32 的根目录下，也即 `/fat32/` 下，所以无需实现与目录遍历相关的逻辑。此外需要注意的是，需要将文件名统一转换为大写或小写，因为我们的实现是不区分大小写的。

读取完成后 nish 会调用 close 来关闭文件，所以你需要实现 57 号系统调用 close，来为指定的文件描述符关闭文件。

最后在 nish 处理 edit 的时候，会先进行 lseek 调整文件指针，然后再进行 write，所以你需要参考 write 和 read 实现类似的 62 号系统调用 lseek。

#### 打开文件

接下来就是本次实验中比较复杂的部分了，首先在 `fat32_open_file` 函数中，我们需要读取出被打开的文件所在的簇和目录项位置的信息，来供后面 read write lseek 使用，目标是获取到：

```c title="include/fs.h" linenums="21"
struct fat32_dir {
    uint32_t cluster;   // 文件的目录项所在的簇
    uint32_t index;     // 文件的目录项是该簇中的第几个目录项
};

struct fat32_file {
    uint32_t cluster;       // 文件开头所在的簇
    struct fat32_dir dir;   // 文件的目录项信息
};
```

你需要遍历数据区开头的根目录扇区，找到 name 和 `path` 末尾的 `filename` 相匹配的 `fat32_dir_entry` 目录项结构体，再从其中得到这些信息。

!!! tip "为什么我匹配不到要打开的文件"
    如果是使用 `memcmp` 来逐一比较 FAT32 文件系统根目录下的各个文件名和想要打开的文件名，则需要 8 个字节完全匹配。但是需要注意的是，FAT32 文件系统根目录下的文件名并不是以 "\0" 结尾的字符串，你需要参考 spec 或者 `disk.img` 中的内容来了解 FAT32 文件名的存储方式。

#### 读取与写入文件

对于 FAT32 文件系统的文件读取，会调用到 `fat32_read` 函数，你需要根据 `file->fat32_file` 中的信息（即 open 的时候获取的信息）找到文件内容所在的簇，然后读取出文件内容到 `buf` 中。

!!! tip "Hint"
    - 通过 `cluster_to_sector` 可以得到簇号对应的扇区号；
    - 通过 `virtio_blk_read_sector` 对扇区进行读取；
    - 你可能需要再通过读取目录项来获取文件长度；
    - 读取是要从 `file->cfo` 开始的；
    - 读取的长度可能会使得内容跨越了一个或几个扇区，你需要多次读取；
    - 读取到了文件末尾就应该截止，并返回实际读取的长度；
    - 如果 read 返回了 0，则说明已经读取到了文件末尾，这样用户态程序就知道文件已经完全读取结束了。

正确实现后，你应该可以看到 `cat /fat32/email` 的输出了：

??? success "示例输出"
    ```text
    ...buddy_init done!
    ...mm_init done!
    ...proc_init done!
    ...virtio_blk_init done!
    ...fat32 partition #1 init done!
    2024 ZJU Operating System
    hello, stdout!
    hello, stderr!
    SHELL > cat /fat32/email
    From: TORVALDS@klaava.Helsinki.FI (Linus Benedict Torvalds)
    Newsgroups: comp.os.minix
    Subject: What would you like to see most in minix?
    Summary: small poll for my new operating system
    Message-ID:
    Date: 25 Aug 91 20:57:08 GMT
    Organization: University of Helsinki

    Hello everybody out there using minix -

    I'm doing a (free) operating system (just a hobby, won't be big and professional like gnu) for 386(486) AT cones. This has been brewing since april, and is starting to get ready. I'd Tike any feedback on things people like/dislike in minix, as my 0S resembles it somewhat (same physical layout of the file-system (due to practical reasons) among other things) .

    I've currently ported bash(1.08) and gcc(1.40), and things seem to work. This implies that I'll get something practical within a few months, andI'd like to know what features most people would want. Any suggestions are welcome, but I won't promise I'll implement them :-)

                Linus (torvalds@kruuna.helsinki.fi)

    PS. Yes . it's free of any minix code, and it has a multi-threaded fs. It is NOT protable (uses 386 task switching etc), and it probably never will support anything other than AT-hard disks, as that's all I have :-($
    SHELL >
    ```

write 操作和 read 非常相似，只需要修改后再通过 `virtio_blk_write_sector` 写回扇区即可。

!!! tip "本次实验不要求实现根据访问时间更新目录项信息"

#### lseek 操作

在 nish 处理 edit 的时候，会先进行 lseek 调整文件指针，然后再进行 write。而 lseek 在做的就是调整指针 `file->cfo` 的值，你需要实现：

```c title="fs/fat32.c" linenums="67"
int64_t fat32_lseek(struct file* file, int64_t offset, uint64_t whence) {
    if (whence == SEEK_SET) {
        file->cfo = /* to calculate */;
    } else if (whence == SEEK_CUR) {
        file->cfo = /* to calculate */;
    } else if (whence == SEEK_END) {
        /* Calculate file length */
        file->cfo = /* to calculate */;
    } else {
        printk("fat32_lseek: whence not implemented\n");
        while (1);
    }
    return file->cfo;
}
```

具体 `whence` 的含义请自行搜索 spec。

#### 测试

全部实现完成后，就可以实现文件的读写操作了：

???+ success "示例输出"
    ```text
    ...buddy_init done!
    ...mm_init done!
    ...proc_init done!
    ...virtio_blk_init done!
    ...fat32 partition #1 init done!
    2024 ZJU Operating System
    hello, stdout!
    hello, stderr!
    SHELL > echo "test"
    test
    SHELL > cat /fat32/email
    From: torvalds@klaava.Helsinki.FI (Linus Benedict Torvalds)
    ...
    SHELL > edit /fat32/email 6 TORVALDS
    SHELL > cat /fat32/email
    From: TORVALDS@klaava.Helsinki.FI (Linus Benedict Torvalds)
    ...
    SHELL >
    ```

    这里通过 `edit /fat32/email 6 TORVALDS` 来将文件 "From" 后面的 torvalds 改成了大写。除此之外你也可以发现重新 `make run` 运行，并直接 `cat /fat32/email`，输出的也是修改后的大写 TORVALDS，因为这部分修改是持久保存在 disk.img 磁盘中的。

## 实验任务与要求

!!! note "本次实验为 bonus，无思考题"

- 请各位同学独立完成作业，任何抄袭行为都将使本次作业判为 0 分。
- 在学在浙大中提交：
    - 整个工程代码的压缩包（提交之前请使用 `make clean` 清除所有构建产物）
    - pdf 格式的实验报告：
        - 记录实验过程并截图（4.1-4.3），并对每一步的命令以及结果进行必要的解释；
        - 记录遇到的问题和心得体会。

!!! tip "关于实验报告内容要求，可见：[常见问题及解答 - 实验提交要求](faq.md#_2)"

