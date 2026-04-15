from django.urls import path
from . import views

urlpatterns = [
    # Patient
    path('book/', views.BookAppointmentView.as_view(), name='book-appointment'),
    path('mine/', views.PatientAppointmentsView.as_view(), name='patient-appointments'),
    path('<int:pk>/', views.AppointmentDetailView.as_view(), name='appointment-detail'),

    # Actions (patient ou praticien)
    path('<int:pk>/cancel/', views.cancel_appointment, name='cancel-appointment'),

    # Actions praticien uniquement
    path('<int:pk>/confirm/', views.confirm_appointment, name='confirm-appointment'),
    path('<int:pk>/complete/', views.complete_appointment, name='complete-appointment'),
    path('<int:pk>/no-show/', views.mark_no_show, name='no-show'),

    # Agenda praticien
    path('practitioner/', views.PractitionerAppointmentsView.as_view(), name='practitioner-appointments'),
]
