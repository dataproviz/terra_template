# Quick Start - S3 Tenant Folders Module (Enhanced)

## 🎯 Key Features

✅ **Per-Tenant Category Assignment** - Each tenant assigned to ONE category  
✅ **Configurable Business Units** - Each tenant specifies which business units they need  
✅ **Configurable Bucket Types** - Each tenant specifies which buckets they need (raw/staging/curated)  
✅ **Maximum Flexibility** - Mix and match business units and bucket types per tenant  

## 🆕 NEW: Configurable Bucket Types

Not all tenants need all three buckets! Each tenant can now specify exactly which bucket types they need:

```hcl
tenant1 = {
  tenant_name    = "tenant1"
  category       = "alpha"
  business_units = ["BusinessDEV", "BusinessQA"]
  bucket_types   = ["raw", "staging", "curated"]  # Full pipeline
  active         = true
}

tenant2 = {
  tenant_name    = "tenant2"
  category       = "beta"
  business_units = ["BusinessDEV"]
  bucket_types   = ["raw", "curated"]  # Skip staging
  active         = true
}

tenant3 = {
  tenant_name    = "tenant3"
  category       = "beta"
  business_units = ["BusinessDEV"]
  bucket_types   = ["raw"]  # Only raw data ingestion
  active         = true
}
```

## 📋 Configuration Summary

Each tenant can now configure:
1. **Category** - Which bucket group (alpha, beta, etc.)
2. **Business Units** - Which environments (BusinessDEV, BusinessQA)
3. **Bucket Types** - Which stages (raw, staging, curated)

## 💡 Common Patterns

### Pattern 1: Full Pipeline
```hcl
business_units = ["BusinessDEV", "BusinessQA"]
bucket_types = ["raw", "staging", "curated"]
# Result: 6 folders (2 × 3)
```

### Pattern 2: Direct Raw-to-Curated
```hcl
business_units = ["BusinessDEV"]
bucket_types = ["raw", "curated"]
# Result: 2 folders (1 × 2)
```

### Pattern 3: Data Ingestion Only
```hcl
business_units = ["BusinessDEV"]
bucket_types = ["raw"]
# Result: 1 folder (1 × 1)
```

### Pattern 4: Analytics Consumer
```hcl
business_units = ["BusinessDEV"]
bucket_types = ["curated"]
# Result: 1 folder (1 × 1)
```

## 📊 Folder Calculation

```
Folders = business_units × bucket_types
```

## 🚀 Quick Start

```bash
cp terraform.tfvars.example terraform.tfvars
nano terraform.tfvars
terraform init
terraform apply
```

Happy deploying! 🚀
