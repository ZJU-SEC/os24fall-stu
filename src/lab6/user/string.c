#include "string.h"
#include "stdint.h"

int strlen(const char *str) {
    int len = 0;
    while (*str++)
        len++;
    return len;
}