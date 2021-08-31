#!/bin/bash

DATE=$(date +"%F_%H-%M-%S")
tar -czf /tmp/docker-debug-logs_${DATE}_${SEMAPHORE_JOB_ID}.tar.gz -C /tmp docker-debug-logs
artifact push job --expire-in 1w /tmp/docker-debug-logs_${DATE}_${SEMAPHORE_JOB_ID}.tar.gz
