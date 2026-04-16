from django.core.management.base import BaseCommand
from apps.practitioners.models import Specialty


class Command(BaseCommand):
    help = 'Insère les données initiales (idempotent)'

    def handle(self, *args, **kwargs):
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
            self.stdout.write('Données déjà présentes — rien à faire')
