# Quick Start - S3 Tenant Folders Module

## 🎯 What is This?

A reusable Terraform **module** that creates S3 folder structures organized by categories and tenants with configurable business units.

## 📦 Module vs Non-Module

**Module** = Reusable component that you can call multiple times

```hcl
# Call the module
module "my_folders" {
  source = "./modules/s3-tenant-folders"
  
  categories = {...}
  tenants    = {...}
}
```

**Benefits:**
- ✅ Reusable across projects
- ✅ Can create multiple instances (dev, prod, etc.)
- ✅ Easier to version and share
- ✅ Cleaner code organization

## 🚀 Quick Start

### 1. Project Structure

```
your-project/
├── modules/
│   └── s3-tenant-folders/     # The module
│       ├── main.tf
│       ├── variables.tf
│       └── outputs.tf
├── main.tf                     # Calls the module
├── variables.tf
├── outputs.tf
└── terraform.tfvars
```

### 2. Call the Module

Create `main.tf`:

```hcl
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
  source = "./modules/s3-tenant-folders"
  
  categories = var.categories
  tenants    = var.tenants
  common_tags = var.common_tags
}
```

### 3. Create Configuration

Create `terraform.tfvars`:

```hcl
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
```

### 4. Deploy

```bash
terraform init
terraform plan
terraform apply
```

## 📋 Basic Examples

### Example 1: Single Environment

```hcl
# main.tf
module "s3_folders" {
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
      business_units = ["BusinessDEV", "BusinessQA"]
      active         = true
    }
  }
}

# View outputs
output "summary" {
  value = module.s3_folders.tenant_summary
}
```

### Example 2: Multiple Environments

```hcl
# Development
module "dev_folders" {
  source = "./modules/s3-tenant-folders"
  
  categories = {
    dev = {
      raw_bucket     = "dev-raw"
      staging_bucket = "dev-staging"
      curated_bucket = "dev-curated"
      description    = "Development"
    }
  }
  
  tenants = {
    app1 = {
      tenant_name    = "app1"
      category       = "dev"
      business_units = ["BusinessDEV", "BusinessQA"]
      active         = true
    }
  }
  
  common_tags = { Environment = "Dev" }
}

# Production
module "prod_folders" {
  source = "./modules/s3-tenant-folders"
  
  categories = {
    prod = {
      raw_bucket     = "prod-raw"
      staging_bucket = "prod-staging"
      curated_bucket = "prod-curated"
      description    = "Production"
    }
  }
  
  tenants = {
    app1 = {
      tenant_name    = "app1"
      category       = "prod"
      business_units = ["BusinessDEV"]  # Prod only
      active         = true
    }
  }
  
  common_tags = { Environment = "Prod" }
}
```

## 🗂️ Module Inputs

| Input | Description | Required |
|-------|-------------|----------|
| `categories` | Map of categories with buckets | Yes |
| `tenants` | Map of tenants with config | Yes |
| `business_units` | Valid business unit names | No (defaults to BusinessDEV, BusinessQA) |
| `common_tags` | Tags for all resources | No |

## 📊 Module Outputs

```hcl
# Access module outputs
output "all_tenants" {
  value = module.s3_folders.tenant_summary
}

output "stats" {
  value = module.s3_folders.statistics
}

output "categories" {
  value = module.s3_folders.category_summary
}
```

## 💡 Common Patterns

### Pattern 1: Workspace-Based

```hcl
locals {
  env = terraform.workspace
}

module "s3_folders" {
  source = "./modules/s3-tenant-folders"
  
  categories = {
    (local.env) = {
      raw_bucket     = "${local.env}-raw"
      staging_bucket = "${local.env}-staging"
      curated_bucket = "${local.env}-curated"
      description    = "${local.env} environment"
    }
  }
  
  tenants = var.tenants
  
  common_tags = {
    Environment = local.env
    Workspace   = terraform.workspace
  }
}
```

```bash
terraform workspace new dev
terraform apply

terraform workspace new prod
terraform apply
```

### Pattern 2: Per-Tenant Business Units

```hcl
tenants = {
  enterprise_client = {
    tenant_name    = "acme"
    category       = "enterprise"
    business_units = ["BusinessDEV", "BusinessQA"]  # Full pipeline
    active         = true
  }
  
  light_client = {
    tenant_name    = "startup"
    category       = "standard"
    business_units = ["BusinessDEV"]  # Production only
    active         = true
  }
  
  test_client = {
    tenant_name    = "test_env"
    category       = "testing"
    business_units = ["BusinessQA"]  # Testing only
    active         = true
  }
}
```

### Pattern 3: Dynamic Configuration

```hcl
# Load from YAML
locals {
  config = yamldecode(file("config.yaml"))
}

module "s3_folders" {
  source = "./modules/s3-tenant-folders"
  
  categories = local.config.categories
  tenants    = local.config.tenants
}
```

## 🔧 Using Remote Modules

### From Git Repository

```hcl
module "s3_folders" {
  source = "git::https://github.com/your-org/terraform-modules.git//s3-tenant-folders?ref=v1.0.0"
  
  categories = var.categories
  tenants    = var.tenants
}
```

### From Terraform Registry (if published)

```hcl
module "s3_folders" {
  source  = "your-org/s3-tenant-folders/aws"
  version = "~> 1.0"
  
  categories = var.categories
  tenants    = var.tenants
}
```

## 📈 View Results

```bash
# See tenant configuration
terraform output tenant_summary

# See statistics
terraform output statistics

# See category breakdown
terraform output category_summary

# See all folders created
terraform output all_folders_created
```

## 🆘 Troubleshooting

### Module not found

```bash
terraform init
```

### Changes not applying

```bash
terraform init -upgrade
terraform plan
```

### Import existing resources

```bash
terraform import 'module.s3_folders.aws_s3_object.raw_folders["bucket/path"]' bucket/path
```

## 📚 Next Steps

1. Check [README.md](../README.md) for comprehensive documentation
2. Browse [examples/](../examples/) for more usage patterns
3. Customize for your use case
4. Deploy!

## 🎓 Key Concepts

**Module** = Reusable Terraform code
```hcl
module "name" {
  source = "./path/to/module"
  
  input1 = value1
  input2 = value2
}
```

**Module Outputs**
```hcl
output "something" {
  value = module.name.output_name
}
```

**Multiple Instances**
```hcl
module "dev" {
  source = "./modules/s3-tenant-folders"
  ...
}

module "prod" {
  source = "./modules/s3-tenant-folders"
  ...
}
```

Happy deploying! 🚀
