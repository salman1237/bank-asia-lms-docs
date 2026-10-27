# Non-Functional Requirements

Read when: touching auth, reporting, performance-sensitive code, or anything cross-cutting. Sourced from RFP Sections 6 and 7; where the RFP is silent on a number, a reasonable default is proposed and flagged.

## Security
- RBAC with granular permissions and full audit trails (RFP 7.9.2, 7.11.1).
- Passwords: industry-standard hashing, encrypted storage, bank-policy-driven validation rules (RFP 7.9.3–7.9.5).
- Encryption at rest and in transit for all confidential data (RFP 7.2.16, 7.9.13).
- OWASP Top 10 compliance, including protection against injection, XSS, CSRF, with regular penetration testing (RFP 7.11.6).
- Session auto-timeout after a configurable idle period; account auto-lock after a configurable number of failed logins (RFP 7.9.17, 7.9.21).
- Single-workstation login restriction per user, terminal IP restriction supported case-by-case (RFP 7.9.15, 7.9.19).
- Data Breach response: the OEM/vendor must notify the Bank in writing within **4 hours** of becoming aware of an incident and cooperate fully with investigation (RFP 6.48). This is a contractual/ops obligation, not application code, but the system must support fast incident diagnosis (structured logs, access history — RFP 8.29.9–8.29.15).

## Performance *(RFP does not specify numeric SLAs — proposed defaults, confirm with stakeholders before launch)*
- API p95 response time: < 500ms for standard CRUD/list endpoints; < 2s for CBS-integrated or report-generation endpoints.
- Dashboard initial load: < 2s.
- Report generation (large/regulatory reports): async job with progress indicator if > 5s.

## Availability & Continuity
- 24/7/365 system availability under warranty/AMC, no unannounced downtime (RFP 6.45).
- Module-based redundancy, DR plan including remote location, target 100% uptime via DR failover (RFP 7.10.1–7.10.2).
- No data/software loss on abrupt shutdown or power failure; clean restart and recovery required (RFP 7.10.3–7.10.4).
- On-premises deployment preferred for full data sovereignty; DC + DR; private cloud/hybrid optional (RFP 7.8.2).

## Compliance & Audit
- Full audit trail on every view/edit/delete action, queryable by admins (RFP 7.9.12, 8.29.9–8.29.15).
- Bangladesh Bank regulatory reporting formats are mandatory and exact (RFP 8.25 — সংযোজনী-ক/খ/গ, RIT, BR-4, DBI 22, CRMR, ISS, Risk Base Audit module).
- Tamper-evident storage of audit/compliance records (RFP 8.29.15).
- Software/library licenses must remain valid and current (RFP 7.11.16).

## Localization
- Multi-language support required (RFP 7.2.5) — Bengali and English, including Bengali-labeled regulatory reports.
- Bank logo displayed in system UI and on printed/viewed reports and statements (RFP 7.2.9).

## Compatibility
- Browser-independent; compatible with latest versions of browsers, OS, and database (RFP 7.11.4).
- Compatible with any new/upgraded server, storage, OS, database, network, or security technology introduced later (RFP 7.11.11).
- Mobile access (responsive web or native app) for legal officers with MFA and offline-entry-with-sync (RFP 8.23.14–8.23.17).

## Scalability
- Cloud-ready, modular, N-tier architecture (RFP 7.1.1) — the FastAPI/Next.js/PostgreSQL stack satisfies this; avoid designs that assume a single-process or single-instance deployment.
- Open-source-friendly integration architecture, open API framework for local customization (RFP 7.3.1, 7.3.7).
