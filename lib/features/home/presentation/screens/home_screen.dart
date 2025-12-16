import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/services/connectivity_service.dart';
import '../../../../core/widgets/offline_banner.dart';
import '../../../../core/widgets/primary_action_button.dart';
import '../../../appointments/domain/entities/doctor.dart';
import '../../../appointments/domain/entities/appointment.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import 'notifications_screen.dart';
import '../screens/search_filters_screen.dart';
import 'package:allosante_benin/features/appointments/presentation/providers/appointment_provider.dart';
import 'package:allosante_benin/features/appointments/presentation/screens/appointment_detail_screen.dart';
import 'package:allosante_benin/features/auth/presentation/screens/personal_info_screen.dart';
import 'package:allosante_benin/features/medical_record/presentation/screens/medical_record_screen.dart';
import 'package:allosante_benin/features/appointments/presentation/screens/doctor_detail_screen.dart';
import 'package:allosante_benin/features/payment/presentation/screens/payment_methods_screen.dart';
import '../../../settings/presentation/screens/settings_screen.dart';
import '../../../settings/presentation/screens/help_support_screen.dart';
import '../../../settings/presentation/screens/about_screen.dart';
import '../../../appointments/presentation/providers/doctor_provider.dart';

/// Écran d'accueil AlloSanté
/// Dashboard avec accès rapide aux fonctionnalités principales
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  // États pour les filtres rapides
  String? _selectedLocation;
  String? _selectedAvailability; // 'Maintenant', 'Tout'
  String? _selectedPrice; // '< 10k', 'Tout'

  @override
  void initState() {
    super.initState();
    // Charger les médecins depuis le backend au démarrage
    Future.microtask(() {
      context.read<DoctorProvider>().loadDoctors();
      context.read<AppointmentProvider>().loadAppointments();
    });
  }

  @override
  Widget build(BuildContext context) {
    final connectivity = context.watch<ConnectivityService>();
    final authProvider = context.watch<AuthProvider>();
    final user = authProvider.user;

    return OfflineAwareScaffold(
      isOffline: connectivity.isOffline,
      lastSyncTime: connectivity.lastSyncTime,
      onRetry: () => connectivity.checkConnection(),
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.local_hospital, size: 28),
            const SizedBox(width: 8),
            Text(AppConstants.appName),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const NotificationsScreen(),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsScreen()),
              );
            },
          ),
        ],
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          _buildHomeContent(user),
          _buildAppointmentsContent(),
          _buildSearchContent(),
          _buildProfileContent(user),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
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
            icon: Icon(Icons.search_outlined),
            activeIcon: Icon(Icons.search),
            label: 'Recherche',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profil',
          ),
        ],
      ),
      floatingActionButton: EmergencyButton(onPressed: _handleEmergency),
    );
  }

  Widget _buildHomeContent(user) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Message de bienvenue
          _buildWelcomeCard(user),

          const SizedBox(height: 24),

          // Actions rapides
          Text(
            'Actions rapides',
            style: Theme.of(context).textTheme.titleLarge,
          ),

          const SizedBox(height: 16),

          _buildQuickActions(),

          const SizedBox(height: 24),

          // Spécialités populaires
          Text('Spécialités', style: Theme.of(context).textTheme.titleLarge),

          const SizedBox(height: 16),

          _buildSpecialtiesGrid(),

          const SizedBox(height: 24),

          // Prochain RDV (si connecté)
          if (user != null) ...[
            Text(
              'Prochain rendez-vous',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            _buildNextAppointmentCard(),
          ],

          const SizedBox(height: 80), // Espace pour le FAB
        ],
      ),
    );
  }

  Widget _buildWelcomeCard(user) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.largePadding),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.primaryDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusLarge),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: Colors.white.withValues(alpha: 0.2),
                backgroundImage: user?.fullProfilePictureUrl != null
                    ? NetworkImage(user!.fullProfilePictureUrl!)
                    : null,
                child: user?.fullProfilePictureUrl == null
                    ? Text(
                        user?.initials ?? '👤',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      )
                    : null,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user != null
                          ? 'Bonjour, ${user.firstName} !'
                          : 'Bienvenue sur AlloSanté',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      AppConstants.appTagline,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withValues(alpha: 0.9),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          PrimaryActionButton(
            text: 'Prendre un rendez-vous',
            onPressed: () {
              setState(() => _selectedIndex = 2);
            },
            backgroundColor: Colors.white,
            foregroundColor: AppColors.primary,
            icon: Icons.add_circle_outline,
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return Row(
      children: [
        Expanded(
          child: _QuickActionCard(
            icon: Icons.medical_services,
            title: 'Trouver un\nmédecin',
            color: AppColors.primary,
            onTap: () => setState(() => _selectedIndex = 2),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _QuickActionCard(
            icon: Icons.calendar_month,
            title: 'Mes\nrendez-vous',
            color: AppColors.secondary,
            onTap: () => setState(() => _selectedIndex = 1),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _QuickActionCard(
            icon: Icons.qr_code,
            title: 'Mon\ndossier',
            color: AppColors.info,
            onTap: () {
              // Naviguer vers l'écran du dossier médical
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const MedicalRecordScreen(),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSpecialtiesGrid() {
    final specialties = [
      _SpecialtyItem(
        'Médecine Générale',
        Icons.local_hospital,
        AppColors.primary,
      ),
      _SpecialtyItem(
        'Gynécologie',
        Icons.pregnant_woman,
        const Color.fromARGB(255, 236, 47, 173),
      ),
      _SpecialtyItem('Pédiatrie', Icons.child_care, Colors.orange),
      _SpecialtyItem(
        'Cardiologie',
        Icons.favorite,
        const Color.fromARGB(255, 233, 20, 20),
      ),
      _SpecialtyItem('Dentiste', Icons.mood, Colors.blue),
      _SpecialtyItem('Plus...', Icons.more_horiz, AppColors.textSecondary),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1,
      ),
      itemCount: specialties.length,
      itemBuilder: (context, index) {
        final item = specialties[index];
        return _SpecialtyCard(
          title: item.title,
          icon: item.icon,
          color: item.color,
          onTap: () {
            // TODO: Filtrer par spécialité
            setState(() => _selectedIndex = 2);
          },
        );
      },
    );
  }

  Widget _buildNextAppointmentCard() {
    // Mock d'un prochain RDV
    return Container(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: AppColors.primaryLight.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.person,
                  color: AppColors.primary,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Dr. Mariama Sanni',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const Text(
                      'Pédiatrie',
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppColors.successLight,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'Confirmé',
                  style: TextStyle(
                    color: AppColors.success,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Row(
                  children: [
                    const Icon(
                      Icons.calendar_today,
                      size: 18,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Lundi 15 Janvier',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Row(
                  children: [
                    const Icon(
                      Icons.access_time,
                      size: 18,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '10:00',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAppointmentsContent() {
    // Données de démonstration pour les rendez-vous
    final appointmentProvider = context.watch<AppointmentProvider>();
    final appointments = appointmentProvider.appointments;

    if (appointmentProvider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (appointmentProvider.error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: AppColors.error),
            const SizedBox(height: 16),
            Text(
              appointmentProvider.error ?? 'Erreur de chargement',
              style: const TextStyle(color: AppColors.error),
              textAlign: TextAlign.center,
            ),
            TextButton(
              onPressed: () {
                context.read<AppointmentProvider>().loadAppointments();
              },
              child: const Text('Réessayer'),
            ),
          ],
        ),
      );
    }

    if (appointments.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.calendar_today,
              size: 80,
              color: AppColors.textSecondary.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'Mes rendez-vous',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'Vos rendez-vous apparaîtront ici',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 24),
            PrimaryActionButton(
              text: 'Prendre un rendez-vous',
              onPressed: () {
                setState(() => _selectedIndex = 2);
              },
              icon: Icons.add_circle_outline,
              width: 250,
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Mes rendez-vous à venir',
            style: Theme.of(context).textTheme.titleLarge,
          ),

          const SizedBox(height: 16),

          Expanded(
            child: ListView.separated(
              itemCount: appointments.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final appointment = appointments[index];
                return _AppointmentCard(
                  appointment: appointment,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            AppointmentDetailScreen(appointment: appointment),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          PrimaryActionButton(
            text: 'Prendre un rendez-vous',
            onPressed: () {
              setState(() => _selectedIndex = 2);
            },
            icon: Icons.add_circle_outline,
          ),
        ],
      ),
    );
  }

  Widget _buildSearchContent() {
    final doctorProvider = context.watch<DoctorProvider>();
    final doctors = doctorProvider.doctors;
    final isLoading = doctorProvider.isLoading;

    return Padding(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Barre de recherche
          TextField(
            decoration: InputDecoration(
              hintText: 'Rechercher un médecin...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: IconButton(
                icon: const Icon(Icons.tune),
                onPressed: () async {
                  final filters = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SearchFiltersScreen(),
                    ),
                  );

                  if (filters != null && mounted) {
                    // Appliquer les filtres
                    context.read<DoctorProvider>().loadDoctors(
                      location: filters['location'],
                      maxPrice: (filters['maxPrice'] as double?)?.toInt(),
                      specialty:
                          (filters['specialties'] as List?)?.isNotEmpty == true
                          ? (filters['specialties'] as List).first
                          : null, // Backend supports regex contains, so one is safer for now or loop?
                      // Backend logic I updated: if I pass partial string, it finds.
                      // But frontend sends List<String>.
                      // I decided earlier to send ONE specialty because backend 'specialty' param is string.
                      // Wait, checking my backend update.
                      // Backend 'specialty' is string.
                      // So I take the first one if multiple selected.
                      languages: (filters['languages'] as List?)
                          ?.cast<String>(),
                      isAvailable: filters['availableNow'] == true
                          ? true
                          : null,
                      minRating: (filters['minRating'] as double?) != 0
                          ? filters['minRating']
                          : null,
                    );
                  }
                },
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Filtres rapides
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                // Ville Dropdown
                _buildFilterDropdown<String>(
                  value: _selectedLocation,
                  hint: 'Ville',
                  items: [
                    'Toutes',
                    'Cotonou',
                    'Porto-Novo',
                    'Parakou',
                    'Abomey-Calavi',
                    'Bohicon',
                    'Natitingou',
                  ],
                  onChanged: (value) {
                    setState(() => _selectedLocation = value);
                    _applyQuickFilters();
                  },
                ),
                const SizedBox(width: 8),

                // Disponibilité Dropdown
                _buildFilterDropdown<String>(
                  value: _selectedAvailability,
                  hint: 'Disponibilité',
                  items: ['Tout', 'Maintenant'],
                  onChanged: (value) {
                    setState(() => _selectedAvailability = value);
                    _applyQuickFilters();
                  },
                ),
                const SizedBox(width: 8),

                // Prix Dropdown
                _buildFilterDropdown<String>(
                  value: _selectedPrice,
                  hint: 'Prix',
                  items: ['Tout', 'Abordable (< 10k)'],
                  onChanged: (value) {
                    setState(() => _selectedPrice = value);
                    _applyQuickFilters();
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          Text(
            'Médecins disponibles',
            style: Theme.of(context).textTheme.titleLarge,
          ),

          const SizedBox(height: 16),

          // Liste des médecins depuis le backend
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : doctors.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.search_off,
                          size: 64,
                          color: AppColors.textSecondary.withValues(alpha: 0.5),
                        ),
                        const SizedBox(height: 16),
                        const Text('Aucun médecin trouvé'),
                        const SizedBox(height: 8),
                        TextButton(
                          onPressed: () => doctorProvider.loadDoctors(),
                          child: const Text('Réessayer'),
                        ),
                      ],
                    ),
                  )
                : ListView.separated(
                    itemCount: doctors.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final doctor = doctors[index];
                      return _DoctorCard(
                        doctor: doctor,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  DoctorDetailScreen(doctor: doctor),
                            ),
                          );
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileContent(user) {
    final authProvider = context.read<AuthProvider>();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      child: Column(
        children: [
          // Avatar et nom
          CircleAvatar(
            radius: 50,
            backgroundColor: AppColors.primaryLight,
            backgroundImage: user?.fullProfilePictureUrl != null
                ? NetworkImage(user!.fullProfilePictureUrl!)
                : null,
            child: user?.fullProfilePictureUrl == null
                ? Text(
                    user?.initials ?? '👤',
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  )
                : null,
          ),
          const SizedBox(height: 16),
          Text(
            user?.fullName ?? 'Utilisateur',
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          Text(
            user?.email ?? '',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
          ),

          const SizedBox(height: 32),

          // Menu profil
          _ProfileMenuItem(
            icon: Icons.person_outline,
            title: 'Informations personnelles',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const PersonalInfoScreen(),
                ),
              );
            },
          ),
          _ProfileMenuItem(
            icon: Icons.folder_outlined,
            title: 'Mon dossier médical',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const MedicalRecordScreen(),
                ),
              );
            },
          ),
          _ProfileMenuItem(
            icon: Icons.payment_outlined,
            title: 'Moyens de paiement',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const PaymentMethodsScreen(),
                ),
              );
            },
          ),
          _ProfileMenuItem(
            icon: Icons.settings_outlined,
            title: 'Paramètres',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsScreen()),
              );
            },
          ),
          _ProfileMenuItem(
            icon: Icons.help_outline,
            title: 'Aide & Support',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const HelpSupportScreen(),
                ),
              );
            },
          ),
          _ProfileMenuItem(
            icon: Icons.info_outline,
            title: 'À propos',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AboutScreen()),
              );
            },
          ),

          const SizedBox(height: 24),

          // Bouton déconnexion
          SecondaryActionButton(
            text: 'Déconnexion',
            onPressed: () => authProvider.logout(),
            icon: Icons.logout,
            borderColor: AppColors.error,
            textColor: AppColors.error,
          ),
        ],
      ),
    );
  }

  void _handleEmergency() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Urgence'),
          content: const Text(
            'Voulez-vous appeler les services d\'urgence (118) ?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Annuler'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _makeEmergencyCall();
              },
              child: const Text(
                'APPELER',
                style: TextStyle(
                  color: AppColors.error,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildFilterDropdown<T>({
    required T? value,
    required String hint,
    required List<T> items,
    required ValueChanged<T?> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
      decoration: BoxDecoration(
        color: value != null
            ? AppColors.primaryLight.withValues(alpha: 0.2)
            : AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: value != null ? AppColors.primary : AppColors.border,
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: value,
          hint: Text(
            hint,
            style: TextStyle(
              color: value != null
                  ? AppColors.primary
                  : AppColors.textSecondary,
              fontSize: 13,
              fontWeight: value != null ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
          icon: Icon(
            Icons.arrow_drop_down,
            color: value != null ? AppColors.primary : AppColors.textSecondary,
            size: 20,
          ),
          isDense: true,
          items: items.map((T item) {
            return DropdownMenuItem<T>(
              value: item,
              child: Text(
                item.toString(),
                style: const TextStyle(fontSize: 13),
              ),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  void _applyQuickFilters() {
    context.read<DoctorProvider>().loadDoctors(
      location: _selectedLocation == 'Toutes' ? null : _selectedLocation,
      isAvailable: _selectedAvailability == 'Maintenant' ? true : null,
      maxPrice: _selectedPrice == 'Abordable (< 10k)' ? 10000 : null,
    );
  }

  Future<void> _makeEmergencyCall() async {
    final Uri emergencyLaunchUri = Uri(scheme: 'tel', path: '118');
    try {
      if (await canLaunchUrl(emergencyLaunchUri)) {
        await launchUrl(emergencyLaunchUri);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Impossible de lancer l\'appel')),
          );
        }
      }
    } catch (e) {
      debugPrint('Error launching emergency call: $e');
    }
  }

  Future<void> _openFilters([Map<String, dynamic>? initialFilters]) async {
    final filters = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            SearchFiltersScreen(initialFilters: initialFilters ?? {}),
      ),
    );

    if (filters != null && mounted) {
      context.read<DoctorProvider>().loadDoctors(
        location: filters['location'],
        maxPrice: (filters['maxPrice'] as double?)?.toInt(),
        specialty: (filters['specialties'] as List?)?.isNotEmpty == true
            ? (filters['specialties'] as List).first
            : null,
        languages: (filters['languages'] as List?)?.cast<String>(),
        isAvailable: filters['availableNow'] == true ? true : null,
        minRating: (filters['minRating'] as double?) != 0
            ? filters['minRating']
            : null,
        gender: filters['gender'],
      );
    }
  }
}

// ============================================================
// WIDGETS HELPERS
// ============================================================

class _QuickActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionCard({
    required this.icon,
    required this.title,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppConstants.borderRadius),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(AppConstants.borderRadius),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SpecialtyItem {
  final String title;
  final IconData icon;
  final Color color;

  _SpecialtyItem(this.title, this.icon, this.color);
}

class _SpecialtyCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _SpecialtyCard({
    required this.title,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppConstants.borderRadius),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppConstants.borderRadius),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadowLight,
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

class _DoctorCard extends StatelessWidget {
  final Doctor doctor;
  final VoidCallback onTap;

  const _DoctorCard({required this.doctor, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppConstants.borderRadius),
      child: Container(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppConstants.borderRadius),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadow,
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 28,
              backgroundColor: AppColors.primaryLight,
              child: Text(
                doctor.initials,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    doctor.fullName,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    doctor.specialty,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 14,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.star, size: 16, color: Colors.amber),
                      const SizedBox(width: 4),
                      Text(
                        doctor.formattedRating,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(
                        Icons.location_on,
                        size: 14,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: 2),
                      Flexible(
                        child: Text(
                          doctor.location,
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 13,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  doctor.formattedPrice,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.successLight,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'Disponible',
                    style: TextStyle(
                      fontSize: 11,
                      color: AppColors.success,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileMenuItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _ProfileMenuItem({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: AppColors.textSecondary),
      title: Text(title),
      trailing: const Icon(Icons.chevron_right, color: AppColors.textSecondary),
      onTap: onTap,
    );
  }
}

class EmergencyButton extends StatelessWidget {
  final VoidCallback onPressed;

  const EmergencyButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: AppColors.error.withValues(alpha: 0.4),
            blurRadius: 12,
            spreadRadius: 2,
          ),
        ],
      ),
      child: FloatingActionButton(
        onPressed: onPressed,
        backgroundColor: AppColors.error,
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.emergency, size: 24),
            Text(
              'SOS',
              style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}

/// Carte de rendez-vous pour la liste
class _AppointmentCard extends StatelessWidget {
  final Appointment appointment;
  final VoidCallback onTap;

  const _AppointmentCard({required this.appointment, required this.onTap});

  @override
  Widget build(BuildContext context) {
    // Déterminer le statut et la couleur appropriés
    Color statusColor;
    String statusText;

    switch (appointment.status) {
      case AppointmentStatus.confirmed:
        statusColor = AppColors.success;
        statusText = 'Confirmé';
        break;
      case AppointmentStatus.pending:
        statusColor = AppColors.warning;
        statusText = 'En attente';
        break;
      case AppointmentStatus.cancelled:
        statusColor = AppColors.error;
        statusText = 'Annulé';
        break;
      case AppointmentStatus.completed:
        statusColor = AppColors.info;
        statusText = 'Terminé';
        break;
      default:
        statusColor = AppColors.textSecondary;
        statusText = 'Inconnu';
    }

    // Vérifier si le médecin existe
    final doctor = appointment.doctor;

    return Card(
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        child: Container(
          padding: const EdgeInsets.all(AppConstants.defaultPadding),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppConstants.borderRadius),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // En-tête avec médecin et statut
              Row(
                children: [
                  // Avatar du médecin
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: AppColors.primaryLight,
                    child: Text(
                      doctor?.initials ?? '?',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontSize: 12,
                      ),
                    ),
                  ),

                  const SizedBox(width: 12),

                  // Informations du médecin
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          doctor?.fullName ?? 'Médecin inconnu',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          doctor?.specialty ?? 'Spécialité inconnue',
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Statut
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      statusText,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: statusColor,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Date et heure
              Row(
                children: [
                  const Icon(
                    Icons.calendar_today,
                    size: 16,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${appointment.appointmentDate.day}/${appointment.appointmentDate.month}/${appointment.appointmentDate.year}',
                    style: const TextStyle(color: AppColors.textSecondary),
                  ),
                  const SizedBox(width: 16),
                  const Icon(
                    Icons.access_time,
                    size: 16,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    appointment.timeSlot,
                    style: const TextStyle(color: AppColors.textSecondary),
                  ),
                ],
              ),

              const SizedBox(height: 8),

              // Lieu
              Row(
                children: [
                  const Icon(
                    Icons.location_on,
                    size: 16,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      doctor?.location ?? 'Lieu inconnu',
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 13,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
