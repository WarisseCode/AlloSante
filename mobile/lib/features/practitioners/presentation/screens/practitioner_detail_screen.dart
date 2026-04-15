import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../providers/practitioners_provider.dart';

class PractitionerDetailScreen extends ConsumerWidget {
  final int practitionerId;

  const PractitionerDetailScreen({super.key, required this.practitionerId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detailAsync = ref.watch(_practitionerDetailProvider(practitionerId));
    final tt = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: detailAsync.when(
        data: (data) => _DetailBody(data: data),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline,
                  size: 48, color: AppColors.textSecondary),
              const SizedBox(height: 12),
              Text('Impossible de charger le profil.', style: tt.bodyLarge),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: () =>
                    ref.refresh(_practitionerDetailProvider(practitionerId)),
                child: const Text('Réessayer'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Provider local au fichier
final _practitionerDetailProvider =
    FutureProvider.family<Map<String, dynamic>, int>((ref, id) {
  return ref.read(practitionersRepositoryProvider).getPractitionerDetail(id);
});

// ─── Corps de la fiche ───────────────────────────────────────────────────────

class _DetailBody extends StatelessWidget {
  final Map<String, dynamic> data;
  const _DetailBody({required this.data});

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final name = data['full_name'] as String? ?? '';
    final specialty = (data['specialty'] as Map?)?['name'] as String?;
    final photo = data['photo_url'] as String?;
    final city = data['city'] as String? ?? '';
    final neighborhood = data['neighborhood'] as String? ?? '';
    final address = data['address'] as String? ?? '';
    final fee = data['consultation_fee'] as int? ?? 0;
    final teleconFee = data['teleconsultation_fee'] as int? ?? 0;
    final bio = data['bio'] as String? ?? '';
    final rating = double.tryParse(
            data['rating_average']?.toString() ?? '0') ??
        0.0;
    final reviewCount = data['review_count'] as int? ?? 0;
    final yearsExp = data['years_experience'] as int? ?? 0;
    final languages = (data['languages_list'] as List?)
            ?.map((e) => e.toString())
            .toList() ??
        [];
    final workingHours = data['working_hours'] as List? ?? [];

    return CustomScrollView(
      slivers: [
        // Header avec photo
        SliverAppBar(
          expandedHeight: 200,
          pinned: true,
          backgroundColor: AppColors.primary,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => context.pop(),
          ),
          flexibleSpace: FlexibleSpaceBar(
            background: Stack(
              fit: StackFit.expand,
              children: [
                Container(color: AppColors.primary),
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 40),
                      CircleAvatar(
                        radius: 48,
                        backgroundColor: AppColors.backgroundLight,
                        backgroundImage:
                            photo != null ? NetworkImage(photo) : null,
                        child: photo == null
                            ? Text(
                                name.isNotEmpty ? name[0].toUpperCase() : '?',
                                style: const TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.primary,
                                ),
                              )
                            : null,
                      ),
                      const SizedBox(height: 8),
                      Text(name,
                          style: tt.titleLarge
                              ?.copyWith(color: Colors.white)),
                      if (specialty != null)
                        Text(specialty,
                            style: tt.bodyMedium?.copyWith(
                                color: Colors.white
                                    .withValues(alpha: 0.85))),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),

        SliverPadding(
          padding: const EdgeInsets.all(16),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              // Note & avis
              if (reviewCount > 0)
                _InfoCard(children: [
                  Row(children: [
                    const Icon(Icons.star_rounded,
                        color: AppColors.warning, size: 20),
                    const SizedBox(width: 4),
                    Text(rating.toStringAsFixed(1),
                        style: tt.titleLarge?.copyWith(fontSize: 18)),
                    const SizedBox(width: 4),
                    Text('($reviewCount avis)', style: tt.bodySmall),
                    const Spacer(),
                    if (yearsExp > 0)
                      Text('$yearsExp ans d\'expérience',
                          style: tt.bodySmall),
                  ]),
                ]),

              const SizedBox(height: 12),

              // Localisation & tarifs
              _InfoCard(children: [
                _InfoRow(Icons.location_on_outlined,
                    [neighborhood, city, address]
                        .where((s) => s.isNotEmpty)
                        .join(', ')),
                const SizedBox(height: 8),
                _InfoRow(Icons.payments_outlined,
                    'Consultation : $fee FCFA'),
                if (teleconFee > 0) ...[
                  const SizedBox(height: 8),
                  _InfoRow(Icons.videocam_outlined,
                      'Téléconsultation : $teleconFee FCFA'),
                ],
                if (languages.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  _InfoRow(Icons.language_outlined, languages.join(', ')),
                ],
              ]),

              const SizedBox(height: 12),

              // Bio
              if (bio.isNotEmpty) ...[
                _InfoCard(children: [
                  Text('À propos',
                      style: tt.titleLarge?.copyWith(fontSize: 16)),
                  const SizedBox(height: 8),
                  Text(bio, style: tt.bodyMedium),
                ]),
                const SizedBox(height: 12),
              ],

              // Horaires
              if (workingHours.isNotEmpty) ...[
                _InfoCard(children: [
                  Text('Horaires',
                      style: tt.titleLarge?.copyWith(fontSize: 16)),
                  const SizedBox(height: 8),
                  ...workingHours.map((h) {
                    final map = h as Map;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Row(
                        mainAxisAlignment:
                            MainAxisAlignment.spaceBetween,
                        children: [
                          Text(map['day_label'] as String? ?? '',
                              style: tt.bodyMedium),
                          Text(
                            '${map['start_time']} – ${map['end_time']}',
                            style: tt.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    );
                  }),
                ]),
                const SizedBox(height: 12),
              ],

              // Bouton prendre RDV
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    // TODO: navigation vers écran de réservation
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Écran de réservation — bientôt disponible')),
                    );
                  },
                  icon: const Icon(Icons.calendar_today_outlined),
                  label: const Text('Prendre rendez-vous'),
                ),
              ),

              const SizedBox(height: 32),
            ]),
          ),
        ),
      ],
    );
  }
}

class _InfoCard extends StatelessWidget {
  final List<Widget> children;
  const _InfoCard({required this.children});

  @override
  Widget build(BuildContext context) => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start, children: children),
      );
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String text;
  const _InfoRow(this.icon, this.text);

  @override
  Widget build(BuildContext context) => Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: AppColors.primary),
          const SizedBox(width: 8),
          Expanded(
            child: Text(text,
                style: Theme.of(context).textTheme.bodyMedium),
          ),
        ],
      );
}
