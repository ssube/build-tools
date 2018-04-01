#! /bin/bash

source "$(dirname ${BASH_SOURCE[0]})/common.sh"

###
# read secret script
#
# read the value of a secret from the decrypted yml
###

secret_file="${1}"
secret_key="${2}"
secret_default="${3:-}"

if [[ -z "$(which yq)" ]];
then
  echo_error "yq is missing" "${secret_default}"
fi

if [[ ! -f "${secret_file}" ]]; 
then
  echo_error "secrets file does not exist" "${secret_default}"
fi

if [[ ! -r "${secret_file}" ]];
then
  echo_error "unable to read secrets file" "${secret_default}"
fi

secret_value="$(yq "${secret_key} // empty" ${secret_file} | tr -d '"')"

if [[ -z "${secret_value}" ]];
then
  echo "${secret_default}"
  exit -1
fi

echo "${secret_value}"
exit 0