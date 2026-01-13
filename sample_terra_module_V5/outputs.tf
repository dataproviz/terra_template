# outputs.tf
# Root-level outputs (pass through from module)

output "tenant_summary" {
  description = "Summary of each tenant's configuration and S3 paths"
  value       = module.s3_tenant_folders.tenant_summary
}

output "category_summary" {
  description = "Summary of each category with its tenants"
  value       = module.s3_tenant_folders.category_summary
}

output "business_unit_summary" {
  description = "Summary of tenants by business unit"
  value       = module.s3_tenant_folders.business_unit_summary
}

output "all_folders_created" {
  description = "List of all folder paths created"
  value       = module.s3_tenant_folders.all_folders_created
}

output "folders_by_category" {
  description = "Folders organized by category"
  value       = module.s3_tenant_folders.folders_by_category
}

output "statistics" {
  description = "Overall statistics"
  value       = module.s3_tenant_folders.statistics
}

output "bucket_list" {
  description = "Complete list of all buckets across all categories"
  value       = module.s3_tenant_folders.bucket_list
}
