"""
AllôDoto — Vues Praticiens
Annuaire, fiche détail, créneaux, avis
"""
from django.utils import timezone
from django.db.models import Q
from rest_framework import generics, status, filters
from rest_framework.decorators import api_view, permission_classes
from rest_framework.permissions import IsAuthenticated, AllowAny
from rest_framework.response import Response

from .models import Specialty, Practitioner, TimeSlot, PractitionerReview, WorkingHours
from .serializers import (
    SpecialtySerializer,
    PractitionerListSerializer,
    PractitionerDetailSerializer,
    PractitionerProfileUpdateSerializer,
    TimeSlotSerializer,
    TimeSlotCreateSerializer,
    PractitionerReviewSerializer,
    WorkingHoursCreateSerializer,
)
from .permissions import IsPractitioner


# ─── Spécialités ────────────────────────────────────────────────────────────

class SpecialtyListView(generics.ListAPIView):
    """Liste de toutes les spécialités médicales actives."""
    serializer_class = SpecialtySerializer
    permission_classes = [AllowAny]
    queryset = Specialty.objects.filter(is_active=True)


# ─── Annuaire Praticiens ─────────────────────────────────────────────────────

class PractitionerListView(generics.ListAPIView):
    """
    Annuaire des praticiens actifs avec recherche et filtres.

    Paramètres de recherche :
    - `q` : nom, spécialité (recherche textuelle)
    - `specialty` : slug de la spécialité (ex: medecin-generaliste)
    - `city` : ville (ex: Cotonou)
    - `neighborhood` : quartier
    - `gender` : M / F
    - `max_fee` : tarif maximum en FCFA
    - `available_today` : true — uniquement avec créneaux aujourd'hui
    - `teleconsultation` : true — uniquement avec téléconsultation
    """
    serializer_class = PractitionerListSerializer
    permission_classes = [AllowAny]

    def get_queryset(self):
        qs = Practitioner.objects.filter(
            status=Practitioner.Status.ACTIVE
        ).select_related('user', 'specialty')

        params = self.request.query_params

        # Recherche textuelle
        q = params.get('q', '').strip()
        if q:
            qs = qs.filter(
                Q(user__first_name__icontains=q)
                | Q(user__last_name__icontains=q)
                | Q(specialty__name__icontains=q)
                | Q(cabinet_name__icontains=q)
                | Q(neighborhood__icontains=q)
            )

        # Filtres
        specialty = params.get('specialty')
        if specialty:
            qs = qs.filter(specialty__slug=specialty)

        city = params.get('city')
        if city:
            qs = qs.filter(city__icontains=city)

        neighborhood = params.get('neighborhood')
        if neighborhood:
            qs = qs.filter(neighborhood__icontains=neighborhood)

        gender = params.get('gender')
        if gender in ('M', 'F', 'O'):
            qs = qs.filter(gender=gender)

        max_fee = params.get('max_fee')
        if max_fee and max_fee.isdigit():
            qs = qs.filter(consultation_fee__lte=int(max_fee))

        if params.get('available_today') == 'true':
            today = timezone.localdate()
            qs = qs.filter(
                time_slots__date=today,
                time_slots__status=TimeSlot.Status.AVAILABLE,
            ).distinct()

        if params.get('teleconsultation') == 'true':
            qs = qs.filter(teleconsultation_fee__gt=0)

        return qs


class PractitionerDetailView(generics.RetrieveAPIView):
    """Fiche complète d'un praticien."""
    serializer_class = PractitionerDetailSerializer
    permission_classes = [AllowAny]
    queryset = Practitioner.objects.filter(
        status=Practitioner.Status.ACTIVE
    ).select_related('user', 'specialty').prefetch_related('working_hours')


# ─── Profil praticien (accès praticien authentifié) ──────────────────────────

class MyPractitionerProfileView(generics.RetrieveUpdateAPIView):
    """Le praticien consulte ou met à jour son propre profil."""
    permission_classes = [IsAuthenticated, IsPractitioner]

    def get_object(self):
        practitioner, _ = Practitioner.objects.get_or_create(user=self.request.user)
        return practitioner

    def get_serializer_class(self):
        if self.request.method in ('PUT', 'PATCH'):
            return PractitionerProfileUpdateSerializer
        return PractitionerDetailSerializer


