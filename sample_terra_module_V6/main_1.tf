# modules/s3-tenant-folders/main.tf
#
# Folder pattern per bucket:
#   s3://<bucket>/<tenant_name>/       ← prod
#   s3://<bucket>/<tenant_name>_dev/   ← dev

locals {
  active_tenants = {
    for k, v in var.tenants : k => v
    if v.active == true
  }

  # For each active tenant, emit one prod + one dev entry per bucket_type the
  # tenant has opted into. The null check on the bucket name is a safety guard —
  # the primary opt-in mechanism is contains(tenant.bucket_types, <type>).
  folder_entries = flatten([
    for tenant_key, tenant in local.active_tenants : flatten([

      # ── default bucket (always present) ─────────────────────────────────
      [
        {
          key         = "${tenant_key}/default/prod"
          bucket      = tenant.default_bucket
          prefix      = "${tenant_key}/"        # s3://<bucket>/<tenant_name>/
          bucket_type = "default"
          env         = "prod"
        },
        {
          key         = "${tenant_key}/default/dev"
          bucket      = tenant.default_bucket
          prefix      = "${tenant_key}_dev/"    # s3://<bucket>/<tenant_name>_dev/
          bucket_type = "default"
          env         = "dev"
        },
      ],

      # ── raw bucket (optional) ────────────────────────────────────────────
      contains(tenant.bucket_types, "raw") && tenant.raw_bucket != null ? [
        {
          key         = "${tenant_key}/raw/prod"
          bucket      = tenant.raw_bucket
          prefix      = "${tenant_key}/"        # s3://<raw_bucket>/<tenant_name>/
          bucket_type = "raw"
          env         = "prod"
        },
        {
          key         = "${tenant_key}/raw/dev"
          bucket      = tenant.raw_bucket
          prefix      = "${tenant_key}_dev/"    # s3://<raw_bucket>/<tenant_name>_dev/
          bucket_type = "raw"
          env         = "dev"
        },
      ] : [],

      # ── staging bucket (optional) ────────────────────────────────────────
      contains(tenant.bucket_types, "staging") && tenant.staging_bucket != null ? [
        {
          key         = "${tenant_key}/staging/prod"
          bucket      = tenant.staging_bucket
          prefix      = "${tenant_key}/"        # s3://<staging_bucket>/<tenant_name>/
          bucket_type = "staging"
          env         = "prod"
        },
        {
          key         = "${tenant_key}/staging/dev"
          bucket      = tenant.staging_bucket
          prefix      = "${tenant_key}_dev/"    # s3://<staging_bucket>/<tenant_name>_dev/
          bucket_type = "staging"
          env         = "dev"
        },
      ] : [],

      # ── curated bucket (optional) ────────────────────────────────────────
      contains(tenant.bucket_types, "curated") && tenant.curated_bucket != null ? [
        {
          key         = "${tenant_key}/curated/prod"
          bucket      = tenant.curated_bucket
          prefix      = "${tenant_key}/"        # s3://<curated_bucket>/<tenant_name>/
          bucket_type = "curated"
          env         = "prod"
        },
        {
          key         = "${tenant_key}/curated/dev"
          bucket      = tenant.curated_bucket
          prefix      = "${tenant_key}_dev/"    # s3://<curated_bucket>/<tenant_name>_dev/
          bucket_type = "curated"
          env         = "dev"
        },
      ] : [],

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
    TenantName  = each.value.key != null ? split("/", each.key)[0] : ""
    BucketType  = each.value.bucket_type
    Environment = each.value.env
  })
}
