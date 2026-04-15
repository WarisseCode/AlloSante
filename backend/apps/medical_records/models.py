"""
AllôDoto — Module Dossier Médical
Modèles : Prescription, MedicalDocument, MedicationReminder
"""
from django.db import models
from django.conf import settings
from django.core.validators import MinValueValidator


class Prescription(models.Model):
    """
    Ordonnance numérique générée après une consultation.
    Liée à un rendez-vous terminé.
    """
    appointment = models.OneToOneField(
        'appointments.Appointment',
        on_delete=models.CASCADE,
        related_name='prescription',
    )
    patient = models.ForeignKey(
        settings.AUTH_USER_MODEL,
        on_delete=models.CASCADE,
        related_name='prescriptions',
    )
    practitioner = models.ForeignKey(
        'practitioners.Practitioner',
        on_delete=models.CASCADE,
        related_name='prescriptions_issued',
    )

    # Contenu
    diagnosis = models.TextField(blank=True, help_text="Diagnostic")
    instructions = models.TextField(blank=True, help_text="Instructions générales")
    follow_up_date = models.DateField(null=True, blank=True, help_text="Date de suivi recommandée")

    # Fichier PDF généré
    pdf_file = models.FileField(upload_to='prescriptions/', null=True, blank=True)

    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        db_table = 'prescriptions'
        verbose_name = 'Ordonnance'
        verbose_name_plural = 'Ordonnances'
        ordering = ['-created_at']

    def __str__(self):
        return f"Ordonnance #{self.pk} — {self.patient.full_name} ({self.created_at.date()})"


class PrescriptionItem(models.Model):
    """Une ligne de médicament dans une ordonnance."""
    prescription = models.ForeignKey(
        Prescription, on_delete=models.CASCADE, related_name='items'
    )
    medication_name = models.CharField(max_length=200)
    dosage = models.CharField(max_length=100, help_text="Ex: 500mg")
    frequency = models.CharField(max_length=100, help_text="Ex: 2 fois par jour")
    duration_days = models.PositiveSmallIntegerField(
        validators=[MinValueValidator(1)],
        help_text="Durée du traitement en jours"
    )
    instructions = models.CharField(
        max_length=300, blank=True,
        help_text="Ex: Prendre après les repas"
    )

    class Meta:
        db_table = 'prescription_items'
        verbose_name = 'Médicament prescrit'
        verbose_name_plural = 'Médicaments prescrits'

    def __str__(self):
        return f"{self.medication_name} {self.dosage} — {self.frequency}"


class MedicalDocument(models.Model):
    """
    Document médical uploadé par le patient (résultats d'examens, radios, etc.)
    """
    class DocumentType(models.TextChoices):
        LAB_RESULT = 'lab', 'Résultat d\'analyse'
        IMAGING = 'imaging', 'Imagerie (radio, écho...)'
        PRESCRIPTION = 'prescription', 'Ordonnance externe'
        REPORT = 'report', 'Compte-rendu médical'
        OTHER = 'other', 'Autre'

    patient = models.ForeignKey(
        settings.AUTH_USER_MODEL,
        on_delete=models.CASCADE,
        related_name='medical_documents',
    )
    document_type = models.CharField(
        max_length=20, choices=DocumentType.choices, default=DocumentType.OTHER
    )
    title = models.CharField(max_length=200)
    file = models.FileField(upload_to='medical_documents/%Y/%m/')
    document_date = models.DateField(null=True, blank=True, help_text="Date de l'examen")
    notes = models.TextField(blank=True)
    uploaded_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        db_table = 'medical_documents'
        verbose_name = 'Document médical'
        verbose_name_plural = 'Documents médicaux'
        ordering = ['-uploaded_at']

    def __str__(self):
        return f"{self.get_document_type_display()} — {self.title} ({self.patient.full_name})"


class MedicationReminder(models.Model):
    """Rappel de prise de médicament (lié ou non à une ordonnance)."""

    class Frequency(models.TextChoices):
        ONCE_DAILY = 'once_daily', 'Une fois par jour'
        TWICE_DAILY = 'twice_daily', 'Deux fois par jour'
        THREE_DAILY = 'three_daily', 'Trois fois par jour'
        EVERY_8H = 'every_8h', 'Toutes les 8 heures'
        WEEKLY = 'weekly', 'Une fois par semaine'
        AS_NEEDED = 'as_needed', 'Si besoin'

    patient = models.ForeignKey(
        settings.AUTH_USER_MODEL,
        on_delete=models.CASCADE,
        related_name='medication_reminders',
    )
    prescription_item = models.ForeignKey(
        PrescriptionItem,
        on_delete=models.SET_NULL,
        null=True, blank=True,
        related_name='reminders',
    )
    medication_name = models.CharField(max_length=200)
    dosage = models.CharField(max_length=100, blank=True)
    frequency = models.CharField(
        max_length=20, choices=Frequency.choices, default=Frequency.ONCE_DAILY
    )
    reminder_times = models.JSONField(
        default=list,
        help_text="Liste d'heures de rappel ex: ['08:00', '20:00']"
    )
    start_date = models.DateField()
    end_date = models.DateField(null=True, blank=True)
    is_active = models.BooleanField(default=True)
    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        db_table = 'medication_reminders'
        verbose_name = 'Rappel médicament'
        verbose_name_plural = 'Rappels médicaments'
        ordering = ['medication_name']

    def __str__(self):
        return f"Rappel {self.medication_name} — {self.patient.full_name}"
