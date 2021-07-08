#!/bin/bash

# Author: Vitor Duarte
# Date: 08/07/2021
#
# PrimeUp - Outstanding IT Performance

msg() {
    echo "$(date +%F-%T:) $*"
}

getProcess() {
    export pid="$(ps aux | grep -v grep | grep ${appHome} )"
}

export appHome="/apps/elk/kibana"
export logsDir="$(readlink -m ${appHome}/logs)"

pushd "${appHome}" >/dev/null

case ${1} in
    "start")

        getProcess

        if [ "${pid}" != "" ]; then
            msg "Ja existe um processo rodando: ${pid}"
            exit
        fi

        mkdir -p "${logsDir}"

        nohup ${appHome}/bin/kibana \
            -e http://127.0.0.1:9200 \
            -H 0.0.0.0 > ${logsDir}/kibana-stdout.$(date +%F-%H-%M-%S-%N).log 2>&1 &

        sleep 1

        getProcess

        msg "Processo rodando: ${pid}"

        ;;
    "stop")

        getProcess

        if [ "${pid}" == "" ]; then
            msg "nenhum processo rodando...."
            exit
        else
            msg "finalizando processo: ${pid}"
            kill $(echo ${pid} | awk '{print $2}')
        fi
    ;;

    *)
        msg "Opcao invalida. Tente:"
        msg "$0 start|stop"
    ;;
esac

popd >/dev/null
