# variables.tf
# Root-level variables

variable "categories" {
  description = "Map of categories with their S3 buckets (raw, staging, curated)"
  type = map(object({
    raw_bucket     = string
    staging_bucket = string
    curated_bucket = string
    description    = string
  }))
  
  default = {
    alpha = {
      raw_bucket     = "company-alpha-raw"
      staging_bucket = "company-alpha-staging"
      curated_bucket = "company-alpha-curated"
      description    = "Alpha category for enterprise clients"
    }
    beta = {
      raw_bucket     = "company-beta-raw"
      staging_bucket = "company-beta-staging"
      curated_bucket = "company-beta-curated"
      description    = "Beta category for standard clients"
    }
  }
}

variable "tenants" {
  description = "Map of tenants with their category and business unit assignments"
  type = map(object({
    tenant_name    = string
    category       = string
    business_units = list(string)
    active         = bool
  }))
  
  default = {
    tenant1 = {
      tenant_name    = "tenant1"
      category       = "alpha"
      business_units = ["BusinessDEV", "BusinessQA"]
      active         = true
    }
    tenant2 = {
      tenant_name    = "tenant2"
      category       = "beta"
      business_units = ["BusinessDEV", "BusinessQA"]
      active         = true
    }
    tenant3 = {
      tenant_name    = "tenant3"
      category       = "beta"
      business_units = ["BusinessDEV"]
      active         = true
    }
  }
}

variable "business_units" {
  description = "Valid business unit names"
  type        = list(string)
  default     = ["BusinessDEV", "BusinessQA"]
}

variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "common_tags" {
  description = "Common tags to apply to all resources"
  type        = map(string)
  default = {
    ManagedBy   = "Terraform"
    Environment = "Production"
  }
}
