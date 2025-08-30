#!/bin/bash
# Deploy CloudWatch Container Insights using EKS add-on

set -e

CLUSTER_NAME=${CLUSTER_NAME:-"eks-demo"}
REGION=${AWS_REGION:-"us-east-1"}

echo "📊 Deploying CloudWatch Container Insights add-on..."

# Install the Amazon CloudWatch Observability EKS add-on
aws eks create-addon \
    --cluster-name $CLUSTER_NAME \
    --addon-name amazon-cloudwatch-observability \
    --region $REGION

# Wait for add-on to be active
echo "⏳ Waiting for Container Insights add-on to be active..."
aws eks wait addon-active \
    --cluster-name $CLUSTER_NAME \
    --addon-name amazon-cloudwatch-observability \
    --region $REGION

echo "✅ Container Insights add-on deployed successfully"