#include "stdint.h"
#include "sbi.h"

struct sbiret sbi_ecall(uint64_t eid, uint64_t fid,
                        uint64_t arg0, uint64_t arg1, uint64_t arg2,
                        uint64_t arg3, uint64_t arg4, uint64_t arg5) {
    #error Unimplemented
}

struct sbiret sbi_debug_console_write_byte(uint8_t byte) {
    #error Unimplemented
}

struct sbiret sbi_system_reset(uint32_t reset_type, uint32_t reset_reason) {
    #error Unimplemented
}