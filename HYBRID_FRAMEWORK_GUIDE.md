# Hybrid Framework Guide: Spec-Kit + GSD-v1 + GSD-2

**Document Date:** May 1, 2026
**Purpose:** Integrate three complementary AI-native development frameworks for enterprise-grade agentic engineering

---

## Executive Summary

Your project (`hdd-gsd2-hybrid-framework`) combines **three proven frameworks** into a unified system:

| Framework | Creator | Role | Stars | Best For |
|-----------|---------|------|-------|----------|
| **Spec-Kit** | GitHub | **Definition Layer** (What to build) | 92.1K | Requirements governance, constitutional clarity, quality gates |
| **GSD-v1** | @glittercowboy/gsd-build | **Prompt Layer** (How to guide building) | 59.3K | Context engineering, agent coordination, atomic workflows |
| **GSD-2** | @glittercowboy/gsd-build | **Execution Layer** (How to build autonomously) | 7K | Unattended automation, state management, cost tracking |

**Hybrid Architecture:**
```
┌─────────────────────────────────────────────────────────────────┐
│                    Your Hybrid Framework                         │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  Spec-Kit        GSD-v1              GSD-2                     │
│  ─────────────    ─────────────      ──────────────            │
│  Specifications  Context              Autonomous               │
│  Constitution    Engineering          Execution                │
│  Requirements    Multi-Agent          State Machine            │
│  Quality Gates   Orchestration        Cost Tracking            │
│  Reviewability   Atomic Commits       Git Management           │
│                  Verification         Parallelization          │
│                  XML Formatting       Dashboard               │
│                                                                │
│  ↓↓↓ WORKFLOW ↓↓↓                                              │
│                                                                 │
│  Define (Spec-Kit) → Plan (GSD-v1) → Execute (GSD-2)          │
│  Requirements      Context          Autonomous                │
│  Review Gates      Engineer          Delivery                 │
│                    Agents                                      │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

---

## Framework Deep-Dive

### 1. Spec-Kit (Definition Layer)

**What:** GitHub's specification-driven development toolkit
**Creator:** GitHub
**Language:** Python
**Repository:** [github/spec-kit](https://github.com/github/spec-kit)
**Stars:** 92.1K

#### Core Concept
Specifications are executable; code serves specifications (power inversion from traditional TDD).

#### Workflow (6 Phases)
1. **Constitution** — Define project values, coding standards, compliance rules
2. **Specify** — Executable specifications in multiple formats (Gherkin, OpenAPI, Protobuf, etc.)
3. **Plan** — Breaking specs into implementable tasks
4. **Tasks** — Atomic, verifiable work units
5. **Implement** — Code development
6. **Verify** — Spec compliance validation

#### Key Features
- **Constitutional Governance** — All decisions cascade from a constitution
- **100+ Extensions** — Domain-specific and compliance presets
- **Multi-Format Specs** — Gherkin (BDD), OpenAPI, Protobuf, JSON Schema, GraphQL
- **Agent Support** — Works with Claude, Cursor, GitHub Copilot, Windsurf, etc.
- **Quality Gates** — Mandatory review points before advancing phases

#### Configuration Example
```yaml
# Constitution
project:
  values:
    - "Security-first: All data encrypted at rest and in transit"
    - "User trust: Clear privacy disclosures, no dark patterns"
    - "Performance: < 200ms p99 latency, 99.95% uptime SLA"

standards:
  - "TypeScript strict mode mandatory"
  - "80% test coverage (lines + branches)"
  - "Architecture Decision Records (ADRs) for all major changes"

compliance:
  - "OWASP Top 10 audit quarterly"
  - "SOC 2 Type II ready (encryption, access logs, incident response)"
