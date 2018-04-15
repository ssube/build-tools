#! /bin/bash

BUILD_TOOLS_ROOT="$(dirname ${BASH_SOURCE[0]})"

if [[ "${DEBUG:-}" != "" ]];
then
  set -Eeuxo pipefail || set -x
fi

###
# common functions
###

# echo with a color
function echo_color() {
  color="${1}"
  shift
  msg="${@}"

  if [[ "${color}" =~ '^[0-9]+$' ]];
  then
    begin_color ${color}
  else
    begin_color $(std_color ${color})
  fi

  echo "${msg}"
  close_color
}

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

  (>&2 echo "error: ${error_msg}")

  if [[ ! -z "${msg}" ]];
  then
    echo "${msg}"
  fi

  sleep 5
  exit 1
}

###
# include all other common scripts
###

source "${BUILD_TOOLS_ROOT}/common-colors.sh"
source "${BUILD_TOOLS_ROOT}/common-k8s.sh"
