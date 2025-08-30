#!/bin/bash
# Setup business metrics tracking

set -e

REGION=${AWS_REGION:-"us-east-1"}

echo "💼 Setting up business metrics..."

# Create business metric filters
aws logs put-metric-filter \
  --log-group-name "/aws/eks/ecommerce/order-service" \
  --filter-name "order-completion-rate" \
  --filter-pattern "[timestamp, request_id, level, message=\"Order completed\", orderId, ...]" \
  --metric-transformations \
    metricName=OrdersCompleted,metricNamespace=ECommerce/Business,metricValue=1,defaultValue=0 \
  --region $REGION \
  --no-cli-pager

aws logs put-metric-filter \
  --log-group-name "/aws/eks/ecommerce/payment-service" \
  --filter-name "payment-success-rate" \
  --filter-pattern "[timestamp, request_id, level, message=\"Payment successful\", paymentId, ...]" \
  --metric-transformations \
    metricName=PaymentsSuccessful,metricNamespace=ECommerce/Business,metricValue=1,defaultValue=0 \
  --region $REGION \
  --no-cli-pager

aws logs put-metric-filter \
  --log-group-name "/aws/eks/ecommerce/user-service" \
  --filter-name "user-registration-rate" \
  --filter-pattern "[timestamp, request_id, level, message=\"User registered\", userId, ...]" \
  --metric-transformations \
    metricName=UsersRegistered,metricNamespace=ECommerce/Business,metricValue=1,defaultValue=0 \
  --region $REGION \
  --no-cli-pager

# Business alarms
aws cloudwatch put-metric-alarm \
  --alarm-name "low-order-completion-rate" \
  --alarm-description "Order completion rate below threshold" \
  --metric-name OrdersCompleted \
  --namespace ECommerce/Business \
  --statistic Sum \
  --period 3600 \
  --threshold 10 \
  --comparison-operator LessThanThreshold \
  --evaluation-periods 1 \
  --treat-missing-data breaching \
  --region $REGION \
  --no-cli-pager

echo "✅ Business metrics configured successfully"