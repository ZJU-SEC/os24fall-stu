# 关于 spike 工具链的使用

!!! abstract "感兴趣的同学可以根据本文档自行使用 spike 工具链运行 RISC-V kernel"

!!! tip "本课程所有实验的结果最后仍以 qemu 为准，spike 仅供有兴趣的同学尝试"


## 工具链简介

### Spike

[Spike](https://github.com/riscv-software-src/riscv-isa-sim/) 是一个和 QEMU 类似的指令模拟器。虽然它不像 QEMU 那样支持各种指令集架构，可以模拟复杂的外设，但是在 RISC-V 的模拟和支持上，spike 是逐条指令进行模拟，且严格按照 RISC-V 的指令集手册，对于 RISC-V 程序的检查更为严谨。

!!! note "特别是在页表的实验中，spike 会严谨得多，推荐有精力的同学额外用 spike 运行进行测试"

QEMU 为了追求运行的高效，往往会将指令分块打包编译为宿主机指令高效运行；而 spike 则选择了根据 RISC-V 指令集充分模拟 RISC-V 体系结构的各种硬件，然后逐条运行指令，并修改各个模拟硬件，当然这也会导致 spike 运行速度比 qemu 慢一些。

如果同学们想要了解一些 RISC-V 机制的具体实现，直接阅读 spike 的源码也是不错的选择。

### OpenOCD

[OpenOCD](https://github.com/openocd-org/openocd/) 是一个调试的中间工具。一些 RISC-V 芯片为了方便硬件调试内部的信息会在内部集成一个 debug module，并对外暴露一个 JTAG 接口。调试者可以用 JTAG 线的输入线向 debug module 输入命令，并用输出线得到需要读取的结果。这个指令传输协议是复杂的，我们本能地希望可以有一个简单的命令工具，我们向他发送诸如 read、write 的指令，它再帮我们转换为晦涩的 DMI 指令序列，这个工具就是 OpenOCD。

Spike 直接模拟的是硬件设备，所以它也直接模拟了一个 debug module，指定 `--rbb-port` 选项之后，它就可以开放对应的模拟 JTAG 端口等待被连接调试。OpenOCD 连接这个端口然后开始调试，不过它并不知道我们的 spike 的平台类型的连接类型，因此需要我们额外提供 openocd.cfg 文件，只要运行 `openocd -f openocd.cfg`，就会自动连接 9824 端口，并准备调试我们的 spike。配置文件内容如下：

```tcl
adapter driver remote_bitbang
remote_bitbang host localhost
remote_bitbang port 9824

set _CHIPNAME riscv
jtag newtap $_CHIPNAME cpu -irlen 5 

set _TARGETNAME $_CHIPNAME.cpu
target create $_TARGETNAME riscv -chain-position $_TARGETNAME

bindto 0.0.0.0
gdb_report_data_abort enable

init
reset halt
```

它连接了 remote bitbang 的端口，然后创建了一个 tap 和 target，开启了 gdb 后重置等待调试。这样 OpenOCD 会默认开放 3333 端口给 gdb 连接，通过 `target extended-remote localhost:3333` 或者 `tar ext :3333` 就可以连接到 OpenOCD。

之后 OpenOCD 可以担当 gdb 和 spike 之间的桥梁。gdb 接收到的指令会发送给 OpenOCD，OpenOCD 将它转换为对应的 01 串发送给 spike 进行调试，反之亦然。于是我们可以使用 gdb-OpenOCD-spike 的工具链实现原来 gdb-qemu 的效果。

### OpenSBI

OpenSBI 大家在 [lab1](lab1.md) 中应该都有所了解，就不介绍它本身了。这个工具链之所以需要 OpenSBI，是因为 spike 模拟的是一台裸机。我们的 kernel 不可以直接在裸机上运行，所以我们需要一个额外的 OpenSBI 的代码做前期的启动。所以我们需要下载 OpenSBI 代码并将它编译得到 fw_jump.elf，作为 M 态的维护代码。

## 工具链使用

### 编译安装
#### Spike

Spike 需要大家从源码自行编译安装：

```bash
git clone https://github.com/riscv-software-src/riscv-isa-sim
cd riscv-isa-sim
sudo apt install device-tree-compiler libboost-regex-dev libboost-system-dev
mkdir build
cd build
../configure
make -j$(nproc)
sudo make install
```

#### OpenOCD

OpenOCD 可以直接通过 `sudo apt install openocd` 来安装，也可以从源码编译：

```bash
git clone https://github.com/openocd-org/openocd/
cd openocd
sudo apt install libtool
./bootstrap
./configure --enable-remote-bitbang
make
sudo make install
```

#### OpenSBI

我们提供了一个编译好的 fw_jump.elf 在本仓库 `src/spike/fw_jump.elf` 中。

如果需要自行编译的话需要先通过 `make PLATFORM=generic menuconfig` 来关掉 Utils and Drivers Support > Serial Device Support > Semihosting support 这一选项。然后进行编译：

```bash
git clone https://github.com/riscv-software-src/opensbi
cd opensbi
mkdir build
make O=build CROSS_COMPILE=riscv64-linux-gnu- PLATFORM=generic
# output: build/platform/generic/firmware/fw_jump.elf
```

### 运行

本仓库 `src/spike` 中提供了 `Makefile.extra`，需要大家将其中内容复制到自己 kernel 的 `Makefile` 中，注意其中 `SPIKE_CONFIG` 目录的具体位置要进行修改。

然后执行 `make spike_run` 就可以通过 spike 运行 kernel 了。

### 调试

调试的话一共需要三个终端窗口，依次执行：

1. `make spike_debug`：启动 spike 并等待调试
2. `make spike_bridge`：启动 OpenOCD 并连接 spike
3. `gdb-multiarch vmlinux`：启动 gdb，然后执行：
    - `tar ext :3333`：连接到 OpenOCD
    - 开始调试

后续的调试流程和 qemu 类似，不再赘述。