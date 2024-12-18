#! /bin/bash
cd /home/fuzzer/json-parser-1.1.0

# afl++ build
CC=afl-clang-lto ./configure && make
mkdir afl_build && cp libjsonparser.a afl_build
make clean

# asan build
CC=afl-clang-lto CFLAGS="-fsanitize=address" ./configure && make
mkdir asan_build && cp libjsonparser.a asan_build
make clean

# ubsan build
CC=afl-clang-lto CFLAGS="-fsanitize=undefined" ./configure && make
mkdir ubsan_build && cp libjsonparser.a ubsan_build
make clean

# cov build
CC=clang CFLAGS="-fprofile-instr-generate -fcoverage-mapping" ./configure && make
mkdir cov_build && cp libjsonparser.a cov_build
make clean

cd /home/fuzzer/json-parser-1.1.0/fuzz
# afl++ build
afl-clang-lto json_fuzz.c -I.. -L../afl_build/ -ljsonparser -lm -o afl_fuzz

# asan build
afl-clang-lto json_fuzz.c -fsanitize=address -I.. -L../asan_build/ -ljsonparser -lm -o asan_fuzz

# ubsan build
afl-clang-lto json_fuzz.c -fsanitize=undefined -I.. -L../ubsan_build/ -ljsonparser -lm -o ubsan_fuzz

# ubsan build
clang json_fuzz.c -I.. -L../cov_build/ -ljsonparser -lm -o cov_fuzz
