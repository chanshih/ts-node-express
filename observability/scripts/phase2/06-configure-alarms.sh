#!/bin/bash
# Configure CloudWatch alarms

set -e

REGION=${AWS_REGION:-"us-east-1"}
CLUSTER_NAME=${CLUSTER_NAME:-"ecommerce-cluster"}

echo "🚨 Configuring CloudWatch alarms..."

SERVICES=("user-service" "product-service" "order-service" "payment-service" "notification-service")

for service in "${SERVICES[@]}"; do
  # High CPU alarm
  aws cloudwatch put-metric-alarm \
    --alarm-name "${service}-high-cpu" \
    --alarm-description "High CPU utilization for $service" \
    --metric-name pod_cpu_utilization \
    --namespace AWS/ContainerInsights \
    --statistic Average \
    --period 300 \
    --threshold 70 \
    --comparison-operator GreaterThanThreshold \
    --evaluation-periods 2 \
    --dimensions Name=ClusterName,Value=$CLUSTER_NAME Name=Namespace,Value=ecommerce Name=Service,Value=$service \
    --region $REGION \
    --no-cli-pager

  # High memory alarm
  aws cloudwatch put-metric-alarm \
    --alarm-name "${service}-high-memory" \
    --alarm-description "High memory utilization for $service" \
    --metric-name pod_memory_utilization \
    --namespace AWS/ContainerInsights \
    --statistic Average \
    --period 300 \
    --threshold 80 \
    --comparison-operator GreaterThanThreshold \
    --evaluation-periods 2 \
    --dimensions Name=ClusterName,Value=$CLUSTER_NAME Name=Namespace,Value=ecommerce Name=Service,Value=$service \
    --region $REGION \
    --no-cli-pager

  # Error rate alarm
  aws cloudwatch put-metric-alarm \
    --alarm-name "${service}-high-error-rate" \
    --alarm-description "High error rate for $service" \
    --metric-name ErrorCount \
    --namespace ECommerce/Errors \
    --statistic Sum \
    --period 300 \
    --threshold 10 \
    --comparison-operator GreaterThanThreshold \
    --evaluation-periods 2 \
    --treat-missing-data notBreaching \
    --region $REGION \
    --no-cli-pager
done

echo "✅ CloudWatch alarms configured successfully"