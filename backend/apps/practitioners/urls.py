from django.urls import path
from . import views

urlpatterns = [
    # Spécialités
    path('specialties/', views.SpecialtyListView.as_view(), name='specialty-list'),

    # Annuaire (accès public)
    path('', views.PractitionerListView.as_view(), name='practitioner-list'),
    path('<int:pk>/', views.PractitionerDetailView.as_view(), name='practitioner-detail'),
    path('<int:pk>/slots/', views.PractitionerTimeSlotsView.as_view(), name='practitioner-slots'),
    path('<int:pk>/reviews/', views.PractitionerReviewsView.as_view(), name='practitioner-reviews'),
    path('<int:pk>/reviews/add/', views.LeaveReviewView.as_view(), name='leave-review'),

    # Gestion profil praticien (authentifié)
    path('me/', views.MyPractitionerProfileView.as_view(), name='my-practitioner-profile'),
    path('me/slots/', views.MyTimeSlotsView.as_view(), name='my-slots'),
    path('me/slots/<int:slot_id>/block/', views.block_time_slot, name='block-slot'),
    path('me/working-hours/', views.MyWorkingHoursView.as_view(), name='my-working-hours'),
]
