import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../practitioners/presentation/providers/practitioners_provider.dart';
import '../../../practitioners/presentation/widgets/practitioner_card.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _tabIndex = 0;
  final _searchCtrl = TextEditingController();

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: IndexedStack(
        index: _tabIndex,
        children: const [
          _HomeTab(),
          _PlaceholderTab(icon: Icons.calendar_today_outlined, label: 'Mes rendez-vous'),
          _PlaceholderTab(icon: Icons.local_pharmacy_outlined, label: 'Pharmacies de garde'),
          _PlaceholderTab(icon: Icons.person_outline, label: 'Mon profil'),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _tabIndex,
        onTap: (i) => setState(() => _tabIndex = i),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Accueil',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today_outlined),
            activeIcon: Icon(Icons.calendar_today),
            label: 'Rendez-vous',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.local_pharmacy_outlined),
            activeIcon: Icon(Icons.local_pharmacy),
            label: 'Pharmacies',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profil',
          ),
        ],
      ),
    );
  }
}

// ─── Onglet Accueil ──────────────────────────────────────────────────────────

class _HomeTab extends ConsumerStatefulWidget {
  const _HomeTab();

  @override
  ConsumerState<_HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends ConsumerState<_HomeTab> {
  final _searchCtrl = TextEditingController();

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  void _onSearch(String q) {
    ref.read(searchFiltersProvider.notifier).update(
          (s) => s.copyWith(query: q),
        );
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authProvider).user;
    final specialties = ref.watch(specialtiesProvider);
    final practitioners = ref.watch(practitionersProvider);
    final filters = ref.watch(searchFiltersProvider);
    final tt = Theme.of(context).textTheme;

    return CustomScrollView(
      slivers: [
        // Header vert
        SliverAppBar(
          expandedHeight: 160,
          pinned: true,
          backgroundColor: AppColors.primary,
          flexibleSpace: FlexibleSpaceBar(
            background: Container(
              color: AppColors.primary,
              padding: const EdgeInsets.fromLTRB(24, 60, 24, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Bonjour${user != null ? ', ${user.firstName}' : ''} 👋',
                    style: tt.titleLarge?.copyWith(color: Colors.white),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Comment pouvons-nous vous aider ?',
                    style: tt.bodyMedium?.copyWith(
                      color: Colors.white.withValues(alpha: 0.85),
                    ),
                  ),
                ],
              ),
            ),
          ),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(56),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: TextField(
                controller: _searchCtrl,
                onChanged: _onSearch,
                decoration: InputDecoration(
                  hintText: 'Médecin, spécialité, quartier...',
                  prefixIcon: const Icon(Icons.search, color: AppColors.textSecondary),
                  suffixIcon: _searchCtrl.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, size: 18),
                          onPressed: () {
                            _searchCtrl.clear();
                            _onSearch('');
                          },
                        )
                      : null,
                  filled: true,
                  fillColor: AppColors.surface,
                  contentPadding: const EdgeInsets.symmetric(vertical: 0),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
          ),
        ),

