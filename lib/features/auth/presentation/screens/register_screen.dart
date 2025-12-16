import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/widgets/primary_action_button.dart';
import '../../../../core/widgets/secure_input_field.dart';
import '../providers/auth_provider.dart';

/// Écran d'inscription AlloSanté
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;
  bool _acceptTerms = false;

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;

    if (!_acceptTerms) {
      _showError('Veuillez accepter les termes et conditions');
      return;
    }

    setState(() => _isLoading = true);

    final authProvider = context.read<AuthProvider>();
    final success = await authProvider.register(
      firstName: _firstNameController.text.trim(),
      lastName: _lastNameController.text.trim(),
      email: _emailController.text.trim(),
      phone: '01${_phoneController.text.replaceAll(RegExp(r'\s'), '').trim()}',
      password: _passwordController.text,
    );

    if (mounted) {
      setState(() => _isLoading = false);

      if (success) {
        // Navigation vers OTP gérée par le router
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Compte créé avec succès! Veuillez vérifier votre numéro.',
                  ),
                ),
              ],
            ),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
          ),
        );
      } else {
        _showError(
          authProvider.errorMessage ?? 'Erreur lors de l\'inscription',
        );
      }
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
      ),
    );
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

                // Titre
                _buildHeader(),

                const SizedBox(height: 32),

                // Formulaire d'inscription
                _buildRegisterForm(),

                const SizedBox(height: 24),

                // Conditions d'utilisation
                _buildTermsCheckbox(),

                const SizedBox(height: 24),

                // Bouton d'inscription
                PrimaryActionButton(
                  text: 'Créer un compte',
                  onPressed: _handleRegister,
                  isLoading: _isLoading,
                  icon: Icons.person_add,
                ),

                const SizedBox(height: 24),

                // Lien vers connexion
                _buildLoginLink(),
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
            Icons.person_add,
            size: 40,
            color: AppColors.primary,
          ),
        ),

        const SizedBox(height: 24),

        // Titre
        Text(
          'Créer un compte',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),

        const SizedBox(height: 8),

        Text(
          'Remplissez vos informations pour commencer',
          style: Theme.of(
            context,
          ).textTheme.bodyLarge?.copyWith(color: AppColors.textSecondary),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildRegisterForm() {
    return Column(
      children: [
        // Prénom
        SecureInputField(
          label: 'Prénom',
          hint: 'Entrez votre prénom',
          controller: _firstNameController,
          inputType: SecureInputType.text,
          textInputAction: TextInputAction.next,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Veuillez entrer votre prénom';
            }
            if (value.length < 2) {
              return 'Le prénom doit contenir au moins 2 caractères';
            }
            return null;
          },
        ),

        const SizedBox(height: 20),

        // Nom
        SecureInputField(
          label: 'Nom',
          hint: 'Entrez votre nom',
          controller: _lastNameController,
          inputType: SecureInputType.text,
          textInputAction: TextInputAction.next,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Veuillez entrer votre nom';
            }
            if (value.length < 2) {
              return 'Le nom doit contenir au moins 2 caractères';
            }
            return null;
          },
        ),

        const SizedBox(height: 20),

        // Email
        SecureInputField(
          label: 'Adresse e-mail',
          hint: 'exemple@email.com',
          controller: _emailController,
          inputType: SecureInputType.email,
          textInputAction: TextInputAction.next,
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

        const SizedBox(height: 20),

        // Téléphone (préfixe 01 visible, ajouté automatiquement lors de l'envoi)
        SecureInputField(
          label: 'Numéro de téléphone',
          hint: '97 00 00 00',
          prefixText: '01',
          controller: _phoneController,
          inputType: SecureInputType.phone,
          textInputAction: TextInputAction.next,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Veuillez entrer votre numéro de téléphone';
            }
            // Nettoyer les espaces
            final cleanNumber = value.replaceAll(RegExp(r'\s'), '');
            // Doit être exactement 8 chiffres
            if (cleanNumber.length != 8) {
              return 'Veuillez entrer exactement 8 chiffres';
            }
            // Doit commencer par un nombre entre 40 et 99
            final prefix = int.tryParse(cleanNumber.substring(0, 2)) ?? 0;
            if (prefix < 40 || prefix > 99) {
              return 'Le numéro doit commencer par un chiffre entre 40 et 99';
            }
            return null;
          },
        ),

        const SizedBox(height: 20),

        // Mot de passe
        SecureInputField(
          label: 'Mot de passe',
          hint: '••••••••',
          controller: _passwordController,
          inputType: SecureInputType.password,
          textInputAction: TextInputAction.next,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Veuillez entrer un mot de passe';
            }
            if (value.length < 6) {
              return 'Le mot de passe doit contenir au moins 6 caractères';
            }
            return null;
          },
        ),

        const SizedBox(height: 20),

        // Confirmation du mot de passe
        SecureInputField(
          label: 'Confirmer le mot de passe',
          hint: '••••••••',
          controller: _confirmPasswordController,
          inputType: SecureInputType.password,
          textInputAction: TextInputAction.done,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Veuillez confirmer votre mot de passe';
            }
            if (value != _passwordController.text) {
              return 'Les mots de passe ne correspondent pas';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildTermsCheckbox() {
    return Row(
      children: [
        Checkbox(
          value: _acceptTerms,
          onChanged: (value) {
            setState(() => _acceptTerms = value ?? false);
          },
          activeColor: AppColors.primary,
        ),
        Expanded(
          child: GestureDetector(
            onTap: () {
              setState(() => _acceptTerms = !_acceptTerms);
            },
            child: Text.rich(
              TextSpan(
                children: [
                  const TextSpan(text: 'J\'accepte les '),
                  TextSpan(
                    text: 'termes et conditions',
                    style: TextStyle(color: AppColors.primary),
                  ),
                  const TextSpan(text: ' et la '),
                  TextSpan(
                    text: 'politique de confidentialité',
                    style: TextStyle(color: AppColors.primary),
                  ),
                ],
              ),
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLoginLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          'Vous avez déjà un compte ? ',
          style: TextStyle(color: AppColors.textSecondary),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text(
            'Se connecter',
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