```

#### When to Use
✅ Regulated industries (fintech, healthcare, telecom)
✅ Large teams with governance requirements
✅ Multi-month projects with stakeholder reviews
✅ Public-facing systems requiring auditable decisions

---

### 2. GSD-v1 (Context Engineering Layer)

**What:** Meta-prompting system for Claude Code and 15+ AI coding agents
**Creator:** @glittercowboy (TÂCHES) — gsd-build organization
**Language:** JavaScript/TypeScript
**Repository:** [gsd-build/get-shit-done](https://github.com/gsd-build/get-shit-done)
**Stars:** 59.3K
**Version:** v1.39.1 (actively maintained alongside v2)

#### Core Concept
**Context is the bottleneck.** GSD v1 structures work to keep context windows clean and focused.

#### Workflow (6 Phases)
1. **Initialize** — Questions → Research → Requirements → Roadmap
2. **Discuss Phase** — Capture implementation decisions and preferences
3. **Plan Phase** — Research + decompose into atomic XML-structured tasks
4. **Execute Phase** — Parallel wave execution with fresh 200K context per task
5. **Verify Work** — Human acceptance testing (UAT)
6. **Ship** — Create PR with auto-generated descriptions

#### Key Principles
| Principle | Implementation |
|-----------|-----------------|
| **Context Engineering > Prompting** | Every dispatch pre-loads only relevant files |
| **Thin Orchestrator** | Spawns agents, integrates results, never does heavy lifting |
| **Spec-Driven Development** | XML-formatted plans with must-haves and verification criteria |
| **Atomic Commits** | One commit per task, bisect-able git history |
| **No Enterprise Theater** | No story points, Jira, sprint ceremonies — just code |
| **Vibecoding Prevention** | Structured plans + verification prevent garbage output |

#### Directory Structure (`.planning/`)
```
.planning/
├── config.json                # Workflow settings (modes, models, profiles)
├── PROJECT.md                 # Project vision and summary
├── REQUIREMENTS.md            # v1/v2/out-of-scope features
├── ROADMAP.md                 # Phase breakdown (1-10 per milestone)
├── STATE.md                   # Current status, decisions, position
├── DECISIONS.md               # Append-only architectural decisions register
├── KNOWLEDGE.md               # Cross-session patterns and lessons learned
├── research/
│   ├── stack.md               # Technology stack analysis
│   ├── features.md            # Competitor/ecosystem feature survey
│   ├── architecture.md        # Design patterns and reference implementations
│   └── pitfalls.md            # Common mistakes and how to avoid them
├── phase-001-users/
│   ├── CONTEXT.md             # Your implementation preferences for this phase
│   ├── RESEARCH.md            # Investigative findings
│   ├── plan-01-auth.md        # Individual task plan (XML)
│   ├── plan-02-profile.md
│   ├── plan-01-auth-SUMMARY.md   # What happened (YAML + narrative)
│   ├── plan-02-profile-SUMMARY.md
│   ├── VERIFICATION.md        # UAT checklist
│   └── UAT.md                 # Test script (human-runnable)
└── phase-002-products/
    └── ... (same structure)
```

#### Example: Atomic XML Task Plan
```xml
<task type="auto">
  <name>User authentication endpoint</name>
  <description>Express middleware for JWT-protected routes</description>
  <files>src/middleware/auth.ts, src/utils/jwt.ts</files>
  <action>
    1. Install jose (not jsonwebtoken — CommonJS issues)
    2. Implement JWT signing with RS256 + PKCS8 private key
    3. Create express middleware that validates Authorization: Bearer token
    4. Return 401 if token invalid or expired
    5. Attach user ID to req.user on success
  </action>
  <must_haves>
    <artifact>src/middleware/auth.ts exported</artifact>
    <artifact>Tests pass: npm test -- auth.test.ts</artifact>
    <truth>curl -H "Authorization: Bearer invalid" returns 401</truth>
    <truth>curl -H "Authorization: Bearer valid" returns 200</truth>
  </must_haves>
  <verify>curl -X GET localhost:3000/api/me -H "Authorization: Bearer $(jwt_token)" returns 200 + user object</verify>
  <done>Authentication middleware validates tokens and protects routes</done>
