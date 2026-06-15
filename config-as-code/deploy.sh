#!/bin/bash

# Deployment script for Idea Board application
set -e

echo "🚀 Deploying Idea Board Application"

# Check if helmfile is installed
if ! command -v helmfile &> /dev/null; then
    echo "❌ helmfile not found. Installing..."
    brew install helmfile
fi

# Check cluster connection
echo "📡 Checking cluster connection..."
kubectl cluster-info &> /dev/null || {
    echo "❌ Not connected to cluster. Please run:"
    echo "gcloud container clusters get-credentials idea-board-dev --zone us-central1-a --project reborg-studio-development"
    exit 1
}

# Create namespace if not exists
echo "📦 Creating namespace..."
kubectl create namespace idea-board --dry-run=client -o yaml | kubectl apply -f -

# Create database secret
echo "🔐 Creating database secret..."
kubectl create secret generic idea-board-secrets \
    --from-literal=database-url='postgresql://ideauser:ChangeMeSecure123!@10.57.0.3:5432/ideaboard' \
    --namespace idea-board \
    --dry-run=client -o yaml | kubectl apply -f -

# Deploy with helmfile
echo "📊 Deploying with Helmfile..."
helmfile -f helmfile.yaml sync

echo "✅ Deployment complete!"
echo ""
echo "🌐 Access your application at: https://simpletwist.dpdns.org"
echo ""
echo "📋 Useful commands:"
echo "  helmfile list               # List all releases"
echo "  helmfile status             # Check status"
echo "  helmfile diff               # Preview changes"
echo "  helmfile destroy            # Remove everything"
echo "  kubectl get pods -n idea-board  # Check pods"