import { Router } from 'express';
import { appointmentController } from './appointments.controller.js';
import { authMiddleware } from '../../middlewares/auth.middleware.js';

const router = Router();

// All routes require authentication
router.use(authMiddleware);

router.post('/', appointmentController.create);
router.get('/', appointmentController.getAll);
router.get('/:id', appointmentController.getById);
router.patch('/:id/cancel', appointmentController.cancel);
router.patch('/:id/status', appointmentController.updateStatus);

export default router;
