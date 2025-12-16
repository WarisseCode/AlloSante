import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/widgets/primary_action_button.dart';
import '../../domain/entities/doctor.dart';
import 'booking_screen.dart';

/// Écran de détail d'un médecin
class DoctorDetailScreen extends StatelessWidget {
  final Doctor doctor;

  const DoctorDetailScreen({super.key, required this.doctor});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // En-tête avec photo et infos principales
            _buildHeader(context),

            const SizedBox(height: 24),

            // Informations détaillées
            _buildDetailsSection(context),

            const SizedBox(height: 24),

            // Disponibilités
            _buildAvailabilitySection(context),

            const SizedBox(height: 24),

            // Langues parlées
            _buildLanguagesSection(context),

            const SizedBox(height: 24),

            // Bouton de prise de rendez-vous
            _buildBookAppointmentButton(context),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.largePadding),
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Photo du médecin
          CircleAvatar(
            radius: 50,
            backgroundColor: AppColors.primaryLight,
            child: Text(
              doctor.initials,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),

          const SizedBox(width: 16),

          // Informations principales
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  doctor.fullName,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  doctor.specialty,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 16,
                  ),
                ),

                const SizedBox(height: 8),

                // Note et expérience
                Row(
                  children: [
                    const Icon(Icons.star, size: 18, color: Colors.amber),
                    const SizedBox(width: 4),
                    Text(
                      doctor.formattedRating,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${doctor.reviewCount} avis',
                      style: const TextStyle(color: AppColors.textSecondary),
                    ),
                  ],
                ),

                const SizedBox(height: 4),

                Row(
                  children: [
                    const Icon(
                      Icons.work_outline,
                      size: 18,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${doctor.experienceYears} ans d\'expérience',
                      style: const TextStyle(color: AppColors.textSecondary),
                    ),
                  ],
                ),

                const SizedBox(height: 4),

                Row(
                  children: [
                    const Icon(
                      Icons.location_on,
                      size: 18,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      doctor.location,
                      style: const TextStyle(color: AppColors.textSecondary),
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

  Widget _buildDetailsSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      margin: const EdgeInsets.symmetric(
        horizontal: AppConstants.defaultPadding,
      ),
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
          Text('À propos', style: Theme.of(context).textTheme.titleLarge),

          const SizedBox(height: 12),

          Text(
            'Dr. ${doctor.lastName} est un professionnel de santé qualifié avec une expertise approfondie en ${doctor.specialty.toLowerCase()}. Avec ${doctor.experienceYears} ans d\'expérience, il/elle s\'engage à fournir des soins de qualité à ses patients.',
            style: const TextStyle(color: AppColors.textSecondary, height: 1.5),
          ),

          const SizedBox(height: 16),

          // Tarif de consultation
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primaryLight.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(
                AppConstants.borderRadiusSmall,
              ),
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Tarif de consultation',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                Text(
                  doctor.formattedPrice,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvailabilitySection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      margin: const EdgeInsets.symmetric(
        horizontal: AppConstants.defaultPadding,
      ),
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
          Text('Disponibilités', style: Theme.of(context).textTheme.titleLarge),

          const SizedBox(height: 16),

          // Jours disponibles
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _AvailabilityChip(
                day: 'Lun',
                isAvailable: doctor.availableDays.contains('Lundi'),
              ),
              _AvailabilityChip(
                day: 'Mar',
                isAvailable: doctor.availableDays.contains('Mardi'),
              ),
              _AvailabilityChip(
                day: 'Mer',
                isAvailable: doctor.availableDays.contains('Mercredi'),
              ),
              _AvailabilityChip(
                day: 'Jeu',
                isAvailable: doctor.availableDays.contains('Jeudi'),
              ),
              _AvailabilityChip(
                day: 'Ven',
                isAvailable: doctor.availableDays.contains('Vendredi'),
              ),
              _AvailabilityChip(
                day: 'Sam',
                isAvailable: doctor.availableDays.contains('Samedi'),
              ),
              _AvailabilityChip(
                day: 'Dim',
                isAvailable: doctor.availableDays.contains('Dimanche'),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Horaires typiques
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.backgroundGrey,
              borderRadius: BorderRadius.circular(
                AppConstants.borderRadiusSmall,
              ),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [Text('Horaires habituels'), Text('08:00 - 17:00')],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLanguagesSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      margin: const EdgeInsets.symmetric(
        horizontal: AppConstants.defaultPadding,
      ),
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
            'Langues parlées',
            style: Theme.of(context).textTheme.titleLarge,
          ),

          const SizedBox(height: 12),

          Wrap(
            spacing: 8,
            children: doctor.languages
                .map((language) => _LanguageChip(language: language))
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildBookAppointmentButton(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.largePadding,
      ),
      child: PrimaryActionButton(
        text: 'Prendre un rendez-vous',
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => BookingScreen(doctor: doctor),
            ),
          );
        },
        icon: Icons.calendar_today,
      ),
    );
  }
}

/// Chip pour afficher la disponibilité d'un jour
class _AvailabilityChip extends StatelessWidget {
  final String day;
  final bool isAvailable;

  const _AvailabilityChip({required this.day, required this.isAvailable});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isAvailable ? AppColors.successLight : AppColors.errorLight,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isAvailable ? AppColors.success : AppColors.error,
        ),
      ),
      child: Text(
        day,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          color: isAvailable ? AppColors.success : AppColors.error,
        ),
      ),
    );
  }
}

/// Chip pour afficher une langue
class _LanguageChip extends StatelessWidget {
  final String language;

  const _LanguageChip({required this.language});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.primaryLight.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
      ),
      child: Text(
        language,
        style: const TextStyle(
          fontWeight: FontWeight.w500,
          color: AppColors.primary,
        ),
      ),
    );
  }
}
