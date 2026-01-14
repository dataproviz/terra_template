# examples/basic/main.tf
# Basic example of using the s3-tenant-folders module

terraform {
  required_version = ">= 1.0"
  
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

# Call the module
module "s3_tenant_folders" {
  source = "../../modules/s3-tenant-folders"
  
  categories = {
    production = {
      raw_bucket     = "my-company-prod-raw"
      staging_bucket = "my-company-prod-staging"
      curated_bucket = "my-company-prod-curated"
      description    = "Production environment"
    }
  }
  
  tenants = {
    app1 = {
      tenant_name    = "app1"
      category       = "production"
      business_units = ["BusinessDEV", "BusinessQA"]
      bucket_types   = ["raw", "staging", "curated"]  # Full pipeline
      active         = true
    }
    app2 = {
      tenant_name    = "app2"
      category       = "production"
      business_units = ["BusinessDEV"]  # Production only
      bucket_types   = ["raw", "curated"]  # No staging needed
      active         = true
    }
  }
  
  common_tags = {
    ManagedBy   = "Terraform"
    Environment = "Production"
    Example     = "Basic"
  }
}

# Output the results
output "tenant_summary" {
  description = "Summary of tenant configurations"
  value       = module.s3_tenant_folders.tenant_summary
}

output "statistics" {
  description = "Overall statistics"
  value       = module.s3_tenant_folders.statistics
}
