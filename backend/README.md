# AlloSanté Backend API

Backend Node.js + Express + PostgreSQL pour l'application mobile AlloSanté.

## Prérequis

- Node.js 18+
- PostgreSQL 14+

## Installation

```bash
# Installer les dépendances
npm install

# Copier le fichier d'environnement
cp .env.example .env

# Modifier les variables dans .env (surtout DATABASE_URL)

# Générer le client Prisma
npm run db:generate

# Appliquer les migrations
npm run db:migrate

# (Optionnel) Insérer les données de test
npm run db:seed
```

## Lancer le serveur

```bash
# Mode développement (avec hot reload)
npm run dev

# Mode production
npm run build
npm start
```

## Endpoints API

### Auth
- `POST /api/auth/register` - Inscription
- `POST /api/auth/login` - Connexion
- `POST /api/auth/verify-otp` - Vérification OTP
- `POST /api/auth/resend-otp` - Renvoyer OTP

### Doctors
- `GET /api/doctors` - Liste des médecins
- `GET /api/doctors/:id` - Détail d'un médecin
- `GET /api/doctors/specialties` - Liste des spécialités
- `GET /api/doctors/locations` - Liste des villes

### Appointments (Auth requise)
- `POST /api/appointments` - Créer un rendez-vous
- `GET /api/appointments` - Mes rendez-vous
- `GET /api/appointments/:id` - Détail d'un RDV
- `PATCH /api/appointments/:id/cancel` - Annuler

### Medical Record (Auth requise)
- `GET /api/medical-record` - Mon dossier médical
- `PATCH /api/medical-record` - Modifier mon dossier

## Variables d'environnement

```env
DATABASE_URL="postgresql://user:password@localhost:5432/allosante"
JWT_SECRET="votre-secret-jwt"
JWT_EXPIRES_IN="7d"
PORT=3000
NODE_ENV=development
```
