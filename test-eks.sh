#!/bin/bash

# Get ALB URL
ALB_URL=$(kubectl get ingress ecommerce-ingress -n ecommerce -o jsonpath='{.status.loadBalancer.ingress[0].hostname}')

if [ -z "ecommerce-alb-26367432.us-east-1.elb.amazonaws.com" ]; then
    echo "❌ ALB URL not found. Check if ingress is deployed and ready."
    exit 1
fi

echo "🚀 Testing EKS Microservices"
echo "ALB URL: http://ecommerce-alb-26367432.us-east-1.elb.amazonaws.com"
echo "================================"

# Function to test endpoint with expected outcome validation
test_endpoint() {
    local method=$1
    local url=$2
    local data=$3
    local service_name=$4
    local expected=$5  # "success" or "error" or specific status code
    
    if [ "$method" = "GET" ]; then
        response=$(curl -s -w "\n%{http_code}" "$url")
    else
        response=$(curl -s -w "\n%{http_code}" -X "$method" "$url" -H "Content-Type: application/json" -d "$data")
    fi
    
    # Split response and status code
    body=$(echo "$response" | sed '$d')
    status_code=$(echo "$response" | tail -n 1)
    
    # Validate based on expected outcome
    if [ "$expected" = "success" ]; then
        if [ "$status_code" = "200" ] || [ "$status_code" = "201" ]; then
            if echo "$body" | grep -q "Cannot GET\|Cannot POST"; then
                echo " ❌ $service_name (route not implemented)"
            elif [ -z "$body" ]; then
                echo " ❌ $service_name (empty response)"
            elif echo "$body" | grep -q "error\|Error\|ERROR"; then
                echo " ❌ $service_name (error in response: $(echo "$body" | cut -c1-50)...)"
            else
                echo " ✅ $service_name (HTTP $status_code)"
            fi
        else
            echo " ❌ $service_name (expected success, got HTTP $status_code: $(echo "$body" | cut -c1-50)...)"
        fi
    elif [ "$expected" = "503" ]; then
        if [ "$status_code" = "503" ]; then
            echo " ✅ $service_name (correctly returned 503 Service Unavailable)"
        else
            echo " ❌ $service_name (expected 503, got HTTP $status_code: $(echo "$body" | cut -c1-50)...)"
        fi
    elif [ "$expected" = "422" ]; then
        if [ "$status_code" = "422" ]; then
            echo " ✅ $service_name (correctly returned 422 Validation Error)"
        else
            echo " ❌ $service_name (expected 422, got HTTP $status_code: $(echo "$body" | cut -c1-50)...)"
        fi
    elif [ "$expected" = "400" ]; then
        if [ "$status_code" = "400" ]; then
            echo " ✅ $service_name (correctly returned 400 Bad Request)"
        else
            echo " ❌ $service_name (expected 400, got HTTP $status_code: $(echo "$body" | cut -c1-50)...)"
        fi
    else
        # Default validation for any response
        if [ "$status_code" = "200" ] || [ "$status_code" = "201" ]; then
            echo " ✅ $service_name (HTTP $status_code)"
        else
            echo " ❌ $service_name (HTTP $status_code: $(echo "$body" | cut -c1-50)...)"
        fi
    fi
}

# Test GET endpoints (expect success)
echo "1. Testing GET Endpoints:"
test_endpoint "GET" "http://ecommerce-alb-26367432.us-east-1.elb.amazonaws.com/" "" "Root" "success"
test_endpoint "GET" "http://ecommerce-alb-26367432.us-east-1.elb.amazonaws.com/health" "" "Health Check" "success"
test_endpoint "GET" "http://ecommerce-alb-26367432.us-east-1.elb.amazonaws.com/api/users" "" "GET Users" "success"
test_endpoint "GET" "http://ecommerce-alb-26367432.us-east-1.elb.amazonaws.com/api/products" "" "GET Products" "success"
test_endpoint "GET" "http://ecommerce-alb-26367432.us-east-1.elb.amazonaws.com/api/orders" "" "GET Orders" "success"
test_endpoint "GET" "http://ecommerce-alb-26367432.us-east-1.elb.amazonaws.com/api/payments" "" "GET Payments" "success"
test_endpoint "GET" "http://ecommerce-alb-26367432.us-east-1.elb.amazonaws.com/api/notifications" "" "GET Notifications" "success"

# Test POST endpoints (expect success)
echo -e "\n2. Testing POST Endpoints:"
test_endpoint "POST" "http://ecommerce-alb-26367432.us-east-1.elb.amazonaws.com/api/users" '{"name": "John Doe", "email": "john@example.com"}' "POST Create User" "success"
test_endpoint "POST" "http://ecommerce-alb-26367432.us-east-1.elb.amazonaws.com/api/products" '{"name": "Laptop", "price": 999, "stock": 10}' "POST Create Product" "success"
test_endpoint "POST" "http://ecommerce-alb-26367432.us-east-1.elb.amazonaws.com/api/orders" '{"productId": "123", "quantity": 2}' "POST Create Order" "success"
test_endpoint "POST" "http://ecommerce-alb-26367432.us-east-1.elb.amazonaws.com/api/payments" '{"orderId": "123", "amount": 999}' "POST Process Payment" "success"
test_endpoint "POST" "http://ecommerce-alb-26367432.us-east-1.elb.amazonaws.com/api/notifications" '{"message": "Test notification"}' "POST Send Notification" "success"

# Test error scenarios (expect specific errors)
echo -e "\n3. Testing Error Scenarios:"
test_endpoint "POST" "http://ecommerce-alb-26367432.us-east-1.elb.amazonaws.com/api/users" '{"name": "John"}' "Missing email validation" "422"
test_endpoint "POST" "http://ecommerce-alb-26367432.us-east-1.elb.amazonaws.com/api/products" '{"name": "Laptop", "price": -10}' "Invalid price validation" "422"
test_endpoint "POST" "http://ecommerce-alb-26367432.us-east-1.elb.amazonaws.com/api/orders" '{"productId": "999", "quantity": 1}' "Order with unavailable product service" "503"
test_endpoint "GET" "http://ecommerce-alb-26367432.us-east-1.elb.amazonaws.com/proxy?host=nonexistent&port=9999" "" "Proxy to unavailable service" "503"

echo -e "\n✅ All tests completed!"