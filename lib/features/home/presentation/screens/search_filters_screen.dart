import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/widgets/primary_action_button.dart';

/// Écran de filtres de recherche avancés
class SearchFiltersScreen extends StatefulWidget {
  final Map<String, dynamic> initialFilters;

  const SearchFiltersScreen({super.key, this.initialFilters = const {}});

  @override
  State<SearchFiltersScreen> createState() => _SearchFiltersScreenState();
}

class _SearchFiltersScreenState extends State<SearchFiltersScreen> {
  // Contrôleurs pour les filtres
  late String _selectedLocation;
  late double _maxPrice;
  late List<String> _selectedSpecialties;
  late List<String> _selectedLanguages;
  late bool _availableNow;
  late double _minRating;
  String? _selectedGender;

  // Options disponibles
  final List<String> _locations = [
    'Cotonou',
    'Porto-Novo',
    'Parakou',
    'Abomey-Calavi',
    'Bohicon',
    'Natitingou',
  ];

  final List<String> _specialties = [
    'Médecine Générale',
    'Pédiatrie',
    'Gynécologie',
    'Cardiologie',
    'Dermatologie',
    'Ophtalmologie',
    'Orthopédie',
    'Psychiatrie',
  ];

  final List<String> _languages = ['Français', 'Fon', 'Yoruba', 'Anglais'];

