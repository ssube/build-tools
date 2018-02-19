#! /bin/bash

source "$(dirname ${0})/common.sh"

###
# gitlab backup script
###

gitlab_pod="$(find_pod gitlab)"
exec_in_pod "${gitlab_pod}" gitlab-rake gitlab:backup:create
