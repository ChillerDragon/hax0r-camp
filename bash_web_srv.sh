#!/bin/bash
while true;
do
    netcat -lp 8080 -e ./main.sh;
done
