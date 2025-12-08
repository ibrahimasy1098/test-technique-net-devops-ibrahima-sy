## Test technique .NET + DevOps — 30 minutes

But: vérifier rapidement la maîtrise d'un profil .NET avec une sensibilité DevOps, sur un exercice court, concret et vérifiable.

Durée totale: 30 minutes (temps limite ferme)

Livrables attendus: un dépôt Git public ou un zip, avec un README concis.

---

### Prérequis

- **.NET 8 SDK** installé
- **Docker**
- **bash**, **curl** (pour le script `check.sh`) OU **PowerShell**, **curl** (pour le script `check.ps1`)
- **Git** avec accès au dépôt GitLab

---

<details>
<summary><strong>Accès au dépôt GitLab</strong></summary>

Pour cloner et travailler avec ce dépôt, vous devez configurer un token d'accès GitLab :

#### 1. Créer un token d'accès personnel

1. Connectez-vous à [GitLab QimInfo](https://gitlab.com)
2. Allez dans **User Settings** → **Access Tokens**
3. Créez un nouveau token avec les scopes :
   - `read_repository` (pour cloner)
   - `write_repository` (pour pousser les modifications)

#### 2. Configurer le token localement

```bash
# Définir le token comme variable d'environnement
export GITLAB_TOKEN="votre_token_d_acces_personnel"

# Définir l'URL du dépôt
export GITLAB_REPOSITORY_URL="gitlab.com/qiminfo1/test-technique-net-devops.git"

# Cloner le dépôt avec le token
git clone https://oauth2:${GITLAB_TOKEN}@${GITLAB_REPOSITORY_URL}

```

</details>

---

### Contexte

Vous réalisez une mini API .NET 8 permettant de gérer des entrées de temps (Time Entries). L'objectif est de produire une version minimale, testable localement, conteneurisable, et versionnée proprement.

Technos attendues:

- .NET 8 Web API minimal (C#)
- Validation d'entrées
- Unité de tests (xUnit ou NUnit) — 1 à 2 tests suffisants
- Dockerfile (build multi‑stage)
- Git avec commits lisibles (Conventional Commits)

Pas de base de données requise (stockage en mémoire acceptable).

---

### Énoncé

Réaliser les éléments suivants, dans l'ordre. Respecter le temps (30 minutes). Faites simple et fonctionnel.

1. API minimale

   - Exposer un endpoint POST `/time-entries` qui accepte un JSON:
     - `date` (string ISO 8601, ex: "2025-10-07")
     - `durationMinutes` (int > 0)
     - `project` (string non vide)
   - Valider les champs; en cas d'erreur, retourner `400` avec un message clair.
   - Sur succès, retourner `201` avec l'objet créé (ajoutez un `id` généré en mémoire).

2. Lecture filtrée

   - Exposer un endpoint GET `/time-entries?from=YYYY-MM-DD&to=YYYY-MM-DD`.
   - Retourner la liste des entrées dont `date` est dans l'intervalle `[from, to]` inclus.
   - Si `from` ou `to` est absent, ignorer le filtre correspondant.

3. Health check

   - Exposer un endpoint GET `/health` qui retourne `200 { status: "ok" }`.

4. Test unitaire (1 à 2 max)

   - Couvrir au moins un cas de validation (ex: `durationMinutes <= 0` → erreur).

5. Docker

   - Fournir un `Dockerfile` multi‑stage (build + runtime) permettant de lancer l'API.

6. Git
   - 2 à 4 commits maximum, clairs et lisibles (Conventional Commits, ex: `feat: add POST /time-entries`).

---

### Contraintes

- **Structure de projet obligatoire**: Le projet API doit être nommé `Api` et placé dans le dossier `Api/` à la racine du dépôt (ex: `Api/Api.csproj`). Le projet de tests peut avoir n'importe quel nom.
- **Dockerfile obligatoire**: Un `Dockerfile` doit être présent à la racine pour que le pipeline CI passe l'étape `container:build`.
- **Port de l'API**: L'API doit écouter sur le port 5080 en local (configurer via `applicationUrl` dans `Properties/launchSettings.json` ou programmatiquement).
- Ne pas committer de secrets.
- Code lisible, endpoints REST simples, messages d'erreurs clairs.
- Pas de sur‑ingénierie: un seul projet API + projet de tests suffisent.

---

### Ce que nous évaluerons

- Fonctionnalité: endpoints opérationnels, validation correcte.
- Qualité: lisibilité, petites fonctions, erreurs explicites.
- Tests: au moins un test pertinent qui échoue si la validation est brisée.
- Conteneurisation: `Dockerfile` exécutable.
- Git: commits propres et atomiques.

Barème (indicatif):

- API/Validation: 40
- GET filtré: 15
- Test(s): 15
- Dockerfile: 15
- Git (commits): 15

---

### Rendu attendu (obligatoire)

- Lien vers le dépôt Git public OU archive `.zip`.
- Fichier `README.md` avec:
  - Instructions locales: `dotnet build`, `dotnet test`, lancement HTTP (port), et `docker build`/`docker run`.
  - Exemples d'appels curl (POST/GET) avec corps/paramètres.
  - Temps réellement passé si différent de 30 min (honnêteté appréciée).

Exemples d'appels:

```bash
curl -s -X POST http://localhost:5080/time-entries \
  -H "Content-Type: application/json" \
  -d '{
    "date": "2025-10-07",
    "durationMinutes": 90,
    "project": "QimTime"
  }'

curl -s "http://localhost:5080/time-entries?from=2025-10-01&to=2025-10-31"

curl -s http://localhost:5080/health
```

---

### Conseils (facultatif)

- Conservez les entrées en mémoire (liste statique) pour aller vite.
- Utilisez des enregistrements C# (records) pour le modèle d'entrée/sortie.
- Validez tôt et retournez des erreurs précises (champ et raison).

### Contenu

- `check.sh`: script local de vérification (build, tests, run, appels HTTP).
- `check.ps1`: script local de vérification (build, tests, run, appels HTTP).
- `.gitlab-ci.yml`: pipeline GitLab CI (modèle) pour vérifications automatiques.

Ces fichiers sont des modèles: copiez-les tels quels dans la racine de VOTRE dépôt de test (ou adaptez si besoin).

### Structure de projet attendue

Votre dépôt doit avoir la structure suivante:

```
.
├── Api/
│   ├── Api.csproj
│   ├── Program.cs
│   └── Properties/
│       └── launchSettings.json (port 5080)
├── Api.Tests/              (nom libre)
│   └── Api.Tests.csproj
├── Dockerfile
├── check.sh
├── check.ps1
├── .gitlab-ci.yml
├── commitlint.config.cjs
└── README.md
```

### Utilisation rapide

1. Créez votre projet API à la racine du dépôt.
2. Ajoutez un projet de tests (xUnit/NUnit) minimal.
3. Les fichiers `check.sh`, `check.ps1`, `.gitlab-ci.yml` et `commitlint.config.cjs` sont déjà fournis.
4. Exécutez localement:

```powershell
powershell -ExecutionPolicy Bypass -File ./check.ps1
```

```bash
chmod +x ./check.sh
./check.sh
```

5. Poussez sur GitLab pour déclencher le pipeline CI.

Note: adaptez le port si votre API écoute sur un autre port (remplacez `http://localhost:5080`).

---

### Démarrage rapide (local)

1. Placez votre projet API .NET 8 et le projet de tests à la racine.
2. Rendez le script exécutable puis lancez-le:

```powershell
powershell -ExecutionPolicy Bypass -File ./check.ps1
```

```bash
chmod +x ./check.sh
./check.sh
```

Le script va: build, exécuter les tests, démarrer l'API, puis vérifier `GET /health`, `POST /time-entries` et `GET /time-entries`.

---

### Utilisation Docker (optionnelle)

Assurez-vous d'avoir un `Dockerfile` multi‑stage à la racine. Puis:

```bash
docker build -t test-api:local .
docker run -d -p 5080:8080 --name api test-api:local
curl -s http://localhost:5080/health
```

Arrêt/suppression:

```bash
docker rm -f api || true
```

---

### CI/CD (GitLab)

Le pipeline fourni dans `.gitlab-ci.yml` comprend les stages: `lint`, `build`, `test`, `verify`.

- `lint:commitlint` (Node 22): vérifie les messages de commit (Conventional Commits).
- `build` (SDK .NET 8): `dotnet restore` puis `dotnet build -c Release`.
- `test` (SDK .NET 8): exécute `dotnet test -c Release`.
- `quality:coverage` (SDK .NET 8): génère un rapport de couverture de code.
- `container:build` (Kaniko): construit l'image Docker et la pousse vers le registry GitLab.
- `verify:endpoints` (SDK .NET 8 Alpine): lance l'API avec `dotnet run` et vérifie tous les endpoints via `curl` (health, POST time-entries, GET time-entries filtré).

Le pipeline inclut également la détection de secrets via le template GitLab intégré.

Déclenchement: pousser sur la branche du dépôt active pour lancer la CI.

---

### Lint des commits

Les commits sont vérifiés par Commitlint avec la config conventionnelle.

Fichier de configuration inclus: `commitlint.config.cjs`.

```javascript
module.exports = {
  extends: ["@commitlint/config-conventional"],
  rules: {
    "body-max-line-length": [0],
  },
};
```

Bonnes pratiques:

- Sujet de commit au format: `type(scope): description courte`.
- Corps optionnel, lignes courtes recommandées même si la règle de longueur est désactivée.
