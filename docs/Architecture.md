# Architecture

Read when: changing structure, adding a module, or touching how layers talk to each other.

## Layers

```
frontend (Next.js)
    |  HTTPS / JSON
api/        <- FastAPI routers. Auth + RBAC check, request/response schemas only. No business logic, no DB session beyond what the service needs.
    |
service/    <- Business logic, maker-checker workflow, audit trail writes, CBS/SMS/email calls (via clients below).
    |
repository/ <- SQLAlchemy models + query functions. Only layer that touches the DB session directly.
    |
PostgreSQL 15
```

`api/` never touches the database directly — it calls `service/`, which calls `repository/`. `repository/` never contains business logic or workflow rules.

## Module Layout

Each RFP Section 8 module (see `Functional_Requirements.md`) gets its own vertical slice:

```
backend/app/modules/<module_name>/
    api.py         # routers
    service.py     # business logic, workflow, audit
    repository.py  # DB access
    schemas.py     # Pydantic request/response models
    models.py      # SQLAlchemy models
tests/modules/<module_name>/
    test_service.py
    test_api.py
```

Cross-cutting modules (not tied to one RFP section): `auth/`, `audit/`, `cbs_client/`, `notifications/` (SMS/email), `documents/` (file storage).

## Maker-Checker Workflow (shared pattern)

Nearly every module in Section 8 repeats the same request lifecycle (branch makes, head office checks). This is implemented once as a shared state machine in `service/workflow.py` and reused by each module's service layer, not reimplemented per module.

States: `draft_saved -> pending -> approved | rejected | returned`

Rules enforced by the shared workflow helper:
- A new request cannot be created for an entity that already has a `pending` request (must be `rejected`/`approved`/`completed` first). Attempting to do so surfaces the existing request's reference number.
- `returned` or `draft_saved` requests are editable; other states are not.
- Every transition is logged (who, when, from-state, to-state, reason if rejected/returned) and is queryable via an enquiry endpoint.
- Email/SMS notification hooks fire on initiate / reject / complete, via `notifications/`.

## CBS Integration

`cbs_client/` defines a `CBSClient` protocol (interface) with methods like `get_account(account_no)`, `get_customer(customer_id)`. Two implementations:
- `MockCBSClient` — default in dev/test, returns fixture data from `tests/fixtures/cbs/`.
- `RealCBSClient` — stub only for now; wiring real CBS credentials/endpoints is a separate later milestone (see `DECISIONS.md`).

Selection is via `CBS_CLIENT_IMPL` env var. No code outside `cbs_client/` and `service/` layers may import CBS SDK/HTTP clients directly.

## Data Flow: Example (1st Legal Notice, RFP 8.8)

1. Branch user searches customer by account/card/mobile → `api/legal_notice.py` → `service.search_customer()` → `cbs_client.get_customer()` (mocked).
2. Branch user drafts notice → `service.create_notice()` → `repository` insert, state `draft_saved`.
3. Branch sends to checker → shared workflow `submit()` → state `pending`, notification fired.
4. Head office verifies → shared workflow `approve()` → state `approved`, audit row written, notice becomes queryable in the served-notices view.

## High Availability / DR

Out of scope for application code structure — covered in `Non_Functional_Requirements.md` and RFP Section 7.8/7.10. The app must not assume a single DB instance is permanent (no hardcoded connection pooling assumptions that break failover).
