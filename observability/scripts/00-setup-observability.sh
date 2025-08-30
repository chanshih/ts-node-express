#!/bin/bash
# Main orchestration script for observability implementation

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CLUSTER_NAME=${CLUSTER_NAME:-"ecommerce-cluster"}
REGION=${AWS_REGION:-"us-east-1"}

echo "🚀 Starting Ecommerce Microservices Observability Setup"
echo "Cluster: $CLUSTER_NAME | Region: $REGION"

# Phase 1: Infrastructure Monitoring
echo "📊 Phase 1: Setting up Container Insights and Logging..."
$SCRIPT_DIR/phase1/01-deploy-container-insights.sh
$SCRIPT_DIR/phase1/02-setup-logging.sh
$SCRIPT_DIR/phase1/03-create-basic-dashboards.sh

# Phase 2: Distributed Tracing
echo "🔍 Phase 2: Setting up X-Ray and Custom Metrics..."
$SCRIPT_DIR/phase2/04-deploy-xray.sh
$SCRIPT_DIR/phase2/05-setup-custom-metrics.sh
$SCRIPT_DIR/phase2/06-configure-alarms.sh

# Phase 3: Business Metrics
echo "📈 Phase 3: Setting up Business Metrics and Advanced Dashboards..."
$SCRIPT_DIR/phase3/07-business-metrics.sh
$SCRIPT_DIR/phase3/08-advanced-dashboards.sh
$SCRIPT_DIR/phase3/09-alert-tuning.sh

# Phase 4: Optimization
echo "⚡ Phase 4: Performance and Cost Optimization..."
$SCRIPT_DIR/phase4/10-performance-optimization.sh
$SCRIPT_DIR/phase4/11-cost-optimization.sh

echo "✅ Observability setup complete!"
echo "📋 Next steps:"
echo "  1. Update application code with instrumentation"
echo "  2. Redeploy services with observability enabled"
echo "  3. Validate dashboards and alerts"