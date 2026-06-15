# Production-Ready GCP Infrastructure Deployment

## Prerequisites
1. GCP Project: `reborg-studio-development`
2. Service Account with required permissions
3. Terraform >= 1.3.0
4. gcloud CLI configured

## Current Issues & Fixes

### 1. IP Address Conflict
**Issue**: `private-service-access-ip` already exists from another VPC
**Fix**: IP name now uses VPC prefix: `${var.vpc_name}-private-service-ip`

### 2. State Lock Issues
**Issue**: Multiple Terraform processes trying to acquire lock
**Fix**: Kill all running processes before applying

### 3. Missing Permissions
**Issue**: Service account missing IAM permissions
**Fix**: Required roles added:
- roles/compute.admin
- roles/container.admin
- roles/servicenetworking.networksAdmin
- roles/cloudsql.admin
- roles/iam.serviceAccountUser

## Deployment Steps

### Step 1: Clean Environment
```bash
# Kill any running Terraform processes
pkill -f terraform

# Set credentials
export GOOGLE_APPLICATION_CREDENTIALS="/Users/nikhil/Desktop/outmarket/idea-board/terraform-gcp-key.json"

# Clean up lock if exists
gsutil rm gs://idea-board-terraform-state-reborg/terraform/state/default.tflock 2>/dev/null || true
```

### Step 2: Initialize Terraform
```bash
cd /Users/nikhil/Desktop/outmarket/idea-board/infra-as-code/terraform/environments/gcp
terraform init
```

### Step 3: Review Plan
```bash
terraform plan
```

### Step 4: Apply Infrastructure
```bash
terraform apply -auto-approve
```

## Infrastructure Components

### Network
- VPC: `idea-board-dev-vpc`
- Private Subnet: `10.0.1.0/24` (with NAT)
- Public Subnet: `10.0.2.0/24`
- Service IP: `idea-board-dev-vpc-private-service-ip`

### GKE Cluster
- Name: `idea-board-dev`
- Version: Latest stable
- Nodes: 2 (autoscaling 1-3)
- Machine Type: e2-medium
- Zone: us-central1-a

### Cloud SQL
- Instance: `idea-board-dev-db`
- Database: `ideaboard`
- User: `ideauser`
- Private IP only
- Tier: db-f1-micro (dev), upgrade for production

## Connect to Resources

### GKE Cluster
```bash
gcloud container clusters get-credentials idea-board-dev \
    --zone us-central1-a \
    --project reborg-studio-development
```

### Database Connection
```
postgresql://ideauser:ChangeMeSecure123!@<PRIVATE_IP>:5432/ideaboard
```

## Production Recommendations

1. **Secrets Management**: Use Google Secret Manager for passwords
2. **GKE Security**: Enable Workload Identity
3. **Database**: Upgrade to production tier (db-n1-standard-1)
4. **Monitoring**: Enable Cloud Monitoring and Logging
5. **Backup**: Configure automated Cloud SQL backups
6. **Network**: Implement Cloud Armor for DDoS protection

## Troubleshooting

### State Lock Error
```bash
terraform force-unlock <LOCK_ID>
```

### Permission Errors
Ensure service account has all required roles listed above

### IP Already Exists
Check existing IPs:
```bash
gcloud compute addresses list --global --project=reborg-studio-development
```

## Clean Up
To destroy all resources:
```bash
terraform destroy -auto-approve
```