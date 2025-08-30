# Ecommerce Microservices Observability Design Plan

## Architecture Overview

The ecommerce platform consists of 5 microservices running on AWS EKS:
- **User Service** (Port 3001) - Authentication and user management
- **Product Service** (Port 3002) - Product catalog and inventory  
- **Order Service** (Port 3003) - Order processing (calls Product Service sync)
- **Payment Service** (Port 3004) - Payment processing
- **Notification Service** (Port 3005) - Email/SMS notifications

## Observability Strategy

### 1. Metrics Collection (CloudWatch Container Insights)

**Implementation:**
- Deploy CloudWatch Container Insights on EKS cluster
- Collect pod, node, and cluster-level metrics
- Custom application metrics via CloudWatch SDK

**Key Metrics:**
- **Infrastructure:** CPU, memory, network, disk I/O per service
- **Application:** Request rate, response time, error rate (RED metrics)
- **Business:** Order completion rate, payment success rate, user registrations

**CloudWatch Dashboards:**
- Service-level dashboard per microservice
- Cross-service dependency dashboard
- Business metrics dashboard

### 2. Distributed Tracing (AWS X-Ray)

**Implementation:**
- Deploy X-Ray daemon as DaemonSet
- Instrument Node.js applications with X-Ray SDK
- Trace inter-service communication (Order → Product Service)

**Trace Points:**
- HTTP requests between services
- Database operations (if applicable)
- External API calls
- Critical business operations

### 3. Logging (CloudWatch Logs)

**Log Aggregation:**
- Centralized logging via CloudWatch Logs
- Structured JSON logging format
- Log groups per service with retention policies

**Log Categories:**
- **Application Logs:** Business logic, errors, warnings
- **Access Logs:** HTTP requests/responses via ALB
- **Audit Logs:** Security events, authentication
- **Performance Logs:** Slow queries, timeouts

### 4. Alerting (CloudWatch Alarms)

**Critical Alerts:**
- Service availability < 99%
- Response time > 2 seconds (P95)
- Error rate > 5%
- Memory usage > 80%
- CPU usage > 70%

**Business Alerts:**
- Order processing failures
- Payment service errors
- Product service unavailable (impacts orders)

### 5. Service Health Monitoring

**Health Checks:**
- Kubernetes liveness/readiness probes
- Custom health endpoints per service
- Dependency health validation

**SLA Monitoring:**
- Service availability targets
- Response time SLAs
- Error rate thresholds

## Implementation Components

### 1. CloudWatch Container Insights Setup

```yaml
# CloudWatch Container Insights ConfigMap
apiVersion: v1
kind: ConfigMap
metadata:
  name: cwagentconfig
  namespace: amazon-cloudwatch
data:
  cwagentconfig.json: |
    {
      "logs": {
        "metrics_collected": {
          "kubernetes": {
            "cluster_name": "ecommerce-cluster",
            "metrics_collection_interval": 60
          }
        }
      },
      "metrics": {
        "namespace": "CWAgent",
        "metrics_collected": {
          "cpu": {"measurement": ["cpu_usage_idle", "cpu_usage_iowait"]},
          "disk": {"measurement": ["used_percent"], "resources": ["*"]},
          "mem": {"measurement": ["mem_used_percent"]}
        }
      }
    }
```

### 2. X-Ray Integration

**Node.js Instrumentation:**
```javascript
// Add to each service
const AWSXRay = require('aws-xray-sdk-core');
const express = require('express');
const app = AWSXRay.captureHTTPsGlobal(express());

// Capture HTTP requests
app.use(AWSXRay.express.openSegment('ecommerce-service'));
app.use(AWSXRay.express.closeSegment());
```

**X-Ray DaemonSet:**
```yaml
apiVersion: apps/v1
kind: DaemonSet
metadata:
  name: xray-daemon
  namespace: ecommerce
spec:
  selector:
    matchLabels:
      app: xray-daemon
  template:
    spec:
      containers:
      - name: xray-daemon
        image: amazon/aws-xray-daemon:latest
        ports:
        - containerPort: 2000
          protocol: UDP
```

### 3. Custom Metrics Implementation

