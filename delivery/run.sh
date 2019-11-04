#!/bin/bash

set -e
set -o pipefail

export root="$(dirname "$0")"
source $root/config

LOG_FILE=deployment-$(date "+%Y%m%d-%H%M").log

./00_preflight_checks.sh |& tee -a $LOG_FILE
./10_import_images.sh |& tee -a $LOG_FILE
./20_execute_deployment.sh |& tee -a $LOG_FILE
./30_verify_deployment.sh |& tee -a $LOG_FILE

exit 0
