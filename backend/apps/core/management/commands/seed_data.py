from django.core.management.base import BaseCommand
from django.contrib.auth import get_user_model
from apps.practitioners.models import Specialty

User = get_user_model()


class Command(BaseCommand):
    help = 'Insère les données initiales (idempotent)'

    def handle(self, *args, **kwargs):
        # ── Superuser ────────────────────────────────────────────────────────
        admin_phone = '+22900000000'
        if not User.objects.filter(phone_number=admin_phone).exists():
            User.objects.create_superuser(
                phone_number=admin_phone,
                password='Admin1234!',
                first_name='Admin',
                last_name='AlloDoto',
                role='admin',
            )
            self.stdout.write(self.style.SUCCESS(
                f'Superuser créé : {admin_phone} / Admin1234!'
            ))
        else:
            self.stdout.write(f'Superuser déjà existant ({admin_phone})')

        # ── Spécialités ──────────────────────────────────────────────────────
        specialties = [
            ('Médecine générale', 'medecine-generale', 1),
            ('Pédiatrie', 'pediatrie', 2),
            ('Gynécologie', 'gynecologie', 3),
            ('Cardiologie', 'cardiologie', 4),
            ('Dermatologie', 'dermatologie', 5),
            ('Ophtalmologie', 'ophtalmologie', 6),
            ('Dentisterie', 'dentisterie', 7),
            ('Neurologie', 'neurologie', 8),
        ]
        created = 0
        for name, slug, order in specialties:
            _, is_new = Specialty.objects.get_or_create(
                slug=slug,
                defaults={'name': name, 'order': order},
            )
            if is_new:
                created += 1

        if created:
            self.stdout.write(self.style.SUCCESS(f'{created} spécialité(s) créée(s)'))
        else:
            self.stdout.write('Spécialités déjà présentes — rien à faire')
