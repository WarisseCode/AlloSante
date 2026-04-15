from django.urls import path
from . import views

urlpatterns = [
    # Ordonnances
    path('prescriptions/', views.PatientPrescriptionsView.as_view(), name='prescriptions'),
    path('prescriptions/create/', views.CreatePrescriptionView.as_view(), name='create-prescription'),
    path('prescriptions/<int:pk>/', views.PrescriptionDetailView.as_view(), name='prescription-detail'),

    # Documents médicaux
    path('documents/', views.MedicalDocumentsView.as_view(), name='medical-documents'),
    path('documents/<int:pk>/', views.MedicalDocumentDeleteView.as_view(), name='delete-document'),

    # Rappels médicaments
    path('reminders/', views.MedicationRemindersView.as_view(), name='reminders'),
    path('reminders/<int:pk>/', views.MedicationReminderDetailView.as_view(), name='reminder-detail'),
]
