#!/bin/bash

# Author: Vitor Duarte
# Date: 08/07/2021

msg() {
    echo "$(date +%F-%T:) $*"
}

getProcess() {
    export pid="$(ps aux | grep -v grep | grep ${appHome} )"
}

export appHome="/apps/elk/metricbeat"
export logsDir="$(readlink -m ${appHome}/logs)"
export processToMonitor=".*java.*,.*beat.*,.*node.*,.*kibana.*,.*bvmf.*"

pushd "${appHome}" >/dev/null

case ${1} in
    "start")

        getProcess

        if [ "${pid}" != "" ]; then
            msg "Ja existe um processo rodando: ${pid}"
            exit
        fi

        mkdir -p "${logsDir}"


        nohup ${appHome}/metricbeat \
            -c metricbeat.yml \
            -E output.logstash.hosts='["elscor00101q:5045", "elscor00201q:5045", "elscor00301q:5045", "elscor00401q:5045", "elscor00501q:5045" ]' \
            -E setup.dashboards.enabled='false' \
            -E setup.kibana.host='elscor00101q:5601' > ${logsDir}/metricbeat-stdout.$(date +%F-%H-%M-%S-%N).log 2>&1 &

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
