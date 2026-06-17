#!/bin/bash

# Azure LoadBalancer Permission Fix Script
# This script grants the necessary permissions for AKS to create LoadBalancer with external IP

set -e

echo "🔧 Fixing Azure permissions for LoadBalancer..."

# Configuration from your Terraform output
RESOURCE_GROUP="ng-central-dev-rg"
CLUSTER_NAME="ng-central-dev"
MC_RESOURCE_GROUP="mc_${RESOURCE_GROUP}_${CLUSTER_NAME}_centralus"
VNET_NAME="vnet-ng-central-dev-01"
SUBNET_NAME="snet-aks-ng-central-dev-01"
SUBSCRIPTION_ID="777e3e4b-0998-4759-adc2-e7b5b19a6b28"

echo "📋 Configuration:"
echo "   Resource Group: $RESOURCE_GROUP"
echo "   Cluster Name: $CLUSTER_NAME"
echo "   MC Resource Group: $MC_RESOURCE_GROUP"
echo "   VNet: $VNET_NAME"
echo "   Subnet: $SUBNET_NAME"

# Get the cluster's managed identity
echo "🔍 Getting AKS managed identity..."
IDENTITY_ID=$(az aks show \
    --resource-group $RESOURCE_GROUP \
    --name $CLUSTER_NAME \
    --query "identityProfile.kubeletidentity.clientId" -o tsv)

if [ -z "$IDENTITY_ID" ]; then
    # Try getting system assigned managed identity
    IDENTITY_ID=$(az aks show \
        --resource-group $RESOURCE_GROUP \
        --name $CLUSTER_NAME \
        --query "identity.principalId" -o tsv)
fi

echo "   Managed Identity: $IDENTITY_ID"

# Get the subnet resource ID
SUBNET_ID="/subscriptions/$SUBSCRIPTION_ID/resourceGroups/$RESOURCE_GROUP/providers/Microsoft.Network/virtualNetworks/$VNET_NAME/subnets/$SUBNET_NAME"
echo "   Subnet ID: $SUBNET_ID"

# Assign Network Contributor role to the managed identity on the subnet
echo "🔐 Assigning Network Contributor role to managed identity on subnet..."
az role assignment create \
    --assignee $IDENTITY_ID \
    --role "Network Contributor" \
    --scope $SUBNET_ID \
    || echo "Role assignment might already exist, continuing..."

# Also assign Network Contributor on the VNet
echo "🔐 Assigning Network Contributor role on VNet..."
VNET_ID="/subscriptions/$SUBSCRIPTION_ID/resourceGroups/$RESOURCE_GROUP/providers/Microsoft.Network/virtualNetworks/$VNET_NAME"
az role assignment create \
    --assignee $IDENTITY_ID \
    --role "Network Contributor" \
    --scope $VNET_ID \
    || echo "Role assignment might already exist, continuing..."

# Assign Contributor role on the MC resource group (for public IP creation)
echo "🔐 Assigning Contributor role on MC resource group..."
az role assignment create \
    --assignee $IDENTITY_ID \
    --role "Contributor" \
    --scope "/subscriptions/$SUBSCRIPTION_ID/resourceGroups/$MC_RESOURCE_GROUP" \
    || echo "Role assignment might already exist, continuing..."

echo "✅ Permissions configured successfully!"
echo ""
echo "🔄 Now restarting the LoadBalancer service to apply changes..."

# Delete and recreate the LoadBalancer service to trigger IP allocation
kubectl delete svc nginx-ingress-ingress-nginx-controller -n ingress-nginx --ignore-not-found=true

# Wait a moment
sleep 5

# Recreate the service
kubectl apply -f - <<EOF
apiVersion: v1
kind: Service
metadata:
  name: nginx-ingress-ingress-nginx-controller
  namespace: ingress-nginx
  labels:
    app.kubernetes.io/component: controller
    app.kubernetes.io/instance: nginx-ingress
    app.kubernetes.io/name: ingress-nginx
  annotations:
    service.beta.kubernetes.io/azure-load-balancer-health-probe-request-path: /healthz
spec:
  type: LoadBalancer
  selector:
    app.kubernetes.io/component: controller
    app.kubernetes.io/instance: nginx-ingress
    app.kubernetes.io/name: ingress-nginx
  ports:
    - name: http
      port: 80
      targetPort: 80
      protocol: TCP
    - name: https
      port: 443
      targetPort: 443
      protocol: TCP
EOF

echo ""
echo "⏳ Waiting for LoadBalancer IP to be assigned (this may take 2-3 minutes)..."

# Wait for external IP
for i in {1..60}; do
    EXTERNAL_IP=$(kubectl get svc nginx-ingress-ingress-nginx-controller -n ingress-nginx -o jsonpath='{.status.loadBalancer.ingress[0].ip}' 2>/dev/null || echo "")
    if [ ! -z "$EXTERNAL_IP" ]; then
        echo ""
        echo "✅ LoadBalancer External IP assigned: $EXTERNAL_IP"
        echo ""
        echo "📝 Next steps:"
        echo "1. Update your DNS (simpletwist.dpdns.org) to point to: $EXTERNAL_IP"
        echo "2. Run the deployment script to deploy your application:"
        echo "   ./deploy-apps.sh"
        break
    fi
    echo -n "."
    sleep 5
done

if [ -z "$EXTERNAL_IP" ]; then
    echo ""
    echo "⚠️  External IP not assigned yet. Check status with:"
    echo "   kubectl get svc nginx-ingress-ingress-nginx-controller -n ingress-nginx"
    echo ""
    echo "You can also check events for any issues:"
    echo "   kubectl describe svc nginx-ingress-ingress-nginx-controller -n ingress-nginx"
fi