import jwt from 'jsonwebtoken';
import { config } from '../config/env.js';

export interface JwtPayload {
    userId: string;
    email: string;
    role?: string;
}

export function generateToken(payload: JwtPayload): string {
    return jwt.sign(payload, config.jwt.secret, {
        expiresIn: config.jwt.expiresIn,
    });
}

export function verifyToken(token: string): JwtPayload {
    return jwt.verify(token, config.jwt.secret) as JwtPayload;
}
