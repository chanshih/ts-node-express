import { Router } from "express";
import {
  getSysInfo,
  getEnvVar,
  proxyRequest,
  fibonacci,
  getServiceData,
  healthCheck,
  createServiceData,
} from "../controllers/controller";

const router = Router();

router.get("/env-var", getEnvVar);
router.get("/fib", fibonacci);
router.get("/req", proxyRequest);
router.get("/health", healthCheck);
// Microservice API routes
router.get("/api/users", getServiceData);
router.get("/api/products", getServiceData);
router.get("/api/products/:productId", getServiceData);
router.get("/api/orders", getServiceData);
router.get("/api/payments", getServiceData);
router.get("/api/notifications", getServiceData);

router.post("/api/users", createServiceData);
router.post("/api/products", createServiceData);
router.post("/api/orders", createServiceData);
router.post("/api/payments", createServiceData);
router.post("/api/notifications", createServiceData);

// Proxy route
router.get("/proxy", proxyRequest);
router.get("/", getSysInfo);

export default router;
