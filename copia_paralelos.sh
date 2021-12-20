#!/bin/bash

# Author: Thiago Ruiz
# Date: 27/08/2018

#echo "NAO UTILIZE ESTE SCRIPT SE NAO SOUBER O QUE ESTA FAZENDO"
#echo "comente esta linha caso saiba"
#exit


#exemplo jogar arquivo em todoas as maquinas no mesmo diretorio
# time /home/usuario/scripts/CopiaParalelos.sh /usr/local/diretorio/arquivo.tar.gz



MY_PID="$$"
UNIQUE_TEST="$MY_PID $*"
SLEEP_TIME="3"
OUTPUT_DIR="/tmp"
USUARIO="_svcElkQ"


#use uma variavel com os hosts menos importantes para testar comandos/jeitos de usar este script
#ANTES para tentar minimizar comportamentos errados!!!
#SERVIDORES=(Computador42 )

SERVIDORES=(apspos30501q.internalenv.corp apspos22101q.intraservice.corp apspos22201q.intraservice.corp apspos22301q.intraservice.corp apspos22401q.intraservice.corp apspos22501q.intraservice.corp apspos22601q.intraservice.corp apspos22701q.intraservice.corp apspos22801q.intraservice.corp apspos22901q.intraservice.corp apspos22001q.intraservice.corp apspos24901q.intraservice.corp apspos25001q.intraservice.corp apspos25101q.intraservice.corp apspos25201q.intraservice.corp apspos25301q.intraservice.corp apspos25401q.intraservice.corp apspos25501q.intraservice.corp apspos25601q.intraservice.corp apspos25701q.intraservice.corp apspos25801q.intraservice.corp apspos77101q apspos78101q apspos79101q.internalenv.corp apspos79201q.internalenv.corp )

if [ "$1" == "" ]; then
  echo "#### digite o caminho de um arquivo a ser copiado nos SERVIDORES"
  exit
fi

if [ "$2" == "" ]; then
  echo "#### digite o path que o arquivo sera copiado nos SERVIDORES"
  exit
fi

originalFile=$(basename $1)




for SERVIDOR in ${SERVIDORES[@]}
do
    OUTPUT_FILE="$OUTPUT_DIR/$SERVIDOR.$MY_PID.log"
    echo "# executando scp "$originalFile" em  $SERVIDOR output em $OUTPUT_FILE "
    $(scp -q -pr -o StrictHostKeyChecking=no "$1" $USUARIO@$SERVIDOR:"$2" > "$OUTPUT_FILE" 2>&1) &

done

COUNT=$(ps aux |grep "scp -pr -o StrictHostKeyChecking=no" | grep "$*" | grep -v $MY_PID )

while [ "$COUNT" != "" ]
do
    echo ""
    echo ""
    echo ""
    echo "esperando sleeping $SLEEP_TIME"
    echo ""
    echo "$COUNT"
    echo ""
    echo ""
    echo ""
    sleep $SLEEP_TIME
    COUNT=$(ps aux |grep "scp -pr -o StrictHostKeyChecking=no" | grep "$*" | grep -v $MY_PID )
done

echo "todos acabaram... sem este ultimo sleep o arquivo output ainda nao foi gerado (inexplicavel...) "
echo ""
echo ""
sleep $SLEEP_TIME

wait

for SERVIDOR in ${SERVIDORES[@]}
do

    OUTPUT_FILE="$OUTPUT_DIR/$SERVIDOR.$MY_PID.log"
    echo "# retorno comando '"$*"' em  $SERVIDOR outputfile $OUTPUT_FILE"
    cat "$OUTPUT_FILE"
    rm $OUTPUT_FILE

    echo ""

done



exit

