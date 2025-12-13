import 'package:flutter/material.dart';
import 'package:pinput/pinput.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/widgets/primary_action_button.dart';
import '../providers/auth_provider.dart';

/// Écran de vérification OTP (MFA)
/// Vérifie le code envoyé par SMS au numéro de téléphone
class OtpScreen extends StatefulWidget {
  const OtpScreen({super.key});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> with TickerProviderStateMixin {
  final _pinController = TextEditingController();
  final _focusNode = FocusNode();
  late AnimationController _shakeController;
  bool _isLoading = false;
  String? _errorText;

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _pinController.dispose();
    _focusNode.dispose();
    _shakeController.dispose();
    super.dispose();
  }

  Future<void> _handleVerify() async {
    if (_pinController.text.length != AppConstants.otpLength) {
      _showError('Veuillez entrer le code complet');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorText = null;
    });

    final authProvider = context.read<AuthProvider>();
    final success = await authProvider.verifyOtp(_pinController.text);

    if (mounted) {
      setState(() => _isLoading = false);

      if (!success) {
        _showError(authProvider.errorMessage ?? 'Code invalide');
        _shakeController.forward(from: 0);
        _pinController.clear();
      }
      // Navigation gérée par le router si succès
    }
  }

  void _showError(String message) {
    setState(() => _errorText = message);
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final phone = authProvider.pendingPhone ?? 'votre numéro';
    final countdown = authProvider.otpResendCountdown;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () {
            authProvider.cancelOtp();
          },
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppConstants.largePadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 20),
              
              // Icône
              _buildIcon(),
              
              const SizedBox(height: 32),
              
              // Titre et description
              _buildHeader(phone),
              
              const SizedBox(height: 40),
              
              // Champ OTP avec animation shake
              AnimatedBuilder(
                animation: _shakeController,
                builder: (context, child) {
                  final offset = _shakeController.value * 10 * 
                      (1 - _shakeController.value) * 
                      (_shakeController.value < 0.5 ? 1 : -1);
                  return Transform.translate(
                    offset: Offset(offset, 0),
                    child: child,
                  );
                },
                child: _buildOtpInput(),
              ),
              
              // Message d'erreur
              if (_errorText != null) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.errorLight,
                    borderRadius: BorderRadius.circular(AppConstants.borderRadiusSmall),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline, color: AppColors.error, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _errorText!,
                          style: const TextStyle(
                            color: AppColors.error,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              
              const SizedBox(height: 32),
              
              // Bouton de vérification
              PrimaryActionButton(
                text: 'Vérifier le code',
                onPressed: _handleVerify,
                isLoading: _isLoading,
                icon: Icons.check_circle,
              ),
              
              const SizedBox(height: 24),
              
              // Renvoyer le code
              _buildResendSection(countdown, authProvider),
              
              const SizedBox(height: 32),
              
              // Info de test
              _buildTestInfo(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIcon() {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        color: AppColors.primaryLight.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Icon(
        Icons.sms_outlined,
        size: 40,
        color: AppColors.primary,
      ),
    );
  }

  Widget _buildHeader(String phone) {
    return Column(
      children: [
        Text(
          'Vérification SMS',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        
        const SizedBox(height: 12),
        
        Text(
          'Entrez le code à 6 chiffres envoyé au',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: AppColors.textSecondary,
          ),
          textAlign: TextAlign.center,
        ),
        
        const SizedBox(height: 8),
        
        Text(
          '+229 $phone',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),
      ],
    );
  }

  Widget _buildOtpInput() {
    final defaultPinTheme = PinTheme(
      width: 52,
      height: 60,
      textStyle: const TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: AppColors.textPrimary,
      ),
      decoration: BoxDecoration(
        color: AppColors.backgroundGrey,
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusSmall),
        border: Border.all(color: AppColors.border),
      ),
    );

    final focusedPinTheme = defaultPinTheme.copyWith(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusSmall),
        border: Border.all(color: AppColors.primary, width: 2),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.2),
            blurRadius: 8,
            spreadRadius: 2,
          ),
        ],
      ),
    );

    final submittedPinTheme = defaultPinTheme.copyWith(
      decoration: BoxDecoration(
        color: AppColors.successLight,
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusSmall),
        border: Border.all(color: AppColors.success),
      ),
    );

    final errorPinTheme = defaultPinTheme.copyWith(
      decoration: BoxDecoration(
        color: AppColors.errorLight,
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusSmall),
        border: Border.all(color: AppColors.error),
      ),
    );

    return Center(
      child: Pinput(
        length: AppConstants.otpLength,
        controller: _pinController,
        focusNode: _focusNode,
        defaultPinTheme: _errorText != null ? errorPinTheme : defaultPinTheme,
        focusedPinTheme: focusedPinTheme,
        submittedPinTheme: submittedPinTheme,
        showCursor: true,
        cursor: Container(
          width: 2,
          height: 24,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(1),
          ),
        ),
        onCompleted: (pin) {
          _handleVerify();
        },
        onChanged: (value) {
          if (_errorText != null) {
            setState(() => _errorText = null);
          }
        },
      ),
    );
  }

  Widget _buildResendSection(int countdown, AuthProvider authProvider) {
    return Column(
      children: [
        Text(
          'Vous n\'avez pas reçu le code ?',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        
        const SizedBox(height: 8),
        
        if (countdown > 0)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.timer, size: 18, color: AppColors.textSecondary),
              const SizedBox(width: 4),
              Text(
                'Renvoyer dans ${countdown}s',
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          )
        else
          TextButton.icon(
            onPressed: () async {
              final success = await authProvider.resendOtp();
              if (success && mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Row(
                      children: [
                        Icon(Icons.check_circle, color: Colors.white),
                        SizedBox(width: 8),
                        Text('Nouveau code envoyé'),
                      ],
                    ),
                    backgroundColor: AppColors.success,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
            icon: const Icon(Icons.refresh),
            label: const Text(
              'Renvoyer le code',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
      ],
    );
  }

  Widget _buildTestInfo() {
    return Container(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      decoration: BoxDecoration(
        color: AppColors.infoLight,
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        border: Border.all(color: AppColors.info.withValues(alpha: 0.3)),
      ),
      child: const Row(
        children: [
          Icon(Icons.info_outline, color: AppColors.info),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Mode Test',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.info,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Code de test : 123456',
                  style: TextStyle(
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
