import { Request, Response, NextFunction } from 'express';
import { config } from '../config/env.js';

export interface ApiError extends Error {
    statusCode?: number;
}

export function errorMiddleware(
    err: ApiError,
    req: Request,
    res: Response,
    next: NextFunction
): void {
    const statusCode = err.statusCode || 500;
    const message = err.message || 'Erreur interne du serveur';

    console.error(`[ERROR] ${req.method} ${req.path}:`, err);

    res.status(statusCode).json({
        error: message,
        ...(config.isDev && { stack: err.stack }),
    });
}

export function notFoundMiddleware(
    req: Request,
    res: Response,
    next: NextFunction
): void {
    res.status(404).json({
        error: `Route ${req.method} ${req.path} non trouvée`,
    });
}