</task>
```

#### 75+ Commands (v1.39.1)
**Core Workflow:**
- `/gsd-new-project` — Initialize with discussion → research → requirements → roadmap
- `/gsd-discuss-phase N` — Capture implementation preferences
- `/gsd-plan-phase N` — Research + plan with verification
- `/gsd-execute-phase N` — Parallel wave execution
- `/gsd-verify-work N` — UAT confirmation
- `/gsd-next` — Auto-advance to next step

**Phase Management:**
- `/gsd-add-phase`, `/gsd-insert-phase`, `/gsd-edit-phase`, `/gsd-remove-phase`
- `/gsd-add-backlog`, `/gsd-review-backlog`, `/gsd-plant-seed`

**Quality:**
- `/gsd-review` — Cross-AI peer review
- `/gsd-secure-phase N` — Security enforcement
- `/gsd-docs-update` — Verified documentation generation
- `/gsd-audit-uat` — Find phases missing UAT

**Utilities:**
- `/gsd-settings` — Configure models and workflow
- `/gsd-spike` — Throwaway feasibility experiments
- `/gsd-sketch` — UI mockup exploration
- `/gsd-quick --discuss --research --validate` — Ad-hoc tasks

#### Configuration Example
```json
{
  "mode": "interactive",
  "granularity": "standard",
  "profile": "balanced",
  "workflow": {
    "research": true,
    "plan_check": true,
    "verifier": true,
    "auto_advance": false,
    "discuss_mode": "discuss"
  },
  "models": {
    "planner": "claude-opus-4-7",
    "executor": "claude-sonnet-4-6",
    "verifier": "claude-sonnet-4-6"
  },
  "parallelization": {
    "enabled": true
  }
}
```

#### When to Use GSD-v1
✅ Solo developers and small teams (< 10 people)
✅ Rapid iteration (weekly or bi-weekly releases)
✅ Vibecoding prevention (need quality without overhead)
✅ Multi-agent coordination (parallel planning + execution)
✅ Atomic git history requirement

---

### 3. GSD-2 (Autonomous Execution Layer)

**What:** Production TypeScript application with state machine orchestration
**Creator:** @glittercowboy (TÂCHES) — gsd-build organization (maintained by @jeremymcs)
**Language:** TypeScript (94.6%), built on Pi SDK
**Repository:** [gsd-build/gsd-2](https://github.com/gsd-build/gsd-2)
**Stars:** 7K
**Version:** v2.78.1 (released every 2-5 days)
**Latest Updates:** Worktree lifecycle, unified component system, auto pipeline, extensions framework

#### Core Concept
GSD v1 proved context engineering works. **GSD-2 makes it production-ready** by replacing "prompt framework" with "state machine application."

#### Architecture
```
gsd-2 (CLI binary)
  └─ loader.ts                    # Sets env vars, dynamic imports
      └─ cli.ts                   # SDK managers, extensions, InteractiveMode
          ├─ headless.ts          # Headless orchestrator (CI/cron)
          ├─ onboarding.ts        # LLM provider + tool key setup
          ├─ wizard.ts            # Env hydration
          └─ src/resources/
              ├─ extensions/      # 24 bundled extensions (GSD, browser, search, etc.)
              ├─ agents/          # 5 specialized agents (scout, researcher, worker, js-pro, ts-pro)
              └─ WORKFLOW.md      # Manual bootstrap protocol
