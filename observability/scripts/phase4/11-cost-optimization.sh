#!/bin/bash
# Cost optimization for observability

set -e

REGION=${AWS_REGION:-"us-east-1"}

echo "💰 Optimizing observability costs..."

# Set appropriate log retention policies
aws logs put-retention-policy \
  --log-group-name "/aws/eks/ecommerce/alb-access" \
  --retention-in-days 90 \
  --region $REGION \
  --no-cli-pager

# Create cost monitoring alarm
aws cloudwatch put-metric-alarm \
  --alarm-name "high-cloudwatch-costs" \
  --alarm-description "CloudWatch costs exceeding budget" \
  --metric-name EstimatedCharges \
  --namespace AWS/Billing \
  --statistic Maximum \
  --period 86400 \
  --threshold 100 \
  --comparison-operator GreaterThanThreshold \
  --evaluation-periods 1 \
  --dimensions Name=Currency,Value=USD Name=ServiceName,Value=CloudWatch \
  --region us-east-1 \
  --no-cli-pager

# Configure metric filters to reduce noise
SERVICES=("user-service" "product-service" "order-service" "payment-service" "notification-service")

for service in "${SERVICES[@]}"; do
  # Remove debug log filters in production
  aws logs delete-metric-filter \
    --log-group-name "/aws/eks/ecommerce/$service" \
    --filter-name "${service}-debug-logs" \
    --region $REGION \
    --no-cli-pager 2>/dev/null || echo "Debug filter for $service not found"
done

echo "✅ Cost optimization completed"
echo "💡 Consider:"
echo "  - Review dashboard usage monthly"
echo "  - Adjust X-Ray sampling rates based on traffic"
echo "  - Archive old logs to S3 for long-term storage"