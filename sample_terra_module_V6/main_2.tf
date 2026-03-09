# modules/s3-tenant-folders/main.tf
#
# Folder prefix rule:
#   prod  → s3://<bucket>/<tenant_name>/
#   other → s3://<bucket>/<tenant_name>_<env>/   (e.g. tenant_dev/, tenant_test/)

locals {
  active_tenants = {
    for k, v in var.tenants : k => v
    if v.active == true
  }

  # Resolve which bucket belongs to each bucket_type
  bucket_for_type = {
    default = "default_bucket"
    raw     = "raw_bucket"
    staging = "staging_bucket"
    curated = "curated_bucket"
  }

  # For every combination of (tenant, bucket_type, env) produce one folder entry.
  # bucket_type is skipped if not in tenant.bucket_types or its bucket is null.
  folder_entries = flatten([
    for tenant_key, tenant in local.active_tenants : flatten([
      for bucket_type in tenant.bucket_types : flatten([
        for env in tenant.environments : {
          key         = "${tenant_key}/${bucket_type}/${env}"
          bucket_type = bucket_type
          env         = env
          # prod gets a clean prefix; all other envs get _<env> suffix
          prefix      = env == "prod" ? "${tenant_key}/" : "${tenant_key}_${env}/"
          bucket = (
            bucket_type == "default" ? tenant.default_bucket :
            bucket_type == "raw"     ? tenant.raw_bucket     :
            bucket_type == "staging" ? tenant.staging_bucket :
            bucket_type == "curated" ? tenant.curated_bucket :
            null
          )
        }
        if (
          bucket_type == "default" ? true :
          bucket_type == "raw"     ? tenant.raw_bucket     != null :
          bucket_type == "staging" ? tenant.staging_bucket != null :
          bucket_type == "curated" ? tenant.curated_bucket != null :
          false
        )
      ])
    ])
  ])

  folders_map = {
    for entry in local.folder_entries : entry.key => entry
  }
}

resource "aws_s3_object" "tenant_folders" {
  for_each = local.folders_map

  bucket  = each.value.bucket
  key     = each.value.prefix
  content = ""

  tags = merge(var.common_tags, {
    TenantName  = split("/", each.key)[0]
    BucketType  = each.value.bucket_type
    Environment = each.value.env
  })
}
