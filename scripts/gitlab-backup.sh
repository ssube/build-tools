#! /bin/bash

source "$(dirname ${BASH_SOURCE[0]})/common.sh"

###
# gitlab backup script
###

begin_color $(std_color start)
echo "Starting backup: $(date)"
close_color

gitlab_pod="$(find_pod gitlab)"
exec_in_pod "${gitlab_pod}" gitlab-rake gitlab:backup:create SKIP=artifacts,builds,registry

begin_color $(std_color success)
echo "Finished backup: $(date)"
close_color
