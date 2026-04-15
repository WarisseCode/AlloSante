"""
AllôDoto — Sérialiseurs Users
"""
from django.contrib.auth import get_user_model
from rest_framework import serializers
from .models import PatientProfile

User = get_user_model()


class RegisterSerializer(serializers.ModelSerializer):
    """Inscription via numéro de téléphone ou email."""
    password = serializers.CharField(write_only=True, min_length=8)

    class Meta:
        model = User
        fields = ['phone_number', 'email', 'first_name', 'last_name', 'role', 'password']
        extra_kwargs = {
            'role': {'default': User.Role.PATIENT},
        }

    def validate(self, data):
        if not data.get('phone_number') and not data.get('email'):
            raise serializers.ValidationError(
                "Un numéro de téléphone ou un email est requis."
            )
        return data

    def create(self, validated_data):
        password = validated_data.pop('password')
        user = User(**validated_data)
        user.set_password(password)
        user.is_verified = False
        user.save()
        if user.role == User.Role.PATIENT:
            PatientProfile.objects.create(user=user)
        return user


class OTPVerifySerializer(serializers.Serializer):
    phone_number = serializers.CharField(required=False, allow_blank=True)
    email = serializers.EmailField(required=False, allow_blank=True)
    code = serializers.CharField(max_length=6, min_length=6)

    def validate(self, data):
        if not data.get('phone_number') and not data.get('email'):
            raise serializers.ValidationError(
                "Un numéro de téléphone ou un email est requis."
            )
        return data


class UserSerializer(serializers.ModelSerializer):
    full_name = serializers.ReadOnlyField()

    class Meta:
        model = User
        fields = [
            'id', 'phone_number', 'email', 'first_name', 'last_name',
            'full_name', 'role', 'is_verified', 'date_joined',
        ]
        read_only_fields = ['id', 'role', 'is_verified', 'date_joined']


class PatientProfileSerializer(serializers.ModelSerializer):
    user = UserSerializer(read_only=True)

    class Meta:
        model = PatientProfile
        fields = [
            'user', 'date_of_birth', 'blood_group',
            'known_allergies', 'chronic_conditions',
            'emergency_contact_name', 'emergency_contact_phone',
        ]
