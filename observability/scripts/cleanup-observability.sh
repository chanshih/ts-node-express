#!/bin/bash
# Cleanup observability resources

set -e

REGION=${AWS_REGION:-"us-east-1"}
CLUSTER_NAME=${CLUSTER_NAME:-"ecommerce-cluster"}

echo "🧹 Cleaning up observability resources..."

# Delete CloudWatch alarms
SERVICES=("user-service" "product-service" "order-service" "payment-service" "notification-service")

for service in "${SERVICES[@]}"; do
  aws cloudwatch delete-alarms \
    --alarm-names "${service}-high-cpu" "${service}-high-memory" "${service}-high-error-rate" \
    --region $REGION \
    --no-cli-pager 2>/dev/null || echo "Alarms for $service not found"
done

# Delete business alarms
aws cloudwatch delete-alarms \
  --alarm-names "low-order-completion-rate" "high-cloudwatch-costs" \
  --region $REGION \
  --no-cli-pager 2>/dev/null || echo "Business alarms not found"

# Delete dashboards
aws cloudwatch delete-dashboards \
  --dashboard-names "ECommerce-Service-Overview" "ECommerce-Business-Metrics" "ECommerce-Service-Dependencies" \
  --region $REGION \
  --no-cli-pager 2>/dev/null || echo "Dashboards not found"

# Delete log groups
for service in "${SERVICES[@]}"; do
  aws logs delete-log-group \
    --log-group-name "/aws/eks/ecommerce/$service" \
    --region $REGION \
    --no-cli-pager 2>/dev/null || echo "Log group for $service not found"
done

aws logs delete-log-group \
  --log-group-name "/aws/eks/ecommerce/alb-access" \
  --region $REGION \
  --no-cli-pager 2>/dev/null || echo "ALB log group not found"

# Delete X-Ray daemon
kubectl delete -f /tmp/xray-daemon.yaml 2>/dev/null || echo "X-Ray daemon not found"

# Delete Container Insights
kubectl delete namespace amazon-cloudwatch 2>/dev/null || echo "CloudWatch namespace not found"

echo "✅ Observability cleanup completed"