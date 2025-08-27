#!/bin/bash
# Kill any existing processes on these ports
lsof -ti:3001,3002,3003,3004,3005 | xargs kill -9 2>/dev/null

# Start all services in background
PORT=3001 SERVICE_NAME=user-service npm run dev &
PORT=3002 SERVICE_NAME=product-service npm run dev &
PORT=3003 SERVICE_NAME=order-service PRODUCT_SERVICE_URL=http://localhost:3002 npm run dev &
PORT=3004 SERVICE_NAME=payment-service npm run dev &
PORT=3005 SERVICE_NAME=notification-service npm run dev &

echo "All services started. Press Ctrl+C to stop all."
wait