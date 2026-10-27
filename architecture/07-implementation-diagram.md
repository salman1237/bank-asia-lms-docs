# 7. Implementation Diagram

[← Back to index](README.md)

How the LMS goes from contract to a supported production system: the phased roadmap, the environments and release pipeline, the data migration and cut-over approach, the project organisation, and the support model after go-live (RFP §6.8 items 9–10, §6.52).

## 7.1 Implementation roadmap

A phased plan of about 23 weeks from kick-off to go-live, followed by four weeks of hypercare. Durations are indicative and are baselined in the detailed project plan after the requirement workshops; calendar dates assume kick-off on 3 January 2027 purely for illustration. Delay is measured from the kick-off meeting (RFP §6.58(c)).

```mermaid
gantt
  title Indicative implementation roadmap
  dateFormat YYYY-MM-DD
  axisFormat %d %b

  section Mobilise
  Kick-off meeting                        :milestone, m0, 2027-01-03, 0d
  Project charter and plan baseline       :a0, 2027-01-03, 14d

  section Discover and design
  Requirement workshops and gap analysis  :a1, 2027-01-03, 28d
  Solution and integration design         :a2, after a1, 14d
  Design sign-off                         :milestone, m1, after a2, 0d

  section Infrastructure
  Test and UAT environments               :b1, 2027-01-24, 28d
  Production build at DC, NDR and DR      :b2, 2027-03-07, 42d

  section Build and configure
  Sprint 1 - platform, workflow, admin    :c1, after a2, 14d
  Sprint 2 - pre-litigation               :c2, after c1, 14d
  Sprint 3 - litigation                   :c3, after c2, 14d
  Sprint 4 - recovery and finance         :c4, after c3, 14d
  Sprint 5 - reports and notifications    :c5, after c4, 14d

  section Integration
  CBS integration                         :d1, after a2, 56d
  AD, SMS, email, Finance and EDW         :d2, after a2, 56d

  section Data migration
  Profiling, mapping and gap analysis     :e1, 2027-01-24, 28d
  Mock migrations 1 and 2                 :e2, after c3, 28d

  section Testing
  System integration testing              :f1, after c5, 21d
  Performance testing and VAPT            :f2, after f1, 14d
  User acceptance testing                 :f3, after f1, 21d
  UAT sign-off                            :milestone, m2, after f3, 0d

  section Training and go-live
  Technical training                      :g1, 2027-01-17, 14d
  End-user training - train the trainer   :g2, after f1, 21d
  Final migration and cut-over            :g3, after f3, 7d
  Go-live                                 :milestone, m3, after g3, 0d
  Hypercare and first DR drill            :g4, after g3, 28d
```

| Phase | Key deliverables | Exit criteria |
|---|---|---|
| Mobilise | Project charter, plan, governance, RAID log, communication and escalation matrix | Plan baselined with the Bank |
| Discover and design | Requirement specification, gap analysis against RFP §8, solution design, integration specifications, data dictionary, security design | Design signed off by the Bank |
| Infrastructure | Test, UAT and production environments at DC, NDR and DR; hardening; security review | Environments accepted by Bank ICT |
| Build and configure | Five sprints of configured modules, each demonstrated to the Legal Division | Sprint acceptance by business owners |
| Integration | CBS, AD/SSO, SMS, email, Finance and EDW interfaces built to signed specifications | Interface tests passed with each system owner |
| Data migration | Mapping, data gap report (RFP §7.4.4), two mock migrations with reconciliation | Reconciliation signed off by business |
| Testing | SIT, performance test, VAPT, UAT with the Legal Division | Zero open critical or high defects; UAT signed |
| Training and go-live | Technical and end-user training, SOPs (RFP §6.43), cut-over, go-live, hypercare, first DR drill | Go-live sign-off; warranty starts (RFP §6.51) |

After go-live the solution is under a three-year warranty with support, followed by three years of AMC (RFP §6.33–§6.35).

