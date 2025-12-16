import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/widgets/primary_action_button.dart';

/// Écran de paiement sur place
class CashPaymentScreen extends StatelessWidget {
  final String appointmentId;
  final int amount;
  final String doctorName;
  final DateTime appointmentDate;

  const CashPaymentScreen({
    super.key,
    required this.appointmentId,
    required this.amount,
    required this.doctorName,
    required this.appointmentDate,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Paiement sur place'),
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
            
            // Résumé du rendez-vous
            _buildAppointmentSummary(context),
            
            const SizedBox(height: 32),
            
            // Instructions de paiement
            _buildPaymentInstructions(context),
            
            const SizedBox(height: 32),
            
            // Avantages du paiement sur place
            _buildBenefits(context),
            
            const SizedBox(height: 32),
            
            // Bouton de confirmation
            _buildConfirmButton(context),
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
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            color: AppColors.primaryLight.withValues(alpha: 0.2),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.payments_outlined,
            size: 50,
            color: AppColors.primary,
          ),
        ),
        
        const SizedBox(height: 24),
        
        // Titre
        Text(
          'Paiement sur place',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        
        const SizedBox(height: 8),
        
        Text(
          'Payez directement au cabinet médical',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: AppColors.textSecondary,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildAppointmentSummary(BuildContext context) {
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.receipt_long, color: AppColors.primary),
              const SizedBox(width: 8),
              Text(
                'Résumé du rendez-vous',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          _SummaryRow(
            label: 'Médecin',
            value: doctorName,
            icon: Icons.person,
          ),
          
          const SizedBox(height: 12),
          
          _SummaryRow(
            label: 'Date',
            value: '${appointmentDate.day}/${appointmentDate.month}/${appointmentDate.year}',
            icon: Icons.calendar_today,
          ),
          
          const SizedBox(height: 12),
          
          _SummaryRow(
            label: 'Heure',
            value: '${appointmentDate.hour}:${appointmentDate.minute.toString().padLeft(2, '0')}',
            icon: Icons.access_time,
          ),
          
          const SizedBox(height: 12),
          
          _SummaryRow(
            label: 'Montant',
            value: '${amount} FCFA',
            icon: Icons.attach_money,
            isBold: true,
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentInstructions(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      decoration: BoxDecoration(
        color: AppColors.infoLight,
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        border: Border.all(color: AppColors.info.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.info, color: AppColors.info),
              SizedBox(width: 8),
              Text(
                'Instructions de paiement',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppColors.info,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          const Text(
            '1. Présentez-vous au cabinet médical à l\'heure convenue\n'
            '2. Réglez le montant de ${amount} FCFA en espèces à la réception\n'
            '3. Conservez le reçu de paiement pour votre dossier\n'
            '4. Le médecin vous recevra après validation du paiement',
            style: TextStyle(
              color: AppColors.textSecondary,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBenefits(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Avantages du paiement sur place',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        
        const SizedBox(height: 16),
        
        const _BenefitCard(
          icon: Icons.lock,
          title: 'Sécurité',
          description: 'Aucune donnée bancaire en ligne requise',
        ),
        
        const SizedBox(height: 12),
        
        const _BenefitCard(
          icon: Icons.no_accounts,
          title: 'Pas de frais supplémentaires',
          description: 'Aucun frais de transaction ou commission',
        ),
        
        const SizedBox(height: 12),
        
        const _BenefitCard(
          icon: Icons.support_agent,
          title: 'Assistance directe',
          description: 'Personnel disponible pour vous aider en cas de problème',
        ),
      ],
    );
  }

  Widget _buildConfirmButton(BuildContext context) {
    return Column(
      children: [
        PrimaryActionButton(
          text: 'Confirmer le rendez-vous',
          onPressed: () {
            // TODO: Confirmer le rendez-vous avec paiement sur place
            _showConfirmationDialog(context);
          },
          icon: Icons.check_circle,
          backgroundColor: AppColors.success,
        ),
        
        const SizedBox(height: 16),
        
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text(
            'Choisir un autre mode de paiement',
            style: TextStyle(color: AppColors.primary),
          ),
        ),
      ],
    );
  }

  void _showConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmation'),
          content: const Text(
            'Êtes-vous sûr de vouloir confirmer ce rendez-vous avec paiement sur place ? '
            'Vous devrez régler ${amount} FCFA en espèces au cabinet médical.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Annuler'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _processCashPayment(context);
              },
              child: const Text(
                'Confirmer',
                style: TextStyle(color: AppColors.success),
              ),
            ),
          ],
        );
      },
    );
  }

  void _processCashPayment(BuildContext context) {
    // Simuler le traitement du paiement
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const Dialog(
          child: Padding(
            padding: EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(
                  color: AppColors.primary,
                ),
                SizedBox(height: 20),
                Text('Confirmation du rendez-vous...'),
              ],
            ),
          ),
        );
      },
    );
    
    // Simuler un délai de traitement
    Future.delayed(const Duration(seconds: 2), () {
      Navigator.of(context).pop(); // Fermer le dialogue de chargement
      
      // Montrer le succès
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Rendez-vous confirmé !'),
            content: const Text(
              'Votre rendez-vous avec $doctorName est confirmé. '
              'Vous recevrez un SMS de confirmation. '
              'N\'oubliez pas de régler ${amount} FCFA en espèces au cabinet.',
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Fermer l'alerte
                  Navigator.of(context).pop(); // Retour à l'écran précédent
                },
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
    });
  }
}

/// Widget pour afficher une ligne de résumé
class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final bool isBold;

  const _SummaryRow({
    required this.label,
    required this.value,
    required this.icon,
    this.isBold = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppColors.textSecondary),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(color: AppColors.textSecondary),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            color: isBold ? AppColors.primary : AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}

/// Widget pour afficher un avantage
class _BenefitCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;

  const _BenefitCard({
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusSmall),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.primaryLight.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppColors.primary, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}