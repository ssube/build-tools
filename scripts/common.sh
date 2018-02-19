#! /bin/bash

if [[ "${DEBUG:-}" != "" ]];
then
  set -Eeuxo pipefail
fi

###
# common functions
###

# echo an error
# this function never returns
# from https://stackoverflow.com/a/23550347/129032
function echo_error() {
  error_msg="${1}"
  msg="${2}"

  (>&2 echo "${error_msg}")

  if [[ ! -z "${msg}" ]];
  then
    echo "${msg}"
  fi

  exit 1
}

###
# include all other common scripts
###

source "$(dirname ${0})/common-colors.sh"
source "$(dirname ${0})/common-k8s.sh"
