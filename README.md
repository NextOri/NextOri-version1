# NextOri

NextOri est une application web d'orientation scolaire et professionnelle. Elle aide les apprenants à explorer leur profil RIASEC, à découvrir des métiers compatibles, puis à consulter les filières et établissements associés.

> Architecture de référence : **React/Vite + API Node.js serverless sur Vercel + Supabase PostgreSQL**.
> PHP et MySQL ne font plus partie du runtime ni du déploiement actuel.

## Parcours principal

1. L'utilisateur crée un compte ou se connecte.
2. Il répond au questionnaire RIASEC.
3. L'API calcule les scores `R`, `I`, `A`, `S`, `E` et `C`, puis détermine un profil dominant à deux lettres.
4. Les métiers sont classés selon leur compatibilité avec le profil et, si disponible, la série de l'utilisateur.
5. Chaque métier est enrichi avec ses filières et les établissements qui les proposent.

L'application comporte aussi un espace profil, un tableau de bord avec badges, l'historique des tests, un catalogue métiers/filières/universités, des avis et un module d'hésitation.

## Architecture

```text
Navigateur
  └─ Frontend React (Vite, SPA)
       └─ /api/*
            └─ API Node.js serverless (Vercel)
                 ├─ authentification JWT et cookie HttpOnly
                 ├─ moteur de recommandation RIASEC
                 ├─ notifications e-mail
                 └─ Supabase (PostgreSQL)
```

Vercel construit le frontend et redirige les requêtes `/api/*` vers la passerelle Node. La configuration est dans [`vercel.json`](./vercel.json).

## Technologies

### Frontend

- React 19
- Vite 8
- React Router DOM 7
- Axios et `fetch` pour les appels HTTP
- CSS classique par composants/pages
- Lucide React, React Icons et React Confetti

### Backend et données

- Node.js en modules ES (`type: module`)
- Fonctions serverless Vercel
- Supabase JavaScript (`@supabase/supabase-js`)
- PostgreSQL géré par Supabase
- JWT (`jsonwebtoken`), hachage des mots de passe (`bcryptjs`) et cookies
- Nodemailer pour les envois e-mail

## Structure du dépôt

```text
.
├─ Frontend/                 # Application React/Vite
│  ├─ src/
│  │  ├─ pages/              # Pages et écrans de l'application
│  │  ├─ components/         # Composants réutilisables
│  │  ├─ services/           # Services d'appel API
│  │  ├─ config/api.js       # URLs de l'API
│  │  ├─ utils/              # Utilitaires RIASEC et hésitation
│  │  └─ App.jsx             # Routes React
│  ├─ package.json
│  └─ vite.config.js
├─ api/                      # API Node.js serverless
│  ├─ index.js               # Passerelle et routeur API
│  ├─ _lib/                  # Auth, CORS, e-mail, Supabase, moteur RIASEC
│  └─ _routes/               # Gestionnaires des endpoints
├─ Bases de données/          # Archives SQL et modèles de données historiques
├─ Backend/                  # Ancien backend PHP ; hors runtime actuel
├─ .env.example              # Modèle des variables serveur
├─ package.json              # Workspace npm racine
└─ vercel.json               # Build et routage Vercel
```

`Backend/` et les fichiers SQL présents dans le dépôt sont conservés comme historique ou documentation. Ils ne doivent pas être considérés comme la source de vérité du déploiement Supabase sans validation préalable.

## Points d'entrée importants

| Fichier | Rôle |
|---|---|
| [`Frontend/src/main.jsx`](./Frontend/src/main.jsx) | Monte React et le routeur navigateur. |
| [`Frontend/src/App.jsx`](./Frontend/src/App.jsx) | Définit les routes de l'interface. |
| [`Frontend/src/config/api.js`](./Frontend/src/config/api.js) | Définit les URL de l'API ; `/api` est la valeur par défaut. |
| [`api/index.js`](./api/index.js) | Reçoit `/api/*` et délègue à chaque gestionnaire. |
| [`api/_lib/auth.js`](./api/_lib/auth.js) | Signe et lit les JWT, gère le cookie de session. |
| [`api/_lib/orientationEngine.js`](./api/_lib/orientationEngine.js) | Calcule le profil RIASEC et les recommandations. |
| [`api/_lib/supabase.js`](./api/_lib/supabase.js) | Initialise le client PostgreSQL Supabase. |
| [`vercel.json`](./vercel.json) | Configure le build Vite, les fichiers statiques et les réécritures. |

