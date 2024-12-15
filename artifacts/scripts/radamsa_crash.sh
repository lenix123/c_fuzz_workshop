#! /bin/bash

while true; do
    for filename in corpus/*; do
        # save mutated testcase to "tmp" file
        radamsa $filename > tmp
        # set timeout for 5s
        cat tmp | timeout 5 ./json_parse
        # check exit code to detect a crash
        EXIT_CODE=$?
        if [[ $EXIT_CODE -gt 127 || $EXIT_CODE -eq 124 ]]; then
            # rename testcase to "crash" and exit
            mv tmp crash
            exit 1
        fi
    done
done
