#! /bin/bash

source "$(dirname ${BASH_SOURCE[0]})/common.sh"

###
# gitlab init container script
###

data_path="${1}"

begin_color 6
echo "data path: ${data_path}"
close_color

if [[ ! -d "${data_path}" ]];
then
  mkdir -p "${data_path}"
fi

chown 998:998 "${data_path}"

df -h
ls -lha /assets /config /data

# setup config
config_path="/etc/gitlab"

if [[ -d "${config_path}" ]];
then
  begin_color 7
  echo "config path exists"
  close_color

  config_secrets="${config_path}/gitlab-secrets.json"

  if [[ -f "${config_secrets}" ]];
  then
    begin_color 3
    echo "comparing existing secrets"
    close_color

    diff_secrets="$(diff /config/gitlab-secrets.json "${config_secrets}")"

    if [[ $? != 0 ]];
    then
      echo "${diff_secrets}"
      echo "difference detected in gitlab secrets"
    fi
  fi
fi

mkdir -p "${config_path}"

cp -Lrv /config/* "${config_path}/"

ls -lha "${config_path}"

begin_color 5
echo "config complete"
close_color
