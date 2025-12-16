import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/widgets/primary_action_button.dart';
import '../../../../core/widgets/secure_input_field.dart';
import '../../../appointments/domain/entities/appointment.dart';
import '../../data/repositories/payment_repository.dart';
import '../providers/payment_provider.dart';
import 'cash_payment_screen.dart';

/// Écran de paiement Mobile Money
/// Permet de sélectionner MTN MoMo ou Celtiis Cash
class MobileMoneyPaymentScreen extends StatefulWidget {
  final String appointmentId;
  final int amount;
  final String doctorName;

  const MobileMoneyPaymentScreen({
    super.key,
    required this.appointmentId,
    required this.amount,
    required this.doctorName,
  });

  @override
  State<MobileMoneyPaymentScreen> createState() => _MobileMoneyPaymentScreenState();
}

class _MobileMoneyPaymentScreenState extends State<MobileMoneyPaymentScreen> {
  final _phoneController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PaymentProvider>().startPaymentFlow();
    });
  }

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Paiement'),
        centerTitle: true,
      ),
      body: Consumer<PaymentProvider>(
        builder: (context, provider, _) {
          return AnimatedSwitcher(
            duration: AppConstants.animationNormal,
            child: _buildContent(provider),
          );
        },
      ),
    );
  }

  Widget _buildContent(PaymentProvider provider) {
    switch (provider.status) {
      case PaymentFlowStatus.initial:
      case PaymentFlowStatus.selectingMethod:
        return _buildMethodSelection(provider);
        
      case PaymentFlowStatus.enteringPhone:
        return _buildPhoneEntry(provider);
        
      case PaymentFlowStatus.processing:
        return _buildProcessing();
        
      case PaymentFlowStatus.awaitingConfirmation:
        return _buildAwaitingConfirmation(provider);
        
      case PaymentFlowStatus.success:
        return _buildSuccess(provider);
        
      case PaymentFlowStatus.failed:
      case PaymentFlowStatus.expired:
        return _buildFailure(provider);
        
      case PaymentFlowStatus.cancelled:
        return _buildCancelled(provider);
    }
  }

  /// Sélection de la méthode de paiement
  Widget _buildMethodSelection(PaymentProvider provider) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppConstants.largePadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Résumé de la commande
          _buildOrderSummary(),
          
          const SizedBox(height: 32),
          
          // Titre section
          Text(
            'Choisissez votre mode de paiement',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          
          const SizedBox(height: 16),
          
          // MTN MoMo
          _PaymentMethodCard(
            method: PaymentMethod.mtnMomo,
            title: 'MTN MoMo',
            subtitle: 'Paiement via Mobile Money MTN',
            primaryColor: AppColors.mtnYellow,
            secondaryColor: AppColors.mtnBlue,
            iconData: Icons.phone_android,
            isSelected: provider.selectedMethod == PaymentMethod.mtnMomo,
            onTap: () => provider.selectPaymentMethod(PaymentMethod.mtnMomo),
          ),
          
          const SizedBox(height: 12),
          
          // Celtiis Cash
          _PaymentMethodCard(
            method: PaymentMethod.celtiisCash,
            title: 'Celtiis Cash',
            subtitle: 'Paiement via Celtiis Mobile Money',
            primaryColor: AppColors.celtiisGreen,
            secondaryColor: Colors.white,
            iconData: Icons.phone_android,
            isSelected: provider.selectedMethod == PaymentMethod.celtiisCash,
            onTap: () => provider.selectPaymentMethod(PaymentMethod.celtiisCash),
          ),
          
          const SizedBox(height: 12),
          
          // Paiement sur place (si disponible)
          _PaymentMethodCard(
            method: PaymentMethod.cash,
            title: 'Paiement sur place',
            subtitle: 'Payer lors de la consultation',
            primaryColor: AppColors.textSecondary,
            secondaryColor: Colors.white,
            iconData: Icons.payments_outlined,
            isSelected: provider.selectedMethod == PaymentMethod.cash,
            onTap: () {
              // Naviguer vers l'écran de paiement sur place
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CashPaymentScreen(
                    appointmentId: widget.appointmentId,
                    amount: widget.amount,
                    doctorName: widget.doctorName,
                    appointmentDate: DateTime.now().add(const Duration(days: 1)), // Exemple de date
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  /// Saisie du numéro de téléphone
  Widget _buildPhoneEntry(PaymentProvider provider) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppConstants.largePadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header avec méthode sélectionnée
          _buildSelectedMethodHeader(provider),
          
          const SizedBox(height: 32),
          
          // Résumé du montant
          _buildAmountSummary(),
          
          const SizedBox(height: 32),
          
          // Champ de saisie du numéro
          Text(
            'Entrez votre numéro ${provider.selectedMethod?.displayName ?? ""}',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          
          const SizedBox(height: 16),
          
          BeninPhoneField(
            controller: _phoneController,
            label: 'Numéro de téléphone',
            hint: _getPhoneHint(provider.selectedMethod),
            onChanged: (value) => provider.updatePhoneNumber(value),
            errorText: provider.errorMessage,
          ),
          
          const SizedBox(height: 8),
          
          // Info sur les préfixes
          _buildPrefixInfo(provider.selectedMethod),
          
          const SizedBox(height: 32),
          
          // Bouton de paiement
          PrimaryActionButton(
            text: 'Payer ${widget.amount} FCFA',
            onPressed: () async {
              final success = await provider.initiatePayment(
                appointmentId: widget.appointmentId,
                amount: widget.amount,
              );
              
              if (!success && mounted) {
                // L'erreur est affichée via provider.errorMessage
              }
            },
            icon: Icons.lock,
          ),
          
          const SizedBox(height: 16),
          
          // Bouton retour
          TextButton.icon(
            onPressed: () => provider.changePaymentMethod(),
            icon: const Icon(Icons.arrow_back),
            label: const Text('Changer de mode de paiement'),
          ),
        ],
      ),
    );
  }

  /// Écran de traitement
  Widget _buildProcessing() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(
            color: AppColors.primary,
            strokeWidth: 3,
          ),
          const SizedBox(height: 24),
          Text(
            'Envoi de la demande...',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'Veuillez patienter',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  /// Attente de confirmation USSD
  Widget _buildAwaitingConfirmation(PaymentProvider provider) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppConstants.largePadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 40),
          
          // Animation d'attente
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: AppColors.primaryLight.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 100,
                  height: 100,
                  child: CircularProgressIndicator(
                    value: provider.remainingSeconds / 
                           AppConstants.paymentTimeoutSeconds,
                    strokeWidth: 6,
                    backgroundColor: AppColors.border,
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      AppColors.primary,
                    ),
                  ),
                ),
                const Icon(
                  Icons.phone_android,
                  size: 48,
                  color: AppColors.primary,
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 32),
          
          Text(
            'En attente de validation',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: 12),
          
          Text(
            'Une demande de paiement a été envoyée sur votre téléphone.\nValidez le paiement avec votre code secret.',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: 24),
          
          // Compte à rebours
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.warningLight,
              borderRadius: BorderRadius.circular(AppConstants.borderRadius),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.timer, color: AppColors.warning),
                const SizedBox(width: 8),
                Text(
                  'Temps restant: ${provider.formattedRemainingTime}',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 32),
          
          // Info numéro
          Container(
            padding: const EdgeInsets.all(AppConstants.defaultPadding),
            decoration: BoxDecoration(
              color: AppColors.backgroundGrey,
              borderRadius: BorderRadius.circular(AppConstants.borderRadius),
            ),
            child: Row(
              children: [
                Icon(
                  provider.selectedMethod == PaymentMethod.mtnMomo
                      ? Icons.phone_android
                      : Icons.phone_android,
                  color: provider.selectedMethod == PaymentMethod.mtnMomo
                      ? AppColors.mtnYellow
                      : AppColors.celtiisGreen,
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      provider.selectedMethod?.displayName ?? '',
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      '+229 ${provider.phoneNumber}',
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 32),
          
          // Bouton annuler
          TextButton(
            onPressed: () => provider.cancelPayment(),
            child: const Text(
              'Annuler le paiement',
              style: TextStyle(color: AppColors.error),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Boutons de test (à retirer en production)
          _buildTestButtons(provider),
        ],
      ),
    );
  }

  /// Écran de succès
  Widget _buildSuccess(PaymentProvider provider) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.largePadding),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icône de succès
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: AppColors.successLight,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_circle,
                size: 60,
                color: AppColors.success,
              ),
            ),
            
            const SizedBox(height: 32),
            
            Text(
              'Paiement réussi !',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.success,
              ),
            ),
            
            const SizedBox(height: 12),
            
            Text(
              'Votre rendez-vous avec ${widget.doctorName} est confirmé.',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: 8),
            
            Text(
              'Un SMS de confirmation vous a été envoyé.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: 40),
            
            PrimaryActionButton(
              text: 'Voir mes rendez-vous',
              onPressed: () {
                provider.reset();
                Navigator.of(context).popUntil((route) => route.isFirst);
              },
              backgroundColor: AppColors.success,
              icon: Icons.calendar_today,
            ),
          ],
        ),
      ),
    );
  }

  /// Écran d'échec
  Widget _buildFailure(PaymentProvider provider) {
    final isExpired = provider.status == PaymentFlowStatus.expired;
    
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.largePadding),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icône d'échec
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: AppColors.errorLight,
                shape: BoxShape.circle,
              ),
              child: Icon(
                isExpired ? Icons.timer_off : Icons.error_outline,
                size: 60,
                color: AppColors.error,
              ),
            ),
            
            const SizedBox(height: 32),
            
            Text(
              isExpired ? 'Délai expiré' : 'Paiement échoué',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.error,
              ),
            ),
            
            const SizedBox(height: 12),
            
            Text(
              provider.errorMessage ?? 'Une erreur est survenue',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: 40),
            
            PrimaryActionButton(
              text: 'Réessayer',
              onPressed: () => provider.retryPayment(),
              icon: Icons.refresh,
            ),
            
            const SizedBox(height: 16),
            
            TextButton(
              onPressed: () {
                provider.reset();
                Navigator.of(context).pop();
              },
              child: const Text('Annuler'),
            ),
          ],
        ),
      ),
    );
  }

  /// Écran d'annulation
  Widget _buildCancelled(PaymentProvider provider) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.largePadding),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.cancel_outlined,
              size: 80,
              color: AppColors.textSecondary,
            ),
            
            const SizedBox(height: 24),
            
            Text(
              'Paiement annulé',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            
            const SizedBox(height: 32),
            
            SecondaryActionButton(
              text: 'Réessayer',
              onPressed: () => provider.startPaymentFlow(),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // WIDGETS HELPERS
  // ============================================================

  Widget _buildOrderSummary() {
    return Container(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      decoration: BoxDecoration(
        color: AppColors.primaryLight.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.receipt_long, color: AppColors.primary),
              const SizedBox(width: 8),
              Text(
                'Résumé de la réservation',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const Divider(height: 24),
          _buildSummaryRow('Médecin', widget.doctorName),
          const SizedBox(height: 8),
          _buildSummaryRow('Montant', '${widget.amount} FCFA', isBold: true),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(color: AppColors.textSecondary),
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

  Widget _buildSelectedMethodHeader(PaymentProvider provider) {
    final method = provider.selectedMethod;
    if (method == null) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      decoration: BoxDecoration(
        color: method == PaymentMethod.mtnMomo
            ? AppColors.mtnYellow.withValues(alpha: 0.2)
            : AppColors.celtiisGreen.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
      ),
      child: Row(
        children: [
          Icon(
            Icons.phone_android,
            color: method == PaymentMethod.mtnMomo
                ? AppColors.mtnBlue
                : AppColors.celtiisGreen,
          ),
          const SizedBox(width: 12),
          Text(
            method.displayName,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: method == PaymentMethod.mtnMomo
                  ? AppColors.mtnBlue
                  : AppColors.celtiisGreen,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAmountSummary() {
    return Container(
      padding: const EdgeInsets.all(AppConstants.largePadding),
      decoration: BoxDecoration(
        color: AppColors.backgroundGrey,
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
      ),
      child: Column(
        children: [
          const Text(
            'Montant à payer',
            style: TextStyle(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 8),
          Text(
            '${widget.amount} FCFA',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }

  String _getPhoneHint(PaymentMethod? method) {
    if (method == PaymentMethod.mtnMomo) {
      return 'Ex: 97 00 00 00';
    } else if (method == PaymentMethod.celtiisCash) {
      return 'Ex: 94 00 00 00';
    }
    return 'Ex: 97 00 00 00';
  }

  Widget _buildPrefixInfo(PaymentMethod? method) {
    String prefixes = '';
    if (method == PaymentMethod.mtnMomo) {
      prefixes = AppConstants.mtnPrefixes.join(', ');
    } else if (method == PaymentMethod.celtiisCash) {
      prefixes = AppConstants.celtiisPrefixes.join(', ');
    }

    return Text(
      'Préfixes acceptés: $prefixes',
      style: const TextStyle(
        fontSize: 12,
        color: AppColors.textHint,
      ),
    );
  }

  Widget _buildTestButtons(PaymentProvider provider) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      decoration: BoxDecoration(
        color: AppColors.infoLight,
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        border: Border.all(color: AppColors.info.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          const Row(
            children: [
              Icon(Icons.bug_report, color: AppColors.info, size: 16),
              SizedBox(width: 8),
              Text(
                'Mode Test',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppColors.info,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () => provider.simulateSuccess(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.success,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                  ),
                  child: const Text('Simuler Succès', style: TextStyle(fontSize: 12)),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => provider.simulateFailure(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.error,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                  ),
                  child: const Text('Simuler Échec', style: TextStyle(fontSize: 12)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Carte de méthode de paiement
class _PaymentMethodCard extends StatelessWidget {
  final PaymentMethod method;
  final String title;
  final String subtitle;
  final Color primaryColor;
  final Color secondaryColor;
  final IconData iconData;
  final bool isSelected;
  final VoidCallback onTap;

  const _PaymentMethodCard({
    required this.method,
    required this.title,
    required this.subtitle,
    required this.primaryColor,
    required this.secondaryColor,
    required this.iconData,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppConstants.borderRadius),
      child: Container(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        decoration: BoxDecoration(
          color: isSelected 
              ? primaryColor.withValues(alpha: 0.1) 
              : AppColors.surface,
          borderRadius: BorderRadius.circular(AppConstants.borderRadius),
          border: Border.all(
            color: isSelected ? primaryColor : AppColors.border,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            // Icône
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: primaryColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(iconData, color: secondaryColor, size: 28),
            ),
            
            const SizedBox(width: 16),
            
            // Texte
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            
            // Checkbox
            if (isSelected)
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: primaryColor,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.check,
                  color: secondaryColor,
                  size: 16,
                ),
              )
            else
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.border, width: 2),
                  shape: BoxShape.circle,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
