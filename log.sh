#!/bin/bash

DATE=$(date +"%F_%H-%M-%S")
tar -czf /tmp/docker-debug-log_${DATE}_${SEMAPHORE_JOB_ID}.tar.gz -C /tmp docker-debug-log
artifact push project /tmp/docker-debug-log_${DATE}_${SEMAPHORE_JOB_ID}.tar.gz
