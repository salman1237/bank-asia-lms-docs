# Rules

Read when: writing any code. These are enforced, not optional.

## Backend

- **Layering:** `api/` → `service/` → `repository/`. A router must never import SQLAlchemy or issue a query directly. A service must never return an ORM model to the API layer — map to a Pydantic schema.
- **Maker-checker everywhere:** any endpoint that creates/edits/deletes a case, bill, notice, request, or similar business entity must go through the shared workflow state machine in `service/workflow.py` (see `Architecture.md`). Do not hand-roll a parallel status field.
- **Audit trail:** every state-changing service function writes to the `audit_log` table (actor id, timestamp, entity type, entity id, action, before/after diff). This is not optional per feature — it is a shared decorator/helper (`audit.record()`), applied at the service layer.
- **RBAC:** every router handler declares its required permission(s) via the `require_permission(...)` dependency. No handler is left unguarded, including read-only ones that expose customer data (RFP 8.27 Customer 360).
- **ORM:** SQLAlchemy 2.0 syntax only (`select()`, not legacy `Query`). No raw SQL strings except in Alembic migrations.
- **Migrations:** Alembic only. Never hand-edit a migration that has been applied to any shared environment; create a new one.
- **Passwords/secrets:** hash with argon2id. Never log a password, token, or full card/account number — mask account numbers in logs (show last 4 digits only).
- **CBS/SMS/email:** only `cbs_client/`, `notifications/` may hold integration code. Business modules call these via their public interface only.
- **Errors:** raise typed domain exceptions in `service/`; map to HTTP status + user-safe message in `api/`. Never leak a stack trace or DB error string to the client.
- **Tests:** every service-layer function that performs a state transition or writes data needs a test. Every router needs at least one integration test covering the happy path and one permission-denied path.

## Frontend

- Next.js App Router, TypeScript strict mode. No `any` without an inline comment explaining why.
- All API calls go through a single typed client (`lib/api/`), not ad hoc `fetch()` calls scattered through components.
- Forms that submit to a maker-checker endpoint must reflect the four states (`draft_saved`, `pending`, `approved/rejected/returned`) in their UI — never hide status from the user.
- No secrets, API base URLs, or CBS endpoints hardcoded in components — read from env/config.

## Cross-cutting

- All API responses are JSON; REST conventions (resource nouns, correct verbs/status codes).
- Multi-language support (Bengali/English) is a real requirement (RFP 7.2.5) — don't hardcode English-only strings in shared/report components; use the i18n layer from the start for anything a branch/legal user will read.
- Bangladesh Bank regulatory reports (RFP 8.25, সংযোজনী-ক/খ/গ, RIT, BR-4, DBI 22, CRMR, ISS) are exact-format outputs — do not "improve" their layout without checking the RFP wording; these formats are externally mandated.
- Session timeout, password policy, lockout thresholds are configurable (RFP 8.29), not hardcoded constants — read from `system_settings` table.
- Never commit `.env`, credentials, or CBS/SMS/email fixtures containing real customer data.
