import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../providers/medical_record_provider.dart';

class MedicalRecordScreen extends StatefulWidget {
  const MedicalRecordScreen({super.key});

  @override
  State<MedicalRecordScreen> createState() => _MedicalRecordScreenState();
}

class _MedicalRecordScreenState extends State<MedicalRecordScreen> {
  @override
  void initState() {
    super.initState();
    // Charger les données au démarrage
    Future.microtask(() {
      context.read<MedicalRecordProvider>().loadMedicalRecord();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Dossier Médical'),
        centerTitle: true,
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: Consumer<MedicalRecordProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    size: 48,
                    color: AppColors.error,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    provider.error!,
                    style: const TextStyle(color: AppColors.error),
                    textAlign: TextAlign.center,
                  ),
                  TextButton(
                    onPressed: () => provider.loadMedicalRecord(),
                    child: const Text('Réessayer'),
                  ),
                ],
              ),
            );
          }

          final record = provider.record;
          if (record == null) {
            return const Center(child: Text('Aucun dossier médical trouvé'));
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppConstants.defaultPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildAlertBanner(),
                const SizedBox(height: 24),
                _buildSection(
                  title: "Données biométriques",
                  icon: Icons.monitor_heart,
                  content: Column(
                    children: [
                      _buildMetricRow(
                        "Groupe Sanguin",
                        record.bloodType ?? "Non renseigné",
                        Icons.bloodtype,
                      ),
                      const Divider(),
                      _buildMetricRow(
                        "Poids",
                        record.weight != null
                            ? "${record.weight} kg"
                            : "Non renseigné",
                        Icons.monitor_weight,
                      ),
                      const Divider(),
                      _buildMetricRow(
                        "Taille",
                        record.height != null
                            ? "${record.height} cm"
                            : "Non renseigné",
                        Icons.height,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                _buildSection(
                  title: "Allergies",
                  icon: Icons.warning_amber,
                  content: record.allergies.isEmpty
                      ? const Text(
                          "Aucune allergie signalée",
                          style: TextStyle(
                            fontStyle: FontStyle.italic,
                            color: Colors.grey,
                          ),
                        )
                      : Wrap(
                          spacing: 8,
                          children: record.allergies
                              .map(
                                (allergy) => Chip(
                                  label: Text(allergy),
                                  backgroundColor: const Color(0xFFFFEBEE),
                                  labelStyle: const TextStyle(
                                    color: Colors.red,
                                  ),
                                  avatar: const Icon(
                                    Icons.close,
                                    size: 16,
                                    color: Colors.red,
                                  ),
                                ),
                              )
                              .toList(),
                        ),
                ),
                const SizedBox(height: 16),
                _buildSection(
                  title: "Antécédents",
                  icon: Icons.history,
                  content: record.conditions.isEmpty
                      ? const Text(
                          "Aucun antécédent signalé",
                          style: TextStyle(
                            fontStyle: FontStyle.italic,
                            color: Colors.grey,
                          ),
                        )
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: record.conditions
                              .map(
                                (condition) => Padding(
                                  padding: const EdgeInsets.only(bottom: 4),
                                  child: Text("• $condition"),
                                ),
                              )
                              .toList(),
                        ),
                ),
                const SizedBox(height: 32),
                OutlinedButton.icon(
                  onPressed: () {
                    // TODO: Implémenter l'édition
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'La modification sera disponible bientôt',
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.edit_note),
                  label: const Text("Demander une mise à jour"),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.all(16),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildAlertBanner() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Row(
        children: [
          Icon(Icons.lock, color: Colors.blue.shade700),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              "Ces données sont cryptées et visibles uniquement par vous et vos médecins traitants.",
              style: TextStyle(color: Colors.blue.shade900, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required Widget content,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: AppColors.primary),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            content,
          ],
        ),
      ),
    );
  }

  Widget _buildMetricRow(String label, String value, IconData icon) {
    final isPlaceholder = value == "Non renseigné";
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: Colors.grey),
              const SizedBox(width: 8),
              Text(label, style: const TextStyle(fontSize: 16)),
            ],
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: isPlaceholder ? FontWeight.normal : FontWeight.bold,
              color: isPlaceholder
                  ? AppColors.textSecondary
                  : AppColors.textPrimary,
              fontStyle: isPlaceholder ? FontStyle.italic : FontStyle.normal,
            ),
          ),
        ],
      ),
    );
  }
}
