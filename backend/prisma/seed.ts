import { PrismaClient, Gender, Role } from '@prisma/client';
import bcrypt from 'bcryptjs';

const prisma = new PrismaClient();

async function main() {
    console.log('🌱 Seeding database...');

    // Clear existing data
    await prisma.appointment.deleteMany();
    await prisma.medicalRecord.deleteMany();
    await prisma.otp.deleteMany();
    await prisma.user.deleteMany();
    await prisma.doctor.deleteMany();

    // Create test user
    const passwordHash = await bcrypt.hash('Password123!', 10);

    const user = await prisma.user.create({
        data: {
            email: 'patient@allosante.bj',
            phone: '+22990000001',
            passwordHash,
            firstName: 'Jean',
            lastName: 'Dupont',
            isVerified: true,
            // Gender not on User yet, only Doctor
        },
    });

    console.log('✅ Created user:', user.email);

    const doctorsData = [
        // Cotonou
        {
            firstName: 'Aminou', lastName: 'Kouyaté', specialty: 'Médecine Générale', location: 'Cotonou',
            address: 'Clinique Centrale, Rue 123', rating: 4.8, reviewCount: 120, consultationPrice: 10000,
            languages: ['Français', 'Fon'], availableDays: ['Lundi', 'Mercredi', 'Vendredi'], isAvailable: true,
            experienceYears: 10, bio: 'Médecin généraliste avec 10 ans d\'expérience.', gender: Gender.MALE
        },
        {
            firstName: 'Aïcha', lastName: 'Dossou', specialty: 'Gynécologie', location: 'Cotonou',
            address: 'Hôpital de la Mère et de l\'Enfant', rating: 4.9, reviewCount: 85, consultationPrice: 15000,
            languages: ['Français', 'Yoruba'], availableDays: ['Mardi', 'Jeudi', 'Samedi'], isAvailable: true,
            experienceYears: 8, bio: 'Spécialiste en gynécologie obstétrique.', gender: Gender.FEMALE
        },
        {
            firstName: 'Mariama', lastName: 'Sanni', specialty: 'Pédiatrie', location: 'Cotonou',
            address: 'Clinique Pédiatrique Soleil', rating: 4.9, reviewCount: 150, consultationPrice: 12000,
            languages: ['Français', 'Fon', 'Dendi'], availableDays: ['Lundi', 'Mercredi', 'Vendredi', 'Samedi'], isAvailable: true,
            experienceYears: 15, bio: 'Pédiatre avec une passion pour la santé infantile.', gender: Gender.FEMALE
        },
        {
            firstName: 'Gilles', lastName: 'Gnacadja', specialty: 'Dentiste', location: 'Cotonou',
            address: 'Cabinet Dentaire du Port', rating: 4.6, reviewCount: 45, consultationPrice: 15000,
            languages: ['Français', 'Anglais'], availableDays: ['Lundi', 'Mardi', 'Jeudi'], isAvailable: true,
            experienceYears: 7, bio: 'Expert en soins dentaires et implants.', gender: Gender.MALE
        },
        {
            firstName: 'Fabrice', lastName: 'Tossou', specialty: 'Dermatologue', location: 'Cotonou',
            address: 'Centre Derma Skin', rating: 4.7, reviewCount: 60, consultationPrice: 18000,
            languages: ['Français', 'Fon'], availableDays: ['Mercredi', 'Vendredi'], isAvailable: false,
            experienceYears: 11, bio: 'Traitement des maladies de la peau et esthétique.', gender: Gender.MALE
        },

        // Porto-Novo
        {
            firstName: 'Koffi', lastName: 'Agbossou', specialty: 'Cardiologie', location: 'Porto-Novo',
            address: 'Centre Cardiologique de Porto-Novo', rating: 4.7, reviewCount: 65, consultationPrice: 20000,
            languages: ['Français', 'Goun'], availableDays: ['Lundi', 'Mardi', 'Jeudi'], isAvailable: true,
            experienceYears: 12, bio: 'Cardiologue spécialisé dans les maladies cardiovasculaires.', gender: Gender.MALE
        },
        {
            firstName: 'Brigitte', lastName: 'Hounkponou', specialty: 'Ophtalmologue', location: 'Porto-Novo',
            address: 'Clinique des Yeux Clairs', rating: 4.5, reviewCount: 30, consultationPrice: 12000,
            languages: ['Français', 'Yoruba'], availableDays: ['Mardi', 'Vendredi'], isAvailable: true,
            experienceYears: 9, bio: 'Chirurgien ophtalmologue expérimenté.', gender: Gender.FEMALE
        },
        {
            firstName: 'Hervé', lastName: 'Zannou', specialty: 'Médecine Générale', location: 'Porto-Novo',
            address: 'Cabinet Médical Espoir', rating: 4.3, reviewCount: 22, consultationPrice: 8000,
            languages: ['Français', 'Goun'], availableDays: ['Lundi', 'Mercredi', 'Samedi'], isAvailable: true,
            experienceYears: 5, bio: 'Consultations générales pour toute la famille.', gender: Gender.MALE
        },

        // Parakou
        {
            firstName: 'Ibrahim', lastName: 'Mama', specialty: 'Neurologue', location: 'Parakou',
            address: 'CHUD Borgou', rating: 4.9, reviewCount: 90, consultationPrice: 25000,
            languages: ['Français', 'Dendi', 'Bariba'], availableDays: ['Lundi', 'Jeudi'], isAvailable: true,
            experienceYears: 20, bio: 'Neurologue renommé dans le Nord Bénin.', gender: Gender.MALE
        },
        {
            firstName: 'Salimata', lastName: 'Traoré', specialty: 'Gynécologie', location: 'Parakou',
            address: 'Clinique La Rose', rating: 4.6, reviewCount: 40, consultationPrice: 10000,
            languages: ['Français', 'Bariba'], availableDays: ['Lundi', 'Mardi', 'Mercredi'], isAvailable: true,
            experienceYears: 6, bio: 'Accompagnement grossesse et accouchement.', gender: Gender.FEMALE
        },
        {
            firstName: 'Moussa', lastName: 'Yarou', specialty: 'Orthopédiste', location: 'Parakou',
            address: 'Trauma Center Parakou', rating: 4.4, reviewCount: 35, consultationPrice: 18000,
            languages: ['Français', 'Dendi'], availableDays: ['Vendredi', 'Samedi'], isAvailable: false,
            experienceYears: 14, bio: 'Chirurgie orthopédique et traumatologie.', gender: Gender.MALE
        },

        // Abomey-Calavi
        {
            firstName: 'Clarisse', lastName: 'Mensah', specialty: 'Pédiatrie', location: 'Abomey-Calavi',
            address: 'Clinique Calavi Kids', rating: 4.8, reviewCount: 110, consultationPrice: 10000,
            languages: ['Français', 'Mina'], availableDays: ['Lundi', 'Mardi', 'Jeudi'], isAvailable: true,
            experienceYears: 10, bio: 'Pédiatre attentionnée et douce avec les enfants.', gender: Gender.FEMALE
        },
        {
            firstName: 'Patrick', lastName: 'Gomez', specialty: 'Dentiste', location: 'Abomey-Calavi',
            address: 'Cabinet Dentaire IITA', rating: 4.5, reviewCount: 55, consultationPrice: 15000,
            languages: ['Français', 'Anglais'], availableDays: ['Mercredi', 'Vendredi'], isAvailable: true,
            experienceYears: 8, bio: 'Prothèses dentaires et orthodontie.', gender: Gender.MALE
        },
        {
            firstName: 'Justine', lastName: 'Agbo', specialty: 'Médecine Générale', location: 'Abomey-Calavi',
            address: 'Centre de Santé Bidossessi', rating: 4.2, reviewCount: 15, consultationPrice: 5000,
            languages: ['Français', 'Fon'], availableDays: ['Lundi', 'Mardi', 'Mercredi', 'Jeudi', 'Vendredi'], isAvailable: true,
            experienceYears: 3, bio: 'Médecin de famille dévoué.', gender: Gender.FEMALE
        },

        // Bohicon
        {
            firstName: 'Césaire', lastName: 'Lokossou', specialty: 'Gastro-entérologue', location: 'Bohicon',
            address: 'Clinique du Zou', rating: 4.7, reviewCount: 25, consultationPrice: 17000,
            languages: ['Français', 'Fon'], availableDays: ['Jeudi', 'Samedi'], isAvailable: true,
            experienceYears: 13, bio: 'Spécialiste des maladies digestives.', gender: Gender.MALE
        },
        {
            firstName: 'Bernadette', lastName: 'Soglo', specialty: 'Ophtalmologue', location: 'Bohicon',
            address: 'Vision Plus Bohicon', rating: 4.4, reviewCount: 18, consultationPrice: 12000,
            languages: ['Français', 'Fon'], availableDays: ['Lundi', 'Mercredi'], isAvailable: true,
            experienceYears: 7, bio: 'Consultations ophtalmologiques et lunetterie.', gender: Gender.FEMALE
        },

        // Natitingou
        {
            firstName: 'Barthélémy', lastName: 'Nata', specialty: 'Médecine Générale', location: 'Natitingou',
            address: 'Hôpital de Zone Natitingou', rating: 4.5, reviewCount: 50, consultationPrice: 7000,
            languages: ['Français', 'Ditamari'], availableDays: ['Lundi', 'Mardi', 'Vendredi'], isAvailable: true,
            experienceYears: 15, bio: 'Médecin chef expérimenté.', gender: Gender.MALE
        },

        // Ouidah
        {
            firstName: 'Rose', lastName: 'De Souza', specialty: 'Psychiatre', location: 'Ouidah',
            address: 'Centre Psychothérapique', rating: 4.8, reviewCount: 20, consultationPrice: 20000,
            languages: ['Français', 'Mina'], availableDays: ['Mardi', 'Jeudi'], isAvailable: true,
            experienceYears: 18, bio: 'Psychothérapie et santé mentale.', gender: Gender.FEMALE
        },
        {
            firstName: 'Victor', lastName: 'Quénum', specialty: 'Dermatologue', location: 'Ouidah',
            address: 'Cabinet de la Plage', rating: 4.3, reviewCount: 12, consultationPrice: 15000,
            languages: ['Français', 'Fon'], availableDays: ['Mercredi', 'Samedi'], isAvailable: true,
            experienceYears: 6, bio: 'Dermatologie tropicale.', gender: Gender.MALE
        }
    ];


    // Create Doctor User (Link to Aminou Kouyaté)
    const passwordHashDoc = await bcrypt.hash('DoctorPass123!', 10);
    const doctorUser = await prisma.user.create({
        data: {
            email: 'medecin@allosante.bj',
            phone: '+22990000002',
            passwordHash: passwordHashDoc,
            firstName: 'Aminou',
            lastName: 'Kouyaté',
            role: Role.DOCTOR,
            isVerified: true,
        }
    });
    console.log('✅ Created doctor user:', doctorUser.email);

    for (const doctorData of doctorsData) {
        // Link the first doctor (Aminou) to the created user
        const isAminou = doctorData.firstName === 'Aminou' && doctorData.lastName === 'Kouyaté';

        await prisma.doctor.create({
            data: {
                ...doctorData,
                email: `dr.${doctorData.lastName.toLowerCase().replace(/[^a-z0-9]/g, '')}.${doctorData.firstName.toLowerCase().replace(/[^a-z0-9]/g, '')}@allosante.bj`,
                profilePictureUrl: null,
                userId: isAminou ? doctorUser.id : null, // Link if it's Aminou
            },
        });
    }

    console.log(`✅ Created ${doctorsData.length} doctors across Benin`);

    // Create medical record for test user
    await prisma.medicalRecord.create({
        data: {
            userId: user.id,
            bloodType: 'O+',
            allergies: ['Pénicilline'],
            conditions: ['Hypertension légère'],
            medications: ['Amlodipine 5mg'],
            notes: 'Patient en bonne santé générale.',
        },
    });

    console.log('✅ Created medical record');

    console.log('🎉 Seeding completed!');
}

main()
    .catch((e) => {
        console.error('❌ Seeding failed:', e);
        process.exit(1);
    })
    .finally(async () => {
        await prisma.$disconnect();
    });
