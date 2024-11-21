
../../vmlinux:     file format elf64-littleriscv


Disassembly of section .text:

0000000080200000 <_skernel>:
    .extern start_kernel
    .section .text.init
    .globl _start
_start:
    la sp, boot_stack_top
    80200000:	00003117          	auipc	sp,0x3
    80200004:	02013103          	ld	sp,32(sp) # 80203020 <_GLOBAL_OFFSET_TABLE_+0x18>
    jal mm_init
    80200008:	3ac000ef          	jal	802003b4 <mm_init>
    jal task_init
    8020000c:	3ec000ef          	jal	802003f8 <task_init>
    # ------------------
    # set stvec = _traps
    la t0, _traps
    80200010:	00003297          	auipc	t0,0x3
    80200014:	0202b283          	ld	t0,32(t0) # 80203030 <_GLOBAL_OFFSET_TABLE_+0x28>
    csrw stvec, t0
    80200018:	10529073          	csrw	stvec,t0
    # ------------------
    # set sie[STIE] = 1
    li t0, 1<<5
    8020001c:	02000293          	li	t0,32
    csrw sie, t0
    80200020:	10429073          	csrw	sie,t0
    # ------------------
    # set first time interrupt
    li t1,10000000
    80200024:	00989337          	lui	t1,0x989
    80200028:	6803031b          	addiw	t1,t1,1664 # 989680 <_skernel-0x7f876980>
    # get time
    rdtime t0
    8020002c:	c01022f3          	rdtime	t0
    add t0,t0,t1
    80200030:	006282b3          	add	t0,t0,t1
    # set next interrupt
    jal x1, sbi_set_timer
    80200034:	361000ef          	jal	80200b94 <sbi_set_timer>
    # ------------------
    # set sstatus[SIE] = 1
    li t0, 1<<1
    80200038:	00200293          	li	t0,2
    csrw sstatus, t0
    8020003c:	10029073          	csrw	sstatus,t0

0000000080200040 <_traps>:
    .align 2
    .globl _traps 
_traps:
    # -----------
        # 1. save 32 registers and sepc to stack
        addi sp, sp, -256
    80200040:	f0010113          	addi	sp,sp,-256
        sd x1, 0(sp)
    80200044:	00113023          	sd	ra,0(sp)
        sd x2, 8(sp)
    80200048:	00213423          	sd	sp,8(sp)
        sd x3, 16(sp)
    8020004c:	00313823          	sd	gp,16(sp)
        sd x4, 24(sp)
    80200050:	00413c23          	sd	tp,24(sp)
        sd x5, 32(sp)
    80200054:	02513023          	sd	t0,32(sp)
        sd x6, 40(sp)
    80200058:	02613423          	sd	t1,40(sp)
        sd x7, 48(sp)
    8020005c:	02713823          	sd	t2,48(sp)
        sd x8, 56(sp)
    80200060:	02813c23          	sd	s0,56(sp)
        sd x9, 64(sp)
    80200064:	04913023          	sd	s1,64(sp)
        sd x10, 72(sp)
    80200068:	04a13423          	sd	a0,72(sp)
        sd x11, 80(sp)
    8020006c:	04b13823          	sd	a1,80(sp)
        sd x12, 88(sp)
    80200070:	04c13c23          	sd	a2,88(sp)
        sd x13, 96(sp)
    80200074:	06d13023          	sd	a3,96(sp)
        sd x14, 104(sp)
    80200078:	06e13423          	sd	a4,104(sp)
        sd x15, 112(sp)
    8020007c:	06f13823          	sd	a5,112(sp)
        sd x16, 120(sp)
    80200080:	07013c23          	sd	a6,120(sp)
        sd x17, 128(sp)
    80200084:	09113023          	sd	a7,128(sp)
        sd x18, 136(sp)
    80200088:	09213423          	sd	s2,136(sp)
        sd x19, 144(sp)
    8020008c:	09313823          	sd	s3,144(sp)
        sd x20, 152(sp)
    80200090:	09413c23          	sd	s4,152(sp)
        sd x21, 160(sp)
    80200094:	0b513023          	sd	s5,160(sp)
        sd x22, 168(sp)
    80200098:	0b613423          	sd	s6,168(sp)
        sd x23, 176(sp)
    8020009c:	0b713823          	sd	s7,176(sp)
        sd x24, 184(sp)
    802000a0:	0b813c23          	sd	s8,184(sp)
        sd x25, 192(sp)
    802000a4:	0d913023          	sd	s9,192(sp)
        sd x26, 200(sp)
    802000a8:	0da13423          	sd	s10,200(sp)
        sd x27, 208(sp)
    802000ac:	0db13823          	sd	s11,208(sp)
        sd x28, 216(sp)
    802000b0:	0dc13c23          	sd	t3,216(sp)
        sd x29, 224(sp)
    802000b4:	0fd13023          	sd	t4,224(sp)
        sd x30, 232(sp)
    802000b8:	0fe13423          	sd	t5,232(sp)
        sd x31, 240(sp)
    802000bc:	0ff13823          	sd	t6,240(sp)
        csrr t0, sepc
    802000c0:	141022f3          	csrr	t0,sepc
        sd t0, 248(sp)
    802000c4:	0e513c23          	sd	t0,248(sp)
    # -----------
        # 2. call trap_handler
        csrr a0, scause
    802000c8:	14202573          	csrr	a0,scause
        csrr a1, sepc
    802000cc:	141025f3          	csrr	a1,sepc
        jal x1, trap_handler
    802000d0:	31d000ef          	jal	80200bec <trap_handler>
    # -----------
        # 3. restore sepc and 32 registers (x2(sp) should be restore last) from stack
        ld t0, 248(sp)
    802000d4:	0f813283          	ld	t0,248(sp)
        csrw sepc, t0
    802000d8:	14129073          	csrw	sepc,t0
        ld x1, 0(sp)
    802000dc:	00013083          	ld	ra,0(sp)
        ld x3, 16(sp)
    802000e0:	01013183          	ld	gp,16(sp)
        ld x4, 24(sp)
    802000e4:	01813203          	ld	tp,24(sp)
        ld x5, 32(sp)
    802000e8:	02013283          	ld	t0,32(sp)
        ld x6, 40(sp)
    802000ec:	02813303          	ld	t1,40(sp)
        ld x7, 48(sp)
    802000f0:	03013383          	ld	t2,48(sp)
        ld x8, 56(sp)
    802000f4:	03813403          	ld	s0,56(sp)
        ld x9, 64(sp)
    802000f8:	04013483          	ld	s1,64(sp)
        ld x10, 72(sp)
    802000fc:	04813503          	ld	a0,72(sp)
        ld x11, 80(sp)
    80200100:	05013583          	ld	a1,80(sp)
        ld x12, 88(sp)
    80200104:	05813603          	ld	a2,88(sp)
        ld x13, 96(sp)
    80200108:	06013683          	ld	a3,96(sp)
        ld x14, 104(sp)
    8020010c:	06813703          	ld	a4,104(sp)
        ld x15, 112(sp)
    80200110:	07013783          	ld	a5,112(sp)
        ld x16, 120(sp)
    80200114:	07813803          	ld	a6,120(sp)
        ld x17, 128(sp)
    80200118:	08013883          	ld	a7,128(sp)
        ld x18, 136(sp)
    8020011c:	08813903          	ld	s2,136(sp)
        ld x19, 144(sp)
    80200120:	09013983          	ld	s3,144(sp)
        ld x20, 152(sp)
    80200124:	09813a03          	ld	s4,152(sp)
        ld x21, 160(sp)
    80200128:	0a013a83          	ld	s5,160(sp)
        ld x22, 168(sp)
    8020012c:	0a813b03          	ld	s6,168(sp)
        ld x23, 176(sp)
    80200130:	0b013b83          	ld	s7,176(sp)
        ld x24, 184(sp)
    80200134:	0b813c03          	ld	s8,184(sp)
        ld x25, 192(sp)
    80200138:	0c013c83          	ld	s9,192(sp)
        ld x26, 200(sp)
    8020013c:	0c813d03          	ld	s10,200(sp)
        ld x27, 208(sp)
    80200140:	0d013d83          	ld	s11,208(sp)
        ld x28, 216(sp)
    80200144:	0d813e03          	ld	t3,216(sp)
        ld x29, 224(sp)
    80200148:	0e013e83          	ld	t4,224(sp)
        ld x30, 232(sp)
    8020014c:	0e813f03          	ld	t5,232(sp)
        ld x31, 240(sp)
    80200150:	0f013f83          	ld	t6,240(sp)
        ld x2, 8(sp)
    80200154:	00813103          	ld	sp,8(sp)
        addi sp, sp, 256
    80200158:	10010113          	addi	sp,sp,256
    # -----------
        # 4. return from trap
        sret 
    8020015c:	10200073          	sret

0000000080200160 <__dummy>:
    # -----------
    .extern dummy
    .globl __dummy
__dummy:
    # 将 sepc 设置为 dummy() 的地址，并使用 sret 从 S 模式中返回
    la t0, dummy
    80200160:	00003297          	auipc	t0,0x3
    80200164:	ec82b283          	ld	t0,-312(t0) # 80203028 <_GLOBAL_OFFSET_TABLE_+0x20>
    csrw sepc, t0
    80200168:	14129073          	csrw	sepc,t0
    sret
    8020016c:	10200073          	sret

0000000080200170 <__switch_to>:
    # -----------
    .globl __switch_to
__switch_to:
    # save state to prev process
    # 保存当前线程的 ra，sp，s0~s11 到当前线程的 thread_struct 中
    addi t0, a0, 32 #t0 = &prev->thread
    80200170:	02050293          	addi	t0,a0,32
    sd ra, 0(t0)
    80200174:	0012b023          	sd	ra,0(t0)
    sd sp, 8(t0)
    80200178:	0022b423          	sd	sp,8(t0)
    sd s0, 16(t0)
    8020017c:	0082b823          	sd	s0,16(t0)
    sd s1, 24(t0)
    80200180:	0092bc23          	sd	s1,24(t0)
    sd s2, 32(t0)
    80200184:	0322b023          	sd	s2,32(t0)
    sd s3, 40(t0)
    80200188:	0332b423          	sd	s3,40(t0)
    sd s4, 48(t0)
    8020018c:	0342b823          	sd	s4,48(t0)
    sd s5, 56(t0)
    80200190:	0352bc23          	sd	s5,56(t0)
    sd s6, 64(t0)
    80200194:	0562b023          	sd	s6,64(t0)
    sd s7, 72(t0)
    80200198:	0572b423          	sd	s7,72(t0)
    sd s8, 80(t0)
    8020019c:	0582b823          	sd	s8,80(t0)
    sd s9, 88(t0)
    802001a0:	0592bc23          	sd	s9,88(t0)
    sd s10, 96(t0)
    802001a4:	07a2b023          	sd	s10,96(t0)
    sd s11, 104(t0)
    802001a8:	07b2b423          	sd	s11,104(t0)
    # restore state from next process
    # 将下一个线程的 thread_struct 中的相关数据载入到 ra，sp，s0~s11 中进行恢复
    addi t0, a1, 32
    802001ac:	02058293          	addi	t0,a1,32
    ld ra, 0(t0)
    802001b0:	0002b083          	ld	ra,0(t0)
    ld sp, 8(t0)
    802001b4:	0082b103          	ld	sp,8(t0)
    ld s0, 16(t0)
    802001b8:	0102b403          	ld	s0,16(t0)
    ld s1, 24(t0)
    802001bc:	0182b483          	ld	s1,24(t0)
    ld s2, 32(t0)
    802001c0:	0202b903          	ld	s2,32(t0)
    ld s3, 40(t0)
    802001c4:	0282b983          	ld	s3,40(t0)
    ld s4, 48(t0)
    802001c8:	0302ba03          	ld	s4,48(t0)
    ld s5, 56(t0)
    802001cc:	0382ba83          	ld	s5,56(t0)
    ld s6, 64(t0)
    802001d0:	0402bb03          	ld	s6,64(t0)
    ld s7, 72(t0)
    802001d4:	0482bb83          	ld	s7,72(t0)
    ld s8, 80(t0)
    802001d8:	0502bc03          	ld	s8,80(t0)
    ld s9, 88(t0)
    802001dc:	0582bc83          	ld	s9,88(t0)
    ld s10, 96(t0)
    802001e0:	0602bd03          	ld	s10,96(t0)
    ld s11, 104(t0)
    802001e4:	0682bd83          	ld	s11,104(t0)
    802001e8:	00008067          	ret

00000000802001ec <get_cycles>:
#include "sbi.h"

// QEMU 中时钟的频率是 10MHz，也就是 1 秒钟相当于 10000000 个时钟周期
uint64_t TIMECLOCK = 1000000;

uint64_t get_cycles() {
    802001ec:	fe010113          	addi	sp,sp,-32
    802001f0:	00813c23          	sd	s0,24(sp)
    802001f4:	02010413          	addi	s0,sp,32
    // 编写内联汇编，使用 rdtime 获取 time 寄存器中（也就是 mtime 寄存器）的值并返回
    unsigned long time;

    __asm__ volatile(
    802001f8:	c01027f3          	rdtime	a5
    802001fc:	fef43423          	sd	a5,-24(s0)
        "rdtime %[time]"
        :[time] "=r" (time)
        : :"memory"
    );
    
    return time;
    80200200:	fe843783          	ld	a5,-24(s0)
}
    80200204:	00078513          	mv	a0,a5
    80200208:	01813403          	ld	s0,24(sp)
    8020020c:	02010113          	addi	sp,sp,32
    80200210:	00008067          	ret

0000000080200214 <clock_set_next_event>:

void clock_set_next_event() {
    80200214:	fe010113          	addi	sp,sp,-32
    80200218:	00113c23          	sd	ra,24(sp)
    8020021c:	00813823          	sd	s0,16(sp)
    80200220:	02010413          	addi	s0,sp,32
    // 下一次时钟中断的时间点
    uint64_t next_interrupt = get_cycles() + TIMECLOCK;
    80200224:	fc9ff0ef          	jal	802001ec <get_cycles>
    80200228:	00050713          	mv	a4,a0
    8020022c:	00003797          	auipc	a5,0x3
    80200230:	dd478793          	addi	a5,a5,-556 # 80203000 <TIMECLOCK>
    80200234:	0007b783          	ld	a5,0(a5)
    80200238:	00f707b3          	add	a5,a4,a5
    8020023c:	fef43423          	sd	a5,-24(s0)

    // 使用 sbi_set_timer 来完成对下一次时钟中断的设置
    sbi_set_timer(next_interrupt);
    80200240:	fe843503          	ld	a0,-24(s0)
    80200244:	151000ef          	jal	80200b94 <sbi_set_timer>
}
    80200248:	00000013          	nop
    8020024c:	01813083          	ld	ra,24(sp)
    80200250:	01013403          	ld	s0,16(sp)
    80200254:	02010113          	addi	sp,sp,32
    80200258:	00008067          	ret

000000008020025c <kalloc>:

struct {
    struct run *freelist;
} kmem;

void *kalloc() {
    8020025c:	fe010113          	addi	sp,sp,-32
    80200260:	00113c23          	sd	ra,24(sp)
    80200264:	00813823          	sd	s0,16(sp)
    80200268:	02010413          	addi	s0,sp,32
    struct run *r;

    r = kmem.freelist;
    8020026c:	00005797          	auipc	a5,0x5
    80200270:	d9478793          	addi	a5,a5,-620 # 80205000 <kmem>
    80200274:	0007b783          	ld	a5,0(a5)
    80200278:	fef43423          	sd	a5,-24(s0)
    kmem.freelist = r->next;
    8020027c:	fe843783          	ld	a5,-24(s0)
    80200280:	0007b703          	ld	a4,0(a5)
    80200284:	00005797          	auipc	a5,0x5
    80200288:	d7c78793          	addi	a5,a5,-644 # 80205000 <kmem>
    8020028c:	00e7b023          	sd	a4,0(a5)
    
    memset((void *)r, 0x0, PGSIZE);
    80200290:	00001637          	lui	a2,0x1
    80200294:	00000593          	li	a1,0
    80200298:	fe843503          	ld	a0,-24(s0)
    8020029c:	1e1010ef          	jal	80201c7c <memset>
    return (void *)r;
    802002a0:	fe843783          	ld	a5,-24(s0)
}
    802002a4:	00078513          	mv	a0,a5
    802002a8:	01813083          	ld	ra,24(sp)
    802002ac:	01013403          	ld	s0,16(sp)
    802002b0:	02010113          	addi	sp,sp,32
    802002b4:	00008067          	ret

00000000802002b8 <kfree>:

void kfree(void *addr) {
    802002b8:	fd010113          	addi	sp,sp,-48
    802002bc:	02113423          	sd	ra,40(sp)
    802002c0:	02813023          	sd	s0,32(sp)
    802002c4:	03010413          	addi	s0,sp,48
    802002c8:	fca43c23          	sd	a0,-40(s0)
    struct run *r;

    // PGSIZE align 
    //PGROUNDDOWN
    *(uintptr_t *)&addr = (uintptr_t)addr & ~(PGSIZE - 1);
    802002cc:	fd843783          	ld	a5,-40(s0)
    802002d0:	00078693          	mv	a3,a5
    802002d4:	fd840793          	addi	a5,s0,-40
    802002d8:	fffff737          	lui	a4,0xfffff
    802002dc:	00e6f733          	and	a4,a3,a4
    802002e0:	00e7b023          	sd	a4,0(a5)

    memset(addr, 0x0, (uint64_t)PGSIZE);
    802002e4:	fd843783          	ld	a5,-40(s0)
    802002e8:	00001637          	lui	a2,0x1
    802002ec:	00000593          	li	a1,0
    802002f0:	00078513          	mv	a0,a5
    802002f4:	189010ef          	jal	80201c7c <memset>

    r = (struct run *)addr;
    802002f8:	fd843783          	ld	a5,-40(s0)
    802002fc:	fef43423          	sd	a5,-24(s0)
    r->next = kmem.freelist;
    80200300:	00005797          	auipc	a5,0x5
    80200304:	d0078793          	addi	a5,a5,-768 # 80205000 <kmem>
    80200308:	0007b703          	ld	a4,0(a5)
    8020030c:	fe843783          	ld	a5,-24(s0)
    80200310:	00e7b023          	sd	a4,0(a5)
    kmem.freelist = r;
    80200314:	00005797          	auipc	a5,0x5
    80200318:	cec78793          	addi	a5,a5,-788 # 80205000 <kmem>
    8020031c:	fe843703          	ld	a4,-24(s0)
    80200320:	00e7b023          	sd	a4,0(a5)

    return;
    80200324:	00000013          	nop
}
    80200328:	02813083          	ld	ra,40(sp)
    8020032c:	02013403          	ld	s0,32(sp)
    80200330:	03010113          	addi	sp,sp,48
    80200334:	00008067          	ret

0000000080200338 <kfreerange>:

