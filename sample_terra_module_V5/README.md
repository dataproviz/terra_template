# S3 Tenant Folder Structure - Terraform Module

A reusable Terraform module for creating category-based S3 folder structures with configurable business units per tenant.

## Overview

This module automates the creation of S3 folder structures where:
- ✅ Each **category** has 3 buckets: raw, staging, curated
- ✅ Each **tenant** is assigned to ONE category
- ✅ Each tenant specifies which **business units** they need (default: BusinessDEV, BusinessQA)
- ✅ Folders are created automatically based on configuration

## Module Structure

```
s3-category-module/
├── modules/
│   └── s3-tenant-folders/         # Reusable module
│       ├── main.tf
│       ├── variables.tf
│       └── outputs.tf
├── main.tf                         # Root module (calls the module)
├── variables.tf                    # Root variables
├── outputs.tf                      # Root outputs
├── terraform.tfvars.example        # Example configuration
└── README.md                       # This file
```

## Quick Start

### 1. Configure Your Environment

```bash
cp terraform.tfvars.example terraform.tfvars
nano terraform.tfvars
```

### 2. Initialize and Apply

```bash
terraform init
terraform plan
terraform apply
```

## Usage Examples

### Example 1: Basic Usage (Root Module)

```hcl
# main.tf
module "s3_tenant_folders" {
  source = "./modules/s3-tenant-folders"
  
  categories = {
    alpha = {
      raw_bucket     = "my-alpha-raw"
      staging_bucket = "my-alpha-staging"
      curated_bucket = "my-alpha-curated"
      description    = "Enterprise tier"
    }
  }
  
  tenants = {
    tenant1 = {
      tenant_name    = "tenant1"
      category       = "alpha"
      business_units = ["BusinessDEV", "BusinessQA"]
      active         = true
    }
  }
  
  common_tags = {
    Environment = "Production"
    ManagedBy   = "Terraform"
  }
}

# outputs.tf
output "tenant_summary" {
  value = module.s3_tenant_folders.tenant_summary
}
```

### Example 2: Multiple Environments

```hcl
# Production environment
module "s3_prod_folders" {
  source = "./modules/s3-tenant-folders"
  
  categories = {
    production = {
      raw_bucket     = "prod-raw"
      staging_bucket = "prod-staging"
      curated_bucket = "prod-curated"
      description    = "Production"
    }
  }
  
  tenants = {
    app1 = {
      tenant_name    = "app1"
      category       = "production"
      business_units = ["BusinessDEV"]
      active         = true
    }
  }
  
  common_tags = {
    Environment = "Production"
  }
}

# Development environment
module "s3_dev_folders" {
  source = "./modules/s3-tenant-folders"
  
  categories = {
    development = {
      raw_bucket     = "dev-raw"
      staging_bucket = "dev-staging"
      curated_bucket = "dev-curated"
      description    = "Development"
    }
  }
  
  tenants = {
    app1_dev = {
      tenant_name    = "app1_dev"
      category       = "development"
      business_units = ["BusinessDEV", "BusinessQA"]
      active         = true
    }
  }
  
  common_tags = {
    Environment = "Development"
  }
}
```

### Example 3: Remote Module Source

```hcl
# Use from Git repository
module "s3_tenant_folders" {
  source = "git::https://github.com/your-org/terraform-modules.git//s3-tenant-folders?ref=v1.0.0"
  
  categories     = var.categories
  tenants        = var.tenants
  business_units = var.business_units
  common_tags    = var.common_tags
}
```

### Example 4: Terraform Registry (if published)

```hcl
module "s3_tenant_folders" {
  source  = "your-org/s3-tenant-folders/aws"
  version = "~> 1.0"
  
  categories     = var.categories
  tenants        = var.tenants
  business_units = var.business_units
  common_tags    = var.common_tags
}
```

## Module Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| categories | Map of categories with their S3 buckets | `map(object)` | n/a | yes |
| tenants | Map of tenants with category and business unit assignments | `map(object)` | n/a | yes |
| business_units | Valid business unit names | `list(string)` | `["BusinessDEV", "BusinessQA"]` | no |
| common_tags | Common tags to apply to all S3 objects | `map(string)` | `{}` | no |

### Categories Object Structure

