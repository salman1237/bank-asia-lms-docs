# Functional Requirements

Read when: building a feature. Each FR below maps 1:1 to an RFP Section 8 module and seeds one entry in `feature_list.json`. Full field-level detail lives in `RFP_Litigation_Management_System_v0.3.md` — this doc is the index, not a replacement.

Every FR module that is a "request" type (almost all of them) implements the shared maker-checker workflow described in `Architecture.md` — that detail is not repeated per row below.

| ID | Module (RFP §) | Summary |
|---|---|---|
| FR-00 | — | Project scaffolding: auth, RBAC core, audit trail infra, shared workflow state machine. Prerequisite for every other FR. |
| FR-01 | User Group Management (8.1) | Create/edit/delete user groups; group-wise privilege/right setup; search/filter groups. |
| FR-02 | User Management (8.2) | Create/edit/delete users, group-wise menu access restriction, maker-checker approval of profiles, lock/unlock, activate/deactivate, session policy. |
| FR-03 | Login (8.3) | Login with user ID/password, lockout after 5 failed attempts, self-service password reset. |
| FR-04 | Parameter Management (8.4) | Admin CRUD for ~36 reference/lookup lists (Department, Case Type, Court List, Lawyer List, Expense Type, etc.) used throughout the system. |
| FR-05 | Holiday Setup (8.5) | Court-wise (Lower Court / High Court) holiday calendar management. |
| FR-06 | Lawyer Package Bill Setup (8.6) | Add/edit/delete/verify lawyer billing packages; extend package amount. |
| FR-07 | Dashboard (8.7) | Real-time daily stats: notices, approvals, auctions, case updates, professional bills, court schedules. |
| FR-08 | 1st Legal Notice / Reminder Notice (8.8) | Create/send/verify legal notices; system-generated notices; CBS customer search; served-notice history view. |
| FR-09 | Case Merit Analysis — CMA (8.9) | Pre-litigation case viability assessment workflow; document archiving (security docs, sanction letters, facility/guarantor details); dedicated pre-litigation TAT workflow; land/property legal vetting workflow. |
| FR-10 | Auction Management (8.10) | Auction record creation/validation, publication management, system-generated publication copies (12(3), 33(5), 33(7)), bidder info, final auction memo. |
| FR-11 | Account Statement Generation (8.11) | CBS-integrated account statement generation with interest application. |
| FR-12 | Jari Statement with Certificate (8.12) | Aurtho Jari statement and certificate generation from CBS data + calculations. |
| FR-13 | Lower Court Suit Management (8.13) | Suit file management, reassignment, Arji copy upload, legal expense recording, hearing/limitation tracking, dormant-case accountability. |
| FR-14 | Case Steps Update (8.14) | Daily case progress tracking, lawyer expense entry tied to package bills, automated hearing/limitation/milestone notifications (email, push, in-system). |
| FR-15 | Arising Case from Original Case (8.15) | Linked execution suits, session cases, merged suit monitoring, integrated case history tree. |
| FR-16 | Bill Processing and Disbursement (8.16) | Lawyer professional bills, court fees, paper publication bills, court entertainment bills, staff conveyance bills; Finance Division integration; partial/full recovery and settlement workflow. |
| FR-17 | Court Fee Return and Adjustment (8.17) | Return unutilized court fees; adjust against lawyer's next case; audit log of returns/adjustments. |
| FR-18 | HC & AD Matters (8.18) | High Court / Appellate Division case filing (linked or independent), arising case tracking, lawyer expense management, integrated case history across courts. |
| FR-19 | Case Against Bank (8.19) | Record/track/manage cases filed against the bank; lawyer bill integration; centralized repository. |
| FR-20 | Employee Related & Other Legal Affairs Suit (8.20) | Non-account-linked internal/miscellaneous legal cases (employee disputes, contractual/regulatory issues). |
| FR-21 | Authorization Management (8.21) | Branch-to-HO approval requests: plaintiff change, case withdrawal, appeal bail money withdrawal, court change, and a configurable "other request" type. |
| FR-22 | Warrant of Arrest Management (8.22) | Record WOA, arrest history (borrower/guarantor), execution bill entry, issuance/service/enforcement tracking, unexecuted-warrant escalation. |
| FR-23 | Appeal Bail Money Deposit & Withdraw (8.23) | Bail deposit entry, withdrawal with related expenses, deposit/withdrawal history and balance tracking; mobile access with MFA and offline sync. |
| FR-24 | Document Upload (8.24) | Multi-format document upload with metadata, search/retrieval, audit trail of uploads/downloads. |
| FR-25 | Reports (8.25) | ~48 reports: Bangladesh Bank regulatory formats (সংযোজনী-ক/খ/গ, RIT, BR-4, DBI 22, CRMR, ISS), portfolio/segment/officer/lawyer summaries, pending/disposed case statements, recovery summaries, bill/fee summaries. |
| FR-26 | Notification (8.26) | Execution-case filing reminder, fixed-date case notifications, "next date not updated" alerts, certificate-owned-property notification, lawyer bill/update reminders, account-wise communication log. |
| FR-27 | Customer 360 Search (8.27) | Multi-parameter customer search; consolidated view (personal info, legal cases, financials, documents, interaction history, arrest/bail history). |
| FR-28 | Legal Memos and Notices Publication (8.28) | Admin memo/notice publishing to target groups with expiry management and dashboard display. |
| FR-29 | System Settings (8.29) | Credential/password policy config, session timeout (global and per-user/role), CAPTCHA config, API config, full audit log of settings changes, user login/activity history. |
| FR-30 | Legal Opinion Management (8.30) | Submit/track legal opinion requests, record/retrieve opinions, monitor response timelines. |
| FR-31 | Task Management System (8.31) | Internal/branch work request and task assignment, deadline tracking, completion status, outcome audit record. |

## Notes on Sizing

Each FR above is section-sized, not session-sized. When an FR is picked up as the `active` feature in `feature_list.json`, break it into session-sized sub-tasks (one controller/workflow slice at a time — e.g. "FR-08: notice CRUD + draft/send" before "FR-08: CBS customer search integration").