void kfreerange(char *start, char *end) {
    80200338:	fd010113          	addi	sp,sp,-48
    8020033c:	02113423          	sd	ra,40(sp)
    80200340:	02813023          	sd	s0,32(sp)
    80200344:	03010413          	addi	s0,sp,48
    80200348:	fca43c23          	sd	a0,-40(s0)
    8020034c:	fcb43823          	sd	a1,-48(s0)
    char *addr = (char *)PGROUNDUP((uintptr_t)start);
    80200350:	fd843703          	ld	a4,-40(s0)
    80200354:	000017b7          	lui	a5,0x1
    80200358:	fff78793          	addi	a5,a5,-1 # fff <_skernel-0x801ff001>
    8020035c:	00f70733          	add	a4,a4,a5
    80200360:	fffff7b7          	lui	a5,0xfffff
    80200364:	00f777b3          	and	a5,a4,a5
    80200368:	fef43423          	sd	a5,-24(s0)
    for (; (uintptr_t)(addr) + PGSIZE <= (uintptr_t)end; addr += PGSIZE) {
    8020036c:	01c0006f          	j	80200388 <kfreerange+0x50>
        kfree((void *)addr);
    80200370:	fe843503          	ld	a0,-24(s0)
    80200374:	f45ff0ef          	jal	802002b8 <kfree>
    for (; (uintptr_t)(addr) + PGSIZE <= (uintptr_t)end; addr += PGSIZE) {
    80200378:	fe843703          	ld	a4,-24(s0)
    8020037c:	000017b7          	lui	a5,0x1
    80200380:	00f707b3          	add	a5,a4,a5
    80200384:	fef43423          	sd	a5,-24(s0)
    80200388:	fe843703          	ld	a4,-24(s0)
    8020038c:	000017b7          	lui	a5,0x1
    80200390:	00f70733          	add	a4,a4,a5
    80200394:	fd043783          	ld	a5,-48(s0)
    80200398:	fce7fce3          	bgeu	a5,a4,80200370 <kfreerange+0x38>
    }
}
    8020039c:	00000013          	nop
    802003a0:	00000013          	nop
    802003a4:	02813083          	ld	ra,40(sp)
    802003a8:	02013403          	ld	s0,32(sp)
    802003ac:	03010113          	addi	sp,sp,48
    802003b0:	00008067          	ret

00000000802003b4 <mm_init>:

void mm_init(void) {
    802003b4:	ff010113          	addi	sp,sp,-16
    802003b8:	00113423          	sd	ra,8(sp)
    802003bc:	00813023          	sd	s0,0(sp)
    802003c0:	01010413          	addi	s0,sp,16
    kfreerange(_ekernel, (char *)PHY_END);
    802003c4:	01100793          	li	a5,17
    802003c8:	01b79593          	slli	a1,a5,0x1b
    802003cc:	00003517          	auipc	a0,0x3
    802003d0:	c4453503          	ld	a0,-956(a0) # 80203010 <_GLOBAL_OFFSET_TABLE_+0x8>
    802003d4:	f65ff0ef          	jal	80200338 <kfreerange>
    printk("...mm_init done!\n");
    802003d8:	00002517          	auipc	a0,0x2
    802003dc:	c2850513          	addi	a0,a0,-984 # 80202000 <_srodata>
    802003e0:	77c010ef          	jal	80201b5c <printk>
}
    802003e4:	00000013          	nop
    802003e8:	00813083          	ld	ra,8(sp)
    802003ec:	00013403          	ld	s0,0(sp)
    802003f0:	01010113          	addi	sp,sp,16
    802003f4:	00008067          	ret

00000000802003f8 <task_init>:

struct task_struct *idle;           // idle process
struct task_struct *current;        // 指向当前运行线程的 task_struct
struct task_struct *task[NR_TASKS]; // 线程数组，所有的线程都保存在此

void task_init() {
    802003f8:	fe010113          	addi	sp,sp,-32
    802003fc:	00113c23          	sd	ra,24(sp)
    80200400:	00813823          	sd	s0,16(sp)
    80200404:	02010413          	addi	s0,sp,32
    srand(2024);
    80200408:	7e800513          	li	a0,2024
    8020040c:	7d0010ef          	jal	80201bdc <srand>
    // 3. 由于 idle 不参与调度，可以将其 counter / priority 设置为 0
    // 4. 设置 idle 的 pid 为 0
    // 5. 将 current 和 task[0] 指向 idle

    /* YOUR CODE HERE */
    idle = (struct task_struct *)kalloc();
    80200410:	e4dff0ef          	jal	8020025c <kalloc>
    80200414:	00050713          	mv	a4,a0
    80200418:	00005797          	auipc	a5,0x5
    8020041c:	bf078793          	addi	a5,a5,-1040 # 80205008 <idle>
    80200420:	00e7b023          	sd	a4,0(a5)
    idle->state = TASK_RUNNING;
    80200424:	00005797          	auipc	a5,0x5
    80200428:	be478793          	addi	a5,a5,-1052 # 80205008 <idle>
    8020042c:	0007b783          	ld	a5,0(a5)
    80200430:	0007b023          	sd	zero,0(a5)
    idle->counter = idle->priority = 0;
    80200434:	00005797          	auipc	a5,0x5
    80200438:	bd478793          	addi	a5,a5,-1068 # 80205008 <idle>
    8020043c:	0007b783          	ld	a5,0(a5)
    80200440:	0007b823          	sd	zero,16(a5)
    80200444:	00005717          	auipc	a4,0x5
    80200448:	bc470713          	addi	a4,a4,-1084 # 80205008 <idle>
    8020044c:	00073703          	ld	a4,0(a4)
    80200450:	0107b783          	ld	a5,16(a5)
    80200454:	00f73423          	sd	a5,8(a4)
    idle->pid = 0;
    80200458:	00005797          	auipc	a5,0x5
    8020045c:	bb078793          	addi	a5,a5,-1104 # 80205008 <idle>
    80200460:	0007b783          	ld	a5,0(a5)
    80200464:	0007bc23          	sd	zero,24(a5)
    current = task[0] = idle;
    80200468:	00005797          	auipc	a5,0x5
    8020046c:	ba078793          	addi	a5,a5,-1120 # 80205008 <idle>
    80200470:	0007b703          	ld	a4,0(a5)
    80200474:	00005797          	auipc	a5,0x5
    80200478:	ba478793          	addi	a5,a5,-1116 # 80205018 <task>
    8020047c:	00e7b023          	sd	a4,0(a5)
    80200480:	00005797          	auipc	a5,0x5
    80200484:	b9878793          	addi	a5,a5,-1128 # 80205018 <task>
    80200488:	0007b703          	ld	a4,0(a5)
    8020048c:	00005797          	auipc	a5,0x5
    80200490:	b8478793          	addi	a5,a5,-1148 # 80205010 <current>
    80200494:	00e7b023          	sd	a4,0(a5)
    // 3. 为 task[1] ~ task[NR_TASKS - 1] 设置 thread_struct 中的 ra 和 sp
    //     - ra 设置为 __dummy（见 4.2.2）的地址
    //     - sp 设置为该线程申请的物理页的高地址

    /* YOUR CODE HERE */
    for(int i = 1; i < NR_TASKS; i++)
    80200498:	00100793          	li	a5,1
    8020049c:	fef42623          	sw	a5,-20(s0)
    802004a0:	12c0006f          	j	802005cc <task_init+0x1d4>
    {
        task[i] = (struct task_struct *)kalloc();
    802004a4:	db9ff0ef          	jal	8020025c <kalloc>
    802004a8:	00050693          	mv	a3,a0
    802004ac:	00005717          	auipc	a4,0x5
    802004b0:	b6c70713          	addi	a4,a4,-1172 # 80205018 <task>
    802004b4:	fec42783          	lw	a5,-20(s0)
    802004b8:	00379793          	slli	a5,a5,0x3
    802004bc:	00f707b3          	add	a5,a4,a5
    802004c0:	00d7b023          	sd	a3,0(a5)
        task[i]->state = TASK_RUNNING;
    802004c4:	00005717          	auipc	a4,0x5
    802004c8:	b5470713          	addi	a4,a4,-1196 # 80205018 <task>
    802004cc:	fec42783          	lw	a5,-20(s0)
    802004d0:	00379793          	slli	a5,a5,0x3
    802004d4:	00f707b3          	add	a5,a4,a5
    802004d8:	0007b783          	ld	a5,0(a5)
    802004dc:	0007b023          	sd	zero,0(a5)
        task[i]->counter = 0;
    802004e0:	00005717          	auipc	a4,0x5
    802004e4:	b3870713          	addi	a4,a4,-1224 # 80205018 <task>
    802004e8:	fec42783          	lw	a5,-20(s0)
    802004ec:	00379793          	slli	a5,a5,0x3
    802004f0:	00f707b3          	add	a5,a4,a5
    802004f4:	0007b783          	ld	a5,0(a5)
    802004f8:	0007b423          	sd	zero,8(a5)
        task[i]->priority = rand() % (PRIORITY_MAX - PRIORITY_MIN + 1) + PRIORITY_MIN;
    802004fc:	724010ef          	jal	80201c20 <rand>
    80200500:	00050793          	mv	a5,a0
    80200504:	00078713          	mv	a4,a5
    80200508:	00a00793          	li	a5,10
    8020050c:	02f767bb          	remw	a5,a4,a5
    80200510:	0007879b          	sext.w	a5,a5
    80200514:	0017879b          	addiw	a5,a5,1
    80200518:	0007869b          	sext.w	a3,a5
    8020051c:	00005717          	auipc	a4,0x5
    80200520:	afc70713          	addi	a4,a4,-1284 # 80205018 <task>
    80200524:	fec42783          	lw	a5,-20(s0)
    80200528:	00379793          	slli	a5,a5,0x3
    8020052c:	00f707b3          	add	a5,a4,a5
    80200530:	0007b783          	ld	a5,0(a5)
    80200534:	00068713          	mv	a4,a3
    80200538:	00e7b823          	sd	a4,16(a5)
        task[i]->pid = i;
    8020053c:	00005717          	auipc	a4,0x5
    80200540:	adc70713          	addi	a4,a4,-1316 # 80205018 <task>
    80200544:	fec42783          	lw	a5,-20(s0)
    80200548:	00379793          	slli	a5,a5,0x3
    8020054c:	00f707b3          	add	a5,a4,a5
    80200550:	0007b783          	ld	a5,0(a5)
    80200554:	fec42703          	lw	a4,-20(s0)
    80200558:	00e7bc23          	sd	a4,24(a5)
        task[i]->thread.ra = (uint64_t)__dummy;
    8020055c:	00005717          	auipc	a4,0x5
    80200560:	abc70713          	addi	a4,a4,-1348 # 80205018 <task>
    80200564:	fec42783          	lw	a5,-20(s0)
    80200568:	00379793          	slli	a5,a5,0x3
    8020056c:	00f707b3          	add	a5,a4,a5
    80200570:	0007b783          	ld	a5,0(a5)
    80200574:	00003717          	auipc	a4,0x3
    80200578:	aa473703          	ld	a4,-1372(a4) # 80203018 <_GLOBAL_OFFSET_TABLE_+0x10>
    8020057c:	02e7b023          	sd	a4,32(a5)
        task[i]->thread.sp = (uint64_t)task[i] + PGSIZE;
    80200580:	00005717          	auipc	a4,0x5
    80200584:	a9870713          	addi	a4,a4,-1384 # 80205018 <task>
    80200588:	fec42783          	lw	a5,-20(s0)
    8020058c:	00379793          	slli	a5,a5,0x3
    80200590:	00f707b3          	add	a5,a4,a5
    80200594:	0007b783          	ld	a5,0(a5)
    80200598:	00078693          	mv	a3,a5
    8020059c:	00005717          	auipc	a4,0x5
    802005a0:	a7c70713          	addi	a4,a4,-1412 # 80205018 <task>
    802005a4:	fec42783          	lw	a5,-20(s0)
    802005a8:	00379793          	slli	a5,a5,0x3
    802005ac:	00f707b3          	add	a5,a4,a5
    802005b0:	0007b783          	ld	a5,0(a5)
    802005b4:	00001737          	lui	a4,0x1
    802005b8:	00e68733          	add	a4,a3,a4
    802005bc:	02e7b423          	sd	a4,40(a5)
    for(int i = 1; i < NR_TASKS; i++)
    802005c0:	fec42783          	lw	a5,-20(s0)
    802005c4:	0017879b          	addiw	a5,a5,1
    802005c8:	fef42623          	sw	a5,-20(s0)
    802005cc:	fec42783          	lw	a5,-20(s0)
    802005d0:	0007871b          	sext.w	a4,a5
    802005d4:	01f00793          	li	a5,31
    802005d8:	ece7d6e3          	bge	a5,a4,802004a4 <task_init+0xac>
    //s到thread_struct的偏移量
    printk("offset_s_to_thread_struct=%d\n", offsetof(struct thread_struct, s));
    //s[1]到thread_struct的偏移量
    printk("offset_s1_to_thread_struct=%d\n", offsetof(struct thread_struct, s[1]));*/

    printk("...task_init done!\n");
    802005dc:	00002517          	auipc	a0,0x2
    802005e0:	a3c50513          	addi	a0,a0,-1476 # 80202018 <_srodata+0x18>
    802005e4:	578010ef          	jal	80201b5c <printk>
}
    802005e8:	00000013          	nop
    802005ec:	01813083          	ld	ra,24(sp)
    802005f0:	01013403          	ld	s0,16(sp)
    802005f4:	02010113          	addi	sp,sp,32
    802005f8:	00008067          	ret

00000000802005fc <dummy>:
int tasks_output_index = 0;
char expected_output[] = "2222222222111111133334222222222211111113";
#include "sbi.h"
#endif

void dummy() {
    802005fc:	fd010113          	addi	sp,sp,-48
    80200600:	02113423          	sd	ra,40(sp)
    80200604:	02813023          	sd	s0,32(sp)
    80200608:	03010413          	addi	s0,sp,48
    uint64_t MOD = 1000000007;
    8020060c:	3b9ad7b7          	lui	a5,0x3b9ad
    80200610:	a0778793          	addi	a5,a5,-1529 # 3b9aca07 <_skernel-0x448535f9>
    80200614:	fcf43c23          	sd	a5,-40(s0)
    uint64_t auto_inc_local_var = 0;
    80200618:	fe043423          	sd	zero,-24(s0)
    int last_counter = -1;
    8020061c:	fff00793          	li	a5,-1
    80200620:	fef42223          	sw	a5,-28(s0)
    while (1) {
        if ((last_counter == -1 || current->counter != last_counter) && current->counter > 0) {
    80200624:	fe442783          	lw	a5,-28(s0)
    80200628:	0007871b          	sext.w	a4,a5
    8020062c:	fff00793          	li	a5,-1
    80200630:	00f70e63          	beq	a4,a5,8020064c <dummy+0x50>
    80200634:	00005797          	auipc	a5,0x5
    80200638:	9dc78793          	addi	a5,a5,-1572 # 80205010 <current>
    8020063c:	0007b783          	ld	a5,0(a5)
    80200640:	0087b703          	ld	a4,8(a5)
    80200644:	fe442783          	lw	a5,-28(s0)
    80200648:	fcf70ee3          	beq	a4,a5,80200624 <dummy+0x28>
    8020064c:	00005797          	auipc	a5,0x5
    80200650:	9c478793          	addi	a5,a5,-1596 # 80205010 <current>
    80200654:	0007b783          	ld	a5,0(a5)
    80200658:	0087b783          	ld	a5,8(a5)
    8020065c:	fc0784e3          	beqz	a5,80200624 <dummy+0x28>
            if (current->counter == 1) {
    80200660:	00005797          	auipc	a5,0x5
    80200664:	9b078793          	addi	a5,a5,-1616 # 80205010 <current>
    80200668:	0007b783          	ld	a5,0(a5)
    8020066c:	0087b703          	ld	a4,8(a5)
    80200670:	00100793          	li	a5,1
    80200674:	00f71e63          	bne	a4,a5,80200690 <dummy+0x94>
                --(current->counter);   // forced the counter to be zero if this thread is going to be scheduled
    80200678:	00005797          	auipc	a5,0x5
    8020067c:	99878793          	addi	a5,a5,-1640 # 80205010 <current>
    80200680:	0007b783          	ld	a5,0(a5)
    80200684:	0087b703          	ld	a4,8(a5)
    80200688:	fff70713          	addi	a4,a4,-1 # fff <_skernel-0x801ff001>
    8020068c:	00e7b423          	sd	a4,8(a5)
            }                           // in case that the new counter is also 1, leading the information not printed.
            last_counter = current->counter;
    80200690:	00005797          	auipc	a5,0x5
    80200694:	98078793          	addi	a5,a5,-1664 # 80205010 <current>
    80200698:	0007b783          	ld	a5,0(a5)
    8020069c:	0087b783          	ld	a5,8(a5)
    802006a0:	fef42223          	sw	a5,-28(s0)
            auto_inc_local_var = (auto_inc_local_var + 1) % MOD;
    802006a4:	fe843783          	ld	a5,-24(s0)
    802006a8:	00178713          	addi	a4,a5,1
    802006ac:	fd843783          	ld	a5,-40(s0)
    802006b0:	02f777b3          	remu	a5,a4,a5
    802006b4:	fef43423          	sd	a5,-24(s0)
            printk("[PID = %d] is running. auto_inc_local_var = %d\n", current->pid, auto_inc_local_var);
    802006b8:	00005797          	auipc	a5,0x5
    802006bc:	95878793          	addi	a5,a5,-1704 # 80205010 <current>
    802006c0:	0007b783          	ld	a5,0(a5)
    802006c4:	0187b783          	ld	a5,24(a5)
    802006c8:	fe843603          	ld	a2,-24(s0)
    802006cc:	00078593          	mv	a1,a5
    802006d0:	00002517          	auipc	a0,0x2
    802006d4:	96050513          	addi	a0,a0,-1696 # 80202030 <_srodata+0x30>
    802006d8:	484010ef          	jal	80201b5c <printk>
        if ((last_counter == -1 || current->counter != last_counter) && current->counter > 0) {
    802006dc:	f49ff06f          	j	80200624 <dummy+0x28>

00000000802006e0 <switch_to>:
    }
}

extern void __switch_to(struct task_struct *prev, struct task_struct *next);

void switch_to(struct task_struct *next) {
    802006e0:	fd010113          	addi	sp,sp,-48
    802006e4:	02113423          	sd	ra,40(sp)
    802006e8:	02813023          	sd	s0,32(sp)
    802006ec:	03010413          	addi	s0,sp,48
    802006f0:	fca43c23          	sd	a0,-40(s0)
    //判断下一个执行的线程 next 与当前的线程 current 是否为同一个线程
    //如果是同一个线程，则无需做任何处理，否则调用 __switch_to 进行线程切换
    if (next != current) {
    802006f4:	00005797          	auipc	a5,0x5
    802006f8:	91c78793          	addi	a5,a5,-1764 # 80205010 <current>
    802006fc:	0007b783          	ld	a5,0(a5)
    80200700:	fd843703          	ld	a4,-40(s0)
    80200704:	06f70063          	beq	a4,a5,80200764 <switch_to+0x84>
        struct task_struct *prev = current;
    80200708:	00005797          	auipc	a5,0x5
    8020070c:	90878793          	addi	a5,a5,-1784 # 80205010 <current>
    80200710:	0007b783          	ld	a5,0(a5)
    80200714:	fef43423          	sd	a5,-24(s0)
        current = next;
    80200718:	00005797          	auipc	a5,0x5
    8020071c:	8f878793          	addi	a5,a5,-1800 # 80205010 <current>
    80200720:	fd843703          	ld	a4,-40(s0)
    80200724:	00e7b023          	sd	a4,0(a5)
        printk("\nswitch to [PID = %d PRIORITY = %d COUNTER = %d]\n",next->pid, next->priority, next->counter);
    80200728:	fd843783          	ld	a5,-40(s0)
    8020072c:	0187b703          	ld	a4,24(a5)
    80200730:	fd843783          	ld	a5,-40(s0)
    80200734:	0107b603          	ld	a2,16(a5)
    80200738:	fd843783          	ld	a5,-40(s0)
    8020073c:	0087b783          	ld	a5,8(a5)
    80200740:	00078693          	mv	a3,a5
    80200744:	00070593          	mv	a1,a4
    80200748:	00002517          	auipc	a0,0x2
    8020074c:	91850513          	addi	a0,a0,-1768 # 80202060 <_srodata+0x60>
    80200750:	40c010ef          	jal	80201b5c <printk>
        __switch_to(prev, next);
    80200754:	fd843583          	ld	a1,-40(s0)
    80200758:	fe843503          	ld	a0,-24(s0)
    8020075c:	a15ff0ef          	jal	80200170 <__switch_to>
    80200760:	0080006f          	j	80200768 <switch_to+0x88>
    }
    else {
        return;
    80200764:	00000013          	nop
    }
}
    80200768:	02813083          	ld	ra,40(sp)
    8020076c:	02013403          	ld	s0,32(sp)
    80200770:	03010113          	addi	sp,sp,48
    80200774:	00008067          	ret

0000000080200778 <do_timer>:

void do_timer() {
    80200778:	ff010113          	addi	sp,sp,-16
    8020077c:	00113423          	sd	ra,8(sp)
    80200780:	00813023          	sd	s0,0(sp)
    80200784:	01010413          	addi	s0,sp,16
    // 1. 如果当前线程是 idle 线程或当前线程时间片耗尽则直接进行调度
    // 2. 否则对当前线程的运行剩余时间减 1，若剩余时间仍然大于 0 则直接返回，否则进行调度
    // YOUR CODE HERE
    if(current == idle || current->counter == 0)
    80200788:	00005797          	auipc	a5,0x5
    8020078c:	88878793          	addi	a5,a5,-1912 # 80205010 <current>
    80200790:	0007b703          	ld	a4,0(a5)
    80200794:	00005797          	auipc	a5,0x5
    80200798:	87478793          	addi	a5,a5,-1932 # 80205008 <idle>
    8020079c:	0007b783          	ld	a5,0(a5)
    802007a0:	00f70c63          	beq	a4,a5,802007b8 <do_timer+0x40>
    802007a4:	00005797          	auipc	a5,0x5
    802007a8:	86c78793          	addi	a5,a5,-1940 # 80205010 <current>
    802007ac:	0007b783          	ld	a5,0(a5)
    802007b0:	0087b783          	ld	a5,8(a5)
    802007b4:	00079663          	bnez	a5,802007c0 <do_timer+0x48>
        schedule();
    802007b8:	050000ef          	jal	80200808 <schedule>
    802007bc:	03c0006f          	j	802007f8 <do_timer+0x80>
    else {
        current->counter--;
    802007c0:	00005797          	auipc	a5,0x5
    802007c4:	85078793          	addi	a5,a5,-1968 # 80205010 <current>
    802007c8:	0007b783          	ld	a5,0(a5)
    802007cc:	0087b703          	ld	a4,8(a5)
    802007d0:	fff70713          	addi	a4,a4,-1
    802007d4:	00e7b423          	sd	a4,8(a5)
        if(current->counter > 0)
    802007d8:	00005797          	auipc	a5,0x5
    802007dc:	83878793          	addi	a5,a5,-1992 # 80205010 <current>
    802007e0:	0007b783          	ld	a5,0(a5)
    802007e4:	0087b783          	ld	a5,8(a5)
    802007e8:	00079663          	bnez	a5,802007f4 <do_timer+0x7c>
            return;
        else 
            schedule();
    802007ec:	01c000ef          	jal	80200808 <schedule>
    802007f0:	0080006f          	j	802007f8 <do_timer+0x80>
            return;
    802007f4:	00000013          	nop
    }
}
    802007f8:	00813083          	ld	ra,8(sp)
    802007fc:	00013403          	ld	s0,0(sp)
    80200800:	01010113          	addi	sp,sp,16
    80200804:	00008067          	ret

0000000080200808 <schedule>:

void schedule() {
    80200808:	fd010113          	addi	sp,sp,-48
    8020080c:	02113423          	sd	ra,40(sp)
    80200810:	02813023          	sd	s0,32(sp)
    80200814:	03010413          	addi	s0,sp,48
    //如果所有线程 counter 都为 0，则令所有线程 counter = priority
    int flag = 0;
    80200818:	fe042623          	sw	zero,-20(s0)
    for(int i = 1; i < NR_TASKS; i++)
    8020081c:	00100793          	li	a5,1
    80200820:	fef42423          	sw	a5,-24(s0)
    80200824:	03c0006f          	j	80200860 <schedule+0x58>
    {
        if(task[i]->counter != 0)
    80200828:	00004717          	auipc	a4,0x4
    8020082c:	7f070713          	addi	a4,a4,2032 # 80205018 <task>
    80200830:	fe842783          	lw	a5,-24(s0)
    80200834:	00379793          	slli	a5,a5,0x3
    80200838:	00f707b3          	add	a5,a4,a5
    8020083c:	0007b783          	ld	a5,0(a5)
    80200840:	0087b783          	ld	a5,8(a5)
    80200844:	00078863          	beqz	a5,80200854 <schedule+0x4c>
        {
            flag = 1;
    80200848:	00100793          	li	a5,1
    8020084c:	fef42623          	sw	a5,-20(s0)
            break;
    80200850:	0200006f          	j	80200870 <schedule+0x68>
    for(int i = 1; i < NR_TASKS; i++)
    80200854:	fe842783          	lw	a5,-24(s0)
    80200858:	0017879b          	addiw	a5,a5,1
    8020085c:	fef42423          	sw	a5,-24(s0)
    80200860:	fe842783          	lw	a5,-24(s0)
    80200864:	0007871b          	sext.w	a4,a5
    80200868:	01f00793          	li	a5,31
    8020086c:	fae7dee3          	bge	a5,a4,80200828 <schedule+0x20>
        }
    }
    if(flag == 0)
    80200870:	fec42783          	lw	a5,-20(s0)
    80200874:	0007879b          	sext.w	a5,a5
    80200878:	0c079a63          	bnez	a5,8020094c <schedule+0x144>
    {
        printk("\n");
    8020087c:	00002517          	auipc	a0,0x2
    80200880:	81c50513          	addi	a0,a0,-2020 # 80202098 <_srodata+0x98>
    80200884:	2d8010ef          	jal	80201b5c <printk>
        for(int i = 1; i < NR_TASKS; i++)
    80200888:	00100793          	li	a5,1
    8020088c:	fef42223          	sw	a5,-28(s0)
    80200890:	0ac0006f          	j	8020093c <schedule+0x134>
        {
            task[i]->counter = task[i]->priority;
    80200894:	00004717          	auipc	a4,0x4
    80200898:	78470713          	addi	a4,a4,1924 # 80205018 <task>
    8020089c:	fe442783          	lw	a5,-28(s0)
    802008a0:	00379793          	slli	a5,a5,0x3
    802008a4:	00f707b3          	add	a5,a4,a5
    802008a8:	0007b703          	ld	a4,0(a5)
    802008ac:	00004697          	auipc	a3,0x4
    802008b0:	76c68693          	addi	a3,a3,1900 # 80205018 <task>
    802008b4:	fe442783          	lw	a5,-28(s0)
    802008b8:	00379793          	slli	a5,a5,0x3
    802008bc:	00f687b3          	add	a5,a3,a5
    802008c0:	0007b783          	ld	a5,0(a5)
    802008c4:	01073703          	ld	a4,16(a4)
    802008c8:	00e7b423          	sd	a4,8(a5)
            printk("SET [PID = %d PRIORITY = %d COUNTER = %d]\n", task[i]->pid, task[i]->priority, task[i]->counter);
    802008cc:	00004717          	auipc	a4,0x4
    802008d0:	74c70713          	addi	a4,a4,1868 # 80205018 <task>
    802008d4:	fe442783          	lw	a5,-28(s0)
    802008d8:	00379793          	slli	a5,a5,0x3
    802008dc:	00f707b3          	add	a5,a4,a5
    802008e0:	0007b783          	ld	a5,0(a5)
    802008e4:	0187b583          	ld	a1,24(a5)
    802008e8:	00004717          	auipc	a4,0x4
    802008ec:	73070713          	addi	a4,a4,1840 # 80205018 <task>
    802008f0:	fe442783          	lw	a5,-28(s0)
    802008f4:	00379793          	slli	a5,a5,0x3
    802008f8:	00f707b3          	add	a5,a4,a5
    802008fc:	0007b783          	ld	a5,0(a5)
    80200900:	0107b603          	ld	a2,16(a5)
    80200904:	00004717          	auipc	a4,0x4
    80200908:	71470713          	addi	a4,a4,1812 # 80205018 <task>
    8020090c:	fe442783          	lw	a5,-28(s0)
    80200910:	00379793          	slli	a5,a5,0x3
    80200914:	00f707b3          	add	a5,a4,a5
    80200918:	0007b783          	ld	a5,0(a5)
    8020091c:	0087b783          	ld	a5,8(a5)
    80200920:	00078693          	mv	a3,a5
    80200924:	00001517          	auipc	a0,0x1
    80200928:	77c50513          	addi	a0,a0,1916 # 802020a0 <_srodata+0xa0>
    8020092c:	230010ef          	jal	80201b5c <printk>
        for(int i = 1; i < NR_TASKS; i++)
    80200930:	fe442783          	lw	a5,-28(s0)
    80200934:	0017879b          	addiw	a5,a5,1
    80200938:	fef42223          	sw	a5,-28(s0)
    8020093c:	fe442783          	lw	a5,-28(s0)
    80200940:	0007871b          	sext.w	a4,a5
    80200944:	01f00793          	li	a5,31
    80200948:	f4e7d6e3          	bge	a5,a4,80200894 <schedule+0x8c>
        }
            
    }
    //调度时选择 counter 最大的线程运行
    int max = 0;
    8020094c:	fe042023          	sw	zero,-32(s0)
    int next = 0;
    80200950:	fc042e23          	sw	zero,-36(s0)
    for(int i = 1; i < NR_TASKS; i++)
    80200954:	00100793          	li	a5,1
    80200958:	fcf42c23          	sw	a5,-40(s0)
    8020095c:	05c0006f          	j	802009b8 <schedule+0x1b0>
    {
        if(task[i]->counter > max)
    80200960:	00004717          	auipc	a4,0x4
    80200964:	6b870713          	addi	a4,a4,1720 # 80205018 <task>
    80200968:	fd842783          	lw	a5,-40(s0)
    8020096c:	00379793          	slli	a5,a5,0x3
    80200970:	00f707b3          	add	a5,a4,a5
    80200974:	0007b783          	ld	a5,0(a5)
    80200978:	0087b703          	ld	a4,8(a5)
    8020097c:	fe042783          	lw	a5,-32(s0)
    80200980:	02e7f663          	bgeu	a5,a4,802009ac <schedule+0x1a4>
        {
            max = task[i]->counter;
    80200984:	00004717          	auipc	a4,0x4
    80200988:	69470713          	addi	a4,a4,1684 # 80205018 <task>
    8020098c:	fd842783          	lw	a5,-40(s0)
    80200990:	00379793          	slli	a5,a5,0x3
    80200994:	00f707b3          	add	a5,a4,a5
    80200998:	0007b783          	ld	a5,0(a5)
    8020099c:	0087b783          	ld	a5,8(a5)
    802009a0:	fef42023          	sw	a5,-32(s0)
            next = i;
    802009a4:	fd842783          	lw	a5,-40(s0)
    802009a8:	fcf42e23          	sw	a5,-36(s0)
    for(int i = 1; i < NR_TASKS; i++)
    802009ac:	fd842783          	lw	a5,-40(s0)
    802009b0:	0017879b          	addiw	a5,a5,1
    802009b4:	fcf42c23          	sw	a5,-40(s0)
    802009b8:	fd842783          	lw	a5,-40(s0)
    802009bc:	0007871b          	sext.w	a4,a5
    802009c0:	01f00793          	li	a5,31
    802009c4:	f8e7dee3          	bge	a5,a4,80200960 <schedule+0x158>
        }
    }
    
    switch_to(task[next]);
    802009c8:	00004717          	auipc	a4,0x4
    802009cc:	65070713          	addi	a4,a4,1616 # 80205018 <task>
    802009d0:	fdc42783          	lw	a5,-36(s0)
    802009d4:	00379793          	slli	a5,a5,0x3
    802009d8:	00f707b3          	add	a5,a4,a5
    802009dc:	0007b783          	ld	a5,0(a5)
    802009e0:	00078513          	mv	a0,a5
    802009e4:	cfdff0ef          	jal	802006e0 <switch_to>
    802009e8:	00000013          	nop
    802009ec:	02813083          	ld	ra,40(sp)
    802009f0:	02013403          	ld	s0,32(sp)
    802009f4:	03010113          	addi	sp,sp,48
    802009f8:	00008067          	ret

00000000802009fc <sbi_ecall>:
#include "stdint.h"
#include "sbi.h"

struct sbiret sbi_ecall(uint64_t eid, uint64_t fid,
                        uint64_t arg0, uint64_t arg1, uint64_t arg2,
                        uint64_t arg3, uint64_t arg4, uint64_t arg5) {
    802009fc:	f8010113          	addi	sp,sp,-128
    80200a00:	06813c23          	sd	s0,120(sp)
    80200a04:	06913823          	sd	s1,112(sp)
    80200a08:	07213423          	sd	s2,104(sp)
    80200a0c:	07313023          	sd	s3,96(sp)
    80200a10:	08010413          	addi	s0,sp,128
    80200a14:	faa43c23          	sd	a0,-72(s0)
    80200a18:	fab43823          	sd	a1,-80(s0)
    80200a1c:	fac43423          	sd	a2,-88(s0)
    80200a20:	fad43023          	sd	a3,-96(s0)
    80200a24:	f8e43c23          	sd	a4,-104(s0)
    80200a28:	f8f43823          	sd	a5,-112(s0)
    80200a2c:	f9043423          	sd	a6,-120(s0)
    80200a30:	f9143023          	sd	a7,-128(s0)
    struct sbiret ret;
	__asm__ volatile(
    80200a34:	fb843e03          	ld	t3,-72(s0)
    80200a38:	fb043e83          	ld	t4,-80(s0)
    80200a3c:	fa843f03          	ld	t5,-88(s0)
    80200a40:	fa043f83          	ld	t6,-96(s0)
    80200a44:	f9843283          	ld	t0,-104(s0)
    80200a48:	f9043483          	ld	s1,-112(s0)
    80200a4c:	f8843903          	ld	s2,-120(s0)
    80200a50:	f8043983          	ld	s3,-128(s0)
    80200a54:	000e0893          	mv	a7,t3
    80200a58:	000e8813          	mv	a6,t4
    80200a5c:	000f0513          	mv	a0,t5
    80200a60:	000f8593          	mv	a1,t6
    80200a64:	00028613          	mv	a2,t0
    80200a68:	00048693          	mv	a3,s1
    80200a6c:	00090713          	mv	a4,s2
    80200a70:	00098793          	mv	a5,s3
    80200a74:	00000073          	ecall
    80200a78:	00050e93          	mv	t4,a0
    80200a7c:	00058e13          	mv	t3,a1
    80200a80:	fdd43023          	sd	t4,-64(s0)
    80200a84:	fdc43423          	sd	t3,-56(s0)
		: [error] "=r"(ret.error), [value] "=r"(ret.value)
		: [eid] "r"(eid), [fid] "r"(fid), [arg0] "r"(arg0), [arg1] "r"(arg1),
		  [arg2] "r"(arg2), [arg3] "r"(arg3), [arg4] "r"(arg4), [arg5] "r"(arg5)
		: "memory","a0","a1","a2","a3","a4","a5","a6","a7"
		);
	return ret;
    80200a88:	fc043783          	ld	a5,-64(s0)
    80200a8c:	fcf43823          	sd	a5,-48(s0)
    80200a90:	fc843783          	ld	a5,-56(s0)
    80200a94:	fcf43c23          	sd	a5,-40(s0)
    80200a98:	fd043703          	ld	a4,-48(s0)
    80200a9c:	fd843783          	ld	a5,-40(s0)
    80200aa0:	00070313          	mv	t1,a4
    80200aa4:	00078393          	mv	t2,a5
    80200aa8:	00030713          	mv	a4,t1
    80200aac:	00038793          	mv	a5,t2
}
    80200ab0:	00070513          	mv	a0,a4
    80200ab4:	00078593          	mv	a1,a5
    80200ab8:	07813403          	ld	s0,120(sp)
    80200abc:	07013483          	ld	s1,112(sp)
    80200ac0:	06813903          	ld	s2,104(sp)
    80200ac4:	06013983          	ld	s3,96(sp)
    80200ac8:	08010113          	addi	sp,sp,128
    80200acc:	00008067          	ret

0000000080200ad0 <sbi_debug_console_write_byte>:

struct sbiret sbi_debug_console_write_byte(uint8_t byte) {
    80200ad0:	fe010113          	addi	sp,sp,-32
    80200ad4:	00113c23          	sd	ra,24(sp)
    80200ad8:	00813823          	sd	s0,16(sp)
    80200adc:	02010413          	addi	s0,sp,32
    80200ae0:	00050793          	mv	a5,a0
    80200ae4:	fef407a3          	sb	a5,-17(s0)
    sbi_ecall(SBI_DBCN_EXT, SBI_DBCN_WRITE_BYTE, byte, 0, 0, 0, 0, 0);
    80200ae8:	fef44603          	lbu	a2,-17(s0)
    80200aec:	00000893          	li	a7,0
    80200af0:	00000813          	li	a6,0
    80200af4:	00000793          	li	a5,0
    80200af8:	00000713          	li	a4,0
    80200afc:	00000693          	li	a3,0
    80200b00:	00200593          	li	a1,2
    80200b04:	44424537          	lui	a0,0x44424
    80200b08:	34e50513          	addi	a0,a0,846 # 4442434e <_skernel-0x3bddbcb2>
    80200b0c:	ef1ff0ef          	jal	802009fc <sbi_ecall>
}
    80200b10:	00000013          	nop
    80200b14:	00070513          	mv	a0,a4
    80200b18:	00078593          	mv	a1,a5
    80200b1c:	01813083          	ld	ra,24(sp)
    80200b20:	01013403          	ld	s0,16(sp)
    80200b24:	02010113          	addi	sp,sp,32
    80200b28:	00008067          	ret

0000000080200b2c <sbi_system_reset>:

struct sbiret sbi_system_reset(uint32_t reset_type, uint32_t reset_reason) {
    80200b2c:	fe010113          	addi	sp,sp,-32
    80200b30:	00113c23          	sd	ra,24(sp)
    80200b34:	00813823          	sd	s0,16(sp)
    80200b38:	02010413          	addi	s0,sp,32
    80200b3c:	00050793          	mv	a5,a0
    80200b40:	00058713          	mv	a4,a1
    80200b44:	fef42623          	sw	a5,-20(s0)
    80200b48:	00070793          	mv	a5,a4
    80200b4c:	fef42423          	sw	a5,-24(s0)
    sbi_ecall(SBI_SRST_EXT, SBI_SRST, reset_type, reset_reason, 0, 0, 0, 0);
    80200b50:	fec46603          	lwu	a2,-20(s0)
    80200b54:	fe846683          	lwu	a3,-24(s0)
    80200b58:	00000893          	li	a7,0
    80200b5c:	00000813          	li	a6,0
    80200b60:	00000793          	li	a5,0
    80200b64:	00000713          	li	a4,0
    80200b68:	00000593          	li	a1,0
    80200b6c:	53525537          	lui	a0,0x53525
    80200b70:	35450513          	addi	a0,a0,852 # 53525354 <_skernel-0x2ccdacac>
    80200b74:	e89ff0ef          	jal	802009fc <sbi_ecall>
}
    80200b78:	00000013          	nop
    80200b7c:	00070513          	mv	a0,a4
    80200b80:	00078593          	mv	a1,a5
    80200b84:	01813083          	ld	ra,24(sp)
    80200b88:	01013403          	ld	s0,16(sp)
    80200b8c:	02010113          	addi	sp,sp,32
    80200b90:	00008067          	ret

0000000080200b94 <sbi_set_timer>:

struct sbiret sbi_set_timer(uint64_t stime_value) {
    80200b94:	fe010113          	addi	sp,sp,-32
    80200b98:	00113c23          	sd	ra,24(sp)
    80200b9c:	00813823          	sd	s0,16(sp)
    80200ba0:	02010413          	addi	s0,sp,32
    80200ba4:	fea43423          	sd	a0,-24(s0)
    sbi_ecall(SBI_SET_TIMER_EXT, SBI_SET_TIMER, stime_value, 0, 0, 0, 0, 0);
    80200ba8:	00000893          	li	a7,0
    80200bac:	00000813          	li	a6,0
    80200bb0:	00000793          	li	a5,0
    80200bb4:	00000713          	li	a4,0
    80200bb8:	00000693          	li	a3,0
    80200bbc:	fe843603          	ld	a2,-24(s0)
    80200bc0:	00000593          	li	a1,0
    80200bc4:	54495537          	lui	a0,0x54495
    80200bc8:	d4550513          	addi	a0,a0,-699 # 54494d45 <_skernel-0x2bd6b2bb>
    80200bcc:	e31ff0ef          	jal	802009fc <sbi_ecall>
    80200bd0:	00000013          	nop
    80200bd4:	00070513          	mv	a0,a4
    80200bd8:	00078593          	mv	a1,a5
    80200bdc:	01813083          	ld	ra,24(sp)
    80200be0:	01013403          	ld	s0,16(sp)
    80200be4:	02010113          	addi	sp,sp,32
    80200be8:	00008067          	ret

0000000080200bec <trap_handler>:
#include "stdint.h"
#include "printk.h"

extern void clock_set_next_event();

void trap_handler(uint64_t scause, uint64_t sepc) {
    80200bec:	fe010113          	addi	sp,sp,-32
    80200bf0:	00113c23          	sd	ra,24(sp)
    80200bf4:	00813823          	sd	s0,16(sp)
    80200bf8:	02010413          	addi	s0,sp,32
    80200bfc:	fea43423          	sd	a0,-24(s0)
    80200c00:	feb43023          	sd	a1,-32(s0)
    // 通过 `scause` 判断trap类型
    if (scause >> 63){ 
    80200c04:	fe843783          	ld	a5,-24(s0)
    80200c08:	0007de63          	bgez	a5,80200c24 <trap_handler+0x38>
        // 如果是interrupt 判断是否是timer interrupt
        if (scause % 8 == 5) { 
    80200c0c:	fe843783          	ld	a5,-24(s0)
    80200c10:	0077f713          	andi	a4,a5,7
    80200c14:	00500793          	li	a5,5
    80200c18:	00f71663          	bne	a4,a5,80200c24 <trap_handler+0x38>
            // 如果是timer interrupt 则打印输出相关信息, 并通过 `clock_set_next_event()` 设置下一次时钟中断
            //printk("[S] Supervisor Mode Timer Interrupt\n"); 
            clock_set_next_event();
    80200c1c:	df8ff0ef          	jal	80200214 <clock_set_next_event>
            do_timer();
    80200c20:	b59ff0ef          	jal	80200778 <do_timer>
        }
    }
    // `clock_set_next_event()` 见 4.3.4 节
    // 其他interrupt / exception 可以直接忽略
    80200c24:	00000013          	nop
    80200c28:	01813083          	ld	ra,24(sp)
    80200c2c:	01013403          	ld	s0,16(sp)
    80200c30:	02010113          	addi	sp,sp,32
    80200c34:	00008067          	ret

0000000080200c38 <start_kernel>:
#include "printk.h"
//#include "defs.h"

extern void test();

int start_kernel() {
    80200c38:	ff010113          	addi	sp,sp,-16
    80200c3c:	00113423          	sd	ra,8(sp)
    80200c40:	00813023          	sd	s0,0(sp)
    80200c44:	01010413          	addi	s0,sp,16
    printk("2024");
    80200c48:	00001517          	auipc	a0,0x1
    80200c4c:	48850513          	addi	a0,a0,1160 # 802020d0 <_srodata+0xd0>
    80200c50:	70d000ef          	jal	80201b5c <printk>
    printk(" ZJU Operating System\n");
    80200c54:	00001517          	auipc	a0,0x1
    80200c58:	48450513          	addi	a0,a0,1156 # 802020d8 <_srodata+0xd8>
    80200c5c:	701000ef          	jal	80201b5c <printk>
    //uint64_t cr;
    //cr = csr_read(sstatus);
    //asm volatile("mv a6,%[cr]"::[cr]"r"(cr));
    //int cw = 30;
    //csr_write(sscratch, cw);
    test();
    80200c60:	01c000ef          	jal	80200c7c <test>
    return 0;
    80200c64:	00000793          	li	a5,0
}
    80200c68:	00078513          	mv	a0,a5
    80200c6c:	00813083          	ld	ra,8(sp)
    80200c70:	00013403          	ld	s0,0(sp)
    80200c74:	01010113          	addi	sp,sp,16
    80200c78:	00008067          	ret

0000000080200c7c <test>:
#include "printk.h"

void test() {
    80200c7c:	fe010113          	addi	sp,sp,-32
    80200c80:	00113c23          	sd	ra,24(sp)
    80200c84:	00813823          	sd	s0,16(sp)
    80200c88:	02010413          	addi	s0,sp,32
    int i = 0;
    80200c8c:	fe042623          	sw	zero,-20(s0)
    while (1) {
        if ((++i) % 320000000 == 0) {
    80200c90:	fec42783          	lw	a5,-20(s0)
    80200c94:	0017879b          	addiw	a5,a5,1
    80200c98:	fef42623          	sw	a5,-20(s0)
    80200c9c:	fec42783          	lw	a5,-20(s0)
    80200ca0:	00078713          	mv	a4,a5
    80200ca4:	1312d7b7          	lui	a5,0x1312d
    80200ca8:	02f767bb          	remw	a5,a4,a5
    80200cac:	0007879b          	sext.w	a5,a5
    80200cb0:	fe0790e3          	bnez	a5,80200c90 <test+0x14>
            printk("kernel is running!\n");
    80200cb4:	00001517          	auipc	a0,0x1
    80200cb8:	43c50513          	addi	a0,a0,1084 # 802020f0 <_srodata+0xf0>
    80200cbc:	6a1000ef          	jal	80201b5c <printk>
            i = 0;
    80200cc0:	fe042623          	sw	zero,-20(s0)
        if ((++i) % 320000000 == 0) {
    80200cc4:	fcdff06f          	j	80200c90 <test+0x14>

0000000080200cc8 <putc>:
// credit: 45gfg9 <45gfg9@45gfg9.net>

#include "printk.h"
#include "sbi.h"

int putc(int c) {
    80200cc8:	fe010113          	addi	sp,sp,-32
    80200ccc:	00113c23          	sd	ra,24(sp)
    80200cd0:	00813823          	sd	s0,16(sp)
    80200cd4:	02010413          	addi	s0,sp,32
    80200cd8:	00050793          	mv	a5,a0
    80200cdc:	fef42623          	sw	a5,-20(s0)
    sbi_debug_console_write_byte(c);
    80200ce0:	fec42783          	lw	a5,-20(s0)
    80200ce4:	0ff7f793          	zext.b	a5,a5
    80200ce8:	00078513          	mv	a0,a5
    80200cec:	de5ff0ef          	jal	80200ad0 <sbi_debug_console_write_byte>
    return (char)c;
    80200cf0:	fec42783          	lw	a5,-20(s0)
    80200cf4:	0ff7f793          	zext.b	a5,a5
    80200cf8:	0007879b          	sext.w	a5,a5
}
    80200cfc:	00078513          	mv	a0,a5
    80200d00:	01813083          	ld	ra,24(sp)
    80200d04:	01013403          	ld	s0,16(sp)
    80200d08:	02010113          	addi	sp,sp,32
    80200d0c:	00008067          	ret

0000000080200d10 <isspace>:
    bool sign;
    int width;
    int prec;
};

int isspace(int c) {
    80200d10:	fe010113          	addi	sp,sp,-32
    80200d14:	00813c23          	sd	s0,24(sp)
    80200d18:	02010413          	addi	s0,sp,32
    80200d1c:	00050793          	mv	a5,a0
    80200d20:	fef42623          	sw	a5,-20(s0)
    return c == ' ' || (c >= '\t' && c <= '\r');
    80200d24:	fec42783          	lw	a5,-20(s0)
    80200d28:	0007871b          	sext.w	a4,a5
    80200d2c:	02000793          	li	a5,32
    80200d30:	02f70263          	beq	a4,a5,80200d54 <isspace+0x44>
    80200d34:	fec42783          	lw	a5,-20(s0)
    80200d38:	0007871b          	sext.w	a4,a5
    80200d3c:	00800793          	li	a5,8
    80200d40:	00e7de63          	bge	a5,a4,80200d5c <isspace+0x4c>
    80200d44:	fec42783          	lw	a5,-20(s0)
    80200d48:	0007871b          	sext.w	a4,a5
    80200d4c:	00d00793          	li	a5,13
    80200d50:	00e7c663          	blt	a5,a4,80200d5c <isspace+0x4c>
    80200d54:	00100793          	li	a5,1
    80200d58:	0080006f          	j	80200d60 <isspace+0x50>
    80200d5c:	00000793          	li	a5,0
}
    80200d60:	00078513          	mv	a0,a5
    80200d64:	01813403          	ld	s0,24(sp)
    80200d68:	02010113          	addi	sp,sp,32
    80200d6c:	00008067          	ret

0000000080200d70 <strtol>:

long strtol(const char *restrict nptr, char **restrict endptr, int base) {
    80200d70:	fb010113          	addi	sp,sp,-80
    80200d74:	04113423          	sd	ra,72(sp)
    80200d78:	04813023          	sd	s0,64(sp)
    80200d7c:	05010413          	addi	s0,sp,80
    80200d80:	fca43423          	sd	a0,-56(s0)
    80200d84:	fcb43023          	sd	a1,-64(s0)
    80200d88:	00060793          	mv	a5,a2
    80200d8c:	faf42e23          	sw	a5,-68(s0)
    long ret = 0;
    80200d90:	fe043423          	sd	zero,-24(s0)
    bool neg = false;
    80200d94:	fe0403a3          	sb	zero,-25(s0)
    const char *p = nptr;
    80200d98:	fc843783          	ld	a5,-56(s0)
    80200d9c:	fcf43c23          	sd	a5,-40(s0)

    while (isspace(*p)) {
    80200da0:	0100006f          	j	80200db0 <strtol+0x40>
        p++;
    80200da4:	fd843783          	ld	a5,-40(s0)
    80200da8:	00178793          	addi	a5,a5,1 # 1312d001 <_skernel-0x6d0d2fff>
    80200dac:	fcf43c23          	sd	a5,-40(s0)
    while (isspace(*p)) {
    80200db0:	fd843783          	ld	a5,-40(s0)
    80200db4:	0007c783          	lbu	a5,0(a5)
    80200db8:	0007879b          	sext.w	a5,a5
    80200dbc:	00078513          	mv	a0,a5
    80200dc0:	f51ff0ef          	jal	80200d10 <isspace>
    80200dc4:	00050793          	mv	a5,a0
    80200dc8:	fc079ee3          	bnez	a5,80200da4 <strtol+0x34>
    }

    if (*p == '-') {
    80200dcc:	fd843783          	ld	a5,-40(s0)
    80200dd0:	0007c783          	lbu	a5,0(a5)
    80200dd4:	00078713          	mv	a4,a5
    80200dd8:	02d00793          	li	a5,45
    80200ddc:	00f71e63          	bne	a4,a5,80200df8 <strtol+0x88>
        neg = true;
    80200de0:	00100793          	li	a5,1
    80200de4:	fef403a3          	sb	a5,-25(s0)
        p++;
    80200de8:	fd843783          	ld	a5,-40(s0)
    80200dec:	00178793          	addi	a5,a5,1
    80200df0:	fcf43c23          	sd	a5,-40(s0)
    80200df4:	0240006f          	j	80200e18 <strtol+0xa8>
    } else if (*p == '+') {
    80200df8:	fd843783          	ld	a5,-40(s0)
    80200dfc:	0007c783          	lbu	a5,0(a5)
    80200e00:	00078713          	mv	a4,a5
    80200e04:	02b00793          	li	a5,43
    80200e08:	00f71863          	bne	a4,a5,80200e18 <strtol+0xa8>
        p++;
    80200e0c:	fd843783          	ld	a5,-40(s0)
    80200e10:	00178793          	addi	a5,a5,1
    80200e14:	fcf43c23          	sd	a5,-40(s0)
    }

    if (base == 0) {
    80200e18:	fbc42783          	lw	a5,-68(s0)
    80200e1c:	0007879b          	sext.w	a5,a5
    80200e20:	06079c63          	bnez	a5,80200e98 <strtol+0x128>
        if (*p == '0') {
    80200e24:	fd843783          	ld	a5,-40(s0)
    80200e28:	0007c783          	lbu	a5,0(a5)
    80200e2c:	00078713          	mv	a4,a5
    80200e30:	03000793          	li	a5,48
    80200e34:	04f71e63          	bne	a4,a5,80200e90 <strtol+0x120>
            p++;
    80200e38:	fd843783          	ld	a5,-40(s0)
    80200e3c:	00178793          	addi	a5,a5,1
    80200e40:	fcf43c23          	sd	a5,-40(s0)
            if (*p == 'x' || *p == 'X') {
    80200e44:	fd843783          	ld	a5,-40(s0)
    80200e48:	0007c783          	lbu	a5,0(a5)
    80200e4c:	00078713          	mv	a4,a5
    80200e50:	07800793          	li	a5,120
    80200e54:	00f70c63          	beq	a4,a5,80200e6c <strtol+0xfc>
    80200e58:	fd843783          	ld	a5,-40(s0)
    80200e5c:	0007c783          	lbu	a5,0(a5)
    80200e60:	00078713          	mv	a4,a5
    80200e64:	05800793          	li	a5,88
    80200e68:	00f71e63          	bne	a4,a5,80200e84 <strtol+0x114>
                base = 16;
    80200e6c:	01000793          	li	a5,16
    80200e70:	faf42e23          	sw	a5,-68(s0)
                p++;
    80200e74:	fd843783          	ld	a5,-40(s0)
    80200e78:	00178793          	addi	a5,a5,1
    80200e7c:	fcf43c23          	sd	a5,-40(s0)
    80200e80:	0180006f          	j	80200e98 <strtol+0x128>
            } else {
                base = 8;
    80200e84:	00800793          	li	a5,8
    80200e88:	faf42e23          	sw	a5,-68(s0)
    80200e8c:	00c0006f          	j	80200e98 <strtol+0x128>
            }
        } else {
            base = 10;
    80200e90:	00a00793          	li	a5,10
    80200e94:	faf42e23          	sw	a5,-68(s0)
        }
    }

    while (1) {
        int digit;
        if (*p >= '0' && *p <= '9') {
    80200e98:	fd843783          	ld	a5,-40(s0)
    80200e9c:	0007c783          	lbu	a5,0(a5)
    80200ea0:	00078713          	mv	a4,a5
    80200ea4:	02f00793          	li	a5,47
    80200ea8:	02e7f863          	bgeu	a5,a4,80200ed8 <strtol+0x168>
    80200eac:	fd843783          	ld	a5,-40(s0)
    80200eb0:	0007c783          	lbu	a5,0(a5)
    80200eb4:	00078713          	mv	a4,a5
    80200eb8:	03900793          	li	a5,57
    80200ebc:	00e7ee63          	bltu	a5,a4,80200ed8 <strtol+0x168>
            digit = *p - '0';
    80200ec0:	fd843783          	ld	a5,-40(s0)
    80200ec4:	0007c783          	lbu	a5,0(a5)
    80200ec8:	0007879b          	sext.w	a5,a5
    80200ecc:	fd07879b          	addiw	a5,a5,-48
    80200ed0:	fcf42a23          	sw	a5,-44(s0)
    80200ed4:	0800006f          	j	80200f54 <strtol+0x1e4>
        } else if (*p >= 'a' && *p <= 'z') {
    80200ed8:	fd843783          	ld	a5,-40(s0)
    80200edc:	0007c783          	lbu	a5,0(a5)
    80200ee0:	00078713          	mv	a4,a5
    80200ee4:	06000793          	li	a5,96
    80200ee8:	02e7f863          	bgeu	a5,a4,80200f18 <strtol+0x1a8>
    80200eec:	fd843783          	ld	a5,-40(s0)
    80200ef0:	0007c783          	lbu	a5,0(a5)
    80200ef4:	00078713          	mv	a4,a5
    80200ef8:	07a00793          	li	a5,122
    80200efc:	00e7ee63          	bltu	a5,a4,80200f18 <strtol+0x1a8>
            digit = *p - ('a' - 10);
    80200f00:	fd843783          	ld	a5,-40(s0)
    80200f04:	0007c783          	lbu	a5,0(a5)
    80200f08:	0007879b          	sext.w	a5,a5
    80200f0c:	fa97879b          	addiw	a5,a5,-87
    80200f10:	fcf42a23          	sw	a5,-44(s0)
    80200f14:	0400006f          	j	80200f54 <strtol+0x1e4>
        } else if (*p >= 'A' && *p <= 'Z') {
    80200f18:	fd843783          	ld	a5,-40(s0)
    80200f1c:	0007c783          	lbu	a5,0(a5)
    80200f20:	00078713          	mv	a4,a5
    80200f24:	04000793          	li	a5,64
    80200f28:	06e7f863          	bgeu	a5,a4,80200f98 <strtol+0x228>
    80200f2c:	fd843783          	ld	a5,-40(s0)
    80200f30:	0007c783          	lbu	a5,0(a5)
    80200f34:	00078713          	mv	a4,a5
    80200f38:	05a00793          	li	a5,90
    80200f3c:	04e7ee63          	bltu	a5,a4,80200f98 <strtol+0x228>
            digit = *p - ('A' - 10);
    80200f40:	fd843783          	ld	a5,-40(s0)
    80200f44:	0007c783          	lbu	a5,0(a5)
    80200f48:	0007879b          	sext.w	a5,a5
    80200f4c:	fc97879b          	addiw	a5,a5,-55
    80200f50:	fcf42a23          	sw	a5,-44(s0)
        } else {
            break;
        }

        if (digit >= base) {
    80200f54:	fd442783          	lw	a5,-44(s0)
    80200f58:	00078713          	mv	a4,a5
    80200f5c:	fbc42783          	lw	a5,-68(s0)
    80200f60:	0007071b          	sext.w	a4,a4
    80200f64:	0007879b          	sext.w	a5,a5
    80200f68:	02f75663          	bge	a4,a5,80200f94 <strtol+0x224>
            break;
        }

        ret = ret * base + digit;
    80200f6c:	fbc42703          	lw	a4,-68(s0)
    80200f70:	fe843783          	ld	a5,-24(s0)
    80200f74:	02f70733          	mul	a4,a4,a5
    80200f78:	fd442783          	lw	a5,-44(s0)
    80200f7c:	00f707b3          	add	a5,a4,a5
    80200f80:	fef43423          	sd	a5,-24(s0)
        p++;
    80200f84:	fd843783          	ld	a5,-40(s0)
    80200f88:	00178793          	addi	a5,a5,1
    80200f8c:	fcf43c23          	sd	a5,-40(s0)
    while (1) {
    80200f90:	f09ff06f          	j	80200e98 <strtol+0x128>
            break;
    80200f94:	00000013          	nop
    }

    if (endptr) {
    80200f98:	fc043783          	ld	a5,-64(s0)
    80200f9c:	00078863          	beqz	a5,80200fac <strtol+0x23c>
        *endptr = (char *)p;
    80200fa0:	fc043783          	ld	a5,-64(s0)
    80200fa4:	fd843703          	ld	a4,-40(s0)
    80200fa8:	00e7b023          	sd	a4,0(a5)
    }

    return neg ? -ret : ret;
    80200fac:	fe744783          	lbu	a5,-25(s0)
    80200fb0:	0ff7f793          	zext.b	a5,a5
    80200fb4:	00078863          	beqz	a5,80200fc4 <strtol+0x254>
    80200fb8:	fe843783          	ld	a5,-24(s0)
    80200fbc:	40f007b3          	neg	a5,a5
    80200fc0:	0080006f          	j	80200fc8 <strtol+0x258>
    80200fc4:	fe843783          	ld	a5,-24(s0)
}
    80200fc8:	00078513          	mv	a0,a5
    80200fcc:	04813083          	ld	ra,72(sp)
    80200fd0:	04013403          	ld	s0,64(sp)
    80200fd4:	05010113          	addi	sp,sp,80
    80200fd8:	00008067          	ret

0000000080200fdc <puts_wo_nl>:

// puts without newline
static int puts_wo_nl(int (*putch)(int), const char *s) {
    80200fdc:	fd010113          	addi	sp,sp,-48
    80200fe0:	02113423          	sd	ra,40(sp)
    80200fe4:	02813023          	sd	s0,32(sp)
    80200fe8:	03010413          	addi	s0,sp,48
    80200fec:	fca43c23          	sd	a0,-40(s0)
    80200ff0:	fcb43823          	sd	a1,-48(s0)
    if (!s) {
    80200ff4:	fd043783          	ld	a5,-48(s0)
    80200ff8:	00079863          	bnez	a5,80201008 <puts_wo_nl+0x2c>
        s = "(null)";
    80200ffc:	00001797          	auipc	a5,0x1
    80201000:	10c78793          	addi	a5,a5,268 # 80202108 <_srodata+0x108>
    80201004:	fcf43823          	sd	a5,-48(s0)
    }
    const char *p = s;
    80201008:	fd043783          	ld	a5,-48(s0)
    8020100c:	fef43423          	sd	a5,-24(s0)
    while (*p) {
    80201010:	0240006f          	j	80201034 <puts_wo_nl+0x58>
        putch(*p++);
    80201014:	fe843783          	ld	a5,-24(s0)
    80201018:	00178713          	addi	a4,a5,1
    8020101c:	fee43423          	sd	a4,-24(s0)
    80201020:	0007c783          	lbu	a5,0(a5)
    80201024:	0007871b          	sext.w	a4,a5
    80201028:	fd843783          	ld	a5,-40(s0)
    8020102c:	00070513          	mv	a0,a4
    80201030:	000780e7          	jalr	a5
    while (*p) {
    80201034:	fe843783          	ld	a5,-24(s0)
    80201038:	0007c783          	lbu	a5,0(a5)
    8020103c:	fc079ce3          	bnez	a5,80201014 <puts_wo_nl+0x38>
    }
    return p - s;
    80201040:	fe843703          	ld	a4,-24(s0)
    80201044:	fd043783          	ld	a5,-48(s0)
    80201048:	40f707b3          	sub	a5,a4,a5
    8020104c:	0007879b          	sext.w	a5,a5
}
    80201050:	00078513          	mv	a0,a5
    80201054:	02813083          	ld	ra,40(sp)
    80201058:	02013403          	ld	s0,32(sp)
    8020105c:	03010113          	addi	sp,sp,48
    80201060:	00008067          	ret

0000000080201064 <print_dec_int>:

static int print_dec_int(int (*putch)(int), unsigned long num, bool is_signed, struct fmt_flags *flags) {
    80201064:	f9010113          	addi	sp,sp,-112
    80201068:	06113423          	sd	ra,104(sp)
    8020106c:	06813023          	sd	s0,96(sp)
    80201070:	07010413          	addi	s0,sp,112
    80201074:	faa43423          	sd	a0,-88(s0)
    80201078:	fab43023          	sd	a1,-96(s0)
    8020107c:	00060793          	mv	a5,a2
    80201080:	f8d43823          	sd	a3,-112(s0)
    80201084:	f8f40fa3          	sb	a5,-97(s0)
    if (is_signed && num == 0x8000000000000000UL) {
    80201088:	f9f44783          	lbu	a5,-97(s0)
    8020108c:	0ff7f793          	zext.b	a5,a5
    80201090:	02078663          	beqz	a5,802010bc <print_dec_int+0x58>
    80201094:	fa043703          	ld	a4,-96(s0)
    80201098:	fff00793          	li	a5,-1
    8020109c:	03f79793          	slli	a5,a5,0x3f
    802010a0:	00f71e63          	bne	a4,a5,802010bc <print_dec_int+0x58>
        // special case for 0x8000000000000000
        return puts_wo_nl(putch, "-9223372036854775808");
    802010a4:	00001597          	auipc	a1,0x1
    802010a8:	06c58593          	addi	a1,a1,108 # 80202110 <_srodata+0x110>
    802010ac:	fa843503          	ld	a0,-88(s0)
    802010b0:	f2dff0ef          	jal	80200fdc <puts_wo_nl>
    802010b4:	00050793          	mv	a5,a0
    802010b8:	2a00006f          	j	80201358 <print_dec_int+0x2f4>
    }

    if (flags->prec == 0 && num == 0) {
    802010bc:	f9043783          	ld	a5,-112(s0)
    802010c0:	00c7a783          	lw	a5,12(a5)
    802010c4:	00079a63          	bnez	a5,802010d8 <print_dec_int+0x74>
    802010c8:	fa043783          	ld	a5,-96(s0)
    802010cc:	00079663          	bnez	a5,802010d8 <print_dec_int+0x74>
        return 0;
    802010d0:	00000793          	li	a5,0
    802010d4:	2840006f          	j	80201358 <print_dec_int+0x2f4>
    }

    bool neg = false;
    802010d8:	fe0407a3          	sb	zero,-17(s0)

    if (is_signed && (long)num < 0) {
    802010dc:	f9f44783          	lbu	a5,-97(s0)
    802010e0:	0ff7f793          	zext.b	a5,a5
    802010e4:	02078063          	beqz	a5,80201104 <print_dec_int+0xa0>
    802010e8:	fa043783          	ld	a5,-96(s0)
    802010ec:	0007dc63          	bgez	a5,80201104 <print_dec_int+0xa0>
        neg = true;
    802010f0:	00100793          	li	a5,1
    802010f4:	fef407a3          	sb	a5,-17(s0)
        num = -num;
    802010f8:	fa043783          	ld	a5,-96(s0)
    802010fc:	40f007b3          	neg	a5,a5
    80201100:	faf43023          	sd	a5,-96(s0)
    }

    char buf[20];
    int decdigits = 0;
    80201104:	fe042423          	sw	zero,-24(s0)

    bool has_sign_char = is_signed && (neg || flags->sign || flags->spaceflag);
    80201108:	f9f44783          	lbu	a5,-97(s0)
    8020110c:	0ff7f793          	zext.b	a5,a5
    80201110:	02078863          	beqz	a5,80201140 <print_dec_int+0xdc>
    80201114:	fef44783          	lbu	a5,-17(s0)
    80201118:	0ff7f793          	zext.b	a5,a5
    8020111c:	00079e63          	bnez	a5,80201138 <print_dec_int+0xd4>
    80201120:	f9043783          	ld	a5,-112(s0)
    80201124:	0057c783          	lbu	a5,5(a5)
    80201128:	00079863          	bnez	a5,80201138 <print_dec_int+0xd4>
    8020112c:	f9043783          	ld	a5,-112(s0)
    80201130:	0047c783          	lbu	a5,4(a5)
    80201134:	00078663          	beqz	a5,80201140 <print_dec_int+0xdc>
    80201138:	00100793          	li	a5,1
    8020113c:	0080006f          	j	80201144 <print_dec_int+0xe0>
    80201140:	00000793          	li	a5,0
    80201144:	fcf40ba3          	sb	a5,-41(s0)
    80201148:	fd744783          	lbu	a5,-41(s0)
    8020114c:	0017f793          	andi	a5,a5,1
    80201150:	fcf40ba3          	sb	a5,-41(s0)

    do {
        buf[decdigits++] = num % 10 + '0';
    80201154:	fa043703          	ld	a4,-96(s0)
    80201158:	00a00793          	li	a5,10
    8020115c:	02f777b3          	remu	a5,a4,a5
    80201160:	0ff7f713          	zext.b	a4,a5
    80201164:	fe842783          	lw	a5,-24(s0)
    80201168:	0017869b          	addiw	a3,a5,1
    8020116c:	fed42423          	sw	a3,-24(s0)
    80201170:	0307071b          	addiw	a4,a4,48
    80201174:	0ff77713          	zext.b	a4,a4
    80201178:	ff078793          	addi	a5,a5,-16
    8020117c:	008787b3          	add	a5,a5,s0
    80201180:	fce78423          	sb	a4,-56(a5)
        num /= 10;
    80201184:	fa043703          	ld	a4,-96(s0)
    80201188:	00a00793          	li	a5,10
    8020118c:	02f757b3          	divu	a5,a4,a5
    80201190:	faf43023          	sd	a5,-96(s0)
    } while (num);
    80201194:	fa043783          	ld	a5,-96(s0)
    80201198:	fa079ee3          	bnez	a5,80201154 <print_dec_int+0xf0>

    if (flags->prec == -1 && flags->zeroflag) {
    8020119c:	f9043783          	ld	a5,-112(s0)
    802011a0:	00c7a783          	lw	a5,12(a5)
    802011a4:	00078713          	mv	a4,a5
    802011a8:	fff00793          	li	a5,-1
    802011ac:	02f71063          	bne	a4,a5,802011cc <print_dec_int+0x168>
    802011b0:	f9043783          	ld	a5,-112(s0)
    802011b4:	0037c783          	lbu	a5,3(a5)
    802011b8:	00078a63          	beqz	a5,802011cc <print_dec_int+0x168>
        flags->prec = flags->width;
    802011bc:	f9043783          	ld	a5,-112(s0)
    802011c0:	0087a703          	lw	a4,8(a5)
    802011c4:	f9043783          	ld	a5,-112(s0)
    802011c8:	00e7a623          	sw	a4,12(a5)
    }

    int written = 0;
    802011cc:	fe042223          	sw	zero,-28(s0)

    for (int i = flags->width - __MAX(decdigits, flags->prec) - has_sign_char; i > 0; i--) {
    802011d0:	f9043783          	ld	a5,-112(s0)
    802011d4:	0087a703          	lw	a4,8(a5)
    802011d8:	fe842783          	lw	a5,-24(s0)
    802011dc:	fcf42823          	sw	a5,-48(s0)
    802011e0:	f9043783          	ld	a5,-112(s0)
    802011e4:	00c7a783          	lw	a5,12(a5)
    802011e8:	fcf42623          	sw	a5,-52(s0)
    802011ec:	fd042783          	lw	a5,-48(s0)
    802011f0:	00078593          	mv	a1,a5
    802011f4:	fcc42783          	lw	a5,-52(s0)
    802011f8:	00078613          	mv	a2,a5
    802011fc:	0006069b          	sext.w	a3,a2
    80201200:	0005879b          	sext.w	a5,a1
    80201204:	00f6d463          	bge	a3,a5,8020120c <print_dec_int+0x1a8>
    80201208:	00058613          	mv	a2,a1
    8020120c:	0006079b          	sext.w	a5,a2
    80201210:	40f707bb          	subw	a5,a4,a5
    80201214:	0007871b          	sext.w	a4,a5
    80201218:	fd744783          	lbu	a5,-41(s0)
    8020121c:	0007879b          	sext.w	a5,a5
    80201220:	40f707bb          	subw	a5,a4,a5
    80201224:	fef42023          	sw	a5,-32(s0)
    80201228:	0280006f          	j	80201250 <print_dec_int+0x1ec>
        putch(' ');
    8020122c:	fa843783          	ld	a5,-88(s0)
    80201230:	02000513          	li	a0,32
    80201234:	000780e7          	jalr	a5
        ++written;
    80201238:	fe442783          	lw	a5,-28(s0)
    8020123c:	0017879b          	addiw	a5,a5,1
    80201240:	fef42223          	sw	a5,-28(s0)
    for (int i = flags->width - __MAX(decdigits, flags->prec) - has_sign_char; i > 0; i--) {
    80201244:	fe042783          	lw	a5,-32(s0)
    80201248:	fff7879b          	addiw	a5,a5,-1
    8020124c:	fef42023          	sw	a5,-32(s0)
    80201250:	fe042783          	lw	a5,-32(s0)
    80201254:	0007879b          	sext.w	a5,a5
    80201258:	fcf04ae3          	bgtz	a5,8020122c <print_dec_int+0x1c8>
    }

    if (has_sign_char) {
    8020125c:	fd744783          	lbu	a5,-41(s0)
    80201260:	0ff7f793          	zext.b	a5,a5
    80201264:	04078463          	beqz	a5,802012ac <print_dec_int+0x248>
        putch(neg ? '-' : flags->sign ? '+' : ' ');
    80201268:	fef44783          	lbu	a5,-17(s0)
    8020126c:	0ff7f793          	zext.b	a5,a5
    80201270:	00078663          	beqz	a5,8020127c <print_dec_int+0x218>
    80201274:	02d00793          	li	a5,45
    80201278:	01c0006f          	j	80201294 <print_dec_int+0x230>
    8020127c:	f9043783          	ld	a5,-112(s0)
    80201280:	0057c783          	lbu	a5,5(a5)
    80201284:	00078663          	beqz	a5,80201290 <print_dec_int+0x22c>
    80201288:	02b00793          	li	a5,43
    8020128c:	0080006f          	j	80201294 <print_dec_int+0x230>
    80201290:	02000793          	li	a5,32
    80201294:	fa843703          	ld	a4,-88(s0)
    80201298:	00078513          	mv	a0,a5
    8020129c:	000700e7          	jalr	a4
        ++written;
    802012a0:	fe442783          	lw	a5,-28(s0)
    802012a4:	0017879b          	addiw	a5,a5,1
    802012a8:	fef42223          	sw	a5,-28(s0)
    }

    for (int i = decdigits; i < flags->prec - has_sign_char; i++) {
    802012ac:	fe842783          	lw	a5,-24(s0)
    802012b0:	fcf42e23          	sw	a5,-36(s0)
    802012b4:	0280006f          	j	802012dc <print_dec_int+0x278>
        putch('0');
    802012b8:	fa843783          	ld	a5,-88(s0)
    802012bc:	03000513          	li	a0,48
    802012c0:	000780e7          	jalr	a5
        ++written;
    802012c4:	fe442783          	lw	a5,-28(s0)
    802012c8:	0017879b          	addiw	a5,a5,1
    802012cc:	fef42223          	sw	a5,-28(s0)
    for (int i = decdigits; i < flags->prec - has_sign_char; i++) {
    802012d0:	fdc42783          	lw	a5,-36(s0)
    802012d4:	0017879b          	addiw	a5,a5,1
    802012d8:	fcf42e23          	sw	a5,-36(s0)
    802012dc:	f9043783          	ld	a5,-112(s0)
    802012e0:	00c7a703          	lw	a4,12(a5)
    802012e4:	fd744783          	lbu	a5,-41(s0)
    802012e8:	0007879b          	sext.w	a5,a5
    802012ec:	40f707bb          	subw	a5,a4,a5
    802012f0:	0007871b          	sext.w	a4,a5
    802012f4:	fdc42783          	lw	a5,-36(s0)
    802012f8:	0007879b          	sext.w	a5,a5
    802012fc:	fae7cee3          	blt	a5,a4,802012b8 <print_dec_int+0x254>
    }

    for (int i = decdigits - 1; i >= 0; i--) {
    80201300:	fe842783          	lw	a5,-24(s0)
    80201304:	fff7879b          	addiw	a5,a5,-1
    80201308:	fcf42c23          	sw	a5,-40(s0)
    8020130c:	03c0006f          	j	80201348 <print_dec_int+0x2e4>
        putch(buf[i]);
    80201310:	fd842783          	lw	a5,-40(s0)
    80201314:	ff078793          	addi	a5,a5,-16
    80201318:	008787b3          	add	a5,a5,s0
    8020131c:	fc87c783          	lbu	a5,-56(a5)
    80201320:	0007871b          	sext.w	a4,a5
    80201324:	fa843783          	ld	a5,-88(s0)
    80201328:	00070513          	mv	a0,a4
    8020132c:	000780e7          	jalr	a5
        ++written;
    80201330:	fe442783          	lw	a5,-28(s0)
    80201334:	0017879b          	addiw	a5,a5,1
    80201338:	fef42223          	sw	a5,-28(s0)
    for (int i = decdigits - 1; i >= 0; i--) {
    8020133c:	fd842783          	lw	a5,-40(s0)
    80201340:	fff7879b          	addiw	a5,a5,-1
    80201344:	fcf42c23          	sw	a5,-40(s0)
    80201348:	fd842783          	lw	a5,-40(s0)
    8020134c:	0007879b          	sext.w	a5,a5
    80201350:	fc07d0e3          	bgez	a5,80201310 <print_dec_int+0x2ac>
    }

    return written;
    80201354:	fe442783          	lw	a5,-28(s0)
}
    80201358:	00078513          	mv	a0,a5
    8020135c:	06813083          	ld	ra,104(sp)
    80201360:	06013403          	ld	s0,96(sp)
    80201364:	07010113          	addi	sp,sp,112
    80201368:	00008067          	ret

000000008020136c <vprintfmt>:

int vprintfmt(int (*putch)(int), const char *fmt, va_list vl) {
    8020136c:	f4010113          	addi	sp,sp,-192
    80201370:	0a113c23          	sd	ra,184(sp)
    80201374:	0a813823          	sd	s0,176(sp)
    80201378:	0c010413          	addi	s0,sp,192
    8020137c:	f4a43c23          	sd	a0,-168(s0)
    80201380:	f4b43823          	sd	a1,-176(s0)
    80201384:	f4c43423          	sd	a2,-184(s0)
    static const char lowerxdigits[] = "0123456789abcdef";
    static const char upperxdigits[] = "0123456789ABCDEF";

    struct fmt_flags flags = {};
    80201388:	f8043023          	sd	zero,-128(s0)
    8020138c:	f8043423          	sd	zero,-120(s0)

    int written = 0;
    80201390:	fe042623          	sw	zero,-20(s0)

    for (; *fmt; fmt++) {
    80201394:	7a40006f          	j	80201b38 <vprintfmt+0x7cc>
        if (flags.in_format) {
    80201398:	f8044783          	lbu	a5,-128(s0)
    8020139c:	72078e63          	beqz	a5,80201ad8 <vprintfmt+0x76c>
            if (*fmt == '#') {
    802013a0:	f5043783          	ld	a5,-176(s0)
    802013a4:	0007c783          	lbu	a5,0(a5)
    802013a8:	00078713          	mv	a4,a5
    802013ac:	02300793          	li	a5,35
    802013b0:	00f71863          	bne	a4,a5,802013c0 <vprintfmt+0x54>
                flags.sharpflag = true;
    802013b4:	00100793          	li	a5,1
    802013b8:	f8f40123          	sb	a5,-126(s0)
    802013bc:	7700006f          	j	80201b2c <vprintfmt+0x7c0>
            } else if (*fmt == '0') {
    802013c0:	f5043783          	ld	a5,-176(s0)
    802013c4:	0007c783          	lbu	a5,0(a5)
    802013c8:	00078713          	mv	a4,a5
    802013cc:	03000793          	li	a5,48
    802013d0:	00f71863          	bne	a4,a5,802013e0 <vprintfmt+0x74>
                flags.zeroflag = true;
    802013d4:	00100793          	li	a5,1
    802013d8:	f8f401a3          	sb	a5,-125(s0)
    802013dc:	7500006f          	j	80201b2c <vprintfmt+0x7c0>
            } else if (*fmt == 'l' || *fmt == 'z' || *fmt == 't' || *fmt == 'j') {
    802013e0:	f5043783          	ld	a5,-176(s0)
    802013e4:	0007c783          	lbu	a5,0(a5)
    802013e8:	00078713          	mv	a4,a5
    802013ec:	06c00793          	li	a5,108
    802013f0:	04f70063          	beq	a4,a5,80201430 <vprintfmt+0xc4>
    802013f4:	f5043783          	ld	a5,-176(s0)
    802013f8:	0007c783          	lbu	a5,0(a5)
    802013fc:	00078713          	mv	a4,a5
    80201400:	07a00793          	li	a5,122
    80201404:	02f70663          	beq	a4,a5,80201430 <vprintfmt+0xc4>
    80201408:	f5043783          	ld	a5,-176(s0)
    8020140c:	0007c783          	lbu	a5,0(a5)
    80201410:	00078713          	mv	a4,a5
    80201414:	07400793          	li	a5,116
    80201418:	00f70c63          	beq	a4,a5,80201430 <vprintfmt+0xc4>
    8020141c:	f5043783          	ld	a5,-176(s0)
    80201420:	0007c783          	lbu	a5,0(a5)
    80201424:	00078713          	mv	a4,a5
    80201428:	06a00793          	li	a5,106
    8020142c:	00f71863          	bne	a4,a5,8020143c <vprintfmt+0xd0>
                // l: long, z: size_t, t: ptrdiff_t, j: intmax_t
                flags.longflag = true;
    80201430:	00100793          	li	a5,1
    80201434:	f8f400a3          	sb	a5,-127(s0)
    80201438:	6f40006f          	j	80201b2c <vprintfmt+0x7c0>
            } else if (*fmt == '+') {
    8020143c:	f5043783          	ld	a5,-176(s0)
    80201440:	0007c783          	lbu	a5,0(a5)
    80201444:	00078713          	mv	a4,a5
    80201448:	02b00793          	li	a5,43
    8020144c:	00f71863          	bne	a4,a5,8020145c <vprintfmt+0xf0>
                flags.sign = true;
    80201450:	00100793          	li	a5,1
    80201454:	f8f402a3          	sb	a5,-123(s0)
    80201458:	6d40006f          	j	80201b2c <vprintfmt+0x7c0>
            } else if (*fmt == ' ') {
    8020145c:	f5043783          	ld	a5,-176(s0)
    80201460:	0007c783          	lbu	a5,0(a5)
    80201464:	00078713          	mv	a4,a5
    80201468:	02000793          	li	a5,32
    8020146c:	00f71863          	bne	a4,a5,8020147c <vprintfmt+0x110>
                flags.spaceflag = true;
    80201470:	00100793          	li	a5,1
    80201474:	f8f40223          	sb	a5,-124(s0)
    80201478:	6b40006f          	j	80201b2c <vprintfmt+0x7c0>
            } else if (*fmt == '*') {
    8020147c:	f5043783          	ld	a5,-176(s0)
    80201480:	0007c783          	lbu	a5,0(a5)
    80201484:	00078713          	mv	a4,a5
    80201488:	02a00793          	li	a5,42
    8020148c:	00f71e63          	bne	a4,a5,802014a8 <vprintfmt+0x13c>
                flags.width = va_arg(vl, int);
    80201490:	f4843783          	ld	a5,-184(s0)
    80201494:	00878713          	addi	a4,a5,8
    80201498:	f4e43423          	sd	a4,-184(s0)
    8020149c:	0007a783          	lw	a5,0(a5)
    802014a0:	f8f42423          	sw	a5,-120(s0)
    802014a4:	6880006f          	j	80201b2c <vprintfmt+0x7c0>
            } else if (*fmt >= '1' && *fmt <= '9') {
    802014a8:	f5043783          	ld	a5,-176(s0)
    802014ac:	0007c783          	lbu	a5,0(a5)
    802014b0:	00078713          	mv	a4,a5
    802014b4:	03000793          	li	a5,48
    802014b8:	04e7f663          	bgeu	a5,a4,80201504 <vprintfmt+0x198>
    802014bc:	f5043783          	ld	a5,-176(s0)
    802014c0:	0007c783          	lbu	a5,0(a5)
    802014c4:	00078713          	mv	a4,a5
    802014c8:	03900793          	li	a5,57
    802014cc:	02e7ec63          	bltu	a5,a4,80201504 <vprintfmt+0x198>
                flags.width = strtol(fmt, (char **)&fmt, 10);
    802014d0:	f5043783          	ld	a5,-176(s0)
    802014d4:	f5040713          	addi	a4,s0,-176
    802014d8:	00a00613          	li	a2,10
    802014dc:	00070593          	mv	a1,a4
    802014e0:	00078513          	mv	a0,a5
    802014e4:	88dff0ef          	jal	80200d70 <strtol>
    802014e8:	00050793          	mv	a5,a0
    802014ec:	0007879b          	sext.w	a5,a5
    802014f0:	f8f42423          	sw	a5,-120(s0)
                fmt--;
    802014f4:	f5043783          	ld	a5,-176(s0)
    802014f8:	fff78793          	addi	a5,a5,-1
    802014fc:	f4f43823          	sd	a5,-176(s0)
    80201500:	62c0006f          	j	80201b2c <vprintfmt+0x7c0>
            } else if (*fmt == '.') {
    80201504:	f5043783          	ld	a5,-176(s0)
    80201508:	0007c783          	lbu	a5,0(a5)
    8020150c:	00078713          	mv	a4,a5
    80201510:	02e00793          	li	a5,46
    80201514:	06f71863          	bne	a4,a5,80201584 <vprintfmt+0x218>
                fmt++;
    80201518:	f5043783          	ld	a5,-176(s0)
    8020151c:	00178793          	addi	a5,a5,1
    80201520:	f4f43823          	sd	a5,-176(s0)
                if (*fmt == '*') {
    80201524:	f5043783          	ld	a5,-176(s0)
    80201528:	0007c783          	lbu	a5,0(a5)
    8020152c:	00078713          	mv	a4,a5
    80201530:	02a00793          	li	a5,42
    80201534:	00f71e63          	bne	a4,a5,80201550 <vprintfmt+0x1e4>
                    flags.prec = va_arg(vl, int);
    80201538:	f4843783          	ld	a5,-184(s0)
    8020153c:	00878713          	addi	a4,a5,8
    80201540:	f4e43423          	sd	a4,-184(s0)
    80201544:	0007a783          	lw	a5,0(a5)
    80201548:	f8f42623          	sw	a5,-116(s0)
    8020154c:	5e00006f          	j	80201b2c <vprintfmt+0x7c0>
                } else {
                    flags.prec = strtol(fmt, (char **)&fmt, 10);
    80201550:	f5043783          	ld	a5,-176(s0)
    80201554:	f5040713          	addi	a4,s0,-176
    80201558:	00a00613          	li	a2,10
    8020155c:	00070593          	mv	a1,a4
    80201560:	00078513          	mv	a0,a5
    80201564:	80dff0ef          	jal	80200d70 <strtol>
    80201568:	00050793          	mv	a5,a0
    8020156c:	0007879b          	sext.w	a5,a5
    80201570:	f8f42623          	sw	a5,-116(s0)
                    fmt--;
    80201574:	f5043783          	ld	a5,-176(s0)
    80201578:	fff78793          	addi	a5,a5,-1
    8020157c:	f4f43823          	sd	a5,-176(s0)
    80201580:	5ac0006f          	j	80201b2c <vprintfmt+0x7c0>
                }
            } else if (*fmt == 'x' || *fmt == 'X' || *fmt == 'p') {
    80201584:	f5043783          	ld	a5,-176(s0)
    80201588:	0007c783          	lbu	a5,0(a5)
    8020158c:	00078713          	mv	a4,a5
    80201590:	07800793          	li	a5,120
    80201594:	02f70663          	beq	a4,a5,802015c0 <vprintfmt+0x254>
    80201598:	f5043783          	ld	a5,-176(s0)
    8020159c:	0007c783          	lbu	a5,0(a5)
    802015a0:	00078713          	mv	a4,a5
    802015a4:	05800793          	li	a5,88
    802015a8:	00f70c63          	beq	a4,a5,802015c0 <vprintfmt+0x254>
    802015ac:	f5043783          	ld	a5,-176(s0)
    802015b0:	0007c783          	lbu	a5,0(a5)
    802015b4:	00078713          	mv	a4,a5
    802015b8:	07000793          	li	a5,112
    802015bc:	30f71263          	bne	a4,a5,802018c0 <vprintfmt+0x554>
                bool is_long = *fmt == 'p' || flags.longflag;
    802015c0:	f5043783          	ld	a5,-176(s0)
    802015c4:	0007c783          	lbu	a5,0(a5)
    802015c8:	00078713          	mv	a4,a5
    802015cc:	07000793          	li	a5,112
    802015d0:	00f70663          	beq	a4,a5,802015dc <vprintfmt+0x270>
    802015d4:	f8144783          	lbu	a5,-127(s0)
    802015d8:	00078663          	beqz	a5,802015e4 <vprintfmt+0x278>
    802015dc:	00100793          	li	a5,1
    802015e0:	0080006f          	j	802015e8 <vprintfmt+0x27c>
    802015e4:	00000793          	li	a5,0
    802015e8:	faf403a3          	sb	a5,-89(s0)
    802015ec:	fa744783          	lbu	a5,-89(s0)
    802015f0:	0017f793          	andi	a5,a5,1
    802015f4:	faf403a3          	sb	a5,-89(s0)

                unsigned long num = is_long ? va_arg(vl, unsigned long) : va_arg(vl, unsigned int);
    802015f8:	fa744783          	lbu	a5,-89(s0)
    802015fc:	0ff7f793          	zext.b	a5,a5
    80201600:	00078c63          	beqz	a5,80201618 <vprintfmt+0x2ac>
    80201604:	f4843783          	ld	a5,-184(s0)
    80201608:	00878713          	addi	a4,a5,8
    8020160c:	f4e43423          	sd	a4,-184(s0)
    80201610:	0007b783          	ld	a5,0(a5)
    80201614:	01c0006f          	j	80201630 <vprintfmt+0x2c4>
    80201618:	f4843783          	ld	a5,-184(s0)
    8020161c:	00878713          	addi	a4,a5,8
    80201620:	f4e43423          	sd	a4,-184(s0)
    80201624:	0007a783          	lw	a5,0(a5)
    80201628:	02079793          	slli	a5,a5,0x20
    8020162c:	0207d793          	srli	a5,a5,0x20
    80201630:	fef43023          	sd	a5,-32(s0)

                if (flags.prec == 0 && num == 0 && *fmt != 'p') {
    80201634:	f8c42783          	lw	a5,-116(s0)
    80201638:	02079463          	bnez	a5,80201660 <vprintfmt+0x2f4>
    8020163c:	fe043783          	ld	a5,-32(s0)
    80201640:	02079063          	bnez	a5,80201660 <vprintfmt+0x2f4>
    80201644:	f5043783          	ld	a5,-176(s0)
    80201648:	0007c783          	lbu	a5,0(a5)
    8020164c:	00078713          	mv	a4,a5
    80201650:	07000793          	li	a5,112
    80201654:	00f70663          	beq	a4,a5,80201660 <vprintfmt+0x2f4>
                    flags.in_format = false;
    80201658:	f8040023          	sb	zero,-128(s0)
    8020165c:	4d00006f          	j	80201b2c <vprintfmt+0x7c0>
                    continue;
                }

                // 0x prefix for pointers, or, if # flag is set and non-zero
                bool prefix = *fmt == 'p' || (flags.sharpflag && num != 0);
    80201660:	f5043783          	ld	a5,-176(s0)
    80201664:	0007c783          	lbu	a5,0(a5)
    80201668:	00078713          	mv	a4,a5
    8020166c:	07000793          	li	a5,112
    80201670:	00f70a63          	beq	a4,a5,80201684 <vprintfmt+0x318>
    80201674:	f8244783          	lbu	a5,-126(s0)
    80201678:	00078a63          	beqz	a5,8020168c <vprintfmt+0x320>
    8020167c:	fe043783          	ld	a5,-32(s0)
    80201680:	00078663          	beqz	a5,8020168c <vprintfmt+0x320>
    80201684:	00100793          	li	a5,1
    80201688:	0080006f          	j	80201690 <vprintfmt+0x324>
    8020168c:	00000793          	li	a5,0
    80201690:	faf40323          	sb	a5,-90(s0)
    80201694:	fa644783          	lbu	a5,-90(s0)
    80201698:	0017f793          	andi	a5,a5,1
    8020169c:	faf40323          	sb	a5,-90(s0)

                int hexdigits = 0;
    802016a0:	fc042e23          	sw	zero,-36(s0)
                const char *xdigits = *fmt == 'X' ? upperxdigits : lowerxdigits;
    802016a4:	f5043783          	ld	a5,-176(s0)
    802016a8:	0007c783          	lbu	a5,0(a5)
    802016ac:	00078713          	mv	a4,a5
    802016b0:	05800793          	li	a5,88
    802016b4:	00f71863          	bne	a4,a5,802016c4 <vprintfmt+0x358>
    802016b8:	00001797          	auipc	a5,0x1
    802016bc:	a7078793          	addi	a5,a5,-1424 # 80202128 <upperxdigits.1>
    802016c0:	00c0006f          	j	802016cc <vprintfmt+0x360>
    802016c4:	00001797          	auipc	a5,0x1
    802016c8:	a7c78793          	addi	a5,a5,-1412 # 80202140 <lowerxdigits.0>
    802016cc:	f8f43c23          	sd	a5,-104(s0)
                char buf[2 * sizeof(unsigned long)];

                do {
                    buf[hexdigits++] = xdigits[num & 0xf];
    802016d0:	fe043783          	ld	a5,-32(s0)
    802016d4:	00f7f793          	andi	a5,a5,15
    802016d8:	f9843703          	ld	a4,-104(s0)
    802016dc:	00f70733          	add	a4,a4,a5
    802016e0:	fdc42783          	lw	a5,-36(s0)
    802016e4:	0017869b          	addiw	a3,a5,1
    802016e8:	fcd42e23          	sw	a3,-36(s0)
    802016ec:	00074703          	lbu	a4,0(a4)
    802016f0:	ff078793          	addi	a5,a5,-16
    802016f4:	008787b3          	add	a5,a5,s0
    802016f8:	f8e78023          	sb	a4,-128(a5)
                    num >>= 4;
    802016fc:	fe043783          	ld	a5,-32(s0)
    80201700:	0047d793          	srli	a5,a5,0x4
    80201704:	fef43023          	sd	a5,-32(s0)
                } while (num);
    80201708:	fe043783          	ld	a5,-32(s0)
    8020170c:	fc0792e3          	bnez	a5,802016d0 <vprintfmt+0x364>

                if (flags.prec == -1 && flags.zeroflag) {
    80201710:	f8c42783          	lw	a5,-116(s0)
    80201714:	00078713          	mv	a4,a5
    80201718:	fff00793          	li	a5,-1
    8020171c:	02f71663          	bne	a4,a5,80201748 <vprintfmt+0x3dc>
    80201720:	f8344783          	lbu	a5,-125(s0)
    80201724:	02078263          	beqz	a5,80201748 <vprintfmt+0x3dc>
                    flags.prec = flags.width - 2 * prefix;
    80201728:	f8842703          	lw	a4,-120(s0)
    8020172c:	fa644783          	lbu	a5,-90(s0)
    80201730:	0007879b          	sext.w	a5,a5
    80201734:	0017979b          	slliw	a5,a5,0x1
    80201738:	0007879b          	sext.w	a5,a5
    8020173c:	40f707bb          	subw	a5,a4,a5
    80201740:	0007879b          	sext.w	a5,a5
    80201744:	f8f42623          	sw	a5,-116(s0)
                }

                for (int i = flags.width - 2 * prefix - __MAX(hexdigits, flags.prec); i > 0; i--) {
    80201748:	f8842703          	lw	a4,-120(s0)
    8020174c:	fa644783          	lbu	a5,-90(s0)
    80201750:	0007879b          	sext.w	a5,a5
    80201754:	0017979b          	slliw	a5,a5,0x1
    80201758:	0007879b          	sext.w	a5,a5
    8020175c:	40f707bb          	subw	a5,a4,a5
    80201760:	0007871b          	sext.w	a4,a5
    80201764:	fdc42783          	lw	a5,-36(s0)
    80201768:	f8f42a23          	sw	a5,-108(s0)
    8020176c:	f8c42783          	lw	a5,-116(s0)
    80201770:	f8f42823          	sw	a5,-112(s0)
    80201774:	f9442783          	lw	a5,-108(s0)
    80201778:	00078593          	mv	a1,a5
    8020177c:	f9042783          	lw	a5,-112(s0)
    80201780:	00078613          	mv	a2,a5
    80201784:	0006069b          	sext.w	a3,a2
    80201788:	0005879b          	sext.w	a5,a1
    8020178c:	00f6d463          	bge	a3,a5,80201794 <vprintfmt+0x428>
    80201790:	00058613          	mv	a2,a1
    80201794:	0006079b          	sext.w	a5,a2
    80201798:	40f707bb          	subw	a5,a4,a5
    8020179c:	fcf42c23          	sw	a5,-40(s0)
    802017a0:	0280006f          	j	802017c8 <vprintfmt+0x45c>
                    putch(' ');
    802017a4:	f5843783          	ld	a5,-168(s0)
    802017a8:	02000513          	li	a0,32
    802017ac:	000780e7          	jalr	a5
                    ++written;
    802017b0:	fec42783          	lw	a5,-20(s0)
    802017b4:	0017879b          	addiw	a5,a5,1
    802017b8:	fef42623          	sw	a5,-20(s0)
                for (int i = flags.width - 2 * prefix - __MAX(hexdigits, flags.prec); i > 0; i--) {
    802017bc:	fd842783          	lw	a5,-40(s0)
    802017c0:	fff7879b          	addiw	a5,a5,-1
    802017c4:	fcf42c23          	sw	a5,-40(s0)
    802017c8:	fd842783          	lw	a5,-40(s0)
    802017cc:	0007879b          	sext.w	a5,a5
    802017d0:	fcf04ae3          	bgtz	a5,802017a4 <vprintfmt+0x438>
                }

                if (prefix) {
    802017d4:	fa644783          	lbu	a5,-90(s0)
    802017d8:	0ff7f793          	zext.b	a5,a5
    802017dc:	04078463          	beqz	a5,80201824 <vprintfmt+0x4b8>
                    putch('0');
    802017e0:	f5843783          	ld	a5,-168(s0)
    802017e4:	03000513          	li	a0,48
    802017e8:	000780e7          	jalr	a5
                    putch(*fmt == 'X' ? 'X' : 'x');
    802017ec:	f5043783          	ld	a5,-176(s0)
    802017f0:	0007c783          	lbu	a5,0(a5)
    802017f4:	00078713          	mv	a4,a5
    802017f8:	05800793          	li	a5,88
    802017fc:	00f71663          	bne	a4,a5,80201808 <vprintfmt+0x49c>
    80201800:	05800793          	li	a5,88
    80201804:	0080006f          	j	8020180c <vprintfmt+0x4a0>
    80201808:	07800793          	li	a5,120
    8020180c:	f5843703          	ld	a4,-168(s0)
    80201810:	00078513          	mv	a0,a5
    80201814:	000700e7          	jalr	a4
                    written += 2;
    80201818:	fec42783          	lw	a5,-20(s0)
    8020181c:	0027879b          	addiw	a5,a5,2
    80201820:	fef42623          	sw	a5,-20(s0)
                }

                for (int i = hexdigits; i < flags.prec; i++) {
    80201824:	fdc42783          	lw	a5,-36(s0)
    80201828:	fcf42a23          	sw	a5,-44(s0)
    8020182c:	0280006f          	j	80201854 <vprintfmt+0x4e8>
                    putch('0');
    80201830:	f5843783          	ld	a5,-168(s0)
    80201834:	03000513          	li	a0,48
    80201838:	000780e7          	jalr	a5
                    ++written;
    8020183c:	fec42783          	lw	a5,-20(s0)
    80201840:	0017879b          	addiw	a5,a5,1
    80201844:	fef42623          	sw	a5,-20(s0)
                for (int i = hexdigits; i < flags.prec; i++) {
    80201848:	fd442783          	lw	a5,-44(s0)
    8020184c:	0017879b          	addiw	a5,a5,1
    80201850:	fcf42a23          	sw	a5,-44(s0)
    80201854:	f8c42703          	lw	a4,-116(s0)
    80201858:	fd442783          	lw	a5,-44(s0)
    8020185c:	0007879b          	sext.w	a5,a5
    80201860:	fce7c8e3          	blt	a5,a4,80201830 <vprintfmt+0x4c4>
                }

                for (int i = hexdigits - 1; i >= 0; i--) {
    80201864:	fdc42783          	lw	a5,-36(s0)
    80201868:	fff7879b          	addiw	a5,a5,-1
    8020186c:	fcf42823          	sw	a5,-48(s0)
    80201870:	03c0006f          	j	802018ac <vprintfmt+0x540>
                    putch(buf[i]);
    80201874:	fd042783          	lw	a5,-48(s0)
    80201878:	ff078793          	addi	a5,a5,-16
    8020187c:	008787b3          	add	a5,a5,s0
    80201880:	f807c783          	lbu	a5,-128(a5)
    80201884:	0007871b          	sext.w	a4,a5
    80201888:	f5843783          	ld	a5,-168(s0)
    8020188c:	00070513          	mv	a0,a4
    80201890:	000780e7          	jalr	a5
                    ++written;
    80201894:	fec42783          	lw	a5,-20(s0)
    80201898:	0017879b          	addiw	a5,a5,1
    8020189c:	fef42623          	sw	a5,-20(s0)
                for (int i = hexdigits - 1; i >= 0; i--) {
    802018a0:	fd042783          	lw	a5,-48(s0)
    802018a4:	fff7879b          	addiw	a5,a5,-1
    802018a8:	fcf42823          	sw	a5,-48(s0)
    802018ac:	fd042783          	lw	a5,-48(s0)
    802018b0:	0007879b          	sext.w	a5,a5
    802018b4:	fc07d0e3          	bgez	a5,80201874 <vprintfmt+0x508>
                }

                flags.in_format = false;
    802018b8:	f8040023          	sb	zero,-128(s0)
            } else if (*fmt == 'x' || *fmt == 'X' || *fmt == 'p') {
    802018bc:	2700006f          	j	80201b2c <vprintfmt+0x7c0>
            } else if (*fmt == 'd' || *fmt == 'i' || *fmt == 'u') {
    802018c0:	f5043783          	ld	a5,-176(s0)
    802018c4:	0007c783          	lbu	a5,0(a5)
    802018c8:	00078713          	mv	a4,a5
    802018cc:	06400793          	li	a5,100
    802018d0:	02f70663          	beq	a4,a5,802018fc <vprintfmt+0x590>
    802018d4:	f5043783          	ld	a5,-176(s0)
    802018d8:	0007c783          	lbu	a5,0(a5)
    802018dc:	00078713          	mv	a4,a5
    802018e0:	06900793          	li	a5,105
    802018e4:	00f70c63          	beq	a4,a5,802018fc <vprintfmt+0x590>
    802018e8:	f5043783          	ld	a5,-176(s0)
    802018ec:	0007c783          	lbu	a5,0(a5)
    802018f0:	00078713          	mv	a4,a5
    802018f4:	07500793          	li	a5,117
    802018f8:	08f71063          	bne	a4,a5,80201978 <vprintfmt+0x60c>
                long num = flags.longflag ? va_arg(vl, long) : va_arg(vl, int);
    802018fc:	f8144783          	lbu	a5,-127(s0)
    80201900:	00078c63          	beqz	a5,80201918 <vprintfmt+0x5ac>
    80201904:	f4843783          	ld	a5,-184(s0)
    80201908:	00878713          	addi	a4,a5,8
    8020190c:	f4e43423          	sd	a4,-184(s0)
    80201910:	0007b783          	ld	a5,0(a5)
    80201914:	0140006f          	j	80201928 <vprintfmt+0x5bc>
    80201918:	f4843783          	ld	a5,-184(s0)
    8020191c:	00878713          	addi	a4,a5,8
    80201920:	f4e43423          	sd	a4,-184(s0)
    80201924:	0007a783          	lw	a5,0(a5)
    80201928:	faf43423          	sd	a5,-88(s0)

                written += print_dec_int(putch, num, *fmt != 'u', &flags);
    8020192c:	fa843583          	ld	a1,-88(s0)
    80201930:	f5043783          	ld	a5,-176(s0)
    80201934:	0007c783          	lbu	a5,0(a5)
    80201938:	0007871b          	sext.w	a4,a5
    8020193c:	07500793          	li	a5,117
    80201940:	40f707b3          	sub	a5,a4,a5
    80201944:	00f037b3          	snez	a5,a5
    80201948:	0ff7f793          	zext.b	a5,a5
    8020194c:	f8040713          	addi	a4,s0,-128
    80201950:	00070693          	mv	a3,a4
    80201954:	00078613          	mv	a2,a5
    80201958:	f5843503          	ld	a0,-168(s0)
    8020195c:	f08ff0ef          	jal	80201064 <print_dec_int>
    80201960:	00050793          	mv	a5,a0
    80201964:	fec42703          	lw	a4,-20(s0)
    80201968:	00f707bb          	addw	a5,a4,a5
    8020196c:	fef42623          	sw	a5,-20(s0)
                flags.in_format = false;
    80201970:	f8040023          	sb	zero,-128(s0)
            } else if (*fmt == 'd' || *fmt == 'i' || *fmt == 'u') {
    80201974:	1b80006f          	j	80201b2c <vprintfmt+0x7c0>
            } else if (*fmt == 'n') {
    80201978:	f5043783          	ld	a5,-176(s0)
    8020197c:	0007c783          	lbu	a5,0(a5)
    80201980:	00078713          	mv	a4,a5
    80201984:	06e00793          	li	a5,110
    80201988:	04f71c63          	bne	a4,a5,802019e0 <vprintfmt+0x674>
                if (flags.longflag) {
    8020198c:	f8144783          	lbu	a5,-127(s0)
    80201990:	02078463          	beqz	a5,802019b8 <vprintfmt+0x64c>
                    long *n = va_arg(vl, long *);
    80201994:	f4843783          	ld	a5,-184(s0)
    80201998:	00878713          	addi	a4,a5,8
    8020199c:	f4e43423          	sd	a4,-184(s0)
    802019a0:	0007b783          	ld	a5,0(a5)
    802019a4:	faf43823          	sd	a5,-80(s0)
                    *n = written;
    802019a8:	fec42703          	lw	a4,-20(s0)
    802019ac:	fb043783          	ld	a5,-80(s0)
    802019b0:	00e7b023          	sd	a4,0(a5)
    802019b4:	0240006f          	j	802019d8 <vprintfmt+0x66c>
                } else {
                    int *n = va_arg(vl, int *);
    802019b8:	f4843783          	ld	a5,-184(s0)
    802019bc:	00878713          	addi	a4,a5,8
    802019c0:	f4e43423          	sd	a4,-184(s0)
    802019c4:	0007b783          	ld	a5,0(a5)
    802019c8:	faf43c23          	sd	a5,-72(s0)
                    *n = written;
    802019cc:	fb843783          	ld	a5,-72(s0)
    802019d0:	fec42703          	lw	a4,-20(s0)
    802019d4:	00e7a023          	sw	a4,0(a5)
                }
                flags.in_format = false;
    802019d8:	f8040023          	sb	zero,-128(s0)
    802019dc:	1500006f          	j	80201b2c <vprintfmt+0x7c0>
            } else if (*fmt == 's') {
    802019e0:	f5043783          	ld	a5,-176(s0)
    802019e4:	0007c783          	lbu	a5,0(a5)
    802019e8:	00078713          	mv	a4,a5
    802019ec:	07300793          	li	a5,115
    802019f0:	02f71e63          	bne	a4,a5,80201a2c <vprintfmt+0x6c0>
                const char *s = va_arg(vl, const char *);
    802019f4:	f4843783          	ld	a5,-184(s0)
    802019f8:	00878713          	addi	a4,a5,8
    802019fc:	f4e43423          	sd	a4,-184(s0)
    80201a00:	0007b783          	ld	a5,0(a5)
    80201a04:	fcf43023          	sd	a5,-64(s0)
                written += puts_wo_nl(putch, s);
    80201a08:	fc043583          	ld	a1,-64(s0)
    80201a0c:	f5843503          	ld	a0,-168(s0)
    80201a10:	dccff0ef          	jal	80200fdc <puts_wo_nl>
    80201a14:	00050793          	mv	a5,a0
    80201a18:	fec42703          	lw	a4,-20(s0)
    80201a1c:	00f707bb          	addw	a5,a4,a5
    80201a20:	fef42623          	sw	a5,-20(s0)
                flags.in_format = false;
    80201a24:	f8040023          	sb	zero,-128(s0)
    80201a28:	1040006f          	j	80201b2c <vprintfmt+0x7c0>
            } else if (*fmt == 'c') {
    80201a2c:	f5043783          	ld	a5,-176(s0)
    80201a30:	0007c783          	lbu	a5,0(a5)
    80201a34:	00078713          	mv	a4,a5
    80201a38:	06300793          	li	a5,99
    80201a3c:	02f71e63          	bne	a4,a5,80201a78 <vprintfmt+0x70c>
                int ch = va_arg(vl, int);
    80201a40:	f4843783          	ld	a5,-184(s0)
    80201a44:	00878713          	addi	a4,a5,8
    80201a48:	f4e43423          	sd	a4,-184(s0)
    80201a4c:	0007a783          	lw	a5,0(a5)
    80201a50:	fcf42623          	sw	a5,-52(s0)
                putch(ch);
    80201a54:	fcc42703          	lw	a4,-52(s0)
    80201a58:	f5843783          	ld	a5,-168(s0)
    80201a5c:	00070513          	mv	a0,a4
    80201a60:	000780e7          	jalr	a5
                ++written;
    80201a64:	fec42783          	lw	a5,-20(s0)
    80201a68:	0017879b          	addiw	a5,a5,1
    80201a6c:	fef42623          	sw	a5,-20(s0)
                flags.in_format = false;
    80201a70:	f8040023          	sb	zero,-128(s0)
    80201a74:	0b80006f          	j	80201b2c <vprintfmt+0x7c0>
            } else if (*fmt == '%') {
    80201a78:	f5043783          	ld	a5,-176(s0)
    80201a7c:	0007c783          	lbu	a5,0(a5)
    80201a80:	00078713          	mv	a4,a5
    80201a84:	02500793          	li	a5,37
    80201a88:	02f71263          	bne	a4,a5,80201aac <vprintfmt+0x740>
                putch('%');
    80201a8c:	f5843783          	ld	a5,-168(s0)
    80201a90:	02500513          	li	a0,37
    80201a94:	000780e7          	jalr	a5
                ++written;
    80201a98:	fec42783          	lw	a5,-20(s0)
    80201a9c:	0017879b          	addiw	a5,a5,1
    80201aa0:	fef42623          	sw	a5,-20(s0)
                flags.in_format = false;
    80201aa4:	f8040023          	sb	zero,-128(s0)
    80201aa8:	0840006f          	j	80201b2c <vprintfmt+0x7c0>
            } else {
                putch(*fmt);
    80201aac:	f5043783          	ld	a5,-176(s0)
    80201ab0:	0007c783          	lbu	a5,0(a5)
    80201ab4:	0007871b          	sext.w	a4,a5
    80201ab8:	f5843783          	ld	a5,-168(s0)
    80201abc:	00070513          	mv	a0,a4
    80201ac0:	000780e7          	jalr	a5
                ++written;
    80201ac4:	fec42783          	lw	a5,-20(s0)
    80201ac8:	0017879b          	addiw	a5,a5,1
    80201acc:	fef42623          	sw	a5,-20(s0)
                flags.in_format = false;
    80201ad0:	f8040023          	sb	zero,-128(s0)
    80201ad4:	0580006f          	j	80201b2c <vprintfmt+0x7c0>
            }
        } else if (*fmt == '%') {
    80201ad8:	f5043783          	ld	a5,-176(s0)
    80201adc:	0007c783          	lbu	a5,0(a5)
    80201ae0:	00078713          	mv	a4,a5
    80201ae4:	02500793          	li	a5,37
    80201ae8:	02f71063          	bne	a4,a5,80201b08 <vprintfmt+0x79c>
            flags = (struct fmt_flags) {.in_format = true, .prec = -1};
    80201aec:	f8043023          	sd	zero,-128(s0)
    80201af0:	f8043423          	sd	zero,-120(s0)
    80201af4:	00100793          	li	a5,1
    80201af8:	f8f40023          	sb	a5,-128(s0)
    80201afc:	fff00793          	li	a5,-1
    80201b00:	f8f42623          	sw	a5,-116(s0)
    80201b04:	0280006f          	j	80201b2c <vprintfmt+0x7c0>
        } else {
            putch(*fmt);
    80201b08:	f5043783          	ld	a5,-176(s0)
    80201b0c:	0007c783          	lbu	a5,0(a5)
    80201b10:	0007871b          	sext.w	a4,a5
    80201b14:	f5843783          	ld	a5,-168(s0)
    80201b18:	00070513          	mv	a0,a4
    80201b1c:	000780e7          	jalr	a5
            ++written;
    80201b20:	fec42783          	lw	a5,-20(s0)
    80201b24:	0017879b          	addiw	a5,a5,1
    80201b28:	fef42623          	sw	a5,-20(s0)
    for (; *fmt; fmt++) {
    80201b2c:	f5043783          	ld	a5,-176(s0)
    80201b30:	00178793          	addi	a5,a5,1
    80201b34:	f4f43823          	sd	a5,-176(s0)
    80201b38:	f5043783          	ld	a5,-176(s0)
    80201b3c:	0007c783          	lbu	a5,0(a5)
    80201b40:	84079ce3          	bnez	a5,80201398 <vprintfmt+0x2c>
        }
    }

    return written;
    80201b44:	fec42783          	lw	a5,-20(s0)
}
    80201b48:	00078513          	mv	a0,a5
    80201b4c:	0b813083          	ld	ra,184(sp)
    80201b50:	0b013403          	ld	s0,176(sp)
    80201b54:	0c010113          	addi	sp,sp,192
    80201b58:	00008067          	ret

0000000080201b5c <printk>:

int printk(const char* s, ...) {
    80201b5c:	f9010113          	addi	sp,sp,-112
    80201b60:	02113423          	sd	ra,40(sp)
    80201b64:	02813023          	sd	s0,32(sp)
    80201b68:	03010413          	addi	s0,sp,48
    80201b6c:	fca43c23          	sd	a0,-40(s0)
    80201b70:	00b43423          	sd	a1,8(s0)
    80201b74:	00c43823          	sd	a2,16(s0)
    80201b78:	00d43c23          	sd	a3,24(s0)
    80201b7c:	02e43023          	sd	a4,32(s0)
    80201b80:	02f43423          	sd	a5,40(s0)
    80201b84:	03043823          	sd	a6,48(s0)
    80201b88:	03143c23          	sd	a7,56(s0)
    int res = 0;
    80201b8c:	fe042623          	sw	zero,-20(s0)
    va_list vl;
    va_start(vl, s);
    80201b90:	04040793          	addi	a5,s0,64
    80201b94:	fcf43823          	sd	a5,-48(s0)
    80201b98:	fd043783          	ld	a5,-48(s0)
    80201b9c:	fc878793          	addi	a5,a5,-56
    80201ba0:	fef43023          	sd	a5,-32(s0)
    res = vprintfmt(putc, s, vl);
    80201ba4:	fe043783          	ld	a5,-32(s0)
    80201ba8:	00078613          	mv	a2,a5
    80201bac:	fd843583          	ld	a1,-40(s0)
    80201bb0:	fffff517          	auipc	a0,0xfffff
    80201bb4:	11850513          	addi	a0,a0,280 # 80200cc8 <putc>
    80201bb8:	fb4ff0ef          	jal	8020136c <vprintfmt>
    80201bbc:	00050793          	mv	a5,a0
    80201bc0:	fef42623          	sw	a5,-20(s0)
    va_end(vl);
    return res;
    80201bc4:	fec42783          	lw	a5,-20(s0)
}
    80201bc8:	00078513          	mv	a0,a5
    80201bcc:	02813083          	ld	ra,40(sp)
    80201bd0:	02013403          	ld	s0,32(sp)
    80201bd4:	07010113          	addi	sp,sp,112
    80201bd8:	00008067          	ret

0000000080201bdc <srand>:
#include "stdint.h"
#include "stdlib.h"

static uint64_t seed;

void srand(unsigned s) {
    80201bdc:	fe010113          	addi	sp,sp,-32
    80201be0:	00813c23          	sd	s0,24(sp)
    80201be4:	02010413          	addi	s0,sp,32
    80201be8:	00050793          	mv	a5,a0
    80201bec:	fef42623          	sw	a5,-20(s0)
    seed = s - 1;
    80201bf0:	fec42783          	lw	a5,-20(s0)
    80201bf4:	fff7879b          	addiw	a5,a5,-1
    80201bf8:	0007879b          	sext.w	a5,a5
    80201bfc:	02079713          	slli	a4,a5,0x20
    80201c00:	02075713          	srli	a4,a4,0x20
    80201c04:	00003797          	auipc	a5,0x3
    80201c08:	51478793          	addi	a5,a5,1300 # 80205118 <seed>
    80201c0c:	00e7b023          	sd	a4,0(a5)
}
    80201c10:	00000013          	nop
    80201c14:	01813403          	ld	s0,24(sp)
    80201c18:	02010113          	addi	sp,sp,32
    80201c1c:	00008067          	ret

0000000080201c20 <rand>:

int rand(void) {
    80201c20:	ff010113          	addi	sp,sp,-16
    80201c24:	00813423          	sd	s0,8(sp)
    80201c28:	01010413          	addi	s0,sp,16
    seed = 6364136223846793005ULL * seed + 1;
    80201c2c:	00003797          	auipc	a5,0x3
    80201c30:	4ec78793          	addi	a5,a5,1260 # 80205118 <seed>
    80201c34:	0007b703          	ld	a4,0(a5)
    80201c38:	00000797          	auipc	a5,0x0
    80201c3c:	52078793          	addi	a5,a5,1312 # 80202158 <lowerxdigits.0+0x18>
    80201c40:	0007b783          	ld	a5,0(a5)
    80201c44:	02f707b3          	mul	a5,a4,a5
    80201c48:	00178713          	addi	a4,a5,1
    80201c4c:	00003797          	auipc	a5,0x3
    80201c50:	4cc78793          	addi	a5,a5,1228 # 80205118 <seed>
    80201c54:	00e7b023          	sd	a4,0(a5)
    return seed >> 33;
    80201c58:	00003797          	auipc	a5,0x3
    80201c5c:	4c078793          	addi	a5,a5,1216 # 80205118 <seed>
    80201c60:	0007b783          	ld	a5,0(a5)
    80201c64:	0217d793          	srli	a5,a5,0x21
    80201c68:	0007879b          	sext.w	a5,a5
}
    80201c6c:	00078513          	mv	a0,a5
    80201c70:	00813403          	ld	s0,8(sp)
    80201c74:	01010113          	addi	sp,sp,16
    80201c78:	00008067          	ret

0000000080201c7c <memset>:
#include "string.h"
#include "stdint.h"

void *memset(void *dest, int c, uint64_t n) {
    80201c7c:	fc010113          	addi	sp,sp,-64
    80201c80:	02813c23          	sd	s0,56(sp)
    80201c84:	04010413          	addi	s0,sp,64
    80201c88:	fca43c23          	sd	a0,-40(s0)
    80201c8c:	00058793          	mv	a5,a1
    80201c90:	fcc43423          	sd	a2,-56(s0)
    80201c94:	fcf42a23          	sw	a5,-44(s0)
    char *s = (char *)dest;
    80201c98:	fd843783          	ld	a5,-40(s0)
    80201c9c:	fef43023          	sd	a5,-32(s0)
    for (uint64_t i = 0; i < n; ++i) {
    80201ca0:	fe043423          	sd	zero,-24(s0)
    80201ca4:	0280006f          	j	80201ccc <memset+0x50>
        s[i] = c;
    80201ca8:	fe043703          	ld	a4,-32(s0)
    80201cac:	fe843783          	ld	a5,-24(s0)
    80201cb0:	00f707b3          	add	a5,a4,a5
    80201cb4:	fd442703          	lw	a4,-44(s0)
    80201cb8:	0ff77713          	zext.b	a4,a4
    80201cbc:	00e78023          	sb	a4,0(a5)
    for (uint64_t i = 0; i < n; ++i) {
    80201cc0:	fe843783          	ld	a5,-24(s0)
    80201cc4:	00178793          	addi	a5,a5,1
    80201cc8:	fef43423          	sd	a5,-24(s0)
    80201ccc:	fe843703          	ld	a4,-24(s0)
    80201cd0:	fc843783          	ld	a5,-56(s0)
    80201cd4:	fcf76ae3          	bltu	a4,a5,80201ca8 <memset+0x2c>
    }
    return dest;
    80201cd8:	fd843783          	ld	a5,-40(s0)
}
    80201cdc:	00078513          	mv	a0,a5
    80201ce0:	03813403          	ld	s0,56(sp)
    80201ce4:	04010113          	addi	sp,sp,64
    80201ce8:	00008067          	ret
