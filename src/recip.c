/*
 * Copyright Supranational LLC
 * Licensed under the Apache License, Version 2.0 or the MIT license,
 * at your option, see LICENSE-APACHE and LICENSE-MIT for details.
 * SPDX-License-Identifier: MIT OR Apache-2.0
 */

#include "vect.h"

void pasta_reciprocal(vec256 out, const vec256 inp, const vec256 mod, limb_t m0)
{
    static const vec256 Pallasx2 = { /* left-aligned value of the modulus */
        TO_LIMB_T(0x325a61da00000002), TO_LIMB_T(0x448d31f81299f237),
        TO_LIMB_T(0x0000000000000000), TO_LIMB_T(0x8000000000000000)
    };
    static const vec256 Vestax2 = { /* left-aligned value of the modulus */
        TO_LIMB_T(0x188dd64200000002), TO_LIMB_T(0x448d31f8132951bb),
        TO_LIMB_T(0x0000000000000000), TO_LIMB_T(0x8000000000000000)
    };
    vec512 temp;

    if ((byte)mod[1] == (byte)Pallas_P[1]) {
        ct_inverse_pasta(temp, inp, mod, Pallasx2);
        pasta_redc(out, temp, mod, m0);
        pasta_mul(out, Pallas_RR, out, mod, m0);
    } else {
        ct_inverse_pasta(temp, inp, mod, Vestax2);
        pasta_redc(out, temp, mod, m0);
        pasta_mul(out, Vesta_RR, out, mod, m0);
    }
}