```hcl
{
  raw_bucket     = string  # Name of raw S3 bucket
  staging_bucket = string  # Name of staging S3 bucket
  curated_bucket = string  # Name of curated S3 bucket
  description    = string  # Description of this category
}
```

### Tenants Object Structure

```hcl
{
  tenant_name    = string        # Name of the tenant
  category       = string        # Category key (must exist in categories)
  business_units = list(string)  # List of business units for this tenant
  active         = bool          # Whether tenant is active
}
```

## Module Outputs

| Name | Description | Type |
|------|-------------|------|
| tenant_summary | Summary of each tenant's configuration and S3 paths | `map(object)` |
| category_summary | Summary of each category with its tenants | `map(object)` |
| business_unit_summary | Summary of tenants by business unit | `map(list)` |
| all_folders_created | List of all folder paths created | `object` |
| folders_by_category | Folders organized by category | `map(object)` |
| statistics | Overall statistics | `object` |
| bucket_list | Complete list of all buckets | `object` |

## Configuration

### Minimum Configuration

```hcl
module "s3_tenant_folders" {
  source = "./modules/s3-tenant-folders"
  
  categories = {
    alpha = {
      raw_bucket     = "my-raw"
      staging_bucket = "my-staging"
      curated_bucket = "my-curated"
      description    = "Category alpha"
    }
  }
  
  tenants = {
    tenant1 = {
      tenant_name    = "tenant1"
      category       = "alpha"
      business_units = ["BusinessDEV", "BusinessQA"]
      active         = true
    }
  }
}
```

### Full Configuration

```hcl
module "s3_tenant_folders" {
  source = "./modules/s3-tenant-folders"
  
  categories = {
    enterprise = {
      raw_bucket     = "enterprise-raw"
      staging_bucket = "enterprise-staging"
      curated_bucket = "enterprise-curated"
      description    = "Enterprise tier clients"
    }
    standard = {
      raw_bucket     = "standard-raw"
      staging_bucket = "standard-staging"
      curated_bucket = "standard-curated"
      description    = "Standard tier clients"
    }
  }
  
  tenants = {
    acme_corp = {
      tenant_name    = "acme_corp"
      category       = "enterprise"
      business_units = ["BusinessDEV", "BusinessQA"]
      active         = true
    }
    startup1 = {
      tenant_name    = "startup1"
      category       = "standard"
      business_units = ["BusinessDEV"]  # Production only
      active         = true
    }
    startup2 = {
      tenant_name    = "startup2"
      category       = "standard"
      business_units = ["BusinessQA"]  # Testing only
      active         = false  # Inactive
    }
  }
  
  business_units = ["BusinessDEV", "BusinessQA", "BusinessSTAGING"]
  
  common_tags = {
    ManagedBy    = "Terraform"
    Environment  = "Production"
    Project      = "DataPlatform"
    CostCenter   = "Engineering"
  }
}
```

## Resulting Folder Structure

For a tenant with both BusinessDEV and BusinessQA:

```
{category}-raw/
├── BusinessDEV/
│   └── {tenant_name}/
└── BusinessQA/
    └── {tenant_name}/

{category}-staging/
├── BusinessDEV/
│   └── {tenant_name}/
└── BusinessQA/
    └── {tenant_name}/

{category}-curated/
├── BusinessDEV/
│   └── {tenant_name}/
└── BusinessQA/
    └── {tenant_name}/
```

Total: **6 folders** (2 business units × 3 buckets)

## Module Features

✅ **Reusable** - Use in multiple projects and environments  
✅ **Configurable** - Flexible per-tenant business units  
✅ **Validated** - Built-in validation for categories and business units  
✅ **Tagged** - Automatic tagging with tenant, category, and business unit info  
✅ **Safe** - Only manages folder placeholders, never touches actual data  
✅ **Scalable** - Supports unlimited categories and tenants  

## Advanced Usage

### Using with Terraform Workspaces

```hcl
# main.tf
locals {
  environment = terraform.workspace
  
  categories = {
    default = {
      raw_bucket     = "${local.environment}-raw"
      staging_bucket = "${local.environment}-staging"
      curated_bucket = "${local.environment}-curated"
      description    = "${local.environment} environment"
    }
  }
}

module "s3_tenant_folders" {
  source = "./modules/s3-tenant-folders"
  
  categories = local.categories
  tenants    = var.tenants
  
  common_tags = {
    Environment = local.environment
    Workspace   = terraform.workspace
  }
}
```

