#!/bin/bash

set -e

echo "🚀 Installing ArgoCD at https://argocd.simpletwist.dpdns.org"
echo "============================================================="
echo ""

# Add Helm repo
helm repo add argo https://argoproj.github.io/argo-helm 2>/dev/null || true
helm repo update

# Install ArgoCD with subdomain configuration
helm upgrade --install argocd argo/argo-cd \
  --namespace argocd \
  --create-namespace \
  --version 7.7.17 \
  --values argocd-subdomain-values.yaml \
  --wait

# Apply the correct ingress
kubectl apply -f argocd-subdomain-ingress.yaml

# Get credentials
echo ""
echo "✅ ArgoCD Installation Complete!"
echo "================================"
ARGOCD_PASSWORD=$(kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d)
echo ""
echo "URL: https://argocd.simpletwist.dpdns.org"
echo "Username: admin"
echo "Password: ${ARGOCD_PASSWORD}"
echo ""
echo "LoadBalancer IP: $(kubectl get svc -n ingress-nginx nginx-ingress-ingress-nginx-controller -o jsonpath='{.status.loadBalancer.ingress[0].ip}')"
echo ""
echo "Note: Make sure DNS A record for argocd.simpletwist.dpdns.org points to the LoadBalancer IP"