# ─── Créneaux ────────────────────────────────────────────────────────────────

class PractitionerTimeSlotsView(generics.ListAPIView):
    """Créneaux disponibles d'un praticien (accès public)."""
    serializer_class = TimeSlotSerializer
    permission_classes = [AllowAny]

    def get_queryset(self):
        practitioner_id = self.kwargs['pk']
        today = timezone.localdate()

        date_from = self.request.query_params.get('date_from', str(today))
        date_to = self.request.query_params.get('date_to')

        qs = TimeSlot.objects.filter(
            practitioner_id=practitioner_id,
            status=TimeSlot.Status.AVAILABLE,
            date__gte=date_from,
        )
        if date_to:
            qs = qs.filter(date__lte=date_to)

        if self.request.query_params.get('teleconsultation') == 'true':
            qs = qs.filter(is_teleconsultation=True)

        return qs


class MyTimeSlotsView(generics.ListCreateAPIView):
    """Le praticien gère ses propres créneaux."""
    permission_classes = [IsAuthenticated, IsPractitioner]

    def get_serializer_class(self):
        if self.request.method == 'POST':
            return TimeSlotCreateSerializer
        return TimeSlotSerializer

    def get_queryset(self):
        practitioner = self.request.user.practitioner_profile
        return TimeSlot.objects.filter(
            practitioner=practitioner,
            date__gte=timezone.localdate(),
        )

    def perform_create(self, serializer):
        practitioner = self.request.user.practitioner_profile
        serializer.save(practitioner=practitioner)


@api_view(['PATCH'])
@permission_classes([IsAuthenticated, IsPractitioner])
def block_time_slot(request, slot_id):
    """Bloquer un créneau (le praticien ne sera pas disponible)."""
    try:
        slot = TimeSlot.objects.get(
            id=slot_id,
            practitioner=request.user.practitioner_profile,
        )
    except TimeSlot.DoesNotExist:
        return Response({'error': 'Créneau introuvable.'}, status=status.HTTP_404_NOT_FOUND)

    if slot.status == TimeSlot.Status.BOOKED:
        return Response(
            {'error': 'Impossible de bloquer un créneau déjà réservé.'},
            status=status.HTTP_400_BAD_REQUEST,
        )

    slot.status = TimeSlot.Status.BLOCKED
    slot.save()
    return Response(TimeSlotSerializer(slot).data)


# ─── Horaires hebdomadaires ──────────────────────────────────────────────────

class MyWorkingHoursView(generics.ListCreateAPIView):
    """Le praticien définit ses horaires hebdomadaires."""
    permission_classes = [IsAuthenticated, IsPractitioner]

    def get_serializer_class(self):
        if self.request.method == 'POST':
            return WorkingHoursCreateSerializer
        from .serializers import WorkingHoursSerializer
        return WorkingHoursSerializer

    def get_queryset(self):
        return WorkingHours.objects.filter(
            practitioner=self.request.user.practitioner_profile
        )

    def perform_create(self, serializer):
        practitioner = self.request.user.practitioner_profile
        serializer.save(practitioner=practitioner)


# ─── Avis ─────────────────────────────────────────────────────────────────

class PractitionerReviewsView(generics.ListAPIView):
    """Liste des avis sur un praticien (accès public)."""
    serializer_class = PractitionerReviewSerializer
    permission_classes = [AllowAny]

    def get_queryset(self):
        return PractitionerReview.objects.filter(
            practitioner_id=self.kwargs['pk']
        ).select_related('patient')


class LeaveReviewView(generics.CreateAPIView):
    """Un patient laisse un avis sur un praticien."""
    serializer_class = PractitionerReviewSerializer
    permission_classes = [IsAuthenticated]

    def perform_create(self, serializer):
        practitioner = generics.get_object_or_404(
            Practitioner, pk=self.kwargs['pk'], status=Practitioner.Status.ACTIVE
        )
        serializer.save(patient=self.request.user, practitioner=practitioner)
