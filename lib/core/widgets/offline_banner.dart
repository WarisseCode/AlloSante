import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_constants.dart';

/// Bannière d'avertissement de connexion hors ligne
/// S'affiche de manière discrète en haut de l'écran lorsque
/// la connectivité est perdue
class OfflineBanner extends StatefulWidget {
  const OfflineBanner({
    super.key,
    required this.isOffline,
    this.lastSyncTime,
    this.onRetry,
    this.showRetryButton = true,
    this.animate = true,
  });

  /// État de la connectivité
  final bool isOffline;
  
  /// Dernière heure de synchronisation
  final DateTime? lastSyncTime;
  
  /// Callback pour réessayer la connexion
  final VoidCallback? onRetry;
  
  /// Afficher le bouton de réessai
  final bool showRetryButton;
  
  /// Animer l'apparition/disparition
  final bool animate;

  @override
  State<OfflineBanner> createState() => _OfflineBannerState();
}

class _OfflineBannerState extends State<OfflineBanner>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: AppConstants.animationNormal,
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    if (widget.isOffline) {
      _controller.forward();
    }
  }

  @override
  void didUpdateWidget(OfflineBanner oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isOffline != oldWidget.isOffline) {
      if (widget.isOffline) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String _getLastSyncText() {
    if (widget.lastSyncTime == null) {
      return 'Données en cache';
    }
    
    final now = DateTime.now();
    final difference = now.difference(widget.lastSyncTime!);
    
    if (difference.inMinutes < 1) {
      return 'Dernière synchro: à l\'instant';
    } else if (difference.inMinutes < 60) {
      return 'Dernière synchro: il y a ${difference.inMinutes} min';
    } else if (difference.inHours < 24) {
      return 'Dernière synchro: il y a ${difference.inHours}h';
    } else {
      return 'Dernière synchro: il y a ${difference.inDays} jour(s)';
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.animate) {
      return widget.isOffline ? _buildBanner() : const SizedBox.shrink();
    }

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        if (_controller.value == 0 && !widget.isOffline) {
          return const SizedBox.shrink();
        }
        
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, -1),
            end: Offset.zero,
          ).animate(CurvedAnimation(
            parent: _controller,
            curve: Curves.easeOut,
          )),
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: _buildBanner(),
          ),
        );
      },
    );
  }

  Widget _buildBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.defaultPadding,
        vertical: 10,
      ),
      decoration: BoxDecoration(
        color: AppColors.offline,
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: Row(
          children: [
            // Icône hors ligne
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Icon(
                Icons.wifi_off_rounded,
                color: Colors.white,
                size: 18,
              ),
            ),
            const SizedBox(width: 12),
            
            // Texte
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Mode hors ligne',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _getLastSyncText(),
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.8),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            
            // Bouton réessayer
            if (widget.showRetryButton && widget.onRetry != null)
              TextButton(
                onPressed: widget.onRetry,
                style: TextButton.styleFrom(
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  minimumSize: const Size(0, 36),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.refresh, size: 16),
                    SizedBox(width: 4),
                    Text(
                      'Réessayer',
                      style: TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Widget wrapper qui affiche la bannière hors ligne au-dessus du contenu
class OfflineAwareScaffold extends StatelessWidget {
  const OfflineAwareScaffold({
    super.key,
    required this.isOffline,
    required this.body,
    this.appBar,
    this.floatingActionButton,
    this.bottomNavigationBar,
    this.drawer,
    this.lastSyncTime,
    this.onRetry,
    this.backgroundColor,
  });

  final bool isOffline;
  final Widget body;
  final PreferredSizeWidget? appBar;
  final Widget? floatingActionButton;
  final Widget? bottomNavigationBar;
  final Widget? drawer;
  final DateTime? lastSyncTime;
  final VoidCallback? onRetry;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: appBar,
      drawer: drawer,
      floatingActionButton: floatingActionButton,
      bottomNavigationBar: bottomNavigationBar,
      body: Column(
        children: [
          OfflineBanner(
            isOffline: isOffline,
            lastSyncTime: lastSyncTime,
            onRetry: onRetry,
          ),
          Expanded(child: body),
        ],
      ),
    );
  }
}
