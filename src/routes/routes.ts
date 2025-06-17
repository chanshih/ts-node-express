import { Router } from "express";
import {
  getSysInfo,
  getEnvVar,
  proxyRequest,
  fibonacci,
} from "../controllers/controller";

const router = Router();

const paths = [
  { path: "/env-var", handler: getEnvVar },
  { path: "/fib", handler: fibonacci },
  { path: "/req", handler: proxyRequest },
  { path: "/", handler: getSysInfo },
];

const path_prefixes = process.env.PATH_PREFIXES?.split(",") || [];

for (const path of paths) {
  router.get(path.path, path.handler);
  for (const prefix of path_prefixes) {
    router.get(prefix + path.path, path.handler);
  }
}

export default router;
