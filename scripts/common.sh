#! /bin/bash

if [[ "${DEBUG:-}" != "" ]];
then
  set -Eeuxo pipefail
fi

###
# include all other common scripts
###

source "$(dirname ${0})/common-colors.sh"
source "$(dirname ${0})/common-k8s.sh"
