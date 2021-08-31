# Troubleshooting slow docker performance on Semaphore

## Description of the problem

The performance of third-party tools installed in CI/CD environment needs to be measured. Docker is one of the most commonly used tools on Semaphore. In order to improve the experience of using Docker on Semaphore, we need to start measuring how it performs on our platform.

## How to install and use debug scripts

In order to be aware of the docker performance, we have created wrapper scripts that will generate reports for docker push|pull durations.

To start reporting slow docker performance in your CI/CD pipeline please do the following steps:

### 1. Install docker-debug-push|docker-debug-pull commands in a job environment

Add the following command to your semaphore YAML:

```
curl https://raw.githubusercontent.com/renderedtext/snippets/master/install_docker_debug.sh | bash
```

A) You can add to global_job_config:
```
global_job_config:
  prologue:
    commands:
      - curl https://raw.githubusercontent.com/renderedtext/snippets/master/install_docker_debug.sh | bash
      ...
```

B) Or within single block prologue:

```
task:
  prologue:
    commands:
      - curl https://raw.githubusercontent.com/renderedtext/snippets/master/install_docker_debug.sh | bash
      ...
```

C) Or put the installation command at the beginning before other job commands:

```
jobs:
  - name: Docker push
    commands:
      - curl https://raw.githubusercontent.com/renderedtext/snippets/master/install_docker_debug.sh | bash
      ...
```

### 2. Replace docker push|pull commands with a new command

Replace calls to `docker push <IMAGE>:<TAG>` command with `docker-debug-push <IMAGE>:<TAG>` command.
Replace calls to `docker pull <IMAGE>:<TAG>` command with `docker-debug-pull <IMAGE>:<TAG>` command.

### 3. Upload logs as artifacts and sent them to support

Scripts will generate logs for every called push|pull in `/tmp/docker-debug-log` directory and they need to be pushed to artifacts and sent to the support for evaluation.
For that you can use `docker-debug-log` scripts at the end of each job for which you gathered docker logs.
Script will push `/tmp/docker-debug-log_${DATE}_${SEMAPHORE_JOB_ID}.tar.gz` archive to project artifacts.

```
jobs:
  - name: Docker push
    commands:
      - curl https://raw.githubusercontent.com/renderedtext/snippets/master/install_docker_debug.sh | bash
      - docker-debug-pull mariadb:latest
      - docker-debug-pull php:latest
      - docker-debug-log
```
Get the logs from the project artifacts and send them to the support.

### 4. Notes

Due to the additional commands for log gathering push and pull commands migh take up to 15 sec longer.

In case you are concerned about introducing the script to your CI/CD pipeline, you can have a look at its code for [push.sh](https://github.com/renderedtext/snippets/blob/master/push.sh), [pull.sh](https://github.com/renderedtext/snippets/blob/master/pull.sh) or [log.sh](https://github.com/renderedtext/snippets/blob/master/log.sh) scripts in this repository. 

For any additional concerns about the script please contact us through Semaphore support.
