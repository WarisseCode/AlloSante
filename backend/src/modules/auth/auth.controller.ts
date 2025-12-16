import { Request, Response, NextFunction } from 'express';
import { z } from 'zod';
import { authService } from './auth.service.js';

// Validation schemas
const registerSchema = z.object({
    email: z.string().email('Email invalide'),
    phone: z.string().min(8, 'Téléphone invalide'),
    password: z.string().min(6, 'Mot de passe trop court (min 6 caractères)'),
    firstName: z.string().min(2, 'Prénom trop court'),
    lastName: z.string().min(2, 'Nom trop court'),
    role: z.string().optional(),
    specialty: z.string().optional(),
    location: z.string().optional(),
    consultationPrice: z.number().optional(),
});

const loginSchema = z.object({
    email: z.string().email('Email invalide'),
    password: z.string().min(1, 'Mot de passe requis'),
});

const verifyOtpSchema = z.object({
    phone: z.string().min(8, 'Téléphone invalide'),
    code: z.string().length(6, 'Code OTP invalide'),
});

export const authController = {
    async register(req: Request, res: Response, next: NextFunction) {
        try {
            const data = registerSchema.parse(req.body);
            const result = await authService.register(data);
            res.status(201).json(result);
        } catch (error: any) {
            if (error instanceof z.ZodError) {
                res.status(400).json({ error: error.errors[0].message });
                return;
            }
            next(error);
        }
    },

    async login(req: Request, res: Response, next: NextFunction) {
        try {
            const data = loginSchema.parse(req.body);
            const result = await authService.login(data);
            res.json(result);
        } catch (error: any) {
            if (error instanceof z.ZodError) {
                res.status(400).json({ error: error.errors[0].message });
                return;
            }
            next(error);
        }
    },

    async verifyOtp(req: Request, res: Response, next: NextFunction) {
        try {
            const data = verifyOtpSchema.parse(req.body);
            const result = await authService.verifyOtp(data.phone, data.code);
            res.json(result);
        } catch (error: any) {
            if (error instanceof z.ZodError) {
                res.status(400).json({ error: error.errors[0].message });
                return;
            }
            next(error);
        }
    },

    async resendOtp(req: Request, res: Response, next: NextFunction) {
        try {
            const { phone } = req.body;
            if (!phone) {
                res.status(400).json({ error: 'Téléphone requis' });
                return;
            }
            const result = await authService.resendOtp(phone);
            res.json(result);
        } catch (error) {
            next(error);
        }
    },
};
