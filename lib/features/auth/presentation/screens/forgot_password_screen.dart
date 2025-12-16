import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/widgets/primary_action_button.dart';
import '../../../../core/widgets/secure_input_field.dart';
import '../providers/auth_provider.dart';

/// Écran de récupération de mot de passe
class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _isLoading = false;
  bool _emailSent = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _handleResetPassword() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    // Simuler l'envoi d'email de réinitialisation
    await Future.delayed(const Duration(seconds: 2));
    
    if (mounted) {
      setState(() {
        _isLoading = false;
        _emailSent = true;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white),
              SizedBox(width: 8),
              Text('Instructions envoyées à votre email'),
            ],
          ),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

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
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppConstants.largePadding),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 20),
                
                // Header
                _buildHeader(),
                
                const SizedBox(height: 32),
                
                // Contenu principal
                if (!_emailSent)
                  _buildResetForm()
                else
                  _buildSuccessMessage(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
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
            Icons.lock_reset,
            size: 40,
            color: AppColors.primary,
          ),
        ),
        
        const SizedBox(height: 24),
        
        // Titre
        Text(
          _emailSent ? 'Vérifiez votre email' : 'Mot de passe oublié ?',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        
        const SizedBox(height: 8),
        
        Text(
          _emailSent 
            ? 'Nous avons envoyé des instructions pour réinitialiser votre mot de passe à votre adresse email.'
            : 'Entrez votre adresse email et nous vous enverrons des instructions pour réinitialiser votre mot de passe.',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: AppColors.textSecondary,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildResetForm() {
    return Column(
      children: [
        // Champ email
        SecureInputField(
          label: 'Adresse e-mail',
          hint: 'exemple@email.com',
          controller: _emailController,
          inputType: SecureInputType.email,
          textInputAction: TextInputAction.done,
          onSubmitted: (_) => _handleResetPassword(),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Veuillez entrer votre email';
            }
            if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
              return 'Veuillez entrer un email valide';
            }
            return null;
          },
        ),
        
        const SizedBox(height: 32),
        
        // Bouton d'envoi
        PrimaryActionButton(
          text: 'Envoyer les instructions',
          onPressed: _handleResetPassword,
          isLoading: _isLoading,
          icon: Icons.send,
        ),
        
        const SizedBox(height: 24),
        
        // Lien retour connexion
        _buildBackToLoginLink(),
      ],
    );
  }

  Widget _buildSuccessMessage() {
    return Column(
      children: [
        const SizedBox(height: 32),
        
        // Illustration
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            color: AppColors.successLight,
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.mark_email_read,
            size: 60,
            color: AppColors.success,
          ),
        ),
        
        const SizedBox(height: 32),
        
        // Instructions
        Container(
          padding: const EdgeInsets.all(AppConstants.defaultPadding),
          decoration: BoxDecoration(
            color: AppColors.infoLight,
            borderRadius: BorderRadius.circular(AppConstants.borderRadius),
          ),
          child: const Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.info, color: AppColors.info),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Si vous ne recevez pas d\'email, vérifiez votre dossier spam ou courrier indésirable.',
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 32),
        
        // Bouton retour
        PrimaryActionButton(
          text: 'Retour à la connexion',
          onPressed: () => Navigator.of(context).pop(),
          backgroundColor: AppColors.secondary,
          icon: Icons.login,
        ),
      ],
    );
  }

  Widget _buildBackToLoginLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text(
            'Retour à la connexion',
            style: TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}