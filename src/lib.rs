// Copyright Supranational LLC
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0

#![allow(dead_code)]

use core::fmt;
use core::mem::MaybeUninit;

#[derive(Default, Copy, Clone)]
#[repr(transparent)]
pub struct Scalar([u8; 32usize]);

impl fmt::Debug for Scalar {
    fn fmt(&self, f: &mut fmt::Formatter) -> fmt::Result {
        write!(f, "0x")?;
        for &b in self.0.iter().rev() {
            write!(f, "{:02x}", b)?;
        }
        Ok(())
    }
}
impl fmt::Display for Scalar {
    fn fmt(&self, f: &mut fmt::Formatter) -> fmt::Result {
        write!(f, "{:?}", self)
    }
}

impl Scalar {
    fn num_bits(&self) -> usize {
        let mut i = 32usize;
        while i > 0 {
            i -= 1;
            if self.0[i] != 0 {
                return (i + 1) * 8 - self.0[i].leading_zeros() as usize;
            }
        }
        0usize
    }

    fn is_bit_set(&self, i: usize) -> bool {
        (self.0[i / 8] >> (i % 8)) & 1 != 0
    }
}

type Pasta = [u64; 4usize];

extern "C" {
    fn pasta_from_scalar(
        out: *mut Pasta,
        a: *const Scalar,
        p: *const Pasta,
        p0: u64,
    );
    fn pasta_to_scalar(
        out: *mut Scalar,
        a: *const Pasta,
        p: *const Pasta,
        p0: u64,
    );
    fn pasta_mul(
        out: *mut Pasta,
        a: *const Pasta,
        b: *const Pasta,
        p: *const Pasta,
        p0: u64,
    );
    fn pasta_sqr(out: *mut Pasta, a: *const Pasta, p: *const Pasta, p0: u64);
    fn pasta_from(out: *mut Pasta, a: *const Pasta, p: *const Pasta, p0: u64);
    fn pasta_to(out: *mut Pasta, a: *const Pasta, p: *const Pasta, p0: u64);
    fn pasta_add(
        out: *mut Pasta,
        a: *const Pasta,
        b: *const Pasta,
        p: *const Pasta,
    );
    fn pasta_sub(
        out: *mut Pasta,
        a: *const Pasta,
        b: *const Pasta,
        p: *const Pasta,
    );
    fn pasta_lshift(
        out: *mut Pasta,
        a: *const Pasta,
        count: usize,
        p: *const Pasta,
    );
    fn pasta_rshift(
        out: *mut Pasta,
        a: *const Pasta,
        count: usize,
        p: *const Pasta,
    );
    fn pasta_cneg(
        out: *mut Pasta,
        a: *const Pasta,
        flag: bool,
        p: *const Pasta,
    );
    fn pasta_reciprocal(
        out: *mut Pasta,
        a: *const Pasta,
        p: *const Pasta,
        p0: u64,
    );
}

