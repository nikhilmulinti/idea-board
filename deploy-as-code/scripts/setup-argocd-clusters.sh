#!/bin/bash

# Script to add multiple clusters to ArgoCD

set -e

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${GREEN}=== ArgoCD Multi-Cluster Setup ===${NC}"

# Check if argocd CLI is installed
if ! command -v argocd &> /dev/null; then
    echo -e "${RED}ArgoCD CLI is not installed${NC}"
    echo "Install it from: https://argo-cd.readthedocs.io/en/stable/cli_installation/"
    exit 1
fi

# Login to ArgoCD
echo -e "${YELLOW}Logging into ArgoCD...${NC}"
ARGOCD_SERVER="argocd.example.com"  # Replace with your ArgoCD server
argocd login $ARGOCD_SERVER

# Function to add cluster
add_cluster() {
    local context=$1
    local name=$2

    echo -e "${GREEN}Adding cluster: $name (context: $context)${NC}"

    # Check if cluster already exists
    if argocd cluster list | grep -q "$name"; then
        echo -e "${YELLOW}Cluster $name already exists, skipping...${NC}"
    else
        argocd cluster add "$context" --name "$name" --upsert
        echo -e "${GREEN}Successfully added cluster: $name${NC}"
    fi
}

# Add your clusters here
# Format: add_cluster "kubectl-context-name" "friendly-name"

# Example for GKE clusters
add_cluster "gke_project-dev_us-central1-a_dev-cluster" "gke-dev"
add_cluster "gke_project-staging_us-central1-a_staging-cluster" "gke-staging"
add_cluster "gke_project-prod_us-central1-a_prod-cluster" "gke-production"

# Example for EKS clusters
# add_cluster "arn:aws:eks:us-west-2:123456789012:cluster/dev-cluster" "eks-dev"
# add_cluster "arn:aws:eks:us-west-2:123456789012:cluster/prod-cluster" "eks-production"

# Example for Azure AKS
# add_cluster "aks-dev-cluster" "aks-dev"
# add_cluster "aks-prod-cluster" "aks-production"

# List all clusters
echo -e "${GREEN}Current ArgoCD clusters:${NC}"
argocd cluster list

echo -e "${GREEN}=== Setup Complete ===${NC}"
echo -e "${YELLOW}Note: Update the cluster URLs in your ApplicationSets with the actual cluster addresses${NC}"