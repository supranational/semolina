use std::env;
use std::path::{Path, PathBuf};

#[cfg(target_env = "msvc")]
fn assembly(file_vec: &mut Vec<PathBuf>, base_dir: &Path, arch: &String) {
    let sfx = match arch.as_str() {
        "x86_64" => "x86_64",
        "aarch64" => "armv8",
        _ => "unknown",
    };
    let files =
        glob::glob(&format!("{}/win64/*-{}.asm", base_dir.display(), sfx))
            .expect("unable to collect assembly files");
    for file in files {
        file_vec.push(file.unwrap());
    }
}

#[cfg(not(target_env = "msvc"))]
fn assembly(file_vec: &mut Vec<PathBuf>, base_dir: &Path, _: &String) {
    file_vec.push(base_dir.join("assembly.S"))
}

fn main() {
    // account for cross-compilation [by examining environment variable]
    let target_arch = env::var("CARGO_CFG_TARGET_ARCH").unwrap();

    // Set CC environment variable to choose alternative C compiler.
    // Optimization level depends on whether or not --release is passed
    // or implied.
    let mut cc = cc::Build::new();

    let c_src_dir = PathBuf::from("src");
    let mut files = vec![c_src_dir.join("pasta.c")];
    assembly(&mut files, &c_src_dir, &target_arch);

    match (cfg!(feature = "portable"), cfg!(feature = "force-adx")) {
        (true, false) => {
            println!("Compiling in portable mode without ISA extensions");
            cc.define("__PASTA_PORTABLE__", None);
        }
        (false, true) => {
            if target_arch.eq("x86_64") {
                println!("Enabling ADX support via `force-adx` feature");
                cc.define("__ADX__", None);
            } else {
                println!("`force-adx` is ignored for non-x86_64 targets");
            }
        }
        (false, false) => {
            #[cfg(target_arch = "x86_64")]
            if target_arch.eq("x86_64") && std::is_x86_feature_detected!("adx")
            {
                println!("Enabling ADX because it was detected on the host");
                cc.define("__ADX__", None);
            }
        }
        (true, true) => panic!(
            "Cannot compile with both `portable` and `force-adx` features"
        ),
    }

    cc.flag_if_supported("-mno-avx") // avoid costly transitions
        .flag_if_supported("-fno-builtin")
        .flag_if_supported("-Wno-unused-function")
        .flag_if_supported("-Wno-unused-command-line-argument");
    if !cfg!(debug_assertions) {
        cc.opt_level(2);
    }
    cc.files(&files).compile("semolina");

    if let Some(manifest_dir) = env::var_os("CARGO_MANIFEST_DIR") {
        let c_include = Path::new(&manifest_dir).join("src");
        // set DEP_SEMOLINA_C_INCLUDE for dependents
        println!("cargo:C_INCLUDE={}", c_include.to_string_lossy());
    }
}
