"""
AllôDoto — Module Praticiens
Modèles : Specialty, Practitioner, WorkingHours, TimeSlot, PractitionerReview
"""
from django.db import models
from django.conf import settings
from django.core.validators import MinValueValidator, MaxValueValidator


class Specialty(models.Model):
    """Spécialité médicale (Médecin généraliste, Cardiologue, etc.)"""
    name = models.CharField(max_length=100, unique=True)
    slug = models.SlugField(max_length=100, unique=True)
    description = models.TextField(blank=True)
    icon = models.CharField(max_length=50, blank=True, help_text="Nom icône Material Icons")
    is_active = models.BooleanField(default=True)
    order = models.PositiveSmallIntegerField(default=0)

    class Meta:
        db_table = 'specialties'
        verbose_name = 'Spécialité'
        verbose_name_plural = 'Spécialités'
        ordering = ['order', 'name']

    def __str__(self):
        return self.name


class Practitioner(models.Model):
    """Profil praticien — lié à un User de rôle 'practitioner'."""

    class Gender(models.TextChoices):
        MALE = 'M', 'Homme'
        FEMALE = 'F', 'Femme'
        OTHER = 'O', 'Autre'

    class Status(models.TextChoices):
        PENDING = 'pending', 'En attente de validation'
        ACTIVE = 'active', 'Actif'
        SUSPENDED = 'suspended', 'Suspendu'

    user = models.OneToOneField(
        settings.AUTH_USER_MODEL,
        on_delete=models.CASCADE,
        related_name='practitioner_profile',
    )
    specialty = models.ForeignKey(
        Specialty,
        on_delete=models.SET_NULL,
        null=True,
        related_name='practitioners',
    )

    # Informations professionnelles
    title = models.CharField(max_length=20, blank=True, help_text="Dr., Pr., etc.")
    bio = models.TextField(blank=True)
    years_experience = models.PositiveSmallIntegerField(default=0)
    languages = models.CharField(
        max_length=200, blank=True,
        help_text="Langues séparées par des virgules (ex: Français,Fon,Anglais)"
    )
    gender = models.CharField(max_length=1, choices=Gender.choices, blank=True)

    # Document de validation
    license_number = models.CharField(max_length=100, blank=True)
    license_document = models.FileField(
        upload_to='practitioner_docs/', null=True, blank=True
    )

    # Cabinet / Localisation
    cabinet_name = models.CharField(max_length=200, blank=True)
    address = models.CharField(max_length=300, blank=True)
    city = models.CharField(max_length=100, default='Cotonou')
    neighborhood = models.CharField(max_length=100, blank=True)
    latitude = models.DecimalField(
        max_digits=9, decimal_places=6, null=True, blank=True
    )
    longitude = models.DecimalField(
        max_digits=9, decimal_places=6, null=True, blank=True
    )

    # Tarification (FCFA)
    consultation_fee = models.PositiveIntegerField(
        default=0, help_text="Tarif de consultation en FCFA"
    )
    teleconsultation_fee = models.PositiveIntegerField(
        default=0, help_text="Tarif téléconsultation en FCFA"
    )

    # Photo de profil
    photo = models.ImageField(upload_to='practitioner_photos/', null=True, blank=True)

    # Statut & validation admin
    status = models.CharField(
        max_length=20, choices=Status.choices, default=Status.PENDING
    )
    validated_at = models.DateTimeField(null=True, blank=True)
    validated_by = models.ForeignKey(
        settings.AUTH_USER_MODEL,
        on_delete=models.SET_NULL,
        null=True, blank=True,
        related_name='validated_practitioners',
    )

    # Statistiques calculées
    rating_average = models.DecimalField(
        max_digits=3, decimal_places=2, default=0.0
    )
    review_count = models.PositiveIntegerField(default=0)

    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        db_table = 'practitioners'
        verbose_name = 'Praticien'
        verbose_name_plural = 'Praticiens'
        ordering = ['-rating_average', 'user__last_name']

    def __str__(self):
        return f"{self.title} {self.user.full_name} — {self.specialty}"

    @property
    def display_name(self):
        if self.title:
            return f"{self.title} {self.user.full_name}"
        return self.user.full_name

    @property
    def is_active(self):
        return self.status == self.Status.ACTIVE

    def languages_list(self):
        return [lang.strip() for lang in self.languages.split(',') if lang.strip()]


