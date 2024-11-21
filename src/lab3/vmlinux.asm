
../../vmlinux:     file format elf64-littleriscv


Disassembly of section .text:

ffffffe000200000 <_skernel>:
    .extern start_kernel
    .section .text.init
    .globl _start
_start:
    la sp, boot_stack_top
ffffffe000200000:	00006117          	auipc	sp,0x6
ffffffe000200004:	00010113          	mv	sp,sp

    call setup_vm
ffffffe000200008:	59d000ef          	jal	ffffffe000200da4 <setup_vm>
    call relocate
ffffffe00020000c:	044000ef          	jal	ffffffe000200050 <relocate>
    
    jal mm_init
ffffffe000200010:	3ec000ef          	jal	ffffffe0002003fc <mm_init>

    call setup_vm_final
ffffffe000200014:	625000ef          	jal	ffffffe000200e38 <setup_vm_final>
    
    jal task_init
ffffffe000200018:	428000ef          	jal	ffffffe000200440 <task_init>
    jal start_kernel
ffffffe00020001c:	15c010ef          	jal	ffffffe000201178 <start_kernel>
    # ------------------
    # set stvec = _traps
    la t0, _traps
ffffffe000200020:	00000297          	auipc	t0,0x0
ffffffe000200024:	06828293          	addi	t0,t0,104 # ffffffe000200088 <_traps>
    csrw stvec, t0
ffffffe000200028:	10529073          	csrw	stvec,t0
    # ------------------
    # set sie[STIE] = 1
    li t0, 1<<5
ffffffe00020002c:	02000293          	li	t0,32
    csrw sie, t0
ffffffe000200030:	10429073          	csrw	sie,t0
    # ------------------
    # set first time interrupt
    li t1,10000000
ffffffe000200034:	00989337          	lui	t1,0x989
ffffffe000200038:	6803031b          	addiw	t1,t1,1664 # 989680 <OPENSBI_SIZE+0x789680>
    # get time
    rdtime t0
ffffffe00020003c:	c01022f3          	rdtime	t0
    add t0,t0,t1
ffffffe000200040:	006282b3          	add	t0,t0,t1
    # set next interrupt
    jal x1, sbi_set_timer
ffffffe000200044:	4bd000ef          	jal	ffffffe000200d00 <sbi_set_timer>
    # ------------------
    # set sstatus[SIE] = 1
    li t0, 1<<1
ffffffe000200048:	00200293          	li	t0,2
    csrw sstatus, t0
ffffffe00020004c:	10029073          	csrw	sstatus,t0

ffffffe000200050 <relocate>:

relocate:
    # set ra = ra + PA2VA_OFFSET
    # set sp = sp + PA2VA_OFFSET (If you have set the sp before)

    li t0, 0xffffffdf80000000
ffffffe000200050:	fbf0029b          	addiw	t0,zero,-65
ffffffe000200054:	01f29293          	slli	t0,t0,0x1f
    add ra, ra, t0 
ffffffe000200058:	005080b3          	add	ra,ra,t0
    add sp, sp, t0 
ffffffe00020005c:	00510133          	add	sp,sp,t0
    # la t1, l1
    # add t1, t1, t0
    # csrw stvec, t1

    # need a fence to ensure the new translations are in use
    sfence.vma zero, zero
ffffffe000200060:	12000073          	sfence.vma

    # set satp with early_pgtbl

    # PPN
    la t2, early_pgtbl # PA of early_pgtbl
ffffffe000200064:	00007397          	auipc	t2,0x7
ffffffe000200068:	f9c38393          	addi	t2,t2,-100 # ffffffe000207000 <early_pgtbl>
    srli t2, t2, 12 # PPN=PA>>12
ffffffe00020006c:	00c3d393          	srli	t2,t2,0xc
    # ASID=0
    # MODE=8 (Sv39)
    addi t0, x0, 1
ffffffe000200070:	00100293          	li	t0,1
    li t1, 63
ffffffe000200074:	03f00313          	li	t1,63
    sll t0, t0, t1
ffffffe000200078:	006292b3          	sll	t0,t0,t1
    or t2, t2, t0   
ffffffe00020007c:	0053e3b3          	or	t2,t2,t0
    csrw satp, t2
ffffffe000200080:	18039073          	csrw	satp,t2
# l1:
    ret
ffffffe000200084:	00008067          	ret

ffffffe000200088 <_traps>:
    .align 2
    .globl _traps 
_traps:
    # -----------
        # 1. save 32 registers and sepc to stack
        addi sp, sp, -256
ffffffe000200088:	f0010113          	addi	sp,sp,-256 # ffffffe000205f00 <_sbss+0xf00>
        sd x1, 0(sp)
ffffffe00020008c:	00113023          	sd	ra,0(sp)
        sd x2, 8(sp)
ffffffe000200090:	00213423          	sd	sp,8(sp)
        sd x3, 16(sp)
ffffffe000200094:	00313823          	sd	gp,16(sp)
        sd x4, 24(sp)
ffffffe000200098:	00413c23          	sd	tp,24(sp)
        sd x5, 32(sp)
ffffffe00020009c:	02513023          	sd	t0,32(sp)
        sd x6, 40(sp)
ffffffe0002000a0:	02613423          	sd	t1,40(sp)
        sd x7, 48(sp)
ffffffe0002000a4:	02713823          	sd	t2,48(sp)
        sd x8, 56(sp)
ffffffe0002000a8:	02813c23          	sd	s0,56(sp)
        sd x9, 64(sp)
ffffffe0002000ac:	04913023          	sd	s1,64(sp)
        sd x10, 72(sp)
ffffffe0002000b0:	04a13423          	sd	a0,72(sp)
        sd x11, 80(sp)
ffffffe0002000b4:	04b13823          	sd	a1,80(sp)
        sd x12, 88(sp)
ffffffe0002000b8:	04c13c23          	sd	a2,88(sp)
        sd x13, 96(sp)
ffffffe0002000bc:	06d13023          	sd	a3,96(sp)
        sd x14, 104(sp)
ffffffe0002000c0:	06e13423          	sd	a4,104(sp)
        sd x15, 112(sp)
ffffffe0002000c4:	06f13823          	sd	a5,112(sp)
        sd x16, 120(sp)
ffffffe0002000c8:	07013c23          	sd	a6,120(sp)
        sd x17, 128(sp)
ffffffe0002000cc:	09113023          	sd	a7,128(sp)
        sd x18, 136(sp)
ffffffe0002000d0:	09213423          	sd	s2,136(sp)
        sd x19, 144(sp)
ffffffe0002000d4:	09313823          	sd	s3,144(sp)
        sd x20, 152(sp)
ffffffe0002000d8:	09413c23          	sd	s4,152(sp)
        sd x21, 160(sp)
ffffffe0002000dc:	0b513023          	sd	s5,160(sp)
        sd x22, 168(sp)
ffffffe0002000e0:	0b613423          	sd	s6,168(sp)
        sd x23, 176(sp)
ffffffe0002000e4:	0b713823          	sd	s7,176(sp)
        sd x24, 184(sp)
ffffffe0002000e8:	0b813c23          	sd	s8,184(sp)
        sd x25, 192(sp)
ffffffe0002000ec:	0d913023          	sd	s9,192(sp)
        sd x26, 200(sp)
ffffffe0002000f0:	0da13423          	sd	s10,200(sp)
        sd x27, 208(sp)
ffffffe0002000f4:	0db13823          	sd	s11,208(sp)
        sd x28, 216(sp)
ffffffe0002000f8:	0dc13c23          	sd	t3,216(sp)
        sd x29, 224(sp)
ffffffe0002000fc:	0fd13023          	sd	t4,224(sp)
        sd x30, 232(sp)
ffffffe000200100:	0fe13423          	sd	t5,232(sp)
        sd x31, 240(sp)
ffffffe000200104:	0ff13823          	sd	t6,240(sp)
        csrr t0, sepc
ffffffe000200108:	141022f3          	csrr	t0,sepc
        sd t0, 248(sp)
ffffffe00020010c:	0e513c23          	sd	t0,248(sp)
    # -----------
        # 2. call trap_handler
        csrr a0, scause
ffffffe000200110:	14202573          	csrr	a0,scause
        csrr a1, sepc
ffffffe000200114:	141025f3          	csrr	a1,sepc
        jal x1, trap_handler
ffffffe000200118:	441000ef          	jal	ffffffe000200d58 <trap_handler>
    # -----------
        # 3. restore sepc and 32 registers (x2(sp) should be restore last) from stack
        ld t0, 248(sp)
ffffffe00020011c:	0f813283          	ld	t0,248(sp)
        csrw sepc, t0
ffffffe000200120:	14129073          	csrw	sepc,t0
        ld x1, 0(sp)
ffffffe000200124:	00013083          	ld	ra,0(sp)
        ld x3, 16(sp)
ffffffe000200128:	01013183          	ld	gp,16(sp)
        ld x4, 24(sp)
ffffffe00020012c:	01813203          	ld	tp,24(sp)
        ld x5, 32(sp)
ffffffe000200130:	02013283          	ld	t0,32(sp)
        ld x6, 40(sp)
ffffffe000200134:	02813303          	ld	t1,40(sp)
        ld x7, 48(sp)
ffffffe000200138:	03013383          	ld	t2,48(sp)
        ld x8, 56(sp)
ffffffe00020013c:	03813403          	ld	s0,56(sp)
        ld x9, 64(sp)
ffffffe000200140:	04013483          	ld	s1,64(sp)
        ld x10, 72(sp)
ffffffe000200144:	04813503          	ld	a0,72(sp)
        ld x11, 80(sp)
ffffffe000200148:	05013583          	ld	a1,80(sp)
        ld x12, 88(sp)
ffffffe00020014c:	05813603          	ld	a2,88(sp)
        ld x13, 96(sp)
ffffffe000200150:	06013683          	ld	a3,96(sp)
        ld x14, 104(sp)
ffffffe000200154:	06813703          	ld	a4,104(sp)
        ld x15, 112(sp)
ffffffe000200158:	07013783          	ld	a5,112(sp)
        ld x16, 120(sp)
ffffffe00020015c:	07813803          	ld	a6,120(sp)
        ld x17, 128(sp)
ffffffe000200160:	08013883          	ld	a7,128(sp)
        ld x18, 136(sp)
ffffffe000200164:	08813903          	ld	s2,136(sp)
        ld x19, 144(sp)
ffffffe000200168:	09013983          	ld	s3,144(sp)
        ld x20, 152(sp)
ffffffe00020016c:	09813a03          	ld	s4,152(sp)
        ld x21, 160(sp)
ffffffe000200170:	0a013a83          	ld	s5,160(sp)
        ld x22, 168(sp)
ffffffe000200174:	0a813b03          	ld	s6,168(sp)
        ld x23, 176(sp)
ffffffe000200178:	0b013b83          	ld	s7,176(sp)
        ld x24, 184(sp)
ffffffe00020017c:	0b813c03          	ld	s8,184(sp)
        ld x25, 192(sp)
ffffffe000200180:	0c013c83          	ld	s9,192(sp)
        ld x26, 200(sp)
ffffffe000200184:	0c813d03          	ld	s10,200(sp)
        ld x27, 208(sp)
ffffffe000200188:	0d013d83          	ld	s11,208(sp)
        ld x28, 216(sp)
ffffffe00020018c:	0d813e03          	ld	t3,216(sp)
        ld x29, 224(sp)
ffffffe000200190:	0e013e83          	ld	t4,224(sp)
        ld x30, 232(sp)
ffffffe000200194:	0e813f03          	ld	t5,232(sp)
        ld x31, 240(sp)
ffffffe000200198:	0f013f83          	ld	t6,240(sp)
        ld x2, 8(sp)
ffffffe00020019c:	00813103          	ld	sp,8(sp)
        addi sp, sp, 256
ffffffe0002001a0:	10010113          	addi	sp,sp,256
    # -----------
        # 4. return from trap
        sret 
ffffffe0002001a4:	10200073          	sret

ffffffe0002001a8 <__dummy>:
    # -----------
    .extern dummy
    .globl __dummy
__dummy:
    # 将 sepc 设置为 dummy() 的地址，并使用 sret 从 S 模式中返回
    la t0, dummy
ffffffe0002001a8:	00000297          	auipc	t0,0x0
ffffffe0002001ac:	49c28293          	addi	t0,t0,1180 # ffffffe000200644 <dummy>
    csrw sepc, t0
ffffffe0002001b0:	14129073          	csrw	sepc,t0
    sret
ffffffe0002001b4:	10200073          	sret

ffffffe0002001b8 <__switch_to>:
    # -----------
    .globl __switch_to
__switch_to:
    # save state to prev process
    # 保存当前线程的 ra，sp，s0~s11 到当前线程的 thread_struct 中
    addi t0, a0, 32 #t0 = &prev->thread
ffffffe0002001b8:	02050293          	addi	t0,a0,32
    sd ra, 0(t0)
ffffffe0002001bc:	0012b023          	sd	ra,0(t0)
    sd sp, 8(t0)
ffffffe0002001c0:	0022b423          	sd	sp,8(t0)
    sd s0, 16(t0)
ffffffe0002001c4:	0082b823          	sd	s0,16(t0)
    sd s1, 24(t0)
ffffffe0002001c8:	0092bc23          	sd	s1,24(t0)
    sd s2, 32(t0)
ffffffe0002001cc:	0322b023          	sd	s2,32(t0)
    sd s3, 40(t0)
ffffffe0002001d0:	0332b423          	sd	s3,40(t0)
    sd s4, 48(t0)
ffffffe0002001d4:	0342b823          	sd	s4,48(t0)
    sd s5, 56(t0)
ffffffe0002001d8:	0352bc23          	sd	s5,56(t0)
    sd s6, 64(t0)
ffffffe0002001dc:	0562b023          	sd	s6,64(t0)
    sd s7, 72(t0)
ffffffe0002001e0:	0572b423          	sd	s7,72(t0)
    sd s8, 80(t0)
ffffffe0002001e4:	0582b823          	sd	s8,80(t0)
    sd s9, 88(t0)
ffffffe0002001e8:	0592bc23          	sd	s9,88(t0)
    sd s10, 96(t0)
ffffffe0002001ec:	07a2b023          	sd	s10,96(t0)
    sd s11, 104(t0)
ffffffe0002001f0:	07b2b423          	sd	s11,104(t0)
    # restore state from next process
    # 将下一个线程的 thread_struct 中的相关数据载入到 ra，sp，s0~s11 中进行恢复
    addi t0, a1, 32
ffffffe0002001f4:	02058293          	addi	t0,a1,32
    ld ra, 0(t0)
ffffffe0002001f8:	0002b083          	ld	ra,0(t0)
    ld sp, 8(t0)
ffffffe0002001fc:	0082b103          	ld	sp,8(t0)
    ld s0, 16(t0)
ffffffe000200200:	0102b403          	ld	s0,16(t0)
    ld s1, 24(t0)
ffffffe000200204:	0182b483          	ld	s1,24(t0)
    ld s2, 32(t0)
ffffffe000200208:	0202b903          	ld	s2,32(t0)
    ld s3, 40(t0)
ffffffe00020020c:	0282b983          	ld	s3,40(t0)
    ld s4, 48(t0)
ffffffe000200210:	0302ba03          	ld	s4,48(t0)
    ld s5, 56(t0)
ffffffe000200214:	0382ba83          	ld	s5,56(t0)
    ld s6, 64(t0)
ffffffe000200218:	0402bb03          	ld	s6,64(t0)
    ld s7, 72(t0)
ffffffe00020021c:	0482bb83          	ld	s7,72(t0)
    ld s8, 80(t0)
ffffffe000200220:	0502bc03          	ld	s8,80(t0)
    ld s9, 88(t0)
ffffffe000200224:	0582bc83          	ld	s9,88(t0)
    ld s10, 96(t0)
ffffffe000200228:	0602bd03          	ld	s10,96(t0)
    ld s11, 104(t0)
ffffffe00020022c:	0682bd83          	ld	s11,104(t0)
ffffffe000200230:	00008067          	ret

ffffffe000200234 <get_cycles>:
#include "sbi.h"

// QEMU 中时钟的频率是 10MHz，也就是 1 秒钟相当于 10000000 个时钟周期
uint64_t TIMECLOCK = 1000000;

uint64_t get_cycles() {
ffffffe000200234:	fe010113          	addi	sp,sp,-32
ffffffe000200238:	00813c23          	sd	s0,24(sp)
ffffffe00020023c:	02010413          	addi	s0,sp,32
    // 编写内联汇编，使用 rdtime 获取 time 寄存器中（也就是 mtime 寄存器）的值并返回
    unsigned long time;

    __asm__ volatile(
ffffffe000200240:	c01027f3          	rdtime	a5
ffffffe000200244:	fef43423          	sd	a5,-24(s0)
        "rdtime %[time]"
        :[time] "=r" (time)
        : :"memory"
    );
    
    return time;
ffffffe000200248:	fe843783          	ld	a5,-24(s0)
}
ffffffe00020024c:	00078513          	mv	a0,a5
ffffffe000200250:	01813403          	ld	s0,24(sp)
ffffffe000200254:	02010113          	addi	sp,sp,32
ffffffe000200258:	00008067          	ret

ffffffe00020025c <clock_set_next_event>:

void clock_set_next_event() {
ffffffe00020025c:	fe010113          	addi	sp,sp,-32
ffffffe000200260:	00113c23          	sd	ra,24(sp)
ffffffe000200264:	00813823          	sd	s0,16(sp)
ffffffe000200268:	02010413          	addi	s0,sp,32
    // 下一次时钟中断的时间点
    uint64_t next_interrupt = get_cycles() + TIMECLOCK;
ffffffe00020026c:	fc9ff0ef          	jal	ffffffe000200234 <get_cycles>
ffffffe000200270:	00050713          	mv	a4,a0
ffffffe000200274:	00004797          	auipc	a5,0x4
ffffffe000200278:	d8c78793          	addi	a5,a5,-628 # ffffffe000204000 <TIMECLOCK>
ffffffe00020027c:	0007b783          	ld	a5,0(a5)
ffffffe000200280:	00f707b3          	add	a5,a4,a5
ffffffe000200284:	fef43423          	sd	a5,-24(s0)

    // 使用 sbi_set_timer 来完成对下一次时钟中断的设置
    sbi_set_timer(next_interrupt);
ffffffe000200288:	fe843503          	ld	a0,-24(s0)
ffffffe00020028c:	275000ef          	jal	ffffffe000200d00 <sbi_set_timer>
}
ffffffe000200290:	00000013          	nop
ffffffe000200294:	01813083          	ld	ra,24(sp)
ffffffe000200298:	01013403          	ld	s0,16(sp)
ffffffe00020029c:	02010113          	addi	sp,sp,32
ffffffe0002002a0:	00008067          	ret

ffffffe0002002a4 <kalloc>:

struct {
    struct run *freelist;
} kmem;

void *kalloc() {
ffffffe0002002a4:	fe010113          	addi	sp,sp,-32
ffffffe0002002a8:	00113c23          	sd	ra,24(sp)
ffffffe0002002ac:	00813823          	sd	s0,16(sp)
ffffffe0002002b0:	02010413          	addi	s0,sp,32
    struct run *r;

    r = kmem.freelist;
ffffffe0002002b4:	00006797          	auipc	a5,0x6
ffffffe0002002b8:	d4c78793          	addi	a5,a5,-692 # ffffffe000206000 <kmem>
ffffffe0002002bc:	0007b783          	ld	a5,0(a5)
ffffffe0002002c0:	fef43423          	sd	a5,-24(s0)
    kmem.freelist = r->next;
ffffffe0002002c4:	fe843783          	ld	a5,-24(s0)
ffffffe0002002c8:	0007b703          	ld	a4,0(a5)
ffffffe0002002cc:	00006797          	auipc	a5,0x6
ffffffe0002002d0:	d3478793          	addi	a5,a5,-716 # ffffffe000206000 <kmem>
ffffffe0002002d4:	00e7b023          	sd	a4,0(a5)
    
    memset((void *)r, 0x0, PGSIZE);
ffffffe0002002d8:	00001637          	lui	a2,0x1
ffffffe0002002dc:	00000593          	li	a1,0
ffffffe0002002e0:	fe843503          	ld	a0,-24(s0)
ffffffe0002002e4:	6a9010ef          	jal	ffffffe00020218c <memset>
    return (void *)r;
ffffffe0002002e8:	fe843783          	ld	a5,-24(s0)
}
ffffffe0002002ec:	00078513          	mv	a0,a5
ffffffe0002002f0:	01813083          	ld	ra,24(sp)
ffffffe0002002f4:	01013403          	ld	s0,16(sp)
ffffffe0002002f8:	02010113          	addi	sp,sp,32
ffffffe0002002fc:	00008067          	ret

ffffffe000200300 <kfree>:

void kfree(void *addr) {
ffffffe000200300:	fd010113          	addi	sp,sp,-48
ffffffe000200304:	02113423          	sd	ra,40(sp)
ffffffe000200308:	02813023          	sd	s0,32(sp)
ffffffe00020030c:	03010413          	addi	s0,sp,48
ffffffe000200310:	fca43c23          	sd	a0,-40(s0)
    struct run *r;

    // PGSIZE align 
    //PGROUNDDOWN
    *(uintptr_t *)&addr = (uintptr_t)addr & ~(PGSIZE - 1);
ffffffe000200314:	fd843783          	ld	a5,-40(s0)
ffffffe000200318:	00078693          	mv	a3,a5
ffffffe00020031c:	fd840793          	addi	a5,s0,-40
ffffffe000200320:	fffff737          	lui	a4,0xfffff
ffffffe000200324:	00e6f733          	and	a4,a3,a4
ffffffe000200328:	00e7b023          	sd	a4,0(a5)

    memset(addr, 0x0, (uint64_t)PGSIZE);
ffffffe00020032c:	fd843783          	ld	a5,-40(s0)
ffffffe000200330:	00001637          	lui	a2,0x1
ffffffe000200334:	00000593          	li	a1,0
ffffffe000200338:	00078513          	mv	a0,a5
ffffffe00020033c:	651010ef          	jal	ffffffe00020218c <memset>

    r = (struct run *)addr;
ffffffe000200340:	fd843783          	ld	a5,-40(s0)
ffffffe000200344:	fef43423          	sd	a5,-24(s0)
    r->next = kmem.freelist;
ffffffe000200348:	00006797          	auipc	a5,0x6
ffffffe00020034c:	cb878793          	addi	a5,a5,-840 # ffffffe000206000 <kmem>
ffffffe000200350:	0007b703          	ld	a4,0(a5)
ffffffe000200354:	fe843783          	ld	a5,-24(s0)
ffffffe000200358:	00e7b023          	sd	a4,0(a5)
    kmem.freelist = r;
ffffffe00020035c:	00006797          	auipc	a5,0x6
ffffffe000200360:	ca478793          	addi	a5,a5,-860 # ffffffe000206000 <kmem>
ffffffe000200364:	fe843703          	ld	a4,-24(s0)
ffffffe000200368:	00e7b023          	sd	a4,0(a5)

    return;
ffffffe00020036c:	00000013          	nop
}
ffffffe000200370:	02813083          	ld	ra,40(sp)
ffffffe000200374:	02013403          	ld	s0,32(sp)
ffffffe000200378:	03010113          	addi	sp,sp,48
ffffffe00020037c:	00008067          	ret

ffffffe000200380 <kfreerange>:

void kfreerange(char *start, char *end) {
ffffffe000200380:	fd010113          	addi	sp,sp,-48
ffffffe000200384:	02113423          	sd	ra,40(sp)
ffffffe000200388:	02813023          	sd	s0,32(sp)
ffffffe00020038c:	03010413          	addi	s0,sp,48
ffffffe000200390:	fca43c23          	sd	a0,-40(s0)
ffffffe000200394:	fcb43823          	sd	a1,-48(s0)
    char *addr = (char *)PGROUNDUP((uintptr_t)start);
ffffffe000200398:	fd843703          	ld	a4,-40(s0)
ffffffe00020039c:	000017b7          	lui	a5,0x1
ffffffe0002003a0:	fff78793          	addi	a5,a5,-1 # fff <PGSIZE-0x1>
ffffffe0002003a4:	00f70733          	add	a4,a4,a5
ffffffe0002003a8:	fffff7b7          	lui	a5,0xfffff
ffffffe0002003ac:	00f777b3          	and	a5,a4,a5
ffffffe0002003b0:	fef43423          	sd	a5,-24(s0)
    for (; (uintptr_t)(addr) + PGSIZE <= (uintptr_t)end; addr += PGSIZE) {
ffffffe0002003b4:	01c0006f          	j	ffffffe0002003d0 <kfreerange+0x50>
        kfree((void *)addr);
ffffffe0002003b8:	fe843503          	ld	a0,-24(s0)
ffffffe0002003bc:	f45ff0ef          	jal	ffffffe000200300 <kfree>
    for (; (uintptr_t)(addr) + PGSIZE <= (uintptr_t)end; addr += PGSIZE) {
ffffffe0002003c0:	fe843703          	ld	a4,-24(s0)
ffffffe0002003c4:	000017b7          	lui	a5,0x1
ffffffe0002003c8:	00f707b3          	add	a5,a4,a5
ffffffe0002003cc:	fef43423          	sd	a5,-24(s0)
ffffffe0002003d0:	fe843703          	ld	a4,-24(s0)
ffffffe0002003d4:	000017b7          	lui	a5,0x1
ffffffe0002003d8:	00f70733          	add	a4,a4,a5
ffffffe0002003dc:	fd043783          	ld	a5,-48(s0)
ffffffe0002003e0:	fce7fce3          	bgeu	a5,a4,ffffffe0002003b8 <kfreerange+0x38>
    }
}
ffffffe0002003e4:	00000013          	nop
ffffffe0002003e8:	00000013          	nop
ffffffe0002003ec:	02813083          	ld	ra,40(sp)
ffffffe0002003f0:	02013403          	ld	s0,32(sp)
ffffffe0002003f4:	03010113          	addi	sp,sp,48
ffffffe0002003f8:	00008067          	ret

ffffffe0002003fc <mm_init>:

void mm_init(void) {
ffffffe0002003fc:	ff010113          	addi	sp,sp,-16
ffffffe000200400:	00113423          	sd	ra,8(sp)
ffffffe000200404:	00813023          	sd	s0,0(sp)
ffffffe000200408:	01010413          	addi	s0,sp,16
    kfreerange(_ekernel, (char *)(PHY_END + PA2VA_OFFSET));
ffffffe00020040c:	c0100793          	li	a5,-1023
ffffffe000200410:	01b79593          	slli	a1,a5,0x1b
ffffffe000200414:	00009517          	auipc	a0,0x9
ffffffe000200418:	bec50513          	addi	a0,a0,-1044 # ffffffe000209000 <_ebss>
ffffffe00020041c:	f65ff0ef          	jal	ffffffe000200380 <kfreerange>
    printk("...mm_init done!\n");
ffffffe000200420:	00003517          	auipc	a0,0x3
ffffffe000200424:	be050513          	addi	a0,a0,-1056 # ffffffe000203000 <_srodata>
ffffffe000200428:	445010ef          	jal	ffffffe00020206c <printk>
ffffffe00020042c:	00000013          	nop
ffffffe000200430:	00813083          	ld	ra,8(sp)
ffffffe000200434:	00013403          	ld	s0,0(sp)
ffffffe000200438:	01010113          	addi	sp,sp,16
ffffffe00020043c:	00008067          	ret

ffffffe000200440 <task_init>:

struct task_struct *idle;           // idle process
struct task_struct *current;        // 指向当前运行线程的 task_struct
struct task_struct *task[NR_TASKS]; // 线程数组，所有的线程都保存在此

void task_init() {
ffffffe000200440:	fe010113          	addi	sp,sp,-32
ffffffe000200444:	00113c23          	sd	ra,24(sp)
ffffffe000200448:	00813823          	sd	s0,16(sp)
ffffffe00020044c:	02010413          	addi	s0,sp,32
    srand(2024);
ffffffe000200450:	7e800513          	li	a0,2024
ffffffe000200454:	499010ef          	jal	ffffffe0002020ec <srand>
    // 3. 由于 idle 不参与调度，可以将其 counter / priority 设置为 0
    // 4. 设置 idle 的 pid 为 0
    // 5. 将 current 和 task[0] 指向 idle

    /* YOUR CODE HERE */
    idle = (struct task_struct *)kalloc();
ffffffe000200458:	e4dff0ef          	jal	ffffffe0002002a4 <kalloc>
ffffffe00020045c:	00050713          	mv	a4,a0
ffffffe000200460:	00006797          	auipc	a5,0x6
ffffffe000200464:	ba878793          	addi	a5,a5,-1112 # ffffffe000206008 <idle>
ffffffe000200468:	00e7b023          	sd	a4,0(a5)
    idle->state = TASK_RUNNING;
ffffffe00020046c:	00006797          	auipc	a5,0x6
ffffffe000200470:	b9c78793          	addi	a5,a5,-1124 # ffffffe000206008 <idle>
ffffffe000200474:	0007b783          	ld	a5,0(a5)
ffffffe000200478:	0007b023          	sd	zero,0(a5)
    idle->counter = idle->priority = 0;
ffffffe00020047c:	00006797          	auipc	a5,0x6
ffffffe000200480:	b8c78793          	addi	a5,a5,-1140 # ffffffe000206008 <idle>
ffffffe000200484:	0007b783          	ld	a5,0(a5)
ffffffe000200488:	0007b823          	sd	zero,16(a5)
ffffffe00020048c:	00006717          	auipc	a4,0x6
ffffffe000200490:	b7c70713          	addi	a4,a4,-1156 # ffffffe000206008 <idle>
ffffffe000200494:	00073703          	ld	a4,0(a4)
ffffffe000200498:	0107b783          	ld	a5,16(a5)
ffffffe00020049c:	00f73423          	sd	a5,8(a4)
    idle->pid = 0;
ffffffe0002004a0:	00006797          	auipc	a5,0x6
ffffffe0002004a4:	b6878793          	addi	a5,a5,-1176 # ffffffe000206008 <idle>
ffffffe0002004a8:	0007b783          	ld	a5,0(a5)
ffffffe0002004ac:	0007bc23          	sd	zero,24(a5)
    current = task[0] = idle;
ffffffe0002004b0:	00006797          	auipc	a5,0x6
ffffffe0002004b4:	b5878793          	addi	a5,a5,-1192 # ffffffe000206008 <idle>
ffffffe0002004b8:	0007b703          	ld	a4,0(a5)
ffffffe0002004bc:	00006797          	auipc	a5,0x6
ffffffe0002004c0:	b6c78793          	addi	a5,a5,-1172 # ffffffe000206028 <task>
ffffffe0002004c4:	00e7b023          	sd	a4,0(a5)
ffffffe0002004c8:	00006797          	auipc	a5,0x6
ffffffe0002004cc:	b6078793          	addi	a5,a5,-1184 # ffffffe000206028 <task>
ffffffe0002004d0:	0007b703          	ld	a4,0(a5)
ffffffe0002004d4:	00006797          	auipc	a5,0x6
ffffffe0002004d8:	b3c78793          	addi	a5,a5,-1220 # ffffffe000206010 <current>
ffffffe0002004dc:	00e7b023          	sd	a4,0(a5)
    // 3. 为 task[1] ~ task[NR_TASKS - 1] 设置 thread_struct 中的 ra 和 sp
    //     - ra 设置为 __dummy（见 4.2.2）的地址
    //     - sp 设置为该线程申请的物理页的高地址

    /* YOUR CODE HERE */
    for(int i = 1; i < NR_TASKS; i++)
ffffffe0002004e0:	00100793          	li	a5,1
ffffffe0002004e4:	fef42623          	sw	a5,-20(s0)
ffffffe0002004e8:	12c0006f          	j	ffffffe000200614 <task_init+0x1d4>
    {
        task[i] = (struct task_struct *)kalloc();
ffffffe0002004ec:	db9ff0ef          	jal	ffffffe0002002a4 <kalloc>
ffffffe0002004f0:	00050693          	mv	a3,a0
ffffffe0002004f4:	00006717          	auipc	a4,0x6
ffffffe0002004f8:	b3470713          	addi	a4,a4,-1228 # ffffffe000206028 <task>
ffffffe0002004fc:	fec42783          	lw	a5,-20(s0)
ffffffe000200500:	00379793          	slli	a5,a5,0x3
ffffffe000200504:	00f707b3          	add	a5,a4,a5
ffffffe000200508:	00d7b023          	sd	a3,0(a5)
        task[i]->state = TASK_RUNNING;
ffffffe00020050c:	00006717          	auipc	a4,0x6
ffffffe000200510:	b1c70713          	addi	a4,a4,-1252 # ffffffe000206028 <task>
ffffffe000200514:	fec42783          	lw	a5,-20(s0)
ffffffe000200518:	00379793          	slli	a5,a5,0x3
ffffffe00020051c:	00f707b3          	add	a5,a4,a5
ffffffe000200520:	0007b783          	ld	a5,0(a5)
ffffffe000200524:	0007b023          	sd	zero,0(a5)
        task[i]->counter = 0;
ffffffe000200528:	00006717          	auipc	a4,0x6
ffffffe00020052c:	b0070713          	addi	a4,a4,-1280 # ffffffe000206028 <task>
ffffffe000200530:	fec42783          	lw	a5,-20(s0)
ffffffe000200534:	00379793          	slli	a5,a5,0x3
ffffffe000200538:	00f707b3          	add	a5,a4,a5
ffffffe00020053c:	0007b783          	ld	a5,0(a5)
ffffffe000200540:	0007b423          	sd	zero,8(a5)
        task[i]->priority = rand() % (PRIORITY_MAX - PRIORITY_MIN + 1) + PRIORITY_MIN;
ffffffe000200544:	3ed010ef          	jal	ffffffe000202130 <rand>
ffffffe000200548:	00050793          	mv	a5,a0
ffffffe00020054c:	00078713          	mv	a4,a5
ffffffe000200550:	00a00793          	li	a5,10
ffffffe000200554:	02f767bb          	remw	a5,a4,a5
ffffffe000200558:	0007879b          	sext.w	a5,a5
ffffffe00020055c:	0017879b          	addiw	a5,a5,1
ffffffe000200560:	0007869b          	sext.w	a3,a5
ffffffe000200564:	00006717          	auipc	a4,0x6
ffffffe000200568:	ac470713          	addi	a4,a4,-1340 # ffffffe000206028 <task>
ffffffe00020056c:	fec42783          	lw	a5,-20(s0)
ffffffe000200570:	00379793          	slli	a5,a5,0x3
ffffffe000200574:	00f707b3          	add	a5,a4,a5
ffffffe000200578:	0007b783          	ld	a5,0(a5)
ffffffe00020057c:	00068713          	mv	a4,a3
ffffffe000200580:	00e7b823          	sd	a4,16(a5)
        task[i]->pid = i;
ffffffe000200584:	00006717          	auipc	a4,0x6
ffffffe000200588:	aa470713          	addi	a4,a4,-1372 # ffffffe000206028 <task>
ffffffe00020058c:	fec42783          	lw	a5,-20(s0)
ffffffe000200590:	00379793          	slli	a5,a5,0x3
ffffffe000200594:	00f707b3          	add	a5,a4,a5
ffffffe000200598:	0007b783          	ld	a5,0(a5)
ffffffe00020059c:	fec42703          	lw	a4,-20(s0)
ffffffe0002005a0:	00e7bc23          	sd	a4,24(a5)
        task[i]->thread.ra = (uint64_t)__dummy;
ffffffe0002005a4:	00006717          	auipc	a4,0x6
ffffffe0002005a8:	a8470713          	addi	a4,a4,-1404 # ffffffe000206028 <task>
ffffffe0002005ac:	fec42783          	lw	a5,-20(s0)
ffffffe0002005b0:	00379793          	slli	a5,a5,0x3
ffffffe0002005b4:	00f707b3          	add	a5,a4,a5
ffffffe0002005b8:	0007b783          	ld	a5,0(a5)
ffffffe0002005bc:	00000717          	auipc	a4,0x0
ffffffe0002005c0:	bec70713          	addi	a4,a4,-1044 # ffffffe0002001a8 <__dummy>
ffffffe0002005c4:	02e7b023          	sd	a4,32(a5)
        task[i]->thread.sp = (uint64_t)task[i] + PGSIZE;
ffffffe0002005c8:	00006717          	auipc	a4,0x6
ffffffe0002005cc:	a6070713          	addi	a4,a4,-1440 # ffffffe000206028 <task>
ffffffe0002005d0:	fec42783          	lw	a5,-20(s0)
ffffffe0002005d4:	00379793          	slli	a5,a5,0x3
ffffffe0002005d8:	00f707b3          	add	a5,a4,a5
ffffffe0002005dc:	0007b783          	ld	a5,0(a5)
ffffffe0002005e0:	00078693          	mv	a3,a5
ffffffe0002005e4:	00006717          	auipc	a4,0x6
ffffffe0002005e8:	a4470713          	addi	a4,a4,-1468 # ffffffe000206028 <task>
ffffffe0002005ec:	fec42783          	lw	a5,-20(s0)
ffffffe0002005f0:	00379793          	slli	a5,a5,0x3
ffffffe0002005f4:	00f707b3          	add	a5,a4,a5
ffffffe0002005f8:	0007b783          	ld	a5,0(a5)
ffffffe0002005fc:	00001737          	lui	a4,0x1
ffffffe000200600:	00e68733          	add	a4,a3,a4
ffffffe000200604:	02e7b423          	sd	a4,40(a5)
    for(int i = 1; i < NR_TASKS; i++)
ffffffe000200608:	fec42783          	lw	a5,-20(s0)
ffffffe00020060c:	0017879b          	addiw	a5,a5,1
ffffffe000200610:	fef42623          	sw	a5,-20(s0)
ffffffe000200614:	fec42783          	lw	a5,-20(s0)
ffffffe000200618:	0007871b          	sext.w	a4,a5
ffffffe00020061c:	00400793          	li	a5,4
ffffffe000200620:	ece7d6e3          	bge	a5,a4,ffffffe0002004ec <task_init+0xac>
    //s到thread_struct的偏移量
    printk("offset_s_to_thread_struct=%d\n", offsetof(struct thread_struct, s));
    //s[1]到thread_struct的偏移量
    printk("offset_s1_to_thread_struct=%d\n", offsetof(struct thread_struct, s[1]));*/

    printk("...task_init done!\n");
ffffffe000200624:	00003517          	auipc	a0,0x3
ffffffe000200628:	9f450513          	addi	a0,a0,-1548 # ffffffe000203018 <_srodata+0x18>
ffffffe00020062c:	241010ef          	jal	ffffffe00020206c <printk>
}
ffffffe000200630:	00000013          	nop
ffffffe000200634:	01813083          	ld	ra,24(sp)
ffffffe000200638:	01013403          	ld	s0,16(sp)
ffffffe00020063c:	02010113          	addi	sp,sp,32
ffffffe000200640:	00008067          	ret

ffffffe000200644 <dummy>:
int tasks_output_index = 0;
char expected_output[] = "2222222222111111133334222222222211111113";
#include "sbi.h"
#endif

void dummy() {
ffffffe000200644:	fd010113          	addi	sp,sp,-48
ffffffe000200648:	02113423          	sd	ra,40(sp)
ffffffe00020064c:	02813023          	sd	s0,32(sp)
ffffffe000200650:	03010413          	addi	s0,sp,48
    uint64_t MOD = 1000000007;
ffffffe000200654:	3b9ad7b7          	lui	a5,0x3b9ad
ffffffe000200658:	a0778793          	addi	a5,a5,-1529 # 3b9aca07 <PHY_SIZE+0x339aca07>
ffffffe00020065c:	fcf43c23          	sd	a5,-40(s0)
    uint64_t auto_inc_local_var = 0;
ffffffe000200660:	fe043423          	sd	zero,-24(s0)
    int last_counter = -1;
ffffffe000200664:	fff00793          	li	a5,-1
ffffffe000200668:	fef42223          	sw	a5,-28(s0)
    while (1) {
        if ((last_counter == -1 || current->counter != last_counter) && current->counter > 0) {
ffffffe00020066c:	fe442783          	lw	a5,-28(s0)
ffffffe000200670:	0007871b          	sext.w	a4,a5
ffffffe000200674:	fff00793          	li	a5,-1
ffffffe000200678:	00f70e63          	beq	a4,a5,ffffffe000200694 <dummy+0x50>
ffffffe00020067c:	00006797          	auipc	a5,0x6
ffffffe000200680:	99478793          	addi	a5,a5,-1644 # ffffffe000206010 <current>
ffffffe000200684:	0007b783          	ld	a5,0(a5)
ffffffe000200688:	0087b703          	ld	a4,8(a5)
ffffffe00020068c:	fe442783          	lw	a5,-28(s0)
ffffffe000200690:	fcf70ee3          	beq	a4,a5,ffffffe00020066c <dummy+0x28>
ffffffe000200694:	00006797          	auipc	a5,0x6
ffffffe000200698:	97c78793          	addi	a5,a5,-1668 # ffffffe000206010 <current>
ffffffe00020069c:	0007b783          	ld	a5,0(a5)
ffffffe0002006a0:	0087b783          	ld	a5,8(a5)
ffffffe0002006a4:	fc0784e3          	beqz	a5,ffffffe00020066c <dummy+0x28>
            if (current->counter == 1) {
ffffffe0002006a8:	00006797          	auipc	a5,0x6
ffffffe0002006ac:	96878793          	addi	a5,a5,-1688 # ffffffe000206010 <current>
ffffffe0002006b0:	0007b783          	ld	a5,0(a5)
ffffffe0002006b4:	0087b703          	ld	a4,8(a5)
ffffffe0002006b8:	00100793          	li	a5,1
ffffffe0002006bc:	00f71e63          	bne	a4,a5,ffffffe0002006d8 <dummy+0x94>
                --(current->counter);   // forced the counter to be zero if this thread is going to be scheduled
ffffffe0002006c0:	00006797          	auipc	a5,0x6
ffffffe0002006c4:	95078793          	addi	a5,a5,-1712 # ffffffe000206010 <current>
ffffffe0002006c8:	0007b783          	ld	a5,0(a5)
ffffffe0002006cc:	0087b703          	ld	a4,8(a5)
ffffffe0002006d0:	fff70713          	addi	a4,a4,-1 # fff <PGSIZE-0x1>
ffffffe0002006d4:	00e7b423          	sd	a4,8(a5)
            }                           // in case that the new counter is also 1, leading the information not printed.
            last_counter = current->counter;
ffffffe0002006d8:	00006797          	auipc	a5,0x6
ffffffe0002006dc:	93878793          	addi	a5,a5,-1736 # ffffffe000206010 <current>
ffffffe0002006e0:	0007b783          	ld	a5,0(a5)
ffffffe0002006e4:	0087b783          	ld	a5,8(a5)
ffffffe0002006e8:	fef42223          	sw	a5,-28(s0)
            auto_inc_local_var = (auto_inc_local_var + 1) % MOD;
ffffffe0002006ec:	fe843783          	ld	a5,-24(s0)
ffffffe0002006f0:	00178713          	addi	a4,a5,1
ffffffe0002006f4:	fd843783          	ld	a5,-40(s0)
ffffffe0002006f8:	02f777b3          	remu	a5,a4,a5
ffffffe0002006fc:	fef43423          	sd	a5,-24(s0)
            printk("[PID = %d] is running. auto_inc_local_var = %d\n", current->pid, auto_inc_local_var);
ffffffe000200700:	00006797          	auipc	a5,0x6
ffffffe000200704:	91078793          	addi	a5,a5,-1776 # ffffffe000206010 <current>
ffffffe000200708:	0007b783          	ld	a5,0(a5)
ffffffe00020070c:	0187b783          	ld	a5,24(a5)
ffffffe000200710:	fe843603          	ld	a2,-24(s0)
ffffffe000200714:	00078593          	mv	a1,a5
ffffffe000200718:	00003517          	auipc	a0,0x3
ffffffe00020071c:	91850513          	addi	a0,a0,-1768 # ffffffe000203030 <_srodata+0x30>
ffffffe000200720:	14d010ef          	jal	ffffffe00020206c <printk>
            #if TEST_SCHED
            tasks_output[tasks_output_index++] = current->pid + '0';
ffffffe000200724:	00006797          	auipc	a5,0x6
ffffffe000200728:	8ec78793          	addi	a5,a5,-1812 # ffffffe000206010 <current>
ffffffe00020072c:	0007b783          	ld	a5,0(a5)
ffffffe000200730:	0187b783          	ld	a5,24(a5)
ffffffe000200734:	0ff7f713          	zext.b	a4,a5
ffffffe000200738:	00006797          	auipc	a5,0x6
ffffffe00020073c:	8e078793          	addi	a5,a5,-1824 # ffffffe000206018 <tasks_output_index>
ffffffe000200740:	0007a783          	lw	a5,0(a5)
ffffffe000200744:	0017869b          	addiw	a3,a5,1
ffffffe000200748:	0006861b          	sext.w	a2,a3
ffffffe00020074c:	00006697          	auipc	a3,0x6
ffffffe000200750:	8cc68693          	addi	a3,a3,-1844 # ffffffe000206018 <tasks_output_index>
ffffffe000200754:	00c6a023          	sw	a2,0(a3)
ffffffe000200758:	0307071b          	addiw	a4,a4,48
ffffffe00020075c:	0ff77713          	zext.b	a4,a4
ffffffe000200760:	00006697          	auipc	a3,0x6
ffffffe000200764:	8f068693          	addi	a3,a3,-1808 # ffffffe000206050 <tasks_output>
ffffffe000200768:	00f687b3          	add	a5,a3,a5
ffffffe00020076c:	00e78023          	sb	a4,0(a5)
            if (tasks_output_index == MAX_OUTPUT) {
ffffffe000200770:	00006797          	auipc	a5,0x6
ffffffe000200774:	8a878793          	addi	a5,a5,-1880 # ffffffe000206018 <tasks_output_index>
ffffffe000200778:	0007a783          	lw	a5,0(a5)
ffffffe00020077c:	00078713          	mv	a4,a5
ffffffe000200780:	02800793          	li	a5,40
ffffffe000200784:	eef714e3          	bne	a4,a5,ffffffe00020066c <dummy+0x28>
                for (int i = 0; i < MAX_OUTPUT; ++i) {
ffffffe000200788:	fe042023          	sw	zero,-32(s0)
ffffffe00020078c:	0800006f          	j	ffffffe00020080c <dummy+0x1c8>
                    if (tasks_output[i] != expected_output[i]) {
ffffffe000200790:	00006717          	auipc	a4,0x6
ffffffe000200794:	8c070713          	addi	a4,a4,-1856 # ffffffe000206050 <tasks_output>
ffffffe000200798:	fe042783          	lw	a5,-32(s0)
ffffffe00020079c:	00f707b3          	add	a5,a4,a5
ffffffe0002007a0:	0007c683          	lbu	a3,0(a5)
ffffffe0002007a4:	00004717          	auipc	a4,0x4
ffffffe0002007a8:	86470713          	addi	a4,a4,-1948 # ffffffe000204008 <expected_output>
ffffffe0002007ac:	fe042783          	lw	a5,-32(s0)
ffffffe0002007b0:	00f707b3          	add	a5,a4,a5
ffffffe0002007b4:	0007c783          	lbu	a5,0(a5)
ffffffe0002007b8:	00068713          	mv	a4,a3
ffffffe0002007bc:	04f70263          	beq	a4,a5,ffffffe000200800 <dummy+0x1bc>
                        printk("\033[31mTest failed!\033[0m\n");
ffffffe0002007c0:	00003517          	auipc	a0,0x3
ffffffe0002007c4:	8a050513          	addi	a0,a0,-1888 # ffffffe000203060 <_srodata+0x60>
ffffffe0002007c8:	0a5010ef          	jal	ffffffe00020206c <printk>
                        printk("\033[31m    Expected: %s\033[0m\n", expected_output);
ffffffe0002007cc:	00004597          	auipc	a1,0x4
ffffffe0002007d0:	83c58593          	addi	a1,a1,-1988 # ffffffe000204008 <expected_output>
ffffffe0002007d4:	00003517          	auipc	a0,0x3
ffffffe0002007d8:	8a450513          	addi	a0,a0,-1884 # ffffffe000203078 <_srodata+0x78>
ffffffe0002007dc:	091010ef          	jal	ffffffe00020206c <printk>
                        printk("\033[31m    Got:      %s\033[0m\n", tasks_output);
ffffffe0002007e0:	00006597          	auipc	a1,0x6
ffffffe0002007e4:	87058593          	addi	a1,a1,-1936 # ffffffe000206050 <tasks_output>
ffffffe0002007e8:	00003517          	auipc	a0,0x3
ffffffe0002007ec:	8b050513          	addi	a0,a0,-1872 # ffffffe000203098 <_srodata+0x98>
ffffffe0002007f0:	07d010ef          	jal	ffffffe00020206c <printk>
                        sbi_system_reset(SBI_SRST_RESET_TYPE_SHUTDOWN, SBI_SRST_RESET_REASON_NONE);
ffffffe0002007f4:	00000593          	li	a1,0
ffffffe0002007f8:	00000513          	li	a0,0
ffffffe0002007fc:	49c000ef          	jal	ffffffe000200c98 <sbi_system_reset>
                for (int i = 0; i < MAX_OUTPUT; ++i) {
ffffffe000200800:	fe042783          	lw	a5,-32(s0)
ffffffe000200804:	0017879b          	addiw	a5,a5,1
ffffffe000200808:	fef42023          	sw	a5,-32(s0)
ffffffe00020080c:	fe042783          	lw	a5,-32(s0)
ffffffe000200810:	0007871b          	sext.w	a4,a5
ffffffe000200814:	02700793          	li	a5,39
ffffffe000200818:	f6e7dce3          	bge	a5,a4,ffffffe000200790 <dummy+0x14c>
                    }
                }
                printk("\033[32mTest passed!\033[0m\n");
ffffffe00020081c:	00003517          	auipc	a0,0x3
ffffffe000200820:	89c50513          	addi	a0,a0,-1892 # ffffffe0002030b8 <_srodata+0xb8>
ffffffe000200824:	049010ef          	jal	ffffffe00020206c <printk>
                printk("\033[32m    Output: %s\033[0m\n", expected_output);
ffffffe000200828:	00003597          	auipc	a1,0x3
ffffffe00020082c:	7e058593          	addi	a1,a1,2016 # ffffffe000204008 <expected_output>
ffffffe000200830:	00003517          	auipc	a0,0x3
ffffffe000200834:	8a050513          	addi	a0,a0,-1888 # ffffffe0002030d0 <_srodata+0xd0>
ffffffe000200838:	035010ef          	jal	ffffffe00020206c <printk>
                sbi_system_reset(SBI_SRST_RESET_TYPE_SHUTDOWN, SBI_SRST_RESET_REASON_NONE);
ffffffe00020083c:	00000593          	li	a1,0
ffffffe000200840:	00000513          	li	a0,0
ffffffe000200844:	454000ef          	jal	ffffffe000200c98 <sbi_system_reset>
        if ((last_counter == -1 || current->counter != last_counter) && current->counter > 0) {
ffffffe000200848:	e25ff06f          	j	ffffffe00020066c <dummy+0x28>

ffffffe00020084c <switch_to>:
    }
}

extern void __switch_to(struct task_struct *prev, struct task_struct *next);

void switch_to(struct task_struct *next) {
ffffffe00020084c:	fd010113          	addi	sp,sp,-48
ffffffe000200850:	02113423          	sd	ra,40(sp)
ffffffe000200854:	02813023          	sd	s0,32(sp)
ffffffe000200858:	03010413          	addi	s0,sp,48
ffffffe00020085c:	fca43c23          	sd	a0,-40(s0)
    //判断下一个执行的线程 next 与当前的线程 current 是否为同一个线程
    //如果是同一个线程，则无需做任何处理，否则调用 __switch_to 进行线程切换
    if (next != current) {
ffffffe000200860:	00005797          	auipc	a5,0x5
ffffffe000200864:	7b078793          	addi	a5,a5,1968 # ffffffe000206010 <current>
ffffffe000200868:	0007b783          	ld	a5,0(a5)
ffffffe00020086c:	fd843703          	ld	a4,-40(s0)
ffffffe000200870:	06f70063          	beq	a4,a5,ffffffe0002008d0 <switch_to+0x84>
        struct task_struct *prev = current;
ffffffe000200874:	00005797          	auipc	a5,0x5
ffffffe000200878:	79c78793          	addi	a5,a5,1948 # ffffffe000206010 <current>
ffffffe00020087c:	0007b783          	ld	a5,0(a5)
ffffffe000200880:	fef43423          	sd	a5,-24(s0)
        current = next;
ffffffe000200884:	00005797          	auipc	a5,0x5
ffffffe000200888:	78c78793          	addi	a5,a5,1932 # ffffffe000206010 <current>
ffffffe00020088c:	fd843703          	ld	a4,-40(s0)
ffffffe000200890:	00e7b023          	sd	a4,0(a5)
        printk("\nswitch to [PID = %d PRIORITY = %d COUNTER = %d]\n",next->pid, next->priority, next->counter);
ffffffe000200894:	fd843783          	ld	a5,-40(s0)
ffffffe000200898:	0187b703          	ld	a4,24(a5)
ffffffe00020089c:	fd843783          	ld	a5,-40(s0)
ffffffe0002008a0:	0107b603          	ld	a2,16(a5)
ffffffe0002008a4:	fd843783          	ld	a5,-40(s0)
ffffffe0002008a8:	0087b783          	ld	a5,8(a5)
ffffffe0002008ac:	00078693          	mv	a3,a5
ffffffe0002008b0:	00070593          	mv	a1,a4
ffffffe0002008b4:	00003517          	auipc	a0,0x3
ffffffe0002008b8:	83c50513          	addi	a0,a0,-1988 # ffffffe0002030f0 <_srodata+0xf0>
ffffffe0002008bc:	7b0010ef          	jal	ffffffe00020206c <printk>
        __switch_to(prev, next);
ffffffe0002008c0:	fd843583          	ld	a1,-40(s0)
ffffffe0002008c4:	fe843503          	ld	a0,-24(s0)
ffffffe0002008c8:	8f1ff0ef          	jal	ffffffe0002001b8 <__switch_to>
ffffffe0002008cc:	0080006f          	j	ffffffe0002008d4 <switch_to+0x88>
    }
    else {
        return;
ffffffe0002008d0:	00000013          	nop
    }
}
ffffffe0002008d4:	02813083          	ld	ra,40(sp)
ffffffe0002008d8:	02013403          	ld	s0,32(sp)
ffffffe0002008dc:	03010113          	addi	sp,sp,48
ffffffe0002008e0:	00008067          	ret

ffffffe0002008e4 <do_timer>:

void do_timer() {
ffffffe0002008e4:	ff010113          	addi	sp,sp,-16
ffffffe0002008e8:	00113423          	sd	ra,8(sp)
ffffffe0002008ec:	00813023          	sd	s0,0(sp)
ffffffe0002008f0:	01010413          	addi	s0,sp,16
    // 1. 如果当前线程是 idle 线程或当前线程时间片耗尽则直接进行调度
    // 2. 否则对当前线程的运行剩余时间减 1，若剩余时间仍然大于 0 则直接返回，否则进行调度
    // YOUR CODE HERE
    if(current == idle || current->counter == 0)
ffffffe0002008f4:	00005797          	auipc	a5,0x5
ffffffe0002008f8:	71c78793          	addi	a5,a5,1820 # ffffffe000206010 <current>
ffffffe0002008fc:	0007b703          	ld	a4,0(a5)
ffffffe000200900:	00005797          	auipc	a5,0x5
ffffffe000200904:	70878793          	addi	a5,a5,1800 # ffffffe000206008 <idle>
ffffffe000200908:	0007b783          	ld	a5,0(a5)
ffffffe00020090c:	00f70c63          	beq	a4,a5,ffffffe000200924 <do_timer+0x40>
ffffffe000200910:	00005797          	auipc	a5,0x5
ffffffe000200914:	70078793          	addi	a5,a5,1792 # ffffffe000206010 <current>
ffffffe000200918:	0007b783          	ld	a5,0(a5)
ffffffe00020091c:	0087b783          	ld	a5,8(a5)
ffffffe000200920:	00079663          	bnez	a5,ffffffe00020092c <do_timer+0x48>
        schedule();
ffffffe000200924:	050000ef          	jal	ffffffe000200974 <schedule>
ffffffe000200928:	03c0006f          	j	ffffffe000200964 <do_timer+0x80>
    else {
        current->counter--;
ffffffe00020092c:	00005797          	auipc	a5,0x5
ffffffe000200930:	6e478793          	addi	a5,a5,1764 # ffffffe000206010 <current>
ffffffe000200934:	0007b783          	ld	a5,0(a5)
ffffffe000200938:	0087b703          	ld	a4,8(a5)
ffffffe00020093c:	fff70713          	addi	a4,a4,-1
ffffffe000200940:	00e7b423          	sd	a4,8(a5)
        if(current->counter > 0)
ffffffe000200944:	00005797          	auipc	a5,0x5
ffffffe000200948:	6cc78793          	addi	a5,a5,1740 # ffffffe000206010 <current>
ffffffe00020094c:	0007b783          	ld	a5,0(a5)
ffffffe000200950:	0087b783          	ld	a5,8(a5)
ffffffe000200954:	00079663          	bnez	a5,ffffffe000200960 <do_timer+0x7c>
            return;
        else 
            schedule();
ffffffe000200958:	01c000ef          	jal	ffffffe000200974 <schedule>
ffffffe00020095c:	0080006f          	j	ffffffe000200964 <do_timer+0x80>
            return;
ffffffe000200960:	00000013          	nop
    }
}
ffffffe000200964:	00813083          	ld	ra,8(sp)
ffffffe000200968:	00013403          	ld	s0,0(sp)
ffffffe00020096c:	01010113          	addi	sp,sp,16
ffffffe000200970:	00008067          	ret

ffffffe000200974 <schedule>:

void schedule() {
ffffffe000200974:	fd010113          	addi	sp,sp,-48
ffffffe000200978:	02113423          	sd	ra,40(sp)
ffffffe00020097c:	02813023          	sd	s0,32(sp)
ffffffe000200980:	03010413          	addi	s0,sp,48
    //如果所有线程 counter 都为 0，则令所有线程 counter = priority
    int flag = 0;
ffffffe000200984:	fe042623          	sw	zero,-20(s0)
    for(int i = 1; i < NR_TASKS; i++)
ffffffe000200988:	00100793          	li	a5,1
ffffffe00020098c:	fef42423          	sw	a5,-24(s0)
ffffffe000200990:	03c0006f          	j	ffffffe0002009cc <schedule+0x58>
    {
        if(task[i]->counter != 0)
ffffffe000200994:	00005717          	auipc	a4,0x5
ffffffe000200998:	69470713          	addi	a4,a4,1684 # ffffffe000206028 <task>
ffffffe00020099c:	fe842783          	lw	a5,-24(s0)
ffffffe0002009a0:	00379793          	slli	a5,a5,0x3
ffffffe0002009a4:	00f707b3          	add	a5,a4,a5
ffffffe0002009a8:	0007b783          	ld	a5,0(a5)
ffffffe0002009ac:	0087b783          	ld	a5,8(a5)
ffffffe0002009b0:	00078863          	beqz	a5,ffffffe0002009c0 <schedule+0x4c>
        {
            flag = 1;
ffffffe0002009b4:	00100793          	li	a5,1
ffffffe0002009b8:	fef42623          	sw	a5,-20(s0)
            break;
ffffffe0002009bc:	0200006f          	j	ffffffe0002009dc <schedule+0x68>
    for(int i = 1; i < NR_TASKS; i++)
ffffffe0002009c0:	fe842783          	lw	a5,-24(s0)
ffffffe0002009c4:	0017879b          	addiw	a5,a5,1
ffffffe0002009c8:	fef42423          	sw	a5,-24(s0)
ffffffe0002009cc:	fe842783          	lw	a5,-24(s0)
ffffffe0002009d0:	0007871b          	sext.w	a4,a5
ffffffe0002009d4:	00400793          	li	a5,4
ffffffe0002009d8:	fae7dee3          	bge	a5,a4,ffffffe000200994 <schedule+0x20>
        }
    }
    if(flag == 0)
ffffffe0002009dc:	fec42783          	lw	a5,-20(s0)
ffffffe0002009e0:	0007879b          	sext.w	a5,a5
ffffffe0002009e4:	0c079a63          	bnez	a5,ffffffe000200ab8 <schedule+0x144>
    {
        printk("\n");
ffffffe0002009e8:	00002517          	auipc	a0,0x2
ffffffe0002009ec:	74050513          	addi	a0,a0,1856 # ffffffe000203128 <_srodata+0x128>
ffffffe0002009f0:	67c010ef          	jal	ffffffe00020206c <printk>
        for(int i = 1; i < NR_TASKS; i++)
ffffffe0002009f4:	00100793          	li	a5,1
ffffffe0002009f8:	fef42223          	sw	a5,-28(s0)
ffffffe0002009fc:	0ac0006f          	j	ffffffe000200aa8 <schedule+0x134>
        {
            task[i]->counter = task[i]->priority;
ffffffe000200a00:	00005717          	auipc	a4,0x5
ffffffe000200a04:	62870713          	addi	a4,a4,1576 # ffffffe000206028 <task>
ffffffe000200a08:	fe442783          	lw	a5,-28(s0)
ffffffe000200a0c:	00379793          	slli	a5,a5,0x3
ffffffe000200a10:	00f707b3          	add	a5,a4,a5
ffffffe000200a14:	0007b703          	ld	a4,0(a5)
ffffffe000200a18:	00005697          	auipc	a3,0x5
ffffffe000200a1c:	61068693          	addi	a3,a3,1552 # ffffffe000206028 <task>
ffffffe000200a20:	fe442783          	lw	a5,-28(s0)
ffffffe000200a24:	00379793          	slli	a5,a5,0x3
ffffffe000200a28:	00f687b3          	add	a5,a3,a5
ffffffe000200a2c:	0007b783          	ld	a5,0(a5)
ffffffe000200a30:	01073703          	ld	a4,16(a4)
ffffffe000200a34:	00e7b423          	sd	a4,8(a5)
            printk("SET [PID = %d PRIORITY = %d COUNTER = %d]\n", task[i]->pid, task[i]->priority, task[i]->counter);
ffffffe000200a38:	00005717          	auipc	a4,0x5
ffffffe000200a3c:	5f070713          	addi	a4,a4,1520 # ffffffe000206028 <task>
ffffffe000200a40:	fe442783          	lw	a5,-28(s0)
ffffffe000200a44:	00379793          	slli	a5,a5,0x3
ffffffe000200a48:	00f707b3          	add	a5,a4,a5
ffffffe000200a4c:	0007b783          	ld	a5,0(a5)
ffffffe000200a50:	0187b583          	ld	a1,24(a5)
ffffffe000200a54:	00005717          	auipc	a4,0x5
ffffffe000200a58:	5d470713          	addi	a4,a4,1492 # ffffffe000206028 <task>
ffffffe000200a5c:	fe442783          	lw	a5,-28(s0)
ffffffe000200a60:	00379793          	slli	a5,a5,0x3
ffffffe000200a64:	00f707b3          	add	a5,a4,a5
ffffffe000200a68:	0007b783          	ld	a5,0(a5)
ffffffe000200a6c:	0107b603          	ld	a2,16(a5)
ffffffe000200a70:	00005717          	auipc	a4,0x5
ffffffe000200a74:	5b870713          	addi	a4,a4,1464 # ffffffe000206028 <task>
ffffffe000200a78:	fe442783          	lw	a5,-28(s0)
ffffffe000200a7c:	00379793          	slli	a5,a5,0x3
ffffffe000200a80:	00f707b3          	add	a5,a4,a5
ffffffe000200a84:	0007b783          	ld	a5,0(a5)
ffffffe000200a88:	0087b783          	ld	a5,8(a5)
ffffffe000200a8c:	00078693          	mv	a3,a5
ffffffe000200a90:	00002517          	auipc	a0,0x2
ffffffe000200a94:	6a050513          	addi	a0,a0,1696 # ffffffe000203130 <_srodata+0x130>
ffffffe000200a98:	5d4010ef          	jal	ffffffe00020206c <printk>
        for(int i = 1; i < NR_TASKS; i++)
ffffffe000200a9c:	fe442783          	lw	a5,-28(s0)
ffffffe000200aa0:	0017879b          	addiw	a5,a5,1
ffffffe000200aa4:	fef42223          	sw	a5,-28(s0)
ffffffe000200aa8:	fe442783          	lw	a5,-28(s0)
ffffffe000200aac:	0007871b          	sext.w	a4,a5
ffffffe000200ab0:	00400793          	li	a5,4
ffffffe000200ab4:	f4e7d6e3          	bge	a5,a4,ffffffe000200a00 <schedule+0x8c>
        }
            
    }
    //调度时选择 counter 最大的线程运行
    int max = 0;
ffffffe000200ab8:	fe042023          	sw	zero,-32(s0)
    int next = 0;
ffffffe000200abc:	fc042e23          	sw	zero,-36(s0)
    for(int i = 1; i < NR_TASKS; i++)
ffffffe000200ac0:	00100793          	li	a5,1
ffffffe000200ac4:	fcf42c23          	sw	a5,-40(s0)
ffffffe000200ac8:	05c0006f          	j	ffffffe000200b24 <schedule+0x1b0>
    {
        if(task[i]->counter > max)
ffffffe000200acc:	00005717          	auipc	a4,0x5
ffffffe000200ad0:	55c70713          	addi	a4,a4,1372 # ffffffe000206028 <task>
ffffffe000200ad4:	fd842783          	lw	a5,-40(s0)
ffffffe000200ad8:	00379793          	slli	a5,a5,0x3
ffffffe000200adc:	00f707b3          	add	a5,a4,a5
ffffffe000200ae0:	0007b783          	ld	a5,0(a5)
ffffffe000200ae4:	0087b703          	ld	a4,8(a5)
ffffffe000200ae8:	fe042783          	lw	a5,-32(s0)
ffffffe000200aec:	02e7f663          	bgeu	a5,a4,ffffffe000200b18 <schedule+0x1a4>
        {
            max = task[i]->counter;
ffffffe000200af0:	00005717          	auipc	a4,0x5
ffffffe000200af4:	53870713          	addi	a4,a4,1336 # ffffffe000206028 <task>
ffffffe000200af8:	fd842783          	lw	a5,-40(s0)
ffffffe000200afc:	00379793          	slli	a5,a5,0x3
ffffffe000200b00:	00f707b3          	add	a5,a4,a5
ffffffe000200b04:	0007b783          	ld	a5,0(a5)
ffffffe000200b08:	0087b783          	ld	a5,8(a5)
ffffffe000200b0c:	fef42023          	sw	a5,-32(s0)
            next = i;
ffffffe000200b10:	fd842783          	lw	a5,-40(s0)
ffffffe000200b14:	fcf42e23          	sw	a5,-36(s0)
    for(int i = 1; i < NR_TASKS; i++)
ffffffe000200b18:	fd842783          	lw	a5,-40(s0)
ffffffe000200b1c:	0017879b          	addiw	a5,a5,1
ffffffe000200b20:	fcf42c23          	sw	a5,-40(s0)
ffffffe000200b24:	fd842783          	lw	a5,-40(s0)
ffffffe000200b28:	0007871b          	sext.w	a4,a5
ffffffe000200b2c:	00400793          	li	a5,4
ffffffe000200b30:	f8e7dee3          	bge	a5,a4,ffffffe000200acc <schedule+0x158>
        }
    }
    
    switch_to(task[next]);
ffffffe000200b34:	00005717          	auipc	a4,0x5
ffffffe000200b38:	4f470713          	addi	a4,a4,1268 # ffffffe000206028 <task>
ffffffe000200b3c:	fdc42783          	lw	a5,-36(s0)
ffffffe000200b40:	00379793          	slli	a5,a5,0x3
ffffffe000200b44:	00f707b3          	add	a5,a4,a5
ffffffe000200b48:	0007b783          	ld	a5,0(a5)
ffffffe000200b4c:	00078513          	mv	a0,a5
ffffffe000200b50:	cfdff0ef          	jal	ffffffe00020084c <switch_to>
ffffffe000200b54:	00000013          	nop
ffffffe000200b58:	02813083          	ld	ra,40(sp)
ffffffe000200b5c:	02013403          	ld	s0,32(sp)
ffffffe000200b60:	03010113          	addi	sp,sp,48
ffffffe000200b64:	00008067          	ret

ffffffe000200b68 <sbi_ecall>:
#include "stdint.h"
#include "sbi.h"

struct sbiret sbi_ecall(uint64_t eid, uint64_t fid,
                        uint64_t arg0, uint64_t arg1, uint64_t arg2,
                        uint64_t arg3, uint64_t arg4, uint64_t arg5) {
ffffffe000200b68:	f8010113          	addi	sp,sp,-128
ffffffe000200b6c:	06813c23          	sd	s0,120(sp)
ffffffe000200b70:	06913823          	sd	s1,112(sp)
ffffffe000200b74:	07213423          	sd	s2,104(sp)
ffffffe000200b78:	07313023          	sd	s3,96(sp)
ffffffe000200b7c:	08010413          	addi	s0,sp,128
ffffffe000200b80:	faa43c23          	sd	a0,-72(s0)
ffffffe000200b84:	fab43823          	sd	a1,-80(s0)
ffffffe000200b88:	fac43423          	sd	a2,-88(s0)
ffffffe000200b8c:	fad43023          	sd	a3,-96(s0)
ffffffe000200b90:	f8e43c23          	sd	a4,-104(s0)
ffffffe000200b94:	f8f43823          	sd	a5,-112(s0)
ffffffe000200b98:	f9043423          	sd	a6,-120(s0)
ffffffe000200b9c:	f9143023          	sd	a7,-128(s0)
    struct sbiret ret;
	__asm__ volatile(
ffffffe000200ba0:	fb843e03          	ld	t3,-72(s0)
ffffffe000200ba4:	fb043e83          	ld	t4,-80(s0)
ffffffe000200ba8:	fa843f03          	ld	t5,-88(s0)
ffffffe000200bac:	fa043f83          	ld	t6,-96(s0)
ffffffe000200bb0:	f9843283          	ld	t0,-104(s0)
ffffffe000200bb4:	f9043483          	ld	s1,-112(s0)
ffffffe000200bb8:	f8843903          	ld	s2,-120(s0)
ffffffe000200bbc:	f8043983          	ld	s3,-128(s0)
ffffffe000200bc0:	000e0893          	mv	a7,t3
ffffffe000200bc4:	000e8813          	mv	a6,t4
ffffffe000200bc8:	000f0513          	mv	a0,t5
ffffffe000200bcc:	000f8593          	mv	a1,t6
ffffffe000200bd0:	00028613          	mv	a2,t0
ffffffe000200bd4:	00048693          	mv	a3,s1
ffffffe000200bd8:	00090713          	mv	a4,s2
ffffffe000200bdc:	00098793          	mv	a5,s3
ffffffe000200be0:	00000073          	ecall
ffffffe000200be4:	00050e93          	mv	t4,a0
ffffffe000200be8:	00058e13          	mv	t3,a1
ffffffe000200bec:	fdd43023          	sd	t4,-64(s0)
ffffffe000200bf0:	fdc43423          	sd	t3,-56(s0)
		: [error] "=r"(ret.error), [value] "=r"(ret.value)
		: [eid] "r"(eid), [fid] "r"(fid), [arg0] "r"(arg0), [arg1] "r"(arg1),
		  [arg2] "r"(arg2), [arg3] "r"(arg3), [arg4] "r"(arg4), [arg5] "r"(arg5)
		: "memory","a0","a1","a2","a3","a4","a5","a6","a7"
		);
	return ret;
ffffffe000200bf4:	fc043783          	ld	a5,-64(s0)
ffffffe000200bf8:	fcf43823          	sd	a5,-48(s0)
ffffffe000200bfc:	fc843783          	ld	a5,-56(s0)
ffffffe000200c00:	fcf43c23          	sd	a5,-40(s0)
ffffffe000200c04:	fd043703          	ld	a4,-48(s0)
ffffffe000200c08:	fd843783          	ld	a5,-40(s0)
ffffffe000200c0c:	00070313          	mv	t1,a4
ffffffe000200c10:	00078393          	mv	t2,a5
ffffffe000200c14:	00030713          	mv	a4,t1
ffffffe000200c18:	00038793          	mv	a5,t2
}
ffffffe000200c1c:	00070513          	mv	a0,a4
ffffffe000200c20:	00078593          	mv	a1,a5
ffffffe000200c24:	07813403          	ld	s0,120(sp)
ffffffe000200c28:	07013483          	ld	s1,112(sp)
ffffffe000200c2c:	06813903          	ld	s2,104(sp)
ffffffe000200c30:	06013983          	ld	s3,96(sp)
ffffffe000200c34:	08010113          	addi	sp,sp,128
ffffffe000200c38:	00008067          	ret

ffffffe000200c3c <sbi_debug_console_write_byte>:

struct sbiret sbi_debug_console_write_byte(uint8_t byte) {
ffffffe000200c3c:	fe010113          	addi	sp,sp,-32
ffffffe000200c40:	00113c23          	sd	ra,24(sp)
ffffffe000200c44:	00813823          	sd	s0,16(sp)
ffffffe000200c48:	02010413          	addi	s0,sp,32
ffffffe000200c4c:	00050793          	mv	a5,a0
ffffffe000200c50:	fef407a3          	sb	a5,-17(s0)
    sbi_ecall(SBI_DBCN_EXT, SBI_DBCN_WRITE_BYTE, byte, 0, 0, 0, 0, 0);
ffffffe000200c54:	fef44603          	lbu	a2,-17(s0)
ffffffe000200c58:	00000893          	li	a7,0
ffffffe000200c5c:	00000813          	li	a6,0
ffffffe000200c60:	00000793          	li	a5,0
ffffffe000200c64:	00000713          	li	a4,0
ffffffe000200c68:	00000693          	li	a3,0
ffffffe000200c6c:	00200593          	li	a1,2
ffffffe000200c70:	44424537          	lui	a0,0x44424
ffffffe000200c74:	34e50513          	addi	a0,a0,846 # 4442434e <PHY_SIZE+0x3c42434e>
ffffffe000200c78:	ef1ff0ef          	jal	ffffffe000200b68 <sbi_ecall>
}
ffffffe000200c7c:	00000013          	nop
ffffffe000200c80:	00070513          	mv	a0,a4
ffffffe000200c84:	00078593          	mv	a1,a5
ffffffe000200c88:	01813083          	ld	ra,24(sp)
ffffffe000200c8c:	01013403          	ld	s0,16(sp)
ffffffe000200c90:	02010113          	addi	sp,sp,32
ffffffe000200c94:	00008067          	ret

ffffffe000200c98 <sbi_system_reset>:

struct sbiret sbi_system_reset(uint32_t reset_type, uint32_t reset_reason) {
ffffffe000200c98:	fe010113          	addi	sp,sp,-32
ffffffe000200c9c:	00113c23          	sd	ra,24(sp)
ffffffe000200ca0:	00813823          	sd	s0,16(sp)
ffffffe000200ca4:	02010413          	addi	s0,sp,32
ffffffe000200ca8:	00050793          	mv	a5,a0
ffffffe000200cac:	00058713          	mv	a4,a1
ffffffe000200cb0:	fef42623          	sw	a5,-20(s0)
ffffffe000200cb4:	00070793          	mv	a5,a4
ffffffe000200cb8:	fef42423          	sw	a5,-24(s0)
    sbi_ecall(SBI_SRST_EXT, SBI_SRST, reset_type, reset_reason, 0, 0, 0, 0);
ffffffe000200cbc:	fec46603          	lwu	a2,-20(s0)
ffffffe000200cc0:	fe846683          	lwu	a3,-24(s0)
ffffffe000200cc4:	00000893          	li	a7,0
ffffffe000200cc8:	00000813          	li	a6,0
ffffffe000200ccc:	00000793          	li	a5,0
ffffffe000200cd0:	00000713          	li	a4,0
ffffffe000200cd4:	00000593          	li	a1,0
ffffffe000200cd8:	53525537          	lui	a0,0x53525
ffffffe000200cdc:	35450513          	addi	a0,a0,852 # 53525354 <PHY_SIZE+0x4b525354>
ffffffe000200ce0:	e89ff0ef          	jal	ffffffe000200b68 <sbi_ecall>
}
ffffffe000200ce4:	00000013          	nop
ffffffe000200ce8:	00070513          	mv	a0,a4
ffffffe000200cec:	00078593          	mv	a1,a5
ffffffe000200cf0:	01813083          	ld	ra,24(sp)
ffffffe000200cf4:	01013403          	ld	s0,16(sp)
ffffffe000200cf8:	02010113          	addi	sp,sp,32
ffffffe000200cfc:	00008067          	ret

ffffffe000200d00 <sbi_set_timer>:

struct sbiret sbi_set_timer(uint64_t stime_value) {
ffffffe000200d00:	fe010113          	addi	sp,sp,-32
ffffffe000200d04:	00113c23          	sd	ra,24(sp)
ffffffe000200d08:	00813823          	sd	s0,16(sp)
ffffffe000200d0c:	02010413          	addi	s0,sp,32
ffffffe000200d10:	fea43423          	sd	a0,-24(s0)
    sbi_ecall(SBI_SET_TIMER_EXT, SBI_SET_TIMER, stime_value, 0, 0, 0, 0, 0);
ffffffe000200d14:	00000893          	li	a7,0
ffffffe000200d18:	00000813          	li	a6,0
ffffffe000200d1c:	00000793          	li	a5,0
ffffffe000200d20:	00000713          	li	a4,0
ffffffe000200d24:	00000693          	li	a3,0
ffffffe000200d28:	fe843603          	ld	a2,-24(s0)
ffffffe000200d2c:	00000593          	li	a1,0
ffffffe000200d30:	54495537          	lui	a0,0x54495
ffffffe000200d34:	d4550513          	addi	a0,a0,-699 # 54494d45 <PHY_SIZE+0x4c494d45>
ffffffe000200d38:	e31ff0ef          	jal	ffffffe000200b68 <sbi_ecall>
ffffffe000200d3c:	00000013          	nop
ffffffe000200d40:	00070513          	mv	a0,a4
ffffffe000200d44:	00078593          	mv	a1,a5
ffffffe000200d48:	01813083          	ld	ra,24(sp)
ffffffe000200d4c:	01013403          	ld	s0,16(sp)
ffffffe000200d50:	02010113          	addi	sp,sp,32
ffffffe000200d54:	00008067          	ret

ffffffe000200d58 <trap_handler>:
#include "stdint.h"
#include "printk.h"

extern void clock_set_next_event();

void trap_handler(uint64_t scause, uint64_t sepc) {
ffffffe000200d58:	fe010113          	addi	sp,sp,-32
ffffffe000200d5c:	00113c23          	sd	ra,24(sp)
ffffffe000200d60:	00813823          	sd	s0,16(sp)
ffffffe000200d64:	02010413          	addi	s0,sp,32
ffffffe000200d68:	fea43423          	sd	a0,-24(s0)
ffffffe000200d6c:	feb43023          	sd	a1,-32(s0)
    // 通过 `scause` 判断trap类型
    if (scause >> 63){ 
ffffffe000200d70:	fe843783          	ld	a5,-24(s0)
ffffffe000200d74:	0007de63          	bgez	a5,ffffffe000200d90 <trap_handler+0x38>
        // 如果是interrupt 判断是否是timer interrupt
        if (scause % 8 == 5) { 
ffffffe000200d78:	fe843783          	ld	a5,-24(s0)
ffffffe000200d7c:	0077f713          	andi	a4,a5,7
ffffffe000200d80:	00500793          	li	a5,5
ffffffe000200d84:	00f71663          	bne	a4,a5,ffffffe000200d90 <trap_handler+0x38>
            // 如果是timer interrupt 则打印输出相关信息, 并通过 `clock_set_next_event()` 设置下一次时钟中断
            //printk("[S] Supervisor Mode Timer Interrupt\n"); 
            clock_set_next_event();
ffffffe000200d88:	cd4ff0ef          	jal	ffffffe00020025c <clock_set_next_event>
            do_timer();
ffffffe000200d8c:	b59ff0ef          	jal	ffffffe0002008e4 <do_timer>
        }
    }
    // `clock_set_next_event()` 见 4.3.4 节
    // 其他interrupt / exception 可以直接忽略
ffffffe000200d90:	00000013          	nop
ffffffe000200d94:	01813083          	ld	ra,24(sp)
ffffffe000200d98:	01013403          	ld	s0,16(sp)
ffffffe000200d9c:	02010113          	addi	sp,sp,32
ffffffe000200da0:	00008067          	ret

ffffffe000200da4 <setup_vm>:


/* early_pgtbl: 用于 setup_vm 进行 1GiB 的映射 */
uint64_t early_pgtbl[512] __attribute__((__aligned__(0x1000)));//8字节*512=4KiB（页表大小）

void setup_vm() {
ffffffe000200da4:	fe010113          	addi	sp,sp,-32
ffffffe000200da8:	00113c23          	sd	ra,24(sp)
ffffffe000200dac:	00813823          	sd	s0,16(sp)
ffffffe000200db0:	02010413          	addi	s0,sp,32
     *     低 30 bit 作为页内偏移，这里注意到 30 = 9 + 9 + 12，即我们只使用根页表，根页表的每个 entry 都对应 1GiB 的区域
     * 3. Page Table Entry 的权限 V | R | W | X 位设置为 1
    **/
   
    //将early_pgtbl清零
    memset(early_pgtbl,0,PGSIZE);
ffffffe000200db4:	00001637          	lui	a2,0x1
ffffffe000200db8:	00000593          	li	a1,0
ffffffe000200dbc:	00006517          	auipc	a0,0x6
ffffffe000200dc0:	24450513          	addi	a0,a0,580 # ffffffe000207000 <early_pgtbl>
ffffffe000200dc4:	3c8010ef          	jal	ffffffe00020218c <memset>
    int index;
    //得到PHY_START->VM_START的index值(等值映射)
    index = PHY_START >> 30 & 0x1ff;//中间9bit作index
ffffffe000200dc8:	00200793          	li	a5,2
ffffffe000200dcc:	fef42623          	sw	a5,-20(s0)
    //从PHY_START得到PPN[2]的值放入early_pgtbl[index]中，且后四位设为1
    early_pgtbl[index] = ((PHY_START >> 30) << 28) | 0xf;
ffffffe000200dd0:	00006717          	auipc	a4,0x6
ffffffe000200dd4:	23070713          	addi	a4,a4,560 # ffffffe000207000 <early_pgtbl>
ffffffe000200dd8:	fec42783          	lw	a5,-20(s0)
ffffffe000200ddc:	00379793          	slli	a5,a5,0x3
ffffffe000200de0:	00f707b3          	add	a5,a4,a5
ffffffe000200de4:	20000737          	lui	a4,0x20000
ffffffe000200de8:	00f70713          	addi	a4,a4,15 # 2000000f <PHY_SIZE+0x1800000f>
ffffffe000200dec:	00e7b023          	sd	a4,0(a5)

    //映射到 direct mapping area
    index = VM_START >> 30 & 0x1ff;
ffffffe000200df0:	18000793          	li	a5,384
ffffffe000200df4:	fef42623          	sw	a5,-20(s0)
    early_pgtbl[index] = ((PHY_START >> 30) << 28) | 0xf; 
ffffffe000200df8:	00006717          	auipc	a4,0x6
ffffffe000200dfc:	20870713          	addi	a4,a4,520 # ffffffe000207000 <early_pgtbl>
ffffffe000200e00:	fec42783          	lw	a5,-20(s0)
ffffffe000200e04:	00379793          	slli	a5,a5,0x3
ffffffe000200e08:	00f707b3          	add	a5,a4,a5
ffffffe000200e0c:	20000737          	lui	a4,0x20000
ffffffe000200e10:	00f70713          	addi	a4,a4,15 # 2000000f <PHY_SIZE+0x1800000f>
ffffffe000200e14:	00e7b023          	sd	a4,0(a5)
    printk("setup_vm done!\n");
ffffffe000200e18:	00002517          	auipc	a0,0x2
ffffffe000200e1c:	34850513          	addi	a0,a0,840 # ffffffe000203160 <_srodata+0x160>
ffffffe000200e20:	24c010ef          	jal	ffffffe00020206c <printk>
}
ffffffe000200e24:	00000013          	nop
ffffffe000200e28:	01813083          	ld	ra,24(sp)
ffffffe000200e2c:	01013403          	ld	s0,16(sp)
ffffffe000200e30:	02010113          	addi	sp,sp,32
ffffffe000200e34:	00008067          	ret

ffffffe000200e38 <setup_vm_final>:
extern void _etext();
extern void _srodata();
extern void _erodata();
extern void _sdata();

void setup_vm_final() {
ffffffe000200e38:	fe010113          	addi	sp,sp,-32
ffffffe000200e3c:	00113c23          	sd	ra,24(sp)
ffffffe000200e40:	00813823          	sd	s0,16(sp)
ffffffe000200e44:	02010413          	addi	s0,sp,32
    printk("setup_vm_final start!\n");
ffffffe000200e48:	00002517          	auipc	a0,0x2
ffffffe000200e4c:	32850513          	addi	a0,a0,808 # ffffffe000203170 <_srodata+0x170>
ffffffe000200e50:	21c010ef          	jal	ffffffe00020206c <printk>
    memset(swapper_pg_dir, 0x0, PGSIZE);
ffffffe000200e54:	00001637          	lui	a2,0x1
ffffffe000200e58:	00000593          	li	a1,0
ffffffe000200e5c:	00007517          	auipc	a0,0x7
ffffffe000200e60:	1a450513          	addi	a0,a0,420 # ffffffe000208000 <swapper_pg_dir>
ffffffe000200e64:	328010ef          	jal	ffffffe00020218c <memset>
    // No OpenSBI mapping required

    // mapping kernel text X|-|R|V
    create_mapping(swapper_pg_dir, (uint64_t)_stext, (uint64_t)_stext - PA2VA_OFFSET, (uint64_t)_etext - (uint64_t)_stext,11);
ffffffe000200e68:	fffff597          	auipc	a1,0xfffff
ffffffe000200e6c:	19858593          	addi	a1,a1,408 # ffffffe000200000 <_skernel>
ffffffe000200e70:	fffff717          	auipc	a4,0xfffff
ffffffe000200e74:	19070713          	addi	a4,a4,400 # ffffffe000200000 <_skernel>
ffffffe000200e78:	04100793          	li	a5,65
ffffffe000200e7c:	01f79793          	slli	a5,a5,0x1f
ffffffe000200e80:	00f70633          	add	a2,a4,a5
ffffffe000200e84:	00001717          	auipc	a4,0x1
ffffffe000200e88:	37870713          	addi	a4,a4,888 # ffffffe0002021fc <_etext>
ffffffe000200e8c:	fffff797          	auipc	a5,0xfffff
ffffffe000200e90:	17478793          	addi	a5,a5,372 # ffffffe000200000 <_skernel>
ffffffe000200e94:	40f707b3          	sub	a5,a4,a5
ffffffe000200e98:	00b00713          	li	a4,11
ffffffe000200e9c:	00078693          	mv	a3,a5
ffffffe000200ea0:	00007517          	auipc	a0,0x7
ffffffe000200ea4:	16050513          	addi	a0,a0,352 # ffffffe000208000 <swapper_pg_dir>
ffffffe000200ea8:	0f0000ef          	jal	ffffffe000200f98 <create_mapping>

    // mapping kernel rodata -|-|R|V
    create_mapping(swapper_pg_dir, (uint64_t)_srodata, (uint64_t)_srodata - PA2VA_OFFSET, (uint64_t)_erodata - (uint64_t)_srodata, 3);
ffffffe000200eac:	00002597          	auipc	a1,0x2
ffffffe000200eb0:	15458593          	addi	a1,a1,340 # ffffffe000203000 <_srodata>
ffffffe000200eb4:	00002717          	auipc	a4,0x2
ffffffe000200eb8:	14c70713          	addi	a4,a4,332 # ffffffe000203000 <_srodata>
ffffffe000200ebc:	04100793          	li	a5,65
ffffffe000200ec0:	01f79793          	slli	a5,a5,0x1f
ffffffe000200ec4:	00f70633          	add	a2,a4,a5
ffffffe000200ec8:	00002717          	auipc	a4,0x2
ffffffe000200ecc:	35070713          	addi	a4,a4,848 # ffffffe000203218 <_erodata>
ffffffe000200ed0:	00002797          	auipc	a5,0x2
ffffffe000200ed4:	13078793          	addi	a5,a5,304 # ffffffe000203000 <_srodata>
ffffffe000200ed8:	40f707b3          	sub	a5,a4,a5
ffffffe000200edc:	00300713          	li	a4,3
ffffffe000200ee0:	00078693          	mv	a3,a5
ffffffe000200ee4:	00007517          	auipc	a0,0x7
ffffffe000200ee8:	11c50513          	addi	a0,a0,284 # ffffffe000208000 <swapper_pg_dir>
ffffffe000200eec:	0ac000ef          	jal	ffffffe000200f98 <create_mapping>

    // mapping other memory -|W|R|V
    create_mapping(swapper_pg_dir, (uint64_t)_sdata, (uint64_t)_sdata - PA2VA_OFFSET, PHY_SIZE - (uint64_t)_srodata + (uint64_t)_stext, 7);
ffffffe000200ef0:	00003597          	auipc	a1,0x3
ffffffe000200ef4:	11058593          	addi	a1,a1,272 # ffffffe000204000 <TIMECLOCK>
ffffffe000200ef8:	00003717          	auipc	a4,0x3
ffffffe000200efc:	10870713          	addi	a4,a4,264 # ffffffe000204000 <TIMECLOCK>
ffffffe000200f00:	04100793          	li	a5,65
ffffffe000200f04:	01f79793          	slli	a5,a5,0x1f
ffffffe000200f08:	00f70633          	add	a2,a4,a5
ffffffe000200f0c:	fffff717          	auipc	a4,0xfffff
ffffffe000200f10:	0f470713          	addi	a4,a4,244 # ffffffe000200000 <_skernel>
ffffffe000200f14:	00002797          	auipc	a5,0x2
ffffffe000200f18:	0ec78793          	addi	a5,a5,236 # ffffffe000203000 <_srodata>
ffffffe000200f1c:	40f70733          	sub	a4,a4,a5
ffffffe000200f20:	080007b7          	lui	a5,0x8000
ffffffe000200f24:	00f707b3          	add	a5,a4,a5
ffffffe000200f28:	00700713          	li	a4,7
ffffffe000200f2c:	00078693          	mv	a3,a5
ffffffe000200f30:	00007517          	auipc	a0,0x7
ffffffe000200f34:	0d050513          	addi	a0,a0,208 # ffffffe000208000 <swapper_pg_dir>
ffffffe000200f38:	060000ef          	jal	ffffffe000200f98 <create_mapping>
    addi t0, x0, 1
    li t2, 63
    sll t0, t0, t2
    or t1, t1, t0
    csrw satp, t1*/
    uint64_t satpswapper = (((uint64_t)swapper_pg_dir - PA2VA_OFFSET) >> 12) | (0x8000000000000000);
ffffffe000200f3c:	00007717          	auipc	a4,0x7
ffffffe000200f40:	0c470713          	addi	a4,a4,196 # ffffffe000208000 <swapper_pg_dir>
ffffffe000200f44:	04100793          	li	a5,65
ffffffe000200f48:	01f79793          	slli	a5,a5,0x1f
ffffffe000200f4c:	00f707b3          	add	a5,a4,a5
ffffffe000200f50:	00c7d713          	srli	a4,a5,0xc
ffffffe000200f54:	fff00793          	li	a5,-1
ffffffe000200f58:	03f79793          	slli	a5,a5,0x3f
ffffffe000200f5c:	00f767b3          	or	a5,a4,a5
ffffffe000200f60:	fef43423          	sd	a5,-24(s0)
    csr_write(satp, satpswapper);
ffffffe000200f64:	fe843783          	ld	a5,-24(s0)
ffffffe000200f68:	fef43023          	sd	a5,-32(s0)
ffffffe000200f6c:	fe043783          	ld	a5,-32(s0)
ffffffe000200f70:	18079073          	csrw	satp,a5


    // flush TLB
    asm volatile("sfence.vma zero, zero");
ffffffe000200f74:	12000073          	sfence.vma
    printk("setup_vm_final done!\n");
ffffffe000200f78:	00002517          	auipc	a0,0x2
ffffffe000200f7c:	21050513          	addi	a0,a0,528 # ffffffe000203188 <_srodata+0x188>
ffffffe000200f80:	0ec010ef          	jal	ffffffe00020206c <printk>
    return;
ffffffe000200f84:	00000013          	nop
}
ffffffe000200f88:	01813083          	ld	ra,24(sp)
ffffffe000200f8c:	01013403          	ld	s0,16(sp)
ffffffe000200f90:	02010113          	addi	sp,sp,32
ffffffe000200f94:	00008067          	ret

ffffffe000200f98 <create_mapping>:


/* 创建多级页表映射关系 */
/* 不要修改该接口的参数和返回值 */
void create_mapping(uint64_t *pgtbl, uint64_t va, uint64_t pa, uint64_t sz, uint64_t perm) {
ffffffe000200f98:	f8010113          	addi	sp,sp,-128
ffffffe000200f9c:	06113c23          	sd	ra,120(sp)
ffffffe000200fa0:	06813823          	sd	s0,112(sp)
ffffffe000200fa4:	08010413          	addi	s0,sp,128
ffffffe000200fa8:	faa43423          	sd	a0,-88(s0)
ffffffe000200fac:	fab43023          	sd	a1,-96(s0)
ffffffe000200fb0:	f8c43c23          	sd	a2,-104(s0)
ffffffe000200fb4:	f8d43823          	sd	a3,-112(s0)
ffffffe000200fb8:	f8e43423          	sd	a4,-120(s0)
     * 创建多级页表的时候可以使用 kalloc() 来获取一页作为页表目录
     * 可以使用 V bit 来判断页表项是否存在
    **/

    // 确认映射的范围
    uint64_t end = va + sz;
ffffffe000200fbc:	fa043703          	ld	a4,-96(s0)
ffffffe000200fc0:	f9043783          	ld	a5,-112(s0)
ffffffe000200fc4:	00f707b3          	add	a5,a4,a5
ffffffe000200fc8:	fef43423          	sd	a5,-24(s0)
    while (va < end) 
ffffffe000200fcc:	1880006f          	j	ffffffe000201154 <create_mapping+0x1bc>
    {
        uint64_t *table;

        // get vpn[2]
        uint64_t vpn2 = ((va)>>30) & 0x1ff;
ffffffe000200fd0:	fa043783          	ld	a5,-96(s0)
ffffffe000200fd4:	01e7d793          	srli	a5,a5,0x1e
ffffffe000200fd8:	1ff7f793          	andi	a5,a5,511
ffffffe000200fdc:	fef43023          	sd	a5,-32(s0)
        //not valid, alloc a new page
        if ((pgtbl[vpn2] & 1) == 0) 
ffffffe000200fe0:	fe043783          	ld	a5,-32(s0)
ffffffe000200fe4:	00379793          	slli	a5,a5,0x3
ffffffe000200fe8:	fa843703          	ld	a4,-88(s0)
ffffffe000200fec:	00f707b3          	add	a5,a4,a5
ffffffe000200ff0:	0007b783          	ld	a5,0(a5) # 8000000 <PHY_SIZE>
ffffffe000200ff4:	0017f793          	andi	a5,a5,1
ffffffe000200ff8:	04079063          	bnez	a5,ffffffe000201038 <create_mapping+0xa0>
        {
            uint64_t newpage = (uint64_t)kalloc();
ffffffe000200ffc:	aa8ff0ef          	jal	ffffffe0002002a4 <kalloc>
ffffffe000201000:	00050793          	mv	a5,a0
ffffffe000201004:	fcf43c23          	sd	a5,-40(s0)
            //newpage是虚拟地址，减去PA2VA_OFFSET得到物理地址，右移12位得到PPN，左移10位得到页表项
            pgtbl[vpn2] = ((((uint64_t)newpage - PA2VA_OFFSET) >> 12) << 10) | 1;//valid=1
ffffffe000201008:	fd843703          	ld	a4,-40(s0)
ffffffe00020100c:	04100793          	li	a5,65
ffffffe000201010:	01f79793          	slli	a5,a5,0x1f
ffffffe000201014:	00f707b3          	add	a5,a4,a5
ffffffe000201018:	00c7d793          	srli	a5,a5,0xc
ffffffe00020101c:	00a79713          	slli	a4,a5,0xa
ffffffe000201020:	fe043783          	ld	a5,-32(s0)
ffffffe000201024:	00379793          	slli	a5,a5,0x3
ffffffe000201028:	fa843683          	ld	a3,-88(s0)
ffffffe00020102c:	00f687b3          	add	a5,a3,a5
ffffffe000201030:	00176713          	ori	a4,a4,1
ffffffe000201034:	00e7b023          	sd	a4,0(a5)
        }
        //pgtbl[vpn2]得到下一级页表，右移10位左移12位得到物理地址，加上PA2VA_OFFSET得到下一级页表的基虚拟地址
        table = (uint64_t*)(((pgtbl[vpn2] >> 10) << 12) + PA2VA_OFFSET);
ffffffe000201038:	fe043783          	ld	a5,-32(s0)
ffffffe00020103c:	00379793          	slli	a5,a5,0x3
ffffffe000201040:	fa843703          	ld	a4,-88(s0)
ffffffe000201044:	00f707b3          	add	a5,a4,a5
ffffffe000201048:	0007b783          	ld	a5,0(a5)
ffffffe00020104c:	00a7d793          	srli	a5,a5,0xa
ffffffe000201050:	00c79713          	slli	a4,a5,0xc
ffffffe000201054:	fbf00793          	li	a5,-65
ffffffe000201058:	01f79793          	slli	a5,a5,0x1f
ffffffe00020105c:	00f707b3          	add	a5,a4,a5
ffffffe000201060:	fcf43823          	sd	a5,-48(s0)

        // vpn1
        uint64_t vpn1 = ((va)>>21) & 0x1ff;
ffffffe000201064:	fa043783          	ld	a5,-96(s0)
ffffffe000201068:	0157d793          	srli	a5,a5,0x15
ffffffe00020106c:	1ff7f793          	andi	a5,a5,511
ffffffe000201070:	fcf43423          	sd	a5,-56(s0)
        if ((table[vpn1] & 1) == 0) 
ffffffe000201074:	fc843783          	ld	a5,-56(s0)
ffffffe000201078:	00379793          	slli	a5,a5,0x3
ffffffe00020107c:	fd043703          	ld	a4,-48(s0)
ffffffe000201080:	00f707b3          	add	a5,a4,a5
ffffffe000201084:	0007b783          	ld	a5,0(a5)
ffffffe000201088:	0017f793          	andi	a5,a5,1
ffffffe00020108c:	04079063          	bnez	a5,ffffffe0002010cc <create_mapping+0x134>
        {
            uint64_t newpage = (uint64_t)kalloc();
ffffffe000201090:	a14ff0ef          	jal	ffffffe0002002a4 <kalloc>
ffffffe000201094:	00050793          	mv	a5,a0
ffffffe000201098:	fcf43023          	sd	a5,-64(s0)
            table[vpn1] = ((((uint64_t)newpage - PA2VA_OFFSET) >> 12) << 10) | 1;
ffffffe00020109c:	fc043703          	ld	a4,-64(s0)
ffffffe0002010a0:	04100793          	li	a5,65
ffffffe0002010a4:	01f79793          	slli	a5,a5,0x1f
ffffffe0002010a8:	00f707b3          	add	a5,a4,a5
ffffffe0002010ac:	00c7d793          	srli	a5,a5,0xc
ffffffe0002010b0:	00a79713          	slli	a4,a5,0xa
ffffffe0002010b4:	fc843783          	ld	a5,-56(s0)
ffffffe0002010b8:	00379793          	slli	a5,a5,0x3
ffffffe0002010bc:	fd043683          	ld	a3,-48(s0)
ffffffe0002010c0:	00f687b3          	add	a5,a3,a5
ffffffe0002010c4:	00176713          	ori	a4,a4,1
ffffffe0002010c8:	00e7b023          	sd	a4,0(a5)
        }
        table = (uint64_t*)(((table[vpn1] >> 10) << 12) + PA2VA_OFFSET);
ffffffe0002010cc:	fc843783          	ld	a5,-56(s0)
ffffffe0002010d0:	00379793          	slli	a5,a5,0x3
ffffffe0002010d4:	fd043703          	ld	a4,-48(s0)
ffffffe0002010d8:	00f707b3          	add	a5,a4,a5
ffffffe0002010dc:	0007b783          	ld	a5,0(a5)
ffffffe0002010e0:	00a7d793          	srli	a5,a5,0xa
ffffffe0002010e4:	00c79713          	slli	a4,a5,0xc
ffffffe0002010e8:	fbf00793          	li	a5,-65
ffffffe0002010ec:	01f79793          	slli	a5,a5,0x1f
ffffffe0002010f0:	00f707b3          	add	a5,a4,a5
ffffffe0002010f4:	fcf43823          	sd	a5,-48(s0)

        // vpn0，不用检查有效性
        uint64_t vpn0 = ((va)>>12) & 0x1ff;
ffffffe0002010f8:	fa043783          	ld	a5,-96(s0)
ffffffe0002010fc:	00c7d793          	srli	a5,a5,0xc
ffffffe000201100:	1ff7f793          	andi	a5,a5,511
ffffffe000201104:	faf43c23          	sd	a5,-72(s0)
        table[vpn0] = ((pa >> 12) << 10) | perm | 1;
ffffffe000201108:	f9843783          	ld	a5,-104(s0)
ffffffe00020110c:	00c7d793          	srli	a5,a5,0xc
ffffffe000201110:	00a79713          	slli	a4,a5,0xa
ffffffe000201114:	f8843783          	ld	a5,-120(s0)
ffffffe000201118:	00f76733          	or	a4,a4,a5
ffffffe00020111c:	fb843783          	ld	a5,-72(s0)
ffffffe000201120:	00379793          	slli	a5,a5,0x3
ffffffe000201124:	fd043683          	ld	a3,-48(s0)
ffffffe000201128:	00f687b3          	add	a5,a3,a5
ffffffe00020112c:	00176713          	ori	a4,a4,1
ffffffe000201130:	00e7b023          	sd	a4,0(a5)

        va += PGSIZE;
ffffffe000201134:	fa043703          	ld	a4,-96(s0)
ffffffe000201138:	000017b7          	lui	a5,0x1
ffffffe00020113c:	00f707b3          	add	a5,a4,a5
ffffffe000201140:	faf43023          	sd	a5,-96(s0)
        pa += PGSIZE;
ffffffe000201144:	f9843703          	ld	a4,-104(s0)
ffffffe000201148:	000017b7          	lui	a5,0x1
ffffffe00020114c:	00f707b3          	add	a5,a4,a5
ffffffe000201150:	f8f43c23          	sd	a5,-104(s0)
    while (va < end) 
ffffffe000201154:	fa043703          	ld	a4,-96(s0)
ffffffe000201158:	fe843783          	ld	a5,-24(s0)
ffffffe00020115c:	e6f76ae3          	bltu	a4,a5,ffffffe000200fd0 <create_mapping+0x38>
    }
ffffffe000201160:	00000013          	nop
ffffffe000201164:	00000013          	nop
ffffffe000201168:	07813083          	ld	ra,120(sp)
ffffffe00020116c:	07013403          	ld	s0,112(sp)
ffffffe000201170:	08010113          	addi	sp,sp,128
ffffffe000201174:	00008067          	ret

ffffffe000201178 <start_kernel>:
#include "printk.h"
#include "defs.h"

extern void test();

int start_kernel() {
ffffffe000201178:	ff010113          	addi	sp,sp,-16
ffffffe00020117c:	00113423          	sd	ra,8(sp)
ffffffe000201180:	00813023          	sd	s0,0(sp)
ffffffe000201184:	01010413          	addi	s0,sp,16
    printk("2024");
ffffffe000201188:	00002517          	auipc	a0,0x2
ffffffe00020118c:	01850513          	addi	a0,a0,24 # ffffffe0002031a0 <_srodata+0x1a0>
ffffffe000201190:	6dd000ef          	jal	ffffffe00020206c <printk>
    printk(" ZJU Operating System\n");
ffffffe000201194:	00002517          	auipc	a0,0x2
ffffffe000201198:	01450513          	addi	a0,a0,20 # ffffffe0002031a8 <_srodata+0x1a8>
ffffffe00020119c:	6d1000ef          	jal	ffffffe00020206c <printk>
    //uint64_t cr;
    //cr = csr_read(sstatus);
    //asm volatile("mv a6,%[cr]"::[cr]"r"(cr));
    //int cw = 30;
    //csr_write(sscratch, cw);
    test();
ffffffe0002011a0:	01c000ef          	jal	ffffffe0002011bc <test>
    return 0;
ffffffe0002011a4:	00000793          	li	a5,0
}
ffffffe0002011a8:	00078513          	mv	a0,a5
ffffffe0002011ac:	00813083          	ld	ra,8(sp)
ffffffe0002011b0:	00013403          	ld	s0,0(sp)
ffffffe0002011b4:	01010113          	addi	sp,sp,16
ffffffe0002011b8:	00008067          	ret

ffffffe0002011bc <test>:
#include "printk.h"

void test() {
ffffffe0002011bc:	ff010113          	addi	sp,sp,-16
ffffffe0002011c0:	00813423          	sd	s0,8(sp)
ffffffe0002011c4:	01010413          	addi	s0,sp,16
        //if ((++i) % 320000000 == 0) {
            //printk("kernel is running!\n");
            //i = 0;
        //}
    //}
ffffffe0002011c8:	00000013          	nop
ffffffe0002011cc:	00813403          	ld	s0,8(sp)
ffffffe0002011d0:	01010113          	addi	sp,sp,16
ffffffe0002011d4:	00008067          	ret

ffffffe0002011d8 <putc>:
// credit: 45gfg9 <45gfg9@45gfg9.net>

#include "printk.h"
#include "sbi.h"

int putc(int c) {
ffffffe0002011d8:	fe010113          	addi	sp,sp,-32
ffffffe0002011dc:	00113c23          	sd	ra,24(sp)
ffffffe0002011e0:	00813823          	sd	s0,16(sp)
ffffffe0002011e4:	02010413          	addi	s0,sp,32
ffffffe0002011e8:	00050793          	mv	a5,a0
ffffffe0002011ec:	fef42623          	sw	a5,-20(s0)
    sbi_debug_console_write_byte(c);
ffffffe0002011f0:	fec42783          	lw	a5,-20(s0)
ffffffe0002011f4:	0ff7f793          	zext.b	a5,a5
ffffffe0002011f8:	00078513          	mv	a0,a5
ffffffe0002011fc:	a41ff0ef          	jal	ffffffe000200c3c <sbi_debug_console_write_byte>
    return (char)c;
ffffffe000201200:	fec42783          	lw	a5,-20(s0)
ffffffe000201204:	0ff7f793          	zext.b	a5,a5
ffffffe000201208:	0007879b          	sext.w	a5,a5
}
ffffffe00020120c:	00078513          	mv	a0,a5
ffffffe000201210:	01813083          	ld	ra,24(sp)
ffffffe000201214:	01013403          	ld	s0,16(sp)
ffffffe000201218:	02010113          	addi	sp,sp,32
ffffffe00020121c:	00008067          	ret

ffffffe000201220 <isspace>:
    bool sign;
    int width;
    int prec;
};

int isspace(int c) {
ffffffe000201220:	fe010113          	addi	sp,sp,-32
ffffffe000201224:	00813c23          	sd	s0,24(sp)
ffffffe000201228:	02010413          	addi	s0,sp,32
ffffffe00020122c:	00050793          	mv	a5,a0
ffffffe000201230:	fef42623          	sw	a5,-20(s0)
    return c == ' ' || (c >= '\t' && c <= '\r');
ffffffe000201234:	fec42783          	lw	a5,-20(s0)
ffffffe000201238:	0007871b          	sext.w	a4,a5
ffffffe00020123c:	02000793          	li	a5,32
ffffffe000201240:	02f70263          	beq	a4,a5,ffffffe000201264 <isspace+0x44>
ffffffe000201244:	fec42783          	lw	a5,-20(s0)
ffffffe000201248:	0007871b          	sext.w	a4,a5
ffffffe00020124c:	00800793          	li	a5,8
ffffffe000201250:	00e7de63          	bge	a5,a4,ffffffe00020126c <isspace+0x4c>
ffffffe000201254:	fec42783          	lw	a5,-20(s0)
ffffffe000201258:	0007871b          	sext.w	a4,a5
ffffffe00020125c:	00d00793          	li	a5,13
ffffffe000201260:	00e7c663          	blt	a5,a4,ffffffe00020126c <isspace+0x4c>
ffffffe000201264:	00100793          	li	a5,1
ffffffe000201268:	0080006f          	j	ffffffe000201270 <isspace+0x50>
ffffffe00020126c:	00000793          	li	a5,0
}
ffffffe000201270:	00078513          	mv	a0,a5
ffffffe000201274:	01813403          	ld	s0,24(sp)
ffffffe000201278:	02010113          	addi	sp,sp,32
ffffffe00020127c:	00008067          	ret

ffffffe000201280 <strtol>:

long strtol(const char *restrict nptr, char **restrict endptr, int base) {
ffffffe000201280:	fb010113          	addi	sp,sp,-80
ffffffe000201284:	04113423          	sd	ra,72(sp)
ffffffe000201288:	04813023          	sd	s0,64(sp)
ffffffe00020128c:	05010413          	addi	s0,sp,80
ffffffe000201290:	fca43423          	sd	a0,-56(s0)
ffffffe000201294:	fcb43023          	sd	a1,-64(s0)
ffffffe000201298:	00060793          	mv	a5,a2
ffffffe00020129c:	faf42e23          	sw	a5,-68(s0)
    long ret = 0;
ffffffe0002012a0:	fe043423          	sd	zero,-24(s0)
    bool neg = false;
ffffffe0002012a4:	fe0403a3          	sb	zero,-25(s0)
    const char *p = nptr;
ffffffe0002012a8:	fc843783          	ld	a5,-56(s0)
ffffffe0002012ac:	fcf43c23          	sd	a5,-40(s0)

    while (isspace(*p)) {
ffffffe0002012b0:	0100006f          	j	ffffffe0002012c0 <strtol+0x40>
        p++;
ffffffe0002012b4:	fd843783          	ld	a5,-40(s0)
ffffffe0002012b8:	00178793          	addi	a5,a5,1 # 1001 <PGSIZE+0x1>
ffffffe0002012bc:	fcf43c23          	sd	a5,-40(s0)
    while (isspace(*p)) {
ffffffe0002012c0:	fd843783          	ld	a5,-40(s0)
ffffffe0002012c4:	0007c783          	lbu	a5,0(a5)
ffffffe0002012c8:	0007879b          	sext.w	a5,a5
ffffffe0002012cc:	00078513          	mv	a0,a5
ffffffe0002012d0:	f51ff0ef          	jal	ffffffe000201220 <isspace>
ffffffe0002012d4:	00050793          	mv	a5,a0
ffffffe0002012d8:	fc079ee3          	bnez	a5,ffffffe0002012b4 <strtol+0x34>
    }

    if (*p == '-') {
ffffffe0002012dc:	fd843783          	ld	a5,-40(s0)
ffffffe0002012e0:	0007c783          	lbu	a5,0(a5)
ffffffe0002012e4:	00078713          	mv	a4,a5
ffffffe0002012e8:	02d00793          	li	a5,45
ffffffe0002012ec:	00f71e63          	bne	a4,a5,ffffffe000201308 <strtol+0x88>
        neg = true;
ffffffe0002012f0:	00100793          	li	a5,1
ffffffe0002012f4:	fef403a3          	sb	a5,-25(s0)
        p++;
ffffffe0002012f8:	fd843783          	ld	a5,-40(s0)
ffffffe0002012fc:	00178793          	addi	a5,a5,1
ffffffe000201300:	fcf43c23          	sd	a5,-40(s0)
ffffffe000201304:	0240006f          	j	ffffffe000201328 <strtol+0xa8>
    } else if (*p == '+') {
ffffffe000201308:	fd843783          	ld	a5,-40(s0)
ffffffe00020130c:	0007c783          	lbu	a5,0(a5)
ffffffe000201310:	00078713          	mv	a4,a5
ffffffe000201314:	02b00793          	li	a5,43
ffffffe000201318:	00f71863          	bne	a4,a5,ffffffe000201328 <strtol+0xa8>
        p++;
ffffffe00020131c:	fd843783          	ld	a5,-40(s0)
ffffffe000201320:	00178793          	addi	a5,a5,1
ffffffe000201324:	fcf43c23          	sd	a5,-40(s0)
    }

    if (base == 0) {
ffffffe000201328:	fbc42783          	lw	a5,-68(s0)
ffffffe00020132c:	0007879b          	sext.w	a5,a5
ffffffe000201330:	06079c63          	bnez	a5,ffffffe0002013a8 <strtol+0x128>
        if (*p == '0') {
ffffffe000201334:	fd843783          	ld	a5,-40(s0)
ffffffe000201338:	0007c783          	lbu	a5,0(a5)
ffffffe00020133c:	00078713          	mv	a4,a5
ffffffe000201340:	03000793          	li	a5,48
ffffffe000201344:	04f71e63          	bne	a4,a5,ffffffe0002013a0 <strtol+0x120>
            p++;
ffffffe000201348:	fd843783          	ld	a5,-40(s0)
ffffffe00020134c:	00178793          	addi	a5,a5,1
ffffffe000201350:	fcf43c23          	sd	a5,-40(s0)
            if (*p == 'x' || *p == 'X') {
ffffffe000201354:	fd843783          	ld	a5,-40(s0)
ffffffe000201358:	0007c783          	lbu	a5,0(a5)
ffffffe00020135c:	00078713          	mv	a4,a5
ffffffe000201360:	07800793          	li	a5,120
ffffffe000201364:	00f70c63          	beq	a4,a5,ffffffe00020137c <strtol+0xfc>
ffffffe000201368:	fd843783          	ld	a5,-40(s0)
ffffffe00020136c:	0007c783          	lbu	a5,0(a5)
ffffffe000201370:	00078713          	mv	a4,a5
ffffffe000201374:	05800793          	li	a5,88
ffffffe000201378:	00f71e63          	bne	a4,a5,ffffffe000201394 <strtol+0x114>
                base = 16;
ffffffe00020137c:	01000793          	li	a5,16
ffffffe000201380:	faf42e23          	sw	a5,-68(s0)
                p++;
ffffffe000201384:	fd843783          	ld	a5,-40(s0)
ffffffe000201388:	00178793          	addi	a5,a5,1
ffffffe00020138c:	fcf43c23          	sd	a5,-40(s0)
ffffffe000201390:	0180006f          	j	ffffffe0002013a8 <strtol+0x128>
            } else {
                base = 8;
ffffffe000201394:	00800793          	li	a5,8
ffffffe000201398:	faf42e23          	sw	a5,-68(s0)
ffffffe00020139c:	00c0006f          	j	ffffffe0002013a8 <strtol+0x128>
            }
        } else {
            base = 10;
ffffffe0002013a0:	00a00793          	li	a5,10
ffffffe0002013a4:	faf42e23          	sw	a5,-68(s0)
        }
    }

    while (1) {
        int digit;
        if (*p >= '0' && *p <= '9') {
ffffffe0002013a8:	fd843783          	ld	a5,-40(s0)
ffffffe0002013ac:	0007c783          	lbu	a5,0(a5)
ffffffe0002013b0:	00078713          	mv	a4,a5
ffffffe0002013b4:	02f00793          	li	a5,47
ffffffe0002013b8:	02e7f863          	bgeu	a5,a4,ffffffe0002013e8 <strtol+0x168>
ffffffe0002013bc:	fd843783          	ld	a5,-40(s0)
ffffffe0002013c0:	0007c783          	lbu	a5,0(a5)
ffffffe0002013c4:	00078713          	mv	a4,a5
ffffffe0002013c8:	03900793          	li	a5,57
ffffffe0002013cc:	00e7ee63          	bltu	a5,a4,ffffffe0002013e8 <strtol+0x168>
            digit = *p - '0';
ffffffe0002013d0:	fd843783          	ld	a5,-40(s0)
ffffffe0002013d4:	0007c783          	lbu	a5,0(a5)
ffffffe0002013d8:	0007879b          	sext.w	a5,a5
ffffffe0002013dc:	fd07879b          	addiw	a5,a5,-48
ffffffe0002013e0:	fcf42a23          	sw	a5,-44(s0)
ffffffe0002013e4:	0800006f          	j	ffffffe000201464 <strtol+0x1e4>
        } else if (*p >= 'a' && *p <= 'z') {
ffffffe0002013e8:	fd843783          	ld	a5,-40(s0)
ffffffe0002013ec:	0007c783          	lbu	a5,0(a5)
ffffffe0002013f0:	00078713          	mv	a4,a5
ffffffe0002013f4:	06000793          	li	a5,96
ffffffe0002013f8:	02e7f863          	bgeu	a5,a4,ffffffe000201428 <strtol+0x1a8>
ffffffe0002013fc:	fd843783          	ld	a5,-40(s0)
ffffffe000201400:	0007c783          	lbu	a5,0(a5)
ffffffe000201404:	00078713          	mv	a4,a5
ffffffe000201408:	07a00793          	li	a5,122
ffffffe00020140c:	00e7ee63          	bltu	a5,a4,ffffffe000201428 <strtol+0x1a8>
            digit = *p - ('a' - 10);
ffffffe000201410:	fd843783          	ld	a5,-40(s0)
ffffffe000201414:	0007c783          	lbu	a5,0(a5)
ffffffe000201418:	0007879b          	sext.w	a5,a5
ffffffe00020141c:	fa97879b          	addiw	a5,a5,-87
ffffffe000201420:	fcf42a23          	sw	a5,-44(s0)
ffffffe000201424:	0400006f          	j	ffffffe000201464 <strtol+0x1e4>
        } else if (*p >= 'A' && *p <= 'Z') {
ffffffe000201428:	fd843783          	ld	a5,-40(s0)
ffffffe00020142c:	0007c783          	lbu	a5,0(a5)
ffffffe000201430:	00078713          	mv	a4,a5
ffffffe000201434:	04000793          	li	a5,64
ffffffe000201438:	06e7f863          	bgeu	a5,a4,ffffffe0002014a8 <strtol+0x228>
ffffffe00020143c:	fd843783          	ld	a5,-40(s0)
ffffffe000201440:	0007c783          	lbu	a5,0(a5)
ffffffe000201444:	00078713          	mv	a4,a5
ffffffe000201448:	05a00793          	li	a5,90
ffffffe00020144c:	04e7ee63          	bltu	a5,a4,ffffffe0002014a8 <strtol+0x228>
            digit = *p - ('A' - 10);
ffffffe000201450:	fd843783          	ld	a5,-40(s0)
ffffffe000201454:	0007c783          	lbu	a5,0(a5)
ffffffe000201458:	0007879b          	sext.w	a5,a5
ffffffe00020145c:	fc97879b          	addiw	a5,a5,-55
ffffffe000201460:	fcf42a23          	sw	a5,-44(s0)
        } else {
            break;
        }

        if (digit >= base) {
ffffffe000201464:	fd442783          	lw	a5,-44(s0)
ffffffe000201468:	00078713          	mv	a4,a5
ffffffe00020146c:	fbc42783          	lw	a5,-68(s0)
ffffffe000201470:	0007071b          	sext.w	a4,a4
ffffffe000201474:	0007879b          	sext.w	a5,a5
ffffffe000201478:	02f75663          	bge	a4,a5,ffffffe0002014a4 <strtol+0x224>
            break;
        }

        ret = ret * base + digit;
ffffffe00020147c:	fbc42703          	lw	a4,-68(s0)
ffffffe000201480:	fe843783          	ld	a5,-24(s0)
ffffffe000201484:	02f70733          	mul	a4,a4,a5
ffffffe000201488:	fd442783          	lw	a5,-44(s0)
ffffffe00020148c:	00f707b3          	add	a5,a4,a5
ffffffe000201490:	fef43423          	sd	a5,-24(s0)
        p++;
ffffffe000201494:	fd843783          	ld	a5,-40(s0)
ffffffe000201498:	00178793          	addi	a5,a5,1
ffffffe00020149c:	fcf43c23          	sd	a5,-40(s0)
    while (1) {
ffffffe0002014a0:	f09ff06f          	j	ffffffe0002013a8 <strtol+0x128>
            break;
ffffffe0002014a4:	00000013          	nop
    }

    if (endptr) {
ffffffe0002014a8:	fc043783          	ld	a5,-64(s0)
ffffffe0002014ac:	00078863          	beqz	a5,ffffffe0002014bc <strtol+0x23c>
        *endptr = (char *)p;
ffffffe0002014b0:	fc043783          	ld	a5,-64(s0)
ffffffe0002014b4:	fd843703          	ld	a4,-40(s0)
ffffffe0002014b8:	00e7b023          	sd	a4,0(a5)
    }

    return neg ? -ret : ret;
ffffffe0002014bc:	fe744783          	lbu	a5,-25(s0)
ffffffe0002014c0:	0ff7f793          	zext.b	a5,a5
ffffffe0002014c4:	00078863          	beqz	a5,ffffffe0002014d4 <strtol+0x254>
ffffffe0002014c8:	fe843783          	ld	a5,-24(s0)
ffffffe0002014cc:	40f007b3          	neg	a5,a5
ffffffe0002014d0:	0080006f          	j	ffffffe0002014d8 <strtol+0x258>
ffffffe0002014d4:	fe843783          	ld	a5,-24(s0)
}
ffffffe0002014d8:	00078513          	mv	a0,a5
ffffffe0002014dc:	04813083          	ld	ra,72(sp)
ffffffe0002014e0:	04013403          	ld	s0,64(sp)
ffffffe0002014e4:	05010113          	addi	sp,sp,80
ffffffe0002014e8:	00008067          	ret

ffffffe0002014ec <puts_wo_nl>:

// puts without newline
static int puts_wo_nl(int (*putch)(int), const char *s) {
ffffffe0002014ec:	fd010113          	addi	sp,sp,-48
ffffffe0002014f0:	02113423          	sd	ra,40(sp)
ffffffe0002014f4:	02813023          	sd	s0,32(sp)
ffffffe0002014f8:	03010413          	addi	s0,sp,48
ffffffe0002014fc:	fca43c23          	sd	a0,-40(s0)
ffffffe000201500:	fcb43823          	sd	a1,-48(s0)
    if (!s) {
ffffffe000201504:	fd043783          	ld	a5,-48(s0)
ffffffe000201508:	00079863          	bnez	a5,ffffffe000201518 <puts_wo_nl+0x2c>
        s = "(null)";
ffffffe00020150c:	00002797          	auipc	a5,0x2
ffffffe000201510:	cb478793          	addi	a5,a5,-844 # ffffffe0002031c0 <_srodata+0x1c0>
ffffffe000201514:	fcf43823          	sd	a5,-48(s0)
    }
    const char *p = s;
ffffffe000201518:	fd043783          	ld	a5,-48(s0)
ffffffe00020151c:	fef43423          	sd	a5,-24(s0)
    while (*p) {
ffffffe000201520:	0240006f          	j	ffffffe000201544 <puts_wo_nl+0x58>
        putch(*p++);
ffffffe000201524:	fe843783          	ld	a5,-24(s0)
ffffffe000201528:	00178713          	addi	a4,a5,1
ffffffe00020152c:	fee43423          	sd	a4,-24(s0)
ffffffe000201530:	0007c783          	lbu	a5,0(a5)
ffffffe000201534:	0007871b          	sext.w	a4,a5
ffffffe000201538:	fd843783          	ld	a5,-40(s0)
ffffffe00020153c:	00070513          	mv	a0,a4
ffffffe000201540:	000780e7          	jalr	a5
    while (*p) {
ffffffe000201544:	fe843783          	ld	a5,-24(s0)
ffffffe000201548:	0007c783          	lbu	a5,0(a5)
ffffffe00020154c:	fc079ce3          	bnez	a5,ffffffe000201524 <puts_wo_nl+0x38>
    }
    return p - s;
ffffffe000201550:	fe843703          	ld	a4,-24(s0)
ffffffe000201554:	fd043783          	ld	a5,-48(s0)
ffffffe000201558:	40f707b3          	sub	a5,a4,a5
ffffffe00020155c:	0007879b          	sext.w	a5,a5
}
ffffffe000201560:	00078513          	mv	a0,a5
ffffffe000201564:	02813083          	ld	ra,40(sp)
ffffffe000201568:	02013403          	ld	s0,32(sp)
ffffffe00020156c:	03010113          	addi	sp,sp,48
ffffffe000201570:	00008067          	ret

ffffffe000201574 <print_dec_int>:

static int print_dec_int(int (*putch)(int), unsigned long num, bool is_signed, struct fmt_flags *flags) {
ffffffe000201574:	f9010113          	addi	sp,sp,-112
ffffffe000201578:	06113423          	sd	ra,104(sp)
ffffffe00020157c:	06813023          	sd	s0,96(sp)
ffffffe000201580:	07010413          	addi	s0,sp,112
ffffffe000201584:	faa43423          	sd	a0,-88(s0)
ffffffe000201588:	fab43023          	sd	a1,-96(s0)
ffffffe00020158c:	00060793          	mv	a5,a2
ffffffe000201590:	f8d43823          	sd	a3,-112(s0)
ffffffe000201594:	f8f40fa3          	sb	a5,-97(s0)
    if (is_signed && num == 0x8000000000000000UL) {
ffffffe000201598:	f9f44783          	lbu	a5,-97(s0)
ffffffe00020159c:	0ff7f793          	zext.b	a5,a5
ffffffe0002015a0:	02078663          	beqz	a5,ffffffe0002015cc <print_dec_int+0x58>
ffffffe0002015a4:	fa043703          	ld	a4,-96(s0)
ffffffe0002015a8:	fff00793          	li	a5,-1
ffffffe0002015ac:	03f79793          	slli	a5,a5,0x3f
ffffffe0002015b0:	00f71e63          	bne	a4,a5,ffffffe0002015cc <print_dec_int+0x58>
        // special case for 0x8000000000000000
        return puts_wo_nl(putch, "-9223372036854775808");
ffffffe0002015b4:	00002597          	auipc	a1,0x2
ffffffe0002015b8:	c1458593          	addi	a1,a1,-1004 # ffffffe0002031c8 <_srodata+0x1c8>
ffffffe0002015bc:	fa843503          	ld	a0,-88(s0)
ffffffe0002015c0:	f2dff0ef          	jal	ffffffe0002014ec <puts_wo_nl>
ffffffe0002015c4:	00050793          	mv	a5,a0
ffffffe0002015c8:	2a00006f          	j	ffffffe000201868 <print_dec_int+0x2f4>
    }

    if (flags->prec == 0 && num == 0) {
ffffffe0002015cc:	f9043783          	ld	a5,-112(s0)
ffffffe0002015d0:	00c7a783          	lw	a5,12(a5)
ffffffe0002015d4:	00079a63          	bnez	a5,ffffffe0002015e8 <print_dec_int+0x74>
ffffffe0002015d8:	fa043783          	ld	a5,-96(s0)
ffffffe0002015dc:	00079663          	bnez	a5,ffffffe0002015e8 <print_dec_int+0x74>
        return 0;
ffffffe0002015e0:	00000793          	li	a5,0
ffffffe0002015e4:	2840006f          	j	ffffffe000201868 <print_dec_int+0x2f4>
    }

    bool neg = false;
ffffffe0002015e8:	fe0407a3          	sb	zero,-17(s0)

    if (is_signed && (long)num < 0) {
ffffffe0002015ec:	f9f44783          	lbu	a5,-97(s0)
ffffffe0002015f0:	0ff7f793          	zext.b	a5,a5
ffffffe0002015f4:	02078063          	beqz	a5,ffffffe000201614 <print_dec_int+0xa0>
ffffffe0002015f8:	fa043783          	ld	a5,-96(s0)
ffffffe0002015fc:	0007dc63          	bgez	a5,ffffffe000201614 <print_dec_int+0xa0>
        neg = true;
ffffffe000201600:	00100793          	li	a5,1
ffffffe000201604:	fef407a3          	sb	a5,-17(s0)
        num = -num;
ffffffe000201608:	fa043783          	ld	a5,-96(s0)
ffffffe00020160c:	40f007b3          	neg	a5,a5
ffffffe000201610:	faf43023          	sd	a5,-96(s0)
    }

    char buf[20];
    int decdigits = 0;
ffffffe000201614:	fe042423          	sw	zero,-24(s0)

    bool has_sign_char = is_signed && (neg || flags->sign || flags->spaceflag);
ffffffe000201618:	f9f44783          	lbu	a5,-97(s0)
ffffffe00020161c:	0ff7f793          	zext.b	a5,a5
ffffffe000201620:	02078863          	beqz	a5,ffffffe000201650 <print_dec_int+0xdc>
ffffffe000201624:	fef44783          	lbu	a5,-17(s0)
ffffffe000201628:	0ff7f793          	zext.b	a5,a5
ffffffe00020162c:	00079e63          	bnez	a5,ffffffe000201648 <print_dec_int+0xd4>
ffffffe000201630:	f9043783          	ld	a5,-112(s0)
ffffffe000201634:	0057c783          	lbu	a5,5(a5)
ffffffe000201638:	00079863          	bnez	a5,ffffffe000201648 <print_dec_int+0xd4>
ffffffe00020163c:	f9043783          	ld	a5,-112(s0)
ffffffe000201640:	0047c783          	lbu	a5,4(a5)
ffffffe000201644:	00078663          	beqz	a5,ffffffe000201650 <print_dec_int+0xdc>
ffffffe000201648:	00100793          	li	a5,1
ffffffe00020164c:	0080006f          	j	ffffffe000201654 <print_dec_int+0xe0>
ffffffe000201650:	00000793          	li	a5,0
ffffffe000201654:	fcf40ba3          	sb	a5,-41(s0)
ffffffe000201658:	fd744783          	lbu	a5,-41(s0)
ffffffe00020165c:	0017f793          	andi	a5,a5,1
ffffffe000201660:	fcf40ba3          	sb	a5,-41(s0)

    do {
        buf[decdigits++] = num % 10 + '0';
ffffffe000201664:	fa043703          	ld	a4,-96(s0)
ffffffe000201668:	00a00793          	li	a5,10
ffffffe00020166c:	02f777b3          	remu	a5,a4,a5
ffffffe000201670:	0ff7f713          	zext.b	a4,a5
ffffffe000201674:	fe842783          	lw	a5,-24(s0)
ffffffe000201678:	0017869b          	addiw	a3,a5,1
ffffffe00020167c:	fed42423          	sw	a3,-24(s0)
ffffffe000201680:	0307071b          	addiw	a4,a4,48
ffffffe000201684:	0ff77713          	zext.b	a4,a4
ffffffe000201688:	ff078793          	addi	a5,a5,-16
ffffffe00020168c:	008787b3          	add	a5,a5,s0
ffffffe000201690:	fce78423          	sb	a4,-56(a5)
        num /= 10;
ffffffe000201694:	fa043703          	ld	a4,-96(s0)
ffffffe000201698:	00a00793          	li	a5,10
ffffffe00020169c:	02f757b3          	divu	a5,a4,a5
ffffffe0002016a0:	faf43023          	sd	a5,-96(s0)
    } while (num);
ffffffe0002016a4:	fa043783          	ld	a5,-96(s0)
ffffffe0002016a8:	fa079ee3          	bnez	a5,ffffffe000201664 <print_dec_int+0xf0>

    if (flags->prec == -1 && flags->zeroflag) {
ffffffe0002016ac:	f9043783          	ld	a5,-112(s0)
ffffffe0002016b0:	00c7a783          	lw	a5,12(a5)
ffffffe0002016b4:	00078713          	mv	a4,a5
ffffffe0002016b8:	fff00793          	li	a5,-1
ffffffe0002016bc:	02f71063          	bne	a4,a5,ffffffe0002016dc <print_dec_int+0x168>
ffffffe0002016c0:	f9043783          	ld	a5,-112(s0)
ffffffe0002016c4:	0037c783          	lbu	a5,3(a5)
ffffffe0002016c8:	00078a63          	beqz	a5,ffffffe0002016dc <print_dec_int+0x168>
        flags->prec = flags->width;
ffffffe0002016cc:	f9043783          	ld	a5,-112(s0)
ffffffe0002016d0:	0087a703          	lw	a4,8(a5)
ffffffe0002016d4:	f9043783          	ld	a5,-112(s0)
ffffffe0002016d8:	00e7a623          	sw	a4,12(a5)
    }

    int written = 0;
ffffffe0002016dc:	fe042223          	sw	zero,-28(s0)

    for (int i = flags->width - __MAX(decdigits, flags->prec) - has_sign_char; i > 0; i--) {
ffffffe0002016e0:	f9043783          	ld	a5,-112(s0)
ffffffe0002016e4:	0087a703          	lw	a4,8(a5)
ffffffe0002016e8:	fe842783          	lw	a5,-24(s0)
ffffffe0002016ec:	fcf42823          	sw	a5,-48(s0)
ffffffe0002016f0:	f9043783          	ld	a5,-112(s0)
ffffffe0002016f4:	00c7a783          	lw	a5,12(a5)
ffffffe0002016f8:	fcf42623          	sw	a5,-52(s0)
ffffffe0002016fc:	fd042783          	lw	a5,-48(s0)
ffffffe000201700:	00078593          	mv	a1,a5
ffffffe000201704:	fcc42783          	lw	a5,-52(s0)
ffffffe000201708:	00078613          	mv	a2,a5
ffffffe00020170c:	0006069b          	sext.w	a3,a2
ffffffe000201710:	0005879b          	sext.w	a5,a1
ffffffe000201714:	00f6d463          	bge	a3,a5,ffffffe00020171c <print_dec_int+0x1a8>
ffffffe000201718:	00058613          	mv	a2,a1
ffffffe00020171c:	0006079b          	sext.w	a5,a2
ffffffe000201720:	40f707bb          	subw	a5,a4,a5
ffffffe000201724:	0007871b          	sext.w	a4,a5
ffffffe000201728:	fd744783          	lbu	a5,-41(s0)
ffffffe00020172c:	0007879b          	sext.w	a5,a5
ffffffe000201730:	40f707bb          	subw	a5,a4,a5
ffffffe000201734:	fef42023          	sw	a5,-32(s0)
ffffffe000201738:	0280006f          	j	ffffffe000201760 <print_dec_int+0x1ec>
        putch(' ');
ffffffe00020173c:	fa843783          	ld	a5,-88(s0)
ffffffe000201740:	02000513          	li	a0,32
ffffffe000201744:	000780e7          	jalr	a5
        ++written;
ffffffe000201748:	fe442783          	lw	a5,-28(s0)
ffffffe00020174c:	0017879b          	addiw	a5,a5,1
ffffffe000201750:	fef42223          	sw	a5,-28(s0)
    for (int i = flags->width - __MAX(decdigits, flags->prec) - has_sign_char; i > 0; i--) {
ffffffe000201754:	fe042783          	lw	a5,-32(s0)
ffffffe000201758:	fff7879b          	addiw	a5,a5,-1
ffffffe00020175c:	fef42023          	sw	a5,-32(s0)
ffffffe000201760:	fe042783          	lw	a5,-32(s0)
ffffffe000201764:	0007879b          	sext.w	a5,a5
ffffffe000201768:	fcf04ae3          	bgtz	a5,ffffffe00020173c <print_dec_int+0x1c8>
    }

    if (has_sign_char) {
ffffffe00020176c:	fd744783          	lbu	a5,-41(s0)
ffffffe000201770:	0ff7f793          	zext.b	a5,a5
ffffffe000201774:	04078463          	beqz	a5,ffffffe0002017bc <print_dec_int+0x248>
        putch(neg ? '-' : flags->sign ? '+' : ' ');
ffffffe000201778:	fef44783          	lbu	a5,-17(s0)
ffffffe00020177c:	0ff7f793          	zext.b	a5,a5
ffffffe000201780:	00078663          	beqz	a5,ffffffe00020178c <print_dec_int+0x218>
ffffffe000201784:	02d00793          	li	a5,45
ffffffe000201788:	01c0006f          	j	ffffffe0002017a4 <print_dec_int+0x230>
ffffffe00020178c:	f9043783          	ld	a5,-112(s0)
ffffffe000201790:	0057c783          	lbu	a5,5(a5)
ffffffe000201794:	00078663          	beqz	a5,ffffffe0002017a0 <print_dec_int+0x22c>
ffffffe000201798:	02b00793          	li	a5,43
ffffffe00020179c:	0080006f          	j	ffffffe0002017a4 <print_dec_int+0x230>
ffffffe0002017a0:	02000793          	li	a5,32
ffffffe0002017a4:	fa843703          	ld	a4,-88(s0)
ffffffe0002017a8:	00078513          	mv	a0,a5
ffffffe0002017ac:	000700e7          	jalr	a4
        ++written;
ffffffe0002017b0:	fe442783          	lw	a5,-28(s0)
ffffffe0002017b4:	0017879b          	addiw	a5,a5,1
ffffffe0002017b8:	fef42223          	sw	a5,-28(s0)
    }

    for (int i = decdigits; i < flags->prec - has_sign_char; i++) {
ffffffe0002017bc:	fe842783          	lw	a5,-24(s0)
ffffffe0002017c0:	fcf42e23          	sw	a5,-36(s0)
ffffffe0002017c4:	0280006f          	j	ffffffe0002017ec <print_dec_int+0x278>
        putch('0');
ffffffe0002017c8:	fa843783          	ld	a5,-88(s0)
ffffffe0002017cc:	03000513          	li	a0,48
ffffffe0002017d0:	000780e7          	jalr	a5
        ++written;
ffffffe0002017d4:	fe442783          	lw	a5,-28(s0)
ffffffe0002017d8:	0017879b          	addiw	a5,a5,1
ffffffe0002017dc:	fef42223          	sw	a5,-28(s0)
    for (int i = decdigits; i < flags->prec - has_sign_char; i++) {
ffffffe0002017e0:	fdc42783          	lw	a5,-36(s0)
ffffffe0002017e4:	0017879b          	addiw	a5,a5,1
ffffffe0002017e8:	fcf42e23          	sw	a5,-36(s0)
ffffffe0002017ec:	f9043783          	ld	a5,-112(s0)
ffffffe0002017f0:	00c7a703          	lw	a4,12(a5)
ffffffe0002017f4:	fd744783          	lbu	a5,-41(s0)
ffffffe0002017f8:	0007879b          	sext.w	a5,a5
ffffffe0002017fc:	40f707bb          	subw	a5,a4,a5
ffffffe000201800:	0007871b          	sext.w	a4,a5
ffffffe000201804:	fdc42783          	lw	a5,-36(s0)
ffffffe000201808:	0007879b          	sext.w	a5,a5
ffffffe00020180c:	fae7cee3          	blt	a5,a4,ffffffe0002017c8 <print_dec_int+0x254>
    }

    for (int i = decdigits - 1; i >= 0; i--) {
ffffffe000201810:	fe842783          	lw	a5,-24(s0)
ffffffe000201814:	fff7879b          	addiw	a5,a5,-1
ffffffe000201818:	fcf42c23          	sw	a5,-40(s0)
ffffffe00020181c:	03c0006f          	j	ffffffe000201858 <print_dec_int+0x2e4>
        putch(buf[i]);
ffffffe000201820:	fd842783          	lw	a5,-40(s0)
ffffffe000201824:	ff078793          	addi	a5,a5,-16
ffffffe000201828:	008787b3          	add	a5,a5,s0
ffffffe00020182c:	fc87c783          	lbu	a5,-56(a5)
ffffffe000201830:	0007871b          	sext.w	a4,a5
ffffffe000201834:	fa843783          	ld	a5,-88(s0)
ffffffe000201838:	00070513          	mv	a0,a4
ffffffe00020183c:	000780e7          	jalr	a5
        ++written;
ffffffe000201840:	fe442783          	lw	a5,-28(s0)
ffffffe000201844:	0017879b          	addiw	a5,a5,1
ffffffe000201848:	fef42223          	sw	a5,-28(s0)
    for (int i = decdigits - 1; i >= 0; i--) {
ffffffe00020184c:	fd842783          	lw	a5,-40(s0)
ffffffe000201850:	fff7879b          	addiw	a5,a5,-1
ffffffe000201854:	fcf42c23          	sw	a5,-40(s0)
ffffffe000201858:	fd842783          	lw	a5,-40(s0)
ffffffe00020185c:	0007879b          	sext.w	a5,a5
ffffffe000201860:	fc07d0e3          	bgez	a5,ffffffe000201820 <print_dec_int+0x2ac>
    }

    return written;
ffffffe000201864:	fe442783          	lw	a5,-28(s0)
}
ffffffe000201868:	00078513          	mv	a0,a5
ffffffe00020186c:	06813083          	ld	ra,104(sp)
ffffffe000201870:	06013403          	ld	s0,96(sp)
ffffffe000201874:	07010113          	addi	sp,sp,112
ffffffe000201878:	00008067          	ret

ffffffe00020187c <vprintfmt>:

int vprintfmt(int (*putch)(int), const char *fmt, va_list vl) {
ffffffe00020187c:	f4010113          	addi	sp,sp,-192
ffffffe000201880:	0a113c23          	sd	ra,184(sp)
ffffffe000201884:	0a813823          	sd	s0,176(sp)
ffffffe000201888:	0c010413          	addi	s0,sp,192
ffffffe00020188c:	f4a43c23          	sd	a0,-168(s0)
ffffffe000201890:	f4b43823          	sd	a1,-176(s0)
ffffffe000201894:	f4c43423          	sd	a2,-184(s0)
    static const char lowerxdigits[] = "0123456789abcdef";
    static const char upperxdigits[] = "0123456789ABCDEF";

    struct fmt_flags flags = {};
ffffffe000201898:	f8043023          	sd	zero,-128(s0)
ffffffe00020189c:	f8043423          	sd	zero,-120(s0)

    int written = 0;
ffffffe0002018a0:	fe042623          	sw	zero,-20(s0)

    for (; *fmt; fmt++) {
ffffffe0002018a4:	7a40006f          	j	ffffffe000202048 <vprintfmt+0x7cc>
        if (flags.in_format) {
ffffffe0002018a8:	f8044783          	lbu	a5,-128(s0)
ffffffe0002018ac:	72078e63          	beqz	a5,ffffffe000201fe8 <vprintfmt+0x76c>
            if (*fmt == '#') {
ffffffe0002018b0:	f5043783          	ld	a5,-176(s0)
ffffffe0002018b4:	0007c783          	lbu	a5,0(a5)
ffffffe0002018b8:	00078713          	mv	a4,a5
ffffffe0002018bc:	02300793          	li	a5,35
ffffffe0002018c0:	00f71863          	bne	a4,a5,ffffffe0002018d0 <vprintfmt+0x54>
                flags.sharpflag = true;
ffffffe0002018c4:	00100793          	li	a5,1
ffffffe0002018c8:	f8f40123          	sb	a5,-126(s0)
ffffffe0002018cc:	7700006f          	j	ffffffe00020203c <vprintfmt+0x7c0>
            } else if (*fmt == '0') {
ffffffe0002018d0:	f5043783          	ld	a5,-176(s0)
ffffffe0002018d4:	0007c783          	lbu	a5,0(a5)
ffffffe0002018d8:	00078713          	mv	a4,a5
ffffffe0002018dc:	03000793          	li	a5,48
ffffffe0002018e0:	00f71863          	bne	a4,a5,ffffffe0002018f0 <vprintfmt+0x74>
                flags.zeroflag = true;
ffffffe0002018e4:	00100793          	li	a5,1
ffffffe0002018e8:	f8f401a3          	sb	a5,-125(s0)
ffffffe0002018ec:	7500006f          	j	ffffffe00020203c <vprintfmt+0x7c0>
            } else if (*fmt == 'l' || *fmt == 'z' || *fmt == 't' || *fmt == 'j') {
ffffffe0002018f0:	f5043783          	ld	a5,-176(s0)
ffffffe0002018f4:	0007c783          	lbu	a5,0(a5)
ffffffe0002018f8:	00078713          	mv	a4,a5
ffffffe0002018fc:	06c00793          	li	a5,108
ffffffe000201900:	04f70063          	beq	a4,a5,ffffffe000201940 <vprintfmt+0xc4>
ffffffe000201904:	f5043783          	ld	a5,-176(s0)
ffffffe000201908:	0007c783          	lbu	a5,0(a5)
ffffffe00020190c:	00078713          	mv	a4,a5
ffffffe000201910:	07a00793          	li	a5,122
ffffffe000201914:	02f70663          	beq	a4,a5,ffffffe000201940 <vprintfmt+0xc4>
ffffffe000201918:	f5043783          	ld	a5,-176(s0)
ffffffe00020191c:	0007c783          	lbu	a5,0(a5)
ffffffe000201920:	00078713          	mv	a4,a5
ffffffe000201924:	07400793          	li	a5,116
ffffffe000201928:	00f70c63          	beq	a4,a5,ffffffe000201940 <vprintfmt+0xc4>
ffffffe00020192c:	f5043783          	ld	a5,-176(s0)
ffffffe000201930:	0007c783          	lbu	a5,0(a5)
ffffffe000201934:	00078713          	mv	a4,a5
ffffffe000201938:	06a00793          	li	a5,106
ffffffe00020193c:	00f71863          	bne	a4,a5,ffffffe00020194c <vprintfmt+0xd0>
                // l: long, z: size_t, t: ptrdiff_t, j: intmax_t
                flags.longflag = true;
ffffffe000201940:	00100793          	li	a5,1
ffffffe000201944:	f8f400a3          	sb	a5,-127(s0)
ffffffe000201948:	6f40006f          	j	ffffffe00020203c <vprintfmt+0x7c0>
            } else if (*fmt == '+') {
ffffffe00020194c:	f5043783          	ld	a5,-176(s0)
ffffffe000201950:	0007c783          	lbu	a5,0(a5)
ffffffe000201954:	00078713          	mv	a4,a5
ffffffe000201958:	02b00793          	li	a5,43
ffffffe00020195c:	00f71863          	bne	a4,a5,ffffffe00020196c <vprintfmt+0xf0>
                flags.sign = true;
ffffffe000201960:	00100793          	li	a5,1
ffffffe000201964:	f8f402a3          	sb	a5,-123(s0)
ffffffe000201968:	6d40006f          	j	ffffffe00020203c <vprintfmt+0x7c0>
            } else if (*fmt == ' ') {
ffffffe00020196c:	f5043783          	ld	a5,-176(s0)
ffffffe000201970:	0007c783          	lbu	a5,0(a5)
ffffffe000201974:	00078713          	mv	a4,a5
ffffffe000201978:	02000793          	li	a5,32
ffffffe00020197c:	00f71863          	bne	a4,a5,ffffffe00020198c <vprintfmt+0x110>
                flags.spaceflag = true;
ffffffe000201980:	00100793          	li	a5,1
ffffffe000201984:	f8f40223          	sb	a5,-124(s0)
ffffffe000201988:	6b40006f          	j	ffffffe00020203c <vprintfmt+0x7c0>
            } else if (*fmt == '*') {
ffffffe00020198c:	f5043783          	ld	a5,-176(s0)
ffffffe000201990:	0007c783          	lbu	a5,0(a5)
ffffffe000201994:	00078713          	mv	a4,a5
ffffffe000201998:	02a00793          	li	a5,42
ffffffe00020199c:	00f71e63          	bne	a4,a5,ffffffe0002019b8 <vprintfmt+0x13c>
                flags.width = va_arg(vl, int);
ffffffe0002019a0:	f4843783          	ld	a5,-184(s0)
ffffffe0002019a4:	00878713          	addi	a4,a5,8
ffffffe0002019a8:	f4e43423          	sd	a4,-184(s0)
ffffffe0002019ac:	0007a783          	lw	a5,0(a5)
ffffffe0002019b0:	f8f42423          	sw	a5,-120(s0)
ffffffe0002019b4:	6880006f          	j	ffffffe00020203c <vprintfmt+0x7c0>
            } else if (*fmt >= '1' && *fmt <= '9') {
ffffffe0002019b8:	f5043783          	ld	a5,-176(s0)
ffffffe0002019bc:	0007c783          	lbu	a5,0(a5)
ffffffe0002019c0:	00078713          	mv	a4,a5
ffffffe0002019c4:	03000793          	li	a5,48
ffffffe0002019c8:	04e7f663          	bgeu	a5,a4,ffffffe000201a14 <vprintfmt+0x198>
ffffffe0002019cc:	f5043783          	ld	a5,-176(s0)
ffffffe0002019d0:	0007c783          	lbu	a5,0(a5)
ffffffe0002019d4:	00078713          	mv	a4,a5
ffffffe0002019d8:	03900793          	li	a5,57
ffffffe0002019dc:	02e7ec63          	bltu	a5,a4,ffffffe000201a14 <vprintfmt+0x198>
                flags.width = strtol(fmt, (char **)&fmt, 10);
ffffffe0002019e0:	f5043783          	ld	a5,-176(s0)
ffffffe0002019e4:	f5040713          	addi	a4,s0,-176
ffffffe0002019e8:	00a00613          	li	a2,10
ffffffe0002019ec:	00070593          	mv	a1,a4
ffffffe0002019f0:	00078513          	mv	a0,a5
ffffffe0002019f4:	88dff0ef          	jal	ffffffe000201280 <strtol>
ffffffe0002019f8:	00050793          	mv	a5,a0
ffffffe0002019fc:	0007879b          	sext.w	a5,a5
ffffffe000201a00:	f8f42423          	sw	a5,-120(s0)
                fmt--;
ffffffe000201a04:	f5043783          	ld	a5,-176(s0)
ffffffe000201a08:	fff78793          	addi	a5,a5,-1
ffffffe000201a0c:	f4f43823          	sd	a5,-176(s0)
ffffffe000201a10:	62c0006f          	j	ffffffe00020203c <vprintfmt+0x7c0>
            } else if (*fmt == '.') {
ffffffe000201a14:	f5043783          	ld	a5,-176(s0)
ffffffe000201a18:	0007c783          	lbu	a5,0(a5)
ffffffe000201a1c:	00078713          	mv	a4,a5
ffffffe000201a20:	02e00793          	li	a5,46
ffffffe000201a24:	06f71863          	bne	a4,a5,ffffffe000201a94 <vprintfmt+0x218>
                fmt++;
ffffffe000201a28:	f5043783          	ld	a5,-176(s0)
ffffffe000201a2c:	00178793          	addi	a5,a5,1
ffffffe000201a30:	f4f43823          	sd	a5,-176(s0)
                if (*fmt == '*') {
ffffffe000201a34:	f5043783          	ld	a5,-176(s0)
ffffffe000201a38:	0007c783          	lbu	a5,0(a5)
ffffffe000201a3c:	00078713          	mv	a4,a5
ffffffe000201a40:	02a00793          	li	a5,42
ffffffe000201a44:	00f71e63          	bne	a4,a5,ffffffe000201a60 <vprintfmt+0x1e4>
                    flags.prec = va_arg(vl, int);
ffffffe000201a48:	f4843783          	ld	a5,-184(s0)
ffffffe000201a4c:	00878713          	addi	a4,a5,8
ffffffe000201a50:	f4e43423          	sd	a4,-184(s0)
ffffffe000201a54:	0007a783          	lw	a5,0(a5)
ffffffe000201a58:	f8f42623          	sw	a5,-116(s0)
ffffffe000201a5c:	5e00006f          	j	ffffffe00020203c <vprintfmt+0x7c0>
                } else {
                    flags.prec = strtol(fmt, (char **)&fmt, 10);
ffffffe000201a60:	f5043783          	ld	a5,-176(s0)
ffffffe000201a64:	f5040713          	addi	a4,s0,-176
ffffffe000201a68:	00a00613          	li	a2,10
ffffffe000201a6c:	00070593          	mv	a1,a4
ffffffe000201a70:	00078513          	mv	a0,a5
ffffffe000201a74:	80dff0ef          	jal	ffffffe000201280 <strtol>
ffffffe000201a78:	00050793          	mv	a5,a0
ffffffe000201a7c:	0007879b          	sext.w	a5,a5
ffffffe000201a80:	f8f42623          	sw	a5,-116(s0)
                    fmt--;
ffffffe000201a84:	f5043783          	ld	a5,-176(s0)
ffffffe000201a88:	fff78793          	addi	a5,a5,-1
ffffffe000201a8c:	f4f43823          	sd	a5,-176(s0)
ffffffe000201a90:	5ac0006f          	j	ffffffe00020203c <vprintfmt+0x7c0>
                }
            } else if (*fmt == 'x' || *fmt == 'X' || *fmt == 'p') {
ffffffe000201a94:	f5043783          	ld	a5,-176(s0)
ffffffe000201a98:	0007c783          	lbu	a5,0(a5)
ffffffe000201a9c:	00078713          	mv	a4,a5
ffffffe000201aa0:	07800793          	li	a5,120
ffffffe000201aa4:	02f70663          	beq	a4,a5,ffffffe000201ad0 <vprintfmt+0x254>
ffffffe000201aa8:	f5043783          	ld	a5,-176(s0)
ffffffe000201aac:	0007c783          	lbu	a5,0(a5)
ffffffe000201ab0:	00078713          	mv	a4,a5
ffffffe000201ab4:	05800793          	li	a5,88
ffffffe000201ab8:	00f70c63          	beq	a4,a5,ffffffe000201ad0 <vprintfmt+0x254>
ffffffe000201abc:	f5043783          	ld	a5,-176(s0)
ffffffe000201ac0:	0007c783          	lbu	a5,0(a5)
ffffffe000201ac4:	00078713          	mv	a4,a5
ffffffe000201ac8:	07000793          	li	a5,112
ffffffe000201acc:	30f71263          	bne	a4,a5,ffffffe000201dd0 <vprintfmt+0x554>
                bool is_long = *fmt == 'p' || flags.longflag;
ffffffe000201ad0:	f5043783          	ld	a5,-176(s0)
ffffffe000201ad4:	0007c783          	lbu	a5,0(a5)
ffffffe000201ad8:	00078713          	mv	a4,a5
ffffffe000201adc:	07000793          	li	a5,112
ffffffe000201ae0:	00f70663          	beq	a4,a5,ffffffe000201aec <vprintfmt+0x270>
ffffffe000201ae4:	f8144783          	lbu	a5,-127(s0)
ffffffe000201ae8:	00078663          	beqz	a5,ffffffe000201af4 <vprintfmt+0x278>
ffffffe000201aec:	00100793          	li	a5,1
ffffffe000201af0:	0080006f          	j	ffffffe000201af8 <vprintfmt+0x27c>
ffffffe000201af4:	00000793          	li	a5,0
ffffffe000201af8:	faf403a3          	sb	a5,-89(s0)
ffffffe000201afc:	fa744783          	lbu	a5,-89(s0)
ffffffe000201b00:	0017f793          	andi	a5,a5,1
ffffffe000201b04:	faf403a3          	sb	a5,-89(s0)

                unsigned long num = is_long ? va_arg(vl, unsigned long) : va_arg(vl, unsigned int);
ffffffe000201b08:	fa744783          	lbu	a5,-89(s0)
ffffffe000201b0c:	0ff7f793          	zext.b	a5,a5
ffffffe000201b10:	00078c63          	beqz	a5,ffffffe000201b28 <vprintfmt+0x2ac>
ffffffe000201b14:	f4843783          	ld	a5,-184(s0)
ffffffe000201b18:	00878713          	addi	a4,a5,8
ffffffe000201b1c:	f4e43423          	sd	a4,-184(s0)
ffffffe000201b20:	0007b783          	ld	a5,0(a5)
ffffffe000201b24:	01c0006f          	j	ffffffe000201b40 <vprintfmt+0x2c4>
ffffffe000201b28:	f4843783          	ld	a5,-184(s0)
ffffffe000201b2c:	00878713          	addi	a4,a5,8
ffffffe000201b30:	f4e43423          	sd	a4,-184(s0)
ffffffe000201b34:	0007a783          	lw	a5,0(a5)
ffffffe000201b38:	02079793          	slli	a5,a5,0x20
ffffffe000201b3c:	0207d793          	srli	a5,a5,0x20
ffffffe000201b40:	fef43023          	sd	a5,-32(s0)

                if (flags.prec == 0 && num == 0 && *fmt != 'p') {
ffffffe000201b44:	f8c42783          	lw	a5,-116(s0)
ffffffe000201b48:	02079463          	bnez	a5,ffffffe000201b70 <vprintfmt+0x2f4>
ffffffe000201b4c:	fe043783          	ld	a5,-32(s0)
ffffffe000201b50:	02079063          	bnez	a5,ffffffe000201b70 <vprintfmt+0x2f4>
ffffffe000201b54:	f5043783          	ld	a5,-176(s0)
ffffffe000201b58:	0007c783          	lbu	a5,0(a5)
ffffffe000201b5c:	00078713          	mv	a4,a5
ffffffe000201b60:	07000793          	li	a5,112
ffffffe000201b64:	00f70663          	beq	a4,a5,ffffffe000201b70 <vprintfmt+0x2f4>
                    flags.in_format = false;
ffffffe000201b68:	f8040023          	sb	zero,-128(s0)
ffffffe000201b6c:	4d00006f          	j	ffffffe00020203c <vprintfmt+0x7c0>
                    continue;
                }

                // 0x prefix for pointers, or, if # flag is set and non-zero
                bool prefix = *fmt == 'p' || (flags.sharpflag && num != 0);
ffffffe000201b70:	f5043783          	ld	a5,-176(s0)
ffffffe000201b74:	0007c783          	lbu	a5,0(a5)
ffffffe000201b78:	00078713          	mv	a4,a5
ffffffe000201b7c:	07000793          	li	a5,112
ffffffe000201b80:	00f70a63          	beq	a4,a5,ffffffe000201b94 <vprintfmt+0x318>
ffffffe000201b84:	f8244783          	lbu	a5,-126(s0)
ffffffe000201b88:	00078a63          	beqz	a5,ffffffe000201b9c <vprintfmt+0x320>
ffffffe000201b8c:	fe043783          	ld	a5,-32(s0)
ffffffe000201b90:	00078663          	beqz	a5,ffffffe000201b9c <vprintfmt+0x320>
ffffffe000201b94:	00100793          	li	a5,1
ffffffe000201b98:	0080006f          	j	ffffffe000201ba0 <vprintfmt+0x324>
ffffffe000201b9c:	00000793          	li	a5,0
ffffffe000201ba0:	faf40323          	sb	a5,-90(s0)
ffffffe000201ba4:	fa644783          	lbu	a5,-90(s0)
ffffffe000201ba8:	0017f793          	andi	a5,a5,1
ffffffe000201bac:	faf40323          	sb	a5,-90(s0)

                int hexdigits = 0;
ffffffe000201bb0:	fc042e23          	sw	zero,-36(s0)
                const char *xdigits = *fmt == 'X' ? upperxdigits : lowerxdigits;
ffffffe000201bb4:	f5043783          	ld	a5,-176(s0)
ffffffe000201bb8:	0007c783          	lbu	a5,0(a5)
ffffffe000201bbc:	00078713          	mv	a4,a5
ffffffe000201bc0:	05800793          	li	a5,88
ffffffe000201bc4:	00f71863          	bne	a4,a5,ffffffe000201bd4 <vprintfmt+0x358>
ffffffe000201bc8:	00001797          	auipc	a5,0x1
ffffffe000201bcc:	61878793          	addi	a5,a5,1560 # ffffffe0002031e0 <upperxdigits.1>
ffffffe000201bd0:	00c0006f          	j	ffffffe000201bdc <vprintfmt+0x360>
ffffffe000201bd4:	00001797          	auipc	a5,0x1
ffffffe000201bd8:	62478793          	addi	a5,a5,1572 # ffffffe0002031f8 <lowerxdigits.0>
ffffffe000201bdc:	f8f43c23          	sd	a5,-104(s0)
                char buf[2 * sizeof(unsigned long)];

                do {
                    buf[hexdigits++] = xdigits[num & 0xf];
ffffffe000201be0:	fe043783          	ld	a5,-32(s0)
ffffffe000201be4:	00f7f793          	andi	a5,a5,15
ffffffe000201be8:	f9843703          	ld	a4,-104(s0)
ffffffe000201bec:	00f70733          	add	a4,a4,a5
ffffffe000201bf0:	fdc42783          	lw	a5,-36(s0)
ffffffe000201bf4:	0017869b          	addiw	a3,a5,1
ffffffe000201bf8:	fcd42e23          	sw	a3,-36(s0)
ffffffe000201bfc:	00074703          	lbu	a4,0(a4)
ffffffe000201c00:	ff078793          	addi	a5,a5,-16
ffffffe000201c04:	008787b3          	add	a5,a5,s0
ffffffe000201c08:	f8e78023          	sb	a4,-128(a5)
                    num >>= 4;
ffffffe000201c0c:	fe043783          	ld	a5,-32(s0)
ffffffe000201c10:	0047d793          	srli	a5,a5,0x4
ffffffe000201c14:	fef43023          	sd	a5,-32(s0)
                } while (num);
ffffffe000201c18:	fe043783          	ld	a5,-32(s0)
ffffffe000201c1c:	fc0792e3          	bnez	a5,ffffffe000201be0 <vprintfmt+0x364>

                if (flags.prec == -1 && flags.zeroflag) {
ffffffe000201c20:	f8c42783          	lw	a5,-116(s0)
ffffffe000201c24:	00078713          	mv	a4,a5
ffffffe000201c28:	fff00793          	li	a5,-1
ffffffe000201c2c:	02f71663          	bne	a4,a5,ffffffe000201c58 <vprintfmt+0x3dc>
ffffffe000201c30:	f8344783          	lbu	a5,-125(s0)
ffffffe000201c34:	02078263          	beqz	a5,ffffffe000201c58 <vprintfmt+0x3dc>
                    flags.prec = flags.width - 2 * prefix;
ffffffe000201c38:	f8842703          	lw	a4,-120(s0)
ffffffe000201c3c:	fa644783          	lbu	a5,-90(s0)
ffffffe000201c40:	0007879b          	sext.w	a5,a5
ffffffe000201c44:	0017979b          	slliw	a5,a5,0x1
ffffffe000201c48:	0007879b          	sext.w	a5,a5
ffffffe000201c4c:	40f707bb          	subw	a5,a4,a5
ffffffe000201c50:	0007879b          	sext.w	a5,a5
ffffffe000201c54:	f8f42623          	sw	a5,-116(s0)
                }

                for (int i = flags.width - 2 * prefix - __MAX(hexdigits, flags.prec); i > 0; i--) {
ffffffe000201c58:	f8842703          	lw	a4,-120(s0)
ffffffe000201c5c:	fa644783          	lbu	a5,-90(s0)
ffffffe000201c60:	0007879b          	sext.w	a5,a5
ffffffe000201c64:	0017979b          	slliw	a5,a5,0x1
ffffffe000201c68:	0007879b          	sext.w	a5,a5
ffffffe000201c6c:	40f707bb          	subw	a5,a4,a5
ffffffe000201c70:	0007871b          	sext.w	a4,a5
ffffffe000201c74:	fdc42783          	lw	a5,-36(s0)
ffffffe000201c78:	f8f42a23          	sw	a5,-108(s0)
ffffffe000201c7c:	f8c42783          	lw	a5,-116(s0)
ffffffe000201c80:	f8f42823          	sw	a5,-112(s0)
ffffffe000201c84:	f9442783          	lw	a5,-108(s0)
ffffffe000201c88:	00078593          	mv	a1,a5
ffffffe000201c8c:	f9042783          	lw	a5,-112(s0)
ffffffe000201c90:	00078613          	mv	a2,a5
ffffffe000201c94:	0006069b          	sext.w	a3,a2
ffffffe000201c98:	0005879b          	sext.w	a5,a1
ffffffe000201c9c:	00f6d463          	bge	a3,a5,ffffffe000201ca4 <vprintfmt+0x428>
ffffffe000201ca0:	00058613          	mv	a2,a1
ffffffe000201ca4:	0006079b          	sext.w	a5,a2
ffffffe000201ca8:	40f707bb          	subw	a5,a4,a5
ffffffe000201cac:	fcf42c23          	sw	a5,-40(s0)
ffffffe000201cb0:	0280006f          	j	ffffffe000201cd8 <vprintfmt+0x45c>
                    putch(' ');
ffffffe000201cb4:	f5843783          	ld	a5,-168(s0)
ffffffe000201cb8:	02000513          	li	a0,32
ffffffe000201cbc:	000780e7          	jalr	a5
                    ++written;
ffffffe000201cc0:	fec42783          	lw	a5,-20(s0)
ffffffe000201cc4:	0017879b          	addiw	a5,a5,1
ffffffe000201cc8:	fef42623          	sw	a5,-20(s0)
                for (int i = flags.width - 2 * prefix - __MAX(hexdigits, flags.prec); i > 0; i--) {
ffffffe000201ccc:	fd842783          	lw	a5,-40(s0)
ffffffe000201cd0:	fff7879b          	addiw	a5,a5,-1
ffffffe000201cd4:	fcf42c23          	sw	a5,-40(s0)
ffffffe000201cd8:	fd842783          	lw	a5,-40(s0)
ffffffe000201cdc:	0007879b          	sext.w	a5,a5
ffffffe000201ce0:	fcf04ae3          	bgtz	a5,ffffffe000201cb4 <vprintfmt+0x438>
                }

                if (prefix) {
ffffffe000201ce4:	fa644783          	lbu	a5,-90(s0)
ffffffe000201ce8:	0ff7f793          	zext.b	a5,a5
ffffffe000201cec:	04078463          	beqz	a5,ffffffe000201d34 <vprintfmt+0x4b8>
                    putch('0');
ffffffe000201cf0:	f5843783          	ld	a5,-168(s0)
ffffffe000201cf4:	03000513          	li	a0,48
ffffffe000201cf8:	000780e7          	jalr	a5
                    putch(*fmt == 'X' ? 'X' : 'x');
ffffffe000201cfc:	f5043783          	ld	a5,-176(s0)
ffffffe000201d00:	0007c783          	lbu	a5,0(a5)
ffffffe000201d04:	00078713          	mv	a4,a5
ffffffe000201d08:	05800793          	li	a5,88
ffffffe000201d0c:	00f71663          	bne	a4,a5,ffffffe000201d18 <vprintfmt+0x49c>
ffffffe000201d10:	05800793          	li	a5,88
ffffffe000201d14:	0080006f          	j	ffffffe000201d1c <vprintfmt+0x4a0>
ffffffe000201d18:	07800793          	li	a5,120
ffffffe000201d1c:	f5843703          	ld	a4,-168(s0)
ffffffe000201d20:	00078513          	mv	a0,a5
ffffffe000201d24:	000700e7          	jalr	a4
                    written += 2;
ffffffe000201d28:	fec42783          	lw	a5,-20(s0)
ffffffe000201d2c:	0027879b          	addiw	a5,a5,2
ffffffe000201d30:	fef42623          	sw	a5,-20(s0)
                }

                for (int i = hexdigits; i < flags.prec; i++) {
ffffffe000201d34:	fdc42783          	lw	a5,-36(s0)
ffffffe000201d38:	fcf42a23          	sw	a5,-44(s0)
ffffffe000201d3c:	0280006f          	j	ffffffe000201d64 <vprintfmt+0x4e8>
                    putch('0');
ffffffe000201d40:	f5843783          	ld	a5,-168(s0)
ffffffe000201d44:	03000513          	li	a0,48
ffffffe000201d48:	000780e7          	jalr	a5
                    ++written;
ffffffe000201d4c:	fec42783          	lw	a5,-20(s0)
ffffffe000201d50:	0017879b          	addiw	a5,a5,1
ffffffe000201d54:	fef42623          	sw	a5,-20(s0)
                for (int i = hexdigits; i < flags.prec; i++) {
ffffffe000201d58:	fd442783          	lw	a5,-44(s0)
ffffffe000201d5c:	0017879b          	addiw	a5,a5,1
ffffffe000201d60:	fcf42a23          	sw	a5,-44(s0)
ffffffe000201d64:	f8c42703          	lw	a4,-116(s0)
ffffffe000201d68:	fd442783          	lw	a5,-44(s0)
ffffffe000201d6c:	0007879b          	sext.w	a5,a5
ffffffe000201d70:	fce7c8e3          	blt	a5,a4,ffffffe000201d40 <vprintfmt+0x4c4>
                }

                for (int i = hexdigits - 1; i >= 0; i--) {
ffffffe000201d74:	fdc42783          	lw	a5,-36(s0)
ffffffe000201d78:	fff7879b          	addiw	a5,a5,-1
ffffffe000201d7c:	fcf42823          	sw	a5,-48(s0)
ffffffe000201d80:	03c0006f          	j	ffffffe000201dbc <vprintfmt+0x540>
                    putch(buf[i]);
ffffffe000201d84:	fd042783          	lw	a5,-48(s0)
ffffffe000201d88:	ff078793          	addi	a5,a5,-16
ffffffe000201d8c:	008787b3          	add	a5,a5,s0
ffffffe000201d90:	f807c783          	lbu	a5,-128(a5)
ffffffe000201d94:	0007871b          	sext.w	a4,a5
ffffffe000201d98:	f5843783          	ld	a5,-168(s0)
ffffffe000201d9c:	00070513          	mv	a0,a4
ffffffe000201da0:	000780e7          	jalr	a5
                    ++written;
ffffffe000201da4:	fec42783          	lw	a5,-20(s0)
ffffffe000201da8:	0017879b          	addiw	a5,a5,1
ffffffe000201dac:	fef42623          	sw	a5,-20(s0)
                for (int i = hexdigits - 1; i >= 0; i--) {
ffffffe000201db0:	fd042783          	lw	a5,-48(s0)
ffffffe000201db4:	fff7879b          	addiw	a5,a5,-1
ffffffe000201db8:	fcf42823          	sw	a5,-48(s0)
ffffffe000201dbc:	fd042783          	lw	a5,-48(s0)
ffffffe000201dc0:	0007879b          	sext.w	a5,a5
ffffffe000201dc4:	fc07d0e3          	bgez	a5,ffffffe000201d84 <vprintfmt+0x508>
                }

                flags.in_format = false;
ffffffe000201dc8:	f8040023          	sb	zero,-128(s0)
            } else if (*fmt == 'x' || *fmt == 'X' || *fmt == 'p') {
ffffffe000201dcc:	2700006f          	j	ffffffe00020203c <vprintfmt+0x7c0>
            } else if (*fmt == 'd' || *fmt == 'i' || *fmt == 'u') {
ffffffe000201dd0:	f5043783          	ld	a5,-176(s0)
ffffffe000201dd4:	0007c783          	lbu	a5,0(a5)
ffffffe000201dd8:	00078713          	mv	a4,a5
ffffffe000201ddc:	06400793          	li	a5,100
ffffffe000201de0:	02f70663          	beq	a4,a5,ffffffe000201e0c <vprintfmt+0x590>
ffffffe000201de4:	f5043783          	ld	a5,-176(s0)
ffffffe000201de8:	0007c783          	lbu	a5,0(a5)
ffffffe000201dec:	00078713          	mv	a4,a5
ffffffe000201df0:	06900793          	li	a5,105
ffffffe000201df4:	00f70c63          	beq	a4,a5,ffffffe000201e0c <vprintfmt+0x590>
ffffffe000201df8:	f5043783          	ld	a5,-176(s0)
ffffffe000201dfc:	0007c783          	lbu	a5,0(a5)
ffffffe000201e00:	00078713          	mv	a4,a5
ffffffe000201e04:	07500793          	li	a5,117
ffffffe000201e08:	08f71063          	bne	a4,a5,ffffffe000201e88 <vprintfmt+0x60c>
                long num = flags.longflag ? va_arg(vl, long) : va_arg(vl, int);
ffffffe000201e0c:	f8144783          	lbu	a5,-127(s0)
ffffffe000201e10:	00078c63          	beqz	a5,ffffffe000201e28 <vprintfmt+0x5ac>
ffffffe000201e14:	f4843783          	ld	a5,-184(s0)
ffffffe000201e18:	00878713          	addi	a4,a5,8
ffffffe000201e1c:	f4e43423          	sd	a4,-184(s0)
ffffffe000201e20:	0007b783          	ld	a5,0(a5)
ffffffe000201e24:	0140006f          	j	ffffffe000201e38 <vprintfmt+0x5bc>
ffffffe000201e28:	f4843783          	ld	a5,-184(s0)
ffffffe000201e2c:	00878713          	addi	a4,a5,8
ffffffe000201e30:	f4e43423          	sd	a4,-184(s0)
ffffffe000201e34:	0007a783          	lw	a5,0(a5)
ffffffe000201e38:	faf43423          	sd	a5,-88(s0)

                written += print_dec_int(putch, num, *fmt != 'u', &flags);
ffffffe000201e3c:	fa843583          	ld	a1,-88(s0)
ffffffe000201e40:	f5043783          	ld	a5,-176(s0)
ffffffe000201e44:	0007c783          	lbu	a5,0(a5)
ffffffe000201e48:	0007871b          	sext.w	a4,a5
ffffffe000201e4c:	07500793          	li	a5,117
ffffffe000201e50:	40f707b3          	sub	a5,a4,a5
ffffffe000201e54:	00f037b3          	snez	a5,a5
ffffffe000201e58:	0ff7f793          	zext.b	a5,a5
ffffffe000201e5c:	f8040713          	addi	a4,s0,-128
ffffffe000201e60:	00070693          	mv	a3,a4
ffffffe000201e64:	00078613          	mv	a2,a5
ffffffe000201e68:	f5843503          	ld	a0,-168(s0)
ffffffe000201e6c:	f08ff0ef          	jal	ffffffe000201574 <print_dec_int>
ffffffe000201e70:	00050793          	mv	a5,a0
ffffffe000201e74:	fec42703          	lw	a4,-20(s0)
ffffffe000201e78:	00f707bb          	addw	a5,a4,a5
ffffffe000201e7c:	fef42623          	sw	a5,-20(s0)
                flags.in_format = false;
ffffffe000201e80:	f8040023          	sb	zero,-128(s0)
            } else if (*fmt == 'd' || *fmt == 'i' || *fmt == 'u') {
ffffffe000201e84:	1b80006f          	j	ffffffe00020203c <vprintfmt+0x7c0>
            } else if (*fmt == 'n') {
ffffffe000201e88:	f5043783          	ld	a5,-176(s0)
ffffffe000201e8c:	0007c783          	lbu	a5,0(a5)
ffffffe000201e90:	00078713          	mv	a4,a5
ffffffe000201e94:	06e00793          	li	a5,110
ffffffe000201e98:	04f71c63          	bne	a4,a5,ffffffe000201ef0 <vprintfmt+0x674>
                if (flags.longflag) {
ffffffe000201e9c:	f8144783          	lbu	a5,-127(s0)
ffffffe000201ea0:	02078463          	beqz	a5,ffffffe000201ec8 <vprintfmt+0x64c>
                    long *n = va_arg(vl, long *);
ffffffe000201ea4:	f4843783          	ld	a5,-184(s0)
ffffffe000201ea8:	00878713          	addi	a4,a5,8
ffffffe000201eac:	f4e43423          	sd	a4,-184(s0)
ffffffe000201eb0:	0007b783          	ld	a5,0(a5)
ffffffe000201eb4:	faf43823          	sd	a5,-80(s0)
                    *n = written;
ffffffe000201eb8:	fec42703          	lw	a4,-20(s0)
ffffffe000201ebc:	fb043783          	ld	a5,-80(s0)
ffffffe000201ec0:	00e7b023          	sd	a4,0(a5)
ffffffe000201ec4:	0240006f          	j	ffffffe000201ee8 <vprintfmt+0x66c>
                } else {
                    int *n = va_arg(vl, int *);
ffffffe000201ec8:	f4843783          	ld	a5,-184(s0)
ffffffe000201ecc:	00878713          	addi	a4,a5,8
ffffffe000201ed0:	f4e43423          	sd	a4,-184(s0)
ffffffe000201ed4:	0007b783          	ld	a5,0(a5)
ffffffe000201ed8:	faf43c23          	sd	a5,-72(s0)
                    *n = written;
ffffffe000201edc:	fb843783          	ld	a5,-72(s0)
ffffffe000201ee0:	fec42703          	lw	a4,-20(s0)
ffffffe000201ee4:	00e7a023          	sw	a4,0(a5)
                }
                flags.in_format = false;
ffffffe000201ee8:	f8040023          	sb	zero,-128(s0)
ffffffe000201eec:	1500006f          	j	ffffffe00020203c <vprintfmt+0x7c0>
            } else if (*fmt == 's') {
ffffffe000201ef0:	f5043783          	ld	a5,-176(s0)
ffffffe000201ef4:	0007c783          	lbu	a5,0(a5)
ffffffe000201ef8:	00078713          	mv	a4,a5
ffffffe000201efc:	07300793          	li	a5,115
ffffffe000201f00:	02f71e63          	bne	a4,a5,ffffffe000201f3c <vprintfmt+0x6c0>
                const char *s = va_arg(vl, const char *);
ffffffe000201f04:	f4843783          	ld	a5,-184(s0)
ffffffe000201f08:	00878713          	addi	a4,a5,8
ffffffe000201f0c:	f4e43423          	sd	a4,-184(s0)
ffffffe000201f10:	0007b783          	ld	a5,0(a5)
ffffffe000201f14:	fcf43023          	sd	a5,-64(s0)
                written += puts_wo_nl(putch, s);
ffffffe000201f18:	fc043583          	ld	a1,-64(s0)
ffffffe000201f1c:	f5843503          	ld	a0,-168(s0)
ffffffe000201f20:	dccff0ef          	jal	ffffffe0002014ec <puts_wo_nl>
ffffffe000201f24:	00050793          	mv	a5,a0
ffffffe000201f28:	fec42703          	lw	a4,-20(s0)
ffffffe000201f2c:	00f707bb          	addw	a5,a4,a5
ffffffe000201f30:	fef42623          	sw	a5,-20(s0)
                flags.in_format = false;
ffffffe000201f34:	f8040023          	sb	zero,-128(s0)
ffffffe000201f38:	1040006f          	j	ffffffe00020203c <vprintfmt+0x7c0>
            } else if (*fmt == 'c') {
ffffffe000201f3c:	f5043783          	ld	a5,-176(s0)
ffffffe000201f40:	0007c783          	lbu	a5,0(a5)
ffffffe000201f44:	00078713          	mv	a4,a5
ffffffe000201f48:	06300793          	li	a5,99
ffffffe000201f4c:	02f71e63          	bne	a4,a5,ffffffe000201f88 <vprintfmt+0x70c>
                int ch = va_arg(vl, int);
ffffffe000201f50:	f4843783          	ld	a5,-184(s0)
ffffffe000201f54:	00878713          	addi	a4,a5,8
ffffffe000201f58:	f4e43423          	sd	a4,-184(s0)
ffffffe000201f5c:	0007a783          	lw	a5,0(a5)
ffffffe000201f60:	fcf42623          	sw	a5,-52(s0)
                putch(ch);
ffffffe000201f64:	fcc42703          	lw	a4,-52(s0)
ffffffe000201f68:	f5843783          	ld	a5,-168(s0)
ffffffe000201f6c:	00070513          	mv	a0,a4
ffffffe000201f70:	000780e7          	jalr	a5
                ++written;
ffffffe000201f74:	fec42783          	lw	a5,-20(s0)
ffffffe000201f78:	0017879b          	addiw	a5,a5,1
ffffffe000201f7c:	fef42623          	sw	a5,-20(s0)
                flags.in_format = false;
ffffffe000201f80:	f8040023          	sb	zero,-128(s0)
ffffffe000201f84:	0b80006f          	j	ffffffe00020203c <vprintfmt+0x7c0>
            } else if (*fmt == '%') {
ffffffe000201f88:	f5043783          	ld	a5,-176(s0)
ffffffe000201f8c:	0007c783          	lbu	a5,0(a5)
ffffffe000201f90:	00078713          	mv	a4,a5
ffffffe000201f94:	02500793          	li	a5,37
ffffffe000201f98:	02f71263          	bne	a4,a5,ffffffe000201fbc <vprintfmt+0x740>
                putch('%');
ffffffe000201f9c:	f5843783          	ld	a5,-168(s0)
ffffffe000201fa0:	02500513          	li	a0,37
ffffffe000201fa4:	000780e7          	jalr	a5
                ++written;
ffffffe000201fa8:	fec42783          	lw	a5,-20(s0)
ffffffe000201fac:	0017879b          	addiw	a5,a5,1
ffffffe000201fb0:	fef42623          	sw	a5,-20(s0)
                flags.in_format = false;
ffffffe000201fb4:	f8040023          	sb	zero,-128(s0)
ffffffe000201fb8:	0840006f          	j	ffffffe00020203c <vprintfmt+0x7c0>
            } else {
                putch(*fmt);
ffffffe000201fbc:	f5043783          	ld	a5,-176(s0)
ffffffe000201fc0:	0007c783          	lbu	a5,0(a5)
ffffffe000201fc4:	0007871b          	sext.w	a4,a5
ffffffe000201fc8:	f5843783          	ld	a5,-168(s0)
ffffffe000201fcc:	00070513          	mv	a0,a4
ffffffe000201fd0:	000780e7          	jalr	a5
                ++written;
ffffffe000201fd4:	fec42783          	lw	a5,-20(s0)
ffffffe000201fd8:	0017879b          	addiw	a5,a5,1
ffffffe000201fdc:	fef42623          	sw	a5,-20(s0)
                flags.in_format = false;
ffffffe000201fe0:	f8040023          	sb	zero,-128(s0)
ffffffe000201fe4:	0580006f          	j	ffffffe00020203c <vprintfmt+0x7c0>
            }
        } else if (*fmt == '%') {
ffffffe000201fe8:	f5043783          	ld	a5,-176(s0)
ffffffe000201fec:	0007c783          	lbu	a5,0(a5)
ffffffe000201ff0:	00078713          	mv	a4,a5
ffffffe000201ff4:	02500793          	li	a5,37
ffffffe000201ff8:	02f71063          	bne	a4,a5,ffffffe000202018 <vprintfmt+0x79c>
            flags = (struct fmt_flags) {.in_format = true, .prec = -1};
ffffffe000201ffc:	f8043023          	sd	zero,-128(s0)
ffffffe000202000:	f8043423          	sd	zero,-120(s0)
ffffffe000202004:	00100793          	li	a5,1
ffffffe000202008:	f8f40023          	sb	a5,-128(s0)
ffffffe00020200c:	fff00793          	li	a5,-1
ffffffe000202010:	f8f42623          	sw	a5,-116(s0)
ffffffe000202014:	0280006f          	j	ffffffe00020203c <vprintfmt+0x7c0>
        } else {
            putch(*fmt);
ffffffe000202018:	f5043783          	ld	a5,-176(s0)
ffffffe00020201c:	0007c783          	lbu	a5,0(a5)
ffffffe000202020:	0007871b          	sext.w	a4,a5
ffffffe000202024:	f5843783          	ld	a5,-168(s0)
ffffffe000202028:	00070513          	mv	a0,a4
ffffffe00020202c:	000780e7          	jalr	a5
            ++written;
ffffffe000202030:	fec42783          	lw	a5,-20(s0)
ffffffe000202034:	0017879b          	addiw	a5,a5,1
ffffffe000202038:	fef42623          	sw	a5,-20(s0)
    for (; *fmt; fmt++) {
ffffffe00020203c:	f5043783          	ld	a5,-176(s0)
ffffffe000202040:	00178793          	addi	a5,a5,1
ffffffe000202044:	f4f43823          	sd	a5,-176(s0)
ffffffe000202048:	f5043783          	ld	a5,-176(s0)
ffffffe00020204c:	0007c783          	lbu	a5,0(a5)
ffffffe000202050:	84079ce3          	bnez	a5,ffffffe0002018a8 <vprintfmt+0x2c>
        }
    }

    return written;
ffffffe000202054:	fec42783          	lw	a5,-20(s0)
}
ffffffe000202058:	00078513          	mv	a0,a5
ffffffe00020205c:	0b813083          	ld	ra,184(sp)
ffffffe000202060:	0b013403          	ld	s0,176(sp)
ffffffe000202064:	0c010113          	addi	sp,sp,192
ffffffe000202068:	00008067          	ret

ffffffe00020206c <printk>:

int printk(const char* s, ...) {
ffffffe00020206c:	f9010113          	addi	sp,sp,-112
ffffffe000202070:	02113423          	sd	ra,40(sp)
ffffffe000202074:	02813023          	sd	s0,32(sp)
ffffffe000202078:	03010413          	addi	s0,sp,48
ffffffe00020207c:	fca43c23          	sd	a0,-40(s0)
ffffffe000202080:	00b43423          	sd	a1,8(s0)
ffffffe000202084:	00c43823          	sd	a2,16(s0)
ffffffe000202088:	00d43c23          	sd	a3,24(s0)
ffffffe00020208c:	02e43023          	sd	a4,32(s0)
ffffffe000202090:	02f43423          	sd	a5,40(s0)
ffffffe000202094:	03043823          	sd	a6,48(s0)
ffffffe000202098:	03143c23          	sd	a7,56(s0)
    int res = 0;
ffffffe00020209c:	fe042623          	sw	zero,-20(s0)
    va_list vl;
    va_start(vl, s);
ffffffe0002020a0:	04040793          	addi	a5,s0,64
ffffffe0002020a4:	fcf43823          	sd	a5,-48(s0)
ffffffe0002020a8:	fd043783          	ld	a5,-48(s0)
ffffffe0002020ac:	fc878793          	addi	a5,a5,-56
ffffffe0002020b0:	fef43023          	sd	a5,-32(s0)
    res = vprintfmt(putc, s, vl);
ffffffe0002020b4:	fe043783          	ld	a5,-32(s0)
ffffffe0002020b8:	00078613          	mv	a2,a5
ffffffe0002020bc:	fd843583          	ld	a1,-40(s0)
ffffffe0002020c0:	fffff517          	auipc	a0,0xfffff
ffffffe0002020c4:	11850513          	addi	a0,a0,280 # ffffffe0002011d8 <putc>
ffffffe0002020c8:	fb4ff0ef          	jal	ffffffe00020187c <vprintfmt>
ffffffe0002020cc:	00050793          	mv	a5,a0
ffffffe0002020d0:	fef42623          	sw	a5,-20(s0)
    va_end(vl);
    return res;
ffffffe0002020d4:	fec42783          	lw	a5,-20(s0)
}
ffffffe0002020d8:	00078513          	mv	a0,a5
ffffffe0002020dc:	02813083          	ld	ra,40(sp)
ffffffe0002020e0:	02013403          	ld	s0,32(sp)
ffffffe0002020e4:	07010113          	addi	sp,sp,112
ffffffe0002020e8:	00008067          	ret

ffffffe0002020ec <srand>:
#include "stdint.h"
#include "stdlib.h"

static uint64_t seed;

void srand(unsigned s) {
ffffffe0002020ec:	fe010113          	addi	sp,sp,-32
ffffffe0002020f0:	00813c23          	sd	s0,24(sp)
ffffffe0002020f4:	02010413          	addi	s0,sp,32
ffffffe0002020f8:	00050793          	mv	a5,a0
ffffffe0002020fc:	fef42623          	sw	a5,-20(s0)
    seed = s - 1;
ffffffe000202100:	fec42783          	lw	a5,-20(s0)
ffffffe000202104:	fff7879b          	addiw	a5,a5,-1
ffffffe000202108:	0007879b          	sext.w	a5,a5
ffffffe00020210c:	02079713          	slli	a4,a5,0x20
ffffffe000202110:	02075713          	srli	a4,a4,0x20
ffffffe000202114:	00004797          	auipc	a5,0x4
ffffffe000202118:	f0c78793          	addi	a5,a5,-244 # ffffffe000206020 <seed>
ffffffe00020211c:	00e7b023          	sd	a4,0(a5)
}
ffffffe000202120:	00000013          	nop
ffffffe000202124:	01813403          	ld	s0,24(sp)
ffffffe000202128:	02010113          	addi	sp,sp,32
ffffffe00020212c:	00008067          	ret

ffffffe000202130 <rand>:

int rand(void) {
ffffffe000202130:	ff010113          	addi	sp,sp,-16
ffffffe000202134:	00813423          	sd	s0,8(sp)
ffffffe000202138:	01010413          	addi	s0,sp,16
    seed = 6364136223846793005ULL * seed + 1;
ffffffe00020213c:	00004797          	auipc	a5,0x4
ffffffe000202140:	ee478793          	addi	a5,a5,-284 # ffffffe000206020 <seed>
ffffffe000202144:	0007b703          	ld	a4,0(a5)
ffffffe000202148:	00001797          	auipc	a5,0x1
ffffffe00020214c:	0c878793          	addi	a5,a5,200 # ffffffe000203210 <lowerxdigits.0+0x18>
ffffffe000202150:	0007b783          	ld	a5,0(a5)
ffffffe000202154:	02f707b3          	mul	a5,a4,a5
ffffffe000202158:	00178713          	addi	a4,a5,1
ffffffe00020215c:	00004797          	auipc	a5,0x4
ffffffe000202160:	ec478793          	addi	a5,a5,-316 # ffffffe000206020 <seed>
ffffffe000202164:	00e7b023          	sd	a4,0(a5)
    return seed >> 33;
ffffffe000202168:	00004797          	auipc	a5,0x4
ffffffe00020216c:	eb878793          	addi	a5,a5,-328 # ffffffe000206020 <seed>
ffffffe000202170:	0007b783          	ld	a5,0(a5)
ffffffe000202174:	0217d793          	srli	a5,a5,0x21
ffffffe000202178:	0007879b          	sext.w	a5,a5
}
ffffffe00020217c:	00078513          	mv	a0,a5
ffffffe000202180:	00813403          	ld	s0,8(sp)
ffffffe000202184:	01010113          	addi	sp,sp,16
ffffffe000202188:	00008067          	ret

ffffffe00020218c <memset>:
#include "string.h"
#include "stdint.h"

void *memset(void *dest, int c, uint64_t n) {
ffffffe00020218c:	fc010113          	addi	sp,sp,-64
ffffffe000202190:	02813c23          	sd	s0,56(sp)
ffffffe000202194:	04010413          	addi	s0,sp,64
ffffffe000202198:	fca43c23          	sd	a0,-40(s0)
ffffffe00020219c:	00058793          	mv	a5,a1
ffffffe0002021a0:	fcc43423          	sd	a2,-56(s0)
ffffffe0002021a4:	fcf42a23          	sw	a5,-44(s0)
    char *s = (char *)dest;
ffffffe0002021a8:	fd843783          	ld	a5,-40(s0)
ffffffe0002021ac:	fef43023          	sd	a5,-32(s0)
    for (uint64_t i = 0; i < n; ++i) {
ffffffe0002021b0:	fe043423          	sd	zero,-24(s0)
ffffffe0002021b4:	0280006f          	j	ffffffe0002021dc <memset+0x50>
        s[i] = c;
ffffffe0002021b8:	fe043703          	ld	a4,-32(s0)
ffffffe0002021bc:	fe843783          	ld	a5,-24(s0)
ffffffe0002021c0:	00f707b3          	add	a5,a4,a5
ffffffe0002021c4:	fd442703          	lw	a4,-44(s0)
ffffffe0002021c8:	0ff77713          	zext.b	a4,a4
ffffffe0002021cc:	00e78023          	sb	a4,0(a5)
    for (uint64_t i = 0; i < n; ++i) {
ffffffe0002021d0:	fe843783          	ld	a5,-24(s0)
ffffffe0002021d4:	00178793          	addi	a5,a5,1
ffffffe0002021d8:	fef43423          	sd	a5,-24(s0)
ffffffe0002021dc:	fe843703          	ld	a4,-24(s0)
ffffffe0002021e0:	fc843783          	ld	a5,-56(s0)
ffffffe0002021e4:	fcf76ae3          	bltu	a4,a5,ffffffe0002021b8 <memset+0x2c>
    }
    return dest;
ffffffe0002021e8:	fd843783          	ld	a5,-40(s0)
}
ffffffe0002021ec:	00078513          	mv	a0,a5
ffffffe0002021f0:	03813403          	ld	s0,56(sp)
ffffffe0002021f4:	04010113          	addi	sp,sp,64
ffffffe0002021f8:	00008067          	ret
