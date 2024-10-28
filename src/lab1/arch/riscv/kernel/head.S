    .extern start_kernel
    .section .text.init
    .globl _start
_start:
    la sp, boot_stack_top
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
    li t0, 1<<1
    csrw sstatus, t0
    # ------------------
    jal x0, start_kernel
    # ------------------

    .section .bss.stack
    .globl boot_stack
boot_stack:
    .space 4096 # <-- change to your stack size

    .globl boot_stack_top
boot_stack_top: