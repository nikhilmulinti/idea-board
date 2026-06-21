# Azure Environment Infrastructure

This directory contains Terraform configurations for deploying infrastructure on Azure.

## Structure

```
azure/
├── main.tf           # Main Terraform configuration
├── variables.tf      # Variable definitions
├── outputs.tf        # Output definitions
└── terraform.tfvars  # Variable values
```

## Modules Used

- **Database**: Azure PostgreSQL/MySQL configurations
- **Kubernetes**: Azure Kubernetes Service (AKS) cluster
- **Storage**: Azure Blob Storage configurations

## Prerequisites

1. Azure CLI installed and configured
2. Terraform >= 1.0
3. Appropriate Azure permissions

## Usage

1. Initialize Terraform:
```bash
terraform init
```

2. Plan the deployment:
```bash
terraform plan
```

3. Apply the configuration:
```bash
terraform apply
```

## Remote State

The remote state is configured in `../../remote-state/azure/`