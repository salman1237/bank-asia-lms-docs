# Bank Asia LMS — Project Docs

Project documentation and harness for the Litigation Management System built for Bank Asia PLC, per `RFP_Litigation_Management_System_v0.3.md`.

This repo holds the **documentation and harness**, not the application code — those live in their own repos:

- Frontend (demo + production UI): [`bank-asia-lms-demo`](https://github.com/salman1237/bank-asia-lms-demo)
- Backend (FastAPI + PostgreSQL, demo-grade): [`bank-asia-lms-backend`](https://github.com/salman1237/bank-asia-lms-backend)

Live demo: **https://lms.skoder.co**

## Contents

- **`CLAUDE.md`** — the map: stack, quick-start commands, hard constraints, pointers into `docs/`
- **`docs/`** — Architecture, Rules, Technical/Functional/Non-Functional Requirements for the *real* production system
- **`architecture/`** — proposed target architecture for the real system: nine documents with Mermaid diagrams (system, workflow, data flow, network/storage/server, integration, Level-0 context, implementation, risk management, technology layers). Start at `architecture/README.md`
- **`feature_list.json`** — one entry per feature (FR-00…FR-31), seeded from `docs/Functional_Requirements.md`
- **`claude-progress.md`** — running session log of what's done, in progress, and next
- **`DECISIONS.md`** — architectural and scope decisions with rationale, most recent first
- **`init.sh`** — one-command environment setup for the real backend build
- **`docker-compose.yml`** — local dev compose stub for the real system
- **`RFP_Litigation_Management_System_v0.3.md`** — full text transcription of the Bank Asia RFP (source PDF not included — see below)
- **`presentation/`** — the 15-slide client presentation (`.pptx` + `.pdf`), built from real screenshots of the live demo
- **`db-snapshot/`** — point-in-time export of the live demo database (schema + data). See its README for what it is and how to restore or refresh it.

## Not included here

- `frontend/` and `backend/` — separate repos (linked above)
- The original RFP PDF and workshop slide PDF — large binaries already fully transcribed into `RFP_Litigation_Management_System_v0.3.md`
- `db-exports/` — the local working folder for ad hoc DB dumps; the curated, documented snapshot lives in `db-snapshot/` instead

## Important scope note

Two parallel tracks exist and should not be conflated:

1. **The demo** (`frontend/` + `backend/`, live at lms.skoder.co) — built fast for a client presentation. Real persistence, no real auth, one generic DB table, no RBAC enforcement. See `DECISIONS.md`.
2. **The real system** described by `CLAUDE.md` / `docs/` / `feature_list.json` — has not been started. When it is, follow the harness in this repo from `init.sh` onward.
