#ifndef __STDINT_H__
#define __STDINT_H__

typedef signed char int8_t;
typedef short int16_t;
typedef int int32_t;
typedef long long int64_t;

typedef int8_t int_fast8_t;
typedef int16_t int_fast16_t;
typedef int32_t int_fast32_t;
typedef int64_t int_fast64_t;

typedef int8_t int_least8_t;
typedef int16_t int_least16_t;
typedef int32_t int_least32_t;
typedef int64_t int_least64_t;

typedef int64_t intmax_t;

typedef int64_t intptr_t;

typedef unsigned char uint8_t;
typedef unsigned short uint16_t;
typedef unsigned int uint32_t;
typedef unsigned long long uint64_t;

typedef uint8_t uint_fast8_t;
typedef uint16_t uint_fast16_t;
typedef uint32_t uint_fast32_t;
typedef uint64_t uint_fast64_t;

typedef uint8_t uint_least8_t;
typedef uint16_t uint_least16_t;
typedef uint32_t uint_least32_t;
typedef uint64_t uint_least64_t;

typedef uint64_t uintmax_t;

typedef uint64_t uintptr_t;

#define INT8_MIN ((int8_t)0x80)
#define INT16_MIN ((int16_t)0x8000)
#define INT32_MIN ((int32_t)0x80000000)
#define INT64_MIN ((int64_t)0x8000000000000000)

#define INT_FAST8_MIN ((int_fast8_t)INT8_MIN)
#define INT_FAST16_MIN ((int_fast16_t)INT16_MIN)
#define INT_FAST32_MIN ((int_fast32_t)INT32_MIN)
#define INT_FAST64_MIN ((int_fast64_t)INT64_MIN)

#define INT_LEAST8_MIN ((int_least8_t)INT8_MIN)
#define INT_LEAST16_MIN ((int_least16_t)INT16_MIN)
#define INT_LEAST32_MIN ((int_least32_t)INT32_MIN)
#define INT_LEAST64_MIN ((int_least64_t)INT64_MIN)

#define INTPTR_MIN ((intptr_t)INT64_MIN)

#define INTMAX_MIN ((intmax_t)INT64_MIN)

#define INT8_MAX ((int8_t)0x7f)
#define INT16_MAX ((int16_t)0x7fff)
#define INT32_MAX ((int32_t)0x7fffffff)
#define INT64_MAX ((int64_t)0x7fffffffffffffff)

#define INT_FAST8_MAX ((int_fast8_t)INT8_MAX)
#define INT_FAST16_MAX ((int_fast16_t)INT16_MAX)
#define INT_FAST32_MAX ((int_fast32_t)INT32_MAX)
#define INT_FAST64_MAX ((int_fast64_t)INT64_MAX)

#define INT_LEAST8_MAX ((int_least8_t)INT8_MAX)
#define INT_LEAST16_MAX ((int_least16_t)INT16_MAX)
#define INT_LEAST32_MAX ((int_least32_t)INT32_MAX)
#define INT_LEAST64_MAX ((int_least64_t)INT64_MAX)

#define INTPTR_MAX ((intptr_t)INT64_MAX)

#define INTMAX_MAX ((intmax_t)INT64_MAX)

#define UINT8_MAX ((uint8_t)0xff)
#define UINT16_MAX ((uint16_t)0xffff)
#define UINT32_MAX ((uint32_t)0xffffffff)
#define UINT64_MAX ((uint64_t)0xffffffffffffffff)

#define UINT_FAST8_MAX ((uint_fast8_t)UINT8_MAX)
#define UINT_FAST16_MAX ((uint_fast16_t)UINT16_MAX)
#define UINT_FAST32_MAX ((uint_fast32_t)UINT32_MAX)
#define UINT_FAST64_MAX ((uint_fast64_t)UINT64_MAX)

#define UINT_LEAST8_MAX ((uint_least8_t)UINT8_MAX)
#define UINT_LEAST16_MAX ((uint_least16_t)UINT16_MAX)
#define UINT_LEAST32_MAX ((uint_least32_t)UINT32_MAX)
#define UINT_LEAST64_MAX ((uint_least64_t)UINT64_MAX)

#define UINTPTR_MAX ((uintptr_t)UINT64_MAX)

#define UINTMAX_MAX ((uintmax_t)UINT64_MAX)

#define INT8_C(c) ((int8_t)c)
#define INT16_C(c) ((int16_t)c)
#define INT32_C(c) ((int32_t)c)
#define INT64_C(c) ((int64_t)c##LL)

#define INTMAX_C(c) ((intmax_t)INT64_C(c))

#define UINT8_C(c) ((uint8_t)c)
#define UINT16_C(c) ((uint16_t)c)
#define UINT32_C(c) ((uint32_t)c)
#define UINT64_C(c) ((uint64_t)c##ULL)

#define UINTMAX_C(c) ((uintmax_t)UINT64_C(c))

#endif
