#!/bin/bash

# Get ALB URL
ALB_URL=$(kubectl get ingress ecommerce-ingress -n ecommerce -o jsonpath='{.status.loadBalancer.ingress[0].hostname}')

if [ -z "ecommerce-alb-96033374.us-east-1.elb.amazonaws.com" ]; then
    echo "❌ ALB URL not found. Check if ingress is deployed and ready."
    exit 1
fi

echo "🚀 Testing EKS Microservices"
echo "ALB URL: http://ecommerce-alb-96033374.us-east-1.elb.amazonaws.com"
echo "================================"

# Function to test endpoint with HTTP status validation
test_endpoint() {
    local method=$1
    local url=$2
    local data=$3
    local service_name=$4
    
    if [ "$method" = "GET" ]; then
        response=$(curl -s -w "\n%{http_code}" "$url")
    else
        response=$(curl -s -w "\n%{http_code}" -X "$method" "$url" -H "Content-Type: application/json" -d "$data")
    fi
    
    # Split response and status code
    body=$(echo "$response" | sed '$d')
    status_code=$(echo "$response" | tail -n 1)
    
    # Validate response based on status code and body
    if [ "$status_code" = "200" ] || [ "$status_code" = "201" ]; then
        if echo "$body" | grep -q "Cannot GET\|Cannot POST"; then
            echo " ❌ $service_name (route not implemented)"
        elif [ -z "$body" ]; then
            echo " ❌ $service_name (empty response)"
        elif echo "$body" | grep -q "error\|Error\|ERROR"; then
            echo " ❌ $service_name (error in response: $(echo "$body" | cut -c1-50)...)"
        elif [ "$method" = "POST" ] && ! echo "$body" | grep -q "{\|id\|success\|created"; then
            echo " ❌ $service_name (invalid POST response: $(echo "$body" | cut -c1-50)...)"
        else
            echo " ✅ $service_name (HTTP $status_code)"
        fi
    elif [ "$status_code" = "400" ]; then
        echo " ❌ $service_name (400 Bad Request: $(echo "$body" | cut -c1-50)...)"
    elif [ "$status_code" = "404" ]; then
        echo " ❌ $service_name (404 Not Found)"
    elif [ "$status_code" = "422" ]; then
        echo " ❌ $service_name (422 Validation Error: $(echo "$body" | cut -c1-50)...)"
    elif [ "$status_code" = "500" ]; then
        echo " ❌ $service_name (500 Internal Server Error)"
    elif [ "$status_code" = "502" ]; then
        echo " ❌ $service_name (502 Bad Gateway)"
    elif [ "$status_code" = "503" ]; then
        echo " ❌ $service_name (503 Service Unavailable)"
    elif [ "$status_code" = "000" ] || [ -z "$status_code" ]; then
        echo " ❌ $service_name (connection failed)"
    else
        echo " ❌ $service_name (HTTP $status_code: $(echo "$body" | cut -c1-50)...)"
    fi
}

# Test GET endpoints
echo "1. Testing GET Endpoints:"
test_endpoint "GET" "http://ecommerce-alb-96033374.us-east-1.elb.amazonaws.com/" "" "Root"
test_endpoint "GET" "http://ecommerce-alb-96033374.us-east-1.elb.amazonaws.com/health" "" "Health Check"
test_endpoint "GET" "http://ecommerce-alb-96033374.us-east-1.elb.amazonaws.com/api/users" "" "GET Users"
test_endpoint "GET" "http://ecommerce-alb-96033374.us-east-1.elb.amazonaws.com/api/products" "" "GET Products"
test_endpoint "GET" "http://ecommerce-alb-96033374.us-east-1.elb.amazonaws.com/api/orders" "" "GET Orders"
test_endpoint "GET" "http://ecommerce-alb-96033374.us-east-1.elb.amazonaws.com/api/payments" "" "GET Payments"
test_endpoint "GET" "http://ecommerce-alb-96033374.us-east-1.elb.amazonaws.com/api/notifications" "" "GET Notifications"

# Test POST endpoints
echo -e "\n2. Testing POST Endpoints:"
test_endpoint "POST" "http://ecommerce-alb-96033374.us-east-1.elb.amazonaws.com/api/users" '{"name": "John Doe", "email": "john@example.com"}' "POST Create User"
test_endpoint "POST" "http://ecommerce-alb-96033374.us-east-1.elb.amazonaws.com/api/products" '{"name": "Laptop", "price": 999, "stock": 10}' "POST Create Product"
test_endpoint "POST" "http://ecommerce-alb-96033374.us-east-1.elb.amazonaws.com/api/orders" '{"productId": "123", "quantity": 2}' "POST Create Order"
test_endpoint "POST" "http://ecommerce-alb-96033374.us-east-1.elb.amazonaws.com/api/payments" '{"orderId": "123", "amount": 999}' "POST Process Payment"
test_endpoint "POST" "http://ecommerce-alb-96033374.us-east-1.elb.amazonaws.com/api/notifications" '{"message": "Test notification"}' "POST Send Notification"

# Test 503 Service Unavailable scenarios
echo -e "\n4. Testing 503 Service Unavailable:"
test_endpoint "POST" "http://ecommerce-alb-96033374.us-east-1.elb.amazonaws.com/api/orders" '{"productId": "999", "quantity": 1}' "Order with unavailable product service"
test_endpoint "GET" "http://ecommerce-alb-96033374.us-east-1.elb.amazonaws.com/proxy?host=nonexistent&port=9999" "" "Proxy to unavailable service"

echo -e "\n✅ EKS testing completed!"