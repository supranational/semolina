/*
 * Copyright Supranational LLC
 * Licensed under the Apache License, Version 2.0, see LICENSE for details.
 * SPDX-License-Identifier: Apache-2.0
 */

#include "consts.c"
#include "bytes.h"

typedef vec256 xy256[2];

#if defined(__ADX__) && !defined(__PASTA_PORTABLE__)
# define sqr_n_mul_mont_pasta sqrx_n_mul_mont_pasta
#endif
void sqr_n_mul_mont_pasta(vec256 ret, const vec256 a, size_t n,
                                      const vec256 b,
                                      const vec256 p, limb_t p0);

static const vec256 zero = { 0 };

/* Pallas:0x40000000000000000000000000000000224698fc094cf91b992d30ed00000001 */

static inline void to_pallas(vec256 ret, const vec256 a)
{   mul_mont_pasta(ret, Pallas_RR, a, Pallas_P, Pallas_p0);   }

static inline void add_pallas(vec256 ret, const vec256 a, const vec256 b)
{   pasta_add(ret, a, b, Pallas_P);   }

static inline void sub_pallas(vec256 ret, const vec256 a, const vec256 b)
{   pasta_sub(ret, a, b, Pallas_P);   }

static inline void mul_pallas(vec256 ret, const vec256 a, const vec256 b)
{   mul_mont_pasta(ret, a, b, Pallas_P, Pallas_p0);   }

static inline void sqr_pallas(vec256 ret, const vec256 a)
{   sqr_mont_pasta(ret, a, Pallas_P, Pallas_p0);   }

static inline void sqr_n_mul_pallas(vec256 ret, const vec256 a, size_t n,
                                                const vec256 b)
{   sqr_n_mul_mont_pasta(ret, a, n, b, Pallas_P, Pallas_p0);   }

static inline void from_pallas(vec256 ret, const vec256 a)
{   from_mont_pasta(ret, a, Pallas_P, Pallas_p0);   }

/* Vesta:0x40000000000000000000000000000000224698fc0994a8dd8c46eb2100000001 */

static inline void to_vesta(vec256 ret, const vec256 a)
{   mul_mont_pasta(ret, Vesta_RR, a, Vesta_P, Vesta_p0);   }

static inline void add_vesta(vec256 ret, const vec256 a, const vec256 b)
{   pasta_add(ret, a, b, Vesta_P);   }

static inline void sub_vesta(vec256 ret, const vec256 a, const vec256 b)
{   pasta_sub(ret, a, b, Vesta_P);   }

static inline void mul_vesta(vec256 ret, const vec256 a, const vec256 b)
{   mul_mont_pasta(ret, a, b, Vesta_P, Vesta_p0);   }

static inline void sqr_vesta(vec256 ret, const vec256 a)
{   sqr_mont_pasta(ret, a, Vesta_P, Vesta_p0);   }

static inline void sqr_n_mul_vesta(vec256 ret, const vec256 a, size_t n,
                                               const vec256 b)
{   sqr_n_mul_mont_pasta(ret, a, n, b, Vesta_P, Vesta_p0);   }

static inline void from_vesta(vec256 ret, const vec256 a)
{   from_mont_pasta(ret, a, Vesta_P, Vesta_p0);   }

/*
 * With https://github.com/zcash/pasta/blob/master/addchain_5inv.py as
 * template...
 */