class WorkingHours(models.Model):
    """Horaires hebdomadaires du praticien."""

    class DayOfWeek(models.IntegerChoices):
        MONDAY = 0, 'Lundi'
        TUESDAY = 1, 'Mardi'
        WEDNESDAY = 2, 'Mercredi'
        THURSDAY = 3, 'Jeudi'
        FRIDAY = 4, 'Vendredi'
        SATURDAY = 5, 'Samedi'
        SUNDAY = 6, 'Dimanche'

    practitioner = models.ForeignKey(
        Practitioner, on_delete=models.CASCADE, related_name='working_hours'
    )
    day_of_week = models.IntegerField(choices=DayOfWeek.choices)
    start_time = models.TimeField()
    end_time = models.TimeField()
    slot_duration_minutes = models.PositiveSmallIntegerField(
        default=30, help_text="Durée d'un créneau en minutes"
    )
    is_active = models.BooleanField(default=True)

    class Meta:
        db_table = 'working_hours'
        verbose_name = 'Horaire'
        verbose_name_plural = 'Horaires'
        unique_together = ['practitioner', 'day_of_week']
        ordering = ['day_of_week', 'start_time']

    def __str__(self):
        day = self.DayOfWeek(self.day_of_week).label
        return f"{self.practitioner.display_name} — {day} {self.start_time}→{self.end_time}"


class TimeSlot(models.Model):
    """Créneau de rendez-vous disponible ou réservé."""

    class Status(models.TextChoices):
        AVAILABLE = 'available', 'Disponible'
        BOOKED = 'booked', 'Réservé'
        BLOCKED = 'blocked', 'Bloqué'

    practitioner = models.ForeignKey(
        Practitioner, on_delete=models.CASCADE, related_name='time_slots'
    )
    date = models.DateField()
    start_time = models.TimeField()
    end_time = models.TimeField()
    status = models.CharField(
        max_length=20, choices=Status.choices, default=Status.AVAILABLE
    )
    is_teleconsultation = models.BooleanField(default=False)
    notes = models.CharField(max_length=200, blank=True)
    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        db_table = 'time_slots'
        verbose_name = 'Créneau'
        verbose_name_plural = 'Créneaux'
        ordering = ['date', 'start_time']
        unique_together = ['practitioner', 'date', 'start_time']

    def __str__(self):
        return f"{self.practitioner.display_name} — {self.date} {self.start_time}"

    @property
    def is_available(self):
        return self.status == self.Status.AVAILABLE


class PractitionerReview(models.Model):
    """Avis d'un patient sur un praticien."""
    patient = models.ForeignKey(
        settings.AUTH_USER_MODEL,
        on_delete=models.CASCADE,
        related_name='reviews_given',
    )
    practitioner = models.ForeignKey(
        Practitioner,
        on_delete=models.CASCADE,
        related_name='reviews',
    )
    rating = models.PositiveSmallIntegerField(
        validators=[MinValueValidator(1), MaxValueValidator(5)]
    )
    comment = models.TextField(blank=True)
    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        db_table = 'practitioner_reviews'
        verbose_name = 'Avis'
        verbose_name_plural = 'Avis'
        unique_together = ['patient', 'practitioner']
        ordering = ['-created_at']

    def __str__(self):
        return f"{self.rating}★ — {self.patient.full_name} → {self.practitioner.display_name}"

    def save(self, *args, **kwargs):
        super().save(*args, **kwargs)
        self._recalculate_rating(self.practitioner)

    def delete(self, *args, **kwargs):
        practitioner = self.practitioner
        super().delete(*args, **kwargs)
        self._recalculate_rating(practitioner)

    @staticmethod
    def _recalculate_rating(practitioner):
        from django.db.models import Avg
        reviews = PractitionerReview.objects.filter(practitioner=practitioner)
        count = reviews.count()
        avg = reviews.aggregate(Avg('rating'))['rating__avg'] or 0.0
        practitioner.rating_average = round(avg, 2)
        practitioner.review_count = count
        practitioner.save(update_fields=['rating_average', 'review_count'])
