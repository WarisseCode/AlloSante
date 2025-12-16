import { Router } from 'express';
import { medicalRecordController } from './medical-records.controller.js';
import { authMiddleware } from '../../middlewares/auth.middleware.js';

const router = Router();

router.use(authMiddleware);

router.get('/', medicalRecordController.get);
router.patch('/', medicalRecordController.update);

export default router;