static void pnrt_pallas(vec256 ret, const vec256 p1)
{
    vec256 p11, p101, p111, p1001, p1111, p110011x4, p110011x8;

    /* 0x333333333333333333333333333333334e9ee0c9a10a60e2e0f0f3f0cccccccd */
#define p10 ret
#define p110 p110011x4
    sqr_pallas(p10, p1);
    mul_pallas(p11, p10, p1);
    mul_pallas(p101, p10, p11);
    sqr_pallas(p110, p11);
    mul_pallas(p111, p110, p1);
    mul_pallas(p1001, p111, p10);
    mul_pallas(p1111, p1001, p110);
    sqr_n_mul_pallas(p110011x4, p110, 3, p11);
    sqr_n_mul_pallas(p110011x4, p110011x4, 8, p110011x4);
    sqr_n_mul_pallas(p110011x8, p110011x4, 16, p110011x4);
#undef p10
#undef p110

    sqr_n_mul_pallas(ret, p110011x8, 32, p110011x8);
    sqr_n_mul_pallas(ret, ret, 64, ret);
    sqr_n_mul_pallas(ret, ret, 5, p1001);
    sqr_n_mul_pallas(ret, ret, 8, p111);
    sqr_n_mul_pallas(ret, ret, 4, p1);
    sqr_n_mul_pallas(ret, ret, 2, p110011x4);
    sqr_n_mul_pallas(ret, ret, 7, p11);
    sqr_n_mul_pallas(ret, ret, 6, p1001);
    sqr_n_mul_pallas(ret, ret, 3, p101);
    sqr_n_mul_pallas(ret, ret, 5, p1);
    sqr_n_mul_pallas(ret, ret, 7, p101);
    sqr_n_mul_pallas(ret, ret, 4, p11);
    sqr_n_mul_pallas(ret, ret, 8, p111);
    sqr_n_mul_pallas(ret, ret, 4, p1);
    sqr_n_mul_pallas(ret, ret, 4, p111);
    sqr_n_mul_pallas(ret, ret, 9, p1111);
    sqr_n_mul_pallas(ret, ret, 8, p1111);
    sqr_n_mul_pallas(ret, ret, 6, p1111);
    sqr_n_mul_pallas(ret, ret, 2, p11);
    sqr_n_mul_pallas(ret, ret, 34, p110011x8);
    sqr_n_mul_pallas(ret, ret, 2, p1);

    add_pallas(ret, ret, zero);
}

void minroot_pallas(xy256 xy_d, const xy256 xy0, size_t D)
{
    vec256 xi, yi, ti, i = { 0 };

    to_pallas(xi, xy0[0]);
    to_pallas(yi, xy0[1]);

    while(D--) {
        add_pallas(i, i, Pallas_one);
        add_pallas(ti, xi, yi);
        add_pallas(yi, xi, i);
        pnrt_pallas(xi, ti);
    }

    from_pallas(xy_d[0], xi);
    from_pallas(xy_d[1], yi);
}

int minroot_verify_pallas(const xy256 xy_d, const xy256 xy0, size_t D)
{
    vec256 xi, yi, ti, i = { D+1 };

    to_pallas(xi, xy_d[0]);
    to_pallas(yi, xy_d[1]);
    to_pallas(i, i);

    while(D--) {
        sqr_n_mul_pallas(ti, xi, 2, xi);
        add_pallas(ti, ti, zero);
        sub_pallas(i, i, Pallas_one);
        sub_pallas(xi, yi, i);
        sub_pallas(yi, ti, xi);
    }

    to_pallas(ti, xy0[0]);
    to_pallas(i,  xy0[1]);

    return (int)(vec_is_equal(xi, ti, sizeof(xi)) &
                 vec_is_equal(yi, i, sizeof(yi)));
}

int minroot_partial_verify_pallas(const unsigned char xy_d[64],
                                  const unsigned char xy0[64],
                                  size_t D, size_t E)
{
    vec256 xi, yi, ti, i = { D+1 };

    limbs_from_be_bytes(xi, xy_d, 32);
    limbs_from_be_bytes(yi, xy_d+32, 32);
    to_pallas(xi, xi);
    to_pallas(yi, yi);
    to_pallas(i, i);

    while (D-- >= E) { /* E is assumed to be non-zero */
        sqr_n_mul_pallas(ti, xi, 2, xi);
        add_pallas(ti, ti, zero);
        sub_pallas(i, i, Pallas_one);
        sub_pallas(xi, yi, i);
        sub_pallas(yi, ti, xi);
    }

    limbs_from_be_bytes(ti, xy0, 32);
    limbs_from_be_bytes(i,  xy0+32, 32);
    to_pallas(ti, ti);
    to_pallas(i,  i);

    return (int)(vec_is_equal(xi, ti, sizeof(xi)) &
                 vec_is_equal(yi, i, sizeof(yi)));
}

