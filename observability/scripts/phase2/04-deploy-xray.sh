#!/bin/bash
# Deploy AWS X-Ray daemon to EKS

set -e

CLUSTER_NAME=${CLUSTER_NAME:-"ecommerce-cluster"}
REGION=${AWS_REGION:-"us-east-1"}

echo "🔍 Deploying AWS X-Ray daemon..."

# Create X-Ray daemon DaemonSet
kubectl apply -f - <<EOF
apiVersion: v1
kind: ServiceAccount
metadata:
  name: xray-daemon
  namespace: kube-system
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: xray-daemon
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: cluster-admin
subjects:
- kind: ServiceAccount
  name: xray-daemon
  namespace: kube-system
---
apiVersion: apps/v1
kind: DaemonSet
metadata:
  name: xray-daemon
  namespace: kube-system
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
            cpu: 250m
          requests:
            memory: 32Mi
            cpu: 10m
        ports:
        - containerPort: 2000
          protocol: UDP
        - containerPort: 2000
          protocol: TCP
---
apiVersion: v1
kind: Service
metadata:
  name: xray-daemon
  namespace: kube-system
spec:
  selector:
    app: xray-daemon
  ports:
  - port: 2000
    protocol: UDP
    targetPort: 2000
  - port: 2000
    protocol: TCP
    targetPort: 2000
EOF

# Wait for X-Ray daemon to be ready
echo "⏳ Waiting for X-Ray daemon to be ready..."
kubectl wait --for=condition=ready pod -l app=xray-daemon -n kube-system --timeout=300s

echo "✅ X-Ray daemon deployed successfully"