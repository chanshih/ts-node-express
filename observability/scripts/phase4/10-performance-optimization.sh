#!/bin/bash
# Performance optimization for observability

set -e

REGION=${AWS_REGION:-"us-east-1"}

echo "⚡ Optimizing observability performance..."

# Configure X-Ray sampling rules
cat > /tmp/sampling-rules.json << EOF
{
  "version": 2,
  "default": {
    "fixed_target": 1,
    "rate": 0.1
  },
  "rules": [
    {
      "description": "Critical path sampling",
      "service_name": "order-service",
      "http_method": "POST",
      "url_path": "/api/orders",
      "fixed_target": 2,
      "rate": 0.5
    }
  ]
}
EOF

aws xray put-sampling-rule \
  --sampling-rule file:///tmp/sampling-rules.json \
  --region $REGION \
  --no-cli-pager 2>/dev/null || echo "Sampling rules already configured"

# Optimize log retention for cost
SERVICES=("user-service" "product-service" "order-service" "payment-service" "notification-service")

for service in "${SERVICES[@]}"; do
  aws logs put-retention-policy \
    --log-group-name "/aws/eks/ecommerce/$service" \
    --retention-in-days 30 \
    --region $REGION \
    --no-cli-pager
done

echo "✅ Performance optimization completed"