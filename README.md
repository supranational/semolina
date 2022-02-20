# Semolina

Even though [Pasta Curves](https://electriccoin.co/blog/the-pasta-curves-for-halo-2-and-beyond/) name's etymology is astronomical, it sounds too gastronomical to see past it. Hence the name, [Semolina](https://en.wikipedia.org/wiki/Semolina), the main ingridient in making pasta. The library is a collection of low-level x86_64 and aarch64 primitives optimized for Pasta moduli. It currently provides basic arithmetic, conversion, exponentiation helper and modular inversion subroutines. `cargo test` exercises these against Python. No benchmarks are provided here, because it's argued that it makes more sense to benchmark higher level implementations.

### Technical ranting[s]

From performance viewpoint following implementation is optimal, because it compiles as straightforward call to `pasta_mul` with return value's address as destination pointer:
```Rust
impl core::ops::Mul for $field {
    type Output = Self;

    fn mul(self, other: Self) -> Self {
        unsafe {
            let mut out = MaybeUninit::<Self>::uninit().assume_init();
            pasta_mul(&mut out.0, &self.0, &other.0, &$mod, $m0);
            out
        }
    }
}
```
However, it's argued that using `assume_init()` as initial assignment is not safe in Rust, and that it should be used rather upon return from the subroutine. Which is compiled as a) allocate a temporary value on the stack, b) call `pasta_mul` with the temporary value's address as destination pointer, c) finally copy the temporary value to the target location. This is arguably inefficient. The below snippet on the other hand is compiled as a) zero the return value, b) call `pasta_mul` with the return value's address as the destination pointer. Which is why it was chosen, for efficiency.
```Rust
impl core::ops::Mul for $field {
    type Output = Self;

    fn mul(self, other: Self) -> Self {
        let mut out = Self::default();
        unsafe { pasta_mul(&mut out.0, &self.0, &other.0, &$mod, $m0) };
        out
    }
}
```

## License
The semolina library is licensed under the [Apache License Version 2.0](LICENSE) software license.