        // Spécialités
        SliverToBoxAdapter(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
                child: Text('Spécialités', style: tt.titleLarge),
              ),
              specialties.when(
                data: (list) => SizedBox(
                  height: 90,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: list.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 12),
                    itemBuilder: (_, i) {
                      final s = list[i];
                      final selected = filters.specialtySlug == s.slug;
                      return GestureDetector(
                        onTap: () {
                          ref.read(searchFiltersProvider.notifier).update(
                                (f) => selected
                                    ? f.copyWith(clearSpecialty: true)
                                    : f.copyWith(specialtySlug: s.slug),
                              );
                        },
                        child: Column(
                          children: [
                            Container(
                              width: 56,
                              height: 56,
                              decoration: BoxDecoration(
                                color: selected
                                    ? AppColors.primary
                                    : AppColors.backgroundLight,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Icon(
                                Icons.medical_services_outlined,
                                color: selected
                                    ? Colors.white
                                    : AppColors.primary,
                                size: 26,
                              ),
                            ),
                            const SizedBox(height: 6),
                            SizedBox(
                              width: 64,
                              child: Text(
                                s.name,
                                style: TextStyle(
                                  fontSize: 11,
                                  color: selected
                                      ? AppColors.primary
                                      : AppColors.textSecondary,
                                  fontWeight: selected
                                      ? FontWeight.w600
                                      : FontWeight.normal,
                                ),
                                textAlign: TextAlign.center,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                loading: () => const SizedBox(
                  height: 90,
                  child: Center(child: CircularProgressIndicator()),
                ),
                error: (_, __) => const SizedBox.shrink(),
              ),
            ],
          ),
        ),

        // Filtres rapides
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Row(
              children: [
                _FilterChip(
                  label: 'Disponible aujourd\'hui',
                  active: filters.availableToday,
                  onTap: () => ref.read(searchFiltersProvider.notifier).update(
                        (f) => f.copyWith(availableToday: !f.availableToday),
                      ),
                ),
                const SizedBox(width: 8),
                _FilterChip(
                  label: 'Téléconsultation',
                  active: filters.teleconsultation,
                  onTap: () => ref.read(searchFiltersProvider.notifier).update(
                        (f) => f.copyWith(teleconsultation: !f.teleconsultation),
                      ),
                ),
              ],
            ),
          ),
        ),

        // En-tête liste
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Praticiens', style: tt.titleLarge),
                practitioners.when(
                  data: (list) => Text(
                    '${list.length} résultat${list.length > 1 ? 's' : ''}',
                    style: tt.bodySmall,
                  ),
                  loading: () => const SizedBox.shrink(),
                  error: (_, __) => const SizedBox.shrink(),
                ),
              ],
            ),
          ),
        ),

        // Liste praticiens
        practitioners.when(
          data: (list) => list.isEmpty
              ? SliverToBoxAdapter(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(48),
                      child: Column(
                        children: [
                          const Icon(Icons.search_off,
                              size: 48, color: AppColors.textSecondary),
                          const SizedBox(height: 12),
                          Text('Aucun praticien trouvé',
                              style: tt.bodyLarge),
                          const SizedBox(height: 4),
                          Text('Essayez d\'autres critères de recherche.',
                              style: tt.bodyMedium,
                              textAlign: TextAlign.center),
                        ],
                      ),
                    ),
                  ),
                )
              : SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (_, i) => PractitionerCard(
                        practitioner: list[i],
                        onTap: () => context
                            .push('/practitioners/${list[i].id}'),
                      ),
                      childCount: list.length,
                    ),
                  ),
                ),
          loading: () => const SliverToBoxAdapter(
            child: Center(
              child: Padding(
                padding: EdgeInsets.all(48),
                child: CircularProgressIndicator(),
              ),
            ),
          ),
          error: (e, _) => SliverToBoxAdapter(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    const Icon(Icons.wifi_off,
                        size: 40, color: AppColors.textSecondary),
                    const SizedBox(height: 12),
                    Text('Impossible de charger les praticiens.',
                        style: tt.bodyMedium, textAlign: TextAlign.center),
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: () => ref.refresh(practitionersProvider),
                      child: const Text('Réessayer'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Placeholder pour onglets non encore développés ─────────────────────────

class _PlaceholderTab extends StatelessWidget {
  final IconData icon;
  final String label;

  const _PlaceholderTab({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 56, color: AppColors.textSecondary),
          const SizedBox(height: 16),
          Text(label, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          Text('Bientôt disponible',
              style: Theme.of(context).textTheme.bodyMedium),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool active;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: active ? AppColors.primary : AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: active ? AppColors.primary : AppColors.textSecondary.withValues(alpha: 0.3),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: active ? Colors.white : AppColors.textSecondary,
            fontWeight: active ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}
