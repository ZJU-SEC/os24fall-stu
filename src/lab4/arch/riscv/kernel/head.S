    .extern start_kernel
    .section .text.init
    .globl _start
_start:
    la sp, boot_stack_top

    call setup_vm
    call relocate
    
    jal mm_init

    call setup_vm_final
    
    jal task_init
    # ------------------
    # set stvec = _traps
    la t0, _traps
    csrw stvec, t0
    # ------------------
    # set sie[STIE] = 1
    li t0, 1<<5
    csrw sie, t0
    # ------------------
    # set first time interrupt
    li t1,10000000
    # get time
    rdtime t0
    add t0,t0,t1
    # set next interrupt
    jal x1, sbi_set_timer
    # ------------------
    # set sstatus[SIE] = 1
    # li t0, 1<<1
    # csrw sstatus, t0
    # ------------------
    jal x0, start_kernel
    # ------------------

relocate:
    # set ra = ra + PA2VA_OFFSET
    # set sp = sp + PA2VA_OFFSET (If you have set the sp before)

    li t0, 0xffffffdf80000000
    add ra, ra, t0 
    add sp, sp, t0 
    
    #---set stvec---#
    # la t1, l1
    # add t1, t1, t0
    # csrw stvec, t1

    # need a fence to ensure the new translations are in use
    sfence.vma zero, zero

    # set satp with early_pgtbl

    # PPN
    la t2, early_pgtbl # PA of early_pgtbl
    srli t2, t2, 12 # PPN=PA>>12
    # ASID=0
    # MODE=8 (Sv39)
    addi t0, x0, 1
    li t1, 63
    sll t0, t0, t1
    or t2, t2, t0   
    csrw satp, t2
# l1:
    ret

    .section .bss.stack
    .globl boot_stack
boot_stack:
    .space 4096 # <-- change to your stack size

    .globl boot_stack_top
boot_stack_top: