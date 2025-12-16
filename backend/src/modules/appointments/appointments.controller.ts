import { Request, Response, NextFunction } from 'express';
import { z } from 'zod';
import { appointmentService } from './appointments.service.js';

const createSchema = z.object({
    doctorId: z.string().uuid('ID médecin invalide'),
    date: z.string().transform((s) => new Date(s)),
    timeSlot: z.string().min(1, 'Créneau horaire requis'),
    type: z.enum(['CONSULTATION', 'FOLLOW_UP', 'EMERGENCY', 'TELECONSULTATION']).optional(),
    notes: z.string().optional(),
});

export const appointmentController = {
    async create(req: Request, res: Response, next: NextFunction) {
        try {
            if (!req.user) {
                res.status(401).json({ error: 'Non authentifié' });
                return;
            }

            const data = createSchema.parse(req.body);
            const appointment = await appointmentService.create({
                userId: req.user.userId,
                ...data,
            });

            res.status(201).json({ appointment });
        } catch (error: any) {
            if (error instanceof z.ZodError) {
                res.status(400).json({ error: error.errors[0].message });
                return;
            }
            next(error);
        }
    },

    async getAll(req: Request, res: Response, next: NextFunction) {
        try {
            if (!req.user) {
                res.status(401).json({ error: 'Non authentifié' });
                return;
            }

            let appointments;
            // Check role from request (set by auth middleware)
            // Assuming authMiddleware populates req.user with role or we can check via DB
            // Ideally req.user should have role.
            // Let's assume req.user has { userId, role }
            
            // For now, if we don't have role in token, we might need to fetch it or rely on different endpoints.
            // But we added role to JWT in Step 2232!
            // So TS definition of req.user might be missing role.
            
            const userRole = (req.user as any).role; // Temporary cast

            if (userRole === 'DOCTOR') {
                 appointments = await appointmentService.findByDoctorId(req.user.userId);
            } else {
                 appointments = await appointmentService.findByUserId(req.user.userId);
            }

            res.json({ appointments });
        } catch (error) {
            next(error);
        }
    },

    async updateStatus(req: Request, res: Response, next: NextFunction) {
        try {
            if (!req.user) {
                res.status(401).json({ error: 'Non authentifié' });
                return;
            }

            const { id } = req.params;
            const { status } = req.body; // Expect { status: 'CONFIRMED' | 'CANCELLED' | 'COMPLETED' }

            if (!status) {
                res.status(400).json({ error: 'Statut requis' });
                return;
            }

            const appointment = await appointmentService.updateStatus(id, req.user.userId, status);
            res.json({ appointment });
        } catch (error) {
            next(error);
        }
    },

    async getById(req: Request, res: Response, next: NextFunction) {
        try {
            if (!req.user) {
                res.status(401).json({ error: 'Non authentifié' });
                return;
            }

            const { id } = req.params;
            const appointment = await appointmentService.findById(id, req.user.userId);
            res.json({ appointment });
        } catch (error) {
            next(error);
        }
    },

    async cancel(req: Request, res: Response, next: NextFunction) {
        try {
            if (!req.user) {
                res.status(401).json({ error: 'Non authentifié' });
                return;
            }

            const { id } = req.params;
            const appointment = await appointmentService.cancel(id, req.user.userId);
            res.json({ appointment, message: 'Rendez-vous annulé' });
        } catch (error) {
            next(error);
        }
    },
};
