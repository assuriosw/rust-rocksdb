$env:RUSTUP_HOME = "C:\\ProgramData\\scoop\\persist\\rustup-msvc\\.rustup"
$env:CARGO_HOME = "C:\\ProgramData\\scoop\\persist\\rustup-msvc\\.cargo"
dir C:/ProgramData/scoop/apps/rustup-msvc/current/.cargo/bin
get-command 'cargo.exe' | select Source
C:/ProgramData/scoop/apps/rustup-msvc/current/.cargo/bin/cargo.exe version
cargo version
rustup show

dir env:
