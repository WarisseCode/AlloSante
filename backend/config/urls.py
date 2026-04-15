"""
AllôDoto — Routes principales de l'API
"""
from django.contrib import admin
from django.urls import path, include
from django.conf import settings
from django.conf.urls.static import static
from drf_spectacular.views import SpectacularAPIView, SpectacularSwaggerView

urlpatterns = [
    # Admin Django
    path('admin/', admin.site.urls),

    # Documentation API
    path('api/schema/', SpectacularAPIView.as_view(), name='schema'),
    path('api/docs/', SpectacularSwaggerView.as_view(url_name='schema'), name='swagger-ui'),

    # API v1
    path('api/v1/auth/', include('apps.users.urls')),
    path('api/v1/practitioners/', include('apps.practitioners.urls')),
    path('api/v1/appointments/', include('apps.appointments.urls')),
    path('api/v1/pharmacies/', include('apps.pharmacies.urls')),
    path('api/v1/medical-records/', include('apps.medical_records.urls')),
]

if settings.DEBUG:
    urlpatterns += static(settings.MEDIA_URL, document_root=settings.MEDIA_ROOT)
