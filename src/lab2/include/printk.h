#ifndef __PRINTK_H__
#define __PRINTK_H__

#include "stddef.h"

#define bool _Bool
#define true 1
#define false 0

int printk(const char *, ...);

#endif