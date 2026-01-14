# Bucket Types Configuration - Use Cases

## Overview

Each tenant can specify exactly which bucket types they need: `raw`, `staging`, and/or `curated`.

## All Combinations

### 1. All Three Buckets: `["raw", "staging", "curated"]`

**Use Case:** Complete data processing pipeline

**When to Use:**
- Full ETL/ELT pipeline
- Need intermediate processing area
- Complex transformations
- Quality checks between stages

**Example:**
```hcl
enterprise_client = {
  tenant_name    = "acme_corp"
  category       = "enterprise"
  business_units = ["BusinessDEV", "BusinessQA"]
  bucket_types   = ["raw", "staging", "curated"]
  active         = true
}
```

**Data Flow:**
```
Raw → Staging → Curated
1. Ingest raw data
2. Process in staging
3. Publish to curated
```

### 2. Raw + Curated: `["raw", "curated"]`

**Use Case:** Direct transformation without intermediate staging

**When to Use:**
- Simple transformations
- Single-step processing
- Cost optimization (skip staging)
- Production environments

**Example:**
```hcl
prod_app = {
  tenant_name    = "prod_app"
  category       = "production"
  business_units = ["BusinessDEV"]
  bucket_types   = ["raw", "curated"]
  active         = true
}
```

**Data Flow:**
```
Raw → Curated
1. Ingest raw data
2. Transform directly to curated
```

### 3. Raw + Staging: `["raw", "staging"]`

**Use Case:** Testing and development pipelines

**When to Use:**
- Testing ETL processes
- Development environments
- No need for final output
- Process validation

**Example:**
```hcl
test_env = {
  tenant_name    = "test_pipeline"
  category       = "testing"
  business_units = ["BusinessQA"]
  bucket_types   = ["raw", "staging"]
  active         = true
}
```

**Data Flow:**
```
Raw → Staging
1. Ingest test data
2. Validate processing
(No curated output)
```

### 4. Staging + Curated: `["staging", "curated"]`

**Use Case:** Downstream processing from shared raw data

**When to Use:**
- Multiple tenants share raw data
- Second-stage processing
- Refinement pipelines

**Example:**
```hcl
analytics_team = {
  tenant_name    = "analytics"
  category       = "shared"
  business_units = ["BusinessDEV"]
  bucket_types   = ["staging", "curated"]
  active         = true
}
```

**Data Flow:**
```
[Shared Raw] → Staging → Curated
1. Read from shared raw bucket
2. Process in own staging
3. Output to own curated
```

### 5. Raw Only: `["raw"]`

**Use Case:** Data ingestion/collection only

**When to Use:**
- Data ingestion services
- Event streaming endpoints
- Log aggregation
- No processing needed

**Example:**
```hcl
data_collector = {
  tenant_name    = "ingestion_service"
  category       = "services"
  business_units = ["BusinessDEV"]
  bucket_types   = ["raw"]
  active         = true
}
```

**Data Flow:**
```
→ Raw
1. Collect and store raw data
(Processing happens elsewhere)
```

### 6. Staging Only: `["staging"]`

**Use Case:** Intermediate processing service

**When to Use:**
- Middleware processing
- Data enrichment services
- Reads from shared raw, writes to shared curated

**Example:**
```hcl
processor = {
  tenant_name    = "enrichment_service"
  category       = "services"
  business_units = ["BusinessDEV"]
  bucket_types   = ["staging"]
  active         = true
}
```

**Data Flow:**
```
[Shared Raw] → Staging → [Shared Curated]
1. Read from shared raw
2. Process in own staging
3. Write to shared curated
```

### 7. Curated Only: `["curated"]`

**Use Case:** Read-only analytics/BI access

**When to Use:**
- Analytics dashboards
- BI tools
- Reporting services
- Read-only consumers
- No data processing

**Example:**
```hcl
bi_platform = {
  tenant_name    = "tableau"
  category       = "analytics"
  business_units = ["BusinessDEV"]
  bucket_types   = ["curated"]
  active         = true
}
```

**Data Flow:**
```
[Processed Elsewhere] → Curated
1. Read curated data only
(No write operations)
```

## Decision Matrix

| Scenario | Raw | Staging | Curated | Total Folders* |
|----------|-----|---------|---------|---------------|
| Full pipeline | ✅ | ✅ | ✅ | 3 |
| Direct transform | ✅ | ❌ | ✅ | 2 |
| Testing pipeline | ✅ | ✅ | ❌ | 2 |
| Downstream processing | ❌ | ✅ | ✅ | 2 |
| Data ingestion | ✅ | ❌ | ❌ | 1 |
| Middleware | ❌ | ✅ | ❌ | 1 |
| Analytics consumer | ❌ | ❌ | ✅ | 1 |

\* Assuming 1 business unit. Multiply by number of business units.

## Real-World Scenarios

### Scenario 1: SaaS Platform with Multiple Tiers