## 7.2 Environments and release pipeline

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
  subgraph BUILD["1 - Build"]
    direction LR
    DEV["Developer"]:::user -->|"merge request<br/>and peer review"| GIT["Source repository<br/>Bank-approved Git"]:::ops
    GIT --> CI["CI pipeline"]:::ops
  end
  subgraph GATES["2 - Automated quality gates"]
    direction LR
    G1["Build and<br/>unit tests"]:::ops --> G2["Static code and<br/>dependency scan"]:::sec
    G2 --> G3["Container<br/>image scan"]:::sec
    G3 --> G4["Sign image and<br/>generate SBOM"]:::sec
  end
  subgraph TEST["3 - Test"]
    direction LR
    REG[("Private container<br/>registry")]:::data --> TST["Test / SIT<br/>automated regression"]:::lms
    TST --> UAT["UAT<br/>business sign-off"]:::lms
  end
  subgraph RELEASE["4 - Approve and release"]
    direction LR
    CAB{"Change<br/>advisory board"}:::sec -->|"approved"| PRD["Production at DC<br/>rolling or blue-green"]:::lms
    CAB -->|"rejected"| BACK(["Back to<br/>development"]):::user
    PRD --> DRS["DR updated with the<br/>same signed image"]:::lms
    PRD --> MON["Post-release monitoring,<br/>rollback if needed"]:::ops
  end
  BUILD --> GATES
  GATES -->|"signed image"| TEST
  TEST -->|"UAT signed off"| RELEASE

  classDef user fill:#EEF3FA,stroke:#1B498A,color:#002A64
  classDef lms fill:#1B498A,stroke:#002A64,color:#FFFFFF
  classDef data fill:#002A64,stroke:#002A64,color:#FFFFFF
  classDef sec fill:#FDE8EC,stroke:#D5002B,color:#7A0019
  classDef ops fill:#F1F5F9,stroke:#64748B,color:#1E293B
```

| Environment | Purpose | Data | Integrations |
|---|---|---|---|
| Development (vendor) | Build and unit testing | Synthetic | Simulated CBS, SMS and email |
| Test / SIT | System integration and regression testing; scripted simulation runs (RFP §7.2.6) | Masked copy of migrated data | CBS and gateway test endpoints |
| UAT | Business acceptance by the Legal Division | Masked production-like data | CBS and gateway UAT endpoints |
| Production — DC | Live service | Production | Production |
| Production — NDR and DR | Continuity | Replicas of production | Production endpoints, activated on failover |

The same signed container image moves unchanged from Test to UAT to production; only environment configuration differs (RFP §7.8.3). Every production release goes through the Bank's change control, with a tested rollback.

## 7.3 Data migration

Existing data is migrated into the LMS (RFP §7.4.3), and fields that have no legacy source are identified and mapped up front (RFP §7.4.4).

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
  subgraph SRC["Legacy sources"]
    direction TB
    X1["Legal registers<br/>and spreadsheets"]:::ext
    X2["Existing legal or<br/>recovery database"]:::ext
    X3["Scanned<br/>case files"]:::ext
  end
  SRC --> EX["Extract"]:::lms
  EX --> STG[("Staging area")]:::data
  STG --> CL["Cleanse, de-duplicate,<br/>map to the LMS model"]:::lms
  CL --> GAP["Data gap mapping<br/>missing mandatory<br/>fields flagged"]:::lms
  GAP --> VAL{"Validation<br/>rules passed?"}
  VAL -->|"no"| FIX["Business correction"]:::user
  FIX --> CL
  VAL -->|"yes"| MOCK["Mock migrations 1 and 2<br/>into Test and UAT"]:::lms
  MOCK --> REC["Reconciliation<br/>counts, balances, documents"]:::ops
  REC --> SO{"Business<br/>sign-off"}
  SO -->|"no"| CL
  SO -->|"yes"| FINAL["Final migration at cut-over"]:::lms
  FINAL --> POST["Post-migration<br/>reconciliation report"]:::ops

  classDef user fill:#EEF3FA,stroke:#1B498A,color:#002A64
  classDef lms fill:#1B498A,stroke:#002A64,color:#FFFFFF
  classDef data fill:#002A64,stroke:#002A64,color:#FFFFFF
  classDef ext fill:#FFFFFF,stroke:#64748B,color:#1E293B
  classDef ops fill:#F1F5F9,stroke:#64748B,color:#1E293B
```

