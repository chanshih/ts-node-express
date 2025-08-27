import { Router } from "express";
import {
  getSysInfo,
  getEnvVar,
  proxyRequest,
  fibonacci,
  getServiceData,
  healthCheck,
} from "../controllers/controller";

const router = Router();

router.get("/env-var", getEnvVar);
router.get("/fib", fibonacci);
router.get("/req", proxyRequest);
router.get("/health", healthCheck);
router.get("/api/:service", getServiceData);
router.get("/", getSysInfo);

export default router;
