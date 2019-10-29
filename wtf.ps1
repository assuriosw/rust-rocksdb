$env:RUSTUP_HOME="$env:SystemDrive\\$env:RUSTUP_HOME"
$env:CARGO_HOME="$env:SystemDrive\\$env:CARGO_HOME"
get-command 'cargo.exe' | select Source
C:/ProgramData/scoop/apps/rustup-msvc/current/.cargo/bin/cargo.exe version
cargo version
rustup show
