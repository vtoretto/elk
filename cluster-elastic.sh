#! /bin/bash

# ES_HOME was defined in ~/.bashrc vitor's user,
# means that variable is loaded while logging.
export ES_HOME=/opt/elk-6.4.0/elasticsearch
export ES_PATH_CONF="$ES_HOME"/../nodes-config
export PIDS="$ES_HOME"/../pids

msg() {
    echo "$(date +%F-%T:) $*"
}

case $1 in

  "start")
    while read l; do
      if [ -f "$PIDS"/${l}.pid ]; then
        echo "node \"${l}\" is already running..." 
      else
        nohup "$ES_HOME"/bin/elasticsearch \
        -Enode.name="$l" \
        -Epath.logs=/opt/elk-6.4.0/nodes-log/"$l" \
        -Epath.data=/opt/elk-6.4.0/nodes-data/"$l" -q \
        -p "$PIDS"/${l}.pid &
      fi
    done < nodes
    ;;

  "stop")
    while read l; do
      if [ -f "$PIDS"/${l}.pid ]; then
        pkill -F "$PIDS"/${l}.pid
      else
        echo "node $l is not running"
      fi
    done < nodes
    ;;
    
  *)
    msg "Invalid option."
    echo "Try: $0 start|stop"

esac
