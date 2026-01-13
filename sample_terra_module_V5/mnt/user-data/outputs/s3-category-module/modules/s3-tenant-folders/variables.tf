# modules/s3-tenant-folders/variables.tf
# Module input variables

variable "categories" {
  description = "Map of categories with their S3 buckets (raw, staging, curated)"
  type = map(object({
    raw_bucket     = string
    staging_bucket = string
    curated_bucket = string
    description    = string
  }))
}

variable "tenants" {
  description = "Map of tenants with their category and business unit assignments"
  type = map(object({
    tenant_name    = string
    category       = string
    business_units = list(string)
    active         = bool
  }))
}

variable "business_units" {
  description = "Valid business unit names"
  type        = list(string)
  default     = ["BusinessDEV", "BusinessQA"]
}

variable "common_tags" {
  description = "Common tags to apply to all S3 objects"
  type        = map(string)
  default     = {}
}
