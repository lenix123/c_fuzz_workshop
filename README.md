# Fuzzing json-parser

## Реализация black box фаззера

### Подготовка окружения и создание корпуса
1. Клонируем репозиторий со всеми артефактами
``` bash
git clone https://github.com/lenix123/bmstu_fuzz.git
cd bmstu_fuzz
```

2. Собираем образ с подготовленным окружением. Потом запускаем на основе собранного образа контейнер:
``` bash
docker build -t json_fuzz_img .
docker run -it --name="json_fuzz" -v "$(pwd)/artifacts:/home/fuzzer/artifacts" json_fuzz_img
```

3. Собираем целевое приложение. Чтобы в будущем статически прилинковать библиотеку, можно удалить динамическую библиотеку.
``` bash
cd /home/fuzzer/json-parser-1.1.0
./configure
make
```

4. Копируем артефакты по фаззингу в рабочую директорию. Собираем наш тест:
``` bash
cd /home/fuzzer/json-parser-1.1.0 && mkdir fuzz && cd fuzz
cp -r /home/fuzzer/artifacts/* .
clang json_parse.c -I.. -L.. -ljsonparser -lm -o json_parse
```

5. Подготавливаем начальный корпус (тесткейсы):
``` bash
cd /home/fuzzer/json-parser-1.1.0/fuzz
mkdir corpus
cp ../tests/*.json corpus
```

5. Прогоняем скомпилированный тест с корпусом
``` bash
for filename in corpus/*; do ./json_parse < $filename; done
```

### Добавляем мутатор

1. Компилируем простой мутатор
``` bash
cd /home/fuzzer/json-parser-1.1.0/fuzz
clang mutate.c -o mutate
```

2. Запускаем тест с мутируемым корпусом
``` bash
cd /home/fuzzer/json-parser-1.1.0/fuzz
./scripts/run_mutate.sh
```

3. Устанавливаем radamsa мутатор
``` bash
cd /home/fuzzer
git clone https://gitlab.com/akihe/radamsa.git
cd radamsa
make
make install
```

4. Запускаем тест с мутируемым с помощью radamsa корпусом
``` bash
cd /home/fuzzer/json-parser-1.1.0/fuzz
./scripts/run_radamsa.sh
```

### ДОбавляем обработку падений

1. Добавляем проверку на код возврата и запускаем тест:
``` bash
cd /home/fuzzer/json-parser-1.1.0/fuzz
./scripts/radamsa_crash.sh
```

### AFL++ фаззер
1. Собираем целевое приложение с помощью afl++ компилятора
``` bash
cd /home/fuzzer/json-parser-1.1.0
CC=afl-clang-lto ./configure
make
rm -f libjsonparser.so
```

2. Собираем обёртку с afl++:
``` bash
cd /home/fuzzer/json-parser-1.1.0/fuzz
afl-clang-lto json_parse.c -I.. -L.. -ljsonparser -lm -o json_parse
```

3. Запускаем фаззинг:
``` bash
afl-fuzz -i corpus/ -o out -- ./json_parse
```

### Собираем покрытие
1. Инструментируем целевую программу:
``` bash
cd /home/fuzzer/json-parser-1.1.0
CC=clang CFLAGS="-fprofile-instr-generate -fcoverage-mapping" ./configure
```

2. Компилируем обёртку
``` bash
cd /home/fuzzer/json-parser-1.1.0/fuzz
clang -fprofile-instr-generate -fcoverage-mapping json_parse.c -I.. -L.. -ljsonparser -lm -o cov_json_parse
for filename in out/default/queue/*; do cat $filename | ./cov_json_parse; done
```

3. Генерируем html отчёт
``` bash
llvm-profdata merge default.profraw -o default.profdata
llvm-cov show cov_json_parse --instr-profile=default.profdata -format=html -output-dir=report
```

4. Просматриваем отчёт о покрытии на хосте:
``` bash
docker cp json_fuzz:/home/fuzzer/json-parser-1.1.0/fuzz/report .
open report/index.html
```

### Добавляем санитайзеры
1. Собираем с помощью скрипта `build.sh` целевую программу и обёртку с нужными санитайзерами:
``` bash
cd /home/fuzzer/json-parser-1.1.0/fuzz
./build.sh
```

2. Запускаем главный инстанс фаззера:
``` bash
tmux new -s main
docker exec -it json_fuzz /bin/bash
cd /home/fuzzer/json-parser-1.1.0/fuzz
afl-fuzz -M main -i corpus -o out -- ./afl_fuzz
```

3. Запускаем второстепенный инстанс с адресным санитайзером:
``` bash
tmux new -s asan
docker exec -it json_fuzz /bin/bash
cd /home/fuzzer/json-parser-1.1.0/fuzz
afl-fuzz -S asan -i corpus -o out -- ./asan_fuzz
```

4. Запускаем второстепенный инстанс с UBSAN санитайзером:
``` bash
tmux new -s ubsan
docker exec -it json_fuzz /bin/bash
cd /home/fuzzer/json-parser-1.1.0/fuzz
afl-fuzz -S ubsan -i corpus -o out -- ./ubsan_fuzz
```

5. Узнаём статистику фаззинга по всем инстансам:
``` bash
cd /home/fuzzer/json-parser-1.1.0/fuzz\
afl-whatsup out
```
