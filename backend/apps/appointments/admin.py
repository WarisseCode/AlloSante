from django.contrib import admin
from .models import Appointment, AppointmentCancellation


class CancellationInline(admin.StackedInline):
    model = AppointmentCancellation
    extra = 0
    readonly_fields = ['cancelled_at']
    can_delete = False


@admin.register(Appointment)
class AppointmentAdmin(admin.ModelAdmin):
    list_display = [
        'id', 'patient_name', 'practitioner_name', 'slot_date',
        'appointment_type', 'status', 'fee_at_booking', 'booked_at',
    ]
    list_filter = ['status', 'appointment_type', 'time_slot__date']
    search_fields = [
        'patient__first_name', 'patient__last_name',
        'practitioner__user__last_name',
    ]
    readonly_fields = ['booked_at', 'confirmed_at', 'completed_at', 'fee_at_booking', 'updated_at']
    inlines = [CancellationInline]
    date_hierarchy = 'time_slot__date'

    def patient_name(self, obj):
        return obj.patient.full_name
    patient_name.short_description = 'Patient'

    def practitioner_name(self, obj):
        return obj.practitioner.display_name
    practitioner_name.short_description = 'Praticien'

    def slot_date(self, obj):
        return f"{obj.time_slot.date} {obj.time_slot.start_time}"
    slot_date.short_description = 'Date & Heure'


@admin.register(AppointmentCancellation)
class AppointmentCancellationAdmin(admin.ModelAdmin):
    list_display = ['appointment', 'cancelled_by', 'reason', 'cancelled_at']
    list_filter = ['cancelled_by']
    readonly_fields = ['cancelled_at']
