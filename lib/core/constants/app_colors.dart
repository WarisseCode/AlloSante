import 'package:flutter/material.dart';

/// Palette de couleurs AlloSanté Bénin
/// Basée sur l'analyse du site https://www.allosante.bj/
class AppColors {
  AppColors._();

  // === COULEURS PRIMAIRES ===
  /// Vert Teal Médical - Couleur de confiance principale
  static const Color primary = Color(0xFF00897B);
  static const Color primaryLight = Color(0xFF4DB6AC);
  static const Color primaryDark = Color(0xFF00695C);
  
  // === COULEURS SECONDAIRES (ACTION) ===
  /// Orange - Pour les boutons d'appel à l'action (Payer, Réserver)
  static const Color secondary = Color(0xFFFF9800);
  static const Color secondaryLight = Color(0xFFFFB74D);
  static const Color secondaryDark = Color(0xFFF57C00);
  
  // === COULEURS DE FOND ===
  static const Color background = Color(0xFFFFFFFF);
  static const Color backgroundGrey = Color(0xFFF5F5F5);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFFAFAFA);
  
  // === COULEURS DE TEXTE ===
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
  static const Color textHint = Color(0xFF9E9E9E);
  static const Color textOnPrimary = Color(0xFFFFFFFF);
  static const Color textOnSecondary = Color(0xFFFFFFFF);
  
  // === COULEURS D'ÉTAT ===
  static const Color success = Color(0xFF4CAF50);
  static const Color successLight = Color(0xFFE8F5E9);
  static const Color error = Color(0xFFE53935);
  static const Color errorLight = Color(0xFFFFEBEE);
  static const Color warning = Color(0xFFFFC107);
  static const Color warningLight = Color(0xFFFFF8E1);
  static const Color info = Color(0xFF2196F3);
  static const Color infoLight = Color(0xFFE3F2FD);
  
  // === COULEURS SPÉCIALES ===
  /// Couleur pour la bannière hors ligne
  static const Color offline = Color(0xFF616161);
  static const Color offlineLight = Color(0xFFEEEEEE);
  
  /// Couleurs Mobile Money
  static const Color mtnYellow = Color(0xFFFFCC00);
  static const Color mtnBlue = Color(0xFF003C71);
  static const Color celtiisGreen = Color(0xFF00A651);
  
  // === COULEURS DE BORDURE ===
  static const Color border = Color(0xFFE0E0E0);
  static const Color borderLight = Color(0xFFF5F5F5);
  static const Color divider = Color(0xFFE0E0E0);
  
  // === SHADOW ===
  static const Color shadow = Color(0x1A000000);
  static const Color shadowLight = Color(0x0D000000);
}
