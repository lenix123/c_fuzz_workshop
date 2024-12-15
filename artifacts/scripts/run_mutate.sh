#! /bin/bash

while true; do
    for filename in corpus/*; do
        cat $filename | ./mutate | ./json_parse
    done
done
