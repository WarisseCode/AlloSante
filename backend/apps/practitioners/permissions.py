from rest_framework.permissions import BasePermission


class IsPractitioner(BasePermission):
    """Autorise uniquement les utilisateurs avec le rôle 'practitioner'."""
    message = "Accès réservé aux praticiens."

    def has_permission(self, request, view):
        return (
            request.user
            and request.user.is_authenticated
            and request.user.role == 'practitioner'
        )


class IsAdmin(BasePermission):
    """Autorise uniquement les administrateurs."""
    message = "Accès réservé aux administrateurs."

    def has_permission(self, request, view):
        return (
            request.user
            and request.user.is_authenticated
            and request.user.role == 'admin'
        )
