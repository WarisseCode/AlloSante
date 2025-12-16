import { Request, Response, NextFunction } from 'express';
import { doctorService } from './doctors.service.js';

export const doctorController = {
    async getAll(req: Request, res: Response, next: NextFunction) {
        try {
            const { specialty, location, isAvailable, minRating, maxPrice } = req.query;

            const filters = {
                specialty: specialty as string | undefined,
                location: location as string | undefined,
                languages: req.query.languages ? (req.query.languages as string).split(',') : undefined,
                gender: req.query.gender as string | undefined,
                isAvailable: isAvailable === 'true' ? true : isAvailable === 'false' ? false : undefined,
                minRating: minRating ? parseFloat(minRating as string) : undefined,
                maxPrice: maxPrice ? parseInt(maxPrice as string, 10) : undefined,
            };

            const doctors = await doctorService.findAll(filters);
            res.json({ doctors });
        } catch (error) {
            next(error);
        }
    },

    async getById(req: Request, res: Response, next: NextFunction) {
        try {
            const { id } = req.params;
            const doctor = await doctorService.findById(id);
            res.json({ doctor });
        } catch (error) {
            next(error);
        }
    },

    async getSpecialties(req: Request, res: Response, next: NextFunction) {
        try {
            const specialties = await doctorService.getSpecialties();
            res.json({ specialties });
        } catch (error) {
            next(error);
        }
    },

    async getLocations(req: Request, res: Response, next: NextFunction) {
        try {
            const locations = await doctorService.getLocations();
            res.json({ locations });
        } catch (error) {
            next(error);
        }
    },

    async getStats(req: Request, res: Response, next: NextFunction) {
        try {
            if (!req.user) {
                res.status(401).json({ error: 'Non authentifié' });
                return;
            }
            const stats = await doctorService.getDashboardStats(req.user.userId);
            res.json(stats);
        } catch (error) {
            next(error);
        }
    },
};
