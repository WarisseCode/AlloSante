import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_constants.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('À Propos'),
        centerTitle: true,
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: Column(
          children: [
            const SizedBox(height: 32),
            _buildLogo(),
            const SizedBox(height: 24),
            _buildVersionInfo(),
            const SizedBox(height: 48),
            _buildLinksSection(),
            const SizedBox(height: 48),
            _buildCopyright(),
          ],
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: const Icon(
        Icons.local_hospital_rounded,
        size: 50,
        color: Colors.white,
      ),
    );
  }

  Widget _buildVersionInfo() {
    return Column(
      children: [
        const Text(
          "AlloSanté Bénin",
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          "Version 1.0.0 (Build 100)",
          style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
        ),
      ],
    );
  }

  Widget _buildLinksSection() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        children: [
          _buildLinkItem("Site Web Officiel", "https://www.allosante.bj"),
          const Divider(height: 1),
          _buildLinkItem(
            "Conditions Générales d'Utilisation",
            "https://www.allosante.bj/cgu",
          ),
          const Divider(height: 1),
          _buildLinkItem(
            "Politique de Confidentialité",
            "https://www.allosante.bj/privacy",
          ),
          const Divider(height: 1),
          _buildLinkItem(
            "Licences Open Source",
            "",
          ), // Could open LicenseRegistry
        ],
      ),
    );
  }

  Widget _buildLinkItem(String title, String url) {
    return ListTile(
      title: Text(title),
      trailing: const Icon(Icons.open_in_new, size: 16, color: Colors.grey),
      onTap: () {
        if (url.isNotEmpty) {
          _launchUrl(url);
        }
      },
    );
  }

  Widget _buildCopyright() {
    return Text(
      "© 2024 AlloSanté Bénin. Tous droits réservés.",
      style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
    );
  }

  Future<void> _launchUrl(String urlString) async {
    final Uri url = Uri.parse(urlString);
    if (!await launchUrl(url)) {
      throw Exception('Could not launch $url');
    }
  }
}
