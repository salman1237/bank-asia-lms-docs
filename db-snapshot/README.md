# Database Snapshot

A point-in-time export of the live demo database (`bank_asia_lms` on the Dokploy-managed PostgreSQL instance backing https://lms.skoder.co).

- **Taken:** 2026-10-26, 21:35 UTC+6 (via `pg_dump` directly against production, streamed over SSH)
- **Contains:** full schema (`module_records` table) + all data present at that moment — 293 rows across 27 modules
- **Files:**
  - `bank_asia_lms-20261026-213516.sql` — plain-text SQL dump (215 KB)
  - `bank_asia_lms-20261026-213516.sql.gz` — compressed copy (27 KB)

## What this is — and isn't

This is a **snapshot**, not a live sync. It reflects the database's state at the moment it was taken and will not update automatically. Anyone who has used the live demo since 2026-10-26 21:35 has changed data that this file does not reflect — treat it as a reference artifact, not a current source of truth.

See [`DECISIONS.md`](../DECISIONS.md) for the scope boundary between this demo backend and the real production system `CLAUDE.md`/`docs/` describe.

## Restoring it

```bash
createdb bank_asia_lms_restore
psql -d bank_asia_lms_restore -f bank_asia_lms-20261026-213516.sql
```

## Taking a new one

From a machine with SSH access to the VPS:

```bash
ssh myvps "docker exec bank-asia-lms-db-o3sljv.1.<task-id> pg_dump -U lms_app -d bank_asia_lms --no-owner --no-privileges" > bank_asia_lms-$(date +%Y%m%d-%H%M%S).sql
```

(Container task ID changes on redeploy — list it with `ssh myvps "docker ps --format '{{.Names}}' | grep bank-asia-lms-db"` first.)
