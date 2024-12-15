#! /bin/bash

while true; do
    for filename in corpus/*; do
        cat $filename | radamsa | ./json_parse
    done
done
