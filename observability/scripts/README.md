# Observability Implementation Scripts

Modular shell scripts to automate the observability implementation for ecommerce microservices.

## Quick Start

```bash
# Set environment variables
export CLUSTER_NAME="eks-demo"
export AWS_REGION="us-east-1"

# Run complete setup
./00-setup-observability.sh
```

## Phase-by-Phase Execution

### Phase 1: Infrastructure Monitoring
```bash
cd phase1
./01-deploy-container-insights.sh
./02-setup-logging.sh
./03-create-basic-dashboards.sh
cd ..
```

### Phase 2: Distributed Tracing
```bash
cd phase2
./04-deploy-xray.sh
./05-setup-custom-metrics.sh
./06-configure-alarms.sh
cd ..
```

### Phase 3: Business Metrics
```bash
cd phase3
./07-business-metrics.sh
./08-advanced-dashboards.sh
./09-alert-tuning.sh
cd ..
```

### Phase 4: Optimization
```bash
cd phase4
./10-performance-optimization.sh
./11-cost-optimization.sh
cd ..
```

## Prerequisites

- AWS CLI configured with appropriate permissions
- kubectl configured for EKS cluster
- EKS cluster with ecommerce namespace

## Environment Variables

- `CLUSTER_NAME`: EKS cluster name (default: ecommerce-cluster)
- `AWS_REGION`: AWS region (default: us-east-1)
- `SNS_TOPIC_ARN`: SNS topic for alerts (optional)

## Cleanup

```bash
./cleanup-observability.sh
```

## Script Components

| Script | Purpose | Dependencies |
|--------|---------|--------------|
| 01-deploy-container-insights.sh | CloudWatch Container Insights | EKS cluster |
| 02-setup-logging.sh | Log groups and retention | AWS CLI |
| 03-create-basic-dashboards.sh | Service overview dashboard | Container Insights |
| 04-deploy-xray.sh | X-Ray daemon deployment | EKS cluster |
| 05-setup-custom-metrics.sh | Custom metrics and filters | Log groups |
| 06-configure-alarms.sh | CloudWatch alarms | Custom metrics |
| 07-business-metrics.sh | Business KPI tracking | Application logs |
| 08-advanced-dashboards.sh | Business and dependency dashboards | Business metrics |
| 09-alert-tuning.sh | SNS notifications | CloudWatch alarms |
| 10-performance-optimization.sh | X-Ray sampling, retention | X-Ray daemon |
| 11-cost-optimization.sh | Cost monitoring and optimization | All components |