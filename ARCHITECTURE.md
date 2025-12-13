# Architecture & Guide Technique - AlloSanté Bénin

## 1. Architecture Flutter/PWA "Offline-First"

### A. Stack Technologique & Packages Clés
L'architecture suit le principe de **Clean Architecture** (Presentation, Domain, Data) pour garantir la maintenabilité et la testabilité.

*   **Gestion d'État :** `Provider` (ou `Riverpod`). Simple, efficace pour PWA et Mobile.
*   **Persistance Locale (Offline-First) :** `Hive` (NoSQL, ultra-rapide).
    *   *Rôle :* Stocke les médecins, les RDV et le profil utilisateur localement.
    *   *Stratégie :* L'UI lit toujours depuis Hive. Le réseau met à jour Hive en arrière-plan.
*   **Réseau & API :** `Dio` (Client HTTP robuste).
    *   Supporte les intercepteurs pour l'injection de token JWT.
    *   Gestion automatique des timeouts (critique en 2G).
*   **Détection Connectivité :** `connectivity_plus` + `internet_connection_checker`.
    *   Permet de basculer l'UI en mode "Hors Ligne" (Bandeau d'avertissement).
*   **Synchronisation :**
    *   Utilisation d'un **Queue Manager** (File d'attente).
    *   Les actions (ex: `bookAppointment`) sont stockées dans une `SyncQueue` locale si hors ligne.
    *   Un `WorkManager` (Android) ou un `Timer` (PWA foreground) dépile la file quand la connexion revient.

### B. Stratégie de Synchronisation (Sync Strategy)
Pour contrer la connectivité intermittente du Bénin :

1.  **Lecture (Read) :** "Stale-While-Revalidate".
    *   Afficher immédiatement les données du cache Hive.
    *   Tenter une requête API en arrière-plan.
    *   Si succès : mettre à jour Hive + `notifyListeners()` pour rafraîchir l'UI.
    *   Si échec : garder l'UI telle quelle (avec indicateur "Dernière synchro : 10h").
2.  **Écriture (Write - Prise de RDV) :** "Optimistic UI".
    *   L'utilisateur clique sur "Réserver".
    *   L'UI affiche "Réservation en cours..." (voire "Confirmé localement").
    *   La requête est ajoutée à la `RequestQueue`.
    *   Dès que le réseau est stable, la Queue envoie la requête.

---

## 2. Flux Critique : Rendez-vous & Paiement Mobile Money

Le paiement Mobile Money (MTN/Celtiis) est asynchrone et critique.

### Wireflow (Parcours Utilisateur)

1.  **Recherche & Sélection :**
    *   Utilisateur choisit un médecin et un créneau (Donnée venant de Hive/Cache).
2.  **Pré-Réservation (Lock) :**
    *   Appel API `POST /appointments/lock`. (Réserve le slot 10min).
3.  **Paiement (Initiation) :**
    *   Choix opérateur : MTN MoMo ou Celtiis.
    *   Saisie du numéro (Validation regex Bénin : `(97|96|95|94|...)`).
    *   **App :** Envoie demande de paiement (`USSD Push`).
4.  **Attente (Polling/Socket) :**
    *   L'utilisateur reçoit la demande sur son téléphone (USSD).
    *   **UI Flutter :** Affiche un écran "En attente de validation sur votre téléphone..." avec un compte à rebours.
    *   **Backend :** Reçoit le callback (Webhook) de l'opérateur.
    *   **App :** Poll le statut du paiement toutes les 5s ou écoute un WebSocket.
5.  **Confirmation :**
    *   Succès : Écran vert "RDV Confirmé" + Envoi SMS + Stockage local du billet.
    *   Échec/Timeout : Proposition de réessayer ou payer sur place (si autorisé).

---

## 3. Design System & UI/UX (Inspiré de AlloSanté.bj)

### Palette de Couleurs
*   **Primaire (Confiance) :** `#00897B` (Teal/Bleu Médical) - *Basé sur l'analyse visuelle*.
*   **Secondaire (Action) :** `#FF9800` (Orange) - Pour les boutons d'appel à l'action (Payer, Réserver).
*   **Fond (Clarté) :** `#FFFFFF` (Blanc pur) et `#F5F5F5` (Gris très clair) pour les listes.
*   **Texte :** `#212121` (Noir doux) pour le contraste WCAG.

### Typographie
*   **Font Family :** `Lato` ou `Roboto` (Google Fonts). Lisibilité maximale.
*   **Échelle :**
    *   H1 (Titres) : 22sp, Bold.
    *   Body (Contenu) : 16sp, Regular (Adapté aux seniors).
    *   Button : 16sp, Semi-Bold, Uppercase.

### Layout & Accessibilité (Faible Littératie)
*   **Grille de Dashboard :** Cartes larges (CardView) avec **Icônes + Texte**.
    *   Ex: Une grande icône "Stéthoscope" + Texte "Trouver un docteur".
*   **Feedback Visuel :** Ne jamais compter uniquement sur le texte.
    *   Succès = Coche Verte + Son.
    *   Erreur = Croix Rouge + Vibration.
*   **Actions Flottantes :** Un `FloatingActionButton` pour "Urgence" ou "SOS".

---

## 4. Implémentation Sécurité (Front-End)

### Gestion des Tokens (Authentification)
*   **Stockage :** Utilisation de `flutter_secure_storage` (Android EncryptedSharedPreferences / iOS KeyChain).
    *   *Note PWA :* En Web, stockage dans `Secure Cookie` (HttpOnly) si possible, ou `localStorage` chiffré (moins sécurisé mais standard PWA).
*   **Expiration :** Intercepteur Dio qui vérifie le `401 Unauthorized` pour lancer un `RefreshToken` automatique sans déconnecter l'utilisateur.

### Partage de Synthèse Médicale (QR Code Temporaire)
*   **Concept :** L'utilisateur veut montrer son dossier à un médecin hors réseau AlloSanté.
*   **Flow :**
    1.  App demande au backend un "Token de Partage" (durée 15 min).
    2.  App génère un QR Code localement (`qr_flutter`).
    3.  Le médecin scanne le QR avec son téléphone -> Redirection vers URL sécurisée (Vue web en lecture seule).
