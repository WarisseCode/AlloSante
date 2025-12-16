import { Request, Response, NextFunction } from 'express';
import { medicalRecordService } from './medical-records.service.js';

export const medicalRecordController = {
    async get(req: Request, res: Response, next: NextFunction) {
        try {
            if (!req.user) {
                res.status(401).json({ error: 'Non authentifié' });
                return;
            }

            const record = await medicalRecordService.findByUserId(req.user.userId);
            res.json({ medicalRecord: record });
        } catch (error) {
            next(error);
        }
    },

    async update(req: Request, res: Response, next: NextFunction) {
        try {
            if (!req.user) {
                res.status(401).json({ error: 'Non authentifié' });
                return;
            }

            const { bloodType, allergies, conditions, medications, notes } = req.body;

            const record = await medicalRecordService.update(req.user.userId, {
                bloodType,
                allergies,
                conditions,
                medications,
                notes,
            });

            res.json({ medicalRecord: record, message: 'Dossier médical mis à jour' });
        } catch (error) {
            next(error);
        }
    },
};