macro_rules! pasta_impl {
    (
        $field:ident,
        $mod:ident,
        $m0:literal,
    ) => {
        #[derive(Default, Copy, Clone)]
        #[repr(transparent)]
        pub struct $field(Pasta);

        impl $field {
            pub fn reciprocal(&self) -> Self {
                let mut out = MaybeUninit::<Self>::uninit();
                unsafe {
                    pasta_reciprocal(
                        &mut (*out.as_mut_ptr()).0,
                        &self.0,
                        &$mod,
                        $m0,
                    );
                    out.assume_init()
                }
            }

            pub fn pow(&self, p: Scalar) -> Self {
                let mut pow_bits = p.num_bits() - 1;
                let mut out = *self;
                while pow_bits != 0 {
                    pow_bits -= 1;
                    unsafe { pasta_sqr(&mut out.0, &out.0, &$mod, $m0) };
                    if p.is_bit_set(pow_bits) {
                        unsafe {
                            pasta_mul(&mut out.0, &out.0, &self.0, &$mod, $m0)
                        };
                    }
                }
                out
            }
        }

        impl core::convert::From<Scalar> for $field {
            fn from(s: Scalar) -> Self {
                let mut out = MaybeUninit::<Self>::uninit();
                unsafe {
                    pasta_from_scalar(
                        &mut (*out.as_mut_ptr()).0,
                        &s,
                        &$mod,
                        $m0,
                    );
                    out.assume_init()
                }
            }
        }
        impl core::convert::From<$field> for Scalar {
            fn from(v: $field) -> Self {
                let mut out = MaybeUninit::<Self>::uninit();
                unsafe {
                    pasta_to_scalar(out.as_mut_ptr(), &v.0, &$mod, $m0);
                    out.assume_init()
                }
            }
        }

        impl core::ops::Mul for $field {
            type Output = Self;

            fn mul(self, other: Self) -> Self {
                let mut out = MaybeUninit::<Self>::uninit();
                unsafe {
                    pasta_mul(
                        &mut (*out.as_mut_ptr()).0,
                        &self.0,
                        &other.0,
                        &$mod,
                        $m0,
                    );
                    out.assume_init()
                }
            }
        }
        impl core::ops::MulAssign for $field {
            fn mul_assign(&mut self, other: Self) {
                unsafe { pasta_mul(&mut self.0, &self.0, &other.0, &$mod, $m0) }
            }
        }

        impl core::ops::Add for $field {
            type Output = Self;

            fn add(self, other: Self) -> Self {
                let mut out = MaybeUninit::<Self>::uninit();
                unsafe {
                    pasta_add(
                        &mut (*out.as_mut_ptr()).0,
                        &self.0,
                        &other.0,
                        &$mod,
                    );
                    out.assume_init()
                }
            }
        }
        impl core::ops::AddAssign for $field {
            fn add_assign(&mut self, other: Self) {
                unsafe { pasta_add(&mut self.0, &self.0, &other.0, &$mod) }
            }
        }
        impl core::ops::AddAssign<usize> for $field {
            fn add_assign(&mut self, other: usize) {
                let mut i = $field([other as u64, 0, 0, 0]);
                unsafe {
                    pasta_to(&mut i.0, &i.0, &$mod, $m0);
                    pasta_add(&mut self.0, &self.0, &i.0, &$mod)
                }
            }
        }

        impl core::ops::Sub for $field {
            type Output = Self;

            fn sub(self, other: Self) -> Self {
                let mut out = MaybeUninit::<Self>::uninit();
                unsafe {
                    pasta_sub(
                        &mut (*out.as_mut_ptr()).0,
                        &self.0,
                        &other.0,
                        &$mod,
                    );
                    out.assume_init()
                }
            }
        }
        impl core::ops::SubAssign for $field {
            fn sub_assign(&mut self, other: Self) {
                unsafe { pasta_sub(&mut self.0, &self.0, &other.0, &$mod) }
            }
        }

        impl core::ops::Shl<usize> for $field {
            type Output = Self;

            fn shl(self, count: usize) -> Self {
                let mut out = MaybeUninit::<Self>::uninit();
                unsafe {
                    pasta_lshift(
                        &mut (*out.as_mut_ptr()).0,
                        &self.0,
                        count,
                        &$mod,
                    );
                    out.assume_init()
                }
            }
        }
        impl core::ops::ShlAssign<usize> for $field {
            fn shl_assign(&mut self, count: usize) {
                unsafe { pasta_lshift(&mut self.0, &self.0, count, &$mod) }
            }
        }

        impl core::ops::Shr<usize> for $field {
            type Output = Self;

            fn shr(self, count: usize) -> Self {
                let mut out = MaybeUninit::<Self>::uninit();
                unsafe {
                    pasta_rshift(
                        &mut (*out.as_mut_ptr()).0,
                        &self.0,
                        count,
                        &$mod,
                    );
                    out.assume_init()
                }
            }
        }
        impl core::ops::ShrAssign<usize> for $field {
            fn shr_assign(&mut self, count: usize) {
                unsafe { pasta_rshift(&mut self.0, &self.0, count, &$mod) }
            }
        }

        impl core::ops::Neg for $field {
            type Output = Self;

            fn neg(self) -> Self {
                let mut out = MaybeUninit::<Self>::uninit();
                unsafe {
                    pasta_cneg(
                        &mut (*out.as_mut_ptr()).0,
                        &self.0,
                        true,
                        &$mod,
                    );
                    out.assume_init()
                }
            }
        }

        impl fmt::Debug for $field {
            fn fmt(&self, f: &mut fmt::Formatter) -> fmt::Result {
                let mut tmp = MaybeUninit::<Scalar>::uninit();
                write!(f, "{:?}", unsafe {
                    pasta_to_scalar(tmp.as_mut_ptr(), &self.0, &$mod, $m0);
                    tmp.assume_init()
                })
            }
        }
        impl fmt::Display for $field {
            fn fmt(&self, f: &mut fmt::Formatter) -> fmt::Result {
                write!(f, "{:?}", self)
            }
        }
    };
}

const PALLAS_P: Pasta = [
    0x992d30ed_00000001u64,
    0x224698fc_094cf91bu64,
    0x00000000_00000000u64,
    0x40000000_00000000u64,
];

pasta_impl!(Pallas, PALLAS_P, 0x992d30ecffffffffu64,);

const VESTA_P: Pasta = [
    0x8c46eb21_00000001u64,
    0x224698fc_0994a8ddu64,
    0x00000000_00000000u64,
    0x40000000_00000000u64,
];

pasta_impl!(Vesta, VESTA_P, 0x8c46eb20ffffffffu64,);

