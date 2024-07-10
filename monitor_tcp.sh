#!/bin/bash
HOST=${1:-'1'}
PORT=${2:-'0'}

#sudo apt-get install -y mtr

if [[ $# -ne 2 ]];then
  echo "Usage: ./monitor_tcp.sh [hostname|host ip] [tcp port number]"
  exit 1
fi
if [[ $HOST == '1' ]];then
  echo 'Host is not defined'
  exit 1
fi
if [[ $PORT == '0' ]];then
  echo 'PORT is not defined'
  exit 1
fi

while true; do sudo mtr -P ${PORT} -T ${HOST} -c 10 -r -n >> /tmp/mtr.log;sleep 1; done