static void pnrt_vesta(vec256 ret, const vec256 q1)
{
    vec256 q11, q101, q111, q1001, q1111, q110011x4, q110011x8;

    /* 0x333333333333333333333333333333334e9ee0c9a143ba4ad69f2280cccccccd */
#define q10 ret
#define q110 q110011x4
    sqr_vesta(q10, q1);
    mul_vesta(q11, q10, q1);
    mul_vesta(q101, q10, q11);
    sqr_vesta(q110, q11);
    mul_vesta(q111, q110, q1);
    mul_vesta(q1001, q111, q10);
    mul_vesta(q1111, q1001, q110);
    sqr_n_mul_vesta(q110011x4, q110, 3, q11);
    sqr_n_mul_vesta(q110011x4, q110011x4, 8, q110011x4);
    sqr_n_mul_vesta(q110011x8, q110011x4, 16, q110011x4);
#undef q10
#undef q110

    sqr_n_mul_vesta(ret, q110011x8, 32, q110011x8);
    sqr_n_mul_vesta(ret, ret, 64, ret);
    sqr_n_mul_vesta(ret, ret, 5, q1001);
    sqr_n_mul_vesta(ret, ret, 8, q111);
    sqr_n_mul_vesta(ret, ret, 4, q1);
    sqr_n_mul_vesta(ret, ret, 2, q110011x4);
    sqr_n_mul_vesta(ret, ret, 7, q11);
    sqr_n_mul_vesta(ret, ret, 6, q1001);
    sqr_n_mul_vesta(ret, ret, 3, q101);
    sqr_n_mul_vesta(ret, ret, 7, q101);
    sqr_n_mul_vesta(ret, ret, 7, q111);
    sqr_n_mul_vesta(ret, ret, 4, q111);
    sqr_n_mul_vesta(ret, ret, 5, q1001);
    sqr_n_mul_vesta(ret, ret, 5, q101);
    sqr_n_mul_vesta(ret, ret, 5, q111);
    sqr_n_mul_vesta(ret, ret, 9, q111);
    sqr_n_mul_vesta(ret, ret, 2, q110011x4);
    sqr_n_mul_vesta(ret, ret, 4, q1001);
    sqr_n_mul_vesta(ret, ret, 6, q101);
    sqr_n_mul_vesta(ret, ret, 37, q110011x8);
    sqr_n_mul_vesta(ret, ret, 2, q1);

    add_vesta(ret, ret, zero);
}

void minroot_vesta(xy256 xy_d, const xy256 xy0, size_t D)
{
    vec256 xi, yi, ti, i = { 0 };

    to_vesta(xi, xy0[0]);
    to_vesta(yi, xy0[1]);

    while(D--) {
        add_vesta(ti, xi, yi);
        add_vesta(i, i, Vesta_one);
        add_vesta(yi, xi, i);
        pnrt_vesta(xi, ti);
    }

    from_vesta(xy_d[0], xi);
    from_vesta(xy_d[1], yi);
}

int minroot_verify_vesta(const xy256 xy_d, const xy256 xy0, size_t D)
{
    vec256 xi, yi, ti, i = { D+1 };

    to_vesta(xi, xy_d[0]);
    to_vesta(yi, xy_d[1]);
    to_vesta(i, i);

    while(D--) {
        sqr_n_mul_vesta(ti, xi, 2, xi);
        add_vesta(ti, ti, zero);
        sub_vesta(i, i, Vesta_one);
        sub_vesta(xi, yi, i);
        sub_vesta(yi, ti, xi);
    }

    to_vesta(ti, xy0[0]);
    to_vesta(i,  xy0[1]);

    return (int)(vec_is_equal(xi, ti, sizeof(xi)) &
                 vec_is_equal(yi, i, sizeof(yi)));
}

