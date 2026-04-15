"""
AllôDoto — Sérialiseurs Praticiens
"""
from django.utils import timezone
from rest_framework import serializers
from .models import Specialty, Practitioner, WorkingHours, TimeSlot, PractitionerReview


class SpecialtySerializer(serializers.ModelSerializer):
    class Meta:
        model = Specialty
        fields = ['id', 'name', 'slug', 'description', 'icon']


class WorkingHoursSerializer(serializers.ModelSerializer):
    day_label = serializers.CharField(source='get_day_of_week_display', read_only=True)

    class Meta:
        model = WorkingHours
        fields = [
            'id', 'day_of_week', 'day_label',
            'start_time', 'end_time', 'slot_duration_minutes', 'is_active',
        ]


class PractitionerListSerializer(serializers.ModelSerializer):
    """Version allégée pour le listing/recherche."""
    full_name = serializers.CharField(source='display_name', read_only=True)
    specialty_name = serializers.CharField(source='specialty.name', read_only=True)
    photo_url = serializers.SerializerMethodField()
    languages_list = serializers.SerializerMethodField()
    is_available_today = serializers.SerializerMethodField()

    class Meta:
        model = Practitioner
        fields = [
            'id', 'full_name', 'title', 'specialty_name',
            'city', 'neighborhood', 'address',
            'consultation_fee', 'teleconsultation_fee',
            'photo_url', 'languages_list',
            'rating_average', 'review_count',
            'is_available_today',
            'latitude', 'longitude',
        ]

    def get_photo_url(self, obj):
        request = self.context.get('request')
        if obj.photo and request:
            return request.build_absolute_uri(obj.photo.url)
        return None

    def get_languages_list(self, obj):
        return obj.languages_list()

    def get_is_available_today(self, obj):
        today = timezone.localdate()
        return obj.time_slots.filter(date=today, status=TimeSlot.Status.AVAILABLE).exists()


class PractitionerDetailSerializer(serializers.ModelSerializer):
    """Version complète pour la fiche praticien."""
    full_name = serializers.CharField(source='display_name', read_only=True)
    specialty = SpecialtySerializer(read_only=True)
    working_hours = WorkingHoursSerializer(many=True, read_only=True)
    photo_url = serializers.SerializerMethodField()
    languages_list = serializers.SerializerMethodField()
    gender_label = serializers.CharField(source='get_gender_display', read_only=True)

    class Meta:
        model = Practitioner
        fields = [
            'id', 'full_name', 'title', 'specialty', 'bio',
            'years_experience', 'languages_list', 'gender_label',
            'cabinet_name', 'address', 'city', 'neighborhood',
            'latitude', 'longitude',
            'consultation_fee', 'teleconsultation_fee',
            'photo_url', 'working_hours',
            'rating_average', 'review_count',
        ]

    def get_photo_url(self, obj):
        request = self.context.get('request')
        if obj.photo and request:
            return request.build_absolute_uri(obj.photo.url)
        return None

    def get_languages_list(self, obj):
        return obj.languages_list()


class PractitionerProfileUpdateSerializer(serializers.ModelSerializer):
    """Mise à jour du profil par le praticien lui-même."""
    class Meta:
        model = Practitioner
        fields = [
            'title', 'bio', 'years_experience', 'languages', 'gender',
            'cabinet_name', 'address', 'city', 'neighborhood',
            'latitude', 'longitude',
            'consultation_fee', 'teleconsultation_fee',
            'license_number', 'license_document', 'photo',
        ]


class TimeSlotSerializer(serializers.ModelSerializer):
    class Meta:
        model = TimeSlot
        fields = [
            'id', 'date', 'start_time', 'end_time',
            'status', 'is_teleconsultation',
        ]
        read_only_fields = ['status']


class TimeSlotCreateSerializer(serializers.ModelSerializer):
    """Création de créneaux par le praticien."""
    class Meta:
        model = TimeSlot
        fields = ['date', 'start_time', 'end_time', 'is_teleconsultation', 'notes']

    def validate(self, data):
        if data['start_time'] >= data['end_time']:
            raise serializers.ValidationError(
                "L'heure de fin doit être après l'heure de début."
            )
        if data['date'] < timezone.localdate():
            raise serializers.ValidationError(
                "Impossible de créer un créneau dans le passé."
            )
        return data


class PractitionerReviewSerializer(serializers.ModelSerializer):
    patient_name = serializers.CharField(source='patient.full_name', read_only=True)

    class Meta:
        model = PractitionerReview
        fields = ['id', 'patient_name', 'rating', 'comment', 'created_at']
        read_only_fields = ['id', 'patient_name', 'created_at']

    def validate_rating(self, value):
        if not 1 <= value <= 5:
            raise serializers.ValidationError("La note doit être entre 1 et 5.")
        return value


class WorkingHoursCreateSerializer(serializers.ModelSerializer):
    class Meta:
        model = WorkingHours
        fields = ['day_of_week', 'start_time', 'end_time', 'slot_duration_minutes']

    def validate(self, data):
        if data['start_time'] >= data['end_time']:
            raise serializers.ValidationError(
                "L'heure de fin doit être après l'heure de début."
            )
        return data
