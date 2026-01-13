# modules/s3-tenant-folders/main.tf
# Module logic for creating S3 tenant folder structures

locals {
  # Filter only active tenants
  active_tenants = {
    for key, tenant in var.tenants :
    key => tenant
    if tenant.active == true
  }
  
  # Create folder structure for each tenant in their specified business units in their category's raw bucket
  raw_folders = flatten([
    for tenant_key, tenant in local.active_tenants : [
      for business_unit in tenant.business_units : {
        tenant_key    = tenant_key
        tenant_name   = tenant.tenant_name
        category      = tenant.category
        business_unit = business_unit
        bucket        = var.categories[tenant.category].raw_bucket
        key           = "${business_unit}/${tenant.tenant_name}/"
        bucket_type   = "raw"
      }
    ]
  ])
  
  # Create folder structure for each tenant in their specified business units in their category's staging bucket
  staging_folders = flatten([
    for tenant_key, tenant in local.active_tenants : [
      for business_unit in tenant.business_units : {
        tenant_key    = tenant_key
        tenant_name   = tenant.tenant_name
        category      = tenant.category
        business_unit = business_unit
        bucket        = var.categories[tenant.category].staging_bucket
        key           = "${business_unit}/${tenant.tenant_name}/"
        bucket_type   = "staging"
      }
    ]
  ])
  
  # Create folder structure for each tenant in their specified business units in their category's curated bucket
  curated_folders = flatten([
    for tenant_key, tenant in local.active_tenants : [
      for business_unit in tenant.business_units : {
        tenant_key    = tenant_key
        tenant_name   = tenant.tenant_name
        category      = tenant.category
        business_unit = business_unit
        bucket        = var.categories[tenant.category].curated_bucket
        key           = "${business_unit}/${tenant.tenant_name}/"
        bucket_type   = "curated"
      }
    ]
  ])
  
  # Combine all folders
  all_folders = concat(
    local.raw_folders,
    local.staging_folders,
    local.curated_folders
  )
  
  # Create unique identifiers for each folder
  raw_folder_map = {
    for folder in local.raw_folders :
    "${folder.bucket}/${folder.key}" => folder
  }
  
  staging_folder_map = {
    for folder in local.staging_folders :
    "${folder.bucket}/${folder.key}" => folder
  }
  
  curated_folder_map = {
    for folder in local.curated_folders :
    "${folder.bucket}/${folder.key}" => folder
  }
}

# Create tenant folders in raw buckets
resource "aws_s3_object" "raw_folders" {
  for_each = local.raw_folder_map
  
  bucket  = each.value.bucket
  key     = each.value.key
  content = ""
  
  tags = merge(
    var.common_tags,
    {
      Tenant       = each.value.tenant_name
      Category     = each.value.category
      BusinessUnit = each.value.business_unit
      BucketType   = "raw"
      Purpose      = "Tenant Folder Structure"
    }
  )
}

# Create tenant folders in staging buckets
resource "aws_s3_object" "staging_folders" {
  for_each = local.staging_folder_map
  
  bucket  = each.value.bucket
  key     = each.value.key
  content = ""
  
  tags = merge(
    var.common_tags,
    {
      Tenant       = each.value.tenant_name
      Category     = each.value.category
      BusinessUnit = each.value.business_unit
      BucketType   = "staging"
      Purpose      = "Tenant Folder Structure"
    }
  )
}

# Create tenant folders in curated buckets
resource "aws_s3_object" "curated_folders" {
  for_each = local.curated_folder_map
  
  bucket  = each.value.bucket
  key     = each.value.key
  content = ""
  
  tags = merge(
    var.common_tags,
    {
      Tenant       = each.value.tenant_name
      Category     = each.value.category
      BusinessUnit = each.value.business_unit
      BucketType   = "curated"
      Purpose      = "Tenant Folder Structure"
    }
  )
}

# Validation: Ensure tenant categories exist
resource "null_resource" "validate_tenant_categories" {
  for_each = local.active_tenants
  
  lifecycle {
    precondition {
      condition     = contains(keys(var.categories), each.value.category)
      error_message = "Tenant ${each.key} references category '${each.value.category}' which is not defined in categories variable."
    }
  }
}

# Validation: Ensure tenant business units are valid
resource "null_resource" "validate_tenant_business_units" {
  for_each = local.active_tenants
  
  lifecycle {
    precondition {
      condition = alltrue([
        for bu in each.value.business_units :
        contains(var.business_units, bu)
      ])
      error_message = "Tenant ${each.key} has invalid business_units. All must be one of: ${join(", ", var.business_units)}"
    }
  }
}
