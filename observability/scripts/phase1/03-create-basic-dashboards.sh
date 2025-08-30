#!/bin/bash
# Create basic CloudWatch dashboards

set -e

REGION=${AWS_REGION:-"us-east-1"}
CLUSTER_NAME=${CLUSTER_NAME:-"ecommerce-cluster"}

echo "📊 Creating basic CloudWatch dashboards..."

# Create service overview dashboard
cat > /tmp/service-overview-dashboard.json << EOF
{
  "widgets": [
    {
      "type": "metric",
      "properties": {
        "metrics": [
          ["AWS/ContainerInsights", "pod_cpu_utilization", "ClusterName", "$CLUSTER_NAME", "Namespace", "ecommerce"],
          [".", "pod_memory_utilization", ".", ".", ".", "."]
        ],
        "period": 300,
        "stat": "Average",
        "region": "$REGION",
        "title": "Pod Resource Utilization"
      }
    },
    {
      "type": "metric",
      "properties": {
        "metrics": [
          ["AWS/ContainerInsights", "pod_number_of_containers", "ClusterName", "$CLUSTER_NAME", "Namespace", "ecommerce"]
        ],
        "period": 300,
        "stat": "Average",
        "region": "$REGION",
        "title": "Running Pods"
      }
    }
  ]
}
EOF

aws cloudwatch put-dashboard \
  --dashboard-name "ECommerce-Service-Overview" \
  --dashboard-body file:///tmp/service-overview-dashboard.json \
  --region $REGION \
  --no-cli-pager

echo "✅ Basic dashboards created successfully"