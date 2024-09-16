#include "sbi.h"

void test() {
    sbi_system_reset(SBI_SRST_RESET_TYPE_SHUTDOWN, SBI_SRST_RESET_REASON_NONE);
    __builtin_unreachable();
}
