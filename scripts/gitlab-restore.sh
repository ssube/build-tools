#! /bin/bash

source "$(dirname ${0})/common.sh"

###
# gitlab restore script
###

backup_name="${1}"
backup_dest="/data/gitlab/backups/${backup_name}_gitlab_backup.tar"
backup_src="s3://${PROJECT_NAME}-backup-prod-primary/${backup_name}_gitlab_backup.tar"
echo "${backup_src}"

# sign the s3 url
presign_url="$(aws s3 presign "${backup_src}" --expires-in 3600)"
echo "${presign_url}"

# restore
gitlab_pod="$(find_pod gitlab)"
echo "running in pod '${gitlab_pod}'..."

exec_in_pod "${gitlab_pod}" ls -lha $(dirname ${backup_dest})
exec_in_pod "${gitlab_pod}" wget -d "${presign_url}" -O "${backup_dest}"
exec_in_pod "${gitlab_pod}" gitlab-rake gitlab:backup:restore BACKUP="${backup_name}"
delete_pod "${gitlab_pod}"
