# Module Architecture

## Directory Structure

```
s3-category-module/
│
├── modules/                                # Reusable modules directory
│   └── s3-tenant-folders/                  # The S3 tenant folders module
│       ├── main.tf                         # Module logic (folder creation)
│       ├── variables.tf                    # Module inputs
│       └── outputs.tf                      # Module outputs
│
├── examples/                               # Usage examples
│   ├── basic/
│   │   └── main.tf                         # Basic usage example
│   └── multi-environment/
│       └── main.tf                         # Multi-env example
│
├── main.tf                                 # Root: Calls the module
├── variables.tf                            # Root: Input variables
├── outputs.tf                              # Root: Pass-through outputs
├── terraform.tfvars.example                # Example configuration
├── README.md                               # Full documentation
└── QUICKSTART.md                           # Quick start guide
```

## Data Flow

```
┌─────────────────────────────────────────────────────────────┐
│                    Root Module (main.tf)                     │
│                                                               │
│  terraform {                                                 │
│    ...                                                       │
│  }                                                           │
│                                                               │
│  provider "aws" {                                            │
│    region = var.aws_region                                  │
│  }                                                           │
│                                                               │
│  module "s3_tenant_folders" {                               │
│    source = "./modules/s3-tenant-folders"                   │
│                                                               │
│    categories     = var.categories         ┐                │
│    tenants        = var.tenants            │ Inputs         │
│    business_units = var.business_units     │                │
│    common_tags    = var.common_tags        ┘                │
│  }                                                           │
└──────────────────────┬──────────────────────────────────────┘
                        │
                        ▼
┌─────────────────────────────────────────────────────────────┐
│           Module: s3-tenant-folders (module logic)           │
│                                                               │
│  locals {                                                    │
│    active_tenants = {...}                                   │
│    raw_folders = {...}                                      │
│    staging_folders = {...}                                  │
│    curated_folders = {...}                                  │
│  }                                                           │
│                                                               │
│  resource "aws_s3_object" "raw_folders" {                   │
│    for_each = local.raw_folder_map                          │
│    ...                                                       │
│  }                                                           │
│                                                               │
│  resource "aws_s3_object" "staging_folders" {               │
│    ...                                                       │
│  }                                                           │
│                                                               │
│  resource "aws_s3_object" "curated_folders" {               │
│    ...                                                       │
│  }                                                           │
└──────────────────────┬──────────────────────────────────────┘
                        │
                        ▼
┌─────────────────────────────────────────────────────────────┐
│                     AWS S3 Buckets                           │
│                                                               │
│  alpha-raw/                                                  │
│  ├── BusinessDEV/tenant1/     ← Created by module          │
│  └── BusinessQA/tenant1/      ← Created by module          │
│                                                               │
│  alpha-staging/                                              │
│  ├── BusinessDEV/tenant1/     ← Created by module          │
│  └── BusinessQA/tenant1/      ← Created by module          │
│                                                               │
│  alpha-curated/                                              │
│  ├── BusinessDEV/tenant1/     ← Created by module          │
│  └── BusinessQA/tenant1/      ← Created by module          │
└─────────────────────────────────────────────────────────────┘
                        │
                        ▼
┌─────────────────────────────────────────────────────────────┐
│               Module Outputs (outputs.tf)                    │
│                                                               │
│  output "tenant_summary" {                                   │
│    value = {...}                ┐                           │
│  }                               │                           │
│                                   │                           │
│  output "category_summary" {     │ Module                   │
│    value = {...}                 │ Outputs                  │
│  }                               │                           │
│                                   │                           │
│  output "statistics" {           │                           │
│    value = {...}                ┘                           │
│  }                                                           │
└──────────────────────┬──────────────────────────────────────┘
                        │
                        ▼
┌─────────────────────────────────────────────────────────────┐
│          Root Outputs (root outputs.tf)                      │
│                                                               │
│  output "tenant_summary" {                                   │
│    value = module.s3_tenant_folders.tenant_summary          │
│  }                                                           │
│                                                               │
│  output "statistics" {                                       │
│    value = module.s3_tenant_folders.statistics              │
│  }                                                           │
└─────────────────────────────────────────────────────────────┘
```

