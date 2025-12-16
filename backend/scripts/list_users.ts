import { PrismaClient } from '@prisma/client';

const prisma = new PrismaClient();

async function main() {
  const users = await prisma.user.findMany({
    include: {
      doctor: true,
    },
    orderBy: {
      createdAt: 'desc',
    }
  });

  const doctors = users.filter(u => u.role === 'DOCTOR');
  const patients = users.filter(u => u.role === 'PATIENT');
  const admins = users.filter(u => u.role === 'ADMIN');

  console.log('\n===== 👨‍⚕️ MÉDECINS (' + doctors.length + ') =====');
  doctors.forEach(u => {
    console.log(`- [${u.id}] ${u.firstName} ${u.lastName} (${u.email}) - Tel: ${u.phone}`);
    if (u.doctor) {
        console.log(`  Spécialité: ${u.doctor.specialty}, Ville: ${u.doctor.location}, Prix: ${u.doctor.consultationPrice} FCFA`);
    } else {
        console.log(`  ⚠️ Profil Docteur manquant !`);
    }
  });

  console.log('\n===== 👤 PATIENTS (' + patients.length + ') =====');
  patients.forEach(u => {
    console.log(`- [${u.id}] ${u.firstName} ${u.lastName} (${u.email}) - Tel: ${u.phone}`);
  });

    console.log('\n===== 🛡️ ADMINS (' + admins.length + ') =====');
  admins.forEach(u => {
    console.log(`- [${u.id}] ${u.firstName} ${u.lastName} (${u.email})`);
  });
}

main()
  .catch((e) => {
    console.error(e);
    process.exit(1);
  })
  .finally(async () => {
    await prisma.$disconnect();
  });
