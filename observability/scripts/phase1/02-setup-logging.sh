#!/bin/bash
# Setup application logging for Container Insights

set -e

CLUSTER_NAME=${CLUSTER_NAME:-"ecommerce-cluster"}
REGION=${AWS_REGION:-"us-east-1"}

echo "📝 Setting up application logging for Container Insights..."

# Create log groups for each service
SERVICES=("user-service" "product-service" "order-service" "payment-service" "notification-service")

for service in "${SERVICES[@]}"; do
    echo "Creating log group for $service..."
    aws logs create-log-group \
        --log-group-name "/aws/containerinsights/$CLUSTER_NAME/application/$service" \
        --region $REGION \
        --retention-in-days 7 || echo "Log group already exists"
done

# Create log group for general application logs
aws logs create-log-group \
    --log-group-name "/aws/containerinsights/$CLUSTER_NAME/application" \
    --region $REGION \
    --retention-in-days 7 || echo "Log group already exists"

echo "✅ Application log groups created successfully"