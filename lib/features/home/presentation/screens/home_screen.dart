import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/services/connectivity_service.dart';
import '../../../../core/widgets/offline_banner.dart';
import '../../../../core/widgets/primary_action_button.dart';
import '../../../appointments/domain/entities/doctor.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

/// Écran d'accueil AlloSanté
/// Dashboard avec accès rapide aux fonctionnalités principales
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

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
              // TODO: Notifications
            },
          ),
          IconButton(
            icon: const Icon(Icons.person_outline),
            onPressed: () {
              // TODO: Profil
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
      floatingActionButton: const EmergencyButton(
        onPressed: _handleEmergency,
      ),
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
          Text(
            'Spécialités',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          
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
                child: Text(
                  user?.initials ?? '👤',
                  style: const TextStyle(
                    fontSize: 20,
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
              // TODO: QR Code dossier médical
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSpecialtiesGrid() {
    final specialties = [
      _SpecialtyItem('Médecine Générale', Icons.local_hospital, AppColors.primary),
      _SpecialtyItem('Gynécologie', Icons.pregnant_woman, Colors.pink),
      _SpecialtyItem('Pédiatrie', Icons.child_care, Colors.orange),
      _SpecialtyItem('Cardiologie', Icons.favorite, Colors.red),
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
                      style: TextStyle(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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
                    const Icon(Icons.calendar_today, size: 18, color: AppColors.textSecondary),
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
                    const Icon(Icons.access_time, size: 18, color: AppColors.textSecondary),
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
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchContent() {
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
                onPressed: () {
                  // TODO: Filtres
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
                _FilterChip(label: 'Cotonou', isSelected: true),
                const SizedBox(width: 8),
                _FilterChip(label: 'Disponible maintenant'),
                const SizedBox(width: 8),
                _FilterChip(label: 'Tarif abordable'),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          Text(
            'Médecins disponibles',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          
          const SizedBox(height: 16),
          
          // Liste des médecins (mock)
          Expanded(
            child: ListView.separated(
              itemCount: 4,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                return _DoctorCard(
                  doctor: Doctor(
                    id: 'doc_$index',
                    firstName: index == 0 ? 'Aminou' : 
                              index == 1 ? 'Aïcha' :
                              index == 2 ? 'Koffi' : 'Mariama',
                    lastName: index == 0 ? 'Kouyaté' : 
                             index == 1 ? 'Dossou' :
                             index == 2 ? 'Agbossou' : 'Sanni',
                    specialty: index == 0 ? 'Médecine Générale' : 
                              index == 1 ? 'Gynécologie' :
                              index == 2 ? 'Cardiologie' : 'Pédiatrie',
                    location: index == 2 ? 'Porto-Novo' : 'Cotonou',
                    rating: 4.5 + (index * 0.1),
                    reviewCount: 50 + (index * 20),
                    consultationPrice: 10000 + (index * 5000),
                    languages: ['Français', 'Fon'],
                    availableDays: ['Lundi', 'Mercredi', 'Vendredi'],
                    isAvailable: true,
                    experienceYears: 8 + index,
                  ),
                  onTap: () {
                    // TODO: Détail du médecin
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
            child: Text(
              user?.initials ?? '👤',
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            user?.fullName ?? 'Utilisateur',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            user?.email ?? '',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          
          const SizedBox(height: 32),
          
          // Menu profil
          _ProfileMenuItem(
            icon: Icons.person_outline,
            title: 'Informations personnelles',
            onTap: () {},
          ),
          _ProfileMenuItem(
            icon: Icons.folder_outlined,
            title: 'Mon dossier médical',
            onTap: () {},
          ),
          _ProfileMenuItem(
            icon: Icons.payment_outlined,
            title: 'Moyens de paiement',
            onTap: () {},
          ),
          _ProfileMenuItem(
            icon: Icons.notifications_outlined,
            title: 'Notifications',
            onTap: () {},
          ),
          _ProfileMenuItem(
            icon: Icons.help_outline,
            title: 'Aide & Support',
            onTap: () {},
          ),
          _ProfileMenuItem(
            icon: Icons.info_outline,
            title: 'À propos',
            onTap: () {},
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

  static void _handleEmergency() {
    // TODO: Gestion des urgences
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
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;

  const _FilterChip({
    required this.label,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) {},
      selectedColor: AppColors.primaryLight,
      checkmarkColor: AppColors.primary,
    );
  }
}

class _DoctorCard extends StatelessWidget {
  final Doctor doctor;
  final VoidCallback onTap;

  const _DoctorCard({
    required this.doctor,
    required this.onTap,
  });

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
                  ),
                  Text(
                    doctor.specialty,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 14,
                    ),
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
                      Icon(Icons.location_on, size: 14, color: AppColors.textSecondary),
                      const SizedBox(width: 2),
                      Text(
                        doctor.location,
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 13,
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
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
            Text('SOS', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}
