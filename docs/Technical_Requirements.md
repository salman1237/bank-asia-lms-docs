# Technical Requirements

Read when: adding a dependency, setting up environments, or touching an integration point.

## Stack

| Layer | Choice |
|---|---|
| Backend language/framework | Python 3.12, FastAPI |
| ORM / migrations | SQLAlchemy 2.0, Alembic |
| Database | PostgreSQL 16 |
| Frontend | Next.js 14 (App Router), TypeScript, Tailwind CSS |
| Auth | JWT access/refresh tokens, RBAC (role → permission mapping stored in DB, per RFP 7.9.2) |
| Background jobs / reminders | Celery 5 workers and Celery Beat with a Valkey 8 broker, as proposed in `architecture/09-technology-layers.md` — confirm at design sign-off, before building the RFP 8.26 Notification module (see `DECISIONS.md`) |
| File storage | Local disk in dev; S3-compatible object storage in UAT/Prod (RFP 8.24 Document Upload) |
| SMS/Email gateway | Mock adapters in dev/test; real gateway config deferred (RFP 7.3.4) |
| CBS integration | Mock adapter in dev/test (`MockCBSClient`); real integration is a separate later milestone |

## Checks (must all pass — this is what `make check` runs)

- Backend: `pytest`, `mypy --strict`, `ruff check`
- Frontend: `tsc --noEmit`, `eslint`
- Full stack smoke: `make verify` — boots the app against a disposable test DB and hits a handful of critical endpoints end-to-end

## Environments

- **Local dev:** Docker Compose (`postgres`, `api`, `web`). `.env` from `.env.example`.
- **UAT:** mirrors prod config, mocked or sandboxed CBS/SMS/email, seeded with anonymized test data.
- **Production:** on-premises per RFP preference (Section 7.8.2 — on-prem preferred, DC + DR, private cloud/hybrid optional). Deployment topology is out of scope for this doc; see ops runbook once it exists.

Test, UAT, and Production environments must be independently configurable (RFP 7.8.3) — no environment-specific values hardcoded in app code.

## Integration Contracts

### CBS (Core Banking System)
- Interface: `CBSClient` protocol — `get_account(account_no)`, `get_customer(customer_id)`, `get_repayment_history(account_no)`, etc. Expand as modules need it.
- Dev/test: `MockCBSClient` backed by fixtures in `tests/fixtures/cbs/`.
- Real integration (REST/SOAP, batch/ETL, SFTP per RFP 7.3.7) is tracked as a separate milestone; do not start it without explicit sign-off (see `DECISIONS.md`).

### SMS / Email
- Interface: `NotificationClient` — `send_sms(to, message)`, `send_email(to, subject, body)`.
- Mock implementation logs to console/test capture in dev/test.

### Document Storage
- Interface: `DocumentStore` — `upload(file, metadata)`, `search(filters)`, `download(id)`.
- Local filesystem in dev; swappable to S3-compatible in later environments.

## Adding a Dependency

1. Confirm it's not already covered by something in this list.
2. Add it to `pyproject.toml` / `package.json` with a pinned version.
3. Note it here under the relevant row, with a one-line reason, before merging.

## Security Baseline (also see `Non_Functional_Requirements.md`)

- HTTPS/TLS only; no plaintext HTTP between services.
- Passwords hashed with argon2id.
- OWASP Top 10 protections (parameterized queries via ORM, output encoding, CSRF tokens on state-changing frontend forms, security headers).
- All libraries/dependencies kept up to date and license-checked (RFP 7.11.16).
