from django.contrib import admin
from django.utils import timezone
from .models import Specialty, Practitioner, WorkingHours, TimeSlot, PractitionerReview


@admin.register(Specialty)
class SpecialtyAdmin(admin.ModelAdmin):
    list_display = ['name', 'slug', 'is_active', 'order']
    list_editable = ['is_active', 'order']
    prepopulated_fields = {'slug': ('name',)}
    search_fields = ['name']


@admin.register(Practitioner)
class PractitionerAdmin(admin.ModelAdmin):
    list_display = [
        'display_name', 'specialty', 'city', 'status',
        'consultation_fee', 'rating_average', 'review_count', 'created_at',
    ]
    list_filter = ['status', 'specialty', 'city', 'gender']
    search_fields = ['user__first_name', 'user__last_name', 'user__phone_number', 'license_number']
    readonly_fields = ['rating_average', 'review_count', 'created_at', 'updated_at']
    actions = ['validate_practitioners', 'suspend_practitioners']

    def display_name(self, obj):
        return obj.display_name
    display_name.short_description = 'Nom'

    def validate_practitioners(self, request, queryset):
        queryset.update(status=Practitioner.Status.ACTIVE, validated_at=timezone.now())
        self.message_user(request, f"{queryset.count()} praticien(s) validé(s).")
    validate_practitioners.short_description = "Valider les praticiens sélectionnés"

    def suspend_practitioners(self, request, queryset):
        queryset.update(status=Practitioner.Status.SUSPENDED)
        self.message_user(request, f"{queryset.count()} praticien(s) suspendu(s).")
    suspend_practitioners.short_description = "Suspendre les praticiens sélectionnés"


@admin.register(WorkingHours)
class WorkingHoursAdmin(admin.ModelAdmin):
    list_display = ['practitioner', 'get_day_of_week_display', 'start_time', 'end_time', 'is_active']
    list_filter = ['day_of_week', 'is_active']
    search_fields = ['practitioner__user__last_name']


@admin.register(TimeSlot)
class TimeSlotAdmin(admin.ModelAdmin):
    list_display = ['practitioner', 'date', 'start_time', 'end_time', 'status', 'is_teleconsultation']
    list_filter = ['status', 'date', 'is_teleconsultation']
    search_fields = ['practitioner__user__last_name']
    date_hierarchy = 'date'


@admin.register(PractitionerReview)
class PractitionerReviewAdmin(admin.ModelAdmin):
    list_display = ['practitioner', 'patient', 'rating', 'created_at']
    list_filter = ['rating']
    search_fields = ['practitioner__user__last_name', 'patient__last_name']
    readonly_fields = ['created_at']
