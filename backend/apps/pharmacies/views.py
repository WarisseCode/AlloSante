"""
AllôDoto — Vues Pharmacies
"""
from django.utils import timezone
from django.db.models import Q
from rest_framework import generics
from rest_framework.permissions import AllowAny, IsAuthenticated

from apps.practitioners.permissions import IsAdmin
from .models import Pharmacy, OnDutySchedule
from .serializers import PharmacySerializer, OnDutyScheduleSerializer, OnDutyCreateSerializer


class PharmacyListView(generics.ListAPIView):
    """
    GET /pharmacies/
    Liste des pharmacies actives.
    Filtres : city, neighborhood, q (nom)
    """
    serializer_class = PharmacySerializer
    permission_classes = [AllowAny]

    def get_queryset(self):
        qs = Pharmacy.objects.filter(status=Pharmacy.Status.ACTIVE)
        params = self.request.query_params

        q = params.get('q', '').strip()
        if q:
            qs = qs.filter(Q(name__icontains=q) | Q(neighborhood__icontains=q))

        if city := params.get('city'):
            qs = qs.filter(city__icontains=city)

        if neighborhood := params.get('neighborhood'):
            qs = qs.filter(neighborhood__icontains=neighborhood)

        return qs


class OnDutyTodayView(generics.ListAPIView):
    """
    GET /pharmacies/on-duty/
    Pharmacies de garde du jour (ou d'une date donnée).
    Filtre : date=YYYY-MM-DD, city, neighborhood
    """
    serializer_class = OnDutyScheduleSerializer
    permission_classes = [AllowAny]

    def get_queryset(self):
        date_param = self.request.query_params.get('date')
        try:
            from datetime import date
            target_date = date.fromisoformat(date_param) if date_param else timezone.localdate()
        except ValueError:
            target_date = timezone.localdate()

        qs = OnDutySchedule.objects.filter(
            date=target_date,
            pharmacy__status=Pharmacy.Status.ACTIVE,
        ).select_related('pharmacy')

        if city := self.request.query_params.get('city'):
            qs = qs.filter(pharmacy__city__icontains=city)

        if neighborhood := self.request.query_params.get('neighborhood'):
            qs = qs.filter(pharmacy__neighborhood__icontains=neighborhood)

        return qs


class OnDutyCreateView(generics.CreateAPIView):
    """
    POST /pharmacies/on-duty/create/
    Création d'une plage de garde (admin uniquement).
    """
    serializer_class = OnDutyCreateSerializer
    permission_classes = [IsAuthenticated, IsAdmin]
