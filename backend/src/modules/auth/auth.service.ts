import bcrypt from 'bcryptjs';
import { PrismaClient } from '@prisma/client';
import { generateToken } from '../../utils/jwt.js';

const prisma = new PrismaClient();

export interface RegisterInput {
    email: string;
    phone: string;
    password: string;
    firstName: string;
    lastName: string;
    role?: string;
    specialty?: string;
    location?: string;
    consultationPrice?: number;
}

export interface LoginInput {
    email: string;
    password: string;
}

export const authService = {
    async register(input: RegisterInput) {
        // Check if user already exists
        const existingUser = await prisma.user.findFirst({
            where: {
                OR: [{ email: input.email }, { phone: input.phone }],
            },
        });

        if (existingUser) {
            throw { statusCode: 400, message: 'Email ou téléphone déjà utilisé' };
        }

        // Hash password
        const passwordHash = await bcrypt.hash(input.password, 10);

        // Use transaction to create User and Doctor if needed
        const result = await prisma.$transaction(async (tx) => {
            // Create user
            const user = await tx.user.create({
                data: {
                    email: input.email,
                    phone: input.phone,
                    passwordHash,
                    firstName: input.firstName,
                    lastName: input.lastName,
                    role: input.role as any || 'PATIENT', // Cast to any to avoid type error if client not generated
                    isVerified: false,
                },
                select: {
                    id: true,
                    email: true,
                    phone: true,
                    firstName: true,
                    lastName: true,
                    isVerified: true,
                    role: true,
                    createdAt: true,
                },
            });

            // If role is DOCTOR, create doctor profile
            if (input.role === 'DOCTOR') {
                await tx.doctor.create({
                    data: {
                        userId: user.id,
                        email: user.email,
                        firstName: user.firstName,
                        lastName: user.lastName,
                        specialty: input.specialty || 'Généraliste',
                        location: input.location || 'Cotonou',
                        consultationPrice: input.consultationPrice || 2000,
                        gender: 'MALE', // Default, should be in input
                        experienceYears: 0,
                    },
                });
            }

            return user;
        });

        // Generate OTP for phone verification
        const otpCode = Math.floor(100000 + Math.random() * 900000).toString();
        await prisma.otp.create({
            data: {
                phone: input.phone,
                code: otpCode,
                expiresAt: new Date(Date.now() + 10 * 60 * 1000), // 10 minutes
            },
        });

        // In production, send SMS here
        console.log(`📱 OTP for ${input.phone}: ${otpCode}`);

        return {
            user: result,
            message: 'Inscription réussie. Vérifiez votre téléphone pour le code OTP.',
        };
    },

    async login(input: LoginInput) {
        // Find user
        const user = await prisma.user.findUnique({
            where: { email: input.email },
        });

        if (!user) {
            throw { statusCode: 401, message: 'Email ou mot de passe incorrect' };
        }

        // Verify password
        const isValidPassword = await bcrypt.compare(input.password, user.passwordHash);

        if (!isValidPassword) {
            throw { statusCode: 401, message: 'Email ou mot de passe incorrect' };
        }

        // Generate OTP for MFA
        const otpCode = Math.floor(100000 + Math.random() * 900000).toString();
        await prisma.otp.create({
            data: {
                phone: user.phone,
                code: otpCode,
                expiresAt: new Date(Date.now() + 10 * 60 * 1000),
            },
        });

        console.log(`📱 OTP for ${user.phone}: ${otpCode}`);

        return {
            userId: user.id,
            phone: user.phone,
            message: 'Connecté. Vérifiez votre téléphone pour le code OTP.',
        };
    },

    async verifyOtp(phone: string, code: string) {
        // Find valid OTP
        const otp = await prisma.otp.findFirst({
            where: {
                phone,
                code,
                used: false,
                expiresAt: { gt: new Date() },
            },
            orderBy: { createdAt: 'desc' },
        });

        if (!otp) {
            throw { statusCode: 400, message: 'Code OTP invalide ou expiré' };
        }

        // Mark OTP as used
        await prisma.otp.update({
            where: { id: otp.id },
            data: { used: true },
        });

        // Get user and mark as verified
        const user = await prisma.user.update({
            where: { phone },
            data: { isVerified: true },
            select: {
                id: true,
                email: true,
                phone: true,
                firstName: true,
                lastName: true,
                isVerified: true,
                role: true,
                profilePictureUrl: true,
                doctorProfile: true, // Return linked doctor profile
            },
        });

        // Generate JWT with role
        const token = generateToken({
            userId: user.id,
            email: user.email,
            role: user.role
        });

        return {
            token,
            user,
        };
    },

    async resendOtp(phone: string) {
        const user = await prisma.user.findUnique({ where: { phone } });

        if (!user) {
            throw { statusCode: 404, message: 'Utilisateur non trouvé' };
        }

        const otpCode = Math.floor(100000 + Math.random() * 900000).toString();
        await prisma.otp.create({
            data: {
                phone,
                code: otpCode,
                expiresAt: new Date(Date.now() + 10 * 60 * 1000),
            },
        });

        console.log(`📱 New OTP for ${phone}: ${otpCode}`);

        return { message: 'Nouveau code OTP envoyé' };
    },
};
