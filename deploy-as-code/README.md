# Idea Board - GitOps Deployment with ArgoCD

## Case Study Setup Guide

This setup demonstrates modern GitOps practices using ArgoCD for continuous deployment of a microservices application.

## Architecture Overview

```
GitHub Repository
    ├── Source Code (backend/frontend)
    ├── Docker Images (GitHub Container Registry)
    └── GitOps Configs (deploy-as-code)
              ↓
         ArgoCD
              ↓
    GKE Cluster (agos-dev)
        ├── idea-board-dev
        ├── idea-board-staging
        └── idea-board-prod
```

## Quick Start

### Prerequisites
- GKE cluster access (agos-dev)
- ArgoCD installed in the cluster
- kubectl configured
- GitHub repository with Docker images

### 1. Install ArgoCD (if not already installed)

```bash
kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
```

### 2. Access ArgoCD UI

```bash
# Port forward
kubectl port-forward svc/argocd-server -n argocd 8080:443

# Get admin password
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d

# Access UI at: https://localhost:8080
# Username: admin
```

### 3. Deploy the ApplicationSet

```bash
# Apply the case study ApplicationSet
kubectl apply -f deploy-as-code/applicationsets/idea-board-casestudy-appset.yaml

# Or use kustomize to apply all resources
kubectl apply -k deploy-as-code/
```

### 4. Monitor Deployments

```bash
# Check applications
kubectl get applications -n argocd

# Check pods in each environment
kubectl get pods -n idea-board-dev
kubectl get pods -n idea-board-staging
kubectl get pods -n idea-board-prod
```

## Key Features Demonstrated

### 1. **Environment Promotion**
- Dev → Staging → Production
- Branch-based deployments (develop → main)

### 2. **GitOps Principles**
- Git as single source of truth
- Declarative infrastructure
- Automated synchronization
- Version-controlled deployments

### 3. **Resource Scaling**
- Environment-specific resource limits
- Replica counts per environment
- Auto-scaling configuration

### 4. **Security & Governance**
- Manual approval for production
- Automated sync for dev/staging
- Namespace isolation
- RBAC through ArgoCD projects

## Demo Scenarios

### Scenario 1: Feature Deployment
1. Push code to `develop` branch
2. GitHub Actions builds new Docker image
3. ArgoCD detects change and auto-deploys to dev
4. Test in dev environment
5. Merge to `main` branch
6. Auto-deploys to staging
7. Manual sync to production

### Scenario 2: Rollback
1. Production issue detected
2. Use ArgoCD UI to rollback to previous version
3. Instant rollback with GitOps history

### Scenario 3: Scaling
1. Update replicas in ApplicationSet
2. Commit and push
3. ArgoCD applies new replica count
4. Demonstrates declarative scaling

## Benefits for Case Study

1. **Cost Effective**: Single cluster with namespace separation
2. **Real-world Patterns**: Demonstrates actual DevOps practices
3. **Easy to Demo**: Visual ArgoCD UI for presentations
4. **Complete Pipeline**: CI/CD from code to deployment
5. **Best Practices**: GitOps, IaC, containerization

## Monitoring & Observability

Access ArgoCD dashboard to see:
- Application health status
- Sync status
- Resource usage
- Deployment history
- Real-time logs

## Cleanup

```bash
# Remove all applications
kubectl delete applicationset idea-board-casestudy -n argocd

# Remove namespaces
kubectl delete namespace idea-board-dev idea-board-staging idea-board-prod
```

## Next Steps

For production readiness, consider:
1. External secrets management (Sealed Secrets/External Secrets Operator)
2. Progressive delivery (Flagger/Argo Rollouts)
3. Monitoring stack (Prometheus/Grafana)
4. Service mesh (Istio/Linkerd)
5. Multi-cluster deployment