int minroot_partial_verify_vesta(const unsigned char xy_d[64],
                                 const unsigned char xy0[64],
                                 size_t D, size_t E)
{
    vec256 xi, yi, ti, i = { D+1 };

    limbs_from_be_bytes(xi, xy_d, 32);
    limbs_from_be_bytes(yi, xy_d+32, 32);
    to_vesta(xi, xi);
    to_vesta(yi, yi);
    to_vesta(i, i);

    while (D-- >= E) { /* E is assumed to be non-zero */
        sqr_n_mul_vesta(ti, xi, 2, xi);
        add_vesta(ti, ti, zero);
        sub_vesta(i, i, Vesta_one);
        sub_vesta(xi, yi, i);
        sub_vesta(yi, ti, xi);
    }

    limbs_from_be_bytes(ti, xy0, 32);
    limbs_from_be_bytes(i,  xy0+32, 32);
    to_vesta(ti, ti);
    to_vesta(i,  i);

    return (int)(vec_is_equal(xi, ti, sizeof(xi)) &
                 vec_is_equal(yi, i, sizeof(yi)));
}

#ifdef SELFTEST
#include <stdio.h>

#ifndef NDEBUG
# include <stdlib.h>
# include <sys/types.h>
# include <sys/stat.h>
# include <fcntl.h>
# include <unistd.h>

static void print_vec256(const vec256 a)
{
    int i;

    printf("0x");
    for (i=4; i;)
        printf("%016llx", a[--i]);
    printf("\n");
}
#endif

static unsigned long long rdtsc()
{
#if defined(__x86_64__)
    unsigned int lo, hi;

    asm volatile("rdtsc": "=a"(lo), "=d"(hi) :: "ecx");

    return (unsigned long long)hi<<32 | lo;
#elif defined(__aarch64__)
    unsigned long long ret;

    asm volatile("mrs   %0, CNTVCT_EL0":"=r"(ret));

    return ret;
#endif
}

int main()
{
    static const vec256 one = {
        TO_LIMB_T(0x34786d38fffffffd), TO_LIMB_T(0x992c350be41914ad),
        TO_LIMB_T(0xffffffffffffffff), TO_LIMB_T(0x3fffffffffffffff)
    };
    static const vec256 two = {
        TO_LIMB_T(0xcfc3a984fffffff9), TO_LIMB_T(0x1011d11bbee5303e),
        TO_LIMB_T(0xffffffffffffffff), TO_LIMB_T(0x3fffffffffffffff)
    };
    static const vec256 x = {
        TO_LIMB_T(0xffffffffffffffff), TO_LIMB_T(0xffffffffffffffff),
        TO_LIMB_T(0xffffffffffffffff), TO_LIMB_T(0x3fffffffffffffff)
    };
    static const vec256 y = {
        TO_LIMB_T(0xffffffffffffffff), TO_LIMB_T(0xffffffffffffffff),
        TO_LIMB_T(0xffffffffffffffff), TO_LIMB_T(0x3ffffffffffffffe)
    };
    unsigned long long start;
    vec256 ret;

    sqr_n_mul_pallas(ret, two, 1000000, two);
    start = rdtsc();
    sqr_n_mul_pallas(ret, two, 1000, two);
    printf("%g\n", (rdtsc()-start)/1000.0);

    pnrt_pallas(ret, two);
    start = rdtsc();
    pnrt_pallas(ret, two);
    printf("%d\n", (int)(rdtsc()-start));

    xy256 a, b;

    minroot_pallas(a, b, 200);
    start = rdtsc();
    minroot_pallas(a, b, 200);
    printf("%g\n", (rdtsc()-start)/200.0);

#ifndef NDEBUG
    int fd = open("/dev/urandom", O_RDONLY), i;

    printf("Random Pallas MinRoot\n");
    for (i=0; i<2500; i++) {
        ssize_t n = read(fd, b, sizeof(b));
        minroot_pallas(a, b, 100);
        if (!minroot_verify_pallas(a, b, 100)) {
            print_vec256(b[0]);
            print_vec256(b[1]);
            abort();
        }
    }

    printf("Random Vesta MinRoot\n");
    for (i=0; i<2500; i++) {
        ssize_t n = read(fd, b, sizeof(b));
        minroot_vesta(a, b, 100);
        if (!minroot_verify_vesta(a, b, 100)) {
            print_vec256(b[0]);
            print_vec256(b[1]);
            abort();
        }
    }

#endif
}
#endif
