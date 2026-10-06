/*
 * Copyright Supranational LLC
 * Licensed under the Apache License, Version 2.0 or the MIT license,
 * at your option, see LICENSE-APACHE and LICENSE-MIT for details.
 * SPDX-License-Identifier: MIT OR Apache-2.0
 */

#include "consts.c"
#include "bytes.h"

void pasta_from_scalar(vec256 ret, const pow256 a, const vec256 p, limb_t n0)
{
    const union {
        long one;
        char little;
    } is_endian = { 1 };

    if ((uptr_t)ret == (uptr_t)a && is_endian.little) {
        pasta_mul(ret, (byte)p[1] == (byte)Pallas_P[1] ? Pallas_RR
                                                       : Vesta_RR,
                            (const limb_t *)a, p, n0);
    } else {
        vec256 out;
        limbs_from_le_bytes(out, a, 32);
        pasta_mul(ret, (byte)p[1] == (byte)Pallas_P[1] ? Pallas_RR
                                                       : Vesta_RR,
                            out, p, n0);
        vec_zero(out, sizeof(out));
    }
}

void pasta_to_scalar(pow256 ret, const vec256 a, const vec256 p, limb_t n0)
{
    const union {
        long one;
        char little;
    } is_endian = { 1 };

    if ((size_t)ret % sizeof(limb_t) == 0 && is_endian.little) {
        pasta_from((limb_t *)ret, a, p, n0);
    } else {
        vec256 out;
        pasta_from(out, a, p, n0);
        le_bytes_from_limbs(ret, out, 32);
        vec_zero(out, sizeof(out));
    }
}

#include "recip.c"
