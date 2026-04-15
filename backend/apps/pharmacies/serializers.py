from rest_framework import serializers
from .models import Pharmacy, OnDutySchedule


class PharmacySerializer(serializers.ModelSerializer):
    class Meta:
        model = Pharmacy
        fields = [
            'id', 'name', 'phone_number', 'email',
            'address', 'city', 'neighborhood',
            'latitude', 'longitude',
            'opening_time', 'closing_time', 'is_open_sunday',
        ]


class OnDutyScheduleSerializer(serializers.ModelSerializer):
    pharmacy = PharmacySerializer(read_only=True)

    class Meta:
        model = OnDutySchedule
        fields = ['id', 'pharmacy', 'date', 'start_time', 'end_time', 'is_overnight', 'notes']


class OnDutyCreateSerializer(serializers.ModelSerializer):
    class Meta:
        model = OnDutySchedule
        fields = ['pharmacy', 'date', 'start_time', 'end_time', 'is_overnight', 'notes']
