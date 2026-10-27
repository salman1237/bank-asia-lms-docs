# 2. Workflow Diagram

[← Back to index](README.md)

Almost every module in RFP Section 8 follows the same pattern: a request is made at branch level, checked at branch level, then made and checked at Head Office, with every step recorded. The LMS implements this once, in a shared workflow engine, and configures it per request type. This document shows that approval workflow, the end-to-end legal case lifecycle the modules support, and the bill disbursement and notification workflows.

## 2.1 Approval chain (maker–checker)

Each request type is configured with one or two approval tiers. The diagram shows the full two-tier chain used by, for example, Case Merit Analysis (RFP §8.9), Authorization Requests (§8.21) and Bill Disbursement (§8.16). Single-tier request types skip the tier they do not need.

```mermaid
---
config:
  layout: dagre
  look: classic
  flowchart:
    nodeSpacing: 30
    rankSpacing: 40
    padding: 10
---
flowchart TB
  BM["Branch maker<br/>creates request,<br/>attaches documents"]:::user --> DUP{"Pending request<br/>for same entity?"}
  DUP -->|"yes"| BLK(["Blocked - user shown<br/>pending reference number"]):::sec
  DUP -->|"no"| BC{"Branch checker"}:::lms
  BC -->|"return with reason"| BM
  BC -->|"reject with reason"| RJ(["Rejected - closed"]):::sec
  BC -->|"approve"| HM["HO maker<br/>reviews and enriches"]:::user
  HM --> HC{"HO checker"}:::lms
  HC -->|"return with reason"| BM
  HC -->|"reject with reason"| RJ
  HC -->|"approve"| AP(["Approved"]):::lms
  AP --> ACT["Downstream action<br/>file suit, disburse bill,<br/>post to CBS, publish notice"]:::lms
  ACT --> CP(["Completed"]):::lms

  classDef user fill:#EEF3FA,stroke:#1B498A,color:#002A64
  classDef lms fill:#1B498A,stroke:#002A64,color:#FFFFFF
  classDef sec fill:#FDE8EC,stroke:#D5002B,color:#7A0019
```

## 2.2 Request statuses

The same statuses appear in every module, so a user who has learned one screen has learned them all.

```mermaid
---
config:
  layout: dagre
  look: classic
---
stateDiagram-v2
  state "Draft saved" as Draft
  state "Pending branch approval" as PendingBranch
  state "Pending HO approval" as PendingHO
  state "Returned" as Returned
  state "Rejected" as Rejected
  state "Approved" as Approved
  state "Completed" as Completed

  [*] --> Draft : maker creates
  Draft --> Draft : maker edits
  Draft --> PendingBranch : send to checker
  PendingBranch --> PendingHO : branch checker approves
  PendingBranch --> Returned : returned with reason
  PendingBranch --> Rejected : rejected with reason
  PendingHO --> Approved : HO checker approves
  PendingHO --> Returned : returned with reason
  PendingHO --> Rejected : rejected with reason
  Returned --> PendingBranch : maker corrects and resubmits
  Approved --> Completed : downstream action done
  Rejected --> [*]
  Completed --> [*]
```

| Rule | Enforced by | RFP |
|---|---|---|
| A new request is blocked while one is pending for the same customer or case; the existing reference number is shown | Workflow engine | §8.9.13–§8.9.14 and equivalents |
| Requests are editable only in *Draft saved* or *Returned* | Workflow engine | §8.9.17 and equivalents |
| Return and reject always require a reason | Workflow engine | §8.9.15 and equivalents |
| Every transition records user, role, time, from-status, to-status and reason | Audit service | §8.9.18 and equivalents |
| Current status and full history are available through enquiry at any time | Enquiry view | §8.9.11 and equivalents |
| Email and SMS go to the next actor on initiate, return, reject and complete | Notification service | §8.9.12 and equivalents |
| A maker cannot approve their own request | RBAC | §7.9.9 |

## 2.3 Request processing — step by step

