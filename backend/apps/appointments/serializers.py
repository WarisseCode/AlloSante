"""
AllôDoto — Sérialiseurs Rendez-vous
"""
from rest_framework import serializers
from .models import Appointment, AppointmentCancellation
from apps.practitioners.serializers import PractitionerListSerializer, TimeSlotSerializer
from apps.users.serializers import UserSerializer


class AppointmentBookSerializer(serializers.ModelSerializer):
    """Prise de rendez-vous par un patient."""

    class Meta:
        model = Appointment
        fields = ['time_slot', 'appointment_type', 'reason', 'patient_notes']

    def validate_time_slot(self, slot):
        if slot.status != 'available':
            raise serializers.ValidationError("Ce créneau n'est plus disponible.")
        return slot

    def validate(self, data):
        slot = data.get('time_slot')
        appt_type = data.get('appointment_type', Appointment.Type.IN_PERSON)
        if appt_type == Appointment.Type.TELECONSULTATION and not slot.is_teleconsultation:
            raise serializers.ValidationError(
                "Ce créneau n'est pas disponible en téléconsultation."
            )
        return data

    def create(self, validated_data):
        from django.utils import timezone
        from apps.practitioners.models import TimeSlot

        slot = validated_data['time_slot']
        patient = self.context['request'].user

        # Marquer le créneau comme réservé
        slot.status = TimeSlot.Status.BOOKED
        slot.save(update_fields=['status'])

        appointment = Appointment.objects.create(
            patient=patient,
            practitioner=slot.practitioner,
            **validated_data,
        )
        return appointment


class AppointmentListSerializer(serializers.ModelSerializer):
    """Vue allégée pour les listes (dashboard patient / praticien)."""
    practitioner_name = serializers.CharField(
        source='practitioner.display_name', read_only=True
    )
    practitioner_specialty = serializers.CharField(
        source='practitioner.specialty.name', read_only=True
    )
    practitioner_photo = serializers.SerializerMethodField()
    slot_date = serializers.DateField(source='time_slot.date', read_only=True)
    slot_start = serializers.TimeField(source='time_slot.start_time', read_only=True)
    slot_end = serializers.TimeField(source='time_slot.end_time', read_only=True)
    patient_name = serializers.CharField(source='patient.full_name', read_only=True)
    status_label = serializers.CharField(source='get_status_display', read_only=True)
    type_label = serializers.CharField(
        source='get_appointment_type_display', read_only=True
    )

    class Meta:
        model = Appointment
        fields = [
            'id', 'status', 'status_label', 'appointment_type', 'type_label',
            'practitioner_name', 'practitioner_specialty', 'practitioner_photo',
            'patient_name',
            'slot_date', 'slot_start', 'slot_end',
            'fee_at_booking', 'booked_at',
        ]

    def get_practitioner_photo(self, obj):
        request = self.context.get('request')
        if obj.practitioner.photo and request:
            return request.build_absolute_uri(obj.practitioner.photo.url)
        return None


class AppointmentDetailSerializer(serializers.ModelSerializer):
    """Vue complète d'un rendez-vous."""
    practitioner = PractitionerListSerializer(read_only=True)
    patient = UserSerializer(read_only=True)
    time_slot = TimeSlotSerializer(read_only=True)
    status_label = serializers.CharField(source='get_status_display', read_only=True)
    type_label = serializers.CharField(
        source='get_appointment_type_display', read_only=True
    )
    cancellation = serializers.SerializerMethodField()

    class Meta:
        model = Appointment
        fields = [
            'id', 'status', 'status_label', 'appointment_type', 'type_label',
            'practitioner', 'patient', 'time_slot',
            'reason', 'patient_notes',
            'fee_at_booking',
            'booked_at', 'confirmed_at', 'completed_at',
            'cancellation',
        ]

    def get_cancellation(self, obj):
        try:
            c = obj.cancellation
            return {
                'cancelled_by': c.cancelled_by,
                'reason': c.reason,
                'cancelled_at': c.cancelled_at,
            }
        except AppointmentCancellation.DoesNotExist:
            return None


class CancelAppointmentSerializer(serializers.Serializer):
    reason = serializers.CharField(required=False, allow_blank=True, default='')


class PractitionerNotesSerializer(serializers.ModelSerializer):
    """Le praticien ajoute ses observations après la consultation."""
    class Meta:
        model = Appointment
        fields = ['practitioner_notes']
