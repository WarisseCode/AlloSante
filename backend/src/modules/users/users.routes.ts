import { Router } from 'express';
import { usersController } from './users.controller.js';
import { authMiddleware } from '../../middlewares/auth.middleware.js';

const router = Router();

// Toutes les routes utilisateurs nécessitent une authentification
console.log('Imported authMiddleware:', authMiddleware);
router.use(authMiddleware);

router.get('/me', usersController.getMe);
router.patch('/me', usersController.updateMe);
router.post(
    '/avatar',
    (req, res, next) => {
        // Dynamic import workaround if circular dep persists or just standard import
        import('../../middlewares/upload.middleware.js').then(({ upload }) => {
            upload.single('avatar')(req, res, next);
        }).catch(next);
    },
    usersController.uploadAvatar
);

export default router;