```hcl
# Enterprise: Full pipeline
enterprise = {
  tenant_name    = "bigcorp"
  category       = "enterprise"
  business_units = ["BusinessDEV", "BusinessQA"]
  bucket_types   = ["raw", "staging", "curated"]
  active         = true
}

# Standard: Simplified pipeline
standard = {
  tenant_name    = "mediumco"
  category       = "standard"
  business_units = ["BusinessDEV"]
  bucket_types   = ["raw", "curated"]
  active         = true
}

# Basic: Ingestion only
basic = {
  tenant_name    = "startup"
  category       = "basic"
  business_units = ["BusinessDEV"]
  bucket_types   = ["raw"]
  active         = true
}
```

### Scenario 2: Microservices Architecture

```hcl
# Ingestion service
ingest = {
  tenant_name    = "ingestion"
  category       = "services"
  business_units = ["BusinessDEV"]
  bucket_types   = ["raw"]
  active         = true
}

# Processing service
process = {
  tenant_name    = "processor"
  category       = "services"
  business_units = ["BusinessDEV"]
  bucket_types   = ["raw", "staging", "curated"]
  active         = true
}

# Analytics service
analytics = {
  tenant_name    = "analytics"
  category       = "services"
  business_units = ["BusinessDEV"]
  bucket_types   = ["curated"]
  active         = true
}
```

### Scenario 3: Development Lifecycle

```hcl
# Dev: Full pipeline
dev = {
  tenant_name    = "myapp_dev"
  category       = "development"
  business_units = ["BusinessDEV", "BusinessQA"]
  bucket_types   = ["raw", "staging", "curated"]
  active         = true
}

# Staging: Simplified
staging = {
  tenant_name    = "myapp_staging"
  category       = "staging"
  business_units = ["BusinessDEV"]
  bucket_types   = ["raw", "curated"]
  active         = true
}

# Prod: Optimized
prod = {
  tenant_name    = "myapp_prod"
  category       = "production"
  business_units = ["BusinessDEV"]
  bucket_types   = ["raw", "curated"]
  active         = true
}
```

### Scenario 4: Data Lake Architecture

```hcl
# Raw zone - ingestion
raw_zone = {
  tenant_name    = "data_lake_raw"
  category       = "datalake"
  business_units = ["BusinessDEV"]
  bucket_types   = ["raw"]
  active         = true
}

# Bronze/Silver zone - staging
processing_zone = {
  tenant_name    = "data_lake_processing"
  category       = "datalake"
  business_units = ["BusinessDEV"]
  bucket_types   = ["staging"]
  active         = true
}

# Gold zone - curated
analytics_zone = {
  tenant_name    = "data_lake_curated"
  category       = "datalake"
  business_units = ["BusinessDEV"]
  bucket_types   = ["curated"]
  active         = true
}
```

## Cost Optimization Examples

### Before: One-size-fits-all
```hcl
# All tenants get all buckets
tenant1 = { bucket_types = ["raw", "staging", "curated"] }  # 3 buckets
tenant2 = { bucket_types = ["raw", "staging", "curated"] }  # 3 buckets
tenant3 = { bucket_types = ["raw", "staging", "curated"] }  # 3 buckets
# Total: 9 buckets × 2 business units = 18 folders
```

### After: Right-sized configurations
```hcl
tenant1 = { bucket_types = ["raw", "staging", "curated"] }  # Needs all 3
tenant2 = { bucket_types = ["raw", "curated"] }             # Needs 2
tenant3 = { bucket_types = ["raw"] }                         # Needs 1
# Total: 6 buckets × 1 business unit = 6 folders
# Savings: 67% fewer folders!
```

## Best Practices

### ✅ DO

1. **Start with what you need**
   - Don't create buckets "just in case"
   - Add bucket types as requirements evolve

2. **Match to actual workflow**
   - Ingestion-only services: raw only
   - Analytics services: curated only
   - Processing services: all three

3. **Optimize for production**
   - Skip staging in prod if not needed
   - Keep staging in dev/test environments

4. **Use consistent patterns**
   - All dev environments: full pipeline
   - All prod environments: raw + curated

### ❌ DON'T

1. **Don't over-provision**
   - Creating unused buckets wastes resources
   - More folders = more complexity

2. **Don't under-provision**
   - Ensure services have buckets they need
   - Test configurations thoroughly

3. **Don't forget IAM implications**
   - Fewer buckets = simpler IAM policies
   - More buckets = more granular control

## Migration Paths

### Adding Bucket Types
```hcl
# Week 1: Start minimal
tenant = { bucket_types = ["raw"] }

# Week 2: Add processing
tenant = { bucket_types = ["raw", "staging", "curated"] }
```

### Removing Bucket Types
```hcl
# Current: Full pipeline
tenant = { bucket_types = ["raw", "staging", "curated"] }

# Optimized: Remove staging
tenant = { bucket_types = ["raw", "curated"] }
```

## Summary

Choose bucket types based on:
- **Data flow requirements**
- **Processing complexity**
- **Cost constraints**
- **Access patterns**
- **Environment type** (dev/test/prod)

The most flexible configuration allows each tenant to specify exactly what they need, optimizing both cost and complexity.
