#!/usr/bin/env bash
set -euo pipefail

# Install commitlint if not available
if ! command -v npx &> /dev/null; then
    echo "npx not found, installing Node.js dependencies..."
    npm init -y >/dev/null 2>&1
    npm i -D @commitlint/cli @commitlint/config-conventional >/dev/null 2>&1
fi

# Check conventional commits
echo "Checking conventional commits..."
npm init -y >/dev/null 2>&1
npm i -D @commitlint/cli @commitlint/config-conventional >/dev/null 2>&1
npx commitlint --extends @commitlint/config-conventional --from HEAD~3 --to HEAD || (echo "commitlint failed" && exit 1)
echo "✅ All commit messages follow conventional commit format"

# Build + tests
dotnet build -c Release
dotnet test -c Release --no-build

# Run app (background)
dotnet run --project Api/Api.csproj -c Release --no-build &
APP_PID=$!

# Wait for app
for i in {1..30}; do
  if curl -fsS http://localhost:5080/health >/dev/null 2>&1; then
    break
  fi
  sleep 1
done

# Checks
curl -fsS http://localhost:5080/health | grep -q '"status"' || (echo "health failed" && exit 1)

curl -fsS -X POST http://localhost:5080/time-entries \
  -H "Content-Type: application/json" \
  -d '{"date":"2025-10-07","durationMinutes":90,"project":"QimTime"}' | grep -q '"id"' || (echo "post failed" && exit 1)

curl -fsS "http://localhost:5080/time-entries?from=2025-10-01&to=2025-10-31" | grep -q 'QimTime' || (echo "get failed" && exit 1)

kill $APP_PID || true
echo "OK"


