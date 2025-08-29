# Ecommerce Microservices

A microservices-based ecommerce platform built with TypeScript, Node.js, and Express framework, designed for deployment on AWS EKS.

## Prerequisites

- Node.js (v16 or higher)
- npm or yarn package manager

## Local Development

### 1. Install Dependencies

```bash
npm install
```

### 2. Run in Development Mode

```bash
npm run dev
```

This starts the server with hot reload using nodemon and ts-node. The server will run on [http://localhost:8000](http://localhost:8000)

### 3. Build and Run Production

```bash
# Build TypeScript to JavaScript
npm run build

# Start production server
npm start
```

## Available Scripts

- `npm run dev` - Start development server with hot reload
- `npm run build` - Compile TypeScript to JavaScript
- `npm start` - Run production server
- `npm run lint` - Run ESLint
- `npm run lint-fix` - Fix ESLint issues automatically
- `npm run prettier` - Format code with Prettier

## Environment Variables

- `PORT` - Server port (default: 8000)
- `NODE_ENV` - Environment mode (default: development)
- `PRODUCT_SERVICE_LATENCY` - Artificial latency for product service in milliseconds (default: 0)

## Microservices Architecture

### Services Overview

1. **User Service** (Port 3001) - Authentication and user management
2. **Product Service** (Port 3002) - Product catalog and inventory
3. **Order Service** (Port 3003) - Order processing (calls Product Service sync)
4. **Payment Service** (Port 3004) - Payment processing
5. **Notification Service** (Port 3005) - Email/SMS notifications

### Service Communication
- Order Service → Product Service (synchronous inventory check)
- All services communicate via REST APIs
- Service discovery using environment variables

## Local Testing (Native Node.js)

### 1. Quick Start - Single Terminal

Run all services at once:

```bash
./start-all.sh
```

### 2. Debug Individual Services

For debugging specific services:

```bash
# Stop all services first
lsof -ti:3001,3002,3003,3004,3005 | xargs kill -9

# Start only the services you need
PORT=3002 SERVICE_NAME=product-service npm run dev &  # Dependency
PORT=3003 SERVICE_NAME=order-service PRODUCT_SERVICE_URL=http://localhost:3002 npm run dev  # Debug target
```

### 3. Simulate Network Latency

Add artificial latency to product service for testing:

```bash
# Add 2 second latency to product service
PORT=3002 SERVICE_NAME=product-service PRODUCT_SERVICE_LATENCY=6000 npm run dev &

# Test order service with slow product dependency
PORT=3003 SERVICE_NAME=order-service PRODUCT_SERVICE_URL=http://localhost:3002 npm run dev
```

### 4. Test All Services

Run comprehensive service tests:

```bash
./test-services.sh
```

### 5. Development Workflow

**Daily cycle:**
1. Start: `./start-all.sh`
2. Test: `./test-services.sh`
3. Stop: `lsof -ti:3001,3002,3003,3004,3005 | xargs kill -9`

## EKS Testing

### Deploy to EKS

```bash
# Deploy all microservices
kubectl apply -f web-app.yaml

# Check deployment status
kubectl get pods -n ecommerce
kubectl get ingress -n ecommerce
```

### Test EKS Deployment

```bash
# Test all services via ALB
./test-eks.sh

# Manual testing
ALB_URL=$(kubectl get ingress ecommerce-ingress -n ecommerce -o jsonpath='{.status.loadBalancer.ingress[0].hostname}')
curl http://$ALB_URL/api/users
```

### Add Latency to Product Service in EKS

```bash
# Add 6 second latency to product service
kubectl set env deployment/product-service PRODUCT_SERVICE_LATENCY=6000 -n ecommerce

# Remove latency (set to 0)
kubectl set env deployment/product-service PRODUCT_SERVICE_LATENCY=0 -n ecommerce

# Check current environment variables
kubectl describe deployment/product-service -n ecommerce | grep -A 10 Environment
```

### Debug EKS Issues

```bash
# Check pod logs
kubectl logs -f deployment/user-service -n ecommerce

# Check service connectivity
kubectl exec -it deployment/order-service -n ecommerce -- curl http://product-service:3002/api/products

# Port forward for direct testing
kubectl port-forward service/user-service 3001:3001 -n ecommerce
```

