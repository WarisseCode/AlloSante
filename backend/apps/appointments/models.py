"""
AllôDoto — Module Rendez-vous
Modèles : Appointment, AppointmentCancellation
"""
from django.db import models
from django.conf import settings
from django.core.exceptions import ValidationError


class Appointment(models.Model):
    """
    Rendez-vous entre un patient et un praticien.
    Cycle de vie : PENDING → CONFIRMED → COMPLETED
                                └→ CANCELLED (par patient ou praticien)
    """

    class Status(models.TextChoices):
        PENDING = 'pending', 'En attente de confirmation'
        CONFIRMED = 'confirmed', 'Confirmé'
        COMPLETED = 'completed', 'Terminé'
        CANCELLED = 'cancelled', 'Annulé'
        NO_SHOW = 'no_show', 'Patient absent'

    class Type(models.TextChoices):
        IN_PERSON = 'in_person', 'En cabinet'
        TELECONSULTATION = 'teleconsultation', 'Téléconsultation'

    # Participants
    patient = models.ForeignKey(
        settings.AUTH_USER_MODEL,
        on_delete=models.CASCADE,
        related_name='appointments_as_patient',
    )
    practitioner = models.ForeignKey(
        'practitioners.Practitioner',
        on_delete=models.CASCADE,
        related_name='appointments',
    )

    # Créneau réservé
    time_slot = models.OneToOneField(
        'practitioners.TimeSlot',
        on_delete=models.PROTECT,
        related_name='appointment',
    )

    # Détails
    appointment_type = models.CharField(
        max_length=20, choices=Type.choices, default=Type.IN_PERSON
    )
    status = models.CharField(
        max_length=20, choices=Status.choices, default=Status.PENDING
    )
    reason = models.TextField(
        blank=True, help_text="Motif de consultation indiqué par le patient"
    )
    patient_notes = models.TextField(
        blank=True, help_text="Notes complémentaires du patient"
    )
    practitioner_notes = models.TextField(
        blank=True, help_text="Observations du praticien (non visible par le patient)"
    )

    # Prix appliqué au moment de la réservation (snapshot)
    fee_at_booking = models.PositiveIntegerField(
        default=0, help_text="Tarif en FCFA au moment de la réservation"
    )

    # Timestamps
    booked_at = models.DateTimeField(auto_now_add=True)
    confirmed_at = models.DateTimeField(null=True, blank=True)
    completed_at = models.DateTimeField(null=True, blank=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        db_table = 'appointments'
        verbose_name = 'Rendez-vous'
        verbose_name_plural = 'Rendez-vous'
        ordering = ['-time_slot__date', '-time_slot__start_time']

    def __str__(self):
        return (
            f"RDV {self.patient.full_name} → {self.practitioner.display_name} "
            f"le {self.time_slot.date} à {self.time_slot.start_time}"
        )

    def clean(self):
        # Un seul RDV actif par patient/praticien/créneau
        if self.time_slot.status != 'available' and not self.pk:
            raise ValidationError("Ce créneau n'est plus disponible.")
        if self.appointment_type == self.Type.TELECONSULTATION:
            if not self.time_slot.is_teleconsultation:
                raise ValidationError(
                    "Ce créneau n'est pas disponible pour la téléconsultation."
                )

    def save(self, *args, **kwargs):
        # Snapshot du tarif au moment de la réservation
        if not self.pk:
            if self.appointment_type == self.Type.TELECONSULTATION:
                self.fee_at_booking = self.practitioner.teleconsultation_fee
            else:
                self.fee_at_booking = self.practitioner.consultation_fee
        super().save(*args, **kwargs)

    @property
    def is_upcoming(self):
        from django.utils import timezone
        slot_dt = timezone.datetime.combine(
            self.time_slot.date, self.time_slot.start_time
        )
        return (
            self.status in (self.Status.PENDING, self.Status.CONFIRMED)
            and slot_dt > timezone.now()
        )


class AppointmentCancellation(models.Model):
    """Enregistre les détails d'une annulation."""

    class CancelledBy(models.TextChoices):
        PATIENT = 'patient', 'Patient'
        PRACTITIONER = 'practitioner', 'Praticien'
        ADMIN = 'admin', 'Administrateur'
        SYSTEM = 'system', 'Système'

    appointment = models.OneToOneField(
        Appointment,
        on_delete=models.CASCADE,
        related_name='cancellation',
    )
    cancelled_by = models.CharField(max_length=20, choices=CancelledBy.choices)
    cancelled_by_user = models.ForeignKey(
        settings.AUTH_USER_MODEL,
        on_delete=models.SET_NULL,
        null=True, blank=True,
    )
    reason = models.TextField(blank=True)
    cancelled_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        db_table = 'appointment_cancellations'
        verbose_name = 'Annulation'
        verbose_name_plural = 'Annulations'

    def __str__(self):
        return f"Annulation RDV #{self.appointment_id} par {self.cancelled_by}"
