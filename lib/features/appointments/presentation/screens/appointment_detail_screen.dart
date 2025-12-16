import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/widgets/primary_action_button.dart';
import '../../domain/entities/appointment.dart';
import '../../domain/entities/doctor.dart';

/// Écran de détail d'un rendez-vous
class AppointmentDetailScreen extends StatelessWidget {
  final Appointment appointment;

  const AppointmentDetailScreen({super.key, required this.appointment});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Détail du rendez-vous'),
        centerTitle: true,
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () {
              // TODO: Options supplémentaires (partager, exporter, etc.)
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Options supplémentaires à implémenter'),
                  backgroundColor: AppColors.info,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppConstants.largePadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // En-tête avec statut
            _buildHeader(context),

            const SizedBox(height: 24),

            // Informations du médecin
            _buildDoctorInfo(context),

            const SizedBox(height: 24),

            // Détails du rendez-vous
            _buildAppointmentDetails(context),

            const SizedBox(height: 24),

            // Actions possibles
            _buildActions(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    // Déterminer le statut et la couleur appropriés
    Color statusColor;
    String statusText;
    IconData statusIcon;

    switch (appointment.status) {
      case AppointmentStatus.confirmed:
        statusColor = AppColors.success;
        statusText = 'Confirmé';
        statusIcon = Icons.check_circle;
        break;
      case AppointmentStatus.pending:
        statusColor = AppColors.warning;
        statusText = 'En attente';
        statusIcon = Icons.pending;
        break;
      case AppointmentStatus.cancelled:
        statusColor = AppColors.error;
        statusText = 'Annulé';
        statusIcon = Icons.cancel;
        break;
      case AppointmentStatus.completed:
        statusColor = AppColors.info;
        statusText = 'Terminé';
        statusIcon = Icons.done_all;
        break;
      default:
        statusColor = AppColors.textSecondary;
        statusText = 'Inconnu';
        statusIcon = Icons.help;
    }

    return Container(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'Rendez-vous #${appointment.id.length > 8 ? appointment.id.substring(0, 8) : appointment.id}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: statusColor.withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    Icon(statusIcon, size: 16, color: statusColor),
                    const SizedBox(width: 4),
                    Text(
                      statusText,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: statusColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Date et heure
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primaryLight.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(
                AppConstants.borderRadiusSmall,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Column(
                  children: [
                    const Icon(Icons.calendar_today, color: AppColors.primary),
                    const SizedBox(height: 8),
                    Text(
                      _formatDate(appointment.appointmentDate),
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
                Container(width: 1, height: 40, color: AppColors.border),
                Column(
                  children: [
                    const Icon(Icons.access_time, color: AppColors.primary),
                    const SizedBox(height: 8),
                    Text(
                      appointment.timeSlot,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDoctorInfo(BuildContext context) {
    // Vérifier si le médecin existe
    final doctor = appointment.doctor;

    return Container(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Médecin',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 12),

          Row(
            children: [
              // Avatar du médecin
              CircleAvatar(
                radius: 30,
                backgroundColor: AppColors.primaryLight,
                child: Text(
                  doctor?.initials ?? '?',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),

              const SizedBox(width: 12),

              // Informations du médecin
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      doctor?.fullName ?? 'Médecin inconnu',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      doctor?.specialty ?? 'Spécialité inconnue',
                      style: const TextStyle(color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),

              // Note
              if (doctor != null)
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.amber.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.star, size: 16, color: Colors.amber),
                      const SizedBox(width: 4),
                      Text(
                        doctor.formattedRating,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAppointmentDetails(BuildContext context) {
    // Vérifier si le médecin existe
    final doctor = appointment.doctor;

    return Container(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Détails du rendez-vous',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 16),

          _DetailRow(
            icon: Icons.location_on,
            label: 'Lieu',
            value: doctor?.location ?? 'Lieu non spécifié',
          ),

          const SizedBox(height: 12),

          _DetailRow(
            icon: Icons.money,
            label: 'Coût de consultation',
            value: doctor?.formattedPrice ?? 'Prix non spécifié',
          ),

          const SizedBox(height: 12),

          _DetailRow(
            icon: Icons.note,
            label: 'Notes',
            value: appointment.notes?.isNotEmpty == true
                ? appointment.notes!
                : 'Aucune note spécifiée',
          ),
        ],
      ),
    );
  }

  Widget _buildActions(BuildContext context) {
    return Column(
      children: [
        // Actions selon le statut
        if (appointment.status == AppointmentStatus.confirmed) ...[
          PrimaryActionButton(
            text: 'Ajouter au calendrier',
            onPressed: () {
              // TODO: Ajouter au calendrier système
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Fonctionnalité calendrier à implémenter'),
                  backgroundColor: AppColors.info,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            icon: Icons.calendar_today,
          ),

          const SizedBox(height: 12),

          SecondaryActionButton(
            text: 'Obtenir les directions',
            onPressed: () {
              // TODO: Ouvrir Maps avec directions
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Directions vers le cabinet à implémenter'),
                  backgroundColor: AppColors.info,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            icon: Icons.directions,
          ),

          const SizedBox(height: 12),
        ],

        // Annulation (sauf pour les rendez-vous terminés ou annulés)
        if (appointment.status != AppointmentStatus.completed &&
            appointment.status != AppointmentStatus.cancelled) ...[
          SecondaryActionButton(
            text: 'Annuler le rendez-vous',
            onPressed: () => _showCancelDialog(context),
            icon: Icons.cancel,
            borderColor: AppColors.error,
            textColor: AppColors.error,
          ),
        ],
      ],
    );
  }

  void _showCancelDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Annuler le rendez-vous'),
          content: const Text(
            'Êtes-vous sûr de vouloir annuler ce rendez-vous ? '
            'Selon la politique de l\'établissement, des frais d\'annulation peuvent s\'appliquer.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Retour'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                // TODO: Implémenter l'annulation
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Annulation du rendez-vous à implémenter'),
                    backgroundColor: AppColors.info,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
              child: const Text(
                'Annuler',
                style: TextStyle(color: AppColors.error),
              ),
            ),
          ],
        );
      },
    );
  }

  String _formatDate(DateTime date) {
    final months = [
      'Jan',
      'Fév',
      'Mar',
      'Avr',
      'Mai',
      'Jun',
      'Jul',
      'Aoû',
      'Sep',
      'Oct',
      'Nov',
      'Déc',
    ];

    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }
}

/// Widget pour afficher une ligne de détail
class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: AppColors.textSecondary),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 4),
              Text(value, style: const TextStyle(color: AppColors.textPrimary)),
            ],
          ),
        ),
      ],
    );
  }
}
