#!/bin/bash
# Deploy AWS Distro for OpenTelemetry EKS Add-on

set -e

CLUSTER_NAME=${CLUSTER_NAME:-"eks-demo"}
REGION=${AWS_REGION:-"us-east-1"}

echo "🔍 Installing AWS Distro for OpenTelemetry EKS Add-on..."

# Check if add-on already exists
if aws eks describe-addon --cluster-name $CLUSTER_NAME --addon-name adot --region $REGION >/dev/null 2>&1; then
    echo "⚠️  ADOT add-on already exists. Deleting first..."
    aws eks delete-addon --cluster-name $CLUSTER_NAME --addon-name adot --region $REGION
    echo "⏳ Waiting for add-on deletion..."
    aws eks wait addon-deleted --cluster-name $CLUSTER_NAME --addon-name adot --region $REGION
fi

# Install ADOT EKS Add-on
echo "📦 Creating ADOT add-on..."
aws eks create-addon \
    --cluster-name $CLUSTER_NAME \
    --addon-name adot \
    --region $REGION

# Wait for add-on to be active
echo "⏳ Waiting for ADOT add-on to be active..."
aws eks wait addon-active --cluster-name $CLUSTER_NAME --addon-name adot --region $REGION

# Check final status
STATUS=$(aws eks describe-addon --cluster-name $CLUSTER_NAME --addon-name adot --region $REGION --query 'addon.status' --output text)
if [ "$STATUS" != "ACTIVE" ]; then
    echo "❌ Add-on failed to become active. Status: $STATUS"
    aws eks describe-addon --cluster-name $CLUSTER_NAME --addon-name adot --region $REGION
    exit 1
fi

echo "✅ AWS Distro for OpenTelemetry EKS Add-on installed successfully"