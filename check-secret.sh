#!/bin/bash

export SECRET=$1
export PROJECT=$2
export PIPELINE=$3
export BRANCH=$4

if ! which yq; then
  pip install yq
  export PATH=~/.local/bin:$PATH
fi

cat "$SEMAPHORE_YAML_FILE_PATH" | yq --raw-output '.. | objects | select(has("secrets")) | .secrets | .[].name' > /tmp/secrets.txt

echo "Checking if the usage of $SECRET is allowed in this pipeline."

if grep -q $SECRET /tmp/secrets.txt; then

  if [ "$SEMAPHORE_PROJECT_NAME" != "$PROJECT" ]; then
    echo "You can't use $SECRET in the $SEMAPHORE_PROJECT_NAME project."
    exit 1
  fi

  if [ "$SEMAPHORE_YAML_FILE_PATH" != "$PIPELINE" ]; then
    echo "You can't use $SECRET in the $SEMAPHORE_YAML_FILE_PATH pipeline."
    exit 1
  fi

  if [ "$SEMAPHORE_GIT_BRANCH" != "$BRANCH" ]; then
    echo "You can't use $SECRET on the $SEMAPHORE_GIT_BRANCH branch."
    exit 1
  fi

  echo "Checked. Usage is allowed in project=$SEMAPHORE_PROJECT_NAME pipeline=$SEMAPHORE_YAML_FILE_PATH branch=$SEMAPHORE_GIT_BRANCH."
  echo ""
else
  echo "Checked. Secret $SECRET is not used in this pipeline."
  echo ""
fi
