# Tags
tag_environment = "{{secrets.tags.environment}}"
tag_project     = "{{secrets.tags.project}}"
tag_owner       = "{{secrets.tags.owner}}"

# Region
region_global  = "{{secrets.region.global}}"
region_primary = "{{secrets.region.primary}}"
region_replica = "{{secrets.region.replica}}"

zones_primary = ["{{secrets.region.primary}}a"]
zones_replica = ["{{secrets.region.primary}}b", "{{secrets.region.primary}}c"]

# Domain
domain_zone   = "{{secrets.site.zone}}"
domain_name   = "{{cluster.dns}}"

# Keybase
keybase_proof = "{{secrets.keybase.proof}}"

# Site
site_cert = "{{secrets.site.cert}}"

# Database
database_name = "gitlab"
database_user = "gitlab"
