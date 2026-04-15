"""
AllôDoto — Vues Dossier Médical
"""
from rest_framework import generics, status
from rest_framework.permissions import IsAuthenticated
from rest_framework.response import Response

from apps.practitioners.permissions import IsPractitioner
from apps.appointments.models import Appointment
from .models import Prescription, MedicalDocument, MedicationReminder
from .serializers import (
    PrescriptionSerializer, PrescriptionCreateSerializer,
    MedicalDocumentSerializer, MedicationReminderSerializer,
)


# ─── Ordonnances ─────────────────────────────────────────────────────────────

class PatientPrescriptionsView(generics.ListAPIView):
    """GET /medical-records/prescriptions/ — Ordonnances du patient connecté."""
    serializer_class = PrescriptionSerializer
    permission_classes = [IsAuthenticated]

    def get_queryset(self):
        return Prescription.objects.filter(
            patient=self.request.user
        ).select_related('practitioner__user').prefetch_related('items')


class PrescriptionDetailView(generics.RetrieveAPIView):
    """GET /medical-records/prescriptions/:id/ — Détail d'une ordonnance."""
    serializer_class = PrescriptionSerializer
    permission_classes = [IsAuthenticated]

    def get_queryset(self):
        user = self.request.user
        if user.role == 'practitioner':
            return Prescription.objects.filter(practitioner__user=user)
        return Prescription.objects.filter(patient=user)


class CreatePrescriptionView(generics.CreateAPIView):
    """
    POST /medical-records/prescriptions/create/
    Le praticien crée une ordonnance après un rendez-vous terminé.
    """
    serializer_class = PrescriptionCreateSerializer
    permission_classes = [IsAuthenticated, IsPractitioner]

    def perform_create(self, serializer):
        appointment = serializer.validated_data['appointment']

        # Vérifier que le RDV appartient au praticien
        if appointment.practitioner.user != self.request.user:
            from rest_framework.exceptions import PermissionDenied
            raise PermissionDenied("Ce rendez-vous ne vous appartient pas.")

        if appointment.status != Appointment.Status.COMPLETED:
            from rest_framework.exceptions import ValidationError
            raise ValidationError("Le rendez-vous doit être terminé pour créer une ordonnance.")

        serializer.save(
            patient=appointment.patient,
            practitioner=appointment.practitioner,
        )


# ─── Documents médicaux ───────────────────────────────────────────────────────

class MedicalDocumentsView(generics.ListCreateAPIView):
    """
    GET|POST /medical-records/documents/
    Le patient consulte et uploade ses documents médicaux.
    """
    serializer_class = MedicalDocumentSerializer
    permission_classes = [IsAuthenticated]

    def get_queryset(self):
        qs = MedicalDocument.objects.filter(patient=self.request.user)
        doc_type = self.request.query_params.get('type')
        if doc_type:
            qs = qs.filter(document_type=doc_type)
        return qs

    def perform_create(self, serializer):
        serializer.save(patient=self.request.user)


class MedicalDocumentDeleteView(generics.DestroyAPIView):
    """DELETE /medical-records/documents/:id/"""
    permission_classes = [IsAuthenticated]

    def get_queryset(self):
        return MedicalDocument.objects.filter(patient=self.request.user)


# ─── Rappels médicaments ─────────────────────────────────────────────────────

class MedicationRemindersView(generics.ListCreateAPIView):
    """GET|POST /medical-records/reminders/"""
    serializer_class = MedicationReminderSerializer
    permission_classes = [IsAuthenticated]

    def get_queryset(self):
        qs = MedicationReminder.objects.filter(patient=self.request.user)
        if self.request.query_params.get('active') == 'true':
            qs = qs.filter(is_active=True)
        return qs

    def perform_create(self, serializer):
        serializer.save(patient=self.request.user)


class MedicationReminderDetailView(generics.RetrieveUpdateDestroyAPIView):
    """GET|PATCH|DELETE /medical-records/reminders/:id/"""
    serializer_class = MedicationReminderSerializer
    permission_classes = [IsAuthenticated]

    def get_queryset(self):
        return MedicationReminder.objects.filter(patient=self.request.user)
