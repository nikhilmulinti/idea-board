#!/bin/bash

set -e

echo "🚀 Starting deployment of Idea Board application to Kubernetes..."

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Configuration
NAMESPACE="ideaboard"
CONTEXT="ng-central-dev"

echo -e "${YELLOW}Using context: ${CONTEXT}${NC}"
kubectl config use-context ${CONTEXT}

# Step 1: Create namespace if it doesn't exist
echo -e "${GREEN}Creating namespace ${NAMESPACE}...${NC}"
kubectl create namespace ${NAMESPACE} --dry-run=client -o yaml | kubectl apply -f -

# Step 2: Install NGINX Ingress Controller
echo -e "${GREEN}Installing NGINX Ingress Controller...${NC}"
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm repo update

helm upgrade --install nginx-ingress ingress-nginx/ingress-nginx \
  --namespace ingress-nginx \
  --create-namespace \
  --set controller.service.type=LoadBalancer \
  --set controller.service.annotations."service\.beta\.kubernetes\.io/azure-load-balancer-health-probe-request-path"=/healthz \
  --wait

# Step 3: Install cert-manager
echo -e "${GREEN}Installing cert-manager...${NC}"
helm repo add jetstack https://charts.jetstack.io
helm repo update

helm upgrade --install cert-manager jetstack/cert-manager \
  --namespace cert-manager \
  --create-namespace \
  --set installCRDs=true \
  --version v1.13.2 \
  --wait

# Wait for cert-manager to be ready
kubectl wait --for=condition=ready pod \
  --all \
  --namespace cert-manager \
  --timeout=120s

# Step 4: Create ClusterIssuer for Let's Encrypt
echo -e "${GREEN}Creating ClusterIssuer for Let's Encrypt...${NC}"
cat <<EOF | kubectl apply -f -
apiVersion: cert-manager.io/v1
kind: ClusterIssuer
metadata:
  name: letsencrypt-prod
spec:
  acme:
    server: https://acme-v02.api.letsencrypt.org/directory
    email: admin@simpletwist.dpdns.org
    privateKeySecretRef:
      name: letsencrypt-prod
    solvers:
    - http01:
        ingress:
          class: nginx
EOF

# Wait for ClusterIssuer to be ready
sleep 5

# Step 5: Deploy Backend
echo -e "${GREEN}Deploying Backend service...${NC}"
helm upgrade --install backend ./helm/charts/backend \
  --namespace ${NAMESPACE} \
  --set image.tag=latest \
  --wait

# Step 6: Deploy Frontend
echo -e "${GREEN}Deploying Frontend service...${NC}"
helm upgrade --install frontend ./helm/charts/frontend \
  --namespace ${NAMESPACE} \
  --set image.tag=latest \
  --wait

# Step 7: Get the LoadBalancer IP
echo -e "${GREEN}Getting LoadBalancer IP...${NC}"
INGRESS_IP=$(kubectl get svc nginx-ingress-ingress-nginx-controller \
  -n ingress-nginx \
  -o jsonpath='{.status.loadBalancer.ingress[0].ip}' 2>/dev/null || echo "pending")

if [ "$INGRESS_IP" = "pending" ] || [ -z "$INGRESS_IP" ]; then
  echo -e "${YELLOW}Waiting for LoadBalancer IP to be assigned...${NC}"
  kubectl get svc nginx-ingress-ingress-nginx-controller -n ingress-nginx --watch &
  WATCH_PID=$!
  sleep 30
  kill $WATCH_PID 2>/dev/null || true

  INGRESS_IP=$(kubectl get svc nginx-ingress-ingress-nginx-controller \
    -n ingress-nginx \
    -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
fi

echo -e "${GREEN}✅ Deployment completed successfully!${NC}"
echo ""
echo "📝 Deployment Summary:"
echo "   Namespace: ${NAMESPACE}"
echo "   Backend: https://simpletwist.dpdns.org/api"
echo "   Frontend: https://simpletwist.dpdns.org"
echo ""

if [ ! -z "$INGRESS_IP" ] && [ "$INGRESS_IP" != "pending" ]; then
  echo -e "${YELLOW}LoadBalancer IP: ${INGRESS_IP}${NC}"
  echo ""
  echo "⚠️  Important: Make sure your DNS (simpletwist.dpdns.org) points to: ${INGRESS_IP}"
else
  echo -e "${RED}⚠️  LoadBalancer IP not yet assigned. Check later with:${NC}"
  echo "   kubectl get svc nginx-ingress-ingress-nginx-controller -n ingress-nginx"
fi

echo ""
echo "To check the status of your pods:"
echo "   kubectl get pods -n ${NAMESPACE}"
echo ""
echo "To check the ingress status:"
echo "   kubectl get ingress -n ${NAMESPACE}"
echo ""
echo "To view logs:"
echo "   kubectl logs -n ${NAMESPACE} -l app.kubernetes.io/name=backend"
echo "   kubectl logs -n ${NAMESPACE} -l app.kubernetes.io/name=frontend"