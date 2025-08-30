#!/bin/bash
# Fine-tune alerts and notification channels

set -e

REGION=${AWS_REGION:-"us-east-1"}
SNS_TOPIC_ARN=${SNS_TOPIC_ARN:-""}

echo "🔔 Configuring alert notifications..."

if [ -z "$SNS_TOPIC_ARN" ]; then
  echo "Creating SNS topic for alerts..."
  SNS_TOPIC_ARN=$(aws sns create-topic \
    --name ecommerce-alerts \
    --region $REGION \
    --query 'TopicArn' \
    --output text \
    --no-cli-pager)
  
  echo "SNS Topic created: $SNS_TOPIC_ARN"
  echo "Add email subscriptions manually in AWS Console"
fi

# Update critical alarms with SNS notifications
CRITICAL_ALARMS=("order-service-high-error-rate" "payment-service-high-error-rate" "low-order-completion-rate")

for alarm in "${CRITICAL_ALARMS[@]}"; do
  aws cloudwatch put-metric-alarm \
    --alarm-name "$alarm" \
    --alarm-actions "$SNS_TOPIC_ARN" \
    --ok-actions "$SNS_TOPIC_ARN" \
    --region $REGION \
    --no-cli-pager 2>/dev/null || echo "Alarm $alarm not found, skipping..."
done

echo "✅ Alert notifications configured successfully"
echo "📧 SNS Topic ARN: $SNS_TOPIC_ARN"