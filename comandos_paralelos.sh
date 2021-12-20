#!/bin/bash

# Author: Thiago Ruiz
# Date: 27/08/2018

#echo "NAO UTILIZE ESTE SCRIPT SE NAO SOUBER O QUE ESTA FAZENDO"
#echo "comente esta linha caso saiba"
#exit


# exemplo de como executar 2 comandos juntos (escapar o &&)  :
#       ./ComandosParalelos.sh sleep 5 \&\& echo teste

# exemplo de como executar filtro com grep (aspas duplas no comando sempre que tiver pipe):
#      ./ComandosParalelos.sh "ls -lhas /usr/local/ |grep mysqldump"

# exemplo como executar filtro com find (que posteriormente pode ser usado para usar o find com -exec )
#      ./ComandosParalelos.sh find /usr/local/ -name \"*.tar.gz\"

# exemplo como determinar o tamanho de um diretorio dentro de um unico sistema de arquivo (unica perticao)
# e excluindo um diretorio de qualquer da contagem:
#    ./ComandosParalelos.sh du -shx --exclude=/usr/local/ /usr/

# exemplo como backupiar todo o /usr/ sem o diretorio /usr/local/ diretorio qualquer
#    ./ComandosParalelos.sh tar -czf /usr/local/Backup.\$HOSTNAME.tar.gz  --exclude=/usr/local/ /usr/

# exemplo como deszipar arquivo em todas as maquinas
#    ./ComandosParalelos.sh tar -C /usr/ -xvzf /usr/patch.tar.gz

# exemplo como executar um script sql em todas as maquinas
# 1) copiar arquivo para todas:
#    ./CopiaParalelos.sh /tmp/1.sql
# 2) executar em todas (repare no 2>&1) :
#    ./ComandosParalelos.sh "mysql -u usuario -pSENHA BANCO < /tmp/1.sql 2>&1"



# exemplo usando variaveis de ambiente para criar/listar arquivos diferentes em cada maquina
# repare que o primeiro "$" éscapado (para ser usado apenas na maquina que executa) e o sub-shell $(date +%s) serve para pegar o timestamp da Console
# e gerar todos os arquivos com o mesmo timestamp no nome...
#     ./ComandosParalelos.sh "ls -lhas /usr/local/mysqldump.\$HOSTNAME.$(date +%s).--triggers--routines--single-transaction.tar.gz"


#veja o retorno: na maquina1 listou arquivo com nome Computador1, na 2, Computador2, etc..
## retorno comando 'ls -lhas /usr/local/mysqldump.$HOSTNAME.1339768423.--triggers--routines--single-transaction.tar.gz' em  Computador01 outputfile /tmp/Computador01.20652.log
#30M -rw-r--r-- 1 user www-data 30M Jun 15 10:53 /usr/local/mysqldump.Computador01.1339768423.--triggers--routines--single-transaction.tar.gz
#
## retorno comando 'ls -lhas /usr/local/mysqldump.$HOSTNAME.1339768423.--triggers--routines--single-transaction.tar.gz' em  Computador02 outputfile /tmp/Computador02.20652.log
#15M -rw-r--r-- 1 user www-data 15M Jun 15 10:53 /usr/local/mysqldump.Computador02.1339768423.--triggers--routines--single-transaction.tar.gz



MY_PID="$$"
UNIQUE_TEST="$MY_PID $*"
SLEEP_TIME="5"
OUTPUT_DIR="/tmp"
USUARIO="_svcElkQ"


#use uma variavel com os hosts menos importantes para testar comandos/jeitos de usar este script
#ANTES para tentar minimizar comportamentos errados!!!
#SERVIDORES=(Computador42 )

#SERVIDORES=(apspos30501q.internalenv.corp apspos22101q.intraservice.corp apspos22201q.intraservice.corp apspos22301q.intraservice.corp apspos22401q.intraservice.corp apspos22501q.intraservice.corp apspos22601q.intraservice.corp apspos22701q.intraservice.corp apspos22801q.intraservice.corp apspos22901q.intraservice.corp apspos22001q.intraservice.corp apspos24901q.intraservice.corp apspos25001q.intraservice.corp apspos25101q.intraservice.corp apspos25201q.intraservice.corp apspos25301q.intraservice.corp apspos25401q.intraservice.corp apspos25501q.intraservice.corp apspos25601q.intraservice.corp apspos25701q.intraservice.corp apspos25801q.intraservice.corp apspos77101q apspos78101q apspos79101q.internalenv.corp apspos79201q.internalenv.corp )

SERVIDORES=( $(cut -d ' ' -f 1 /home/_svcRTCQ/servidores_rtc.txt | sort -u | paste -sd' ') )


if [ "$*" == "" ]; then
  echo "###################################################digite um comando (CUIDADO COM ISSO, SERA EXECUTADO EM TODOS OS EQUIPAMENTOS)"
  exit
fi


for SERVIDOR in ${SERVIDORES[@]}
do


    #dont ask... on QAB-RTC some comands hands for no reason... so i'm trying to avoid that
    usleep 10000
    OUTPUT_FILE="$OUTPUT_DIR/$SERVIDOR.$MY_PID.log"
    echo "# executando comando "$*" em  $SERVIDOR output em $OUTPUT_FILE "
    $(ssh -q -o StrictHostKeyChecking=no $USUARIO@$SERVIDOR $* > "$OUTPUT_FILE" 2>&1) &

done

#por algum motivo bizarro eu tive que dar grep pelo nome do script...
#dentro do while sempre era gerado outro pid.. nao sei de onde eles
#eram... e tinham a mesma linha do comando inicial...
#em outro pty este mesmo processo nao aparecia...

COUNT=$(ps aux |grep "ssh -o StrictHostKeyChecking=no" | grep "$*" | grep -v $MY_PID )

wait 


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
    COUNT=$(ps aux |grep "ssh -q -o StrictHostKeyChecking=no" | grep "$*" | grep -v $MY_PID )
done


echo ""
echo ""
echo ""
echo ""
echo "todos acabaram... sem este ultimo sleep o arquivo output ainda nao foi gerado (inexplicavel...) "
echo ""
echo ""
sleep $SLEEP_TIME


for SERVIDOR in ${SERVIDORES[@]}
do

    OUTPUT_FILE="$OUTPUT_DIR/$SERVIDOR.$MY_PID.log"
    echo -n "   #-- retorno comando '"$*"' em  $SERVIDOR outputfile $OUTPUT_FILE --#"
    echo ""
    cat "$OUTPUT_FILE"
    echo ""
    rm $OUTPUT_FILE

    echo ""

done

exit

