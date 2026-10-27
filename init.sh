#!/usr/bin/env bash
# One command to a working, verified environment. No feature code — setup only.
set -euo pipefail

echo "== LMS harness init =="

# 1. Env file
if [ ! -f .env ]; then
  cp .env.example .env
  echo "Created .env from .env.example — fill in local secrets before continuing."
fi

# 2. Backend: Python env + deps
if [ ! -d backend/.venv ]; then
  echo "-- Setting up backend venv"
  python3.11 -m venv backend/.venv
fi
# shellcheck disable=SC1091
source backend/.venv/bin/activate
pip install --upgrade pip >/dev/null
pip install -r backend/requirements.txt -r backend/requirements-dev.txt

# 3. Frontend: Node deps
echo "-- Installing frontend deps"
(cd frontend && npm install)

# 4. Database: start Postgres via Docker Compose
echo "-- Starting Postgres"
docker compose up -d postgres

echo "-- Waiting for Postgres to accept connections"
until docker compose exec -T postgres pg_isready -U "${POSTGRES_USER:-lms}" >/dev/null 2>&1; do
  sleep 1
done

# 5. Migrations
echo "-- Running migrations"
(cd backend && alembic upgrade head)

# 6. One passing smoke test
echo "-- Running smoke test"
(cd backend && pytest tests/test_smoke.py -q)

echo "== Init complete. Run 'make up' to start the app, 'make check' to verify. =="
