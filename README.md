# Semolina

Even though [Pasta Curves](https://web.archive.org/web/20260823101850/https://electriccoin.co/blog/the-pasta-curves-for-halo-2-and-beyond/) name's etymology is astronomical, it sounds too gastronomical to see past it. Hence the name, [Semolina](https://en.wikipedia.org/wiki/Semolina), the main ingridient in making pasta. The library is a collection of low-level x86_64 and aarch64 primitives optimized for Pasta moduli. It currently provides basic arithmetic operations, conversion, exponentiation helper, modular inversion subroutines, as well as MinRoot VDF primitives. `cargo test` exercises arithmetic operations against Python. No benchmarks are provided here, because it's argued that it makes more sense to benchmark higher level implementations.

### Technical notes

For optimal performance, prefer working with references over values: `&x + &y` is more efficient than `x + y`. This is because the compiler tends to make redundant copies of the value arguments.

On x86_64 Linux, it's beneficial to compile your application with the `-Crelro-level=partial` Rust flag. This is because with the default `relro-level` FFI calls are performed using indirect calls.

## License

The semolina library is licensed under either of

 * Apache License, Version 2.0, ([LICENSE-APACHE](LICENSE-APACHE) or
   http://www.apache.org/licenses/LICENSE-2.0)
 * MIT license ([LICENSE-MIT](LICENSE-MIT) or
   http://opensource.org/licenses/MIT)

at your option.

### Contribution

Unless you explicitly state otherwise, any contribution intentionally
submitted for inclusion in the work by you, as defined in the Apache-2.0
license, shall be dual licensed as above, without any additional terms or
conditions.

