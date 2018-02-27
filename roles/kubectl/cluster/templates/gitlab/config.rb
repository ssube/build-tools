external_url 'https://git.{{secrets.tags.project}}.{{secrets.dns.base}}'

gitlab_rails['extra_google_analytics_id'] = '{{secrets.google.analytics}}'
gitlab_rails['gitlab_username_changing_enabled'] = false
gitlab_rails['webhook_timeout'] = 2

# defaults
gitlab_rails['gitlab_default_can_create_group'] = false
gitlab_rails['gitlab_default_projects_features_issues'] = true
gitlab_rails['gitlab_default_projects_features_merge_requests'] = true
gitlab_rails['gitlab_default_projects_features_wiki'] = true
gitlab_rails['gitlab_default_projects_features_snippets'] = false
gitlab_rails['gitlab_default_projects_features_builds'] = true
gitlab_rails['gitlab_default_projects_features_container_registry'] = false

# gravatar
gitlab_rails['gravatar_plain_url'] = 'http://www.gravatar.com/avatar/%{hash}?s=%{size}&d=identicon'
gitlab_rails['gravatar_ssl_url'] = 'https://secure.gravatar.com/avatar/%{hash}?s=%{size}&d=identicon'

# email
gitlab_rails['gitlab_email_enabled'] = false
gitlab_rails['incoming_email_enabled'] = false

# artifacts
gitlab_rails['artifacts_enabled'] = true
gitlab_rails['artifacts_path'] = "{{secrets.gitlab.data}}/artifacts"

# lfs
gitlab_rails['lfs_enabled'] = true
gitlab_rails['lfs_storage_path'] = "{{secrets.gitlab.data}}/lfs-objects"

# pages
gitlab_rails['pages_path'] = "{{secrets.gitlab.data}}/pages"

# ldap
gitlab_rails['ldap_enabled'] = true
gitlab_rails['ldap_servers'] = YAML.load <<-EOS
main:
  label: 'foxpass'

  host: '{{secrets.gitlab.ldap.host}}'
  port: 636
  uid: 'uid'

  bind_dn: '{{secrets.gitlab.ldap.user}},{{secrets.gitlab.ldap.base}}'
  password: '{{secrets.gitlab.ldap.pass}}'

  encryption: 'simple_tls'
  verify_certificates: true

  timeout: 10
  active_directory: false

  allow_username_or_email_login: true
  block_auto_created_users: true

  base: '{{secrets.gitlab.ldap.base}}'
  user_filter: ''

  attributes:
    username: ['uid', 'userid', 'sAMAccountName']
    email:    ['mail', 'email', 'userPrincipalName']
    name:       'cn'
    first_name: 'givenName'
    last_name:  'sn'

  lowercase_usernames: true

  group_base: 'ou=groups,{{secrets.gitlab.ldap.base}}'
  admin_group: 'admins'

  sync_ssh_keys: true

EOS

# backups
gitlab_rails['manage_backup_path'] = true
gitlab_rails['backup_path'] = "{{secrets.gitlab.data}}/backups"
gitlab_rails['backup_archive_permissions'] = 0644
gitlab_rails['backup_pg_schema'] = 'public'
gitlab_rails['backup_keep_time'] = 604800
gitlab_rails['backup_upload_connection'] = {
  'provider'        => 'AWS',
  'region'          => '{{ secrets.region.primary }}',
  'use_iam_profile' => true
}
gitlab_rails['backup_upload_remote_directory'] = '{{output.backup.bucket.primary}}'

# data
git_data_dirs({
  "default": {
    "path": "{{secrets.gitlab.data}}"
  }
})

gitlab_rails['shared_path'] = '{{secrets.gitlab.data}}/shared'

gitlab_rails['git_max_size'] = 20971520
gitlab_rails['git_timeout'] = 10

# database
postgresql['enable'] = false

gitlab_rails['db_adapter'] = "postgresql"
gitlab_rails['db_encoding'] = "unicode"
gitlab_rails['db_database'] = "{{output.database.name}}"
gitlab_rails['db_pool'] = 4
gitlab_rails['db_username'] = "{{output.database.user}}"
gitlab_rails['db_password'] = "{{output.database.pass}}"
gitlab_rails['db_host'] = "{{output.database.host}}"
gitlab_rails['db_port'] = 5432

# nginx
nginx['listen_port'] = 80
nginx['listen_https'] = false
nginx['proxy_set_headers'] = {
  "X-Forwarded-Proto" => "https",
  "X-Forwarded-Ssl"   => "on"
}

# kubernetes
gitlab_rails['monitoring_whitelist'] = ['127.0.0.0/8', '10.0.0.0/8', '100.0.0.0/8']

# prometheus
prometheus['enable'] = false

# redis
redis['enable'] = false

gitlab_rails['redis_host'] = "{{output.cache.hosts[0].address}}"
gitlab_rails['redis_port'] = {{output.cache.hosts[0].port | int}}

# shell
gitlab_rails['gitlab_shell_ssh_port'] = 22
gitlab_shell['audit_usernames'] = true
gitlab_shell['auth_file'] = "{{secrets.gitlab.data}}/ssh/authorized_keys"