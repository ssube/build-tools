#! /bin/bash
set -Eeuxo pipefail

###
# gitlab runner setup
#
# register a runner, then replace the config from a template
###

RUNNER_CONFIG="/etc/gitlab-runner/config.toml"

echo "Registering new runner..."
gitlab-runner register \
  --non-interactive --name runner \
{% if 'url' in secrets.gitlab %}
  --url 'https://{{ secrets.gitlab.url }}' \
{% else %}
  --url "https://git.{{ secrets.tags.project }}.{{ secrets.dns.base }}" \
{% endif %}
  --registration-token {{secrets.runner.token}} \
  --executor kubernetes --kubernetes-namespace gitlab-jobs \
  --tag-list "{{runner_tags}}"

echo "Replacing config..."
RUNNER_TOKEN="$(cat ${RUNNER_CONFIG} | grep token | head -n 1 | sed 's/.*token = "\(.*\)"/\1/')"
cp /config/config.toml ${RUNNER_CONFIG}
sed -i "s/TOKEN/${RUNNER_TOKEN}/g" ${RUNNER_CONFIG}

echo "Verifying runner config..."
cat ${RUNNER_CONFIG}
gitlab-runner verify

echo "Starting runner..."
gitlab-runner run