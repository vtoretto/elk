#!/bin/bash

# Author: Vitor Duarte
# Date: 08/07/2020

msg() {
    echo "$(date +%F-%T:) $*"
}

getProcess() {
    export pid="$(ps aux | grep java | grep -v grep | grep ${appHome} | grep ${dataDir} | grep elastic | grep ${clusterName} )"
}

export appHome="/apps/elk/elasticsearch"
export logsDir="$(readlink -m ${appHome}/../elasticLogs)"
export dataDir="$(readlink -m ${appHome}/../elasticData)"
export clusterName="cluster-elk-qab-01"

pushd "${appHome}" >/dev/null

case ${1} in
    "start")

        getProcess

        if [ "${pid}" != "" ]; then
            msg "Ja existe um processo rodando: ${pid}"
            exit
        fi

        mkdir -p "${logsDir}"
        mkdir -p "${dataDir}"

        nohup ${appHome}/bin/elasticsearch \
            -E "thread_pool.search.queue_size=10000" \
            -E "thread_pool.search.size=60" \
            -E "thread_pool.search.min_queue_size=10000" \
            -E "thread_pool.search.max_queue_size=10000" \
            -E "thread_pool.search.auto_queue_frame_size=20000" \
            -E "cluster.name=${clusterName}" \
            -E "node.name=cluster-elk-qab-01-node-${HOSTNAME}" \
            -E "path.data=${dataDir}" \
            -E "path.logs=${logsDir}" \
            -E "network.host=0.0.0.0" \
            -E "bootstrap.memory_lock=true" \
            -E discovery.zen.ping.unicast.hosts='elscor00101q, elscor00201q, elscor00301q, elscor00401q, elscor00501q' \
            -E discovery.zen.minimum_master_nodes="3" > "${logsDir}/elasticsearch-stdout.$(date +%F-%H-%M-%S-%N).log" 2>&1 &
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
