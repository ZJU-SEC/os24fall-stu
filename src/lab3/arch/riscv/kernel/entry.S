    .extern trap_handler
    .section .text.entry
    .align 2
    .globl _traps 
_traps:
    # -----------
        # 1. save 32 registers and sepc to stack
        addi sp, sp, -256
        sd x1, 0(sp)
        sd x2, 8(sp)
        sd x3, 16(sp)
        sd x4, 24(sp)
        sd x5, 32(sp)
        sd x6, 40(sp)
        sd x7, 48(sp)
        sd x8, 56(sp)
        sd x9, 64(sp)
        sd x10, 72(sp)
        sd x11, 80(sp)
        sd x12, 88(sp)
        sd x13, 96(sp)
        sd x14, 104(sp)
        sd x15, 112(sp)
        sd x16, 120(sp)
        sd x17, 128(sp)
        sd x18, 136(sp)
        sd x19, 144(sp)
        sd x20, 152(sp)
        sd x21, 160(sp)
        sd x22, 168(sp)
        sd x23, 176(sp)
        sd x24, 184(sp)
        sd x25, 192(sp)
        sd x26, 200(sp)
        sd x27, 208(sp)
        sd x28, 216(sp)
        sd x29, 224(sp)
        sd x30, 232(sp)
        sd x31, 240(sp)
        csrr t0, sepc
        sd t0, 248(sp)
    # -----------
        # 2. call trap_handler
        csrr a0, scause
        csrr a1, sepc
        jal x1, trap_handler
    # -----------
        # 3. restore sepc and 32 registers (x2(sp) should be restore last) from stack
        ld t0, 248(sp)
        csrw sepc, t0
        ld x1, 0(sp)
        ld x3, 16(sp)
        ld x4, 24(sp)
        ld x5, 32(sp)
        ld x6, 40(sp)
        ld x7, 48(sp)
        ld x8, 56(sp)
        ld x9, 64(sp)
        ld x10, 72(sp)
        ld x11, 80(sp)
        ld x12, 88(sp)
        ld x13, 96(sp)
        ld x14, 104(sp)
        ld x15, 112(sp)
        ld x16, 120(sp)
        ld x17, 128(sp)
        ld x18, 136(sp)
        ld x19, 144(sp)
        ld x20, 152(sp)
        ld x21, 160(sp)
        ld x22, 168(sp)
        ld x23, 176(sp)
        ld x24, 184(sp)
        ld x25, 192(sp)
        ld x26, 200(sp)
        ld x27, 208(sp)
        ld x28, 216(sp)
        ld x29, 224(sp)
        ld x30, 232(sp)
        ld x31, 240(sp)
        ld x2, 8(sp)
        addi sp, sp, 256
    # -----------
        # 4. return from trap
        sret 
    # -----------
    .extern dummy
    .globl __dummy
__dummy:
    # 将 sepc 设置为 dummy() 的地址，并使用 sret 从 S 模式中返回
    la t0, dummy
    csrw sepc, t0
    sret
    # -----------
    .globl __switch_to
__switch_to:
    # save state to prev process
    # 保存当前线程的 ra，sp，s0~s11 到当前线程的 thread_struct 中
    addi t0, a0, 32 #t0 = &prev->thread
    sd ra, 0(t0)
    sd sp, 8(t0)
    sd s0, 16(t0)
    sd s1, 24(t0)
    sd s2, 32(t0)
    sd s3, 40(t0)
    sd s4, 48(t0)
    sd s5, 56(t0)
    sd s6, 64(t0)
    sd s7, 72(t0)
    sd s8, 80(t0)
    sd s9, 88(t0)
    sd s10, 96(t0)
    sd s11, 104(t0)
    # restore state from next process
    # 将下一个线程的 thread_struct 中的相关数据载入到 ra，sp，s0~s11 中进行恢复
    addi t0, a1, 32
    ld ra, 0(t0)
    ld sp, 8(t0)
    ld s0, 16(t0)
    ld s1, 24(t0)
    ld s2, 32(t0)
    ld s3, 40(t0)
    ld s4, 48(t0)
    ld s5, 56(t0)
    ld s6, 64(t0)
    ld s7, 72(t0)
    ld s8, 80(t0)
    ld s9, 88(t0)
    ld s10, 96(t0)
    ld s11, 104(t0)
    ret