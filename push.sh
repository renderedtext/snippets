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
MTR_FILE=$(mktemp)

#
# Enable debug mode for docker push, restart.
#
echo "-------------------------------" >> $LOGS_PATH
echo "RESTARTING DOCKER IN DEBUG MODE" >> $LOGS_PATH
echo "-------------------------------" >> $LOGS_PATH

echo '{"debug": true}' | sudo tee /etc/docker/daemon.json > /dev/null
sudo kill -SIGHUP $(pidof dockerd)
sudo truncate -s 0 /var/log/syslog

#
# Log docker layers.
#

echo "------------------"  >> $LOGS_PATH
echo "DOCKER LAYERS     "  >> $LOGS_PATH
echo "------------------"  >> $LOGS_PATH
docker history $IMAGE_NAME >> $LOGS_PATH

#
# Run docker push.
#
echo "------------------" >> $LOGS_PATH
echo "DOCKER PUSH LOGS  " >> $LOGS_PATH
echo "------------------" >> $LOGS_PATH

REGISTRY_ENDPOINT=$(echo $IMAGE_NAME | cut -d'/' -f1)

# collect MTR logs while docker push is running
mtr -s 1000 --report-wide -c 10 -U 60 -m 60 $REGISTRY_ENDPOINT &> $MTR_FILE &
mtr_pid=$!

# seconds is a magic bash variable that returns number of seconds since last usage
SECONDS=0

docker push $IMAGE_NAME | tee -a $LOGS_PATH

DOCKER_EXIT_STATUS=$?
PUSH_DURATION=$SECONDS

#
# Collect logs
#

echo "------------------" >> $LOGS_PATH
echo "DOCKER DEAMON LOGS" >> $LOGS_PATH
echo "------------------" >> $LOGS_PATH

sudo cat /var/log/syslog          \
  | grep "dockerd"                \
  | awk -F 'time=' '{ print $2 }' \
  | sed 's/level=debug msg="//g'  \
  | sed "s/\"$(date +%F)T//"      \
  | sed 's/Z"//g'                 \
  >> $LOGS_PATH

echo "------------------"       >> $LOGS_PATH
echo "TOTAL DURATION    "       >> $LOGS_PATH
echo "------------------"       >> $LOGS_PATH

echo "PUSH_DURATION ${PUSH_DURATION}" >> $LOGS_PATH

echo "------------------"       >> $LOGS_PATH
echo "REGISTRY_ENDPOINT"        >> $LOGS_PATH
echo "------------------"       >> $LOGS_PATH

echo "REGISTRY_ENDPOINT ${REGISTRY_ENDPOINT}" >> $LOGS_PATH

echo "------------------"       >> $LOGS_PATH
echo "ORGANIZATION NAME"        >> $LOGS_PATH
echo "------------------"       >> $LOGS_PATH

ORGANIZATION_NAME=$(echo $SEMAPHORE_ORGANIZATION_URL | sed 's|https://||g' | cut -d'.' -f1)
echo "ORGANIZATION_NAME ${ORGANIZATION_NAME}" >> $LOGS_PATH

echo "------------------"       >> $LOGS_PATH
echo "PROJECT ID"               >> $LOGS_PATH
echo "------------------"       >> $LOGS_PATH

echo "PROJECT_ID ${SEMAPHORE_PROJECT_ID}"  >> $LOGS_PATH

echo "------------------"       >> $LOGS_PATH
echo "JOB ID"                   >> $LOGS_PATH
echo "------------------"       >> $LOGS_PATH

echo "JOB_ID ${SEMAPHORE_JOB_ID}"  >> $LOGS_PATH

echo "------------------"       >> $LOGS_PATH
echo "JOB NAME"                 >> $LOGS_PATH
echo "------------------"       >> $LOGS_PATH

JOB_NAME=$(echo $SEMAPHORE_JOB_NAME | sed 's| |-|g')
echo "JOB_NAME ${JOB_NAME}"     >> $LOGS_PATH

echo "------------------"       >> $LOGS_PATH
echo "BASE IMAGE NAME"          >> $LOGS_PATH
echo "------------------"       >> $LOGS_PATH

BASE_IMAGE_NAME=$(echo "${IMAGE_NAME}" | awk -F'/' '{ print $NF }' | awk -F':' '{ print $1 }')
echo "BASE_IMAGE_NAME ${BASE_IMAGE_NAME}" >> $LOGS_PATH

echo ""
echo "Total push duration: ${PUSH_DURATION} seconds."
echo "Submitted docker push debug metrics for evaluation."

#
# Save logs in /tmp/push_${unix_timestamp}_${job_id}.txt for internal monitoring.
#
NAME="$(date +%F)---${SEMAPHORE_WORKFLOW_ID}---${PUSH_DURATION}seconds.txt"
cat $LOGS_PATH > /tmp/push_$(date +%s)_${JOB_ID}.txt

# wait for mtr process to finish
wait $mtr_pid
cat $MTR_FILE > /tmp/mtr_$(date +%s)_${JOB_ID}.txt
#
# Preserve the exit code from docker push.
#
exit $DOCKER_EXIT_STATUS
