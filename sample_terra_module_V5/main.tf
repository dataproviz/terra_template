# main.tf
# Root module that calls the s3-tenant-folders module

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
  region = var.aws_region
}

# Call the s3-tenant-folders module
module "s3_tenant_folders" {
  source = "./modules/s3-tenant-folders"
  
  categories     = var.categories
  tenants        = var.tenants
  business_units = var.business_units
  common_tags    = var.common_tags
}