```mermaid
---
config:
  look: classic
  sequence:
    actorMargin: 30
    width: 120
---
sequenceDiagram
  autonumber
  actor M as Branch maker
  participant L as LMS workflow
  participant D as PostgreSQL
  participant Q as Outbox worker
  actor C as Checker

  M->>L: New request, documents
  L->>L: Check role and branch
  L->>D: Pending for this entity?
  alt pending request exists
    D-->>L: Yes - FR-08/2026/1013
    L-->>M: Blocked - reference shown
  else nothing pending
    L->>D: Draft and audit entry
    M->>L: Send to checker
    L->>D: Set Pending, audit, outbox
    Q->>D: Poll outbox
    Q-->>C: SMS and email alert
    C->>L: Approve, return or reject, with reason
    L->>D: New status, audit, outbox
    Q-->>M: Outcome by SMS and email
  end
```

*LMS workflow* is the API layer and workflow engine together. Each status change, its audit entry and its outbox event are written in one database transaction, so a notification can never refer to a change that was not saved.

## 2.4 End-to-end legal case lifecycle

The typical path of a defaulted account from first notice to closure, with the LMS module that supports each step. Cases against the Bank (RFP §8.19) and employee and other legal affairs (§8.20) follow their own shorter lifecycles on the same workflow engine.

```mermaid
---
config:
  layout: dagre
  look: classic
  flowchart:
    nodeSpacing: 30
    rankSpacing: 40
    padding: 10
---
flowchart TD
  A(["Account classified or<br/>in default, flagged by<br/>CBS end-of-day sync"]):::ext --> B["1st legal notice<br/>generated, approved<br/>and served"]:::lms
  B --> C{"Customer regularises?"}
  C -->|"yes"| Z1(["Monitor -<br/>no legal action"]):::ops
  C -->|"no"| D["Reminder notice"]:::lms
  D --> E["Case merit analysis<br/>security documents<br/>and guarantors"]:::lms
  E --> F["Property and title<br/>vetting - mutation and<br/>encumbrance review"]:::lms
  F --> G{"Fit for litigation?"}
  G -->|"needs documents"| E
  G -->|"not recommended"| Z2(["Alternative recovery<br/>or write-off review"]):::ops
  G -->|"yes"| H{"Mortgaged property<br/>with power of sale?"}
  H -->|"yes"| I["Pre-suit auction<br/>u/s 12(3) of the<br/>Artha Rin Adalat Ain"]:::lms
  H -->|"no"| J["File Artha Rin suit<br/>lower court"]:::lms
  I --> J
  J --> K["Case steps and hearings<br/>reminders 3 and 2<br/>working days before"]:::lms
  K --> L{"Judgment"}
  L -->|"against the Bank"| N["Appeal or revision<br/>HC Division or<br/>Appellate Division"]:::lms
  N --> K
  L -->|"decree for the Bank"| M["File execution case<br/>Artha Jari - reminder<br/>60 days after decree"]:::lms
  M --> O["Warrant of arrest and<br/>attachment of property"]:::lms
  O --> P["Execution auction u/s 33"]:::lms
  P --> Q{"Property sold?"}
  Q -->|"yes"| R["Recovery proceeds"]:::lms
  Q -->|"no"| S["Certificate of ownership<br/>u/s 33(5) or 33(7)"]:::lms
  R --> T["Settlement or compromise<br/>solenama where agreed"]:::lms
  S --> T
  T --> U["CBS reconciliation"]:::ext
  U --> V(["Case closed"]):::ops

  classDef lms fill:#1B498A,stroke:#002A64,color:#FFFFFF
  classDef ext fill:#FFFFFF,stroke:#64748B,color:#1E293B
  classDef ops fill:#F1F5F9,stroke:#64748B,color:#1E293B
```

| Lifecycle stage | LMS module | RFP |
|---|---|---|
| Default identified | CBS end-of-day sync, dashboard | §4(a), §7.2.14, §8.7 |
| Notices | 1st Legal Notice / Reminder Notice | §8.8 |
| Merit and vetting | Case Merit Analysis, pre-litigation TAT, land and property vetting | §8.9.19, §8.9.20 |
| Pre-suit and execution auctions | Auction Management, publication copies | §8.10 |
| Suit and hearings | Lower Court Suits, Case Steps Update | §8.13, §8.14 |
| Appeals | HC and AD Matters | §8.18 |
| Execution | Arising Cases, Warrant of Arrest, Appeal Bail Money | §8.15, §8.22, §8.23 |
| Statements | Account Statement, Jari Statement and Certificate | §8.11, §8.12 |
| Recovery and settlement | Bill Processing (recovery and settlement workflow), CBS reconciliation | §8.16.22 |
| Expenses at every stage | Bill Processing, Court Fee Return and Adjustment, Lawyer Packages | §8.6, §8.16, §8.17 |

