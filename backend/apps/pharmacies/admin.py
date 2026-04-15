from django.contrib import admin
from .models import Pharmacy, OnDutySchedule


class OnDutyInline(admin.TabularInline):
    model = OnDutySchedule
    extra = 1
    fields = ['date', 'start_time', 'end_time', 'is_overnight', 'notes']


@admin.register(Pharmacy)
class PharmacyAdmin(admin.ModelAdmin):
    list_display = ['name', 'city', 'neighborhood', 'phone_number', 'status']
    list_filter = ['status', 'city']
    search_fields = ['name', 'neighborhood', 'phone_number']
    list_editable = ['status']
    inlines = [OnDutyInline]


@admin.register(OnDutySchedule)
class OnDutyScheduleAdmin(admin.ModelAdmin):
    list_display = ['pharmacy', 'date', 'start_time', 'end_time', 'is_overnight']
    list_filter = ['date', 'pharmacy__city']
    date_hierarchy = 'date'
    search_fields = ['pharmacy__name', 'pharmacy__neighborhood']
