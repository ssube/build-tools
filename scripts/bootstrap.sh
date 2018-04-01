#! /bin/bash

source "$(dirname ${BASH_SOURCE[0]})/common.sh"

###
# bootstrap dependencies
#
# make sure python, pip, ansible, and blackbox are installed
###

echo_confirm "this script will change your system: it updates python and pip, then installs ansible and blackbox"

if [[ -z "$(which python)" ]];
then
  echo "install python"
  apt-get install python
  echo "done."
else
  echo "python is already installed"
fi

if [[ -z "$(which pip)" ]];
then
  echo "install pip"
  apt-get install python-pip
  pip install --upgrade pip
  echo "done."
else
  echo "pip is already installed"
fi

if [[ -z "$(which ansible-playbook)" ]];
then
  echo "installing ansible..."
  pip install ansible
  echo "done."
else
  echo "ansible is already installed"
fi

if [[ -z "$(which blackbox_decrypt_all_files)" ]];
then
  echo "installing blackbox"

  blackbox_pwd=$(mktemp -d -t blackbox.XXXXXXXX)
  git clone git@github.com:StackExchange/blackbox.git "${blackbox_pwd}"
  (cd "${blackbox_pwd}" && echo make manual-install)
  rm -rv "${blackbox_pwd}"
else
  echo "blackbox is already installed"
fi