```

#### Workflow (per Slice)
```
Plan → Execute → Complete → Reassess Roadmap → Validate → Next Slice
```

Each **Milestone** = 4-10 **Slices** (each 1-7 tasks)
Each **Task** must fit in one 200K context window (iron rule)

#### Key Features

| Feature | Capability |
|---------|-----------|
| **State Machine** | Deterministic workflow (not LLM self-loop) |
| **SQLite Database** | Authoritative project state (.gsd/gsd.db) |
| **Fresh Context** | New 200K session per task, no garbage |
| **Worktree Isolation** | Git `milestone/MID` branch per milestone (auto-merge) |
| **Crash Recovery** | Lock files + session forensics restore on failure |
| **Cost Tracking** | Per-unit token/cost ledger with dashboard + budget ceiling |
| **Stuck Detection** | Sliding-window detector prevents infinite loops (retry once, then stop) |
| **Timeout Supervision** | Soft/idle/hard timeouts with recovery steering |
| **Verification Enforcement** | Configurable shell commands (npm lint, npm test, etc.) auto-fix retries |
| **Adaptive Replanning** | Roadmap reassessed after each slice (add/remove/reorder as needed) |
| **Real-Time Dashboard** | Ctrl+Alt+G overlay shows progress, phase, costs |
| **HTML Reports** | Auto-generated reports after milestone (printable to PDF) |
| **Parallel Orchestration** | Multi-worker parallel milestone execution |
| **20+ LLM Providers** | Anthropic, OpenAI, Google, OpenRouter, Groq, Ollama, etc. |
| **MCP Integration** | Native Model Context Protocol server support |
| **Remote Questions** | Route human decisions to Slack/Discord in headless mode |

#### Directory Structure (`.gsd/`)
```
.gsd/
├── PREFERENCES.md              # Global workflow settings
├── gsd.db                       # SQLite authoritative state (milestones, slices, tasks)
├── STATE.md                     # Rendered dashboard (derived from database)
├── PROJECT.md, REQUIREMENTS.md  # Same as v1
├── M001-ROADMAP.md             # Milestone plan with risk levels, dependencies
├── M001-CONTEXT.md             # User decisions from discuss phase
├── M001-RESEARCH.md            # Codebase and ecosystem research
├── S01-PLAN.md                 # Slice decomposition (1-7 tasks)
├── T01-PLAN.md                 # Individual task plan
├── T01-SUMMARY.md              # What happened (YAML frontmatter + narrative)
├── auto.lock                   # Crash detection sentinel (PID + timestamp)
├── completed-units.json        # Prevents re-running completed work
├── metrics.json                # Per-developer token/cost accumulator
├── activity/                   # JSONL session dumps (auto-pruned)
├── runtime/                    # Unit execution records (dispatch phase, timeouts)
├── worktrees/                  # Git worktree working copies
├── parallel/                   # Multi-worker IPC and status
├── journal/                    # Daily-rotated event journal (structured logs)
├── reports/                    # Generated HTML milestone reports
└── STATE.md                    # Quick-glance dashboard
```

#### Commands (40+)

**Main Loop:**
- `/gsd` — Step mode (pause between units)
- `/gsd auto` — Autonomous mode (walk away, come back when done)
- `/gsd next` — Explicit step mode
- `/gsd new-project [--deep]` — Bootstrap with staged discovery
- `/gsd quick` — Execute ad-hoc task with GSD guarantees

**Steering (works during auto mode in separate terminal):**
- `/gsd discuss` — Talk through architecture
- `/gsd status` — Progress dashboard
- `/gsd queue` — Queue future milestones

**Diagnostics & Forensics:**
- `/gsd forensics` — Full debugger for auto-mode failures
- `/gsd doctor` — Runtime health checks
- `/gsd logs` — Browse activity and metrics
- `/gsd export --html` — Generate milestone report

**Configuration:**
- `/gsd prefs` — Model selection, timeouts, budget
- `/gsd config` — Re-run setup wizard
- `gsd update` — Update to latest version
- `gsd headless [cmd]` — Run commands without TUI (CI/cron)

#### Configuration Example
```yaml
---
version: 1
models:
  research: claude-sonnet-4-6
  planning:
    model: claude-opus-4-7
    fallbacks:
      - openrouter/z-ai/glm-5
      - openrouter/minimax/minimax-m2.5
  execution: claude-sonnet-4-6
  completion: claude-sonnet-4-6
skill_discovery: suggest
auto_supervisor:
  soft_timeout_minutes: 20
  idle_timeout_minutes: 10
  hard_timeout_minutes: 30
budget_ceiling: 50.00
unique_milestone_ids: true
verification_commands:
  - npm run lint
  - npm run test
auto_report: true
git:
  isolation: worktree           # none, worktree, or branch
  manage_gitignore: true
  milestone_resquash: true
verification_auto_fix: true
verification_max_retries: 2
---
```

#### When to Use GSD-2
✅ **Autonomous overnight builds** — Queue work, walk away
✅ **CI/CD integration** — `gsd headless auto --timeout 600000` in pipeline
✅ **Cost-sensitive work** — Budget ceilings + complexity-based routing
✅ **Enterprise teams** — Parallel milestones, unique IDs, cross-developer isolation
✅ **Unattended execution** — Crash recovery + auto-restart with exponential backoff

---

## Hybrid Integration Strategy

### Layered Architecture

```
Layer 1: SPECIFICATION (Spec-Kit)
────────────────────────────────
  Input:  Business requirements, constraints, compliance rules
  Output: constitution.md, specifications.md, quality-gates.md

  → Feeds into GSD-v1 context

Layer 2: PLANNING (GSD-v1)
──────────────────────────
  Input:  Spec-Kit outputs + project vision
  Output: .planning/ directory structure, roadmap, phase plans

  → Feeds into GSD-2 state machine

Layer 3: EXECUTION (GSD-2)
──────────────────────────
  Input:  GSD-v1 plans + verification criteria
  Output: Built software, verified commits, cost reports

  → Closes loop back to Spec-Kit verification gates
```

### Recommended Workflow

#### Phase 1: Define (Spec-Kit)
**Duration:** 1-2 days
**Participants:** Product, Architecture, Compliance
**Deliverables:**
```
project-root/
├── specs/
│   ├── constitution.md         # Project values, standards, compliance
│   ├── architecture.md         # System design, data models, APIs
│   ├── features.gherkin        # Acceptance criteria (BDD format)
│   └── openapi.yaml            # API contract
├── docs/
│   └── IMPROVEMENTS_SUMMARY.md # What's changing and why
└── AGENTS.md                   # Coding standards (auto-loaded by GSD-v1)
```

**Spec-Kit Gates:**
- Architecture decision approval
- Compliance pre-flight check
- Security threat model validation

#### Phase 2: Plan (GSD-v1)
**Duration:** 3-5 days
**Participants:** Dev lead, Agent orchestration
**Entrypoint:**
```bash
# Initialize GSD with Spec-Kit context
/gsd-new-project \
  --constitution specs/constitution.md \
  --spec specs/openapi.yaml \
  --requirements specs/features.gherkin
```

**Output:** `.planning/` structure with:
- Requirements.md traced to Spec-Kit features
- Roadmap phases with risk levels
- Atomic task plans with verification criteria

#### Phase 3: Execute (GSD-2)
**Duration:** Variable (overnight or streaming)
**Entrypoint:**
```bash
# Terminal 1: Autonomous build
gsd headless auto --timeout 600000

# Terminal 2 (optional): Steer during execution
gsd discuss
gsd status
gsd queue M002
```

**Monitoring:**
- Real-time dashboard: `Ctrl+Alt+G`
- Cost tracking: `gsd status` shows per-unit costs
- Budget ceiling: Auto-pauses if USD ceiling reached

#### Phase 4: Verify (Spec-Kit Gates)
**Duration:** 1 day
**Participants:** QA, Product, Compliance
**Process:**
1. GSD-2 generates HTML report (`.gsd/reports/M001.html`)
2. Verify must-haves met (from Spec-Kit specs)
3. Run compliance audit (from Spec-Kit constitution)
4. Close quality gates

---

## Integration Points

### 1. Spec-Kit → GSD-v1
**Map specifications to planning decisions:**
```
specs/openapi.yaml
  ↓
.planning/REQUIREMENTS.md (with traceability)
  ↓
