#!/bin/bash
# Setup custom CloudWatch metrics

set -e

REGION=${AWS_REGION:-"us-east-1"}

echo "📈 Setting up custom CloudWatch metrics..."

# Create custom metric namespaces
NAMESPACES=("ECommerce/Users" "ECommerce/Products" "ECommerce/Orders" "ECommerce/Payments" "ECommerce/Notifications")

for namespace in "${NAMESPACES[@]}"; do
  echo "Creating namespace: $namespace"
  # Namespaces are created automatically when first metric is published
done

# Create metric filters for application logs
SERVICES=("user-service" "product-service" "order-service" "payment-service" "notification-service")

for service in "${SERVICES[@]}"; do
  # Error rate metric filter
  aws logs put-metric-filter \
    --log-group-name "/aws/eks/ecommerce/$service" \
    --filter-name "${service}-error-rate" \
    --filter-pattern "[timestamp, request_id, level=\"ERROR\", ...]" \
    --metric-transformations \
      metricName=ErrorCount,metricNamespace=ECommerce/Errors,metricValue=1,defaultValue=0 \
    --region $REGION \
    --no-cli-pager

  # Response time metric filter
  aws logs put-metric-filter \
    --log-group-name "/aws/eks/ecommerce/$service" \
    --filter-name "${service}-response-time" \
    --filter-pattern "[timestamp, request_id, level, message, duration]" \
    --metric-transformations \
      metricName=ResponseTime,metricNamespace=ECommerce/Performance,metricValue='$duration',defaultValue=0 \
    --region $REGION \
    --no-cli-pager
done

echo "✅ Custom metrics configured successfully"