## 7.4 Cut-over

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
  F1["Freeze legacy entry<br/>announce to branches"]:::user --> F2["Final delta extract"]:::lms
  F2 --> F3["Load and reconcile"]:::lms
  F3 --> F4["Smoke tests by the<br/>Legal Division and ICT"]:::ops
  F4 --> GN{"Go / no-go"}:::sec
  GN -->|"go"| GL(["LMS live for all branches"]):::lms
  GN -->|"no-go"| RB["Roll back - legacy<br/>stays system of record"]:::sec
  GL --> HC["Hypercare<br/>on-site and remote support"]:::ops
  HC --> DR1["First DR drill"]:::ops

  classDef user fill:#EEF3FA,stroke:#1B498A,color:#002A64
  classDef lms fill:#1B498A,stroke:#002A64,color:#FFFFFF
  classDef sec fill:#FDE8EC,stroke:#D5002B,color:#7A0019
  classDef ops fill:#F1F5F9,stroke:#64748B,color:#1E293B
```

Legacy sources remain available read-only for an agreed period after go-live, so any migrated record can be traced back to its source.

## 7.5 Project organisation

```mermaid
---
config:
  layout: dagre
  look: classic
  flowchart:
    nodeSpacing: 30
    rankSpacing: 40
    padding: 12
    wrappingWidth: 280
---
flowchart TB
  SC["Project steering committee<br/>Bank senior management<br/>and vendor leadership"]:::user
  SP["Project sponsors<br/>Head of Legal and<br/>Head of ICT"]:::user
  subgraph PM["Project management"]
    direction LR
    BPM["Bank project<br/>manager"]:::user <-->|"weekly status<br/>and RAID log"| VPM["Vendor project<br/>manager"]:::lms
  end
  BTEAM["<b>Bank team</b><br/>Legal and business SMEs<br/>from the Legal Division<br/>and branches<br/>Bank ICT - infrastructure,<br/>network, security, CBS"]:::user
  VTEAM["<b>Vendor delivery team</b><br/>Solution architect<br/>Development and configuration<br/>Integration<br/>Quality assurance and testing<br/>Data migration<br/>Training and change management<br/>On-site technical SMEs x2,<br/>OEM and partner"]:::lms
  SC --> SP --> PM
  PM --> BTEAM
  PM --> VTEAM

  classDef user fill:#EEF3FA,stroke:#1B498A,color:#002A64
  classDef lms fill:#1B498A,stroke:#002A64,color:#FFFFFF
```

At least two technical subject-matter experts, preferably one from the OEM and one from the partner, are on site through to project completion (RFP §6.28).

| Escalation level | Bank | Vendor | Raised when |
|---|---|---|---|
| 1 | Workstream lead | Workstream lead | Issue not resolved within 2 working days |
| 2 | Bank project manager | Vendor project manager | Not resolved within 5 working days, or threatens a milestone |
| 3 | Project steering committee | Vendor leadership | Threatens go-live, budget or a contractual obligation |

## 7.6 Support model after go-live

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
  USR["Users"]:::user -->|"phone, email, portal"| L1["L1 - Bank IT help desk<br/>logging and triage"]:::user
  L1 -->|"application issue"| L2["L2 - vendor support desk<br/>Sun-Thu 10:00-18:00,<br/>24x7 for severity 1"]:::lms
  L2 -->|"defect or change"| L3["L3 - engineering and OEM"]:::lms
  L2 --> KB["Knowledge base and SOPs"]:::ops
  L3 --> REL["Patch or release<br/>through change control"]:::ops
  REL -->|"fix delivered"| USR

  classDef user fill:#EEF3FA,stroke:#1B498A,color:#002A64
  classDef lms fill:#1B498A,stroke:#002A64,color:#FFFFFF
  classDef ops fill:#F1F5F9,stroke:#64748B,color:#1E293B
```

| Severity | Definition | Response | Restore or workaround | Resolution |
|---|---|---|---|---|
| 1 — Critical | Service down, or data integrity at risk | 30 minutes, 24x7 | 4 hours | 24 hours |
| 2 — High | Major function unavailable with no workaround | 2 hours | 8 hours | 3 working days |
| 3 — Medium | Function impaired, workaround available | 4 working hours | — | 10 working days |
| 4 — Low | Cosmetic issue, query or enhancement request | 1 working day | — | Next scheduled release |

The help desk runs 10:00–18:00, Sunday to Thursday (RFP §7.2.1), with 24x7x365 cover for critical incidents under warranty and AMC (RFP §6.45). Patches, security fixes and upgrades are delivered on a published schedule (RFP §6.27, §6.46). Response and resolution times above are proposed and are finalised in the SLA.
