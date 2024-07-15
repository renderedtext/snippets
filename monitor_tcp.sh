#!/bin/bash
HOST=${1:-'1'}
PORT=${2:-'0'}

DIST=$(uname)

  case $DIST in
    Linux)
      which mtr || (sudo apt-get update && sudo apt-get install -y mtr)
      ;;
    Darwin)
      which mtr || (brew install mtr)
      ;;
    *)
      echo "Unsupported distro $DIST"
      exit 1
      ;;
  esac

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

while true; do sudo mtr -P ${PORT} -T ${HOST} -c 10 -i 0.5 -G 0.1 -r -n -o "LDAWS" >> /tmp/mtr.log;sleep 0.5; done
