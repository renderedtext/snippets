#!/bin/bash

curl https://raw.githubusercontent.com/renderedtext/snippets/master/push.sh > /tmp/docker-debug-push
chmod +x /tmp/docker-debug-push
sudo mv /tmp/docker-debug-push /usr/local/bin/

curl https://raw.githubusercontent.com/renderedtext/snippets/master/pull.sh > /tmp/docker-debug-pull
chmod +x /tmp/docker-debug-pull
sudo mv /tmp/docker-debug-pull /usr/local/bin/

curl https://raw.githubusercontent.com/renderedtext/snippets/master/log.sh > /tmp/docker-debug-log
chmod +x /tmp/docker-debug-log
sudo mv /tmp/docker-debug-log /usr/local/bin/

