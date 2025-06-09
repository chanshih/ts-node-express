import { Router } from "express";
import {
  getSysInfo,
  getEnvVar,
  proxy_request,
  fibonacci,
} from "../controllers/controller";

const router = Router();

router.get("/env-var", getEnvVar);
router.get("/fib", fibonacci);
router.get("/req", proxy_request);
router.get("/", getSysInfo);

export default router;
