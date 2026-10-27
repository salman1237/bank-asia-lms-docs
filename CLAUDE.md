# CLAUDE.md

## Goal
Reliable, verified work over speed. Every feature ships with a passing verification command before it is marked done.

## Project Overview
Litigation Management System (LMS) for Bank Asia PLC's Legal Department, built per `RFP_Litigation_Management_System_v0.3.md` (Sections 7 & 8 are the binding spec).

- **Backend:** Python 3.12, FastAPI, SQLAlchemy 2.0, Alembic, PostgreSQL 16
- **Frontend:** Next.js 14 (App Router), TypeScript, Tailwind
- **Auth:** JWT + Role-Based Access Control (RBAC)
- **Core Banking System (CBS):** integrated via a mock adapter during development (see `docs/Technical_Requirements.md`). Never call a real CBS endpoint from app code at this stage.

## Quick Start
- Install: `make setup`
- Run: `make up`
- Test: `make test`
- Full verification: `make check` (lint + types + tests, all three layers)

## Start
Read `claude-progress.md` first. Then check `feature_list.json` for the one feature currently `active`. Do not start a second feature while one is `active`.

## End
Update `claude-progress.md` and `DECISIONS.md` (if a decision was made), run `make check`, commit only verified work.

## Hard Constraints
- Every API router handler enforces RBAC — no endpoint is reachable without an explicit permission check.
- Every state-changing module follows the maker-checker pattern: branch-level **make**, head-office-level **check**, full `Draft Saved → Pending → Approved/Rejected/Returned` status history (this pattern repeats across nearly every RFP 8.x module — see `docs/Rules.md`).
- Every mutation writes an audit trail row (actor, timestamp, action, before/after). No exceptions.
- CBS access goes only through `CBSClient` (service layer abstraction) — routers and other services never call CBS directly. Mock implementation is the default in dev/test.
- Passwords are hashed (argon2/bcrypt); never logged or stored in plaintext.
- All DB schema changes go through Alembic migrations — never hand-edit the database.
- All PRs/commits must pass `pytest` + `mypy --strict` + `ruff check` (backend) and `tsc --noEmit` + `eslint` (frontend).

## Topic Docs
- `docs/Architecture.md` — layers, module boundaries, data flow. Read when changing structure.
- `docs/Rules.md` — coding conventions enforced on every change. Read when writing any code.
- `docs/Technical_Requirements.md` — stack, versions, check commands, CBS/SMS/email integration contracts. Read when adding a dependency or touching integrations.
- `docs/Functional_Requirements.md` — FR-01…FR-31, one per RFP Section 8 module. Read when building a feature; this is what `feature_list.json` is derived from.
- `docs/Non_Functional_Requirements.md` — security, performance, compliance, localization targets. Read when touching auth, reporting, or anything cross-cutting.
- `architecture/` — proposed target architecture with Mermaid diagrams: sites, network zones, storage, integrations, implementation plan, risks, technology layers. Read when touching deployment, infrastructure or an external integration.

## State Files
- `feature_list.json` — one entry per feature: behavior, verification command, state.
- `claude-progress.md` — session log: done / doing / blocked / next steps.
- `DECISIONS.md` — architectural and scope decisions with rationale, most recent first.
