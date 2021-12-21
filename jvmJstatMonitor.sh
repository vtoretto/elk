#!/bin/bash

JAVA_HOME="/usr/java/jdk1.8.0_31_x64"
#JAVA_HOME="/opt/java/jdk1.8.0_112_x64"
#JAVA_HOME="/usr/java/jdk1.8.0_60_x64"


processFilter="java\|bvmf_"

hostToSend="elscor00101q"
portToSend="7080"

while IFS= read -r line; do
    processList+=( "$line" )
done < <(ps aux | grep "${processFilter}" | grep -v grep)

for ((i = 0; i < ${#processList[@]}; i++)) do

    unset jstatOutputs
    currentPid="$(echo -ne ${processList[i]} | awk '{print $2}')"
    currentCmd="$(cat /proc/${currentPid}/cmdline)"

    while IFS= read -r line; do
        jstatOutputs+=( "$line" )
    done < <(${JAVA_HOME}/bin/jstat -gc ${currentPid} | tail -n 1 | tr -s ' ' '\n')

    timestamp="$(date -u +%FT%T.%3NZ)"

    if [ "" == "${jstatOutputs[7]}" ]; then
        echo "nenhum valor para pid: ${currentPid}"
        continue
    fi

    send='{'
    send+='"@timestamp":"'${timestamp}'",'
    send+='"S0C":'${jstatOutputs[0]}','
    send+='"S1C":'${jstatOutputs[1]}','
    send+='"S0U":'${jstatOutputs[2]}','
    send+='"S1U":'${jstatOutputs[3]}','
    send+='"EC":'${jstatOutputs[4]}','
    send+='"EU":'${jstatOutputs[5]}','
    send+='"OC":'${jstatOutputs[6]}','
    send+='"OU":'${jstatOutputs[7]}','
    send+='"MC":'${jstatOutputs[8]}','
    send+='"MU":'${jstatOutputs[9]}','
    send+='"CCSC":'${jstatOutputs[10]}','
    send+='"CCSU":'${jstatOutputs[11]}','
    send+='"YGC":'${jstatOutputs[12]}','
    send+='"YGCT":'${jstatOutputs[13]}','
    send+='"FGC":'${jstatOutputs[14]}','
    send+='"FGCT":'${jstatOutputs[15]}','
    send+='"GCT":'${jstatOutputs[16]}','
    send+='"beat.hostname":"'$(hostname)'",'
    send+='"system.process.pid":"'${currentPid}'",'
    send+='"cmdLine":"'${currentCmd//\"/\\\"}'",'
    send+='"type":"tcpinput"'
    send+='}'

    #echo "${send}"
    echo -e ${send} > /dev/tcp/${hostToSend}/${portToSend}

done
