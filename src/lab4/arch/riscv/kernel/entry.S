    .extern trap_handler
    .section .text.entry
    .align 2
    .globl _traps 
_traps:
    # 判断是否是S态（sscratch为0）不需切换直接跳转，否则切换
    #保存t0 csrrw
        csrr t0, sscratch
        beq t0, zero, S_mode
        csrw sscratch, sp
        mv sp, t0   # switch stack from U-mode to S-mode

    # -----------
        # 1. save 32 registers and sepc to stack
S_mode:        
        addi sp, sp, -272
        sd x0, 0(sp)
        sd x1, 8(sp)
        sd x2, 16(sp)
        sd x3, 24(sp)
        sd x4, 32(sp)
        sd x5, 40(sp)
        sd x6, 48(sp)
        sd x7, 56(sp)
        sd x8, 64(sp)
        sd x9, 72(sp)
        sd x10, 80(sp)
        sd x11, 88(sp)
        sd x12, 96(sp)
        sd x13, 104(sp)
        sd x14, 112(sp)
        sd x15, 120(sp)
        sd x16, 128(sp)
        sd x17, 136(sp)
        sd x18, 144(sp)
        sd x19, 152(sp)
        sd x20, 160(sp)
        sd x21, 168(sp)
        sd x22, 176(sp)
        sd x23, 184(sp)
        sd x24, 192(sp)
        sd x25, 200(sp)
        sd x26, 208(sp)
        sd x27, 216(sp)
        sd x28, 224(sp)
        sd x29, 232(sp)
        sd x30, 240(sp)
        sd x31, 248(sp)
        csrr t0, sepc
        sd t0, 256(sp)
        csrr t0, sstatus
        sd t0, 264(sp)
    # -----------
        # 2. call trap_handler
        csrr a0, scause
        csrr a1, sepc
        mv a2, sp
        jal x1, trap_handler
    # -----------
        # 3. restore sepc and 32 registers (x2(sp) should be restore last) from stack
        ld t0, 264(sp)
        csrw sstatus, t0
        ld t0, 256(sp)
        csrw sepc, t0
        ld x0, 0(sp)
        ld x1, 8(sp)
        ld x3, 24(sp)
        ld x4, 32(sp)
        ld x5, 40(sp)
        ld x6, 48(sp)
        ld x7, 56(sp)
        ld x8, 64(sp)
        ld x9, 72(sp)
        ld x10, 80(sp)
        ld x11, 88(sp)
        ld x12, 96(sp)
        ld x13, 104(sp)
        ld x14, 112(sp)
        ld x15, 120(sp)
        ld x16, 128(sp)
        ld x17, 136(sp)
        ld x18, 144(sp)
        ld x19, 152(sp)
        ld x20, 160(sp)
        ld x21, 168(sp)
        ld x22, 176(sp)
        ld x23, 184(sp)
        ld x24, 192(sp)
        ld x25, 200(sp)
        ld x26, 208(sp)
        ld x27, 216(sp)
        ld x28, 224(sp)
        ld x29, 232(sp)
        ld x30, 240(sp)
        ld x31, 248(sp)
        ld x2, 16(sp)
        addi sp, sp, 256
    # -----------
        # 4. return from trap
        # switch from S-mode to U-mode
        csrr t0, sscratch
        beq t0, zero, return
        csrw sscratch, sp
        mv sp, t0   
return:        
        sret 
    # -----------
    .extern dummy
    .globl __dummy
__dummy:
    # lab3将 sepc 设置为 dummy() 的地址，并使用 sret 从 S 模式中返回
    # lab4 切换用户栈和内核栈
    csrr t0, sscratch    
    csrw sscratch, sp    
    mv sp, t0     
    sret 
    # -----------
    .globl __switch_to
__switch_to:
    # save state to prev process
    # 保存当前线程的 ra，sp，s0~s11 到当前线程的 thread_struct 中
    # 保存当前线程的 sepc sstatus sscratch 到当前线程的 thread_struct 中
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
    csrr t1, sepc
    sd t1, 112(t0)
    csrr t1, sstatus
    sd t1, 120(t0)
    csrr t1, sscratch
    sd t1, 128(t0)
    # restore state from next process
    # 将下一个线程的 thread_struct 中的相关数据载入到 ra，sp，s0~s11,sepc,sstatus,sscratch 中进行恢复
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
    ld t1, 112(t0)
    csrw sepc, t1
    ld t1, 120(t0)
    csrw sstatus, t1
    ld t1, 128(t0)
    csrw sscratch, t1

    # 切换页表
    #get pgd.va
    ld t1, 168(a1)
    li t2, 0xffffffdf80000000
    sub t1, t1, t2  #pgd.va->pgd.pa
    srli t1, t1, 12 #get PPN
    #mode = 8
    addi t0, zero, 1
    slli t0, t0, 63
    or t0, t0, t1
    csrw satp, t0
    # flush TLB and iCache
    sfence.vma zero, zero

    ret