## API

L'API est préfixée par `/api`. Son routeur se trouve dans [`api/index.js`](./api/index.js).

Les routes actuellement enregistrées comprennent :

- Authentification : `register`, `login`, `logout`, `profile`, `profil`, `verify-code`, `resend-code`.
- Questionnaire et orientation : `questions`, `propositions`, `orientation`, `resultats`, `series`.
- Exploration : `metiers`, `metiers_details`, `filiere`, `filieres`, `filiere_details`, `universites`, `universite-catalogue`, `universite-detail`.
- Suivi : `dashboard`, `historique`, `historique-tests`, `historique-test-detail`.
- Communauté et fonctionnalités : `avis`, `admin-avis`, `temoignages`, `hesitation`, `notifier-fonctionnalite`.

Les handlers consultent directement Supabase. Les tables utilisées par le flux principal incluent notamment `utilisateur`, `questionnaire`, `question`, `proposition`, `test_riasec`, `reponse`, `metier`, `metier_serie`, `metier_filiere`, `filiere`, `universite_filiere` et `universite`.

## Variables d'environnement

Copier `.env.example` vers `.env` pour le développement local, puis renseigner les valeurs réelles. Ne jamais versionner `.env` ni exposer les clés serveur dans le frontend.

Variables serveur principales :

```dotenv
SUPABASE_URL=
SUPABASE_ANON_KEY=
SUPABASE_SERVICE_ROLE_KEY=
JWT_SECRET=
APP_URL=
```

Les variables e-mail sont optionnelles selon le fournisseur choisi : SMTP, Brevo ou Resend. Les variables commençant par `VITE_` sont publiques une fois intégrées au bundle frontend ; elles ne doivent donc contenir aucun secret.

Variables frontend prévues :

```dotenv
VITE_API_PUBLIC_URL=/api
VITE_API_ROUTES_URL=/api
```

## Installation et développement

Prérequis : une version de Node.js compatible avec les dépendances déclarées, ainsi qu'un projet Supabase configuré avec le schéma attendu par l'API.

```bash
npm install
npm run dev
```

Le projet racine utilise le workspace npm `Frontend`. Les commandes utiles sont :

```bash
npm run dev
npm run build
npm run lint
npm run preview
```

En développement Vite, le frontend est servi localement. Pour exercer les routes serverless dans les mêmes conditions que Vercel, utiliser un environnement de développement Vercel configuré pour le projet ; le simple serveur Vite ne remplace pas automatiquement les fonctions contenues dans `api/`.

## Déploiement

Le déploiement cible est Vercel :

- commande de build : `npm run build --workspace=Frontend` ;
- répertoire de sortie : `Frontend/dist` ;
- `/api/*` est redirigé vers `api/index.js` ;
- les autres routes applicatives sont renvoyées vers `index.html` pour permettre le routage SPA.

Configurer dans Vercel les mêmes variables d'environnement serveur que celles décrites ci-dessus, avec les valeurs du projet Supabase de production.

## Sécurité et maintenance

- Les mots de passe sont hachés avec `bcryptjs`.
- Les sessions sont représentées par un JWT et un cookie HttpOnly.
- La clé `SUPABASE_SERVICE_ROLE_KEY` est strictement réservée aux fonctions serverless : elle ne doit jamais être placée dans une variable `VITE_*` ni dans le code React.
- Toute évolution de la base doit être préparée et appliquée sur Supabase/PostgreSQL, pas sur les anciens fichiers MySQL.
- Avant de modifier une table, vérifier toutes les routes Node et les pages frontend qui l'utilisent, notamment les relations métier → filière → université.

## Éléments historiques

Le dépôt contient encore `Backend/` (PHP) et plusieurs fichiers SQL MySQL/MariaDB. Ils documentent des versions précédentes du projet, mais ne sont pas utilisés par l'architecture actuelle Node/Vercel/Supabase. Leur présence ne doit pas conduire à réintroduire PHP ou MySQL dans les scripts de déploiement.
