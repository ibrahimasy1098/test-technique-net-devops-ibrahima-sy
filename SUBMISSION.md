# Time Entries API - Test Technique

## Instructions Locales

### Build
```bash
dotnet build
```

### Tests
```bash
dotnet test
```

### Lancer l'API (port 5080)
```bash
dotnet run --project Api
```

L'API sera accessible sur: `http://localhost:5080`

---

##  Exemples d'appels curl

### Health Check
```bash
curl http://localhost:5080/health
```
**Réponse:** `{"status":"ok"}`

### POST - Créer une entrée de temps
```bash
curl -X POST http://localhost:5080/time-entries \
  -H "Content-Type: application/json" \
  -d "{\"date\":\"2025-10-07\",\"durationMinutes\":90,\"project\":\"QimTime\"}"
```
**Réponse (201):**
```json
{"id":1,"date":"2025-10-07","durationMinutes":90,"project":"QimTime"}
```

### GET - Lister les entrées (avec filtres optionnels)
```bash
# Toutes les entrées
curl http://localhost:5080/time-entries

# Avec filtre de dates
curl "http://localhost:5080/time-entries?from=2025-10-01&to=2025-10-31"
```

---

## Docker

```bash
# Build l'image
docker build -t time-entries-api .

# Lancer le conteneur
docker run -p 5080:8080 time-entries-api
```

L'API sera accessible sur: `http://localhost:5080`

---

## Temps passé

Environ 35 minutes.

---

## Notes

- API Minimal .NET 8 avec validation des entrées
- Stockage en mémoire (liste statique)
- 2 tests d'intégration avec WebApplicationFactory
- Dockerfile multi-stage (build + runtime)
- 4 commits conventionnels

---

PS: Le Dockerfile a été ajouté après la limite de temps initiale de 30 minutes.