#[cfg(test)]
mod tests {
    use super::*;
    use rand::{RngCore, SeedableRng};
    use rand_chacha::ChaCha20Rng;
    use std::io::prelude::*;
    use std::process::{Command, Stdio};

    #[test]
    fn arithmetic() {
        let mut python = match Command::new("python")
            .arg("-")
            .stdin(Stdio::piped())
            .spawn()
        {
            Err(_) => {
                println!("python is not found, skipping the test");
                return;
            }
            Ok(mut child) => {
                let mut pipe = child.stdin.take().unwrap();

                let p = format!(
                    "p = 0x{:016x}{:016x}{:016x}{:016x}\n",
                    PALLAS_P[3], PALLAS_P[2], PALLAS_P[1], PALLAS_P[0]
                );
                pipe.write_all(p.as_bytes()).expect("disaster");

                let q = format!(
                    "q = 0x{:016x}{:016x}{:016x}{:016x}\n",
                    VESTA_P[3], VESTA_P[2], VESTA_P[1], VESTA_P[0]
                );
                pipe.write_all(q.as_bytes()).expect("disaster");

                let mut rng = ChaCha20Rng::from_entropy();
                let mut x = Scalar::default();
                let mut y = Scalar::default();
                let mut eleven = Scalar([0; 32]);
                eleven.0[0] = 11;
                for _ in 0..5_000 {
                    rng.fill_bytes(&mut x.0);
                    let px = Pallas::from(x);

                    let expr = format!("{} % p == {}", x, px);
                    let mut cmd = format!("assert {}, \"{}\"\n", expr, expr);

                    rng.fill_bytes(&mut y.0);
                    let py = Pallas::from(y);

                    let expr = format!("({}+{}) % p == {}", x, y, px + py);
                    cmd += &format!("assert {}, \"{}\"\n", expr, expr);

                    let expr = format!("({}-{}) % p == {}", x, y, px - py);
                    cmd += &format!("assert {}, \"{}\"\n", expr, expr);

                    let expr = format!("({}*{}) % p == {}", x, y, px * py);
                    cmd += &format!("assert {}, \"{}\"\n", expr, expr);

                    let expr = format!("({}*{}) % p == 1", x, px.reciprocal());
                    cmd += &format!("assert {}, \"{}\"\n", expr, expr);

                    let px79 = px << 79;
                    let expr = format!("({}<<79) % p == {}", x, px79);
                    cmd += &format!("assert {}, \"{}\"\n", expr, expr);

                    let expr = format!("{} % p == {}", x, px79 >> 79);
                    cmd += &format!("assert {}, \"{}\"\n", expr, expr);

                    let expr = format!("pow({},11,p) == {}", x, px.pow(eleven));
                    cmd += &format!("assert {}, \"{}\"\n", expr, expr);

                    pipe.write_all(cmd.as_bytes()).expect("disaster");
                    match child.try_wait().expect("disaster") {
                        Some(status) => {
                            assert!(status.success());
                            return;
                        }
                        None => (),
                    }

                    rng.fill_bytes(&mut x.0);
                    let vx = Vesta::from(x);

                    let expr = format!("{} % q == {}", x, vx);
                    let mut cmd = format!("assert {}, \"{}\"\n", expr, expr);

                    rng.fill_bytes(&mut y.0);
                    let vy = Vesta::from(y);

                    let expr = format!("({}+{}) % q == {}", x, y, vx + vy);
                    cmd += &format!("assert {}, \"{}\"\n", expr, expr);

                    let expr = format!("({}-{}) % q == {}", x, y, vx - vy);
                    cmd += &format!("assert {}, \"{}\"\n", expr, expr);

                    let expr = format!("({}*{}) % q == {}", x, y, vx * vy);
                    cmd += &format!("assert {}, \"{}\"\n", expr, expr);

                    let expr = format!("({}*{}) % q == 1", x, vx.reciprocal());
                    cmd += &format!("assert {}, \"{}\"\n", expr, expr);

                    let vx79 = vx << 79;
                    let expr = format!("({}<<79) % q == {}", x, vx79);
                    cmd += &format!("assert {}, \"{}\"\n", expr, expr);

                    let expr = format!("{} % q == {}", x, vx79 >> 79);
                    cmd += &format!("assert {}, \"{}\"\n", expr, expr);

                    let expr = format!("pow({},11,q) == {}", x, vx.pow(eleven));
                    cmd += &format!("assert {}, \"{}\"\n", expr, expr);

                    pipe.write_all(cmd.as_bytes()).expect("disaster");
                    match child.try_wait().expect("disaster") {
                        Some(status) => {
                            assert!(status.success());
                            return;
                        }
                        None => (),
                    }
                }
                child
            }
        };

        let status = python.wait().expect("disaster");
        assert!(status.success());
    }
}
