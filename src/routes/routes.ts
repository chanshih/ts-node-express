import { Router } from 'express';
import {
    getSysInfo,
    getEnvVar
} from '../controllers/controller';

const router = Router();

router.get('/', getSysInfo);
router.get('/env-var', getEnvVar);

export default router;