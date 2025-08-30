#!/bin/bash
# Deploy AWS Distro for OpenTelemetry Collector for X-Ray tracing

set -e

CLUSTER_NAME=${CLUSTER_NAME:-"ecommerce-cluster"}
REGION=${AWS_REGION:-"us-east-1"}

echo "🔍 Deploying AWS Distro for OpenTelemetry Collector..."

# Create ADOT Collector manifest
cat > /tmp/adot-collector.yaml << EOF
apiVersion: v1
kind: ConfigMap
metadata:
  name: adot-collector-config
  namespace: ecommerce
data:
  adot-config.yaml: |
    receivers:
      otlp:
        protocols:
          grpc:
            endpoint: 0.0.0.0:4317
          http:
            endpoint: 0.0.0.0:4318
    processors:
      batch:
    exporters:
      awsxray:
        region: ${REGION}
    service:
      pipelines:
        traces:
          receivers: [otlp]
          processors: [batch]
          exporters: [awsxray]
---
apiVersion: apps/v1
kind: DaemonSet
metadata:
  name: adot-collector
  namespace: ecommerce
spec:
  selector:
    matchLabels:
      app: adot-collector
  template:
    metadata:
      labels:
        app: adot-collector
    spec:
      serviceAccountName: adot-collector
      containers:
      - name: adot-collector
        image: public.ecr.aws/aws-observability/aws-otel-collector:latest
        command: ["/awscollector", "--config=/etc/adot/adot-config.yaml"]
        volumeMounts:
        - name: adot-config
          mountPath: /etc/adot
        resources:
          limits:
            memory: 256Mi
            cpu: 250m
          requests:
            memory: 64Mi
            cpu: 50m
        ports:
        - containerPort: 4317
          protocol: TCP
        - containerPort: 4318
          protocol: TCP
      volumes:
      - name: adot-config
        configMap:
          name: adot-collector-config
---
apiVersion: v1
kind: ServiceAccount
metadata:
  name: adot-collector
  namespace: ecommerce
---
apiVersion: v1
kind: Service
metadata:
  name: adot-collector
  namespace: ecommerce
spec:
  selector:
    app: adot-collector
  ports:
  - name: grpc
    port: 4317
    protocol: TCP
    targetPort: 4317
  - name: http
    port: 4318
    protocol: TCP
    targetPort: 4318
EOF

# Apply ADOT Collector
kubectl apply -f /tmp/adot-collector.yaml

# Wait for deployment
echo "⏳ Waiting for ADOT Collector to be ready..."
kubectl wait --for=condition=ready pod -l app=adot-collector -n ecommerce --timeout=300s

echo "✅ AWS Distro for OpenTelemetry Collector deployed successfully"