#!/bin/bash

#
# A wrapper around docker push that collects metrics into a log file.
#
# On completion, this scripts pushes the logs to project level artifacts.
# visit: https://<org>.semaphoreci.com/artifacts/projects/<project-name>
#
# Usage:
#
#   Replace "docker push <image-name>" with "bash push.sh <image-name>".
#
# What is collected?
#
#  1. Information about docker layers and their sizes
#  2. Docker deamon debug logs, includes timing data about accessing remote docker registry
#  3. Raw docker push output
#  4. Total duration of the docker push command
#

IMAGE_NAME=$1
LOGS_PATH=$(mktemp)

#
# Enable debug mode for docker push and limit uploads concurrency to 1, restart.
#
echo "-------------------------------" | tee -a $LOGS_PATH
echo "RESTARTING DOCKER IN DEBUG MODE" | tee -a $LOGS_PATH
echo "-------------------------------" | tee -a $LOGS_PATH

echo '{"debug": true,"max-concurrent-uploads": 1}' | sudo tee /etc/docker/daemon.json
sudo kill -SIGHUP $(pidof dockerd)
sudo truncate -s 0 /var/log/syslog

#
# Log docker layers.
#

echo "------------------"  | tee -a $LOGS_PATH
echo "DOCKER LAYERS     "  | tee -a $LOGS_PATH
echo "------------------"  | tee -a $LOGS_PATH
docker history $IMAGE_NAME | tee -a $LOGS_PATH

#
# Run docker push.
#
echo "------------------" | tee -a $LOGS_PATH
echo "DOCKER PUSH LOGS  " | tee -a $LOGS_PATH
echo "------------------" | tee -a $LOGS_PATH

# seconds is a magic bash variable that returns number of seconds since last usage
SECONDS=0

docker push $IMAGE_NAME | tee -a $LOGS_PATH

DOCKER_EXIT_STATUS=$?
PUSH_DURATION=$SECONDS

#
# Collect logs
#

echo "------------------" | tee -a $LOGS_PATH
echo "DOCKER DEAMON LOGS" | tee -a $LOGS_PATH
echo "------------------" | tee -a $LOGS_PATH

sudo cat /var/log/syslog          \
  | grep "dockerd"                \
  | awk -F 'time=' '{ print $2 }' \
  | sed 's/level=debug msg="//g'  \
  | sed "s/\"$(date +%F)T//"      \
  | sed 's/Z"//g'                 \
  | tee -a $LOGS_PATH

echo "------------------"       | tee -a $LOGS_PATH
echo "TOTAL DURATION    "       | tee -a $LOGS_PATH
echo "------------------"       | tee -a $LOGS_PATH

echo "PUSH_DURATION ${PUSH_DURATION}" | tee -a $LOGS_PATH

echo "------------------"       | tee -a $LOGS_PATH
echo "REGISTRY_ENDPOINT"        | tee -a $LOGS_PATH
echo "------------------"       | tee -a $LOGS_PATH

REGISTRY_ENDPOINT=$(echo $IMAGE_NAME | cut -d'/' -f1)
echo "REGISTRY_ENDPOINT ${REGISTRY_ENDPOINT}"     | tee -a $LOGS_PATH

echo "------------------"       | tee -a $LOGS_PATH
echo "ORGANIZATION NAME"        | tee -a $LOGS_PATH
echo "------------------"       | tee -a $LOGS_PATH

echo "ORGANIZATION_NAME ${SEMAPHORE_ORGANIZATION_URL}" | sed 's|https://||g' | cut -d'.' -f1 | awk '{ print $1 }'

echo "------------------"       | tee -a $LOGS_PATH
echo "PROJECT ID"               | tee -a $LOGS_PATH
echo "------------------"       | tee -a $LOGS_PATH

echo "PROJECT_ID ${SEMAPHORE_PROJECT_ID}"  | tee -a $LOGS_PATH

echo "------------------"       | tee -a $LOGS_PATH
echo "JOB NAME"                 | tee -a $LOGS_PATH
echo "------------------"       | tee -a $LOGS_PATH

echo "JOB_NAME ${SEMAPHORE_JOB_NAME}"    | sed 's| |-|g' | tee -a $LOGS_PATH

#
# Save them as an artifact on the project level and leave them in /tmp/docker_debug_logs.txt for internal monitoring.
#
# visit: https://<org>.semaphoreci.com/artifacts/projects/<project>
#

NAME="$(date +%F)---${SEMAPHORE_WORKFLOW_ID}---${PUSH_DURATION}seconds.txt"
artifact push project $LOGS_PATH -d docker/$NAME
cat $LOGS_PATH > /tmp/docker_debug_logs.txt

#
# Preserve the exit code from docker push.
#
exit $DOCKER_EXIT_STATUS
