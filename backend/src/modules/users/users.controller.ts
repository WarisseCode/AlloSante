import { Request, Response, NextFunction } from 'express';
import { usersService } from './users.service.js';

export const usersController = {
    async getMe(req: Request, res: Response, next: NextFunction) {
        try {
            const user = await usersService.findById(req.user.userId);
            if (!user) {
                res.status(404).json({ message: 'Utilisateur non trouvé' });
                return;
            }
            res.json(user);
        } catch (error) {
            next(error);
        }
    },

    async updateMe(req: Request, res: Response, next: NextFunction) {
        try {
            const { firstName, lastName, email } = req.body;
            // Basic validation could be added here

            const user = await usersService.update(req.user.userId, {
                firstName,
                lastName,
                email,
            });

            res.json(user);
        } catch (error) {
            next(error);
        }
    },

    async uploadAvatar(req: Request, res: Response, next: NextFunction) {
        try {
            if (!req.file) {
                res.status(400).json({ message: 'Aucun fichier uploadé' });
                return;
            }

            const user = await usersService.updateAvatar(req.user.userId, req.file.filename);
            res.json(user);
        } catch (error) {
            next(error);
        }
    },
};
