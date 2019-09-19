RocksDB bindings
================

Low-level bindings to RocksDB's C API.

Based on original work by Tyler Neely
https://github.com/rust-rocksdb/rust-rocksdb
and Jeremy Fitzhardinge
https://github.com/jsgf/rocksdb-sys

# Updating to a new version

1. Update the `rocksdb` submodule to the tag for whatever the new release is.  
1. In the `rocksdb` subdirectory run `make util/build_version.cc`
1. In the `rocksdb` subdirectory run `make unity.cc`
1. Copy `rocksdb/util/build_version.cc` to this directory
1. Use the contents of `unity.cc` to recreate the `rocksdb_lib_sources.txt` file in this directory.  Just strip the
   `#include` and `"` and replace newlines with spaces.  This isn't always required but sometimes a release adds or
   removes a file and then it won't build until you do this.
1. Don't forget to update the version of the crate in `Cargo.toml` to match the RocksDB version

