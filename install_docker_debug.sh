#!/bin/bash

curl https://raw.githubusercontent.com/renderedtext/snippets/master/push.sh > /tmp/docker-debug
chmod +x /tmp/docker-debug
sudo mv /tmp/docker-debug /usr/local/bin
