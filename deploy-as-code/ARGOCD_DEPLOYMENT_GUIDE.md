# 🚀 Complete ArgoCD Deployment Guide

## Prerequisites
- Kubernetes cluster (GKE/AKS/EKS)
- nginx-ingress installed
- cert-manager installed
- DNS pointing to LoadBalancer IP

## 📦 Deployment Steps

### 1. Install ArgoCD
```bash
# Run the installation script
cd deploy-as-code
./install-argocd.sh
```

This will:
- Install ArgoCD in `argocd` namespace
- Configure it to run at `/argocd` subpath
- Create ingress for `https://simpletwist.dpdns.org/argocd`
- Display admin credentials

### 2. Access ArgoCD UI
- URL: `https://simpletwist.dpdns.org/argocd`
- Username: `admin`
- Password: (displayed by script)

### 3. Deploy Applications via ArgoCD

#### Option A: Using kubectl (Recommended for demo)
```bash
# Deploy backend application
kubectl apply -f deploy-as-code/argocd/backend-app.yaml

# Deploy frontend application
kubectl apply -f deploy-as-code/argocd/frontend-app.yaml
```

#### Option B: Using ArgoCD CLI
```bash
# Login to ArgoCD
argocd login simpletwist.dpdns.org:443 \
  --grpc-web \
  --username admin \
  --password <PASSWORD> \
  --insecure

# Add repository
argocd repo add https://github.com/nikhilmulinti/idea-board

# Create applications
argocd app create backend \
  --repo https://github.com/nikhilmulinti/idea-board \
  --path config-as-code/helm/charts/backend \
  --dest-server https://kubernetes.default.svc \
  --dest-namespace ideaboard \
  --sync-policy automated \
  --auto-prune \
  --self-heal

argocd app create frontend \
  --repo https://github.com/nikhilmulinti/idea-board \
  --path config-as-code/helm/charts/frontend \
  --dest-server https://kubernetes.default.svc \
  --dest-namespace ideaboard \
  --sync-policy automated \
  --auto-prune \
  --self-heal
```

#### Option C: App of Apps Pattern
```bash
# Deploy the app-of-apps (manages all other apps)
kubectl apply -f deploy-as-code/argocd/app-of-apps.yaml
```

### 4. Sync Applications
```bash
# Force sync if needed
argocd app sync backend
argocd app sync frontend

# Or via kubectl
kubectl patch application backend -n argocd --type merge -p '{"operation":{"sync":{}}}'
kubectl patch application frontend -n argocd --type merge -p '{"operation":{"sync":{}}}'
```

## 🔍 Verification

### Check ArgoCD Applications
```bash
# List applications
kubectl get applications -n argocd

# Check application status
kubectl describe application backend -n argocd
kubectl describe application frontend -n argocd
```

### Check Deployed Resources
```bash
# Check pods
kubectl get pods -n ideaboard

# Check services
kubectl get svc -n ideaboard

# Check ingress
kubectl get ingress -n ideaboard
```

## 🌍 Multi-Environment Deployment

### For Different Environments
```yaml
# Create environment-specific applications
# deploy-as-code/argocd/backend-staging.yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: backend-staging
  namespace: argocd
spec:
  source:
    helm:
      valueFiles:
        - values.yaml
        - ../../deploy-as-code/argocd/environments/staging-values.yaml
```

### For Different Clusters
```bash
# Add cluster to ArgoCD
argocd cluster add <context-name>

# Deploy to specific cluster
argocd app create backend-prod \
  --dest-server https://prod-cluster.example.com \
  --dest-namespace ideaboard
```

## 📊 ArgoCD Features to Showcase

### 1. Auto-Sync
Applications automatically sync when Git changes are detected

### 2. Self-Healing
If someone manually changes resources, ArgoCD reverts them

### 3. Rollback
```bash
# Rollback to previous version
argocd app rollback backend 1
```

### 4. Diff View
See what will change before syncing

### 5. Health Status
Real-time health monitoring of all resources

## 🎯 Interview Talking Points

1. **GitOps Benefits**
   - Single source of truth (Git)
   - Audit trail of all changes
   - Easy rollbacks
   - Declarative configuration

2. **Security**
   - No cluster credentials stored in CI/CD
   - RBAC for different teams
   - Encrypted secrets with Sealed Secrets

3. **Scalability**
   - Manage 100s of applications
   - Multi-cluster deployments
   - Environment promotion

4. **Developer Experience**
   - Self-service deployments
   - Preview environments from PRs
   - Automated sync and notifications

## 🔧 Troubleshooting

### ArgoCD Not Accessible
```bash
# Check ingress
kubectl describe ingress argocd-server-ingress -n argocd

# Check ArgoCD server logs
kubectl logs -n argocd deployment/argocd-server
```

### Application Not Syncing
```bash
# Check application status
argocd app get backend

# Force refresh
argocd app refresh backend

# Check repo access
argocd repo list
```

### Reset Admin Password
```bash
# Delete the secret to regenerate
kubectl delete secret argocd-initial-admin-secret -n argocd
kubectl rollout restart deployment/argocd-server -n argocd
```

## 📈 Metrics & Monitoring

```yaml
# Prometheus metrics available at
https://simpletwist.dpdns.org/argocd/metrics
```

## 🚀 Quick Demo Commands

```bash
# 1. Show ArgoCD UI
open https://simpletwist.dpdns.org/argocd

# 2. Deploy via PR comment (with GitHub Actions)
gh pr comment 1 --body "/deploy production"

# 3. Show auto-sync
git commit -m "Update replicas"
git push
# Watch ArgoCD auto-sync

# 4. Demo rollback
argocd app rollback backend
```

## ✨ Advanced Features for Interview

1. **Progressive Delivery with Argo Rollouts**
2. **Secrets management with Sealed Secrets**
3. **Multi-tenancy with Projects**
4. **Webhook notifications to Slack**
5. **Custom health checks**
6. **Resource hooks for migrations**