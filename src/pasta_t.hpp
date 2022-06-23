// Copyright Supranational LLC
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0

#ifndef __PASTA_T_HPP__
#define __PASTA_T_HPP__

extern "C" {
# include "vect.h"
}

#ifndef NDEBUG
# include "bytes.h"
#endif

template<const vec256 MOD, const limb_t M0,
         const vec256 RR, const vec256 ONE> class pasta_t {
private:
    vec256 val;

    inline operator const limb_t*() const           { return val;    }
    inline operator limb_t*()                       { return val;    }
    inline limb_t& operator[](size_t i)             { return val[i]; }
    inline const limb_t& operator[](size_t i) const { return val[i]; }

public:
    static const size_t nbits = 255;
    typedef byte pow_t[256/8];

    inline pasta_t() {}
    inline pasta_t(const vec256 p)
    {   vec_copy(val, p, sizeof(val));   }

    inline void to_scalar(pow_t& scalar) const
    {   pasta_to_scalar(scalar, val, MOD, M0);   }

    static inline const pasta_t& one()
    {   return *reinterpret_cast<const pasta_t*>(ONE);   }

    inline pasta_t& to()
    {   pasta_mul(val, RR, val, MOD, M0);       return *this;   }
    inline pasta_t& from()
    {   pasta_from(val, val, MOD, M0);          return *this;   }

    inline void store(limb_t *p)
    {   vec_copy(p, val, sizeof(val));   }

    inline pasta_t& operator+=(const pasta_t& b)
    {   pasta_add(val, val, b, MOD);            return *this;   }
    friend inline pasta_t operator+(const pasta_t& a, const pasta_t& b)
    {
        pasta_t ret;
        pasta_add(ret, a, b, MOD);
        return ret;
    }

    inline pasta_t& operator<<=(unsigned l)
    {   pasta_lshift(val, val, l, MOD);         return *this;   }
    friend inline pasta_t operator<<(const pasta_t& a, unsigned l)
    {
        pasta_t ret;
        pasta_lshift(ret, a, l, MOD);
        return ret;
    }

    inline pasta_t& operator>>=(unsigned r)
    {   pasta_rshift(val, val, r, MOD);         return *this;   }
    friend inline pasta_t operator>>(pasta_t a, unsigned r)
    {
        pasta_t ret;
        pasta_rshift(ret, a, r, MOD);
        return ret;
    }

    inline pasta_t& operator-=(const pasta_t& b)
    {   pasta_sub(val, val, b, MOD);            return *this;   }
    friend inline pasta_t operator-(const pasta_t& a, const pasta_t& b)
    {
        pasta_t ret;
        pasta_sub(ret, a, b, MOD);
        return ret;
    }

    inline pasta_t& cneg(bool flag)
    {   pasta_cneg(val, val, flag, MOD);        return *this;   }
    friend inline pasta_t cneg(const pasta_t& a, bool flag)
    {
        pasta_t ret;
        pasta_cneg(ret, a, flag, MOD);
        return ret;
    }
    friend inline pasta_t operator-(const pasta_t& a)
    {
        pasta_t ret;
        pasta_cneg(ret, a, true, MOD);
        return ret;
    }

    inline pasta_t& operator*=(const pasta_t& a)
    {
        if (this == &a) pasta_sqr(val, val, MOD, M0);
        else            pasta_mul(val, val, a, MOD, M0);
        return *this;
    }
    friend inline pasta_t operator*(const pasta_t& a, const pasta_t& b)
    {
        pasta_t ret;
        if (&a == &b)   pasta_sqr(ret, a, MOD, M0);
        else            pasta_mul(ret, a, b, MOD, M0);
        return ret;
    }

    // simplified exponentiation, but mind the ^ operator's precedence!
    friend inline pasta_t operator^(const pasta_t& a, unsigned p)
    {
        if (p < 2) {
            abort();
        } else if (p == 2) {
            pasta_t ret;
            pasta_sqr(ret, a, MOD, M0);
            return ret;
        } else {
            pasta_t ret;
            pasta_sqr(ret, a, MOD, M0);
            for (p -= 2; p--;)
                pasta_mul(ret, ret, a, MOD, M0);
            return ret;
        }
    }
    inline pasta_t& operator^=(unsigned p)
    {
        if (p < 2) {
            abort();
        } else if (p == 2) {
            pasta_sqr(val, val, MOD, M0);
            return *this;
        }
        return *this = *this^p;
    }
    inline pasta_t operator()(unsigned p)
    {   return *this^p;   }
    friend inline pasta_t sqr(const pasta_t& a)
    {   return a^2;   }

    inline bool is_zero() const
    {   return vec_is_zero(val, sizeof(val));   }

    inline void zero()
    {   vec_zero(val, sizeof(val));   }

    pasta_t reciprocal() const
    {
        pasta_t ret;
        pasta_reciprocal(ret.val, val, MOD, M0);
        return ret;
    }
    friend inline pasta_t operator/(unsigned one, const pasta_t& a)
    {
        if (one == 1)
            return a.reciprocal();
        abort();
    }
    friend inline pasta_t operator/(const pasta_t& a, const pasta_t& b)
    {   return a * b.reciprocal();   }
    inline pasta_t& operator/=(const pasta_t& a)
    {   return *this *= a.reciprocal();   }

#ifndef NDEBUG
    inline pasta_t(const char *hexascii)
    {   limbs_from_hexascii(val, sizeof(val), hexascii); to();   }

    friend inline bool operator==(const pasta_t& a, const pasta_t& b)
    {   return vec_is_equal(a, b, sizeof(vec256));   }
    friend inline bool operator!=(const pasta_t& a, const pasta_t& b)
    {   return !vec_is_equal(a, b, sizeof(vec256));   }

# if defined(_GLIBCXX_IOSTREAM) || defined(_IOSTREAM_) // non-standard
    friend std::ostream& operator<<(std::ostream& os, const pasta_t& obj)
    {
        unsigned char be[sizeof(obj)];
        char buf[2+2*sizeof(obj)+1], *str = buf;

        be_bytes_from_limbs(be, pasta_t{obj}.from(), sizeof(obj));

        *str++ = '0', *str++ = 'x';
        for (size_t i = 0; i < sizeof(obj); i++)
            *str++ = hex_from_nibble(be[i]>>4), *str++ = hex_from_nibble(be[i]);
	*str = '\0';

        return os << buf;
    }
# endif
#endif
};

#include "consts.c"
typedef pasta_t<Vesta_P, 0x8c46eb20ffffffff, Vesta_RR, Vesta_one> vesta_t;
typedef pasta_t<Pallas_P, 0x992d30ecffffffff, Pallas_RR, Pallas_one> pallas_t;

#endif
