"""
AllôDoto — Vues Rendez-vous
Prise de RDV, confirmation, annulation, complétion
"""
from django.utils import timezone
from rest_framework import generics, status
from rest_framework.decorators import api_view, permission_classes
from rest_framework.permissions import IsAuthenticated
from rest_framework.response import Response

from apps.practitioners.models import TimeSlot
from apps.practitioners.permissions import IsPractitioner
from .models import Appointment, AppointmentCancellation
from .serializers import (
    AppointmentBookSerializer,
    AppointmentListSerializer,
    AppointmentDetailSerializer,
    CancelAppointmentSerializer,
    PractitionerNotesSerializer,
)


# ─── Patient ─────────────────────────────────────────────────────────────────

class BookAppointmentView(generics.CreateAPIView):
    """
    POST /appointments/book/
    Un patient prend un rendez-vous sur un créneau disponible.
    """
    serializer_class = AppointmentBookSerializer
    permission_classes = [IsAuthenticated]

    def perform_create(self, serializer):
        serializer.save()

    def create(self, request, *args, **kwargs):
        serializer = self.get_serializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        appointment = serializer.save()
        return Response(
            AppointmentDetailSerializer(appointment, context={'request': request}).data,
            status=status.HTTP_201_CREATED,
        )


class PatientAppointmentsView(generics.ListAPIView):
    """
    GET /appointments/mine/
    Liste des rendez-vous du patient connecté.
    Filtres : status (pending/confirmed/completed/cancelled), upcoming (true)
    """
    serializer_class = AppointmentListSerializer
    permission_classes = [IsAuthenticated]

    def get_queryset(self):
        qs = Appointment.objects.filter(
            patient=self.request.user
        ).select_related('practitioner__user', 'practitioner__specialty', 'time_slot')

        status_filter = self.request.query_params.get('status')
        if status_filter:
            qs = qs.filter(status=status_filter)

        if self.request.query_params.get('upcoming') == 'true':
            today = timezone.localdate()
            qs = qs.filter(
                time_slot__date__gte=today,
                status__in=[Appointment.Status.PENDING, Appointment.Status.CONFIRMED],
            )

        return qs


class AppointmentDetailView(generics.RetrieveAPIView):
    """
    GET /appointments/:id/
    Détail d'un rendez-vous (accessible par le patient ou le praticien concerné).
    """
    serializer_class = AppointmentDetailSerializer
    permission_classes = [IsAuthenticated]

    def get_queryset(self):
        user = self.request.user
        if user.role == 'practitioner':
            return Appointment.objects.filter(practitioner__user=user)
        return Appointment.objects.filter(patient=user)


# ─── Actions sur le rendez-vous ───────────────────────────────────────────────

@api_view(['PATCH'])
@permission_classes([IsAuthenticated])
def cancel_appointment(request, pk):
    """
    PATCH /appointments/:id/cancel/
    Annulation par le patient ou le praticien.
    Libère automatiquement le créneau.
    """
    user = request.user

    try:
        if user.role == 'practitioner':
            appointment = Appointment.objects.get(
                pk=pk, practitioner__user=user
            )
            cancelled_by = AppointmentCancellation.CancelledBy.PRACTITIONER
        else:
            appointment = Appointment.objects.get(pk=pk, patient=user)
            cancelled_by = AppointmentCancellation.CancelledBy.PATIENT
    except Appointment.DoesNotExist:
        return Response({'error': 'Rendez-vous introuvable.'}, status=404)

    if appointment.status in (Appointment.Status.COMPLETED, Appointment.Status.CANCELLED):
        return Response(
            {'error': f"Ce rendez-vous est déjà {appointment.get_status_display()}."},
            status=400,
        )

    serializer = CancelAppointmentSerializer(data=request.data)
    serializer.is_valid(raise_exception=True)

    # Annuler le RDV
    appointment.status = Appointment.Status.CANCELLED
    appointment.save(update_fields=['status', 'updated_at'])

    # Libérer le créneau
    slot = appointment.time_slot
    slot.status = TimeSlot.Status.AVAILABLE
    slot.save(update_fields=['status'])

    # Enregistrer la raison d'annulation
    AppointmentCancellation.objects.create(
        appointment=appointment,
        cancelled_by=cancelled_by,
        cancelled_by_user=user,
        reason=serializer.validated_data.get('reason', ''),
    )

    return Response(
        AppointmentDetailSerializer(appointment, context={'request': request}).data
    )


