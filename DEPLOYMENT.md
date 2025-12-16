# Guide de Déploiement AlloSanté

Ce guide explique comment déployer l'application AlloSanté pour que d'autres utilisateurs puissent y accéder.

Nous utiliserons **Render** pour héberger le Backend et la Base de données, et nous hébergerons le Frontend comme un site statique (sur Render ou ailleurs).

---

## 1. Déploiement du Backend (Node.js + Database)

Render offre un moyen simple de déployer des applications Node.js et des bases de données PostgreSQL.

### Étape 1.1 : Préparation sur GitHub
Assurez-vous que votre projet est poussé sur un dépôt GitHub (le code doit être à jour).

### Étape 1.2 : Créer la Base de Données sur Render
1.  Créez un compte sur [dashboard.render.com](https://dashboard.render.com/).
2.  Cliquez sur **"New +"** -> **"PostgreSQL"**.
3.  Name: `allosante-db` (ou autre).
4.  Region: Choisissez la plus proche (ex: Frankfurt pour l'Europe).
5.  Plan: **Free** (suffisant pour tester).
6.  Cliquez sur **"Create Database"**.
7.  Une fois créée, copiez le **"Internal Database URL"** (pour le backend déployé sur Render) et le **"External Database URL"** (si vous voulez vous y connecter depuis votre PC).

### Étape 1.3 : Déployer le Web Service (Backend)
1.  Cliquez sur **"New +"** -> **"Web Service"**.
2.  Connectez votre dépôt GitHub.
3.  **Root Directory**: `backend` (Important car votre backend est dans un sous-dossier).
4.  **Runtime**: `Node`.
5.  **Build Command**: `npm install && npm run build`.
6.  **Start Command**: `npm start`.
7.  **Environment Variables** (Section "Advanced"):
    *   `DATABASE_URL`: Collez le **Internal Database URL** copié précédemment.
    *   `JWT_SECRET`: Mettez une longue chaîne de caractères aléatoires.
    *   `NODE_ENV`: `production`.
8.  Cliquez sur **"Create Web Service"**.

Votre backend sera accessible à une URL du type `https://allosante-backend.onrender.com`.

---

## 2. Déploiement du Frontend (Flutter Web)

Render ne supporte pas nativement le build Flutter facilement, donc nous allons construire l'application sur votre ordinateur et envoyer les fichiers.

### Étape 2.1 : Construire l'application Web
Ouvrez votre terminal dans le dossier `AlloSante` (racine) et lancez la commande suivante, en remplaçant l'URL par celle de votre backend Render :

```bash
flutter build web --release --dart-define=API_URL=https://votre-backend.onrender.com/api
```

Cela va créer les fichiers du site dans le dossier `build/web`.

### Étape 2.2 : Héberger les fichiers statiques (Sur Render)
1.  Sur [dashboard.render.com](https://dashboard.render.com/), cliquez sur **"New +"** -> **"Static Site"**.
2.  Connectez votre dépôt GitHub.
3.  **Root Directory**: `build/web` (Attention: cela suppose que vous committez le dossier build, ce qui n'est pas recommandé habituellement. **Alternative recommandée ci-dessous**).

**Alternative Recommandée (Drag & Drop sur Netlify)** :
1.  Allez sur [app.netlify.com/drop](https://app.netlify.com/drop).
2.  Prenez le dossier `build/web` de votre ordinateur et glissez-le sur la page.
3.  Votre site est en ligne instantanément !

---

## Récapitulatif
1.  Backend & DB tournent sur Render.
2.  Frontend tourne sur Netlify (ou Render Static Site).
3.  Le Frontend parle au Backend via l'URL configurée lors du build (`API_URL`).
