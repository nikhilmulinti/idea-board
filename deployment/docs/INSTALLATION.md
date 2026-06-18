# Complete GitOps Installation Guide

This guide provides step-by-step instructions for deploying the Idea Board application with full GitOps capabilities using Helmfile and ArgoCD.

## Table of Contents
- [Prerequisites](#prerequisites)
- [Quick Installation](#quick-installation)
- [Detailed Installation](#detailed-installation)
- [Configuration Reference](#configuration-reference)
- [Verification Steps](#verification-steps)
- [Troubleshooting](#troubleshooting)

## Prerequisites

### Required Tools
```bash
# Check versions
kubectl version --client  # 1.26+
helm version             # 3.10+
helmfile version         # 0.150+
```

### Tool Installation

#### Install Helm
```bash
# macOS
brew install helm

# Linux
curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash

# Windows
choco install kubernetes-helm
```

#### Install Helmfile
```bash
# macOS
brew install helmfile

# Linux
wget https://github.com/helmfile/helmfile/releases/latest/download/helmfile_linux_amd64
chmod +x helmfile_linux_amd64
sudo mv helmfile_linux_amd64 /usr/local/bin/helmfile

# Windows
scoop install helmfile
```

#### Install Helm Diff Plugin
```bash
helm plugin install https://github.com/databus23/helm-diff --verify=false
```

## Quick Installation

### 1. Clone Repository
```bash
git clone https://github.com/nikhilmulinti/idea-board.git
cd idea-board/deployment
```

### 2. Configure Environment
```bash
cp environments/dev.yaml.example environments/dev.yaml
vim environments/dev.yaml  # Update with your values
```

### 3. Deploy Everything
```bash
helmfile -e dev sync
```

### 4. Get Access Info
```bash
# LoadBalancer IP
kubectl get svc -n ingress-nginx ingress-nginx-controller -o jsonpath='{.status.loadBalancer.ingress[0].ip}'

# ArgoCD Password
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d
```

## Detailed Installation

### Step 1: Prepare Environment File

Create `deployment/environments/dev.yaml` with your configuration:

```yaml
# Domain Configuration
letsencrypt:
  email: admin@example.com  # Your email for SSL certificates

argocd:
  host: argocd.example.com  # ArgoCD subdomain

app:
  host: example.com          # Main application domain

# GitHub Repository
github:
  repo: https://github.com/nikhilmulinti/idea-board

# Database Configuration
postgresql:
  host: your-postgres-server.database.azure.com
  database: ideaboard
  username: dbadmin
  password: "your-secure-password"

# Cloud Provider Settings (choose one)

# Azure AKS
ingress:
  annotations:
    service.beta.kubernetes.io/azure-load-balancer-health-probe-request-path: /healthz

# AWS EKS
# ingress:
#   annotations:
#     service.beta.kubernetes.io/aws-load-balancer-type: nlb
#     service.beta.kubernetes.io/aws-load-balancer-backend-protocol: tcp

# Google GKE
# ingress:
#   annotations:
#     cloud.google.com/load-balancer-type: External
#     networking.gke.io/load-balancer-type: External
```

### Step 2: Deploy Infrastructure Layer

```bash
# Deploy cert-manager and ingress-nginx
helmfile -e dev -f helmfile.d/01-infrastructure.yaml.gotmpl sync

# Verify deployment
kubectl get pods -n cert-manager
kubectl get pods -n ingress-nginx

# Wait for LoadBalancer IP
kubectl get svc -n ingress-nginx ingress-nginx-controller -w
```

### Step 3: Configure DNS

Once you have the LoadBalancer IP:

```bash
# Get the IP
export LB_IP=$(kubectl get svc -n ingress-nginx ingress-nginx-controller -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
echo "LoadBalancer IP: $LB_IP"
```

Configure your DNS:
- A Record: `example.com` → `$LB_IP`
- A Record: `argocd.example.com` → `$LB_IP`
- A Record: `*.example.com` → `$LB_IP` (optional wildcard)

### Step 4: Deploy ArgoCD

```bash
# Deploy ArgoCD and Image Updater
helmfile -e dev -f helmfile.d/02-argocd.yaml.gotmpl sync

# Verify ArgoCD is running
kubectl get pods -n argocd
kubectl wait --for=condition=ready pod -l app.kubernetes.io/name=argocd-server -n argocd --timeout=300s
```

### Step 5: Deploy Applications

```bash
# Deploy application manifests to ArgoCD
helmfile -e dev -f helmfile.d/03-applications.yaml.gotmpl sync

# Check ArgoCD applications
kubectl get applications -n argocd

# Check application pods
kubectl get pods -n ideaboard
```

### Step 6: Access ArgoCD UI

```bash
# Get admin password
export ARGOCD_PASSWORD=$(kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d)
echo "ArgoCD Admin Password: $ARGOCD_PASSWORD"

# Access ArgoCD
echo "ArgoCD URL: https://argocd.example.com"
echo "Username: admin"
echo "Password: $ARGOCD_PASSWORD"
```

## Configuration Reference

### Environment Files Structure
```
environments/
├── dev.yaml         # Development environment
├── staging.yaml     # Staging environment (optional)
└── production.yaml  # Production environment (optional)
```

### Deployment Structure
```
deployment/
├── helmfile.d/                    # Helmfile configurations
│   ├── 01-infrastructure.yaml.gotmpl  # Base infrastructure
│   ├── 02-argocd.yaml.gotmpl         # GitOps platform
│   └── 03-applications.yaml.gotmpl    # Application deployments
├── charts/                        # Helm charts
│   ├── backend/                   # Backend application chart
│   ├── frontend/                  # Frontend application chart
│   └── argocd-app/               # ArgoCD application template
├── environments/                  # Environment configurations
│   └── dev.yaml                  # Development environment values
└── docs/                         # Documentation
    └── INSTALLATION.md           # This file
```

### Customization Options

#### PostgreSQL Connection
```yaml
postgresql:
  host: postgres.example.com
  port: 5432  # Optional, defaults to 5432
  database: ideaboard
  username: dbadmin
  password: "secure-password"
  sslmode: require  # Optional SSL configuration
```

#### Scaling Configuration
```yaml
# In application parameters
backend:
  replicaCount: 3
  resources:
    requests:
      memory: "256Mi"
      cpu: "100m"
    limits:
      memory: "512Mi"
      cpu: "500m"
```

#### TLS/SSL Options
```yaml
# Force SSL redirect
ingress:
  annotations:
    nginx.ingress.kubernetes.io/ssl-redirect: "true"
    nginx.ingress.kubernetes.io/force-ssl-redirect: "true"
```

## Verification Steps

### 1. Check All Components
```bash
# Infrastructure
kubectl get all -n cert-manager
kubectl get all -n ingress-nginx

# GitOps
kubectl get all -n argocd

# Applications
kubectl get all -n ideaboard
```

### 2. Verify Certificates
```bash
# Check certificate status
kubectl get certificates -A
kubectl describe certificate argocd-server-tls -n argocd

# Check ClusterIssuer
kubectl get clusterissuer
kubectl describe clusterissuer letsencrypt-prod
```

### 3. Test Application
```bash
# Test backend API
curl https://example.com/api/health

# Test frontend
curl -I https://example.com

# Test ArgoCD
curl -I https://argocd.example.com
```

### 4. Check GitOps Flow
```bash
# Watch Image Updater logs
kubectl logs -f -n argocd deploy/argocd-image-updater

# Check application sync status
argocd app list
argocd app get backend
argocd app get frontend
```

## Troubleshooting

### Common Issues and Solutions

#### 1. Pods Not Starting
```bash
# Check pod status
kubectl describe pod <pod-name> -n <namespace>

# Check events
kubectl get events -n <namespace> --sort-by='.lastTimestamp'

# Check logs
kubectl logs <pod-name> -n <namespace> --previous
```

#### 2. Certificate Issues
```bash
# Check cert-manager logs
kubectl logs -n cert-manager deploy/cert-manager

# Check certificate request
kubectl get certificaterequest -A
kubectl describe certificaterequest <name> -n <namespace>

# Force certificate renewal
kubectl delete certificate <cert-name> -n <namespace>
```

#### 3. LoadBalancer Not Getting IP
```bash
# Check service status
kubectl describe svc ingress-nginx-controller -n ingress-nginx

# Check cloud provider logs (Azure example)
kubectl logs -n kube-system -l component=cloud-controller-manager
```

#### 4. ArgoCD Sync Issues
```bash
# Force sync
kubectl patch application backend -n argocd --type merge \
  -p '{"metadata":{"annotations":{"argocd.argoproj.io/refresh":"hard"}}}'

# Check application details
kubectl get application backend -n argocd -o yaml

# Reset application
argocd app sync backend --force --prune
```

#### 5. Image Updater Not Working
```bash
# Check image accessibility
docker pull ghcr.io/nikhilmulinti/idea-board-frontend:latest

# Check updater configuration
kubectl get application backend -n argocd -o yaml | grep -A10 annotations

# Restart updater
kubectl rollout restart deployment argocd-image-updater -n argocd
```

### Debug Commands
```bash
# Full cluster health check
kubectl get nodes
kubectl top nodes
kubectl get pods --all-namespaces | grep -v Running

# Network connectivity test
kubectl run test-pod --image=busybox --rm -it --restart=Never -- wget -qO- http://backend.ideaboard.svc.cluster.local:8000/health

# DNS resolution test
kubectl run test-pod --image=busybox --rm -it --restart=Never -- nslookup backend.ideaboard.svc.cluster.local
```

## Rollback Procedures

### Application Rollback
```bash
# Via GitOps (recommended)
git revert HEAD
git push

# Via ArgoCD UI
# Navigate to application → History → Select previous version → Rollback

# Via CLI
argocd app rollback backend <revision-id>
```

### Helmfile Rollback
```bash
# Check history
helm list -n <namespace>
helm history <release> -n <namespace>

# Rollback specific release
helm rollback <release> <revision> -n <namespace>

# Rollback all via Helmfile
helmfile -e dev rollback
```

## Uninstallation

### Remove Applications Only
```bash
helmfile -e dev -f helmfile.d/03-applications.yaml.gotmpl destroy
```

### Remove ArgoCD
```bash
helmfile -e dev -f helmfile.d/02-argocd.yaml.gotmpl destroy
```

### Complete Uninstall
```bash
# Remove all components
helmfile -e dev destroy

# Clean up namespaces
kubectl delete namespace ideaboard argocd cert-manager ingress-nginx

# Remove CRDs
kubectl delete crd applications.argoproj.io
kubectl delete crd applicationsets.argoproj.io
kubectl delete crd certificates.cert-manager.io
kubectl delete crd clusterissuers.cert-manager.io
```

## Support & Resources

- **ArgoCD Documentation**: https://argo-cd.readthedocs.io/
- **Helmfile Documentation**: https://helmfile.readthedocs.io/
- **Cert-Manager**: https://cert-manager.io/docs/
- **NGINX Ingress**: https://kubernetes.github.io/ingress-nginx/

## Security Best Practices

1. **Change default passwords immediately**
   ```bash
   argocd account update-password
   ```

2. **Enable RBAC**
   ```bash
   kubectl apply -f rbac/argocd-rbac-cm.yaml
   ```

3. **Use external secret management**
   - Azure Key Vault
   - AWS Secrets Manager
   - HashiCorp Vault
   - Sealed Secrets

4. **Enable audit logging**
   ```yaml
   server:
     extraArgs:
       - --audit-log-path=/tmp/argocd-audit.log
       - --audit-log-maxage=7
   ```

5. **Implement network policies**
   ```bash
   kubectl apply -f network-policies/
   ```

## Performance Tuning

### ArgoCD Performance
```yaml
controller:
  replicas: 2
  env:
    - name: ARGOCD_CONTROLLER_REPLICAS
      value: "2"
  resources:
    requests:
      memory: "512Mi"
      cpu: "250m"
```

### Application Auto-scaling
```yaml
autoscaling:
  enabled: true
  minReplicas: 2
  maxReplicas: 10
  targetCPUUtilizationPercentage: 70
```

## License

MIT