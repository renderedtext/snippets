#!/bin/bash

curl https://raw.githubusercontent.com/renderedtext/snippets/master/push.sh > /tmp/docker-debug-push
chmod +x /tmp/docker-debug-push
sudo mv /tmp/docker-debug-push /usr/local/bin/
