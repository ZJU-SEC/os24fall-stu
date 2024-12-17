#include "stdint.h"
#include "sbi.h"

struct sbiret sbi_ecall(uint64_t eid, uint64_t fid,
                        uint64_t arg0, uint64_t arg1, uint64_t arg2,
                        uint64_t arg3, uint64_t arg4, uint64_t arg5) {
    struct sbiret ret;
	__asm__ volatile(
		"mv a7, %[eid]\n"    
		"mv a6, %[fid]\n"
		"mv a0, %[arg0]\n"
		"mv a1, %[arg1]\n"
		"mv a2, %[arg2]\n"
		"mv a3, %[arg3]\n"
		"mv a4, %[arg4]\n"
		"mv a5, %[arg5]\n"
		"ecall\n"
		"mv %[error], a0\n"
		"mv %[value], a1\n"
		: [error] "=r"(ret.error), [value] "=r"(ret.value)
		: [eid] "r"(eid), [fid] "r"(fid), [arg0] "r"(arg0), [arg1] "r"(arg1),
		  [arg2] "r"(arg2), [arg3] "r"(arg3), [arg4] "r"(arg4), [arg5] "r"(arg5)
		: "memory","a0","a1","a2","a3","a4","a5","a6","a7"
		);
	return ret;
}

struct sbiret sbi_debug_console_write_byte(uint8_t byte) {
    sbi_ecall(SBI_DBCN_EXT, SBI_DBCN_WRITE_BYTE, byte, 0, 0, 0, 0, 0);
}

struct sbiret sbi_system_reset(uint32_t reset_type, uint32_t reset_reason) {
    sbi_ecall(SBI_SRST_EXT, SBI_SRST, reset_type, reset_reason, 0, 0, 0, 0);
}

struct sbiret sbi_set_timer(uint64_t stime_value) {
    sbi_ecall(SBI_SET_TIMER_EXT, SBI_SET_TIMER, stime_value, 0, 0, 0, 0, 0);
}