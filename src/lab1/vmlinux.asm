
../../vmlinux:     file format elf64-littleriscv


Disassembly of section .text:

0000000080200000 <_skernel>:
    .extern start_kernel
    .section .text.init
    .globl _start
_start:
    la sp, boot_stack_top
    80200000:	00003117          	auipc	sp,0x3
    80200004:	01013103          	ld	sp,16(sp) # 80203010 <_GLOBAL_OFFSET_TABLE_+0x8>
    # ------------------
    # set stvec = _traps
    la t0, _traps
    80200008:	00003297          	auipc	t0,0x3
    8020000c:	0102b283          	ld	t0,16(t0) # 80203018 <_GLOBAL_OFFSET_TABLE_+0x10>
    csrw stvec, t0
    80200010:	10529073          	csrw	stvec,t0
    # ------------------
    # set sie[STIE] = 1
    li t0, 1<<5
    80200014:	02000293          	li	t0,32
    csrw sie, t0
    80200018:	10429073          	csrw	sie,t0
    # ------------------
    # set first time interrupt
    li t1,10000000
    8020001c:	00989337          	lui	t1,0x989
    80200020:	6803031b          	addiw	t1,t1,1664 # 989680 <_skernel-0x7f876980>
    # get time
    rdtime t0
    80200024:	c01022f3          	rdtime	t0
    add t0,t0,t1
    80200028:	006282b3          	add	t0,t0,t1
    # set next interrupt
    jal x1, sbi_set_timer
    8020002c:	338000ef          	jal	80200364 <sbi_set_timer>
    # ------------------
    # set sstatus[SIE] = 1
    li t0, 1<<1
    80200030:	00200293          	li	t0,2
    csrw sstatus, t0
    80200034:	10029073          	csrw	sstatus,t0
    # ------------------
    jal x0, start_kernel
    80200038:	3d80006f          	j	80200410 <start_kernel>

000000008020003c <_traps>:
    .align 2
    .globl _traps 
_traps:
    # -----------
        # 1. save 32 registers and sepc to stack
        addi sp, sp, -256
    8020003c:	f0010113          	addi	sp,sp,-256
        sd x1, 0(sp)
    80200040:	00113023          	sd	ra,0(sp)
        sd x2, 8(sp)
    80200044:	00213423          	sd	sp,8(sp)
        sd x3, 16(sp)
    80200048:	00313823          	sd	gp,16(sp)
        sd x4, 24(sp)
    8020004c:	00413c23          	sd	tp,24(sp)
        sd x5, 32(sp)
    80200050:	02513023          	sd	t0,32(sp)
        sd x6, 40(sp)
    80200054:	02613423          	sd	t1,40(sp)
        sd x7, 48(sp)
    80200058:	02713823          	sd	t2,48(sp)
        sd x8, 56(sp)
    8020005c:	02813c23          	sd	s0,56(sp)
        sd x9, 64(sp)
    80200060:	04913023          	sd	s1,64(sp)
        sd x10, 72(sp)
    80200064:	04a13423          	sd	a0,72(sp)
        sd x11, 80(sp)
    80200068:	04b13823          	sd	a1,80(sp)
        sd x12, 88(sp)
    8020006c:	04c13c23          	sd	a2,88(sp)
        sd x13, 96(sp)
    80200070:	06d13023          	sd	a3,96(sp)
        sd x14, 104(sp)
    80200074:	06e13423          	sd	a4,104(sp)
        sd x15, 112(sp)
    80200078:	06f13823          	sd	a5,112(sp)
        sd x16, 120(sp)
    8020007c:	07013c23          	sd	a6,120(sp)
        sd x17, 128(sp)
    80200080:	09113023          	sd	a7,128(sp)
        sd x18, 136(sp)
    80200084:	09213423          	sd	s2,136(sp)
        sd x19, 144(sp)
    80200088:	09313823          	sd	s3,144(sp)
        sd x20, 152(sp)
    8020008c:	09413c23          	sd	s4,152(sp)
        sd x21, 160(sp)
    80200090:	0b513023          	sd	s5,160(sp)
        sd x22, 168(sp)
    80200094:	0b613423          	sd	s6,168(sp)
        sd x23, 176(sp)
    80200098:	0b713823          	sd	s7,176(sp)
        sd x24, 184(sp)
    8020009c:	0b813c23          	sd	s8,184(sp)
        sd x25, 192(sp)
    802000a0:	0d913023          	sd	s9,192(sp)
        sd x26, 200(sp)
    802000a4:	0da13423          	sd	s10,200(sp)
        sd x27, 208(sp)
    802000a8:	0db13823          	sd	s11,208(sp)
        sd x28, 216(sp)
    802000ac:	0dc13c23          	sd	t3,216(sp)
        sd x29, 224(sp)
    802000b0:	0fd13023          	sd	t4,224(sp)
        sd x30, 232(sp)
    802000b4:	0fe13423          	sd	t5,232(sp)
        sd x31, 240(sp)
    802000b8:	0ff13823          	sd	t6,240(sp)
        csrr t0, sepc
    802000bc:	141022f3          	csrr	t0,sepc
        sd t0, 248(sp)
    802000c0:	0e513c23          	sd	t0,248(sp)
    # -----------
        # 2. call trap_handler
        csrr a0, scause
    802000c4:	14202573          	csrr	a0,scause
        csrr a1, sepc
    802000c8:	141025f3          	csrr	a1,sepc
        jal x1, trap_handler
    802000cc:	2f0000ef          	jal	802003bc <trap_handler>
    # -----------
        # 3. restore sepc and 32 registers (x2(sp) should be restore last) from stack
        ld t0, 248(sp)
    802000d0:	0f813283          	ld	t0,248(sp)
        csrw sepc, t0
    802000d4:	14129073          	csrw	sepc,t0
        ld x1, 0(sp)
    802000d8:	00013083          	ld	ra,0(sp)
        ld x3, 16(sp)
    802000dc:	01013183          	ld	gp,16(sp)
        ld x4, 24(sp)
    802000e0:	01813203          	ld	tp,24(sp)
        ld x5, 32(sp)
    802000e4:	02013283          	ld	t0,32(sp)
        ld x6, 40(sp)
    802000e8:	02813303          	ld	t1,40(sp)
        ld x7, 48(sp)
    802000ec:	03013383          	ld	t2,48(sp)
        ld x8, 56(sp)
    802000f0:	03813403          	ld	s0,56(sp)
        ld x9, 64(sp)
    802000f4:	04013483          	ld	s1,64(sp)
        ld x10, 72(sp)
    802000f8:	04813503          	ld	a0,72(sp)
        ld x11, 80(sp)
    802000fc:	05013583          	ld	a1,80(sp)
        ld x12, 88(sp)
    80200100:	05813603          	ld	a2,88(sp)
        ld x13, 96(sp)
    80200104:	06013683          	ld	a3,96(sp)
        ld x14, 104(sp)
    80200108:	06813703          	ld	a4,104(sp)
        ld x15, 112(sp)
    8020010c:	07013783          	ld	a5,112(sp)
        ld x16, 120(sp)
    80200110:	07813803          	ld	a6,120(sp)
        ld x17, 128(sp)
    80200114:	08013883          	ld	a7,128(sp)
        ld x18, 136(sp)
    80200118:	08813903          	ld	s2,136(sp)
        ld x19, 144(sp)
    8020011c:	09013983          	ld	s3,144(sp)
        ld x20, 152(sp)
    80200120:	09813a03          	ld	s4,152(sp)
        ld x21, 160(sp)
    80200124:	0a013a83          	ld	s5,160(sp)
        ld x22, 168(sp)
    80200128:	0a813b03          	ld	s6,168(sp)
        ld x23, 176(sp)
    8020012c:	0b013b83          	ld	s7,176(sp)
        ld x24, 184(sp)
    80200130:	0b813c03          	ld	s8,184(sp)
        ld x25, 192(sp)
    80200134:	0c013c83          	ld	s9,192(sp)
        ld x26, 200(sp)
    80200138:	0c813d03          	ld	s10,200(sp)
        ld x27, 208(sp)
    8020013c:	0d013d83          	ld	s11,208(sp)
        ld x28, 216(sp)
    80200140:	0d813e03          	ld	t3,216(sp)
        ld x29, 224(sp)
    80200144:	0e013e83          	ld	t4,224(sp)
        ld x30, 232(sp)
    80200148:	0e813f03          	ld	t5,232(sp)
        ld x31, 240(sp)
    8020014c:	0f013f83          	ld	t6,240(sp)
        ld x2, 8(sp)
    80200150:	00813103          	ld	sp,8(sp)
        addi sp, sp, 256
    80200154:	10010113          	addi	sp,sp,256
    # -----------
        # 4. return from trap
        sret 
    80200158:	10200073          	sret

000000008020015c <get_cycles>:
#include "sbi.h"

// QEMU 中时钟的频率是 10MHz，也就是 1 秒钟相当于 10000000 个时钟周期
uint64_t TIMECLOCK = 10000000;

uint64_t get_cycles() {
    8020015c:	fe010113          	addi	sp,sp,-32
    80200160:	00813c23          	sd	s0,24(sp)
    80200164:	02010413          	addi	s0,sp,32
    // 编写内联汇编，使用 rdtime 获取 time 寄存器中（也就是 mtime 寄存器）的值并返回
    unsigned long time;

    __asm__ volatile(
    80200168:	c01027f3          	rdtime	a5
    8020016c:	fef43423          	sd	a5,-24(s0)
        "rdtime %[time]"
        :[time] "=r" (time)
        : :"memory"
    );
    
    return time;
    80200170:	fe843783          	ld	a5,-24(s0)
}
    80200174:	00078513          	mv	a0,a5
    80200178:	01813403          	ld	s0,24(sp)
    8020017c:	02010113          	addi	sp,sp,32
    80200180:	00008067          	ret

0000000080200184 <clock_set_next_event>:

void clock_set_next_event() {
    80200184:	fe010113          	addi	sp,sp,-32
    80200188:	00113c23          	sd	ra,24(sp)
    8020018c:	00813823          	sd	s0,16(sp)
    80200190:	02010413          	addi	s0,sp,32
    // 下一次时钟中断的时间点
    uint64_t next_interrupt = get_cycles() + TIMECLOCK;
    80200194:	fc9ff0ef          	jal	8020015c <get_cycles>
    80200198:	00050713          	mv	a4,a0
    8020019c:	00003797          	auipc	a5,0x3
    802001a0:	e6478793          	addi	a5,a5,-412 # 80203000 <TIMECLOCK>
    802001a4:	0007b783          	ld	a5,0(a5)
    802001a8:	00f707b3          	add	a5,a4,a5
    802001ac:	fef43423          	sd	a5,-24(s0)

    // 使用 sbi_set_timer 来完成对下一次时钟中断的设置
    sbi_set_timer(next_interrupt);
    802001b0:	fe843503          	ld	a0,-24(s0)
    802001b4:	1b0000ef          	jal	80200364 <sbi_set_timer>
}
    802001b8:	00000013          	nop
    802001bc:	01813083          	ld	ra,24(sp)
    802001c0:	01013403          	ld	s0,16(sp)
    802001c4:	02010113          	addi	sp,sp,32
    802001c8:	00008067          	ret

00000000802001cc <sbi_ecall>:
#include "stdint.h"
#include "sbi.h"

struct sbiret sbi_ecall(uint64_t eid, uint64_t fid,
                        uint64_t arg0, uint64_t arg1, uint64_t arg2,
                        uint64_t arg3, uint64_t arg4, uint64_t arg5) {
    802001cc:	f8010113          	addi	sp,sp,-128
    802001d0:	06813c23          	sd	s0,120(sp)
    802001d4:	06913823          	sd	s1,112(sp)
    802001d8:	07213423          	sd	s2,104(sp)
    802001dc:	07313023          	sd	s3,96(sp)
    802001e0:	08010413          	addi	s0,sp,128
    802001e4:	faa43c23          	sd	a0,-72(s0)
    802001e8:	fab43823          	sd	a1,-80(s0)
    802001ec:	fac43423          	sd	a2,-88(s0)
    802001f0:	fad43023          	sd	a3,-96(s0)
    802001f4:	f8e43c23          	sd	a4,-104(s0)
    802001f8:	f8f43823          	sd	a5,-112(s0)
    802001fc:	f9043423          	sd	a6,-120(s0)
    80200200:	f9143023          	sd	a7,-128(s0)
    struct sbiret ret;
	__asm__ volatile(
    80200204:	fb843e03          	ld	t3,-72(s0)
    80200208:	fb043e83          	ld	t4,-80(s0)
    8020020c:	fa843f03          	ld	t5,-88(s0)
    80200210:	fa043f83          	ld	t6,-96(s0)
    80200214:	f9843283          	ld	t0,-104(s0)
    80200218:	f9043483          	ld	s1,-112(s0)
    8020021c:	f8843903          	ld	s2,-120(s0)
    80200220:	f8043983          	ld	s3,-128(s0)
    80200224:	000e0893          	mv	a7,t3
    80200228:	000e8813          	mv	a6,t4
    8020022c:	000f0513          	mv	a0,t5
    80200230:	000f8593          	mv	a1,t6
    80200234:	00028613          	mv	a2,t0
    80200238:	00048693          	mv	a3,s1
    8020023c:	00090713          	mv	a4,s2
    80200240:	00098793          	mv	a5,s3
    80200244:	00000073          	ecall
    80200248:	00050e93          	mv	t4,a0
    8020024c:	00058e13          	mv	t3,a1
    80200250:	fdd43023          	sd	t4,-64(s0)
    80200254:	fdc43423          	sd	t3,-56(s0)
		: [error] "=r"(ret.error), [value] "=r"(ret.value)
		: [eid] "r"(eid), [fid] "r"(fid), [arg0] "r"(arg0), [arg1] "r"(arg1),
		  [arg2] "r"(arg2), [arg3] "r"(arg3), [arg4] "r"(arg4), [arg5] "r"(arg5)
		: "memory","a0","a1","a2","a3","a4","a5","a6","a7"
		);
	return ret;
    80200258:	fc043783          	ld	a5,-64(s0)
    8020025c:	fcf43823          	sd	a5,-48(s0)
    80200260:	fc843783          	ld	a5,-56(s0)
    80200264:	fcf43c23          	sd	a5,-40(s0)
    80200268:	fd043703          	ld	a4,-48(s0)
    8020026c:	fd843783          	ld	a5,-40(s0)
    80200270:	00070313          	mv	t1,a4
    80200274:	00078393          	mv	t2,a5
    80200278:	00030713          	mv	a4,t1
    8020027c:	00038793          	mv	a5,t2
}
    80200280:	00070513          	mv	a0,a4
    80200284:	00078593          	mv	a1,a5
    80200288:	07813403          	ld	s0,120(sp)
    8020028c:	07013483          	ld	s1,112(sp)
    80200290:	06813903          	ld	s2,104(sp)
    80200294:	06013983          	ld	s3,96(sp)
    80200298:	08010113          	addi	sp,sp,128
    8020029c:	00008067          	ret

00000000802002a0 <sbi_debug_console_write_byte>:

struct sbiret sbi_debug_console_write_byte(uint8_t byte) {
    802002a0:	fe010113          	addi	sp,sp,-32
    802002a4:	00113c23          	sd	ra,24(sp)
    802002a8:	00813823          	sd	s0,16(sp)
    802002ac:	02010413          	addi	s0,sp,32
    802002b0:	00050793          	mv	a5,a0
    802002b4:	fef407a3          	sb	a5,-17(s0)
    sbi_ecall(SBI_DBCN_EXT, SBI_DBCN_WRITE_BYTE, byte, 0, 0, 0, 0, 0);
    802002b8:	fef44603          	lbu	a2,-17(s0)
    802002bc:	00000893          	li	a7,0
    802002c0:	00000813          	li	a6,0
    802002c4:	00000793          	li	a5,0
    802002c8:	00000713          	li	a4,0
    802002cc:	00000693          	li	a3,0
    802002d0:	00200593          	li	a1,2
    802002d4:	44424537          	lui	a0,0x44424
    802002d8:	34e50513          	addi	a0,a0,846 # 4442434e <_skernel-0x3bddbcb2>
    802002dc:	ef1ff0ef          	jal	802001cc <sbi_ecall>
}
    802002e0:	00000013          	nop
    802002e4:	00070513          	mv	a0,a4
    802002e8:	00078593          	mv	a1,a5
    802002ec:	01813083          	ld	ra,24(sp)
    802002f0:	01013403          	ld	s0,16(sp)
    802002f4:	02010113          	addi	sp,sp,32
    802002f8:	00008067          	ret

00000000802002fc <sbi_system_reset>:

struct sbiret sbi_system_reset(uint32_t reset_type, uint32_t reset_reason) {
    802002fc:	fe010113          	addi	sp,sp,-32
    80200300:	00113c23          	sd	ra,24(sp)
    80200304:	00813823          	sd	s0,16(sp)
    80200308:	02010413          	addi	s0,sp,32
    8020030c:	00050793          	mv	a5,a0
    80200310:	00058713          	mv	a4,a1
    80200314:	fef42623          	sw	a5,-20(s0)
    80200318:	00070793          	mv	a5,a4
    8020031c:	fef42423          	sw	a5,-24(s0)
    sbi_ecall(SBI_SRST_EXT, SBI_SRST, reset_type, reset_reason, 0, 0, 0, 0);
    80200320:	fec46603          	lwu	a2,-20(s0)
    80200324:	fe846683          	lwu	a3,-24(s0)
    80200328:	00000893          	li	a7,0
    8020032c:	00000813          	li	a6,0
    80200330:	00000793          	li	a5,0
    80200334:	00000713          	li	a4,0
    80200338:	00000593          	li	a1,0
    8020033c:	53525537          	lui	a0,0x53525
    80200340:	35450513          	addi	a0,a0,852 # 53525354 <_skernel-0x2ccdacac>
    80200344:	e89ff0ef          	jal	802001cc <sbi_ecall>
}
    80200348:	00000013          	nop
    8020034c:	00070513          	mv	a0,a4
    80200350:	00078593          	mv	a1,a5
    80200354:	01813083          	ld	ra,24(sp)
    80200358:	01013403          	ld	s0,16(sp)
    8020035c:	02010113          	addi	sp,sp,32
    80200360:	00008067          	ret

0000000080200364 <sbi_set_timer>:

struct sbiret sbi_set_timer(uint64_t stime_value) {
    80200364:	fe010113          	addi	sp,sp,-32
    80200368:	00113c23          	sd	ra,24(sp)
    8020036c:	00813823          	sd	s0,16(sp)
    80200370:	02010413          	addi	s0,sp,32
    80200374:	fea43423          	sd	a0,-24(s0)
    sbi_ecall(SBI_SET_TIMER_EXT, SBI_SET_TIMER, stime_value, 0, 0, 0, 0, 0);
    80200378:	00000893          	li	a7,0
    8020037c:	00000813          	li	a6,0
    80200380:	00000793          	li	a5,0
    80200384:	00000713          	li	a4,0
    80200388:	00000693          	li	a3,0
    8020038c:	fe843603          	ld	a2,-24(s0)
    80200390:	00000593          	li	a1,0
    80200394:	54495537          	lui	a0,0x54495
    80200398:	d4550513          	addi	a0,a0,-699 # 54494d45 <_skernel-0x2bd6b2bb>
    8020039c:	e31ff0ef          	jal	802001cc <sbi_ecall>
    802003a0:	00000013          	nop
    802003a4:	00070513          	mv	a0,a4
    802003a8:	00078593          	mv	a1,a5
    802003ac:	01813083          	ld	ra,24(sp)
    802003b0:	01013403          	ld	s0,16(sp)
    802003b4:	02010113          	addi	sp,sp,32
    802003b8:	00008067          	ret

00000000802003bc <trap_handler>:
#include "stdint.h"
#include "printk.h"

extern void clock_set_next_event();

void trap_handler(uint64_t scause, uint64_t sepc) {
    802003bc:	fe010113          	addi	sp,sp,-32
    802003c0:	00113c23          	sd	ra,24(sp)
    802003c4:	00813823          	sd	s0,16(sp)
    802003c8:	02010413          	addi	s0,sp,32
    802003cc:	fea43423          	sd	a0,-24(s0)
    802003d0:	feb43023          	sd	a1,-32(s0)
    // 通过 `scause` 判断trap类型
    if (scause >> 63){ 
    802003d4:	fe843783          	ld	a5,-24(s0)
    802003d8:	0207d263          	bgez	a5,802003fc <trap_handler+0x40>
        // 如果是interrupt 判断是否是timer interrupt
        if (scause % 8 == 5) { 
    802003dc:	fe843783          	ld	a5,-24(s0)
    802003e0:	0077f713          	andi	a4,a5,7
    802003e4:	00500793          	li	a5,5
    802003e8:	00f71a63          	bne	a4,a5,802003fc <trap_handler+0x40>
            // 如果是timer interrupt 则打印输出相关信息, 并通过 `clock_set_next_event()` 设置下一次时钟中断
            printk("[S] Supervisor Mode Timer Interrupt\n"); 
    802003ec:	00002517          	auipc	a0,0x2
    802003f0:	c1450513          	addi	a0,a0,-1004 # 80202000 <_srodata>
    802003f4:	741000ef          	jal	80201334 <printk>
            clock_set_next_event();
    802003f8:	d8dff0ef          	jal	80200184 <clock_set_next_event>
        }
    }
    // `clock_set_next_event()` 见 4.3.4 节
    // 其他interrupt / exception 可以直接忽略
    802003fc:	00000013          	nop
    80200400:	01813083          	ld	ra,24(sp)
    80200404:	01013403          	ld	s0,16(sp)
    80200408:	02010113          	addi	sp,sp,32
    8020040c:	00008067          	ret

0000000080200410 <start_kernel>:
#include "printk.h"
//#include "defs.h"

extern void test();

int start_kernel() {
    80200410:	ff010113          	addi	sp,sp,-16
    80200414:	00113423          	sd	ra,8(sp)
    80200418:	00813023          	sd	s0,0(sp)
    8020041c:	01010413          	addi	s0,sp,16
    printk("2024");
    80200420:	00002517          	auipc	a0,0x2
    80200424:	c0850513          	addi	a0,a0,-1016 # 80202028 <_srodata+0x28>
    80200428:	70d000ef          	jal	80201334 <printk>
    printk(" ZJU Operating System\n");
    8020042c:	00002517          	auipc	a0,0x2
    80200430:	c0450513          	addi	a0,a0,-1020 # 80202030 <_srodata+0x30>
    80200434:	701000ef          	jal	80201334 <printk>
    //uint64_t cr;
    //cr = csr_read(sstatus);
    //asm volatile("mv a6,%[cr]"::[cr]"r"(cr));
    //int cw = 30;
    //csr_write(sscratch, cw);
    test();
    80200438:	01c000ef          	jal	80200454 <test>
    return 0;
    8020043c:	00000793          	li	a5,0
}
    80200440:	00078513          	mv	a0,a5
    80200444:	00813083          	ld	ra,8(sp)
    80200448:	00013403          	ld	s0,0(sp)
    8020044c:	01010113          	addi	sp,sp,16
    80200450:	00008067          	ret

0000000080200454 <test>:
#include "printk.h"

void test() {
    80200454:	fe010113          	addi	sp,sp,-32
    80200458:	00113c23          	sd	ra,24(sp)
    8020045c:	00813823          	sd	s0,16(sp)
    80200460:	02010413          	addi	s0,sp,32
    int i = 0;
    80200464:	fe042623          	sw	zero,-20(s0)
    while (1) {
        if ((++i) % 320000000 == 0) {
    80200468:	fec42783          	lw	a5,-20(s0)
    8020046c:	0017879b          	addiw	a5,a5,1
    80200470:	fef42623          	sw	a5,-20(s0)
    80200474:	fec42783          	lw	a5,-20(s0)
    80200478:	00078713          	mv	a4,a5
    8020047c:	1312d7b7          	lui	a5,0x1312d
    80200480:	02f767bb          	remw	a5,a4,a5
    80200484:	0007879b          	sext.w	a5,a5
    80200488:	fe0790e3          	bnez	a5,80200468 <test+0x14>
            printk("kernel is running!\n");
    8020048c:	00002517          	auipc	a0,0x2
    80200490:	bbc50513          	addi	a0,a0,-1092 # 80202048 <_srodata+0x48>
    80200494:	6a1000ef          	jal	80201334 <printk>
            i = 0;
    80200498:	fe042623          	sw	zero,-20(s0)
        if ((++i) % 320000000 == 0) {
    8020049c:	fcdff06f          	j	80200468 <test+0x14>

00000000802004a0 <putc>:
// credit: 45gfg9 <45gfg9@45gfg9.net>

#include "printk.h"
#include "sbi.h"

int putc(int c) {
    802004a0:	fe010113          	addi	sp,sp,-32
    802004a4:	00113c23          	sd	ra,24(sp)
    802004a8:	00813823          	sd	s0,16(sp)
    802004ac:	02010413          	addi	s0,sp,32
    802004b0:	00050793          	mv	a5,a0
    802004b4:	fef42623          	sw	a5,-20(s0)
    sbi_debug_console_write_byte(c);
    802004b8:	fec42783          	lw	a5,-20(s0)
    802004bc:	0ff7f793          	zext.b	a5,a5
    802004c0:	00078513          	mv	a0,a5
    802004c4:	dddff0ef          	jal	802002a0 <sbi_debug_console_write_byte>
    return (char)c;
    802004c8:	fec42783          	lw	a5,-20(s0)
    802004cc:	0ff7f793          	zext.b	a5,a5
    802004d0:	0007879b          	sext.w	a5,a5
}
    802004d4:	00078513          	mv	a0,a5
    802004d8:	01813083          	ld	ra,24(sp)
    802004dc:	01013403          	ld	s0,16(sp)
    802004e0:	02010113          	addi	sp,sp,32
    802004e4:	00008067          	ret

00000000802004e8 <isspace>:
    bool sign;
    int width;
    int prec;
};

int isspace(int c) {
    802004e8:	fe010113          	addi	sp,sp,-32
    802004ec:	00813c23          	sd	s0,24(sp)
    802004f0:	02010413          	addi	s0,sp,32
    802004f4:	00050793          	mv	a5,a0
    802004f8:	fef42623          	sw	a5,-20(s0)
    return c == ' ' || (c >= '\t' && c <= '\r');
    802004fc:	fec42783          	lw	a5,-20(s0)
    80200500:	0007871b          	sext.w	a4,a5
    80200504:	02000793          	li	a5,32
    80200508:	02f70263          	beq	a4,a5,8020052c <isspace+0x44>
    8020050c:	fec42783          	lw	a5,-20(s0)
    80200510:	0007871b          	sext.w	a4,a5
    80200514:	00800793          	li	a5,8
    80200518:	00e7de63          	bge	a5,a4,80200534 <isspace+0x4c>
    8020051c:	fec42783          	lw	a5,-20(s0)
    80200520:	0007871b          	sext.w	a4,a5
    80200524:	00d00793          	li	a5,13
    80200528:	00e7c663          	blt	a5,a4,80200534 <isspace+0x4c>
    8020052c:	00100793          	li	a5,1
    80200530:	0080006f          	j	80200538 <isspace+0x50>
    80200534:	00000793          	li	a5,0
}
    80200538:	00078513          	mv	a0,a5
    8020053c:	01813403          	ld	s0,24(sp)
    80200540:	02010113          	addi	sp,sp,32
    80200544:	00008067          	ret

0000000080200548 <strtol>:

long strtol(const char *restrict nptr, char **restrict endptr, int base) {
    80200548:	fb010113          	addi	sp,sp,-80
    8020054c:	04113423          	sd	ra,72(sp)
    80200550:	04813023          	sd	s0,64(sp)
    80200554:	05010413          	addi	s0,sp,80
    80200558:	fca43423          	sd	a0,-56(s0)
    8020055c:	fcb43023          	sd	a1,-64(s0)
    80200560:	00060793          	mv	a5,a2
    80200564:	faf42e23          	sw	a5,-68(s0)
    long ret = 0;
    80200568:	fe043423          	sd	zero,-24(s0)
    bool neg = false;
    8020056c:	fe0403a3          	sb	zero,-25(s0)
    const char *p = nptr;
    80200570:	fc843783          	ld	a5,-56(s0)
    80200574:	fcf43c23          	sd	a5,-40(s0)

    while (isspace(*p)) {
    80200578:	0100006f          	j	80200588 <strtol+0x40>
        p++;
    8020057c:	fd843783          	ld	a5,-40(s0)
    80200580:	00178793          	addi	a5,a5,1 # 1312d001 <_skernel-0x6d0d2fff>
    80200584:	fcf43c23          	sd	a5,-40(s0)
    while (isspace(*p)) {
    80200588:	fd843783          	ld	a5,-40(s0)
    8020058c:	0007c783          	lbu	a5,0(a5)
    80200590:	0007879b          	sext.w	a5,a5
    80200594:	00078513          	mv	a0,a5
    80200598:	f51ff0ef          	jal	802004e8 <isspace>
    8020059c:	00050793          	mv	a5,a0
    802005a0:	fc079ee3          	bnez	a5,8020057c <strtol+0x34>
    }

    if (*p == '-') {
    802005a4:	fd843783          	ld	a5,-40(s0)
    802005a8:	0007c783          	lbu	a5,0(a5)
    802005ac:	00078713          	mv	a4,a5
    802005b0:	02d00793          	li	a5,45
    802005b4:	00f71e63          	bne	a4,a5,802005d0 <strtol+0x88>
        neg = true;
    802005b8:	00100793          	li	a5,1
    802005bc:	fef403a3          	sb	a5,-25(s0)
        p++;
    802005c0:	fd843783          	ld	a5,-40(s0)
    802005c4:	00178793          	addi	a5,a5,1
    802005c8:	fcf43c23          	sd	a5,-40(s0)
    802005cc:	0240006f          	j	802005f0 <strtol+0xa8>
    } else if (*p == '+') {
    802005d0:	fd843783          	ld	a5,-40(s0)
    802005d4:	0007c783          	lbu	a5,0(a5)
    802005d8:	00078713          	mv	a4,a5
    802005dc:	02b00793          	li	a5,43
    802005e0:	00f71863          	bne	a4,a5,802005f0 <strtol+0xa8>
        p++;
    802005e4:	fd843783          	ld	a5,-40(s0)
    802005e8:	00178793          	addi	a5,a5,1
    802005ec:	fcf43c23          	sd	a5,-40(s0)
    }

    if (base == 0) {
    802005f0:	fbc42783          	lw	a5,-68(s0)
    802005f4:	0007879b          	sext.w	a5,a5
    802005f8:	06079c63          	bnez	a5,80200670 <strtol+0x128>
        if (*p == '0') {
    802005fc:	fd843783          	ld	a5,-40(s0)
    80200600:	0007c783          	lbu	a5,0(a5)
    80200604:	00078713          	mv	a4,a5
    80200608:	03000793          	li	a5,48
    8020060c:	04f71e63          	bne	a4,a5,80200668 <strtol+0x120>
            p++;
    80200610:	fd843783          	ld	a5,-40(s0)
    80200614:	00178793          	addi	a5,a5,1
    80200618:	fcf43c23          	sd	a5,-40(s0)
            if (*p == 'x' || *p == 'X') {
    8020061c:	fd843783          	ld	a5,-40(s0)
    80200620:	0007c783          	lbu	a5,0(a5)
    80200624:	00078713          	mv	a4,a5
    80200628:	07800793          	li	a5,120
    8020062c:	00f70c63          	beq	a4,a5,80200644 <strtol+0xfc>
    80200630:	fd843783          	ld	a5,-40(s0)
    80200634:	0007c783          	lbu	a5,0(a5)
    80200638:	00078713          	mv	a4,a5
    8020063c:	05800793          	li	a5,88
    80200640:	00f71e63          	bne	a4,a5,8020065c <strtol+0x114>
                base = 16;
    80200644:	01000793          	li	a5,16
    80200648:	faf42e23          	sw	a5,-68(s0)
                p++;
    8020064c:	fd843783          	ld	a5,-40(s0)
    80200650:	00178793          	addi	a5,a5,1
    80200654:	fcf43c23          	sd	a5,-40(s0)
    80200658:	0180006f          	j	80200670 <strtol+0x128>
            } else {
                base = 8;
    8020065c:	00800793          	li	a5,8
    80200660:	faf42e23          	sw	a5,-68(s0)
    80200664:	00c0006f          	j	80200670 <strtol+0x128>
            }
        } else {
            base = 10;
    80200668:	00a00793          	li	a5,10
    8020066c:	faf42e23          	sw	a5,-68(s0)
        }
    }

    while (1) {
        int digit;
        if (*p >= '0' && *p <= '9') {
    80200670:	fd843783          	ld	a5,-40(s0)
    80200674:	0007c783          	lbu	a5,0(a5)
    80200678:	00078713          	mv	a4,a5
    8020067c:	02f00793          	li	a5,47
    80200680:	02e7f863          	bgeu	a5,a4,802006b0 <strtol+0x168>
    80200684:	fd843783          	ld	a5,-40(s0)
    80200688:	0007c783          	lbu	a5,0(a5)
    8020068c:	00078713          	mv	a4,a5
    80200690:	03900793          	li	a5,57
    80200694:	00e7ee63          	bltu	a5,a4,802006b0 <strtol+0x168>
            digit = *p - '0';
    80200698:	fd843783          	ld	a5,-40(s0)
    8020069c:	0007c783          	lbu	a5,0(a5)
    802006a0:	0007879b          	sext.w	a5,a5
    802006a4:	fd07879b          	addiw	a5,a5,-48
    802006a8:	fcf42a23          	sw	a5,-44(s0)
    802006ac:	0800006f          	j	8020072c <strtol+0x1e4>
        } else if (*p >= 'a' && *p <= 'z') {
    802006b0:	fd843783          	ld	a5,-40(s0)
    802006b4:	0007c783          	lbu	a5,0(a5)
    802006b8:	00078713          	mv	a4,a5
    802006bc:	06000793          	li	a5,96
    802006c0:	02e7f863          	bgeu	a5,a4,802006f0 <strtol+0x1a8>
    802006c4:	fd843783          	ld	a5,-40(s0)
    802006c8:	0007c783          	lbu	a5,0(a5)
    802006cc:	00078713          	mv	a4,a5
    802006d0:	07a00793          	li	a5,122
    802006d4:	00e7ee63          	bltu	a5,a4,802006f0 <strtol+0x1a8>
            digit = *p - ('a' - 10);
    802006d8:	fd843783          	ld	a5,-40(s0)
    802006dc:	0007c783          	lbu	a5,0(a5)
    802006e0:	0007879b          	sext.w	a5,a5
    802006e4:	fa97879b          	addiw	a5,a5,-87
    802006e8:	fcf42a23          	sw	a5,-44(s0)
    802006ec:	0400006f          	j	8020072c <strtol+0x1e4>
        } else if (*p >= 'A' && *p <= 'Z') {
    802006f0:	fd843783          	ld	a5,-40(s0)
    802006f4:	0007c783          	lbu	a5,0(a5)
    802006f8:	00078713          	mv	a4,a5
    802006fc:	04000793          	li	a5,64
    80200700:	06e7f863          	bgeu	a5,a4,80200770 <strtol+0x228>
    80200704:	fd843783          	ld	a5,-40(s0)
    80200708:	0007c783          	lbu	a5,0(a5)
    8020070c:	00078713          	mv	a4,a5
    80200710:	05a00793          	li	a5,90
    80200714:	04e7ee63          	bltu	a5,a4,80200770 <strtol+0x228>
            digit = *p - ('A' - 10);
    80200718:	fd843783          	ld	a5,-40(s0)
    8020071c:	0007c783          	lbu	a5,0(a5)
    80200720:	0007879b          	sext.w	a5,a5
    80200724:	fc97879b          	addiw	a5,a5,-55
    80200728:	fcf42a23          	sw	a5,-44(s0)
        } else {
            break;
        }

        if (digit >= base) {
    8020072c:	fd442783          	lw	a5,-44(s0)
    80200730:	00078713          	mv	a4,a5
    80200734:	fbc42783          	lw	a5,-68(s0)
    80200738:	0007071b          	sext.w	a4,a4
    8020073c:	0007879b          	sext.w	a5,a5
    80200740:	02f75663          	bge	a4,a5,8020076c <strtol+0x224>
            break;
        }

        ret = ret * base + digit;
    80200744:	fbc42703          	lw	a4,-68(s0)
    80200748:	fe843783          	ld	a5,-24(s0)
    8020074c:	02f70733          	mul	a4,a4,a5
    80200750:	fd442783          	lw	a5,-44(s0)
    80200754:	00f707b3          	add	a5,a4,a5
    80200758:	fef43423          	sd	a5,-24(s0)
        p++;
    8020075c:	fd843783          	ld	a5,-40(s0)
    80200760:	00178793          	addi	a5,a5,1
    80200764:	fcf43c23          	sd	a5,-40(s0)
    while (1) {
    80200768:	f09ff06f          	j	80200670 <strtol+0x128>
            break;
    8020076c:	00000013          	nop
    }

    if (endptr) {
    80200770:	fc043783          	ld	a5,-64(s0)
    80200774:	00078863          	beqz	a5,80200784 <strtol+0x23c>
        *endptr = (char *)p;
    80200778:	fc043783          	ld	a5,-64(s0)
    8020077c:	fd843703          	ld	a4,-40(s0)
    80200780:	00e7b023          	sd	a4,0(a5)
    }

    return neg ? -ret : ret;
    80200784:	fe744783          	lbu	a5,-25(s0)
    80200788:	0ff7f793          	zext.b	a5,a5
    8020078c:	00078863          	beqz	a5,8020079c <strtol+0x254>
    80200790:	fe843783          	ld	a5,-24(s0)
    80200794:	40f007b3          	neg	a5,a5
    80200798:	0080006f          	j	802007a0 <strtol+0x258>
    8020079c:	fe843783          	ld	a5,-24(s0)
}
    802007a0:	00078513          	mv	a0,a5
    802007a4:	04813083          	ld	ra,72(sp)
    802007a8:	04013403          	ld	s0,64(sp)
    802007ac:	05010113          	addi	sp,sp,80
    802007b0:	00008067          	ret

00000000802007b4 <puts_wo_nl>:

// puts without newline
static int puts_wo_nl(int (*putch)(int), const char *s) {
    802007b4:	fd010113          	addi	sp,sp,-48
    802007b8:	02113423          	sd	ra,40(sp)
    802007bc:	02813023          	sd	s0,32(sp)
    802007c0:	03010413          	addi	s0,sp,48
    802007c4:	fca43c23          	sd	a0,-40(s0)
    802007c8:	fcb43823          	sd	a1,-48(s0)
    if (!s) {
    802007cc:	fd043783          	ld	a5,-48(s0)
    802007d0:	00079863          	bnez	a5,802007e0 <puts_wo_nl+0x2c>
        s = "(null)";
    802007d4:	00002797          	auipc	a5,0x2
    802007d8:	88c78793          	addi	a5,a5,-1908 # 80202060 <_srodata+0x60>
    802007dc:	fcf43823          	sd	a5,-48(s0)
    }
    const char *p = s;
    802007e0:	fd043783          	ld	a5,-48(s0)
    802007e4:	fef43423          	sd	a5,-24(s0)
    while (*p) {
    802007e8:	0240006f          	j	8020080c <puts_wo_nl+0x58>
        putch(*p++);
    802007ec:	fe843783          	ld	a5,-24(s0)
    802007f0:	00178713          	addi	a4,a5,1
    802007f4:	fee43423          	sd	a4,-24(s0)
    802007f8:	0007c783          	lbu	a5,0(a5)
    802007fc:	0007871b          	sext.w	a4,a5
    80200800:	fd843783          	ld	a5,-40(s0)
    80200804:	00070513          	mv	a0,a4
    80200808:	000780e7          	jalr	a5
    while (*p) {
    8020080c:	fe843783          	ld	a5,-24(s0)
    80200810:	0007c783          	lbu	a5,0(a5)
    80200814:	fc079ce3          	bnez	a5,802007ec <puts_wo_nl+0x38>
    }
    return p - s;
    80200818:	fe843703          	ld	a4,-24(s0)
    8020081c:	fd043783          	ld	a5,-48(s0)
    80200820:	40f707b3          	sub	a5,a4,a5
    80200824:	0007879b          	sext.w	a5,a5
}
    80200828:	00078513          	mv	a0,a5
    8020082c:	02813083          	ld	ra,40(sp)
    80200830:	02013403          	ld	s0,32(sp)
    80200834:	03010113          	addi	sp,sp,48
    80200838:	00008067          	ret

000000008020083c <print_dec_int>:

static int print_dec_int(int (*putch)(int), unsigned long num, bool is_signed, struct fmt_flags *flags) {
    8020083c:	f9010113          	addi	sp,sp,-112
    80200840:	06113423          	sd	ra,104(sp)
    80200844:	06813023          	sd	s0,96(sp)
    80200848:	07010413          	addi	s0,sp,112
    8020084c:	faa43423          	sd	a0,-88(s0)
    80200850:	fab43023          	sd	a1,-96(s0)
    80200854:	00060793          	mv	a5,a2
    80200858:	f8d43823          	sd	a3,-112(s0)
    8020085c:	f8f40fa3          	sb	a5,-97(s0)
    if (is_signed && num == 0x8000000000000000UL) {
    80200860:	f9f44783          	lbu	a5,-97(s0)
    80200864:	0ff7f793          	zext.b	a5,a5
    80200868:	02078663          	beqz	a5,80200894 <print_dec_int+0x58>
    8020086c:	fa043703          	ld	a4,-96(s0)
    80200870:	fff00793          	li	a5,-1
    80200874:	03f79793          	slli	a5,a5,0x3f
    80200878:	00f71e63          	bne	a4,a5,80200894 <print_dec_int+0x58>
        // special case for 0x8000000000000000
        return puts_wo_nl(putch, "-9223372036854775808");
    8020087c:	00001597          	auipc	a1,0x1
    80200880:	7ec58593          	addi	a1,a1,2028 # 80202068 <_srodata+0x68>
    80200884:	fa843503          	ld	a0,-88(s0)
    80200888:	f2dff0ef          	jal	802007b4 <puts_wo_nl>
    8020088c:	00050793          	mv	a5,a0
    80200890:	2a00006f          	j	80200b30 <print_dec_int+0x2f4>
    }

    if (flags->prec == 0 && num == 0) {
    80200894:	f9043783          	ld	a5,-112(s0)
    80200898:	00c7a783          	lw	a5,12(a5)
    8020089c:	00079a63          	bnez	a5,802008b0 <print_dec_int+0x74>
    802008a0:	fa043783          	ld	a5,-96(s0)
    802008a4:	00079663          	bnez	a5,802008b0 <print_dec_int+0x74>
        return 0;
    802008a8:	00000793          	li	a5,0
    802008ac:	2840006f          	j	80200b30 <print_dec_int+0x2f4>
    }

    bool neg = false;
    802008b0:	fe0407a3          	sb	zero,-17(s0)

    if (is_signed && (long)num < 0) {
    802008b4:	f9f44783          	lbu	a5,-97(s0)
    802008b8:	0ff7f793          	zext.b	a5,a5
    802008bc:	02078063          	beqz	a5,802008dc <print_dec_int+0xa0>
    802008c0:	fa043783          	ld	a5,-96(s0)
    802008c4:	0007dc63          	bgez	a5,802008dc <print_dec_int+0xa0>
        neg = true;
    802008c8:	00100793          	li	a5,1
    802008cc:	fef407a3          	sb	a5,-17(s0)
        num = -num;
    802008d0:	fa043783          	ld	a5,-96(s0)
    802008d4:	40f007b3          	neg	a5,a5
    802008d8:	faf43023          	sd	a5,-96(s0)
    }

    char buf[20];
    int decdigits = 0;
    802008dc:	fe042423          	sw	zero,-24(s0)

    bool has_sign_char = is_signed && (neg || flags->sign || flags->spaceflag);
    802008e0:	f9f44783          	lbu	a5,-97(s0)
    802008e4:	0ff7f793          	zext.b	a5,a5
    802008e8:	02078863          	beqz	a5,80200918 <print_dec_int+0xdc>
    802008ec:	fef44783          	lbu	a5,-17(s0)
    802008f0:	0ff7f793          	zext.b	a5,a5
    802008f4:	00079e63          	bnez	a5,80200910 <print_dec_int+0xd4>
    802008f8:	f9043783          	ld	a5,-112(s0)
    802008fc:	0057c783          	lbu	a5,5(a5)
    80200900:	00079863          	bnez	a5,80200910 <print_dec_int+0xd4>
    80200904:	f9043783          	ld	a5,-112(s0)
    80200908:	0047c783          	lbu	a5,4(a5)
    8020090c:	00078663          	beqz	a5,80200918 <print_dec_int+0xdc>
    80200910:	00100793          	li	a5,1
    80200914:	0080006f          	j	8020091c <print_dec_int+0xe0>
    80200918:	00000793          	li	a5,0
    8020091c:	fcf40ba3          	sb	a5,-41(s0)
    80200920:	fd744783          	lbu	a5,-41(s0)
    80200924:	0017f793          	andi	a5,a5,1
    80200928:	fcf40ba3          	sb	a5,-41(s0)

    do {
        buf[decdigits++] = num % 10 + '0';
    8020092c:	fa043703          	ld	a4,-96(s0)
    80200930:	00a00793          	li	a5,10
    80200934:	02f777b3          	remu	a5,a4,a5
    80200938:	0ff7f713          	zext.b	a4,a5
    8020093c:	fe842783          	lw	a5,-24(s0)
    80200940:	0017869b          	addiw	a3,a5,1
    80200944:	fed42423          	sw	a3,-24(s0)
    80200948:	0307071b          	addiw	a4,a4,48
    8020094c:	0ff77713          	zext.b	a4,a4
    80200950:	ff078793          	addi	a5,a5,-16
    80200954:	008787b3          	add	a5,a5,s0
    80200958:	fce78423          	sb	a4,-56(a5)
        num /= 10;
    8020095c:	fa043703          	ld	a4,-96(s0)
    80200960:	00a00793          	li	a5,10
    80200964:	02f757b3          	divu	a5,a4,a5
    80200968:	faf43023          	sd	a5,-96(s0)
    } while (num);
    8020096c:	fa043783          	ld	a5,-96(s0)
    80200970:	fa079ee3          	bnez	a5,8020092c <print_dec_int+0xf0>

    if (flags->prec == -1 && flags->zeroflag) {
    80200974:	f9043783          	ld	a5,-112(s0)
    80200978:	00c7a783          	lw	a5,12(a5)
    8020097c:	00078713          	mv	a4,a5
    80200980:	fff00793          	li	a5,-1
    80200984:	02f71063          	bne	a4,a5,802009a4 <print_dec_int+0x168>
    80200988:	f9043783          	ld	a5,-112(s0)
    8020098c:	0037c783          	lbu	a5,3(a5)
    80200990:	00078a63          	beqz	a5,802009a4 <print_dec_int+0x168>
        flags->prec = flags->width;
    80200994:	f9043783          	ld	a5,-112(s0)
    80200998:	0087a703          	lw	a4,8(a5)
    8020099c:	f9043783          	ld	a5,-112(s0)
    802009a0:	00e7a623          	sw	a4,12(a5)
    }

    int written = 0;
    802009a4:	fe042223          	sw	zero,-28(s0)

    for (int i = flags->width - __MAX(decdigits, flags->prec) - has_sign_char; i > 0; i--) {
    802009a8:	f9043783          	ld	a5,-112(s0)
    802009ac:	0087a703          	lw	a4,8(a5)
    802009b0:	fe842783          	lw	a5,-24(s0)
    802009b4:	fcf42823          	sw	a5,-48(s0)
    802009b8:	f9043783          	ld	a5,-112(s0)
    802009bc:	00c7a783          	lw	a5,12(a5)
    802009c0:	fcf42623          	sw	a5,-52(s0)
    802009c4:	fd042783          	lw	a5,-48(s0)
    802009c8:	00078593          	mv	a1,a5
    802009cc:	fcc42783          	lw	a5,-52(s0)
    802009d0:	00078613          	mv	a2,a5
    802009d4:	0006069b          	sext.w	a3,a2
    802009d8:	0005879b          	sext.w	a5,a1
    802009dc:	00f6d463          	bge	a3,a5,802009e4 <print_dec_int+0x1a8>
    802009e0:	00058613          	mv	a2,a1
    802009e4:	0006079b          	sext.w	a5,a2
    802009e8:	40f707bb          	subw	a5,a4,a5
    802009ec:	0007871b          	sext.w	a4,a5
    802009f0:	fd744783          	lbu	a5,-41(s0)
    802009f4:	0007879b          	sext.w	a5,a5
    802009f8:	40f707bb          	subw	a5,a4,a5
    802009fc:	fef42023          	sw	a5,-32(s0)
    80200a00:	0280006f          	j	80200a28 <print_dec_int+0x1ec>
        putch(' ');
    80200a04:	fa843783          	ld	a5,-88(s0)
    80200a08:	02000513          	li	a0,32
    80200a0c:	000780e7          	jalr	a5
        ++written;
    80200a10:	fe442783          	lw	a5,-28(s0)
    80200a14:	0017879b          	addiw	a5,a5,1
    80200a18:	fef42223          	sw	a5,-28(s0)
    for (int i = flags->width - __MAX(decdigits, flags->prec) - has_sign_char; i > 0; i--) {
    80200a1c:	fe042783          	lw	a5,-32(s0)
    80200a20:	fff7879b          	addiw	a5,a5,-1
    80200a24:	fef42023          	sw	a5,-32(s0)
    80200a28:	fe042783          	lw	a5,-32(s0)
    80200a2c:	0007879b          	sext.w	a5,a5
    80200a30:	fcf04ae3          	bgtz	a5,80200a04 <print_dec_int+0x1c8>
    }

    if (has_sign_char) {
    80200a34:	fd744783          	lbu	a5,-41(s0)
    80200a38:	0ff7f793          	zext.b	a5,a5
    80200a3c:	04078463          	beqz	a5,80200a84 <print_dec_int+0x248>
        putch(neg ? '-' : flags->sign ? '+' : ' ');
    80200a40:	fef44783          	lbu	a5,-17(s0)
    80200a44:	0ff7f793          	zext.b	a5,a5
    80200a48:	00078663          	beqz	a5,80200a54 <print_dec_int+0x218>
    80200a4c:	02d00793          	li	a5,45
    80200a50:	01c0006f          	j	80200a6c <print_dec_int+0x230>
    80200a54:	f9043783          	ld	a5,-112(s0)
    80200a58:	0057c783          	lbu	a5,5(a5)
    80200a5c:	00078663          	beqz	a5,80200a68 <print_dec_int+0x22c>
    80200a60:	02b00793          	li	a5,43
    80200a64:	0080006f          	j	80200a6c <print_dec_int+0x230>
    80200a68:	02000793          	li	a5,32
    80200a6c:	fa843703          	ld	a4,-88(s0)
    80200a70:	00078513          	mv	a0,a5
    80200a74:	000700e7          	jalr	a4
        ++written;
    80200a78:	fe442783          	lw	a5,-28(s0)
    80200a7c:	0017879b          	addiw	a5,a5,1
    80200a80:	fef42223          	sw	a5,-28(s0)
    }

    for (int i = decdigits; i < flags->prec - has_sign_char; i++) {
    80200a84:	fe842783          	lw	a5,-24(s0)
    80200a88:	fcf42e23          	sw	a5,-36(s0)
    80200a8c:	0280006f          	j	80200ab4 <print_dec_int+0x278>
        putch('0');
    80200a90:	fa843783          	ld	a5,-88(s0)
    80200a94:	03000513          	li	a0,48
    80200a98:	000780e7          	jalr	a5
        ++written;
    80200a9c:	fe442783          	lw	a5,-28(s0)
    80200aa0:	0017879b          	addiw	a5,a5,1
    80200aa4:	fef42223          	sw	a5,-28(s0)
    for (int i = decdigits; i < flags->prec - has_sign_char; i++) {
    80200aa8:	fdc42783          	lw	a5,-36(s0)
    80200aac:	0017879b          	addiw	a5,a5,1
    80200ab0:	fcf42e23          	sw	a5,-36(s0)
    80200ab4:	f9043783          	ld	a5,-112(s0)
    80200ab8:	00c7a703          	lw	a4,12(a5)
    80200abc:	fd744783          	lbu	a5,-41(s0)
    80200ac0:	0007879b          	sext.w	a5,a5
    80200ac4:	40f707bb          	subw	a5,a4,a5
    80200ac8:	0007871b          	sext.w	a4,a5
    80200acc:	fdc42783          	lw	a5,-36(s0)
    80200ad0:	0007879b          	sext.w	a5,a5
    80200ad4:	fae7cee3          	blt	a5,a4,80200a90 <print_dec_int+0x254>
    }

    for (int i = decdigits - 1; i >= 0; i--) {
    80200ad8:	fe842783          	lw	a5,-24(s0)
    80200adc:	fff7879b          	addiw	a5,a5,-1
    80200ae0:	fcf42c23          	sw	a5,-40(s0)
    80200ae4:	03c0006f          	j	80200b20 <print_dec_int+0x2e4>
        putch(buf[i]);
    80200ae8:	fd842783          	lw	a5,-40(s0)
    80200aec:	ff078793          	addi	a5,a5,-16
    80200af0:	008787b3          	add	a5,a5,s0
    80200af4:	fc87c783          	lbu	a5,-56(a5)
    80200af8:	0007871b          	sext.w	a4,a5
    80200afc:	fa843783          	ld	a5,-88(s0)
    80200b00:	00070513          	mv	a0,a4
    80200b04:	000780e7          	jalr	a5
        ++written;
    80200b08:	fe442783          	lw	a5,-28(s0)
    80200b0c:	0017879b          	addiw	a5,a5,1
    80200b10:	fef42223          	sw	a5,-28(s0)
    for (int i = decdigits - 1; i >= 0; i--) {
    80200b14:	fd842783          	lw	a5,-40(s0)
    80200b18:	fff7879b          	addiw	a5,a5,-1
    80200b1c:	fcf42c23          	sw	a5,-40(s0)
    80200b20:	fd842783          	lw	a5,-40(s0)
    80200b24:	0007879b          	sext.w	a5,a5
    80200b28:	fc07d0e3          	bgez	a5,80200ae8 <print_dec_int+0x2ac>
    }

    return written;
    80200b2c:	fe442783          	lw	a5,-28(s0)
}
    80200b30:	00078513          	mv	a0,a5
    80200b34:	06813083          	ld	ra,104(sp)
    80200b38:	06013403          	ld	s0,96(sp)
    80200b3c:	07010113          	addi	sp,sp,112
    80200b40:	00008067          	ret

0000000080200b44 <vprintfmt>:

int vprintfmt(int (*putch)(int), const char *fmt, va_list vl) {
    80200b44:	f4010113          	addi	sp,sp,-192
    80200b48:	0a113c23          	sd	ra,184(sp)
    80200b4c:	0a813823          	sd	s0,176(sp)
    80200b50:	0c010413          	addi	s0,sp,192
    80200b54:	f4a43c23          	sd	a0,-168(s0)
    80200b58:	f4b43823          	sd	a1,-176(s0)
    80200b5c:	f4c43423          	sd	a2,-184(s0)
    static const char lowerxdigits[] = "0123456789abcdef";
    static const char upperxdigits[] = "0123456789ABCDEF";

    struct fmt_flags flags = {};
    80200b60:	f8043023          	sd	zero,-128(s0)
    80200b64:	f8043423          	sd	zero,-120(s0)

    int written = 0;
    80200b68:	fe042623          	sw	zero,-20(s0)

    for (; *fmt; fmt++) {
    80200b6c:	7a40006f          	j	80201310 <vprintfmt+0x7cc>
        if (flags.in_format) {
    80200b70:	f8044783          	lbu	a5,-128(s0)
    80200b74:	72078e63          	beqz	a5,802012b0 <vprintfmt+0x76c>
            if (*fmt == '#') {
    80200b78:	f5043783          	ld	a5,-176(s0)
    80200b7c:	0007c783          	lbu	a5,0(a5)
    80200b80:	00078713          	mv	a4,a5
    80200b84:	02300793          	li	a5,35
    80200b88:	00f71863          	bne	a4,a5,80200b98 <vprintfmt+0x54>
                flags.sharpflag = true;
    80200b8c:	00100793          	li	a5,1
    80200b90:	f8f40123          	sb	a5,-126(s0)
    80200b94:	7700006f          	j	80201304 <vprintfmt+0x7c0>
            } else if (*fmt == '0') {
    80200b98:	f5043783          	ld	a5,-176(s0)
    80200b9c:	0007c783          	lbu	a5,0(a5)
    80200ba0:	00078713          	mv	a4,a5
    80200ba4:	03000793          	li	a5,48
    80200ba8:	00f71863          	bne	a4,a5,80200bb8 <vprintfmt+0x74>
                flags.zeroflag = true;
    80200bac:	00100793          	li	a5,1
    80200bb0:	f8f401a3          	sb	a5,-125(s0)
    80200bb4:	7500006f          	j	80201304 <vprintfmt+0x7c0>
            } else if (*fmt == 'l' || *fmt == 'z' || *fmt == 't' || *fmt == 'j') {
    80200bb8:	f5043783          	ld	a5,-176(s0)
    80200bbc:	0007c783          	lbu	a5,0(a5)
    80200bc0:	00078713          	mv	a4,a5
    80200bc4:	06c00793          	li	a5,108
    80200bc8:	04f70063          	beq	a4,a5,80200c08 <vprintfmt+0xc4>
    80200bcc:	f5043783          	ld	a5,-176(s0)
    80200bd0:	0007c783          	lbu	a5,0(a5)
    80200bd4:	00078713          	mv	a4,a5
    80200bd8:	07a00793          	li	a5,122
    80200bdc:	02f70663          	beq	a4,a5,80200c08 <vprintfmt+0xc4>
    80200be0:	f5043783          	ld	a5,-176(s0)
    80200be4:	0007c783          	lbu	a5,0(a5)
    80200be8:	00078713          	mv	a4,a5
    80200bec:	07400793          	li	a5,116
    80200bf0:	00f70c63          	beq	a4,a5,80200c08 <vprintfmt+0xc4>
    80200bf4:	f5043783          	ld	a5,-176(s0)
    80200bf8:	0007c783          	lbu	a5,0(a5)
    80200bfc:	00078713          	mv	a4,a5
    80200c00:	06a00793          	li	a5,106
    80200c04:	00f71863          	bne	a4,a5,80200c14 <vprintfmt+0xd0>
                // l: long, z: size_t, t: ptrdiff_t, j: intmax_t
                flags.longflag = true;
    80200c08:	00100793          	li	a5,1
    80200c0c:	f8f400a3          	sb	a5,-127(s0)
    80200c10:	6f40006f          	j	80201304 <vprintfmt+0x7c0>
            } else if (*fmt == '+') {
    80200c14:	f5043783          	ld	a5,-176(s0)
    80200c18:	0007c783          	lbu	a5,0(a5)
    80200c1c:	00078713          	mv	a4,a5
    80200c20:	02b00793          	li	a5,43
    80200c24:	00f71863          	bne	a4,a5,80200c34 <vprintfmt+0xf0>
                flags.sign = true;
    80200c28:	00100793          	li	a5,1
    80200c2c:	f8f402a3          	sb	a5,-123(s0)
    80200c30:	6d40006f          	j	80201304 <vprintfmt+0x7c0>
            } else if (*fmt == ' ') {
    80200c34:	f5043783          	ld	a5,-176(s0)
    80200c38:	0007c783          	lbu	a5,0(a5)
    80200c3c:	00078713          	mv	a4,a5
    80200c40:	02000793          	li	a5,32
    80200c44:	00f71863          	bne	a4,a5,80200c54 <vprintfmt+0x110>
                flags.spaceflag = true;
    80200c48:	00100793          	li	a5,1
    80200c4c:	f8f40223          	sb	a5,-124(s0)
    80200c50:	6b40006f          	j	80201304 <vprintfmt+0x7c0>
            } else if (*fmt == '*') {
    80200c54:	f5043783          	ld	a5,-176(s0)
    80200c58:	0007c783          	lbu	a5,0(a5)
    80200c5c:	00078713          	mv	a4,a5
    80200c60:	02a00793          	li	a5,42
    80200c64:	00f71e63          	bne	a4,a5,80200c80 <vprintfmt+0x13c>
                flags.width = va_arg(vl, int);
    80200c68:	f4843783          	ld	a5,-184(s0)
    80200c6c:	00878713          	addi	a4,a5,8
    80200c70:	f4e43423          	sd	a4,-184(s0)
    80200c74:	0007a783          	lw	a5,0(a5)
    80200c78:	f8f42423          	sw	a5,-120(s0)
    80200c7c:	6880006f          	j	80201304 <vprintfmt+0x7c0>
            } else if (*fmt >= '1' && *fmt <= '9') {
    80200c80:	f5043783          	ld	a5,-176(s0)
    80200c84:	0007c783          	lbu	a5,0(a5)
    80200c88:	00078713          	mv	a4,a5
    80200c8c:	03000793          	li	a5,48
    80200c90:	04e7f663          	bgeu	a5,a4,80200cdc <vprintfmt+0x198>
    80200c94:	f5043783          	ld	a5,-176(s0)
    80200c98:	0007c783          	lbu	a5,0(a5)
    80200c9c:	00078713          	mv	a4,a5
    80200ca0:	03900793          	li	a5,57
    80200ca4:	02e7ec63          	bltu	a5,a4,80200cdc <vprintfmt+0x198>
                flags.width = strtol(fmt, (char **)&fmt, 10);
    80200ca8:	f5043783          	ld	a5,-176(s0)
    80200cac:	f5040713          	addi	a4,s0,-176
    80200cb0:	00a00613          	li	a2,10
    80200cb4:	00070593          	mv	a1,a4
    80200cb8:	00078513          	mv	a0,a5
    80200cbc:	88dff0ef          	jal	80200548 <strtol>
    80200cc0:	00050793          	mv	a5,a0
    80200cc4:	0007879b          	sext.w	a5,a5
    80200cc8:	f8f42423          	sw	a5,-120(s0)
                fmt--;
    80200ccc:	f5043783          	ld	a5,-176(s0)
    80200cd0:	fff78793          	addi	a5,a5,-1
    80200cd4:	f4f43823          	sd	a5,-176(s0)
    80200cd8:	62c0006f          	j	80201304 <vprintfmt+0x7c0>
            } else if (*fmt == '.') {
    80200cdc:	f5043783          	ld	a5,-176(s0)
    80200ce0:	0007c783          	lbu	a5,0(a5)
    80200ce4:	00078713          	mv	a4,a5
    80200ce8:	02e00793          	li	a5,46
    80200cec:	06f71863          	bne	a4,a5,80200d5c <vprintfmt+0x218>
                fmt++;
    80200cf0:	f5043783          	ld	a5,-176(s0)
    80200cf4:	00178793          	addi	a5,a5,1
    80200cf8:	f4f43823          	sd	a5,-176(s0)
                if (*fmt == '*') {
    80200cfc:	f5043783          	ld	a5,-176(s0)
    80200d00:	0007c783          	lbu	a5,0(a5)
    80200d04:	00078713          	mv	a4,a5
    80200d08:	02a00793          	li	a5,42
    80200d0c:	00f71e63          	bne	a4,a5,80200d28 <vprintfmt+0x1e4>
                    flags.prec = va_arg(vl, int);
    80200d10:	f4843783          	ld	a5,-184(s0)
    80200d14:	00878713          	addi	a4,a5,8
    80200d18:	f4e43423          	sd	a4,-184(s0)
    80200d1c:	0007a783          	lw	a5,0(a5)
    80200d20:	f8f42623          	sw	a5,-116(s0)
    80200d24:	5e00006f          	j	80201304 <vprintfmt+0x7c0>
                } else {
                    flags.prec = strtol(fmt, (char **)&fmt, 10);
    80200d28:	f5043783          	ld	a5,-176(s0)
    80200d2c:	f5040713          	addi	a4,s0,-176
    80200d30:	00a00613          	li	a2,10
    80200d34:	00070593          	mv	a1,a4
    80200d38:	00078513          	mv	a0,a5
    80200d3c:	80dff0ef          	jal	80200548 <strtol>
    80200d40:	00050793          	mv	a5,a0
    80200d44:	0007879b          	sext.w	a5,a5
    80200d48:	f8f42623          	sw	a5,-116(s0)
                    fmt--;
    80200d4c:	f5043783          	ld	a5,-176(s0)
    80200d50:	fff78793          	addi	a5,a5,-1
    80200d54:	f4f43823          	sd	a5,-176(s0)
    80200d58:	5ac0006f          	j	80201304 <vprintfmt+0x7c0>
                }
            } else if (*fmt == 'x' || *fmt == 'X' || *fmt == 'p') {
    80200d5c:	f5043783          	ld	a5,-176(s0)
    80200d60:	0007c783          	lbu	a5,0(a5)
    80200d64:	00078713          	mv	a4,a5
    80200d68:	07800793          	li	a5,120
    80200d6c:	02f70663          	beq	a4,a5,80200d98 <vprintfmt+0x254>
    80200d70:	f5043783          	ld	a5,-176(s0)
    80200d74:	0007c783          	lbu	a5,0(a5)
    80200d78:	00078713          	mv	a4,a5
    80200d7c:	05800793          	li	a5,88
    80200d80:	00f70c63          	beq	a4,a5,80200d98 <vprintfmt+0x254>
    80200d84:	f5043783          	ld	a5,-176(s0)
    80200d88:	0007c783          	lbu	a5,0(a5)
    80200d8c:	00078713          	mv	a4,a5
    80200d90:	07000793          	li	a5,112
    80200d94:	30f71263          	bne	a4,a5,80201098 <vprintfmt+0x554>
                bool is_long = *fmt == 'p' || flags.longflag;
    80200d98:	f5043783          	ld	a5,-176(s0)
    80200d9c:	0007c783          	lbu	a5,0(a5)
    80200da0:	00078713          	mv	a4,a5
    80200da4:	07000793          	li	a5,112
    80200da8:	00f70663          	beq	a4,a5,80200db4 <vprintfmt+0x270>
    80200dac:	f8144783          	lbu	a5,-127(s0)
    80200db0:	00078663          	beqz	a5,80200dbc <vprintfmt+0x278>
    80200db4:	00100793          	li	a5,1
    80200db8:	0080006f          	j	80200dc0 <vprintfmt+0x27c>
    80200dbc:	00000793          	li	a5,0
    80200dc0:	faf403a3          	sb	a5,-89(s0)
    80200dc4:	fa744783          	lbu	a5,-89(s0)
    80200dc8:	0017f793          	andi	a5,a5,1
    80200dcc:	faf403a3          	sb	a5,-89(s0)

                unsigned long num = is_long ? va_arg(vl, unsigned long) : va_arg(vl, unsigned int);
    80200dd0:	fa744783          	lbu	a5,-89(s0)
    80200dd4:	0ff7f793          	zext.b	a5,a5
    80200dd8:	00078c63          	beqz	a5,80200df0 <vprintfmt+0x2ac>
    80200ddc:	f4843783          	ld	a5,-184(s0)
    80200de0:	00878713          	addi	a4,a5,8
    80200de4:	f4e43423          	sd	a4,-184(s0)
    80200de8:	0007b783          	ld	a5,0(a5)
    80200dec:	01c0006f          	j	80200e08 <vprintfmt+0x2c4>
    80200df0:	f4843783          	ld	a5,-184(s0)
    80200df4:	00878713          	addi	a4,a5,8
    80200df8:	f4e43423          	sd	a4,-184(s0)
    80200dfc:	0007a783          	lw	a5,0(a5)
    80200e00:	02079793          	slli	a5,a5,0x20
    80200e04:	0207d793          	srli	a5,a5,0x20
    80200e08:	fef43023          	sd	a5,-32(s0)

                if (flags.prec == 0 && num == 0 && *fmt != 'p') {
    80200e0c:	f8c42783          	lw	a5,-116(s0)
    80200e10:	02079463          	bnez	a5,80200e38 <vprintfmt+0x2f4>
    80200e14:	fe043783          	ld	a5,-32(s0)
    80200e18:	02079063          	bnez	a5,80200e38 <vprintfmt+0x2f4>
    80200e1c:	f5043783          	ld	a5,-176(s0)
    80200e20:	0007c783          	lbu	a5,0(a5)
    80200e24:	00078713          	mv	a4,a5
    80200e28:	07000793          	li	a5,112
    80200e2c:	00f70663          	beq	a4,a5,80200e38 <vprintfmt+0x2f4>
                    flags.in_format = false;
    80200e30:	f8040023          	sb	zero,-128(s0)
    80200e34:	4d00006f          	j	80201304 <vprintfmt+0x7c0>
                    continue;
                }

                // 0x prefix for pointers, or, if # flag is set and non-zero
                bool prefix = *fmt == 'p' || (flags.sharpflag && num != 0);
    80200e38:	f5043783          	ld	a5,-176(s0)
    80200e3c:	0007c783          	lbu	a5,0(a5)
    80200e40:	00078713          	mv	a4,a5
    80200e44:	07000793          	li	a5,112
    80200e48:	00f70a63          	beq	a4,a5,80200e5c <vprintfmt+0x318>
    80200e4c:	f8244783          	lbu	a5,-126(s0)
    80200e50:	00078a63          	beqz	a5,80200e64 <vprintfmt+0x320>
    80200e54:	fe043783          	ld	a5,-32(s0)
    80200e58:	00078663          	beqz	a5,80200e64 <vprintfmt+0x320>
    80200e5c:	00100793          	li	a5,1
    80200e60:	0080006f          	j	80200e68 <vprintfmt+0x324>
    80200e64:	00000793          	li	a5,0
    80200e68:	faf40323          	sb	a5,-90(s0)
    80200e6c:	fa644783          	lbu	a5,-90(s0)
    80200e70:	0017f793          	andi	a5,a5,1
    80200e74:	faf40323          	sb	a5,-90(s0)

                int hexdigits = 0;
    80200e78:	fc042e23          	sw	zero,-36(s0)
                const char *xdigits = *fmt == 'X' ? upperxdigits : lowerxdigits;
    80200e7c:	f5043783          	ld	a5,-176(s0)
    80200e80:	0007c783          	lbu	a5,0(a5)
    80200e84:	00078713          	mv	a4,a5
    80200e88:	05800793          	li	a5,88
    80200e8c:	00f71863          	bne	a4,a5,80200e9c <vprintfmt+0x358>
    80200e90:	00001797          	auipc	a5,0x1
    80200e94:	1f078793          	addi	a5,a5,496 # 80202080 <upperxdigits.1>
    80200e98:	00c0006f          	j	80200ea4 <vprintfmt+0x360>
    80200e9c:	00001797          	auipc	a5,0x1
    80200ea0:	1fc78793          	addi	a5,a5,508 # 80202098 <lowerxdigits.0>
    80200ea4:	f8f43c23          	sd	a5,-104(s0)
                char buf[2 * sizeof(unsigned long)];

                do {
                    buf[hexdigits++] = xdigits[num & 0xf];
    80200ea8:	fe043783          	ld	a5,-32(s0)
    80200eac:	00f7f793          	andi	a5,a5,15
    80200eb0:	f9843703          	ld	a4,-104(s0)
    80200eb4:	00f70733          	add	a4,a4,a5
    80200eb8:	fdc42783          	lw	a5,-36(s0)
    80200ebc:	0017869b          	addiw	a3,a5,1
    80200ec0:	fcd42e23          	sw	a3,-36(s0)
    80200ec4:	00074703          	lbu	a4,0(a4)
    80200ec8:	ff078793          	addi	a5,a5,-16
    80200ecc:	008787b3          	add	a5,a5,s0
    80200ed0:	f8e78023          	sb	a4,-128(a5)
                    num >>= 4;
    80200ed4:	fe043783          	ld	a5,-32(s0)
    80200ed8:	0047d793          	srli	a5,a5,0x4
    80200edc:	fef43023          	sd	a5,-32(s0)
                } while (num);
    80200ee0:	fe043783          	ld	a5,-32(s0)
    80200ee4:	fc0792e3          	bnez	a5,80200ea8 <vprintfmt+0x364>

                if (flags.prec == -1 && flags.zeroflag) {
    80200ee8:	f8c42783          	lw	a5,-116(s0)
    80200eec:	00078713          	mv	a4,a5
    80200ef0:	fff00793          	li	a5,-1
    80200ef4:	02f71663          	bne	a4,a5,80200f20 <vprintfmt+0x3dc>
    80200ef8:	f8344783          	lbu	a5,-125(s0)
    80200efc:	02078263          	beqz	a5,80200f20 <vprintfmt+0x3dc>
                    flags.prec = flags.width - 2 * prefix;
    80200f00:	f8842703          	lw	a4,-120(s0)
    80200f04:	fa644783          	lbu	a5,-90(s0)
    80200f08:	0007879b          	sext.w	a5,a5
    80200f0c:	0017979b          	slliw	a5,a5,0x1
    80200f10:	0007879b          	sext.w	a5,a5
    80200f14:	40f707bb          	subw	a5,a4,a5
    80200f18:	0007879b          	sext.w	a5,a5
    80200f1c:	f8f42623          	sw	a5,-116(s0)
                }

                for (int i = flags.width - 2 * prefix - __MAX(hexdigits, flags.prec); i > 0; i--) {
    80200f20:	f8842703          	lw	a4,-120(s0)
    80200f24:	fa644783          	lbu	a5,-90(s0)
    80200f28:	0007879b          	sext.w	a5,a5
    80200f2c:	0017979b          	slliw	a5,a5,0x1
    80200f30:	0007879b          	sext.w	a5,a5
    80200f34:	40f707bb          	subw	a5,a4,a5
    80200f38:	0007871b          	sext.w	a4,a5
    80200f3c:	fdc42783          	lw	a5,-36(s0)
    80200f40:	f8f42a23          	sw	a5,-108(s0)
    80200f44:	f8c42783          	lw	a5,-116(s0)
    80200f48:	f8f42823          	sw	a5,-112(s0)
    80200f4c:	f9442783          	lw	a5,-108(s0)
    80200f50:	00078593          	mv	a1,a5
    80200f54:	f9042783          	lw	a5,-112(s0)
    80200f58:	00078613          	mv	a2,a5
    80200f5c:	0006069b          	sext.w	a3,a2
    80200f60:	0005879b          	sext.w	a5,a1
    80200f64:	00f6d463          	bge	a3,a5,80200f6c <vprintfmt+0x428>
    80200f68:	00058613          	mv	a2,a1
    80200f6c:	0006079b          	sext.w	a5,a2
    80200f70:	40f707bb          	subw	a5,a4,a5
    80200f74:	fcf42c23          	sw	a5,-40(s0)
    80200f78:	0280006f          	j	80200fa0 <vprintfmt+0x45c>
                    putch(' ');
    80200f7c:	f5843783          	ld	a5,-168(s0)
    80200f80:	02000513          	li	a0,32
    80200f84:	000780e7          	jalr	a5
                    ++written;
    80200f88:	fec42783          	lw	a5,-20(s0)
    80200f8c:	0017879b          	addiw	a5,a5,1
    80200f90:	fef42623          	sw	a5,-20(s0)
                for (int i = flags.width - 2 * prefix - __MAX(hexdigits, flags.prec); i > 0; i--) {
    80200f94:	fd842783          	lw	a5,-40(s0)
    80200f98:	fff7879b          	addiw	a5,a5,-1
    80200f9c:	fcf42c23          	sw	a5,-40(s0)
    80200fa0:	fd842783          	lw	a5,-40(s0)
    80200fa4:	0007879b          	sext.w	a5,a5
    80200fa8:	fcf04ae3          	bgtz	a5,80200f7c <vprintfmt+0x438>
                }

                if (prefix) {
    80200fac:	fa644783          	lbu	a5,-90(s0)
    80200fb0:	0ff7f793          	zext.b	a5,a5
    80200fb4:	04078463          	beqz	a5,80200ffc <vprintfmt+0x4b8>
                    putch('0');
    80200fb8:	f5843783          	ld	a5,-168(s0)
    80200fbc:	03000513          	li	a0,48
    80200fc0:	000780e7          	jalr	a5
                    putch(*fmt == 'X' ? 'X' : 'x');
    80200fc4:	f5043783          	ld	a5,-176(s0)
    80200fc8:	0007c783          	lbu	a5,0(a5)
    80200fcc:	00078713          	mv	a4,a5
    80200fd0:	05800793          	li	a5,88
    80200fd4:	00f71663          	bne	a4,a5,80200fe0 <vprintfmt+0x49c>
    80200fd8:	05800793          	li	a5,88
    80200fdc:	0080006f          	j	80200fe4 <vprintfmt+0x4a0>
    80200fe0:	07800793          	li	a5,120
    80200fe4:	f5843703          	ld	a4,-168(s0)
    80200fe8:	00078513          	mv	a0,a5
    80200fec:	000700e7          	jalr	a4
                    written += 2;
    80200ff0:	fec42783          	lw	a5,-20(s0)
    80200ff4:	0027879b          	addiw	a5,a5,2
    80200ff8:	fef42623          	sw	a5,-20(s0)
                }

                for (int i = hexdigits; i < flags.prec; i++) {
    80200ffc:	fdc42783          	lw	a5,-36(s0)
    80201000:	fcf42a23          	sw	a5,-44(s0)
    80201004:	0280006f          	j	8020102c <vprintfmt+0x4e8>
                    putch('0');
    80201008:	f5843783          	ld	a5,-168(s0)
    8020100c:	03000513          	li	a0,48
    80201010:	000780e7          	jalr	a5
                    ++written;
    80201014:	fec42783          	lw	a5,-20(s0)
    80201018:	0017879b          	addiw	a5,a5,1
    8020101c:	fef42623          	sw	a5,-20(s0)
                for (int i = hexdigits; i < flags.prec; i++) {
    80201020:	fd442783          	lw	a5,-44(s0)
    80201024:	0017879b          	addiw	a5,a5,1
    80201028:	fcf42a23          	sw	a5,-44(s0)
    8020102c:	f8c42703          	lw	a4,-116(s0)
    80201030:	fd442783          	lw	a5,-44(s0)
    80201034:	0007879b          	sext.w	a5,a5
    80201038:	fce7c8e3          	blt	a5,a4,80201008 <vprintfmt+0x4c4>
                }

                for (int i = hexdigits - 1; i >= 0; i--) {
    8020103c:	fdc42783          	lw	a5,-36(s0)
    80201040:	fff7879b          	addiw	a5,a5,-1
    80201044:	fcf42823          	sw	a5,-48(s0)
    80201048:	03c0006f          	j	80201084 <vprintfmt+0x540>
                    putch(buf[i]);
    8020104c:	fd042783          	lw	a5,-48(s0)
    80201050:	ff078793          	addi	a5,a5,-16
    80201054:	008787b3          	add	a5,a5,s0
    80201058:	f807c783          	lbu	a5,-128(a5)
    8020105c:	0007871b          	sext.w	a4,a5
    80201060:	f5843783          	ld	a5,-168(s0)
    80201064:	00070513          	mv	a0,a4
    80201068:	000780e7          	jalr	a5
                    ++written;
    8020106c:	fec42783          	lw	a5,-20(s0)
    80201070:	0017879b          	addiw	a5,a5,1
    80201074:	fef42623          	sw	a5,-20(s0)
                for (int i = hexdigits - 1; i >= 0; i--) {
    80201078:	fd042783          	lw	a5,-48(s0)
    8020107c:	fff7879b          	addiw	a5,a5,-1
    80201080:	fcf42823          	sw	a5,-48(s0)
    80201084:	fd042783          	lw	a5,-48(s0)
    80201088:	0007879b          	sext.w	a5,a5
    8020108c:	fc07d0e3          	bgez	a5,8020104c <vprintfmt+0x508>
                }

                flags.in_format = false;
    80201090:	f8040023          	sb	zero,-128(s0)
            } else if (*fmt == 'x' || *fmt == 'X' || *fmt == 'p') {
    80201094:	2700006f          	j	80201304 <vprintfmt+0x7c0>
            } else if (*fmt == 'd' || *fmt == 'i' || *fmt == 'u') {
    80201098:	f5043783          	ld	a5,-176(s0)
    8020109c:	0007c783          	lbu	a5,0(a5)
    802010a0:	00078713          	mv	a4,a5
    802010a4:	06400793          	li	a5,100
    802010a8:	02f70663          	beq	a4,a5,802010d4 <vprintfmt+0x590>
    802010ac:	f5043783          	ld	a5,-176(s0)
    802010b0:	0007c783          	lbu	a5,0(a5)
    802010b4:	00078713          	mv	a4,a5
    802010b8:	06900793          	li	a5,105
    802010bc:	00f70c63          	beq	a4,a5,802010d4 <vprintfmt+0x590>
    802010c0:	f5043783          	ld	a5,-176(s0)
    802010c4:	0007c783          	lbu	a5,0(a5)
    802010c8:	00078713          	mv	a4,a5
    802010cc:	07500793          	li	a5,117
    802010d0:	08f71063          	bne	a4,a5,80201150 <vprintfmt+0x60c>
                long num = flags.longflag ? va_arg(vl, long) : va_arg(vl, int);
    802010d4:	f8144783          	lbu	a5,-127(s0)
    802010d8:	00078c63          	beqz	a5,802010f0 <vprintfmt+0x5ac>
    802010dc:	f4843783          	ld	a5,-184(s0)
    802010e0:	00878713          	addi	a4,a5,8
    802010e4:	f4e43423          	sd	a4,-184(s0)
    802010e8:	0007b783          	ld	a5,0(a5)
    802010ec:	0140006f          	j	80201100 <vprintfmt+0x5bc>
    802010f0:	f4843783          	ld	a5,-184(s0)
    802010f4:	00878713          	addi	a4,a5,8
    802010f8:	f4e43423          	sd	a4,-184(s0)
    802010fc:	0007a783          	lw	a5,0(a5)
    80201100:	faf43423          	sd	a5,-88(s0)

                written += print_dec_int(putch, num, *fmt != 'u', &flags);
    80201104:	fa843583          	ld	a1,-88(s0)
    80201108:	f5043783          	ld	a5,-176(s0)
    8020110c:	0007c783          	lbu	a5,0(a5)
    80201110:	0007871b          	sext.w	a4,a5
    80201114:	07500793          	li	a5,117
    80201118:	40f707b3          	sub	a5,a4,a5
    8020111c:	00f037b3          	snez	a5,a5
    80201120:	0ff7f793          	zext.b	a5,a5
    80201124:	f8040713          	addi	a4,s0,-128
    80201128:	00070693          	mv	a3,a4
    8020112c:	00078613          	mv	a2,a5
    80201130:	f5843503          	ld	a0,-168(s0)
    80201134:	f08ff0ef          	jal	8020083c <print_dec_int>
    80201138:	00050793          	mv	a5,a0
    8020113c:	fec42703          	lw	a4,-20(s0)
    80201140:	00f707bb          	addw	a5,a4,a5
    80201144:	fef42623          	sw	a5,-20(s0)
                flags.in_format = false;
    80201148:	f8040023          	sb	zero,-128(s0)
            } else if (*fmt == 'd' || *fmt == 'i' || *fmt == 'u') {
    8020114c:	1b80006f          	j	80201304 <vprintfmt+0x7c0>
            } else if (*fmt == 'n') {
    80201150:	f5043783          	ld	a5,-176(s0)
    80201154:	0007c783          	lbu	a5,0(a5)
    80201158:	00078713          	mv	a4,a5
    8020115c:	06e00793          	li	a5,110
    80201160:	04f71c63          	bne	a4,a5,802011b8 <vprintfmt+0x674>
                if (flags.longflag) {
    80201164:	f8144783          	lbu	a5,-127(s0)
    80201168:	02078463          	beqz	a5,80201190 <vprintfmt+0x64c>
                    long *n = va_arg(vl, long *);
    8020116c:	f4843783          	ld	a5,-184(s0)
    80201170:	00878713          	addi	a4,a5,8
    80201174:	f4e43423          	sd	a4,-184(s0)
    80201178:	0007b783          	ld	a5,0(a5)
    8020117c:	faf43823          	sd	a5,-80(s0)
                    *n = written;
    80201180:	fec42703          	lw	a4,-20(s0)
    80201184:	fb043783          	ld	a5,-80(s0)
    80201188:	00e7b023          	sd	a4,0(a5)
    8020118c:	0240006f          	j	802011b0 <vprintfmt+0x66c>
                } else {
                    int *n = va_arg(vl, int *);
    80201190:	f4843783          	ld	a5,-184(s0)
    80201194:	00878713          	addi	a4,a5,8
    80201198:	f4e43423          	sd	a4,-184(s0)
    8020119c:	0007b783          	ld	a5,0(a5)
    802011a0:	faf43c23          	sd	a5,-72(s0)
                    *n = written;
    802011a4:	fb843783          	ld	a5,-72(s0)
    802011a8:	fec42703          	lw	a4,-20(s0)
    802011ac:	00e7a023          	sw	a4,0(a5)
                }
                flags.in_format = false;
    802011b0:	f8040023          	sb	zero,-128(s0)
    802011b4:	1500006f          	j	80201304 <vprintfmt+0x7c0>
            } else if (*fmt == 's') {
    802011b8:	f5043783          	ld	a5,-176(s0)
    802011bc:	0007c783          	lbu	a5,0(a5)
    802011c0:	00078713          	mv	a4,a5
    802011c4:	07300793          	li	a5,115
    802011c8:	02f71e63          	bne	a4,a5,80201204 <vprintfmt+0x6c0>
                const char *s = va_arg(vl, const char *);
    802011cc:	f4843783          	ld	a5,-184(s0)
    802011d0:	00878713          	addi	a4,a5,8
    802011d4:	f4e43423          	sd	a4,-184(s0)
    802011d8:	0007b783          	ld	a5,0(a5)
    802011dc:	fcf43023          	sd	a5,-64(s0)
                written += puts_wo_nl(putch, s);
    802011e0:	fc043583          	ld	a1,-64(s0)
    802011e4:	f5843503          	ld	a0,-168(s0)
    802011e8:	dccff0ef          	jal	802007b4 <puts_wo_nl>
    802011ec:	00050793          	mv	a5,a0
    802011f0:	fec42703          	lw	a4,-20(s0)
    802011f4:	00f707bb          	addw	a5,a4,a5
    802011f8:	fef42623          	sw	a5,-20(s0)
                flags.in_format = false;
    802011fc:	f8040023          	sb	zero,-128(s0)
    80201200:	1040006f          	j	80201304 <vprintfmt+0x7c0>
            } else if (*fmt == 'c') {
    80201204:	f5043783          	ld	a5,-176(s0)
    80201208:	0007c783          	lbu	a5,0(a5)
    8020120c:	00078713          	mv	a4,a5
    80201210:	06300793          	li	a5,99
    80201214:	02f71e63          	bne	a4,a5,80201250 <vprintfmt+0x70c>
                int ch = va_arg(vl, int);
    80201218:	f4843783          	ld	a5,-184(s0)
    8020121c:	00878713          	addi	a4,a5,8
    80201220:	f4e43423          	sd	a4,-184(s0)
    80201224:	0007a783          	lw	a5,0(a5)
    80201228:	fcf42623          	sw	a5,-52(s0)
                putch(ch);
    8020122c:	fcc42703          	lw	a4,-52(s0)
    80201230:	f5843783          	ld	a5,-168(s0)
    80201234:	00070513          	mv	a0,a4
    80201238:	000780e7          	jalr	a5
                ++written;
    8020123c:	fec42783          	lw	a5,-20(s0)
    80201240:	0017879b          	addiw	a5,a5,1
    80201244:	fef42623          	sw	a5,-20(s0)
                flags.in_format = false;
    80201248:	f8040023          	sb	zero,-128(s0)
    8020124c:	0b80006f          	j	80201304 <vprintfmt+0x7c0>
            } else if (*fmt == '%') {
    80201250:	f5043783          	ld	a5,-176(s0)
    80201254:	0007c783          	lbu	a5,0(a5)
    80201258:	00078713          	mv	a4,a5
    8020125c:	02500793          	li	a5,37
    80201260:	02f71263          	bne	a4,a5,80201284 <vprintfmt+0x740>
                putch('%');
    80201264:	f5843783          	ld	a5,-168(s0)
    80201268:	02500513          	li	a0,37
    8020126c:	000780e7          	jalr	a5
                ++written;
    80201270:	fec42783          	lw	a5,-20(s0)
    80201274:	0017879b          	addiw	a5,a5,1
    80201278:	fef42623          	sw	a5,-20(s0)
                flags.in_format = false;
    8020127c:	f8040023          	sb	zero,-128(s0)
    80201280:	0840006f          	j	80201304 <vprintfmt+0x7c0>
            } else {
                putch(*fmt);
    80201284:	f5043783          	ld	a5,-176(s0)
    80201288:	0007c783          	lbu	a5,0(a5)
    8020128c:	0007871b          	sext.w	a4,a5
    80201290:	f5843783          	ld	a5,-168(s0)
    80201294:	00070513          	mv	a0,a4
    80201298:	000780e7          	jalr	a5
                ++written;
    8020129c:	fec42783          	lw	a5,-20(s0)
    802012a0:	0017879b          	addiw	a5,a5,1
    802012a4:	fef42623          	sw	a5,-20(s0)
                flags.in_format = false;
    802012a8:	f8040023          	sb	zero,-128(s0)
    802012ac:	0580006f          	j	80201304 <vprintfmt+0x7c0>
            }
        } else if (*fmt == '%') {
    802012b0:	f5043783          	ld	a5,-176(s0)
    802012b4:	0007c783          	lbu	a5,0(a5)
    802012b8:	00078713          	mv	a4,a5
    802012bc:	02500793          	li	a5,37
    802012c0:	02f71063          	bne	a4,a5,802012e0 <vprintfmt+0x79c>
            flags = (struct fmt_flags) {.in_format = true, .prec = -1};
    802012c4:	f8043023          	sd	zero,-128(s0)
    802012c8:	f8043423          	sd	zero,-120(s0)
    802012cc:	00100793          	li	a5,1
    802012d0:	f8f40023          	sb	a5,-128(s0)
    802012d4:	fff00793          	li	a5,-1
    802012d8:	f8f42623          	sw	a5,-116(s0)
    802012dc:	0280006f          	j	80201304 <vprintfmt+0x7c0>
        } else {
            putch(*fmt);
    802012e0:	f5043783          	ld	a5,-176(s0)
    802012e4:	0007c783          	lbu	a5,0(a5)
    802012e8:	0007871b          	sext.w	a4,a5
    802012ec:	f5843783          	ld	a5,-168(s0)
    802012f0:	00070513          	mv	a0,a4
    802012f4:	000780e7          	jalr	a5
            ++written;
    802012f8:	fec42783          	lw	a5,-20(s0)
    802012fc:	0017879b          	addiw	a5,a5,1
    80201300:	fef42623          	sw	a5,-20(s0)
    for (; *fmt; fmt++) {
    80201304:	f5043783          	ld	a5,-176(s0)
    80201308:	00178793          	addi	a5,a5,1
    8020130c:	f4f43823          	sd	a5,-176(s0)
    80201310:	f5043783          	ld	a5,-176(s0)
    80201314:	0007c783          	lbu	a5,0(a5)
    80201318:	84079ce3          	bnez	a5,80200b70 <vprintfmt+0x2c>
        }
    }

    return written;
    8020131c:	fec42783          	lw	a5,-20(s0)
}
    80201320:	00078513          	mv	a0,a5
    80201324:	0b813083          	ld	ra,184(sp)
    80201328:	0b013403          	ld	s0,176(sp)
    8020132c:	0c010113          	addi	sp,sp,192
    80201330:	00008067          	ret

0000000080201334 <printk>:

int printk(const char* s, ...) {
    80201334:	f9010113          	addi	sp,sp,-112
    80201338:	02113423          	sd	ra,40(sp)
    8020133c:	02813023          	sd	s0,32(sp)
    80201340:	03010413          	addi	s0,sp,48
    80201344:	fca43c23          	sd	a0,-40(s0)
    80201348:	00b43423          	sd	a1,8(s0)
    8020134c:	00c43823          	sd	a2,16(s0)
    80201350:	00d43c23          	sd	a3,24(s0)
    80201354:	02e43023          	sd	a4,32(s0)
    80201358:	02f43423          	sd	a5,40(s0)
    8020135c:	03043823          	sd	a6,48(s0)
    80201360:	03143c23          	sd	a7,56(s0)
    int res = 0;
    80201364:	fe042623          	sw	zero,-20(s0)
    va_list vl;
    va_start(vl, s);
    80201368:	04040793          	addi	a5,s0,64
    8020136c:	fcf43823          	sd	a5,-48(s0)
    80201370:	fd043783          	ld	a5,-48(s0)
    80201374:	fc878793          	addi	a5,a5,-56
    80201378:	fef43023          	sd	a5,-32(s0)
    res = vprintfmt(putc, s, vl);
    8020137c:	fe043783          	ld	a5,-32(s0)
    80201380:	00078613          	mv	a2,a5
    80201384:	fd843583          	ld	a1,-40(s0)
    80201388:	fffff517          	auipc	a0,0xfffff
    8020138c:	11850513          	addi	a0,a0,280 # 802004a0 <putc>
    80201390:	fb4ff0ef          	jal	80200b44 <vprintfmt>
    80201394:	00050793          	mv	a5,a0
    80201398:	fef42623          	sw	a5,-20(s0)
    va_end(vl);
    return res;
    8020139c:	fec42783          	lw	a5,-20(s0)
}
    802013a0:	00078513          	mv	a0,a5
    802013a4:	02813083          	ld	ra,40(sp)
    802013a8:	02013403          	ld	s0,32(sp)
    802013ac:	07010113          	addi	sp,sp,112
    802013b0:	00008067          	ret