The steps and statutory sections shown are the typical path; the case-step catalogue (RFP §8.4.13) is configurable, so the Legal Division can add or reorder steps without a software change.

## 2.5 Bill processing and disbursement

```mermaid
---
config:
  look: classic
  sequence:
    actorMargin: 30
    width: 120
---
sequenceDiagram
  autonumber
  actor LW as Panel lawyer
  actor BR as Branch
  actor HO as HO Legal
  participant L as LMS
  participant FN as Finance
  participant CB as Core Banking

  LW->>BR: Bill and invoice
  BR->>L: Enter bill, link case, attach evidence
  L->>L: Check package and fees
  BR->>L: Branch manager approves
  HO->>L: Verify and approve
  L->>FN: Payment instruction
  FN-->>L: Payment reference
  L->>CB: Post legal expense to the account
  CB-->>L: Posting reference
  L->>L: Mark disbursed
  L-->>LW: SMS and email - bill paid
```

*Branch* is the branch legal officer, who enters the bill as maker, and the branch manager, who approves it as checker. The bill memo can be downloaded as a PDF for physical signature at any point (RFP §8.16.15). If Finance or CBS is unavailable, the instruction stays in the outbox and is retried; it is never sent twice (see [Integration Diagram](05-integration-diagram.md)).

## 2.6 Notifications and escalation

```mermaid
---
config:
  layout: dagre
  look: classic
  flowchart:
    nodeSpacing: 30
    rankSpacing: 40
    padding: 10
---
flowchart TD
  S(["Scheduler runs every<br/>15 minutes and<br/>at 08:00 daily"]):::ops --> R["Evaluate notification<br/>rules against the court<br/>holiday calendar"]:::lms
  R --> R1["Hearing in 3 or 2<br/>working days"]:::lms
  R --> R2["Next date<br/>not updated"]:::lms
  R --> R3["Decree 60 days old,<br/>no execution case"]:::lms
  R --> R4["Lawyer bills<br/>pending too long"]:::lms
  R --> R5["Warrant unexecuted<br/>or case stalled"]:::lms
  R1 & R2 & R3 & R4 & R5 --> G["Create notifications<br/>by role, branch and case"]:::lms
  G --> CHN["Send by SMS, email<br/>and in-app"]:::lms
  CHN --> DL{"Delivered?"}
  DL -->|"no"| RT["Retry with backoff,<br/>then alert support"]:::ops
  DL -->|"yes"| AK{"Acknowledged or<br/>case updated in time?"}
  AK -->|"yes"| LOG(["Recorded in the<br/>account's<br/>communication log"]):::lms
  AK -->|"no"| ES["Escalate to supervisor<br/>and flag on dashboard"]:::sec
  ES --> LOG

  classDef lms fill:#1B498A,stroke:#002A64,color:#FFFFFF
  classDef ops fill:#F1F5F9,stroke:#64748B,color:#1E293B
  classDef sec fill:#FDE8EC,stroke:#D5002B,color:#7A0019
```

| Rule | Recipients | Default timing (configurable) | RFP |
|---|---|---|---|
| Upcoming hearing | Case dealing officer, branch manager, lawyer | 3 and 2 working days before | §8.26.2, §8.14.9 |
| Next date not updated | Case dealing officer, supervisor | Day after the hearing | §8.26.3, §8.14.15 |
| Execution not filed after decree | Case dealing officer, HO Legal | 60 days after decree | §8.26.1 |
| Certificate-owned property follow-up | HO Legal | Interval set by the Bank | §8.26.4 |
| Long-pending lawyer bills | Lawyer | Threshold set by the Bank | §8.26.5 |
| Lawyer update overdue | Lawyer | After each fixed date | §8.26.6 |
| Unexecuted warrant | Case dealing officer, supervisor | Threshold set by the Bank | §8.22.12 |
