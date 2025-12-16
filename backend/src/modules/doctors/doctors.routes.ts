import { Router } from 'express';
import { doctorController } from './doctors.controller.js';

import { authMiddleware } from '../../middlewares/auth.middleware.js';

const router = Router();

router.get('/', doctorController.getAll);
router.get('/stats', authMiddleware, doctorController.getStats);
router.get('/specialties', doctorController.getSpecialties);
router.get('/specialties', doctorController.getSpecialties);
router.get('/locations', doctorController.getLocations);
router.get('/:id', doctorController.getById);

export default router;
