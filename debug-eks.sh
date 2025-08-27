#!/bin/bash

ALB_URL="ecommerce-alb-1365943228.us-east-1.elb.amazonaws.com"

echo "🔍 Debugging EKS Services"
echo "ALB URL: http://$ALB_URL"
echo "================================"

# Check cluster connection first
echo "1. Checking Kubernetes Cluster:"
kubectl cluster-info --request-timeout=10s 2>/dev/null && echo " ✅ Cluster Connected" || echo " ❌ Cluster Connection Failed"

# Check namespace and pods
echo -e "\n2. Checking Deployments:"
kubectl get namespace ecommerce 2>/dev/null && echo " ✅ Namespace exists" || echo " ❌ Namespace missing"
kubectl get pods -n ecommerce 2>/dev/null || echo " ❌ No pods found"

# Test ALB endpoints
echo -e "\n3. Testing ALB Endpoints:"
curl -s -o /dev/null -w "Root: %{http_code}\n" "http://$ALB_URL/"
curl -s -o /dev/null -w "Health: %{http_code}\n" "http://$ALB_URL/health"
curl -s -o /dev/null -w "API Users: %{http_code}\n" "http://$ALB_URL/api/users"
curl -s -o /dev/null -w "API Products: %{http_code}\n" "http://$ALB_URL/api/products"

# Check ingress configuration
echo -e "\n4. Checking Ingress:"
kubectl get ingress -n ecommerce 2>/dev/null || echo " ❌ No ingress found"

# Check services
echo -e "\n5. Checking Services:"
kubectl get svc -n ecommerce 2>/dev/null || echo " ❌ No services found"