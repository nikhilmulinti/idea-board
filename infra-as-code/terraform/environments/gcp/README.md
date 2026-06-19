# GCP Infrastructure Setup

This Terraform configuration creates the infrastructure needed for the Idea Board application on Google Cloud Platform.

## Prerequisites

1. GCP Project with billing enabled
2. Service Account with the following roles:
   - Kubernetes Engine Admin
   - Compute Admin
   - Cloud SQL Admin
   - Service Networking Admin
   - Storage Admin (if using GCS)

## Authentication

Choose one of the following methods:

### Option 1: Service Account Key (Recommended for CI/CD)
```bash
export GOOGLE_APPLICATION_CREDENTIALS="path/to/service-account-key.json"
```

### Option 2: gcloud CLI (Recommended for local development)
```bash
gcloud auth application-default login
gcloud config set project YOUR_PROJECT_ID
```

## Usage

```bash
# Initialize Terraform
terraform init

# Review the plan
terraform plan -var="project_id=YOUR_PROJECT_ID"

# Apply the configuration
terraform apply -var="project_id=YOUR_PROJECT_ID"

# Optional: Customize the deployment
terraform apply \
  -var="project_id=YOUR_PROJECT_ID" \
  -var="env_name=production" \
  -var="region=us-central1" \
  -var="zone=us-central1-a" \
  -var="cluster_name=idea-board-cluster"
```

## What Gets Created

- **GKE Cluster**: Managed Kubernetes cluster with autoscaling
- **Cloud SQL**: PostgreSQL instance for the application
- **VPC Network**: Custom network with private subnets
- **Service Accounts**: For workload identity
- **Cloud Storage**: Optional bucket for backups

## Outputs

After successful deployment, Terraform will output:
- Kubernetes cluster endpoint
- Database connection string
- Service account details

## Connect to the Cluster

```bash
gcloud container clusters get-credentials $(terraform output -raw cluster_name) \
  --region $(terraform output -raw region) \
  --project $(terraform output -raw project_id)
```

## Clean Up

To destroy all resources:
```bash
terraform destroy -var="project_id=YOUR_PROJECT_ID"
```

## Important Notes

- The Cloud SQL instance has `deletion_protection` enabled by default
- Review the `terraform.tfvars.example` file for all available variables
- Ensure your service account has sufficient permissions before running