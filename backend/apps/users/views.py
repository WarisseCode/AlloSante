"""
AllôDoto — Vues authentification & profil utilisateur
"""
import random
import string
from datetime import timedelta

from django.utils import timezone
from django.contrib.auth import get_user_model
from rest_framework import status, generics
from rest_framework.decorators import api_view, permission_classes
from rest_framework.permissions import AllowAny, IsAuthenticated
from rest_framework.response import Response
from rest_framework_simplejwt.tokens import RefreshToken

from .models import OTPCode, PatientProfile
from .serializers import (
    RegisterSerializer, OTPVerifySerializer,
    UserSerializer, PatientProfileSerializer,
)
from django.conf import settings

User = get_user_model()


def generate_otp(length=6):
    return ''.join(random.choices(string.digits, k=length))


def send_otp_sms(phone_number, code):
    """Envoie le code OTP par SMS via Africa's Talking."""
    # TODO: intégrer Africa's Talking SDK
    # import africastalking
    # africastalking.initialize(settings.AT_USERNAME, settings.AT_API_KEY)
    # sms = africastalking.SMS
    # sms.send(f"AllôDoto: Votre code de vérification est {code}. Valable 10 minutes.", [phone_number])
    print(f"[SMS simulé] OTP {code} → {phone_number}")


@api_view(['POST'])
@permission_classes([AllowAny])
def register(request):
    """Inscription d'un nouvel utilisateur."""
    serializer = RegisterSerializer(data=request.data)
    if not serializer.is_valid():
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

    user = serializer.save()

    # Générer et envoyer l'OTP
    code = generate_otp()
    expires_at = timezone.now() + timedelta(minutes=settings.OTP_EXPIRY_MINUTES)
    OTPCode.objects.create(
        user=user,
        code=code,
        phone_number=user.phone_number,
        email=user.email,
        expires_at=expires_at,
    )
    if user.phone_number:
        send_otp_sms(user.phone_number, code)

    return Response(
        {
            'message': 'Compte créé. Vérifiez votre téléphone pour le code OTP.',
            'user_id': user.id,
        },
        status=status.HTTP_201_CREATED,
    )


@api_view(['POST'])
@permission_classes([AllowAny])
def verify_otp(request):
    """Vérification du code OTP."""
    serializer = OTPVerifySerializer(data=request.data)
    if not serializer.is_valid():
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

    data = serializer.validated_data
    code = data['code']

    # Trouver l'OTP correspondant
    filters = {'code': code, 'is_used': False}
    if data.get('phone_number'):
        filters['phone_number'] = data['phone_number']
    elif data.get('email'):
        filters['email'] = data['email']

    try:
        otp = OTPCode.objects.filter(**filters).latest('created_at')
    except OTPCode.DoesNotExist:
        return Response({'error': 'Code OTP invalide.'}, status=status.HTTP_400_BAD_REQUEST)

    if not otp.is_valid():
        return Response({'error': 'Code OTP expiré.'}, status=status.HTTP_400_BAD_REQUEST)

    # Marquer l'OTP comme utilisé et activer le compte
    otp.is_used = True
    otp.save()
    otp.user.is_verified = True
    otp.user.save()

    # Générer les tokens JWT
    refresh = RefreshToken.for_user(otp.user)
    return Response({
        'message': 'Compte vérifié avec succès.',
        'access': str(refresh.access_token),
        'refresh': str(refresh),
        'user': UserSerializer(otp.user).data,
    })


@api_view(['POST'])
@permission_classes([AllowAny])
def resend_otp(request):
    """Renvoi d'un code OTP."""
    phone_number = request.data.get('phone_number')
    email = request.data.get('email')

    if not phone_number and not email:
        return Response(
            {'error': 'Un numéro de téléphone ou un email est requis.'},
            status=status.HTTP_400_BAD_REQUEST,
        )

    try:
        if phone_number:
            user = User.objects.get(phone_number=phone_number)
        else:
            user = User.objects.get(email=email)
    except User.DoesNotExist:
        return Response({'error': 'Utilisateur introuvable.'}, status=status.HTTP_404_NOT_FOUND)

    code = generate_otp()
    expires_at = timezone.now() + timedelta(minutes=settings.OTP_EXPIRY_MINUTES)
    OTPCode.objects.create(
        user=user, code=code,
        phone_number=phone_number, email=email,
        expires_at=expires_at,
    )
    if phone_number:
        send_otp_sms(phone_number, code)

    return Response({'message': 'Nouveau code OTP envoyé.'})


class MeView(generics.RetrieveUpdateAPIView):
    """Profil de l'utilisateur connecté."""
    serializer_class = UserSerializer
    permission_classes = [IsAuthenticated]

    def get_object(self):
        return self.request.user


class PatientProfileView(generics.RetrieveUpdateAPIView):
    """Carnet de santé du patient connecté."""
    serializer_class = PatientProfileSerializer
    permission_classes = [IsAuthenticated]

    def get_object(self):
        profile, _ = PatientProfile.objects.get_or_create(user=self.request.user)
        return profile
