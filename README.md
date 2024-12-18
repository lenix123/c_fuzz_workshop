# Fuzzing json-parser

## Команды с презинтации:
``` bash
git clone https://github.com/lenix123/bmstu_fuzz.git
cd bmstu_fuzz
```

``` bash
docker build -t json_fuzz_img .
docker run -it --name="json_fuzz" -v "$(pwd)/artifacts:/home/fuzzer/artifacts" json_fuzz_img
```

``` bash
cd /home/fuzzer/json-parser-1.1.0
./configure
make
```

``` bash
cd /home/fuzzer/json-parser-1.1.0 && mkdir fuzz && cd fuzz
cp -r /home/fuzzer/artifacts/* .
clang json_parse.c -I.. -L.. -ljsonparser -lm -o json_parse
```

``` bash
cd /home/fuzzer/json-parser-1.1.0/fuzz
mkdir corpus
cp ../tests/*.json corpus
```

``` bash
for filename in corpus/*; do ./json_parse < $filename; done
```

``` bash
cd /home/fuzzer/json-parser-1.1.0/fuzz
clang mutate.c -o mutate
```

``` bash
cd /home/fuzzer/json-parser-1.1.0/fuzz
./scripts/run_mutate.sh
```

``` bash
cd /home/fuzzer
git clone https://gitlab.com/akihe/radamsa.git
cd radamsa
make
make install
```

``` bash
cd /home/fuzzer/json-parser-1.1.0/fuzz
./scripts/run_radamsa.sh
```

``` bash
cd /home/fuzzer/json-parser-1.1.0/fuzz
./scripts/radamsa_crash.sh
```

``` bash
cd /home/fuzzer/json-parser-1.1.0
CC=afl-clang-lto ./configure
make
rm -f libjsonparser.so
```

``` bash
cd /home/fuzzer/json-parser-1.1.0/fuzz
afl-clang-lto json_parse.c -I.. -L.. -ljsonparser -lm -o json_parse
```

``` bash
afl-fuzz -i corpus/ -o out -- ./json_parse
```

``` bash
cd /home/fuzzer/json-parser-1.1.0
CC=clang CFLAGS="-fprofile-instr-generate -fcoverage-mapping" ./configure
```

``` bash
cd /home/fuzzer/json-parser-1.1.0/fuzz
clang -fprofile-instr-generate -fcoverage-mapping json_parse.c -I.. -L.. -ljsonparser -lm -o cov_json_parse
for filename in out/default/queue/*; do cat $filename | ./cov_json_parse; done
```

``` bash
llvm-profdata merge default.profraw -o default.profdata
llvm-cov show cov_json_parse --instr-profile=default.profdata -format=html -output-dir=report

``` bash
docker cp json_fuzz:/home/fuzzer/json-parser-1.1.0/fuzz/report .
```

``` bash
cd /home/fuzzer/json-parser-1.1.0/fuzz
./build.sh
```

``` bash
tmux new -s main
docker exec -it json_fuzz /bin/bash
cd /home/fuzzer/json-parser-1.1.0/fuzz
afl-fuzz -M main -i corpus -o out -- ./afl_fuzz
```

``` bash
tmux new -s asan
docker exec -it json_fuzz /bin/bash
cd /home/fuzzer/json-parser-1.1.0/fuzz
afl-fuzz -S asan -i corpus -o out -- ./asan_fuzz
```

``` bash
tmux new -s ubsan
docker exec -it json_fuzz /bin/bash
cd /home/fuzzer/json-parser-1.1.0/fuzz
afl-fuzz -S ubsan -i corpus -o out -- ./ubsan_fuzz
```

``` bash
cd /home/fuzzer/json-parser-1.1.0/fuzz\
afl-whatsup out
```
