from django.contrib import admin
from django.contrib.auth.admin import UserAdmin as BaseUserAdmin
from .models import User, OTPCode, PatientProfile


@admin.register(User)
class UserAdmin(BaseUserAdmin):
    list_display = ['phone_number', 'email', 'full_name', 'role', 'is_verified', 'is_active']
    list_filter = ['role', 'is_verified', 'is_active']
    search_fields = ['phone_number', 'email', 'first_name', 'last_name']
    ordering = ['-date_joined']
    fieldsets = (
        (None, {'fields': ('phone_number', 'email', 'password')}),
        ('Informations', {'fields': ('first_name', 'last_name', 'role')}),
        ('Statut', {'fields': ('is_active', 'is_verified', 'is_staff', 'is_superuser')}),
    )
    add_fieldsets = (
        (None, {
            'classes': ('wide',),
            'fields': ('phone_number', 'email', 'first_name', 'last_name', 'role', 'password1', 'password2'),
        }),
    )


@admin.register(OTPCode)
class OTPCodeAdmin(admin.ModelAdmin):
    list_display = ['user', 'code', 'phone_number', 'is_used', 'created_at', 'expires_at']
    list_filter = ['is_used']


@admin.register(PatientProfile)
class PatientProfileAdmin(admin.ModelAdmin):
    list_display = ['user', 'date_of_birth', 'blood_group']
    search_fields = ['user__first_name', 'user__last_name', 'user__phone_number']