## Module Call Flow

### 1. Configuration (terraform.tfvars)
```hcl
categories = {
  alpha = {
    raw_bucket     = "company-alpha-raw"
    staging_bucket = "company-alpha-staging"
    curated_bucket = "company-alpha-curated"
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
```

### 2. Root Module Calls Child Module (main.tf)
```hcl
module "s3_tenant_folders" {
  source = "./modules/s3-tenant-folders"
  
  categories     = var.categories      ─┐
  tenants        = var.tenants          │ Pass to module
  business_units = var.business_units   │
  common_tags    = var.common_tags     ─┘
}
```

### 3. Module Processes Inputs
```hcl
# modules/s3-tenant-folders/main.tf
locals {
  active_tenants = {...}     # Filter active tenants
  raw_folders    = {...}     # Calculate folders for raw bucket
  staging_folders = {...}    # Calculate folders for staging bucket
  curated_folders = {...}    # Calculate folders for curated bucket
}
```

### 4. Module Creates Resources
```hcl
resource "aws_s3_object" "raw_folders" {
  for_each = local.raw_folder_map
  
  bucket  = each.value.bucket
  key     = each.value.key        # e.g., "BusinessDEV/tenant1/"
  content = ""
  tags    = {...}
}
```

### 5. Module Returns Outputs
```hcl
# modules/s3-tenant-folders/outputs.tf
output "tenant_summary" {
  value = {
    tenant1 = {
      category       = "alpha"
      business_units = ["BusinessDEV", "BusinessQA"]
      paths = {...}
    }
  }
}
```

### 6. Root Exposes Module Outputs
```hcl
# outputs.tf (root)
output "tenant_summary" {
  value = module.s3_tenant_folders.tenant_summary
}
```

### 7. User Views Output
```bash
$ terraform output tenant_summary

{
  "tenant1": {
    "category": "alpha",
    "business_units": ["BusinessDEV", "BusinessQA"],
    "buckets": {...},
    "paths": {...}
  }
}
```

## Module Benefits

### Reusability
```hcl
# Use same module for dev and prod
module "dev_folders" {
  source = "./modules/s3-tenant-folders"
  ...
}

module "prod_folders" {
  source = "./modules/s3-tenant-folders"
  ...
}
```

### Versioning
```hcl
# Pin to specific version
module "s3_folders" {
  source = "git::https://...?ref=v1.0.0"
  ...
}
```

### Sharing
```
# Share module across teams
team-a/project1/ ──┐
team-b/project2/ ──┼─→ modules/s3-tenant-folders/
team-c/project3/ ──┘
```

## Comparison

### Non-Module Approach
```
project/
├── main.tf         (contains all logic)
├── variables.tf
└── outputs.tf

- Hard to reuse
- Everything in one place
- Difficult to share
```

### Module Approach
```
project/
├── modules/
│   └── s3-tenant-folders/    (reusable logic)
│       ├── main.tf
│       ├── variables.tf
│       └── outputs.tf
├── main.tf                    (calls module)
├── variables.tf
└── outputs.tf

✅ Reusable
✅ Organized
✅ Shareable
✅ Versionable
```

## Key Takeaways

1. **Module** = Reusable Terraform code in a separate directory
2. **Root calls module** with `module "name" { source = "..." }`
3. **Inputs** = Pass variables to module
4. **Outputs** = Module returns data to root
5. **Multiple instances** = Call same module multiple times
6. **Versioning** = Tag and version your modules
7. **Sharing** = Use Git, Registry, or local paths

## Next Steps

1. Review [README.md](README.md) for full documentation
2. Check [examples/](examples/) for usage patterns
3. Modify module for your needs
4. Deploy and enjoy! 🚀
