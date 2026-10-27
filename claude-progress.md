# Progress Log

## Status: Demo live on lms.skoder.co with a real backend + database; target architecture proposed in `architecture/`; real production system build not started

### Done
- RFP content extracted and captured in `RFP_Litigation_Management_System_v0.3.md`.
- Full harness doc pack written: `CLAUDE.md`, `docs/Architecture.md`, `docs/Rules.md`, `docs/Technical_Requirements.md`, `docs/Functional_Requirements.md`, `docs/Non_Functional_Requirements.md`, `feature_list.json`, `DECISIONS.md`, `init.sh`.
- Added `context7` and `shadcn` MCP servers to this project.
- Built a fully client-side demo (`frontend/`, Next.js 14 + TypeScript + Tailwind) covering all 31 RFP §8 modules as clickable CRUD + maker-checker workflow screens, plus Dashboard, Customer 360 Search, and Reports/MIS (48 reports with preview + CSV export). Synthetic seeded data via zustand + localStorage, no backend. See `frontend/README.md`.
- Dockerized (`frontend/Dockerfile`, multi-stage, Next.js standalone output) and root `docker-compose.yml` for Dokploy. Verified: `npm run build` (types pass, 8 routes generated), `docker build`, and a live container smoke-test all succeeded.
- Deployed to Dokploy on the user's VPS (89.116.122.118) at **https://lms.skoder.co**, via GitHub App integration (repo `salman1237/bank-asia-lms-demo`), auto-deploy on push to `main`.
- Pulled the real Bank Asia brand with Playwright against bankasia-bd.com: real logo/favicon, brand colors (`#1B498A` primary, `#D5002B` accent), fonts (Poppins headings / Inter body as free substitutes for Century Gothic / Webly Sleek). Applied across the app; redeployed and verified live.
- Built a real backend (`backend/`, separate repo `salman1237/bank-asia-lms-backend`): FastAPI + SQLAlchemy + PostgreSQL, generic `module_records` table (JSONB data/history) backing all 31 modules' CRUD + maker-checker transitions, auto-seeded from a snapshot of the original synthetic dataset. No auth (role-switcher login kept, per user's choice). Rewired the frontend's zustand store (`lib/api-client.ts`, `lib/store.ts`) to call this API instead of localStorage. Deployed to Dokploy as two more resources in the same project: `bank-asia-lms-backend` (API) and `bank-asia-lms-db` (managed Postgres), path-routed at `lms.skoder.co/api/*` (same-origin, no CORS). Verified end-to-end with Playwright against the live production URL: create → submit → approve cycle round-trips through the real database and survives a fresh browser session.

- Wrote the proposed target architecture (`architecture/`): nine documents with 37 Mermaid diagrams, each checked to render on Mermaid 10.9, 11 and 12. Aligned the stack versions in `CLAUDE.md`, `docs/` and `init.sh` to Python 3.12 and PostgreSQL 16, and settled background jobs on Celery with a Valkey broker (see `DECISIONS.md`).

### Doing
- Nothing in progress. Demo is presentation-ready.

### Blocked
- Nothing.

### Next Steps (real system — separate from the demo)
0. Confirm the open items in `architecture/README.md` ("Items to confirm at design sign-off") with the Bank.
1. Run `init.sh` to scaffold the FastAPI + Next.js + PostgreSQL skeleton (FR-00) for the actual production system described in `docs/Architecture.md`.
2. Implement auth/JWT, RBAC core, audit trail infra, shared maker-checker workflow state machine — these are prerequisites for every other FR.
3. Get `make check` passing on the empty skeleton before picking up FR-01.
4. Then proceed through `feature_list.json` in order, one `active` feature at a time.
5. The demo's `frontend/lib/modules-config.tsx` field definitions are a useful reference for real schema design, but demo code is not reused as production code (see `DECISIONS.md`).

### Session Notes
- The `frontend/` demo and the real backend/harness tracked in `feature_list.json` are two separate tracks — do not conflate "demo done" with "FR-xx done" in `feature_list.json`; that file still reflects the real system, which has not been started.
