"""
AllôDoto — Module Pharmacies
Modèles : Pharmacy, OnDutySchedule (pharmacie de garde)
"""
from django.db import models
from django.conf import settings


class Pharmacy(models.Model):
    """Officine pharmaceutique référencée sur AllôDoto."""

    class Status(models.TextChoices):
        PENDING = 'pending', 'En attente de validation'
        ACTIVE = 'active', 'Active'
        SUSPENDED = 'suspended', 'Suspendue'

    # Compte lié (optionnel — peut être géré par l'admin)
    user = models.OneToOneField(
        settings.AUTH_USER_MODEL,
        on_delete=models.SET_NULL,
        null=True, blank=True,
        related_name='pharmacy_profile',
    )

    # Informations générales
    name = models.CharField(max_length=200)
    phone_number = models.CharField(max_length=20)
    email = models.EmailField(blank=True)

    # Localisation
    address = models.CharField(max_length=300)
    city = models.CharField(max_length=100, default='Cotonou')
    neighborhood = models.CharField(max_length=100, blank=True)
    latitude = models.DecimalField(
        max_digits=9, decimal_places=6, null=True, blank=True
    )
    longitude = models.DecimalField(
        max_digits=9, decimal_places=6, null=True, blank=True
    )

    # Horaires habituels
    opening_time = models.TimeField(null=True, blank=True)
    closing_time = models.TimeField(null=True, blank=True)
    is_open_sunday = models.BooleanField(default=False)

    # Statut
    status = models.CharField(
        max_length=20, choices=Status.choices, default=Status.PENDING
    )
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        db_table = 'pharmacies'
        verbose_name = 'Pharmacie'
        verbose_name_plural = 'Pharmacies'
        ordering = ['city', 'name']

    def __str__(self):
        return f"{self.name} — {self.city}"

    @property
    def is_active(self):
        return self.status == self.Status.ACTIVE


class OnDutySchedule(models.Model):
    """
    Pharmacie de garde pour une date donnée.
    Une pharmacie peut être de garde sur plusieurs périodes.
    """
    pharmacy = models.ForeignKey(
        Pharmacy,
        on_delete=models.CASCADE,
        related_name='duty_schedules',
    )
    date = models.DateField()
    start_time = models.TimeField(default='08:00')
    end_time = models.TimeField(default='08:00', help_text="Fin de garde (peut être le lendemain)")
    is_overnight = models.BooleanField(
        default=False,
        help_text="La garde se termine le lendemain matin"
    )
    notes = models.CharField(max_length=200, blank=True)

    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        db_table = 'on_duty_schedules'
        verbose_name = 'Pharmacie de garde'
        verbose_name_plural = 'Pharmacies de garde'
        ordering = ['date', 'start_time']

    def __str__(self):
        return f"{self.pharmacy.name} — garde du {self.date}"
