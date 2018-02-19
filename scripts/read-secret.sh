#! /bin/bash

source "$(dirname ${0})/common.sh"

###
# read secret script
#
# read the value of a secret from the decrypted yml
###

secret_file="${1}"
secret_key="${2}"
secret_default="${3:-}"

if [[ ! -f "${secret_file}" ]]; 
then
  echo "secrets file does not exist"
  exit 1
fi

if [[ ! -r "${secret_file}" ]];
then
  echo "unable to read secrets file"
  exit 1
fi

secret_value="$(yq "${secret_key} // empty" ${secret_file} | tr -d '"')"

if [[ -z "${secret_value}" ]];
then
  echo "${secret_default}"
  exit -1
fi

echo "${secret_value}"
exit 0