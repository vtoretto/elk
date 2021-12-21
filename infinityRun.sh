#!/bin/bash

sleepTimeInSeconds="10"

i=0
runList[i++]="/home/_svcRTCQ/jvmJstatMonitor.sh"

while true; do

    for ((i=0; i < ${#runList[@]}; i++)); do
        nohup ${runList[i]} > /dev/null 2>&1
    done

    sleep ${sleepTimeInSeconds}

done
