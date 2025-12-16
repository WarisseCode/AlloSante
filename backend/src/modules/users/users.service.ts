import { PrismaClient } from '@prisma/client';

const prisma = new PrismaClient();

export const usersService = {
    async findById(id: string) {
        return prisma.user.findUnique({
            where: { id },
            select: {
                id: true,
                email: true,
                phone: true,
                firstName: true,
                lastName: true,
                isVerified: true,
                createdAt: true,
            },
        });
    },

    async update(id: string, data: { firstName?: string; lastName?: string; email?: string }) {
        return prisma.user.update({
            where: { id },
            data,
            select: {
                id: true,
                email: true,
                phone: true,
                firstName: true,
                lastName: true,
                isVerified: true,
                createdAt: true,
            },
        });
    },

    async updateAvatar(id: string, filename: string) {
        // Construct full URL or relative path based on your pref.
        // For simplicity: /uploads/filename
        const profilePictureUrl = `/uploads/${filename}`;

        return prisma.user.update({
            where: { id },
            data: { profilePictureUrl },
            select: {
                id: true,
                email: true,
                phone: true,
                firstName: true,
                lastName: true,
                profilePictureUrl: true,
                isVerified: true,
                createdAt: true,
            },
        });
    },
};
