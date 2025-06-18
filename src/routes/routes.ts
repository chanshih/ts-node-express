import { Router } from "express";
import {
  getSysInfo,
  getEnvVar,
  proxyRequest,
  fibonacci,
} from "../controllers/controller";

const router = Router();

router.get("/env-var", getEnvVar);
router.get("/fib", fibonacci);
router.get("/req", proxyRequest);
router.get("/", getSysInfo);

export default router;
