import { PrismaClient, AppointmentStatus, AppointmentType } from '@prisma/client';

const prisma = new PrismaClient();

export interface CreateAppointmentInput {
    userId: string;
    doctorId: string;
    date: Date;
    timeSlot: string;
    type?: AppointmentType;
    notes?: string;
}

export const appointmentService = {
    async create(input: CreateAppointmentInput) {
        // Get doctor to fetch price
        const doctor = await prisma.doctor.findUnique({
            where: { id: input.doctorId },
        });

        if (!doctor) {
            throw { statusCode: 404, message: 'Médecin non trouvé' };
        }

        if (!doctor.isAvailable) {
            throw { statusCode: 400, message: 'Ce médecin n\'est pas disponible' };
        }

        // Check for conflicting appointment
        const existingAppointment = await prisma.appointment.findFirst({
            where: {
                doctorId: input.doctorId,
                date: input.date,
                timeSlot: input.timeSlot,
                status: { in: ['PENDING', 'CONFIRMED'] },
            },
        });

        if (existingAppointment) {
            throw { statusCode: 400, message: 'Ce créneau est déjà réservé' };
        }

        try {
            const appointment = await prisma.appointment.create({
                data: {
                    userId: input.userId,
                    doctorId: input.doctorId,
                    date: input.date,
                    timeSlot: input.timeSlot,
                    type: input.type || 'CONSULTATION',
                    notes: input.notes,
                    price: doctor.consultationPrice,
                    status: 'PENDING',
                },
                include: {
                    doctor: true,
                },
            });
            return appointment;
        } catch (error: any) {
            if (error.code === 'P2003') {
                // If doctorId was checked, it's likely userId
                throw { statusCode: 401, message: 'Session invalide. Veuillez vous reconnecter.' };
            }
            throw error;
        }

    },

    async findByUserId(userId: string) {
        return prisma.appointment.findMany({
            where: { userId },
            include: { doctor: true },
            orderBy: { date: 'desc' },
        });
    },

    async findByDoctorId(doctorUserId: string) {
        // Find doctor first
        const doctor = await prisma.doctor.findFirst({
             where: { userId: doctorUserId },
        });

        if (!doctor) throw { statusCode: 404, message: 'Profil médecin introuvable' };

        return prisma.appointment.findMany({
            where: { doctorId: doctor.id },
            include: { user: true }, // Include patient info
            orderBy: { date: 'asc' },
        });
    },

    async findById(id: string, requesterUserId: string) {
        const appointment = await prisma.appointment.findUnique({
            where: { id },
            include: { doctor: true, user: true },
        });

        if (!appointment) {
            throw { statusCode: 404, message: 'Rendez-vous non trouvé' };
        }

        // Allow if requester is patient OR doctor
        const isPatient = appointment.userId === requesterUserId;
        const isDoctor = appointment.doctor.userId === requesterUserId;

        if (!isPatient && !isDoctor) {
            throw { statusCode: 403, message: 'Accès non autorisé' };
        }

        return appointment;
    },

    async updateStatus(id: string, requesterUserId: string, status: AppointmentStatus) {
        // Verify ownership
        const appointment = await prisma.appointment.findUnique({ 
            where: { id },
            include: { doctor: true }
        });

        if (!appointment) {
            throw { statusCode: 404, message: 'Rendez-vous non trouvé' };
        }

        const isPatient = appointment.userId === requesterUserId;
        const isDoctor = appointment.doctor.userId === requesterUserId;

        if (!isPatient && !isDoctor) {
            throw { statusCode: 403, message: 'Accès non autorisé' };
        }

        // Specific rules (e.g. Patient can only Cancel)
        if (isPatient && status !== 'CANCELLED') {
             throw { statusCode: 403, message: 'Action non autorisée pour le patient' };
        }

        return prisma.appointment.update({
            where: { id },
            data: { status },
            include: { doctor: true, user: true },
        });
    },

    async cancel(id: string, userId: string) {
        return this.updateStatus(id, userId, 'CANCELLED');
    },
};
