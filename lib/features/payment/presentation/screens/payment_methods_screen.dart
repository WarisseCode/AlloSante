import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_constants.dart';

class PaymentMethodsScreen extends StatelessWidget {
  const PaymentMethodsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Moyens de Paiement'),
        centerTitle: true,
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildSectionHeader("Numéros enregistrés"),
            _buildPaymentMethodItem(
              icon: Icons.phone_android,
              title: "MTN Mobile Money",
              subtitle: "+229 97 00 00 00",
              isDefault: true,
            ),
            const SizedBox(height: 8),
            _buildPaymentMethodItem(
              icon: Icons.phone_android,
              title: "Celtiis Cash",
              subtitle: "+229 95 00 00 00",
              isDefault: false,
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: () {
                // TODO: Add new payment method logic
              },
              icon: const Icon(Icons.add),
              label: const Text("Ajouter un numéro"),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                side: const BorderSide(color: AppColors.primary),
              ),
            ),

            const SizedBox(height: 32),
            _buildSectionHeader("Historique récent"),
            Card(
              elevation: 0,
              color: Colors.white,
              shape: RoundedRectangleBorder(
                side: BorderSide(color: Colors.grey.shade200),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  _buildTransactionItem(
                    "Consultation Dr. Kpanou",
                    "12 Déc",
                    "- 2000 F",
                  ),
                  const Divider(height: 1),
                  _buildTransactionItem(
                    "Pharmacie de la gare",
                    "10 Déc",
                    "- 5500 F",
                  ),
                  const Divider(height: 1),
                  _buildTransactionItem(
                    "Consultation Dr. Assogba",
                    "05 Déc",
                    "- 2000 F",
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16, left: 4),
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

  Widget _buildPaymentMethodItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool isDefault,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.primaryLight.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: AppColors.primary),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle),
        trailing: isDefault
            ? const Chip(
                label: Text("Défaut", style: TextStyle(fontSize: 10)),
                backgroundColor: AppColors.primaryLight,
                labelPadding: EdgeInsets.symmetric(horizontal: 4),
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              )
            : IconButton(icon: const Icon(Icons.more_vert), onPressed: () {}),
      ),
    );
  }

  Widget _buildTransactionItem(String title, String date, String amount) {
    return ListTile(
      title: Text(
        title,
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
      ),
      subtitle: Text(date, style: const TextStyle(fontSize: 12)),
      trailing: Text(
        amount,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }
}
