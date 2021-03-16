# Troubleshooting slow docker pushes on Semaphore

## Description of the problem

The performance of third-party tools installed in CI/CD environment needs to be measured. Docker is one of the most commonly used tools on Semaphore. In order to improve the experience of using Docker on Semaphore, we need to start measuring how it performs on our platform.

## How to install and use docker-debug-push script

In order to be aware of the impact of this problem, we have created a wrapper script which reports slow docker pushes to our internal monitoring system.

To start reporting slow docker pushes in your CI/CD pipeline please do the following steps:

### 1. Install docker-debug-push command in job environment with following command

```
curl https://raw.githubusercontent.com/renderedtext/snippets/master/install_docker_debug.sh | bash
```

You can add to global_job_config:
```
global_job_config:
  prologue:
    commands:
      - 'curl https://raw.githubusercontent.com/renderedtext/snippets/master/install_docker_debug.sh | bash'
      ...
```

Or within single block prologue:

```
task:
  prologue:
    commands:
      - 'curl https://raw.githubusercontent.com/renderedtext/snippets/master/install_docker_debug.sh | bash'
      ...
```

Or put the installation command directly to single job command:

```
jobs:
 - name: Docker push
   commands:
      - 'curl https://raw.githubusercontent.com/renderedtext/snippets/master/install_docker_debug.sh | bash'
      ...
```

### 2. Replace docker push commands with new command

Replace calls to `docker push <IMAGE>:<TAG>` command with `docker-debug-push <IMAGE>:<TAG>` command.

Once new command is in place we will start receiving metrics about your docker push durations. This will help us troubleshoot the problem.