  @override
  void initState() {
    super.initState();
    // Initialiser avec les filtres passés ou des valeurs par défaut
    _selectedLocation = widget.initialFilters['location'] ?? _locations.first;
    _maxPrice = widget.initialFilters['maxPrice'] ?? 50000.0;
    _selectedSpecialties = List<String>.from(
      widget.initialFilters['specialties'] ?? [],
    );
    _selectedLanguages = List<String>.from(
      widget.initialFilters['languages'] ?? [],
    );
    _availableNow = widget.initialFilters['availableNow'] ?? false;
    _minRating = widget.initialFilters['minRating'] ?? 0.0;
    _selectedGender = widget.initialFilters['gender'];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Filtres de recherche'),
        centerTitle: true,
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _resetFilters),
        ],
      ),
      body: Column(
        children: [
          // Filtres appliqués
          _buildAppliedFilters(),

          const SizedBox(height: 16),

          // Liste des filtres
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppConstants.defaultPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Emplacement
                  _buildLocationFilter(),

                  const SizedBox(height: 24),

                  // Prix maximum
                  _buildPriceFilter(),

                  const SizedBox(height: 24),

                  // Spécialités
                  _buildSpecialtiesFilter(),

                  const SizedBox(height: 24),

                  // Genre
                  _buildGenderFilter(),

                  const SizedBox(height: 24),

                  // Langues
                  _buildLanguagesFilter(),

                  const SizedBox(height: 24),

                  // Disponibilité immédiate
                  _buildAvailabilityFilter(),

                  const SizedBox(height: 24),

                  // Note minimale
                  _buildRatingFilter(),

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),

          // Boutons d'action
          _buildActionButtons(),
        ],
      ),
    );
  }

  Widget _buildAppliedFilters() {
    final appliedFilters = _getAppliedFiltersCount();

    if (appliedFilters == 0) {
      return Container();
    }

    return Container(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      decoration: BoxDecoration(
        color: AppColors.primaryLight.withValues(alpha: 0.1),
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '$appliedFilters filtre(s) appliqué(s)',
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
            ),
          ),
          TextButton(
            onPressed: _resetFilters,
            child: const Text(
              'Réinitialiser',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationFilter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Localisation',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),

        const SizedBox(height: 12),

        DropdownButtonFormField<String>(
          value: _selectedLocation,
          decoration: const InputDecoration(hintText: 'Sélectionnez une ville'),
          items: _locations.map((location) {
            return DropdownMenuItem(value: location, child: Text(location));
          }).toList(),
          onChanged: (value) {
            if (value != null) {
              setState(() => _selectedLocation = value);
            }
          },
        ),
      ],
    );
  }

  Widget _buildPriceFilter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Prix maximum',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              '${_maxPrice.toInt()} FCFA',
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),

        Slider(
          value: _maxPrice,
          min: 0,
          max: 100000,
          divisions: 20,
          label: '${_maxPrice.toInt()} FCFA',
          activeColor: AppColors.primary,
          inactiveColor: AppColors.border,
          onChanged: (value) {
            setState(() => _maxPrice = value);
          },
        ),

        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [Text('0 FCFA'), Text('100 000 FCFA')],
        ),
      ],
    );
  }

  Widget _buildSpecialtiesFilter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Spécialités',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),

        const SizedBox(height: 12),

        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _specialties.map((specialty) {
            final isSelected = _selectedSpecialties.contains(specialty);
            return FilterChip(
              label: Text(specialty),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  if (selected) {
                    _selectedSpecialties.add(specialty);
                  } else {
                    _selectedSpecialties.remove(specialty);
                  }
                });
              },
              selectedColor: AppColors.primaryLight,
              checkmarkColor: AppColors.primary,
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildGenderFilter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Genre du médecin',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          children: [
            ChoiceChip(
              label: const Text('Tous'),
              selected: _selectedGender == null,
              onSelected: (selected) {
                if (selected) setState(() => _selectedGender = null);
              },
              selectedColor: AppColors.primaryLight,
              checkmarkColor: AppColors.primary,
            ),
            ChoiceChip(
              label: const Text('Homme'),
              selected: _selectedGender == 'MALE',
              onSelected: (selected) {
                setState(() => _selectedGender = selected ? 'MALE' : null);
              },
              selectedColor: AppColors.primaryLight,
              checkmarkColor: AppColors.primary,
            ),
            ChoiceChip(
              label: const Text('Femme'),
              selected: _selectedGender == 'FEMALE',
              onSelected: (selected) {
                setState(() => _selectedGender = selected ? 'FEMALE' : null);
              },
              selectedColor: AppColors.primaryLight,
              checkmarkColor: AppColors.primary,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildLanguagesFilter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Langues parlées',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),

        const SizedBox(height: 12),

        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _languages.map((language) {
            final isSelected = _selectedLanguages.contains(language);
            return FilterChip(
              label: Text(language),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  if (selected) {
                    _selectedLanguages.add(language);
                  } else {
                    _selectedLanguages.remove(language);
                  }
                });
              },
              selectedColor: AppColors.primaryLight,
              checkmarkColor: AppColors.primary,
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildAvailabilityFilter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Disponibilité',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),

        const SizedBox(height: 12),

        SwitchListTile(
          title: const Text('Disponible maintenant'),
          value: _availableNow,
          activeColor: AppColors.primary,
          onChanged: (value) {
            setState(() => _availableNow = value);
          },
        ),
      ],
    );
  }

  Widget _buildRatingFilter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Note minimale',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              '${_minRating.toStringAsFixed(1)} ★',
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),

        Slider(
          value: _minRating,
          min: 0,
          max: 5,
          divisions: 10,
          label: '${_minRating.toStringAsFixed(1)} étoiles',
          activeColor: AppColors.primary,
          inactiveColor: AppColors.border,
          onChanged: (value) {
            setState(() => _minRating = value);
          },
        ),

        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [Text('0 ★'), Text('5 ★')],
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Container(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Bouton d'annulation
          Expanded(
            child: OutlinedButton(
              onPressed: () => Navigator.of(context).pop(),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                side: const BorderSide(color: AppColors.border),
              ),
              child: const Text('Annuler'),
            ),
          ),

          const SizedBox(width: 12),

          // Bouton d'application des filtres
          Expanded(
            flex: 2,
            child: PrimaryActionButton(
              text: 'Appliquer',
              onPressed: _applyFilters,
              icon: Icons.check,
            ),
          ),
        ],
      ),
    );
  }

  int _getAppliedFiltersCount() {
    int count = 0;

    // Localisation différente de la première option
    if (_selectedLocation != _locations.first) count++;

    // Prix maximum différent de 50000
    if (_maxPrice != 50000.0) count++;

    // Spécialités sélectionnées
    if (_selectedSpecialties.isNotEmpty) count++;

    // Langues sélectionnées
    if (_selectedLanguages.isNotEmpty) count++;

    // Disponible maintenant
    if (_availableNow) count++;

    // Note minimale différente de 0
    if (_minRating > 0) count++;

    // Genre sélectionné
    if (_selectedGender != null) count++;

    return count;
  }

  void _resetFilters() {
    setState(() {
      _selectedLocation = _locations.first;
      _maxPrice = 50000.0;
      _selectedSpecialties.clear();
      _selectedLanguages.clear();
      _availableNow = false;
      _minRating = 0.0;
      _selectedGender = null;
    });
  }

  void _applyFilters() {
    final filters = {
      'location': _selectedLocation,
      'maxPrice': _maxPrice,
      'specialties': _selectedSpecialties,
      'languages': _selectedLanguages,
      'availableNow': _availableNow,
      'minRating': _minRating,
      'gender': _selectedGender,
    };

    // Retourner les filtres à l'écran appelant
    Navigator.of(context).pop(filters);
  }
}
