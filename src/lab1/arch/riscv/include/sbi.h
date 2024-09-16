#ifndef __SBI_H__
#define __SBI_H__

#include "stdint.h"

struct sbiret {
    uint64_t error;
    uint64_t value;
};

struct sbiret sbi_ecall(uint64_t eid, uint64_t fid,
                        uint64_t arg0, uint64_t arg1, uint64_t arg2,
                        uint64_t arg3, uint64_t arg4, uint64_t arg5);

struct sbiret sbi_set_timer(uint64_t stime_value);
struct sbiret sbi_debug_console_write_byte(uint8_t byte);

#define SBI_SRST_RESET_TYPE_SHUTDOWN 0
#define SBI_SRST_RESET_TYPE_COLD_REBOOT 1
#define SBI_SRST_RESET_TYPE_WARM_REBOOT 2
#define SBI_SRST_RESET_REASON_NONE 0
#define SBI_SRST_RESET_REASON_SYSTEM_FAILURE 1
struct sbiret sbi_system_reset(uint32_t reset_type, uint32_t reset_reason);

#endif
