import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../appointments/domain/entities/doctor.dart';
import '../../../appointments/presentation/screens/doctor_detail_screen.dart';

class SearchResultsScreen extends StatelessWidget {
  final Map<String, dynamic> filters;

  const SearchResultsScreen({super.key, required this.filters});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Résultats'),
        centerTitle: true,
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: _buildResultsList(),
    );
  }

  Widget _buildResultsList() {
    // Mock data amélioré
    final results = List.generate(
      5,
      (index) => Doctor(
        id: 'doc_$index',
        firstName: 'Jean',
        lastName: 'Dupont $index',
        specialty: 'Médecine Générale',
        location: 'Cotonou, Bénin',
        rating: 4.5,
        reviewCount: 120,
        profilePictureUrl: 'assets/images/doc_$index.png',
        bio: 'Médecin expérimenté...',
        consultationPrice: 15000,
        availableDays: ['Lundi', 'Mardi'],
        languages: ['Français'],
        experienceYears: 10,
        isAvailable: true,
      ),
    );

    if (results.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 64,
              color: Colors.grey.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'Aucun médecin trouvé',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey.withValues(alpha: 0.8),
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Essayez de modifier vos filtres',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      itemCount: results.length,
      itemBuilder: (context, index) {
        final doctor = results[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          child: ListTile(
            contentPadding: const EdgeInsets.all(16),
            leading: CircleAvatar(
              backgroundColor: AppColors.primaryLight,
              child: Text(
                doctor.initials,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            title: Text(doctor.fullName),
            subtitle: Text('${doctor.specialty} • ${doctor.location}'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DoctorDetailScreen(doctor: doctor),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
