import { Router } from 'express';
import { getSysInfo, getEnvVar, redirect } from '../controllers/controller';

const router = Router();

router.get('/', getSysInfo);
router.get('/env-var', getEnvVar);
router.get('/redirect', redirect);

export default router;