@api_view(['PATCH'])
@permission_classes([IsAuthenticated, IsPractitioner])
def confirm_appointment(request, pk):
    """
    PATCH /appointments/:id/confirm/
    Le praticien confirme un rendez-vous en attente.
    """
    try:
        appointment = Appointment.objects.get(
            pk=pk,
            practitioner__user=request.user,
            status=Appointment.Status.PENDING,
        )
    except Appointment.DoesNotExist:
        return Response(
            {'error': 'Rendez-vous introuvable ou déjà traité.'}, status=404
        )

    appointment.status = Appointment.Status.CONFIRMED
    appointment.confirmed_at = timezone.now()
    appointment.save(update_fields=['status', 'confirmed_at', 'updated_at'])

    return Response(
        AppointmentDetailSerializer(appointment, context={'request': request}).data
    )


@api_view(['PATCH'])
@permission_classes([IsAuthenticated, IsPractitioner])
def complete_appointment(request, pk):
    """
    PATCH /appointments/:id/complete/
    Le praticien marque le rendez-vous comme terminé + ajoute ses observations.
    """
    try:
        appointment = Appointment.objects.get(
            pk=pk,
            practitioner__user=request.user,
            status=Appointment.Status.CONFIRMED,
        )
    except Appointment.DoesNotExist:
        return Response(
            {'error': 'Rendez-vous introuvable ou non confirmé.'}, status=404
        )

    serializer = PractitionerNotesSerializer(
        appointment, data=request.data, partial=True
    )
    serializer.is_valid(raise_exception=True)

    appointment.status = Appointment.Status.COMPLETED
    appointment.completed_at = timezone.now()
    appointment.practitioner_notes = serializer.validated_data.get(
        'practitioner_notes', appointment.practitioner_notes
    )
    appointment.save(update_fields=['status', 'completed_at', 'practitioner_notes', 'updated_at'])

    return Response(
        AppointmentDetailSerializer(appointment, context={'request': request}).data
    )


@api_view(['PATCH'])
@permission_classes([IsAuthenticated, IsPractitioner])
def mark_no_show(request, pk):
    """
    PATCH /appointments/:id/no-show/
    Patient absent — le créneau est libéré pour une prochaine fois.
    """
    try:
        appointment = Appointment.objects.get(
            pk=pk,
            practitioner__user=request.user,
            status=Appointment.Status.CONFIRMED,
        )
    except Appointment.DoesNotExist:
        return Response({'error': 'Rendez-vous introuvable.'}, status=404)

    appointment.status = Appointment.Status.NO_SHOW
    appointment.save(update_fields=['status', 'updated_at'])

    return Response(
        AppointmentDetailSerializer(appointment, context={'request': request}).data
    )


# ─── Praticien ───────────────────────────────────────────────────────────────

class PractitionerAppointmentsView(generics.ListAPIView):
    """
    GET /appointments/practitioner/
    Agenda du praticien connecté.
    Filtres : status, date (YYYY-MM-DD), upcoming
    """
    serializer_class = AppointmentListSerializer
    permission_classes = [IsAuthenticated, IsPractitioner]

    def get_queryset(self):
        practitioner = self.request.user.practitioner_profile
        qs = Appointment.objects.filter(
            practitioner=practitioner
        ).select_related('patient', 'time_slot')

        status_filter = self.request.query_params.get('status')
        if status_filter:
            qs = qs.filter(status=status_filter)

        date_filter = self.request.query_params.get('date')
        if date_filter:
            qs = qs.filter(time_slot__date=date_filter)

        if self.request.query_params.get('upcoming') == 'true':
            today = timezone.localdate()
            qs = qs.filter(
                time_slot__date__gte=today,
                status__in=[Appointment.Status.PENDING, Appointment.Status.CONFIRMED],
            )

        return qs
