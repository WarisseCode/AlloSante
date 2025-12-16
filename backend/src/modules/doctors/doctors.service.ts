import { PrismaClient } from '@prisma/client';

const prisma = new PrismaClient();

export interface DoctorFilters {
    specialty?: string;
    location?: string;
    languages?: string[];
    gender?: string;
    isAvailable?: boolean;
    minRating?: number;
    maxPrice?: number;
}

export const doctorService = {
    async findAll(filters: DoctorFilters = {}) {
        const where: any = {};

        if (filters.specialty) {
            where.specialty = { contains: filters.specialty, mode: 'insensitive' };
        }

        if (filters.location) {
            where.location = { contains: filters.location, mode: 'insensitive' };
        }

        if (filters.languages && filters.languages.length > 0) {
            where.languages = { hasSome: filters.languages };
        }

        if (filters.gender) {
            where.gender = filters.gender.toUpperCase(); // 'MALE' or 'FEMALE'
        }

        if (filters.isAvailable !== undefined) {
            where.isAvailable = filters.isAvailable;
        }

        if (filters.minRating) {
            where.rating = { gte: filters.minRating };
        }

        if (filters.maxPrice) {
            where.consultationPrice = { lte: filters.maxPrice };
        }

        return prisma.doctor.findMany({
            where,
            orderBy: [{ rating: 'desc' }, { reviewCount: 'desc' }],
        });
    },

    async findById(id: string) {
        const doctor = await prisma.doctor.findUnique({ where: { id } });

        if (!doctor) {
            throw { statusCode: 404, message: 'Médecin non trouvé' };
        }

        return doctor;
    },

    async getSpecialties() {
        const result = await prisma.doctor.findMany({
            select: { specialty: true },
            distinct: ['specialty'],
        });

        return result.map((d) => d.specialty);
    },

    async getLocations() {
        const result = await prisma.doctor.findMany({
            select: { location: true },
            distinct: ['location'],
        });

        return result.map((d) => d.location);
    },

    async getDashboardStats(userId: string) {
        // Find doctor first
        const doctor = await prisma.doctor.findFirst({
             where: { userId },
        });

        if (!doctor) throw { statusCode: 404, message: 'Profil médecin introuvable' };

        const now = new Date();
        const startOfDay = new Date(now.setHours(0, 0, 0, 0));
        const endOfDay = new Date(now.setHours(23, 59, 59, 999));
        
        const startOfMonth = new Date(now.getFullYear(), now.getMonth(), 1);
        const endOfMonth = new Date(now.getFullYear(), now.getMonth() + 1, 0);

        // Appointments Today
        const appointmentsToday = await prisma.appointment.count({
            where: {
                doctorId: doctor.id,
                date: {
                    gte: startOfDay,
                    lte: endOfDay,
                },
                status: { not: 'CANCELLED' }
            }
        });

        // Revenue this month (Sum of price of COMPLETED appointments)
        const revenueResult = await prisma.appointment.aggregate({
            where: {
                doctorId: doctor.id,
                date: {
                    gte: startOfMonth,
                    lte: endOfMonth,
                },
                status: 'COMPLETED'
            },
            _sum: {
                price: true
            }
        });

        return {
            appointmentsToday,
            revenueMonth: revenueResult._sum.price || 0,
            rating: doctor.rating,
            reviewCount: doctor.reviewCount
        };
    },
};
