import { Request, Response, NextFunction } from 'express';
import { verifyToken, JwtPayload } from '../utils/jwt.js';

// Extend Express Request type
declare global {
    namespace Express {
        interface Request {
            user?: JwtPayload;
        }
    }
}

export const authMiddleware = (
    req: Request,
    res: Response,
    next: NextFunction
): void => {
    try {
        const authHeader = req.headers.authorization;

        if (!authHeader || !authHeader.startsWith('Bearer ')) {
            res.status(401).json({ error: 'Token manquant' });
            return;
        }

        const token = authHeader.split(' ')[1];
        const payload = verifyToken(token);

        req.user = payload;
        next();
    } catch (error) {
        res.status(401).json({ error: 'Token invalide ou expiré' });
    }
};
