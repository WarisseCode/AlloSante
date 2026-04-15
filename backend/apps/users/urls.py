from django.urls import path
from rest_framework_simplejwt.views import TokenRefreshView, TokenObtainPairView
from . import views

urlpatterns = [
    # Inscription & Vérification OTP
    path('register/', views.register, name='register'),
    path('verify-otp/', views.verify_otp, name='verify-otp'),
    path('resend-otp/', views.resend_otp, name='resend-otp'),

    # Connexion JWT
    path('login/', TokenObtainPairView.as_view(), name='token-obtain'),
    path('token/refresh/', TokenRefreshView.as_view(), name='token-refresh'),

    # Profil
    path('me/', views.MeView.as_view(), name='me'),
    path('me/patient-profile/', views.PatientProfileView.as_view(), name='patient-profile'),
]
