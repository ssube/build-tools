#! /bin/bash

if [[ "${DEBUG:-}" != "" ]];
then
  set -Eeuxo pipefail
fi

###
# common functions
###

# echo a confirmation
# from https://stackoverflow.com/a/1885534/129032
function echo_confirm() {
  msg="${1}"

  (>&2 echo "${msg}")

  read -p "Continue? " -r
  echo

  if [[ "${REPLY:-n}" =~ ^[Yy] ]];
  then
    : # continue
  else
    echo_error "canceled by user."
  fi
}

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
