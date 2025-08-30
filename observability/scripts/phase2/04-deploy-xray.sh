#!/bin/bash
# Deploy AWS X-Ray daemon for distributed tracing

set -e

echo "🔍 Deploying AWS X-Ray daemon..."

# Create X-Ray daemon manifest
cat > /tmp/xray-daemon.yaml << EOF
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
    metadata:
      labels:
        app: xray-daemon
    spec:
      serviceAccountName: xray-daemon
      containers:
      - name: xray-daemon
        image: amazon/aws-xray-daemon:latest
        command: ["/usr/bin/xray", "-o", "-b", "0.0.0.0:2000"]
        resources:
          limits:
            memory: 256Mi
          requests:
            cpu: 256m
            memory: 32Mi
        ports:
        - name: xray-ingest
          containerPort: 2000
          protocol: UDP
        - name: xray-tcp
          containerPort: 2000
          protocol: TCP
---
apiVersion: v1
kind: ServiceAccount
metadata:
  name: xray-daemon
  namespace: ecommerce
  annotations:
    eks.amazonaws.com/role-arn: arn:aws:iam::$(aws sts get-caller-identity --query Account --output text):role/EKS-XRay-Role
---
apiVersion: v1
kind: Service
metadata:
  name: xray-daemon
  namespace: ecommerce
spec:
  selector:
    app: xray-daemon
  ports:
  - name: xray-ingest
    port: 2000
    protocol: UDP
  - name: xray-tcp
    port: 2000
    protocol: TCP
EOF

# Apply X-Ray daemon
kubectl apply -f /tmp/xray-daemon.yaml

# Wait for deployment
echo "⏳ Waiting for X-Ray daemon to be ready..."
kubectl wait --for=condition=ready pod -l app=xray-daemon -n ecommerce --timeout=300s

echo "✅ X-Ray daemon deployed successfully"