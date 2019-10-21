#!/bin/bash

while true
do
    netcat -lp 8080 -e ./main.sh;
    if [ "$1" != "loop" ]
    then
        exit
    fi
done