.planning/phase-001-{domain}/PLAN.md (verification criteria from spec)
```

**Implementation:**
```bash
# In GSD-v1 planning context
/gsd-discuss-phase 1
# Questions reference Spec-Kit constitution values
# → User preferences captured in CONTEXT.md
```

### 2. GSD-v1 → GSD-2
**Migrate .planning/ structure (v1 format) → GSD-2 format (.gsd/)**
```bash
# GSD-2 auto-detects and migrates
gsd headless next

# Or explicit migration
/gsd migrate ~/my-project
```

**State Transfer:**
- `.planning/ROADMAP.md` → `.gsd/M001-ROADMAP.md`
- `.planning/phase-N-PLAN.md` → `.gsd/S01-PLAN.md` (slice-based)
- Completion state preserved (`[x]` phases stay done)

### 3. GSD-2 → Spec-Kit Verification
**After GSD-2 execution, verify against Spec-Kit quality gates:**
```bash
# Generate GSD-2 HTML report
gsd export --html

# Run Spec-Kit gates against artifacts
spec-kit verify \
  --constitution specs/constitution.md \
  --artifacts .gsd/reports/M001.html \
  --tests npm test
```

---

## Implementation Roadmap

### Milestone 1: Foundation (This Sprint)
- [x] Define Spec-Kit constitution (values, standards, compliance)
- [x] Create Spec-Kit specifications (openapi.yaml, features.gherkin)
- [ ] Document integration patterns
- [ ] Set up AGENTS.md (shared across all tools)

### Milestone 2: Planning Integration
- [ ] Bootstrap GSD-v1 with Spec-Kit context
- [ ] Create .planning/ structure with traceability
- [ ] Define phase decomposition strategy
- [ ] Set up atomic task templates

### Milestone 3: Execution Automation
- [ ] Integrate GSD-2 with .planning/ artifacts
- [ ] Configure verification commands (npm lint, npm test)
- [ ] Set up budget ceiling and model per-phase routing
- [ ] Enable parallel milestone orchestration

### Milestone 4: Verification & Reporting
- [ ] Implement Spec-Kit quality gates
- [ ] Auto-generate compliance reports (post-GSD-2)
- [ ] Set up cost dashboards
- [ ] Document lessons learned

---

## Team Collaboration Patterns

### Pattern 1: Single Developer (High Autonomy)
```
Spec-Kit (5 min)  → GSD-v1 (queue)  → GSD-2 (auto mode, overnight)
  Define              Plan              Execute
  (interactive)       (discuss)         (unattended)
```

### Pattern 2: Distributed Team (Async-First)
```
Terminal 1 (Dev A):  GSD-2 auto mode running (M001)
Terminal 2 (Dev B):  /gsd discuss (steering M002 planning)
Terminal 3 (Dev C):  /gsd queue M003 (pre-planning next milestone)

.planning/ artifacts tracked in git
→ All terminals read/write same state
```

### Pattern 3: Enterprise (Compliance-Heavy)
```
Phase 1: Spec-Kit  → Approval gate (security, legal, architecture)
Phase 2: GSD-v1    → Planning review gate (design, estimates)
Phase 3: GSD-2     → Execution gate (cost budget, compliance audit)
Phase 4: Verify    → UAT gate, release gate, post-mortem gate
```

---

## Best Practices

### 1. Constitution First
Never skip Spec-Kit constitution. It cascades to every decision.
```yaml
# Good: Explicit values guide architecture decisions
values:
  - "Privacy-first: User data encrypted at rest and in transit"
  - "Performance: p99 latency < 200ms, 99.95% uptime"

standards:
  - "TypeScript strict mode mandatory for all code"
  - "80% line + branch coverage required"

compliance:
  - "OWASP Top 10 annual audit"
