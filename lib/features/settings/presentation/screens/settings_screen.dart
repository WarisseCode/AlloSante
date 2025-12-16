import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;
  bool _darkModeEnabled = false;
  bool _biometricEnabled = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Paramètres'),
        centerTitle: true,
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        children: [
          _buildSectionHeader('Général'),
          SwitchListTile(
            title: const Text('Mode sombre'),
            secondary: const Icon(Icons.dark_mode_rounded),
            value: _darkModeEnabled,
            onChanged: (bool value) {
              setState(() {
                _darkModeEnabled = value;
              });
            },
            activeColor: AppColors.primary,
          ),
          ListTile(
            title: const Text('Langue'),
            subtitle: const Text('Français (FR)'),
            leading: const Icon(Icons.language),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              // Dialog choix langue
            },
          ),

          _buildSectionHeader('Notifications'),
          SwitchListTile(
            title: const Text('Activer les notifications'),
            secondary: const Icon(Icons.notifications),
            value: _notificationsEnabled,
            onChanged: (bool value) {
              setState(() {
                _notificationsEnabled = value;
              });
            },
            activeColor: AppColors.primary,
          ),

          _buildSectionHeader('Sécurité'),
          SwitchListTile(
            title: const Text('Authentification biométrique'),
            subtitle: const Text('Utiliser l\'empreinte digitale ou FaceID'),
            secondary: const Icon(Icons.fingerprint),
            value: _biometricEnabled,
            onChanged: (bool value) {
              setState(() {
                _biometricEnabled = value;
              });
            },
            activeColor: AppColors.primary,
          ),
          ListTile(
            title: const Text('Changer de mot de passe'),
            leading: const Icon(Icons.lock),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              // Naviguer vers changement mdp
            },
          ),

          _buildSectionHeader('Informations'),
          ListTile(
            title: const Text('Conditions d\'utilisation'),
            leading: const Icon(Icons.description),
            onTap: () {},
          ),
          ListTile(
            title: const Text('Politique de confidentialité'),
            leading: const Icon(Icons.privacy_tip),
            onTap: () {},
          ),
          ListTile(
            title: const Text('À propos de l\'application'),
            subtitle: const Text('Version 1.0.0'),
            leading: const Icon(Icons.info),
            onTap: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.bold,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }
}
