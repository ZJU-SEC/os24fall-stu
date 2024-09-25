// from musl (https://elixir.bootlin.com/musl/v1.2.5/source/src/prng/rand.c)

#include "stdint.h"
#include "stdlib.h"

static uint64_t seed;

void srand(unsigned s) {
    seed = s - 1;
}

int rand(void) {
    seed = 6364136223846793005ULL * seed + 1;
    return seed >> 33;
}
