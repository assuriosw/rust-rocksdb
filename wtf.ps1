# Un-escape the escaped colons caused by a CI system that claims to be "enterprise" but has no concept of Windows paths
$env:RUSTUP_HOME=($env:RUSTUP_HOME -replace "|DRONE_COLON|",":")
$env:CARGO_HOME=($env:CARGO_HOME -replace "|DRONE_COLON|",":")
get-command 'cargo.exe' | select Source
C:/ProgramData/scoop/apps/rustup-msvc/current/.cargo/bin/cargo.exe version
cargo version
rustup show
