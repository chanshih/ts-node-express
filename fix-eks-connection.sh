#!/bin/bash

echo "🔧 EKS Connection Fix Script"
echo "================================"

# Check AWS credentials
echo "1. Checking AWS Credentials:"
aws sts get-caller-identity 2>/dev/null && echo " ✅ AWS credentials valid" || {
    echo " ❌ AWS credentials invalid"
    echo "   Run: aws configure"
    echo "   Or: export AWS_PROFILE=your-profile"
    exit 1
}

# List available EKS clusters
echo -e "\n2. Available EKS Clusters:"
CLUSTERS=$(aws eks list-clusters --region us-east-1 --query 'clusters[]' --output text 2>/dev/null)
if [ -z "$CLUSTERS" ]; then
    echo " ❌ No EKS clusters found in us-east-1"
    echo "   You may need to:"
    echo "   - Deploy the EKS cluster first"
    echo "   - Check the correct AWS region"
    exit 1
else
    echo " ✅ Found clusters: $CLUSTERS"
fi

# Update kubeconfig for each cluster
echo -e "\n3. Updating kubeconfig:"
for cluster in $CLUSTERS; do
    echo "   Updating config for: $cluster"
    aws eks update-kubeconfig --region us-east-1 --name "$cluster"
done

# Test connection
echo -e "\n4. Testing Connection:"
kubectl cluster-info --request-timeout=10s && echo " ✅ Connected to cluster" || {
    echo " ❌ Still cannot connect"
    echo "   Try: kubectl config get-contexts"
    echo "   Then: kubectl config use-context <context-name>"
}

# Check if ecommerce namespace exists
echo -e "\n5. Checking for ecommerce namespace:"
kubectl get namespace ecommerce 2>/dev/null && echo " ✅ Namespace exists" || {
    echo " ❌ Namespace missing - creating it"
    kubectl create namespace ecommerce
}