import { PrismaClient } from '@prisma/client';

const prisma = new PrismaClient();

export interface UpdateMedicalRecordInput {
    bloodType?: string;
    allergies?: string[];
    conditions?: string[];
    medications?: string[];
    notes?: string;
}

export const medicalRecordService = {
    async findByUserId(userId: string) {
        let record = await prisma.medicalRecord.findUnique({
            where: { userId },
        });

        // Create empty record if not exists
        if (!record) {
            record = await prisma.medicalRecord.create({
                data: {
                    userId,
                    allergies: [],
                    conditions: [],
                    medications: [],
                },
            });
        }

        return record;
    },

    async update(userId: string, input: UpdateMedicalRecordInput) {
        // Ensure record exists
        const existing = await prisma.medicalRecord.findUnique({
            where: { userId },
        });

        if (!existing) {
            // Create new record
            return prisma.medicalRecord.create({
                data: {
                    userId,
                    ...input,
                    allergies: input.allergies || [],
                    conditions: input.conditions || [],
                    medications: input.medications || [],
                },
            });
        }

        // Update existing
        return prisma.medicalRecord.update({
            where: { userId },
            data: input,
        });
    },
};
