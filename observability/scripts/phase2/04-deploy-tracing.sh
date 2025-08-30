#!/bin/bash
# Deploy AWS Distro for OpenTelemetry EKS Add-on

set -e

CLUSTER_NAME=${CLUSTER_NAME:-"eks-demo"}
REGION=${AWS_REGION:-"us-east-1"}

echo "🔍 Installing AWS Distro for OpenTelemetry EKS Add-on..."

# Install ADOT EKS Add-on
aws eks create-addon \
    --cluster-name $CLUSTER_NAME \
    --addon-name adot \
    --region $REGION

# Wait for add-on to be active
echo "⏳ Waiting for ADOT add-on to be active..."
aws eks wait addon-active \
    --cluster-name $CLUSTER_NAME \
    --addon-name adot \
    --region $REGION

echo "✅ AWS Distro for OpenTelemetry EKS Add-on installed successfully"