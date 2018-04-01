#! /bin/bash

source "$(dirname ${BASH_SOURCE[0]})/common.sh"

###
# reset a user's password
###

user="${1}"
shift

prev_keys="$(aws iam list-access-keys --user-name "${user}" | jq .AccessKeyMetadata[].AccessKeyId)"
echo "user has $(echo "${prev_keys}" | wc -l) existing keys"

while read key;
do
  echo "removing access key: ${key}"
  aws iam delete-access-key --user-name "${user}" --access-key-id $(echo "${key}" | tr -d '"')
done <<< "${prev_keys}"

keys="$(aws iam create-access-key --user-name "${user}")"
echo "access_key_id: $(echo "${keys}" | jq .AccessKey.AccessKeyId)"
echo "secret_key_id: $(echo "${keys}" | jq .AccessKey.SecretAccessKey)"

next="$(dd if=/dev/random bs=8 count=4 | base64 | tr -d '\n')"
echo "temporary password: ${next}"

prof="$(aws iam get-login-profile --user-name "${user}")"
prof_exists="$(echo "${prof}" | wc -l)"
echo "profile (${prof_exists}): ${prof}"

if [[ "${prof_exists}" == "0" ]];
then
  echo "updating user profile"
  pass="$(aws iam create-login-profile --user-name "${user}" --password "${next}" --password-reset-required)"
  echo "${pass}"
else
  echo "creating user profile"
  pass="$(aws iam update-login-profile --user-name "${user}" --password "${next}" --password-reset-required)"
  echo "${pass}"
fi