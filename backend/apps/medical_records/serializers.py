from rest_framework import serializers
from .models import Prescription, PrescriptionItem, MedicalDocument, MedicationReminder


class PrescriptionItemSerializer(serializers.ModelSerializer):
    class Meta:
        model = PrescriptionItem
        fields = ['id', 'medication_name', 'dosage', 'frequency', 'duration_days', 'instructions']


class PrescriptionSerializer(serializers.ModelSerializer):
    items = PrescriptionItemSerializer(many=True, read_only=True)
    practitioner_name = serializers.CharField(
        source='practitioner.display_name', read_only=True
    )
    pdf_url = serializers.SerializerMethodField()

    class Meta:
        model = Prescription
        fields = [
            'id', 'appointment', 'practitioner_name',
            'diagnosis', 'instructions', 'follow_up_date',
            'items', 'pdf_url', 'created_at',
        ]

    def get_pdf_url(self, obj):
        request = self.context.get('request')
        if obj.pdf_file and request:
            return request.build_absolute_uri(obj.pdf_file.url)
        return None


class PrescriptionCreateSerializer(serializers.ModelSerializer):
    items = PrescriptionItemSerializer(many=True)

    class Meta:
        model = Prescription
        fields = ['appointment', 'diagnosis', 'instructions', 'follow_up_date', 'items']

    def create(self, validated_data):
        items_data = validated_data.pop('items')
        prescription = Prescription.objects.create(**validated_data)
        for item in items_data:
            PrescriptionItem.objects.create(prescription=prescription, **item)
        return prescription


class MedicalDocumentSerializer(serializers.ModelSerializer):
    file_url = serializers.SerializerMethodField()
    type_label = serializers.CharField(source='get_document_type_display', read_only=True)

    class Meta:
        model = MedicalDocument
        fields = [
            'id', 'document_type', 'type_label', 'title',
            'file', 'file_url', 'document_date', 'notes', 'uploaded_at',
        ]
        extra_kwargs = {'file': {'write_only': True}}

    def get_file_url(self, obj):
        request = self.context.get('request')
        if obj.file and request:
            return request.build_absolute_uri(obj.file.url)
        return None


class MedicationReminderSerializer(serializers.ModelSerializer):
    frequency_label = serializers.CharField(source='get_frequency_display', read_only=True)

    class Meta:
        model = MedicationReminder
        fields = [
            'id', 'medication_name', 'dosage',
            'frequency', 'frequency_label', 'reminder_times',
            'start_date', 'end_date', 'is_active',
        ]
