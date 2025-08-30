#!/bin/bash
# Create advanced CloudWatch dashboards

set -e

REGION=${AWS_REGION:-"us-east-1"}
CLUSTER_NAME=${CLUSTER_NAME:-"ecommerce-cluster"}

echo "📊 Creating advanced dashboards..."

# Business metrics dashboard
cat > /tmp/business-dashboard.json << EOF
{
  "widgets": [
    {
      "type": "metric",
      "properties": {
        "metrics": [
          ["ECommerce/Business", "OrdersCompleted"],
          [".", "PaymentsSuccessful"],
          [".", "UsersRegistered"]
        ],
        "period": 3600,
        "stat": "Sum",
        "region": "$REGION",
        "title": "Business Metrics"
      }
    },
    {
      "type": "metric",
      "properties": {
        "metrics": [
          ["ECommerce/Errors", "ErrorCount"]
        ],
        "period": 300,
        "stat": "Sum",
        "region": "$REGION",
        "title": "Error Rate"
      }
    }
  ]
}
EOF

aws cloudwatch put-dashboard \
  --dashboard-name "ECommerce-Business-Metrics" \
  --dashboard-body file:///tmp/business-dashboard.json \
  --region $REGION \
  --no-cli-pager

# Service dependency dashboard
cat > /tmp/dependency-dashboard.json << EOF
{
  "widgets": [
    {
      "type": "metric",
      "properties": {
        "metrics": [
          ["AWS/X-Ray", "TracesReceived", "ServiceName", "order-service"],
          [".", ".", ".", "product-service"]
        ],
        "period": 300,
        "stat": "Sum",
        "region": "$REGION",
        "title": "Service Communication"
      }
    }
  ]
}
EOF

aws cloudwatch put-dashboard \
  --dashboard-name "ECommerce-Service-Dependencies" \
  --dashboard-body file:///tmp/dependency-dashboard.json \
  --region $REGION \
  --no-cli-pager

echo "✅ Advanced dashboards created successfully"