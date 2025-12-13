# AlloSanté Bénin 🏥

[![Flutter](https://img.shields.io/badge/Flutter-3.35.4-blue.svg)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.9.2-blue.svg)](https://dart.dev)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

**Votre santé, notre affaire au quotidien**

Application mobile de prise de rendez-vous médicaux conçue pour le marché ouest-africain, avec une architecture **Offline-First** optimisée pour les conditions réseau du Bénin.

## 🎯 Fonctionnalités

### ✅ Implémentées (MVP)

- **🎨 Design System**
  - Thème conforme au site [allosante.bj](https://www.allosante.bj/)
  - Palette Teal (#00897B) / Orange (#FF9800)
  - Widgets réutilisables (PrimaryActionButton, OfflineBanner, SecureInputField)

- **🔐 Authentification Sécurisée (MFA)**
  - Connexion par email/mot de passe
  - Vérification OTP par SMS
  - Stockage sécurisé des tokens JWT

- **📱 Architecture Offline-First**
  - Cache local avec Hive
  - Détection de connectivité
  - Stratégie Stale-While-Revalidate
  - File d'attente de synchronisation

- **📅 Prise de Rendez-vous**
  - Recherche par spécialité et localisation
  - Sélection de créneaux horaires
  - Historique des rendez-vous

- **💳 Paiement Mobile Money**
  - MTN MoMo
  - Celtiis Cash
  - Validation des numéros béninois
  - Flux asynchrone avec polling

## 📁 Architecture

```
lib/
├── core/
│   ├── constants/      # Couleurs, constantes
│   ├── services/       # ConnectivityService
│   ├── storage/        # LocalStorage, SecureStorage
│   ├── theme/          # AlloSanteTheme
│   └── widgets/        # Widgets réutilisables
├── features/
│   ├── auth/           # Authentification
│   │   ├── data/
│   │   │   └── repositories/
│   │   ├── domain/
│   │   │   └── entities/
│   │   └── presentation/
│   │       ├── providers/
│   │       ├── screens/
│   │       └── widgets/
│   ├── appointments/   # Rendez-vous
│   ├── payment/        # Paiement Mobile Money
│   └── home/           # Écran d'accueil
└── main.dart
```

## 🛠 Technologies

| Catégorie | Package | Version |
|-----------|---------|---------|
| State Management | Provider | 6.1.5+1 |
| Local Storage | Hive | 2.2.3 |
| Secure Storage | flutter_secure_storage | 9.2.3 |
| HTTP Client | Dio | 5.8.0+1 |
| Connectivity | connectivity_plus | 6.1.3 |
| Navigation | go_router | 14.8.1 |

## 🚀 Installation

```bash
# Cloner le dépôt
git clone https://github.com/WarisseCode/AlloSante.git
cd AlloSante

# Installer les dépendances
flutter pub get

# Lancer l'application
flutter run
```

## 📱 Captures d'écran

### Écran de Connexion
- Email et mot de passe
- Design conforme à allosante.bj

### Vérification OTP
- Code SMS à 6 chiffres
- Minuteur de renvoi

### Dashboard
- Actions rapides
- Spécialités médicales
- Prochain rendez-vous

### Paiement Mobile Money
- Sélection MTN MoMo / Celtiis Cash
- Validation des préfixes béninois
- Interface de confirmation USSD

## 🧪 Tests

```bash
# Lancer tous les tests
flutter test

# Tests avec couverture
flutter test --coverage
```

## 📋 Validation Téléphone Bénin

| Opérateur | Préfixes valides |
|-----------|------------------|
| MTN MoMo | 96, 97, 98, 99 |
| Celtiis Cash | 94, 95 |

## 🔧 Configuration Backend (Mock)

L'application utilise actuellement des données mockées pour :
- API d'authentification
- Liste des médecins
- Créneaux horaires
- Transactions Mobile Money

Pour connecter à un vrai backend, modifier les repositories dans `lib/features/*/data/repositories/`.

## 📝 Pattern de Gestion d'État

### Provider Pattern

```dart
// PaymentProvider pour le flux de paiement asynchrone
class PaymentProvider extends ChangeNotifier {
  PaymentFlowStatus _status = PaymentFlowStatus.initial;
  
  Future<bool> initiatePayment({...}) async {
    _status = PaymentFlowStatus.processing;
    notifyListeners();
    
    // Appel API...
    
    _status = PaymentFlowStatus.awaitingConfirmation;
    _startPolling();
    notifyListeners();
  }
}
```

### États du flux de paiement

```
initial → selectingMethod → enteringPhone → processing 
    → awaitingConfirmation → success/failed/expired
```

## 🤝 Contribution

1. Fork le projet
2. Créer une branche (`git checkout -b feature/AmazingFeature`)
3. Commit (`git commit -m 'Add AmazingFeature'`)
4. Push (`git push origin feature/AmazingFeature`)
5. Ouvrir une Pull Request

## 📄 Licence

Distribué sous licence MIT. Voir `LICENSE` pour plus d'informations.

## 📞 Contact

AlloSanté Bénin - [@allosantebj](https://twitter.com/allosantebj)

Site web: [https://www.allosante.bj](https://www.allosante.bj)
