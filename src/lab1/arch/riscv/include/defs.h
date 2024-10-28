#ifndef __DEFS_H__
#define __DEFS_H__

#include "stdint.h"

#define csr_read(csr)                   \
  ({                                    \
    uint64_t __v;                         \
    /* unimplemented */                 \
    asm volatile (                      \
        "csrr %[v], " #csr              \
        : [v] "=r" (__v)                \
        :                               \
        : "memory"                      \
    );                                  \
    __v;                                \                               
  })

#define csr_write(csr, val)                                    \
  ({                                                           \
    uint64_t __v = (uint64_t)(val);                            \
    asm volatile("csrw " #csr ", %0" : : "r"(__v) : "memory"); \
  })

#endif
