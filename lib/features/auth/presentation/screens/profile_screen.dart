import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/widgets/primary_action_button.dart';
import '../providers/auth_provider.dart';

import 'edit_profile_screen.dart';
import 'personal_info_screen.dart';
import '../../../medical_record/presentation/screens/medical_record_screen.dart';
import '../../../payment/presentation/screens/payment_methods_screen.dart';
import '../../../settings/presentation/screens/settings_screen.dart';
import '../../../settings/presentation/screens/help_support_screen.dart';
import '../../../settings/presentation/screens/about_screen.dart';

/// Écran de profil utilisateur
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final user = authProvider.user;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Mon Profil'),
        centerTitle: true,
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const EditProfileScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // En-tête avec avatar et informations utilisateur
            _buildProfileHeader(user),

            const SizedBox(height: 24),

            // Sections du profil
            _buildProfileSections(context),

            const SizedBox(height: 24),

            // Bouton de déconnexion
            _buildLogoutButton(context, authProvider),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader(user) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.largePadding),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.primaryDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Row(
        children: [
          // Avatar
          CircleAvatar(
            radius: 50,
            backgroundColor: Colors.white.withValues(alpha: 0.2),
            child: Text(
              user?.initials ?? 'U',
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),

          const SizedBox(width: 16),

          // Informations
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user?.fullName ?? 'Utilisateur',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  user?.email ?? 'email@example.com',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  '+229 ${user?.phone ?? "00 00 00 00"}',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
                ),

                const SizedBox(height: 12),

                // Badge de statut
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'Compte vérifié',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileSections(BuildContext context) {
    return Column(
      children: [
        // Informations personnelles
        _ProfileSection(
          icon: Icons.person_outline,
          title: 'Informations personnelles',
          subtitle: 'Gérez vos données personnelles',
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const PersonalInfoScreen(),
              ),
            );
          },
        ),

        // Mon dossier médical
        _ProfileSection(
          icon: Icons.folder_outlined,
          title: 'Mon dossier médical',
          subtitle: 'Consultez votre historique médical',
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const MedicalRecordScreen(),
              ),
            );
          },
        ),

        // Moyens de paiement
        _ProfileSection(
          icon: Icons.payment_outlined,
          title: 'Moyens de paiement',
          subtitle: 'Gérez vos méthodes de paiement',
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const PaymentMethodsScreen(),
              ),
            );
          },
        ),

        // Notifications
        _ProfileSection(
          icon: Icons.notifications_outlined,
          title: 'Notifications',
          subtitle: 'Paramétrez vos préférences de notification',
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const SettingsScreen()),
            );
          },
        ),

        // Confidentialité et sécurité
        _ProfileSection(
          icon: Icons.security_outlined,
          title: 'Confidentialité et sécurité',
          subtitle: 'Gérez vos paramètres de sécurité',
          onTap: () {
            // Navigation vers la sécurité (qui est dans les paramètres pour l'instant)
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const SettingsScreen()),
            );
          },
        ),

        // Aide et support
        _ProfileSection(
          icon: Icons.help_outline,
          title: 'Aide & Support',
          subtitle: 'Centre d\'aide et contact',
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const HelpSupportScreen(),
              ),
            );
          },
        ),

        // À propos
        _ProfileSection(
          icon: Icons.info_outline,
          title: 'À propos',
          subtitle: 'Version et informations légales',
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const AboutScreen()),
            );
          },
        ),
      ],
    );
  }

  Widget _buildLogoutButton(BuildContext context, AuthProvider authProvider) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      child: SecondaryActionButton(
        text: 'Déconnexion',
        onPressed: () {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text('Déconnexion'),
                content: const Text(
                  'Êtes-vous sûr de vouloir vous déconnecter ?',
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Annuler'),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      authProvider.logout();
                      Navigator.of(
                        context,
                      ).pushReplacementNamed('/login'); // Example logout nav
                    },
                    child: const Text(
                      'Déconnexion',
                      style: TextStyle(color: AppColors.error),
                    ),
                  ),
                ],
              );
            },
          );
        },
        icon: Icons.logout,
        borderColor: AppColors.error,
        textColor: AppColors.error,
      ),
    );
  }
}

/// Section de profil réutilisable
class _ProfileSection extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _ProfileSection({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: AppColors.primaryLight.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: AppColors.primary),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: Text(
        subtitle,
        style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
      ),
      trailing: const Icon(Icons.chevron_right, color: AppColors.textSecondary),
      onTap: onTap,
    );
  }
}
