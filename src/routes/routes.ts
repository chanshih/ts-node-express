import { Router } from "express";
import {
  getSysInfo,
  getEnvVar,
  redirect,
  fibonacci,
} from "../controllers/controller";

const router = Router();

router.get("/", getSysInfo);
router.get("/env-var", getEnvVar);
router.get("/fib", fibonacci);
router.get("/redirect", redirect);

export default router;
