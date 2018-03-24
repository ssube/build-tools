#! /bin/bash

source "$(dirname ${0})/common.sh"

###
# convert an environment name to a top-level domain name
#
# just a switch
###

DEPLOY_ENV="${1:-test}"

case ${DEPLOY_ENV} in
test)
  echo "net"
  ;;
prod)
  echo "com"
  ;;
*)
  echo "cloud"
  ;;
esac