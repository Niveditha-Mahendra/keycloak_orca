#!/bin/bash

set -e

if [[ "$DEBUG" == "true" ]];
then
  set -x
fi

read -p "Did you double-check the values in 'config' to be the correct ones? [y/N] " -n 1 -r
echo

if [[ $REPLY =~ ^[Yy]$ ]];
then
  echo "Ok, then we can go ahead."
else
  echo "Please do that before we can go ahead. Exiting for now."
  exit 1
fi

exit 0