**Application Metrics:**
```javascript
const AWS = require('aws-sdk');
const cloudwatch = new AWS.CloudWatch();

// Custom metric for order processing
const putMetric = (metricName, value, unit = 'Count') => {
  const params = {
    Namespace: 'ECommerce/Orders',
    MetricData: [{
      MetricName: metricName,
      Value: value,
      Unit: unit,
      Dimensions: [{
        Name: 'Service',
        Value: process.env.SERVICE_NAME
      }]
    }]
  };
  cloudwatch.putMetricData(params).promise();
};
```

### 4. Structured Logging

**Log Format:**
```javascript
const winston = require('winston');

const logger = winston.createLogger({
  format: winston.format.combine(
    winston.format.timestamp(),
    winston.format.json()
  ),
  defaultMeta: {
    service: process.env.SERVICE_NAME,
    version: process.env.APP_VERSION
  },
  transports: [
    new winston.transports.Console()
  ]
});

// Usage
logger.info('Order processed', {
  orderId: order.id,
  userId: order.userId,
  amount: order.amount,
  duration: processingTime
});
```

### 5. CloudWatch Alarms

**Service Availability Alarm:**
```yaml
Type: AWS::CloudWatch::Alarm
Properties:
  AlarmName: !Sub "${ServiceName}-HighErrorRate"
  MetricName: 4XXError
  Namespace: AWS/ApplicationELB
  Statistic: Sum
  Period: 300
  EvaluationPeriods: 2
  Threshold: 10
  ComparisonOperator: GreaterThanThreshold
```

## Monitoring Dashboards

### 1. Service Overview Dashboard
- Service health status grid
- Request volume trends
- Error rate by service
- Response time percentiles

### 2. Infrastructure Dashboard  
- EKS cluster resource utilization
- Pod scaling events
- Node health status
- Network traffic patterns

### 3. Business Metrics Dashboard
- Order conversion funnel
- Payment success rates
- User activity metrics
- Revenue tracking

### 4. Dependency Map Dashboard
- Service communication flow
- Dependency health status
- Circuit breaker states
- Timeout incidents

## Alert Escalation

### Severity Levels:
- **P1 (Critical):** Service completely down, payment failures
- **P2 (High):** High error rates, performance degradation
- **P3 (Medium):** Resource warnings, minor issues
- **P4 (Low):** Informational alerts

### Notification Channels:
- **Slack:** Real-time alerts to #ops-alerts
- **PagerDuty:** P1/P2 incidents with escalation
- **Email:** Daily/weekly summary reports
- **SMS:** Critical production issues only

## Performance Baselines

### Response Time SLAs:
- User Service: < 200ms (P95)
- Product Service: < 300ms (P95) 
- Order Service: < 500ms (P95)
- Payment Service: < 1000ms (P95)
- Notification Service: < 100ms (P95)

### Availability Targets:
- All services: 99.9% uptime
- Critical path (Order → Product): 99.95% uptime

### Error Rate Thresholds:
- Normal operations: < 1%
- Warning level: 1-5%
- Critical level: > 5%

## Cost Optimization

### Log Retention:
- Application logs: 30 days
- Access logs: 90 days  
- Audit logs: 1 year
- Debug logs: 7 days

### Metrics Retention:
- High-resolution (1-minute): 15 days
- Standard (5-minute): 63 days
- Aggregated (1-hour): 455 days

### Sampling Rates:
- X-Ray tracing: 10% sampling for normal traffic
- Increase to 100% during incidents
- Custom sampling rules for critical paths

## Implementation Timeline

### Phase 1 (Week 1-2):
- Deploy Container Insights
- Implement structured logging
- Create basic dashboards

### Phase 2 (Week 3-4):  
- Add X-Ray tracing
- Implement custom metrics
- Configure critical alarms

### Phase 3 (Week 5-6):
- Business metrics tracking
- Advanced dashboards
- Alert fine-tuning

### Phase 4 (Week 7-8):
- Performance optimization
- Cost optimization
- Documentation and training

## Success Metrics

### Technical KPIs:
- Mean Time to Detection (MTTD): < 5 minutes
- Mean Time to Resolution (MTTR): < 30 minutes
- Alert noise ratio: < 10% false positives
- Dashboard adoption: 100% team usage

### Business KPIs:
- Service availability: 99.9%+
- Customer satisfaction: No degradation
- Incident reduction: 50% fewer P1/P2 incidents
- Operational efficiency: 25% faster troubleshooting