```

### 2. Atomic Phase Sizing
GSD-v1 phases should be 2-5 tasks max (not 1 task, not 10).
```
Too small:   Phase 1: Auth (1 task) — waste of ceremony
Too large:   Phase 1: Complete backend (15 tasks) — context rot
Just right:  Phase 1: Auth core (2-3 tasks) + Phase 2: Auth integrations (2-3 tasks)
```

### 3. Task-to-Context Mapping
Each GSD-2 task should pre-load exactly its needed files.
```
Task: "Create JWT middleware"
  Files: src/middleware/auth.ts, src/utils/jwt.ts, tests/auth.test.ts
  Pre-loaded: PROJECT.md, S01-PLAN.md, T01-PLAN.md (+ no clutter)
```

### 4. Verification First
Define must-haves *before* execution, not after.
```xml
<!-- Define in GSD-v1 PLAN.md -->
<must_haves>
  <artifact>src/middleware/auth.ts exists and exports</artifact>
  <truth>curl with valid token returns 200 + user object</truth>
  <truth>curl with invalid token returns 401</truth>
</must_haves>

<!-- GSD-2 auto-verifies and retries if fails -->
```

### 5. Cost Transparency
Set budget ceiling before auto mode, track per-unit costs.
```yaml
budget_ceiling: 50.00           # USD
auto_supervisor:
  soft_timeout_minutes: 20      # Warn agent to wrap up
  idle_timeout_minutes: 10      # Detect stalls
  hard_timeout_minutes: 30      # Force pause
```

### 6. Team Unique IDs
Use unique milestone IDs if working in teams (prevents collisions).
```yaml
unique_milestone_ids: true      # M001-abc123 instead of M001
```

---

## Command Cheat Sheet

### Spec-Kit (Definition)
```bash
# Write specifications
spec-kit new-project                # Interactive constitution builder
spec-kit spec openapi.yaml         # Validate OpenAPI against constitution
spec-kit gate verify-prerequisites  # Pre-flight compliance check
```

### GSD-v1 (Planning)
```bash
# Initialize with Spec-Kit context
/gsd-new-project --constitution specs/constitution.md

# Plan phase with Spec-Kit verification
/gsd-plan-phase 1 --spec specs/features.gherkin

# Verify Spec-Kit quality gates
/gsd-verify-work 1
```

### GSD-2 (Execution)
```bash
# Autonomous execution
gsd /gsd auto

# Steer from another terminal
gsd /gsd discuss         # Talk through decisions
gsd /gsd status          # Check progress + costs
gsd /gsd queue M002      # Queue next milestone

# CI/CD integration
gsd headless auto --timeout 600000
gsd headless query       # Get JSON state snapshot

# Reporting
gsd /gsd export --html   # Generate HTML report
gsd /gsd forensics       # Debug auto-mode failures
```

---

## Troubleshooting

### Q: Plans don't match Spec-Kit expectations
**A:** Check GSD-v1 CONTEXT.md during plan phase — it should reference Spec-Kit decisions. If missing, re-run:
```bash
/gsd-discuss-phase 1 --spec specs/openapi.yaml
```

### Q: GSD-2 execution diverges from planned tasks
**A:** Verify task must-haves are clear. Re-run:
```bash
gsd /gsd steer
# Edit S01-PLAN.md, refresh, continue
gsd /gsd auto
```

### Q: Budget exceeded mid-execution
**A:** GSD-2 pauses at ceiling. Review:
```bash
gsd /gsd status              # See per-unit costs
gsd /gsd prefs               # Adjust budget_ceiling or model tier
gsd /gsd auto                # Resume
```

### Q: Compliance audit fails after GSD-2
**A:** Check if Spec-Kit constitution was loaded in GSD-v1 planning. Verify post-execution:
```bash
spec-kit gate verify-artifacts --constitution specs/constitution.md
```

---

## References

- **Spec-Kit:** [github/spec-kit](https://github.com/github/spec-kit)
- **GSD-v1:** [gsd-build/get-shit-done](https://github.com/gsd-build/get-shit-done) (v1.39.1)
- **GSD-2:** [gsd-build/gsd-2](https://github.com/gsd-build/gsd-2) (v2.78+)

---

**Created:** May 1, 2026
**Status:** Production Ready
**Maintained by:** hdd-gsd2-hybrid-framework contributors
