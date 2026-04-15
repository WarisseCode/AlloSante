import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/practitioners_repository.dart';
import '../../domain/practitioner_model.dart';

final practitionersRepositoryProvider =
    Provider((_) => PractitionersRepository());

// ─── Spécialités ─────────────────────────────────────────────────────────────

final specialtiesProvider = FutureProvider<List<SpecialtyModel>>((ref) {
  return ref.read(practitionersRepositoryProvider).getSpecialties();
});

// ─── Filtres de recherche ────────────────────────────────────────────────────

class SearchFilters {
  final String query;
  final String? specialtySlug;
  final bool availableToday;
  final bool teleconsultation;
  final int? maxFee;

  const SearchFilters({
    this.query = '',
    this.specialtySlug,
    this.availableToday = false,
    this.teleconsultation = false,
    this.maxFee,
  });

  SearchFilters copyWith({
    String? query,
    String? specialtySlug,
    bool? availableToday,
    bool? teleconsultation,
    int? maxFee,
    bool clearSpecialty = false,
  }) =>
      SearchFilters(
        query: query ?? this.query,
        specialtySlug: clearSpecialty ? null : (specialtySlug ?? this.specialtySlug),
        availableToday: availableToday ?? this.availableToday,
        teleconsultation: teleconsultation ?? this.teleconsultation,
        maxFee: maxFee ?? this.maxFee,
      );
}

final searchFiltersProvider =
    StateProvider<SearchFilters>((_) => const SearchFilters());

// ─── Liste des praticiens ────────────────────────────────────────────────────

final practitionersProvider =
    FutureProvider<List<PractitionerModel>>((ref) async {
  final filters = ref.watch(searchFiltersProvider);
  final repo = ref.read(practitionersRepositoryProvider);

  return repo.getPractitioners(
    query: filters.query.isNotEmpty ? filters.query : null,
    specialty: filters.specialtySlug,
    availableToday: filters.availableToday ? true : null,
    teleconsultation: filters.teleconsultation ? true : null,
    maxFee: filters.maxFee,
  );
});
