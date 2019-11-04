#!/bin/bash

set -e

if [[ "$DEBUG" == "true" ]];
then
  set -x
fi

cd orca
./deploy.sh package

exit 0
