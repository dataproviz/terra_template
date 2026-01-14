# examples/multi-environment/main.tf
# Example showing multiple module instances for different environments

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

# Development environment
module "dev_folders" {
  source = "../../modules/s3-tenant-folders"
  
  categories = {
    development = {
      raw_bucket     = "dev-raw"
      staging_bucket = "dev-staging"
      curated_bucket = "dev-curated"
      description    = "Development environment"
    }
  }
  
  tenants = {
    app1_dev = {
      tenant_name    = "app1"
      category       = "development"
      business_units = ["BusinessDEV", "BusinessQA"]
      bucket_types   = ["raw", "staging", "curated"]  # Full pipeline for dev
      active         = true
    }
    app2_dev = {
      tenant_name    = "app2"
      category       = "development"
      business_units = ["BusinessDEV", "BusinessQA"]
      bucket_types   = ["raw", "staging", "curated"]  # Full pipeline for dev
      active         = true
    }
  }
  
  common_tags = {
    ManagedBy   = "Terraform"
    Environment = "Development"
  }
}

# Production environment
module "prod_folders" {
  source = "../../modules/s3-tenant-folders"
  
  categories = {
    production = {
      raw_bucket     = "prod-raw"
      staging_bucket = "prod-staging"
      curated_bucket = "prod-curated"
      description    = "Production environment"
    }
  }
  
  tenants = {
    app1_prod = {
      tenant_name    = "app1"
      category       = "production"
      business_units = ["BusinessDEV"]  # Production only, no QA
      bucket_types   = ["raw", "curated"]  # Direct raw-to-curated (no staging)
      active         = true
    }
    app2_prod = {
      tenant_name    = "app2"
      category       = "production"
      business_units = ["BusinessDEV"]
      bucket_types   = ["raw", "curated"]  # Direct raw-to-curated (no staging)
      active         = true
    }
  }
  
  common_tags = {
    ManagedBy   = "Terraform"
    Environment = "Production"
  }
}

# Outputs for development
output "dev_tenant_summary" {
  description = "Development tenant summary"
  value       = module.dev_folders.tenant_summary
}

output "dev_statistics" {
  description = "Development statistics"
  value       = module.dev_folders.statistics
}

# Outputs for production
output "prod_tenant_summary" {
  description = "Production tenant summary"
  value       = module.prod_folders.tenant_summary
}

output "prod_statistics" {
  description = "Production statistics"
  value       = module.prod_folders.statistics
}
