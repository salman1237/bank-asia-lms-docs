# Decisions Log

Most recent first. Each entry: decision, date, rationale, who/what prompted it.

---

## 2026-10-27 — Target architecture documented; stack moves to Python 3.12 and PostgreSQL 16
**Decision:** Added `architecture/`, the proposed target architecture for the real system in nine documents with Mermaid diagrams: system architecture, workflow, data flow, network/storage/server, integration, Level-0 context, implementation, risk management and technology layers. It proposes on-premises deployment across DC, NDR and far DR (synchronous replication to NDR, cascading to DR; RPO 0, target RTO 30 minutes), a modular monolith on FastAPI and Next.js, PostgreSQL 16 with Patroni, S3-compatible object storage, and Celery workers with a Valkey broker for background jobs. The stack versions in `CLAUDE.md`, `docs/` and `init.sh` move from Python 3.11 and PostgreSQL 15 to Python 3.12 and PostgreSQL 16 to match.
**Why:** The client asked for a complete system architecture with diagrams. Python 3.12 and PostgreSQL 16 are what the live demo already runs, and both stay supported a year longer than 3.11 and 15 into the six-year support term (RFP §6.30); upgrades beyond that are tracked as risk R11. Celery with Valkey settles the background-jobs choice that `docs/Technical_Requirements.md` had left open, using a BSD-licensed, Redis-compatible broker.
**How to apply:** Treat `architecture/` as a proposal until design sign-off. The "Items to confirm at design sign-off" table in `architecture/README.md` lists the open choices; sizing, durations and SLAs are indicative. Every diagram pins Mermaid's classic layout (`layout: dagre`, `look: classic`) in its front matter. Keep the pin when editing, so the diagrams render the same on Mermaid 10, 11 and 12.

## 2026-10-26 — Demo gained a real backend (FastAPI + PostgreSQL), still not the production system
**Decision:** Built a second repo, `bank-asia-lms-backend` (FastAPI, SQLAlchemy, PostgreSQL via Dokploy-managed Postgres resource), and rewired the frontend's zustand store to call it instead of mutating local/localStorage state. Scope: a generic `module_records` table (JSONB `data`/`history` columns) serving all 31 modules' CRUD + maker-checker transitions, auto-seeded from a JSON snapshot of the original synthetic dataset. No authentication (login stays the quick role-switcher — user's explicit call when asked). No Alembic migrations (`create_all` on startup) — deliberately lighter than `docs/Rules.md`'s "Alembic only" rule for the real system.
**Why:** Client asked for "real backend with database for the demo." User chose "demo-grade real backend" over "full production-grade per docs/Architecture.md" when asked — real persistence and a real API, not full RBAC/audit-grade rigor or CBS integration work.
**How to apply:** This is still a separate, parallel track from the real system described in `CLAUDE.md`/`docs/`/`feature_list.json` (same split as the original frontend-only demo — see the 2026-10-26 "clickable demo" decision above). When the real system is eventually built, `backend/app/models.py`'s generic JSONB-per-module approach is NOT the pattern to follow — `docs/Architecture.md` calls for per-module typed tables, the shared maker-checker *service-layer* state machine (not duplicated per-endpoint like the demo backend does), real RBAC, and Alembic migrations. Treat the demo backend as a reference for which fields/workflow states matter, not as a schema to inherit.
**Deployed:** Dokploy project `bank-asia-lms` now has three resources — `bank-asia-lms-app` (frontend), `bank-asia-lms-backend` (API), `bank-asia-lms-db` (Postgres) — all on the same internal network, same domain `lms.skoder.co` with path-based routing (`/api/*` → backend, `/*` → frontend) so no CORS is needed.

## 2026-10-26 — Clickable demo built ahead of the real backend, for a bank presentation
**Decision:** Built a fully client-side Next.js demo (`frontend/`) covering all 31 RFP Section 8 modules as clickable CRUD + maker-checker workflow screens, a dashboard, Customer 360 search, and a 48-report MIS screen — all backed by in-browser synthetic data (zustand + localStorage), not the real FastAPI/PostgreSQL backend described in `docs/Architecture.md`. Dockerized (multi-stage Next.js standalone build) for deployment to the user's Dokploy server.
**Why:** User has a bank presentation the next day and needs every button clickable with realistic dummy data reflecting the RFP feature set — not a production system. Building the real backend first would not have been ready in time.
**How to apply:** This demo is throwaway/parallel to the real build — it does not replace `docs/Architecture.md`'s FastAPI/service/repository layering or the maker-checker implementation plan in `feature_list.json`. When real development starts, the real backend is built per the existing harness docs; the demo's `lib/modules-config.tsx` field definitions are a useful reference for real schema design but the demo code itself is not reused as production code (no RBAC enforcement, no real persistence, no audit integrity guarantees — it's a UI mockup with state).

## 2026-10-26 — Added context7 and shadcn MCP servers
**Decision:** Added `context7` (hosted HTTP, library/framework doc lookup) and `shadcn` (stdio, `npx shadcn@latest mcp`, component registry access) as project-level MCP servers.
**Why:** User requested both explicitly to support frontend development speed.
**How to apply:** Available for future sessions in this project directory; no further setup needed.

---

## 2026-10-26 — Stack: FastAPI + Next.js + PostgreSQL
**Decision:** Backend on Python 3.11/FastAPI/SQLAlchemy 2.0/Alembic, frontend on Next.js 14 (TypeScript/Tailwind), database PostgreSQL 15.
**Why:** RFP leaves the stack open (requires "cloud-ready, modular, N-tier architecture," on-prem preferred — no language/framework mandate). Chosen for team fit and iteration speed.
**How to apply:** All new code follows this stack. See `docs/Technical_Requirements.md` for exact versions and check commands. *(Versions updated on 2026-10-27 to Python 3.12 and PostgreSQL 16 — see the entry above.)*

## 2026-10-26 — CBS integration mocked for initial development
**Decision:** Core Banking System integration is stubbed via `MockCBSClient` during feature development. Real CBS wiring (credentials, real endpoints, REST/SOAP/batch per RFP 7.3.7) is a separate, later milestone — not started without explicit sign-off.
**Why:** Avoids blocking feature work on CBS access/credentials that aren't available yet; keeps dev/test environments self-contained and fast.
**How to apply:** Any module needing account/customer data (e.g. FR-08 Legal Notice, FR-11 Account Statement, FR-12 Jari Statement) builds against the `CBSClient` interface and ships against the mock. Do not add real CBS endpoint URLs or credentials to any config before this decision is revisited.

## 2026-10-26 — Maker-checker implemented once, shared across modules
**Decision:** The branch-make / head-office-check / draft-pending-approved-rejected-returned workflow pattern that repeats across nearly every RFP Section 8 module is implemented as a single shared state machine (`service/workflow.py`), not reimplemented per module.
**Why:** The RFP repeats near-identical maker-checker language in ~20 of 31 modules (8.9, 8.10, 8.13–8.24 etc.). Duplicating it per module would be significant drift risk and wasted effort.
**How to apply:** Every new module that needs approval workflow reuses this shared helper. If a module's workflow genuinely diverges from the standard pattern, document why here before deviating.

## 2026-10-26 — Repo starts empty, harness docs written first
**Decision:** Harness pack (CLAUDE.md, docs/, feature_list.json, claude-progress.md, DECISIONS.md, init.sh) written before any application code.
**Why:** Per harness engineering practice — instructions/state-tracking in place before development begins reduces rework and drift.
**How to apply:** `init.sh` scaffolds the empty skeleton; FR-00 (auth/RBAC/audit/workflow infra) is the first feature picked up.
