# Troubleshooting slow docker pushes on Semaphore

## Description of the problem

The performance of third-party tools installed in CI/CD environment needs to be measured. Docker is one of the most commonly used tools on Semaphore. In order to improve the experience of using Docker on Semaphore, we need to start measuring how it performs on our platform.

## How to install and use docker-debug-push script

In order to be aware of the docker push performance, we have created a wrapper script which reports docker pushes durations to our internal monitoring system.

To start reporting slow docker pushes in your CI/CD pipeline please do the following steps:

### 1. Install docker-debug-push command in job environment

Add the following command to your semaphore YAML:

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

### 3. Use the semaphore YAML with new docker push command in your main branches

For most organizations this step means merging the change in CI/CD pipeline to the master branch. This will help us get the graph which depicts more closely how often poor docker push performance occurs on your Semaphore project.
