#!/bin/bash

set -e

if [[ "$DEBUG" == "true" ]];
then
  set -x
fi

docker stack ls


exit 0
