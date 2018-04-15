#! /bin/bash

source "$(dirname ${BASH_SOURCE[0]})/common.sh"

###
# gitlab backup script
###

echo_color start "Starting backup: $(date)"

gitlab_pod="$(find_pod gitlab)"
exec_in_pod "${gitlab_pod}" gitlab-rake gitlab:backup:create SKIP=artifacts,builds,registry

echo_color success "Finished backup: $(date)"
