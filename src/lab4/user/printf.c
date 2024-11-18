// credit: 45gfg9 <45gfg9@45gfg9.net>
#include "stdio.h"
#include "syscall.h"

int tail = 0;
char buffer[1000] = {[0 ... 999] = 0};

int putc(int c) {
    buffer[tail++] = (char)c;
    return (char)c;
}

#ifndef __MAX
#define __MAX(a, b)         \
    ({                        \
        __typeof__(a) _a = (a); \
        __typeof__(b) _b = (b); \
        _a > _b ? _a : _b;      \
    })
#endif

struct fmt_flags {
    bool in_format;
    bool longflag;
    bool sharpflag;
    bool zeroflag;
    bool spaceflag;
    bool sign;
    int width;
    int prec;
};

int isspace(int c) {
    return c == ' ' || (c >= '\t' && c <= '\r');
}

long strtol(const char *restrict nptr, char **restrict endptr, int base) {
    long ret = 0;
    bool neg = false;
    const char *p = nptr;

    while (isspace(*p)) {
        p++;
    }

    if (*p == '-') {
        neg = true;
        p++;
    } else if (*p == '+') {
        p++;
    }

    if (base == 0) {
        if (*p == '0') {
            p++;
            if (*p == 'x' || *p == 'X') {
                base = 16;
                p++;
            } else {
                base = 8;
            }
        } else {
            base = 10;
        }
    }

    while (1) {
        int digit;
        if (*p >= '0' && *p <= '9') {
            digit = *p - '0';
        } else if (*p >= 'a' && *p <= 'z') {
            digit = *p - ('a' - 10);
        } else if (*p >= 'A' && *p <= 'Z') {
            digit = *p - ('A' - 10);
        } else {
            break;
        }

        if (digit >= base) {
            break;
        }

        ret = ret * base + digit;
        p++;
    }

    if (endptr) {
        *endptr = (char *)p;
    }

    return neg ? -ret : ret;
}

// puts without newline
static int puts_wo_nl(int (*putch)(int), const char *s) {
    if (!s) {
        s = "(null)";
    }
    const char *p = s;
    while (*p) {
        putch(*p++);
    }
    return p - s;
}

static int print_dec_int(int (*putch)(int), unsigned long num, bool is_signed, struct fmt_flags *flags) {
    if (is_signed && num == 0x8000000000000000UL) {
        // special case for 0x8000000000000000
        return puts_wo_nl(putch, "-9223372036854775808");
    }

    if (flags->prec == 0 && num == 0) {
        return 0;
    }

    bool neg = false;

    if (is_signed && (long)num < 0) {
        neg = true;
        num = -num;
    }

    char buf[20];
    int decdigits = 0;

    bool has_sign_char = is_signed && (neg || flags->sign || flags->spaceflag);

    do {
        buf[decdigits++] = num % 10 + '0';
        num /= 10;
    } while (num);

    if (flags->prec == -1 && flags->zeroflag) {
        flags->prec = flags->width;
    }

    int written = 0;

    for (int i = flags->width - __MAX(decdigits, flags->prec) - has_sign_char; i > 0; i--) {
        putch(' ');
        ++written;
    }

    if (has_sign_char) {
        putch(neg ? '-' : flags->sign ? '+' : ' ');
        ++written;
    }

    for (int i = decdigits; i < flags->prec - has_sign_char; i++) {
        putch('0');
        ++written;
    }

    for (int i = decdigits - 1; i >= 0; i--) {
        putch(buf[i]);
        ++written;
    }

    return written;
}

int vprintfmt(int (*putch)(int), const char *fmt, va_list vl) {
    static const char lowerxdigits[] = "0123456789abcdef";
    static const char upperxdigits[] = "0123456789ABCDEF";

    struct fmt_flags flags = {};

    int written = 0;

    for (; *fmt; fmt++) {
        if (flags.in_format) {
            if (*fmt == '#') {
                flags.sharpflag = true;
            } else if (*fmt == '0') {
                flags.zeroflag = true;
            } else if (*fmt == 'l' || *fmt == 'z' || *fmt == 't' || *fmt == 'j') {
                // l: long, z: size_t, t: ptrdiff_t, j: intmax_t
                flags.longflag = true;
            } else if (*fmt == '+') {
                flags.sign = true;
            } else if (*fmt == ' ') {
                flags.spaceflag = true;
            } else if (*fmt == '*') {
                flags.width = va_arg(vl, int);
            } else if (*fmt >= '1' && *fmt <= '9') {
                flags.width = strtol(fmt, (char **)&fmt, 10);
                fmt--;
            } else if (*fmt == '.') {
                fmt++;
                if (*fmt == '*') {
                    flags.prec = va_arg(vl, int);
                } else {
                    flags.prec = strtol(fmt, (char **)&fmt, 10);
                    fmt--;
                }
            } else if (*fmt == 'x' || *fmt == 'X' || *fmt == 'p') {
                bool is_long = *fmt == 'p' || flags.longflag;

                unsigned long num = is_long ? va_arg(vl, unsigned long) : va_arg(vl, unsigned int);

                if (flags.prec == 0 && num == 0 && *fmt != 'p') {
                    flags.in_format = false;
                    continue;
                }

                // 0x prefix for pointers, or, if # flag is set and non-zero
                bool prefix = *fmt == 'p' || (flags.sharpflag && num != 0);

                int hexdigits = 0;
                const char *xdigits = *fmt == 'X' ? upperxdigits : lowerxdigits;
                char buf[2 * sizeof(unsigned long)];

                do {
                    buf[hexdigits++] = xdigits[num & 0xf];
                    num >>= 4;
                } while (num);

                if (flags.prec == -1 && flags.zeroflag) {
                    flags.prec = flags.width - 2 * prefix;
                }

                for (int i = flags.width - 2 * prefix - __MAX(hexdigits, flags.prec); i > 0; i--) {
                    putch(' ');
                    ++written;
                }

                if (prefix) {
                    putch('0');
                    putch(*fmt == 'X' ? 'X' : 'x');
                    written += 2;
                }

                for (int i = hexdigits; i < flags.prec; i++) {
                    putch('0');
                    ++written;
                }

                for (int i = hexdigits - 1; i >= 0; i--) {
                    putch(buf[i]);
                    ++written;
                }

                flags.in_format = false;
            } else if (*fmt == 'd' || *fmt == 'i' || *fmt == 'u') {
                long num = flags.longflag ? va_arg(vl, long) : va_arg(vl, int);

                written += print_dec_int(putch, num, *fmt != 'u', &flags);
                flags.in_format = false;
            } else if (*fmt == 'n') {
                if (flags.longflag) {
                    long *n = va_arg(vl, long *);
                    *n = written;
                } else {
                    int *n = va_arg(vl, int *);
                    *n = written;
                }
                flags.in_format = false;
            } else if (*fmt == 's') {
                const char *s = va_arg(vl, const char *);
                written += puts_wo_nl(putch, s);
                flags.in_format = false;
            } else if (*fmt == 'c') {
                int ch = va_arg(vl, int);
                putch(ch);
                ++written;
                flags.in_format = false;
            } else if (*fmt == '%') {
                putch('%');
                ++written;
                flags.in_format = false;
            } else {
                putch(*fmt);
                ++written;
                flags.in_format = false;
            }
        } else if (*fmt == '%') {
            flags = (struct fmt_flags) {.in_format = true, .prec = -1};
        } else {
            putch(*fmt);
            ++written;
        }
    }

    return written;
}

int printf(const char* s, ...) {
    int res = 0;
    va_list vl;
    va_start(vl, s);
    res = vprintfmt(putc, s, vl);
    long syscall_ret, fd = 1;
    buffer[tail++] = '\0';
    asm volatile ("li a7, %1\n"
                  "mv a0, %2\n"
                  "mv a1, %3\n"
                  "mv a2, %4\n"
                  "ecall\n"
                  "mv %0, a0\n"
                  : "+r" (syscall_ret)
                  : "i" (SYS_WRITE), "r" (fd), "r" (&buffer), "r" (tail));
    tail = 0;
    va_end(vl);
    return res;
}
