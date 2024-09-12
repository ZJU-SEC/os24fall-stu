.extern start_kernel

    .section .text.entry
    .globl _start
_start:
    # ------------------
    # - your code here -
    # ------------------

    .section .bss.stack
    .globl boot_stack
boot_stack:
    .space XYZ # <-- change to your stack size

    .globl boot_stack_top
boot_stack_top: