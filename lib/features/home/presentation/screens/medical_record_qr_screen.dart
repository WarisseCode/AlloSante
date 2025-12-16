import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/widgets/primary_action_button.dart';

/// Écran d'affichage du QR Code du dossier médical
class MedicalRecordQrScreen extends StatelessWidget {
  final String patientId;
  final String patientName;
  final String qrData;

  const MedicalRecordQrScreen({
    super.key,
    required this.patientId,
    required this.patientName,
    required this.qrData,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Mon Dossier Médical'),
        centerTitle: true,
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppConstants.largePadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // En-tête
            _buildHeader(context),
            
            const SizedBox(height: 32),
            
            // QR Code
            _buildQrCode(context),
            
            const SizedBox(height: 32),
            
            // Informations du dossier
            _buildMedicalRecordInfo(context),
            
            const SizedBox(height: 32),
            
            // Instructions
            _buildInstructions(context),
            
            const SizedBox(height: 32),
            
            // Boutons d'action
            _buildActionButtons(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Column(
      children: [
        // Icône
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: AppColors.primaryLight.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Icon(
            Icons.folder_shared,
            size: 40,
            color: AppColors.primary,
          ),
        ),
        
        const SizedBox(height: 24),
        
        // Titre
        Text(
          'Dossier Médical Numérique',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        
        const SizedBox(height: 8),
        
        Text(
          'Accès rapide à vos informations médicales',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: AppColors.textSecondary,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildQrCode(BuildContext context) {
    return Column(
      children: [
        Text(
          'QR Code d\'accès',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        
        const SizedBox(height: 16),
        
        // Conteneur du QR Code
        Container(
          padding: const EdgeInsets.all(AppConstants.largePadding),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(AppConstants.borderRadius),
            boxShadow: [
              BoxShadow(
                color: AppColors.shadow,
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: QrImageView(
            data: qrData,
            version: QrVersions.auto,
            size: 250.0,
            gapless: false,
            errorStateBuilder: (context, error) {
              return Container(
                padding: const EdgeInsets.all(20),
                child: const Text(
                  'Impossible de générer le QR Code',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.error),
                ),
              );
            },
          ),
        ),
        
        const SizedBox(height: 16),
        
        // Identifiant du patient
        Container(
          padding: const EdgeInsets.all(AppConstants.defaultPadding),
          decoration: BoxDecoration(
            color: AppColors.backgroundGrey,
            borderRadius: BorderRadius.circular(AppConstants.borderRadiusSmall),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.person, color: AppColors.textSecondary),
              const SizedBox(width: 8),
              Text(
                'ID: $patientId',
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMedicalRecordInfo(BuildContext context) {
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
            'Contenu du dossier',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          
          const SizedBox(height: 16),
          
          const _InfoRow(
            icon: Icons.person,
            label: 'Nom du patient',
            value: 'Exemple de nom',
          ),
          
          const Divider(height: 24),
          
          const _InfoRow(
            icon: Icons.calendar_today,
            label: 'Date de naissance',
            value: '01/01/1990',
          ),
          
          const Divider(height: 24),
          
          const _InfoRow(
            icon: Icons.bloodtype,
            label: 'Groupe sanguin',
            value: 'O+',
          ),
          
          const Divider(height: 24),
          
          const _InfoRow(
            icon: Icons.medical_services,
            label: 'Allergies',
            value: 'Pénicilline, Arachides',
          ),
          
          const Divider(height: 24),
          
          const _InfoRow(
            icon: Icons.vaccines,
            label: 'Vaccinations',
            value: 'Complètes',
          ),
          
          const Divider(height: 24),
          
          const _InfoRow(
            icon: Icons.medication,
            label: 'Traitements en cours',
            value: 'Aucun',
          ),
        ],
      ),
    );
  }

  Widget _buildInstructions(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      decoration: BoxDecoration(
        color: AppColors.infoLight,
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        border: Border.all(color: AppColors.info.withValues(alpha: 0.3)),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info, color: AppColors.info),
              SizedBox(width: 8),
              Text(
                'Comment utiliser ce QR Code',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppColors.info,
                ),
              ),
            ],
          ),
          
          SizedBox(height: 12),
          
          Text(
            '1. Présentez ce QR Code lors de vos consultations médicales\n'
            '2. Les professionnels de santé peuvent le scanner pour accéder rapidement à vos informations médicales\n'
            '3. Gardez ce code confidentiel et ne le partagez qu\'avec des professionnels de confiance',
            style: TextStyle(
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Column(
      children: [
        PrimaryActionButton(
          text: 'Partager le QR Code',
          onPressed: () {
            // TODO: Implémenter le partage du QR Code
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Fonctionnalité de partage à implémenter'),
                backgroundColor: AppColors.info,
                behavior: SnackBarBehavior.floating,
              ),
            );
          },
          icon: Icons.share,
        ),
        
        const SizedBox(height: 12),
        
        SecondaryActionButton(
          text: 'Télécharger l\'image',
          onPressed: () {
            // TODO: Implémenter le téléchargement du QR Code
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Fonctionnalité de téléchargement à implémenter'),
                backgroundColor: AppColors.info,
                behavior: SnackBarBehavior.floating,
              ),
            );
          },
          icon: Icons.download,
        ),
      ],
    );
  }
}

/// Widget pour afficher une ligne d'information
class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({
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
              Text(
                value,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}