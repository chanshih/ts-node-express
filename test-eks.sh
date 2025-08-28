#!/bin/bash

# Get ALB URL
ALB_URL=$(kubectl get ingress ecommerce-ingress -n ecommerce -o jsonpath='{.status.loadBalancer.ingress[0].hostname}')

if [ -z "ecommerce-alb-1368094492.us-east-1.elb.amazonaws.com" ]; then
    echo "❌ ALB URL not found. Check if ingress is deployed and ready."
    exit 1
fi

echo "🚀 Testing EKS Microservices"
echo "ALB URL: http://ecommerce-alb-1368094492.us-east-1.elb.amazonaws.com"
echo "================================"

# Test basic endpoints first
echo "1. Testing Basic Endpoints:"
curl -s "http://ecommerce-alb-1368094492.us-east-1.elb.amazonaws.com/" && echo " ✅ Root"
curl -s "http://ecommerce-alb-1368094492.us-east-1.elb.amazonaws.com/health" && echo " ✅ Health"

# Test service endpoints (may not exist yet)
echo -e "\n2. Testing Service Endpoints:"
curl -s "http://ecommerce-alb-1368094492.us-east-1.elb.amazonaws.com/api/users" | grep -q "Cannot GET" && echo " ❌ User Service (route not implemented)" || echo " ✅ User Service"
curl -s "http://ecommerce-alb-1368094492.us-east-1.elb.amazonaws.com/api/products" | grep -q "Cannot GET" && echo " ❌ Product Service (route not implemented)" || echo " ✅ Product Service"
curl -s "http://ecommerce-alb-1368094492.us-east-1.elb.amazonaws.com/api/orders" | grep -q "Cannot GET" && echo " ❌ Order Service (route not implemented)" || echo " ✅ Order Service"
curl -s "http://ecommerce-alb-1368094492.us-east-1.elb.amazonaws.com/api/payments" | grep -q "Cannot GET" && echo " ❌ Payment Service (route not implemented)" || echo " ✅ Payment Service"
curl -s "http://ecommerce-alb-1368094492.us-east-1.elb.amazonaws.com/api/notifications" | grep -q "Cannot GET" && echo " ❌ Notification Service (route not implemented)" || echo " ✅ Notification Service"

# Test POST requests
echo -e "\n2. Testing POST Requests:"
curl -X POST "http://ecommerce-alb-1368094492.us-east-1.elb.amazonaws.com/api/users" \
  -H "Content-Type: application/json" \
  -d '{"name": "John Doe", "email": "john@example.com"}' && echo " ✅ Create User"

curl -X POST "http://ecommerce-alb-1368094492.us-east-1.elb.amazonaws.com/api/products" \
  -H "Content-Type: application/json" \
  -d '{"name": "Laptop", "price": 999, "stock": 10}' && echo " ✅ Create Product"

# Test Order → Product sync call
echo -e "\n3. Testing Cross-Service Communication:"
curl -X POST "http://ecommerce-alb-1368094492.us-east-1.elb.amazonaws.com/api/orders" \
  -H "Content-Type: application/json" \
  -d '{"productId": "123", "quantity": 2}' && echo " ✅ Order → Product sync"

echo -e "\n✅ EKS testing completed!"