```bash
# Use with workspaces
terraform workspace new dev
terraform apply

terraform workspace new prod
terraform apply
```

### Dynamic Tenant Configuration

```hcl
# Load tenants from YAML file
locals {
  tenants_yaml = yamldecode(file("${path.module}/tenants.yaml"))
  
  tenants = {
    for tenant in local.tenants_yaml.tenants :
    tenant.id => {
      tenant_name    = tenant.name
      category       = tenant.category
      business_units = tenant.business_units
      active         = tenant.active
    }
  }
}

module "s3_tenant_folders" {
  source = "./modules/s3-tenant-folders"
  
  categories = var.categories
  tenants    = local.tenants
}
```

### Conditional Module Invocation

```hcl
# Only create folders in production
module "s3_tenant_folders" {
  count  = var.environment == "production" ? 1 : 0
  source = "./modules/s3-tenant-folders"
  
  categories = var.categories
  tenants    = var.tenants
}
```

## Testing the Module

### Local Testing

```bash
# Initialize
terraform init

# Validate configuration
terraform validate

# Plan
terraform plan

# Apply
terraform apply

# View outputs
terraform output tenant_summary

# Destroy (for testing)
terraform destroy
```

### Module Testing with Terratest

```go
// test/s3_tenant_folders_test.go
package test

import (
    "testing"
    "github.com/gruntwork-io/terratest/modules/terraform"
)

func TestS3TenantFolders(t *testing.T) {
    terraformOptions := &terraform.Options{
        TerraformDir: "../examples/basic",
    }

    defer terraform.Destroy(t, terraformOptions)
    terraform.InitAndApply(t, terraformOptions)
    
    // Validate outputs
    tenantSummary := terraform.OutputMap(t, terraformOptions, "tenant_summary")
    // Add assertions...
}
```

## Best Practices

### 1. Version Your Module

```hcl
# Use version tags
module "s3_tenant_folders" {
  source = "git::https://github.com/your-org/terraform-modules.git//s3-tenant-folders?ref=v1.0.0"
  
  # ... configuration
}
```

### 2. Separate Configuration Files

```
├── main.tf              # Module calls
├── variables.tf         # Variable definitions
├── terraform.tfvars     # Variable values (don't commit)
├── dev.tfvars          # Dev environment
├── staging.tfvars      # Staging environment
└── prod.tfvars         # Production environment
```

### 3. Use Remote State

```hcl
terraform {
  backend "s3" {
    bucket = "terraform-state-bucket"
    key    = "s3-tenant-folders/terraform.tfstate"
    region = "us-east-1"
  }
}
```

### 4. Organize by Environment

```
environments/
├── dev/
│   ├── main.tf
│   └── terraform.tfvars
├── staging/
│   ├── main.tf
│   └── terraform.tfvars
└── prod/
    ├── main.tf
    └── terraform.tfvars
```

## Troubleshooting

### Module Not Found

```bash
# Ensure module is initialized
terraform init

# If using remote source, check connectivity
terraform init -upgrade
```

### Validation Errors

```bash
# Check that categories exist
terraform validate

# Review error message for guidance
```

### Output Not Available

```bash
# Ensure module has been applied
terraform apply

# Check output name matches module output
terraform output
```

## Migration from Non-Module Version

If you have an existing non-module deployment:

1. **Create module structure**:
   ```bash
   mkdir -p modules/s3-tenant-folders
   # Move main.tf, variables.tf, outputs.tf to modules/s3-tenant-folders/
   ```

2. **Create root main.tf** that calls the module

3. **Import existing resources**:
   ```bash
   terraform import 'module.s3_tenant_folders.aws_s3_object.raw_folders["bucket/path"]' bucket/path
   ```

4. **Verify with plan**:
   ```bash
   terraform plan
   # Should show no changes if import was successful
   ```

## Contributing

To contribute to this module:

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests
5. Submit a pull request

## License

This module is provided as-is for automation purposes.

## Support

For issues or questions:
- Check Terraform AWS provider docs: https://registry.terraform.io/providers/hashicorp/aws/latest/docs
- Review module outputs for debugging
- Check validation error messages

## Version History

- **v1.0.0** - Initial release with module structure
  - Category-based folder organization
  - Configurable business units per tenant
  - Comprehensive outputs
  - Built-in validation
