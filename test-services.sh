#!/bin/bash
echo "Testing all microservices..."

# Health checks
echo "1. Health Checks:"
curl -s http://localhost:3001/health && echo " ✅ User Service"
curl -s http://localhost:3002/health && echo " ✅ Product Service"
curl -s http://localhost:3003/health && echo " ✅ Order Service"
curl -s http://localhost:3004/health && echo " ✅ Payment Service"
curl -s http://localhost:3005/health && echo " ✅ Notification Service"

# Service endpoints
echo "\n2. Service Endpoints:"
curl -s http://localhost:3001/api/users && echo " ✅ Users API"
curl -s http://localhost:3002/api/products && echo " ✅ Products API"
curl -s http://localhost:3003/api/orders && echo " ✅ Orders API"
curl -s http://localhost:3004/api/payments && echo " ✅ Payments API"
curl -s http://localhost:3005/api/notifications && echo " ✅ Notifications API"

# Test POST requests
echo "\n3. POST Requests:"
curl -X POST http://localhost:3001/api/users \
  -H "Content-Type: application/json" \
  -d '{"name": "John Doe", "email": "john@example.com"}' && echo " ✅ Create User"

curl -X POST http://localhost:3002/api/products \
  -H "Content-Type: application/json" \
  -d '{"name": "Laptop", "price": 999, "stock": 10}' && echo " ✅ Create Product"

curl -X POST http://localhost:3004/api/payments \
  -H "Content-Type: application/json" \
  -d '{"orderId": "123", "amount": 999.99}' && echo " ✅ Create Payment"

curl -X POST http://localhost:3005/api/notifications \
  -H "Content-Type: application/json" \
  -d '{"message": "Test notification", "userId": "123"}' && echo " ✅ Send Notification"

# Test Order → Product sync call
echo "\n4. Cross-Service Communication:"
curl -X POST http://localhost:3003/api/orders \
  -H "Content-Type: application/json" \
  -d '{"productId": "123", "quantity": 2}' && echo " ✅ Order → Product sync"

echo "\n✅ All tests completed!"