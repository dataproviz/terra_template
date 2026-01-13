# modules/s3-tenant-folders/outputs.tf
# Module outputs

output "tenant_summary" {
  description = "Summary of each tenant's configuration and S3 paths"
  value = {
    for tenant_key, tenant in local.active_tenants :
    tenant.tenant_name => {
      category       = tenant.category
      business_units = tenant.business_units
      buckets = {
        raw     = var.categories[tenant.category].raw_bucket
        staging = var.categories[tenant.category].staging_bucket
        curated = var.categories[tenant.category].curated_bucket
      }
      paths = {
        for bu in tenant.business_units :
        bu => {
          raw     = "${var.categories[tenant.category].raw_bucket}/${bu}/${tenant.tenant_name}/"
          staging = "${var.categories[tenant.category].staging_bucket}/${bu}/${tenant.tenant_name}/"
          curated = "${var.categories[tenant.category].curated_bucket}/${bu}/${tenant.tenant_name}/"
        }
      }
    }
  }
}

output "category_summary" {
  description = "Summary of each category with its tenants"
  value = {
    for category_key, category in var.categories :
    category_key => {
      description = category.description
      buckets = {
        raw     = category.raw_bucket
        staging = category.staging_bucket
        curated = category.curated_bucket
      }
      tenants = [
        for tenant_key, tenant in local.active_tenants :
        tenant.tenant_name
        if tenant.category == category_key
      ]
      tenant_count = length([
        for tenant in local.active_tenants :
        tenant if tenant.category == category_key
      ])
    }
  }
}

output "business_unit_summary" {
  description = "Summary of tenants by business unit"
  value = {
    for bu in var.business_units :
    bu => [
      for tenant_key, tenant in local.active_tenants :
      {
        tenant_name = tenant.tenant_name
        category    = tenant.category
      }
      if contains(tenant.business_units, bu)
    ]
  }
}

output "all_folders_created" {
  description = "List of all folder paths created"
  value = {
    raw = [
      for folder in local.raw_folders :
      "${folder.bucket}/${folder.key}"
    ]
    staging = [
      for folder in local.staging_folders :
      "${folder.bucket}/${folder.key}"
    ]
    curated = [
      for folder in local.curated_folders :
      "${folder.bucket}/${folder.key}"
    ]
  }
}

output "folders_by_category" {
  description = "Folders organized by category"
  value = {
    for category_key in keys(var.categories) :
    category_key => {
      raw = [
        for folder in local.raw_folders :
        "${folder.bucket}/${folder.key}"
        if folder.category == category_key
      ]
      staging = [
        for folder in local.staging_folders :
        "${folder.bucket}/${folder.key}"
        if folder.category == category_key
      ]
      curated = [
        for folder in local.curated_folders :
        "${folder.bucket}/${folder.key}"
        if folder.category == category_key
      ]
    }
  }
}

output "statistics" {
  description = "Overall statistics"
  value = {
    total_active_tenants  = length(local.active_tenants)
    total_categories      = length(var.categories)
    total_folders_created = length(local.all_folders)
    tenants_by_category = {
      for category_key in keys(var.categories) :
      category_key => length([
        for tenant in local.active_tenants :
        tenant if tenant.category == category_key
      ])
    }
    tenants_by_business_unit = {
      for bu in var.business_units :
      bu => length([
        for tenant in local.active_tenants :
        tenant if contains(tenant.business_units, bu)
      ])
    }
  }
}

output "bucket_list" {
  description = "Complete list of all buckets across all categories"
  value = {
    raw     = [for cat in var.categories : cat.raw_bucket]
    staging = [for cat in var.categories : cat.staging_bucket]
    curated = [for cat in var.categories : cat.curated_bucket]
    all     = distinct(flatten([
      [for cat in var.categories : cat.raw_bucket],
      [for cat in var.categories : cat.staging_bucket],
      [for cat in var.categories : cat.curated_bucket]
    ]))
  }
}
