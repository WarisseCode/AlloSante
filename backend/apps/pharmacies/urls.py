from django.urls import path
from . import views

urlpatterns = [
    path('', views.PharmacyListView.as_view(), name='pharmacy-list'),
    path('on-duty/', views.OnDutyTodayView.as_view(), name='on-duty-today'),
    path('on-duty/create/', views.OnDutyCreateView.as_view(), name='on-duty-create'),
]
