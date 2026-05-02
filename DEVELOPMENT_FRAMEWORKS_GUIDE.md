# Development Frameworks: Spec Kit vs GSD-T Comparison

> A comprehensive research guide comparing Spec-Driven Development (Spec Kit) and Contract-Driven Development (GSD-T) frameworks for agentic software development.

---

## Executive Summary

| Framework | Creator | Focus | Best For | Official Repo |
|-----------|---------|-------|----------|---------------|
| **Spec Kit** | GitHub | Specification-first development | Requirements clarity, compliance, single developers | [github/spec-kit](https://github.com/github/spec-kit) |
| **GSD-T** | Tekyz Inc | Contract-driven, team coordination | Multi-agent teams, parallel execution, observability | [Tekyz-Inc/get-stuff-done-teams](https://github.com/Tekyz-Inc/get-stuff-done-teams) |

---

## 1. Spec Kit: Specification-Driven Development (SDD)

### 1.1 What is Spec-Driven Development?

**Core Concept: The Power Inversion**

For decades, **code was king**. Specifications were scaffolding we built and discarded. SDD inverts this:

```
Traditional: Requirements → Design Docs → Code (specs are secondary)
SDD:         Specifications → Code (specs are executable, primary)
```

The PRD isn't just a guide—it's the **source that generates implementation**. Technical plans aren't documents that inform coding; they're **precise definitions that produce code**.

### 1.2 Core Principles

1. **Specifications as the lingua franca** — Specification becomes primary artifact; code is its expression
2. **Intent-driven development** — Specifications define "what" and "why" before "how"
3. **Multi-step refinement** — Not one-shot code generation; structured phases with guardrails
4. **Rich specification creation** — Organizational principles guide spec quality
5. **Code is specification expression** — Maintaining software means evolving specifications
6. **Maintain engineering velocity through change** — When specs drive implementation, pivots become systematic regenerations

### 1.3 Six-Step Workflow

```
┌─ Constitution (project principles)
├─ Specify (requirements & user stories)
├─ Plan (tech stack & architecture)
├─ Tasks (atomic, actionable breakdown)
├─ Implement (execute all tasks)
└─ Verify (quality gates & validation)
```

#### Phase Details

| Phase | Command | Purpose | Owner |
|-------|---------|---------|-------|
| **1. Constitution** | `/speckit.constitution` | Define project principles, dev guidelines, quality standards | Developer |
| **2. Specify** | `/speckit.specify` | Describe what to build (WHAT + WHY, not tech stack) | Product + Dev |
| **3. Plan** | `/speckit.plan` | Choose tech stack, architecture decisions, constraints | Tech Lead |
| **4. Tasks** | `/speckit.tasks` | Break plan into atomic, context-window-sized tasks | Dev |
| **5. Implement** | `/speckit.implement` | Execute all tasks; AI generates working code | AI Agent |
| **6. Verify** | `/speckit.verify` | Validate implementation against spec | QA + Dev |

#### Optional Quality Gates (new in v0.8.4+)

- `/speckit.clarify` — Resolve underspecified areas (recommended before `/speckit.plan`)
- `/speckit.analyze` — Cross-artifact consistency check (run after `/speckit.tasks`)
- `/speckit.checklist` — Custom quality checklists (like "unit tests for English")

### 1.4 Supported AI Agents (30+)

- GitHub Copilot
- Claude Code
- Cursor
- Windsurf
- OpenAI Codex
- Qwen Code
- And 24+ others

See [Supported AI Coding Agent Integrations](https://github.github.io/spec-kit/reference/integrations.html) for full list and usage notes.

### 1.5 Implementation Pattern (Step-by-Step)

```bash
# 1. Install Specify CLI
uv tool install specify-cli --from git+https://github.com/github/spec-kit.git@vX.Y.Z
# Or with pipx:
pipx install git+https://github.com/github/spec-kit.git@vX.Y.Z

# 2. Initialize project
specify init my-project
cd my-project

# 3. Launch your coding agent
# (GitHub Copilot, Claude Code, Cursor, etc.)
# This workspace now has /speckit.* commands

# 4. Define project principles
/speckit.constitution
# Create principles focused on:
# - Code quality standards
# - Testing approach (TDD, coverage thresholds)
# - UX consistency requirements
# - Performance standards

# 5. Specify what you're building
/speckit.specify
# Focus on WHAT + WHY, not tech:
# "Build a photo album organizer where:
# - Users organize photos into albums by date
# - Albums can be reorganized via drag-drop
# - Photos shown in tile-like preview interface
# - Albums are never nested"

# 6. Define technical approach
/speckit.plan
# Include tech stack + architecture:
# "Use Vite + vanilla JS/CSS
# - No extra frameworks
# - SQLite for local metadata storage
# - Images never uploaded
# - Responsive design for mobile/desktop"

# 7. Generate actionable tasks
/speckit.tasks

# 8. (Optional) Clarify underspecified areas
/speckit.clarify

# 9. (Optional) Check cross-artifact consistency
/speckit.analyze

# 10. Build it!
/speckit.implement

# 11. (Optional) Custom quality validation
/speckit.checklist
```

### 1.6 Customization: Extensions & Presets

#### Extensions (Add New Capabilities)

Extensions introduce **new commands and workflows** beyond core SDD:

**Common Community Extensions:**

| Extension | Purpose | Type |
|-----------|---------|------|
| `spec-kit-jira` | Sync specs to Jira Stories + Issues | Integration |
| `spec-kit-bugfix` | Structured bugfix workflow | Process |
| `spec-kit-review` | Post-impl code review (security, tests, quality) | Code |
| `spec-kit-cleanup` | Post-impl quality gate (fix small issues, report larger) | Code |
| `spec-kit-security-review` | Full security audit + staged reviews | Code |
| `spec-kit-v-model` | Enforces V-Model (dev specs ↔ test specs) | Docs |
| `spec-kit-maqa` | Multi-agent orchestration with QA + Red Team | Process |
| `spec-kit-canon` | Canon-driven (baseline-driven) workflows | Process |
| `spec-kit-fleet` | Full feature lifecycle with human-in-the-loop gates | Process |

Install extensions:
```bash
# Search available extensions
specify extension search

# Install an extension
specify extension add <extension-name>
```

**Browse community extensions:** https://speckit-community.github.io/extensions/ (100+ available)

#### Presets (Customize Existing Workflows)

Presets **customize how Spec Kit works** without adding new capabilities—they override templates and commands:

**When to Use Presets:**

- Enforce compliance-oriented spec format
- Use domain-specific terminology
- Apply organizational standards to plans & tasks
- Localize workflow to different language
- Customize naming conventions

Install presets:
```bash
# Search available presets
specify preset search

# Install a preset
specify preset add <preset-name>
```

**Preset Resolution Order (top-down):**
```
1. Project-Local Overrides (.specify/templates/overrides/)
2. Installed Presets (.specify/presets/templates/)
3. Installed Extensions (.specify/extensions/templates/)
4. Spec Kit Core Defaults (.specify/templates/)
```

**Example Presets:**
- `pirate-speak-demo` — Entire workflow in pirate speak
- Regulatory compliance presets
- Domain-specific templates (enterprise, healthcare, finance)

### 1.7 Best Practices & Patterns

#### ✅ Do This

- **Specs before code** — Invest time in constitution + specify phases
- **Use clarify gate** — `/speckit.clarify` finds gaps before planning
- **Iterate on artifacts** — Update spec.md mid-project; changes cascade to tasks
- **Leverage extensions** — Use community extensions for domain-specific needs
- **Version your specifications** — Keep git history of spec artifacts
- **Document trade-offs** — Capture WHY decisions in plan.md

#### ❌ Avoid This

- **Skipping constitution** — Project principles guide all subsequent work
- **Vague specifications** — "Build a good app" → broken implementation
- **Ignoring drift** — When code diverges from spec, reconcile artifacts
- **Removing failing tests** — Fix them or open follow-up issues (per AGENTS.md)
- **Force-pushing main** — Maintain clean linear history

### 1.8 Real-World Workflow Example

**Scenario:** Building a photo album organizer

```markdown
# Step 1: Constitution
## Quality North Star
This is a published web app for personal use.
Every user action should complete in <500ms.
No external dependencies; run offline-first.

## Code Quality
- TypeScript strict mode
- 80% test coverage threshold
- No vague variable names (searchable, descriptive)
- Use functional patterns; avoid classes

---

# Step 2: Specify (requirements)
## User Stories
1. As a user, I want to organize photos into albums
   - Acceptance: Albums persist locally
   - Acceptance: Albums labeled by date

2. As a user, I want to reorder albums via drag-drop
   - Acceptance: Drag album tile to new position
   - Acceptance: Change reflects immediately

3. As a user, I want to preview photos in tiles
   - Acceptance: 4 columns on desktop, 2 on mobile
   - Acceptance: Click tile to enlarge photo

---

# Step 3: Plan (tech choices)
## Tech Stack
- Frontend: Vite + vanilla JS/CSS
- Storage: Local SQLite (via sql.js)
- No frameworks; <10KB gzipped
- Responsive: mobile-first CSS

## Architecture
- AlbumManager (state)
- DOMRenderer (UI)
- StorageService (persistence)

---

# Step 4: Tasks (auto-generated from plan)
- [ ] Task 1: Set up Vite project structure
- [ ] Task 2: Implement AlbumManager (create, rename, delete)
- [ ] Task 3: Implement DOMRenderer (tiles, reordering)
- [ ] Task 4: Add drag-drop event handlers
- [ ] Task 5: Integrate StorageService (SQLite)
- [ ] Task 6: Add responsive CSS (mobile/desktop)
- [ ] Task 7: Unit tests for AlbumManager
- [ ] Task 8: Integration tests (UI + storage)

---

# Step 5: Implement
/speckit.implement
# AI agent executes all 8 tasks

---

# Step 6: Verify
/speckit.verify
# Validates:
# - All tasks complete
# - Tests pass + 80% coverage
# - No drift from spec
# - Performance meets SLA
```

### 1.9 Community & Resources

- **Official GitHub:** [github/spec-kit](https://github.com/github/spec-kit) (92.1K stars, 195+ contributors)
- **Documentation:** https://github.github.io/spec-kit/
- **Deep Dive:** [spec-driven.md](https://github.com/github/spec-kit/blob/main/spec-driven.md) (complete methodology)
- **Community Extensions:** [speckit-community.github.io/extensions](https://speckit-community.github.io/extensions/)
- **Discussions:** [GitHub Discussions](https://github.com/github/spec-kit/discussions)

---

## 2. GSD-T: Contract-Driven Development for Teams

### 2.1 What is GSD-T?

**Full Name:** Get Stuff Done for Teams (Contract-Driven Development)

**Core Concept: Contracts First, Code Second**

GSD-T is a **structured methodology for reliable, parallelizable development** using Claude Code with optional agent teams. It eliminates context rot through task-level fresh dispatch and enables multi-agent collaboration via explicit contracts (domain ownership, API boundaries, schema specifications).

```
Traditional: Code → Test → Merge (agent context degrades)
GSD-T:       Contract → Task → Code (fresh dispatch per task; context always optimal)
```

### 2.2 Core Principles

1. **Contracts are source of truth** — Code implements contracts, not reverse
2. **Domains own files exclusively** — No two domains modify same file
3. **Impact before execution** — Always analyze downstream effects first
4. **Tests stay synced** — Every code change triggers test analysis
5. **State survives sessions** — Everything persisted in `.gsd-t/` (resumable)
6. **Plan = single-brain, Execute = multi-brain** — Planning always solo; execution parallelizes
7. **Every decision logged** — Decision Log captures WHY, not just WHAT
8. **Agents learn from experience** — JSONL event stream + Reflexion pattern prevents hypothesis repetition

### 2.3 Twelve-Phase Milestone Workflow

```
Prompt
   ↓
Project/Feature/Scan (Initialize)
   ↓
Milestone (Define deliverable)
   ↓
Partition (Decompose into domains)
   ↓
Discuss (Multi-perspective design)
   ↓
Plan (Create task lists)
   ↓
Impact (Analyze downstream effects)
   ↓
Execute (Build with parallelism M44+)
   ↓
Test-Sync (Maintain coverage)
   ↓
Integrate (Wire domains together)
   ↓
Verify (Quality gates)
   ↓
Complete (Archive + tag)
```

#### Phase Ownership Matrix

| Phase | Solo | Team | Purpose |
|-------|------|------|---------|
| Prompt | ✓ | - | Formulate idea |
| Project/Feature/Scan | ✓ | ✓* | Initialize |
| Milestone | ✓ | - | Define deliverable |
| Partition | ✓ | - | Decompose into domains |
| Discuss | ✓ | ✓ | Multi-perspective exploration |
| Plan | ✓ | - | Always solo (single brain) |
| Impact | ✓ | - | Analyze effects |
| Execute | ✓ | ✓ | Build with parallelism |
| Test-Sync | ✓ | - | Maintain coverage |
| Integrate | ✓ | - | Always solo (wire together) |
| Verify | ✓ | ✓ | Quality gates |
| Complete | ✓ | - | Archive + tag |

*Large scans can use teams

### 2.4 The "Partition" Phase: Domain Decomposition

The key to GSD-T's parallelism is **Partition**:

```
Milestone: "User Authentication System"
   ↓
/gsd-t-partition
   ↓
Domains (each with exclusive file ownership):
   • api-domain: /src/auth/api.ts (routes, OAuth)
   • service-domain: /src/auth/service.ts (tokens, verification)
   • schema-domain: /src/db/auth-schema.ts (migrations, tables)
   • ui-domain: /src/components/Login.tsx (form, styling)
   ↓
Contracts:
   • api-contract.md (endpoints, request/response)
   • schema-contract.md (tables, fields, constraints)
   • component-contract.md (props, events, styling)
```

**Key Rule:** If two domains need to modify `/src/auth/api.ts`, partition is wrong—redesign.

### 2.5 Parallel Execution (M44+ Release)

**Task-Level Parallelism with Gating**

```bash
# Preview parallelism plan (no spawn)
gsd-t parallel --dry-run

# Output:
# ┌────────────────────────────────────────────────┐
# │ Worker 1 (Domain: api)     | Task: implement-oauth
# │ Worker 2 (Domain: schema)  | Task: create-tables
# │ Worker 3 (Domain: ui)      | Task: build-form
# │ (sequential dependency: wait on schema before api)
# └────────────────────────────────────────────────┘
```

**Gating Strategy:**
- Pre-spawn validation (dependency graph, file-disjointness, economics)
- Mode-aware headroom (in-session: 85% ceiling; unattended: 60% ceiling with task-splitting)
- Safe merges (atomic via worktree isolation per domain)

### 2.6 Monitoring & Observability

#### Real-Time Dashboard

```bash
/gsd-t-visualize

# Launches browser dashboard at 127.0.0.1:7842
# Shows:
# - Agent hierarchy (orchestrator → domain agents → subagents)
# - Real-time task progress (% complete, duration)
# - Tool activity (Claude API calls, tokens/cost)
# - Phase progression (Partition → Discuss → Plan → Execute → ...)
```

#### Live Transcript

Every detached spawn prints:
```
▶ Live transcript: http://127.0.0.1:{port}/transcript/{id}
```

Opens browser viewer with:
- SSE-streamed stdout
- Per-tool cost breakdown (tokens, $)
- Collapsible "Tool Cost" sidebar

#### Visual Scan Reports

```bash
/gsd-t-scan

# Generates self-contained HTML with:
# - 6 live architectural diagrams (Mermaid)
# - Tech debt register (categorized, prioritized)
# - Domain health scores
# - Optional export: DOCX, PDF
```

#### Token Metrics

```bash
/gsd-t-metrics
# Shows: task telemetry, process ELO, signal distribution, domain health

/gsd-t-metrics --cross-project
# Shows: ELO rankings, global comparison across all registered projects
```

### 2.7 54 Slash Commands (49 GSD-T + 5 Utility)

#### Smart Router

| Command | Purpose |
|---------|---------|
| `/gsd {request}` | Describe what you need → auto-routes to right command |
| `(plain text)` | Auto-routed via UserPromptSubmit hook |

#### Milestone Workflow

| Command | Phase | Purpose |
|---------|-------|---------|
| `/gsd-t-milestone` | Milestone | Define new deliverable |
| `/gsd-t-partition` | Partition | Decompose into domains + contracts |
| `/gsd-t-discuss` | Discuss | Multi-perspective design exploration |
| `/gsd-t-plan` | Plan | Create atomic task lists per domain |
| `/gsd-t-impact` | Impact | Analyze downstream effects |
| `/gsd-t-execute` | Execute | Build with task-level parallelism |
| `/gsd-t-test-sync` | Test-Sync | Sync tests with code changes |
| `/gsd-t-integrate` | Integrate | Wire domains together |
| `/gsd-t-verify` | Verify | Run quality gates |
| `/gsd-t-complete-milestone` | Complete | Archive + git tag |

#### Automation & Utilities

| Command | Purpose |
|---------|---------|
| `/gsd-t-wave` | Full cycle with auto-advance through all phases |
| `/gsd-t-quick` | Fast task with full GSD-T guarantees |
| `/gsd-t-resume` | Restore context after break |
| `/gsd-t-status` | Cross-domain progress view |
| `/gsd-t-visualize` | Launch real-time browser dashboard |
| `/gsd-t-debug` | Systematic debugging with state |
| `/gsd-t-health` | Validate `.gsd-t/` structure |
| `/gsd-t-metrics` | View task telemetry + ELO rankings |

#### Design-to-Code (UI Projects)

| Command | Purpose |
|---------|---------|
| `/gsd-t-design-decompose` | Decompose Figma design into contracts |
| `/gsd-t-design-build` | Build from design (two-terminal review) |
| `/gsd-t-design-review` | Independent review agent for visual comparison |
| `/gsd-t-design-audit` | Pixel-by-pixel comparison vs. Figma |

#### Headless Mode (CI/CD)

```bash
gsd-t headless verify --json --timeout=1200     # Run verify non-interactively
gsd-t headless query status                     # Get project state (<100ms, no LLM)
gsd-t headless --debug-loop --max-iterations=10 # Automated test-fix-retest cycles
```

#### Overnight / Unattended

| Command | Purpose |
|---------|---------|
| `/gsd-t-unattended --hours=24` | Detached supervisor for unattended runs |
| `/gsd-t-unattended-watch` | Watch tick (fires every 270s) |
| `/gsd-t-unattended-stop` | Gracefully halt supervisor |

### 2.8 Project Structure

GSD-T auto-generates:

```
your-project/
├── CLAUDE.md                          # Global + project rules
├── docs/
│   ├── requirements.md
│   ├── architecture.md
│   ├── workflows.md
│   └── infrastructure.md
├── .gsd-t/                            # Master state directory
│   ├── progress.md                    # Current milestone state (resumable)
│   ├── backlog.md                     # Captured items (priority-ordered)
│   ├── roadmap.md                     # Full milestone roadmap
│   ├── techdebt.md                    # Technical debt register
│   ├── verify-report.md               # Latest verification results
│   ├── impact-report.md               # Downstream effect analysis
│   ├── test-coverage.md               # Test sync status
│   ├── contracts/                     # Domain contracts (source of truth)
│   │   ├── api-contract.md
│   │   ├── schema-contract.md
│   │   ├── component-contract.md
│   │   ├── integration-points.md
│   │   └── design-brief.md            # Auto-generated for UI projects
│   ├── domains/                       # Per-domain scope + tasks
│   │   └── {domain-name}/
│   │       ├── scope.md               # What this domain owns
│   │       ├── tasks.md               # Atomic tasks for domain
│   │       └── constraints.md         # Constraints & rules
│   ├── events/                        # Execution stream (JSONL, daily-rotated)
│   ├── retrospectives/                # Post-milestone analysis reports
│   ├── milestones/                    # Archived completed milestones
│   │   └── {milestone-name}-{date}/
│   ├── scan/                          # Codebase analysis outputs
│   └── .unattended/                   # Overnight supervisor state files
└── src/
```

### 2.9 Implementation Pattern (Step-by-Step)

```bash
# 1. Install globally (one-time)
npx @tekyzinc/gsd-t install

# Verify installation
npx @tekyzinc/gsd-t status
npx @tekyzinc/gsd-t doctor

# 2. Initialize project (auto-registers)
cd my-project
/gsd-t-init-scan-setup
# This runs: git + init + scan + setup in one go

# Or step-by-step:
# /gsd-t-scan                    # Analyze existing codebase
# /gsd-t-setup                   # Generate project CLAUDE.md

# 3. Define what you're building
/gsd-t-milestone "User Authentication System"

# 4. Option A: Auto-advance through all phases
/gsd-t-wave
# Automatically runs: partition → discuss → plan → impact → execute → test-sync → integrate → verify

# 4. Option B: Phase-by-phase for more control
/gsd-t-partition               # Decompose into domains
/gsd-t-discuss                 # Multi-perspective design
/gsd-t-plan                    # Create task lists
/gsd-t-impact                  # Analyze downstream effects
/gsd-t-execute                 # Build
/gsd-t-test-sync               # Maintain test coverage
/gsd-t-integrate               # Wire domains together
/gsd-t-verify                  # Quality gates
/gsd-t-complete-milestone      # Archive + tag

# 5. Advanced monitoring
/gsd-t-visualize               # Real-time dashboard
/gsd-t-metrics --cross-project # ELO rankings

# 6. Resume after break
/gsd-t-resume                  # Restores context automatically

# 7. Parallelism (M44+)
gsd-t parallel --dry-run       # Preview parallelism plan
gsd-t parallel                 # Execute with parallelism
```

### 2.10 Self-Learning Rules Engine

**5-Stage Rule Lifecycle:**

```
1. Candidate   → Pattern detected from task metrics
2. Applied     → Rule tested on next task
3. Measured    → Results analyzed (improvement %)
4. Promoted    → >55% improvement threshold → promoted to standard
5. Graduated   → Rules validated in 3+ projects → become universal
```

**Example:**
```
Pattern detected: "When task involves React component + Tailwind,
always start with accessibility audit to catch WCAG violations early"

Status: Applied (testing on next React task)
Improvement: +37% fewer accessibility issues
Gate: >55% threshold? → 37% < 55% → stay as "Applied", retry with refinement
```

**Cross-Project Sync:**

```bash
# Rules validated in 3+ projects
# become universal and sync across all registered projects:
gsd-t update-all

# Rules validated in 5+ projects
# qualify for npm distribution (auto-included in next @tekyzinc/gsd-t release)
```

### 2.11 Stack Rules Engine

GSD-T auto-detects tech stack and injects mandatory best-practice rules:

**Supported Stacks:**
- React + TypeScript
- Vue + TypeScript
- Node.js API
- Python backends
- Go microservices
- Rust systems

**How It Works:**

```javascript
// 1. Auto-detect from manifest files
// (package.json, go.mod, Cargo.toml, requirements.txt, etc.)

// 2. At execute-time, inject stack-specific rules into subagent prompts:
// Universal security rules (always applied)
// + Stack-specific rules (React, TypeScript, Node, etc.)

// 3. Example: React + TypeScript + Tailwind
// Rules injected:
// - Use functional components, no class components
// - Prop drilling max 2 levels; use Context beyond
// - Tailwind: mobile-first responsive classes
// - TypeScript: strict mode, no implicit any
// - Tests: React Testing Library (not Enzyme)
```

**Extend with custom stacks:**
```bash
# Add new stack by dropping .md file:
templates/stacks/your-stack.md
```

### 2.12 Design-to-Code with Figma Integration

**Pixel-Perfect Frontend Implementation**

GSD-T can extract design tokens from Figma and ensure pixel-perfect code-to-design match:

```bash
# Prerequisites: Figma MCP registered in Claude Code settings

# 1. Decompose design into contracts
/gsd-t-design-decompose

# 2. Build from contracts (two-terminal review)
# Terminal 1: Builder implements code
# Terminal 2: Reviewer verifies pixel-perfect match
/gsd-t-design-build

# 3. After QA, verify against original design
/gsd-t-design-audit
# Output: 30+ row comparison table
# Columns: Design Value | Implementation Value | MATCH / DEVIATION
```

### 2.13 Best Practices & Anti-Patterns

#### ✅ Do This

- **Partition early** — Spend time on domain decomposition
- **Define contracts explicitly** — api-contract.md, schema-contract.md, component-contract.md
- **Check impact before executing** — `/gsd-t-impact` analysis prevents surprises
- **Use parallelism** — `gsd-t parallel --dry-run` to preview worker plan
- **Monitor real-time** — `/gsd-t-visualize` dashboard during execution
- **Keep metrics** — `gsd-t metrics` tracks domain health + ELO rankings
- **Resume after breaks** — `/gsd-t-resume` auto-restores context
- **Tag milestones** — `/gsd-t-complete-milestone` archives + git tags

#### ❌ Avoid This

- **Lazy partitioning** — Two domains modifying same file = data corruption risk
- **Skipping impact analysis** — Changes cascade unexpectedly
- **Large monolithic tasks** — Split to fit one context window (auto-split in M44+)
- **Manual state tracking** — Always use `.gsd-t/progress.md`; never commit progress outside structure
- **Daytime unattended runs** — Use `/gsd-t-unattended` only for overnight; daytime in-session is 1.4× faster
- **Ignoring test-sync** — Tests drift from code → late failures

### 2.14 Real-World Workflow Example

**Scenario:** Building user authentication system

```markdown
# Step 1: Define Milestone
/gsd-t-milestone "User Authentication System"

---

# Step 2: Partition into Domains
/gsd-t-partition

## Domains (exclusive file ownership):

### Domain 1: OAuth API Layer
**Files:** `/src/auth/oauth.ts`, `/src/routes/auth.ts`
**Purpose:** Implement OAuth 2.0 endpoints (login, token refresh, logout)
**Tasks:**
- Set up Express route handlers
- Integrate with OAuth provider (Google, GitHub)
- Validate tokens + issue JWTs

### Domain 2: Database Schema
**Files:** `/src/db/schema.ts`, `/migrations/`
**Purpose:** Define user table, session table, indexes
**Tasks:**
- Create users table (id, email, provider, createdAt)
- Create sessions table (userId, token, expiresAt)
- Add unique constraints + indexes

### Domain 3: Auth Service
**Files:** `/src/services/authService.ts`
**Purpose:** Business logic (token verification, user lookup, session management)
**Tasks:**
- Implement token validation
- Implement user lookup by ID
- Implement session cleanup (expired tokens)

### Domain 4: Login UI
**Files:** `/src/components/Login.tsx`, `/styles/auth.css`
**Purpose:** Frontend login form + OAuth button
**Tasks:**
- Build login form (email, password fields)
- Add OAuth provider button
- Handle redirect + session storage

---

# Step 3: Contracts (Source of Truth)

## api-contract.md
```
GET /auth/login → Redirect to OAuth provider
POST /auth/callback → Exchange code for JWT, redirect to dashboard
POST /auth/logout → Invalidate session
```

## schema-contract.md
```
users:
  id (UUID primary)
  email (unique, string)
  provider (string: google|github)
  createdAt (timestamp)

sessions:
  userId (FK → users.id)
  token (JWT, unique)
  expiresAt (timestamp)
```

## component-contract.md
```
<Login />
Props: {onSuccess: (token) => void}
Events: emits onSuccess when login completes
State: loading, error (error message string)
```

---

# Step 4: Execute (Parallel)
/gsd-t-execute

# GSD-T auto-spawns 4 domain agents:
# Domain 1 (OAuth API) → implements endpoints
# Domain 2 (Schema) → creates migrations
# Domain 3 (Auth Service) → implements logic
# Domain 4 (Login UI) → builds form + OAuth button

# Each agent:
# - Gets fresh context window
# - Reads only their domain's contract + tasks
# - Implements independently
# - No cross-domain file collisions

---

# Step 5: Test & Sync
/gsd-t-test-sync

# Automatically:
# - Generates test scaffolds from contracts
# - Maps coverage (100% of Login component, 95% of authService)
# - Reports untested requirements

---

# Step 6: Integrate
/gsd-t-integrate

# Wires domains together:
# - Login UI calls authService.login()
# - authService validates token against schema
# - OAuth API endpoints persist to database

---

# Step 7: Verify
/gsd-t-verify

# Runs quality gates:
# - E2E: User can login with Google → JWT issued → redirects to dashboard
# - Schema: User + session tables created, indexes present
# - Performance: Login redirects in <500ms
# - Security: No plaintext passwords, CSRF tokens, rate limiting

---

# Step 8: Complete
/gsd-t-complete-milestone

# - Archives .gsd-t/milestones/user-auth-2026-05-01/
# - Git tags: release/v1.0.0-auth
# - Generates retrospective report
```

### 2.15 Community & Resources

- **Official GitHub:** [Tekyz-Inc/get-stuff-done-teams](https://github.com/Tekyz-Inc/get-stuff-done-teams)
- **NPM Package:** [@tekyzinc/gsd-t](https://www.npmjs.com/package/@tekyzinc/gsd-t)
- **Installation:** `npx @tekyzinc/gsd-t install`
- **License:** MIT
- **Latest Version:** v3.18.17+ (with M44 parallelism, headless, event streams)

---

## 3. Comparison Matrix

| Aspect | Spec Kit | GSD-T |
|--------|----------|-------|
| **Creator** | GitHub | Tekyz Inc |
| **Focus** | Requirements clarity | Team coordination + execution |
| **Best For** | Single developers, compliance | Multi-agent teams, parallelism |
| **Primary Workflow** | Constitution → Specify → Plan → Tasks → Implement | Partition → Discuss → Plan → Execute → Verify |
| **AI Agents** | 30+ (Copilot, Claude, Cursor, etc.) | Claude Code + optional teams |
| **Parallelism** | Sequential by phase | Task-level (M44+) with gating |
| **State Management** | `.specify/` (optional structure) | `.gsd-t/` (detailed contracts, progress, events) |
| **Customization** | Extensions + Presets | Stack Rules Engine + learning rules |
| **Resumability** | No explicit resume mechanism | `/gsd-t-resume` (restore exact context) |
| **Monitoring** | Quality gates (verify phase) | Real-time dashboard + metrics |
| **Testing** | Quality checklists | Test-sync phase + QA agents |
| **Domains** | Not explicit | Explicit with exclusive file ownership |
| **Contracts** | Implicit (in spec artifacts) | Explicit (api-contract, schema-contract, etc.) |
| **Learning** | No explicit learning mechanism | Rules Engine (Reflexion + ELO rankings) |
| **Cost** | No external dependencies | Optional: Anthropic API for token metering |

---

## 4. Choosing Your Framework

### Choose Spec Kit If:

✅ **Solo developer** or small co-located team
✅ **Strong emphasis on requirements clarity**
✅ **Need compliance-oriented templates**
✅ **Prefer linear, phased workflow**
✅ **Want to start simple** (constitution → specify → plan → build)
✅ **Need support for 30+ different AI agents**

**Example:** Product manager + engineer building a small SaaS app

---

### Choose GSD-T If:

✅ **Multi-agent teams** (Claude Code with orchestration)
✅ **Parallel execution is critical** (M44+ task-level parallelism)
✅ **Need real-time observability** (dashboard, metrics, event streams)
✅ **Want domain isolation & exclusive ownership**
✅ **Need contract-driven handoffs** (API contracts, schema contracts)
✅ **Want self-learning rules engine** (cross-project pattern detection)

**Example:** Engineering team building large system with 4+ specialized agents

---

### Hybrid Approach (Spec Kit + GSD-T):

✅ **Large organization with mixed team sizes**
✅ **Some projects need requirements clarity** (Spec Kit constitution phase)
✅ **Other projects need parallel execution** (GSD-T multi-agent orchestration)
✅ **Centralized rules/policies** (layer Spec Kit presets into GSD-T)
✅ **Cross-project learning** (GSD-T rules graduate → become Spec Kit presets)

**Architecture:**
```
Spec Kit Layer (Requirements & Governance)
   ↓
GSD-T Layer (Execution & Coordination)
   ↓
Domain Agents (Specialized roles)
```

**Example:** Fortune 500 tech company with 50+ teams, each building different products

---

## 5. Getting Started

### Spec Kit Quick Start

```bash
# 1. Install
uv tool install specify-cli --from git+https://github.com/github/spec-kit.git@vX.Y.Z

# 2. Initialize
specify init my-project

# 3. Define + Build
/speckit.constitution
/speckit.specify
/speckit.plan
/speckit.tasks
/speckit.implement
```

**Time to first feature:** ~2-4 hours (including planning)

### GSD-T Quick Start

```bash
# 1. Install
npx @tekyzinc/gsd-t install

# 2. Initialize
/gsd-t-init-scan-setup

# 3. Define milestone
/gsd-t-milestone "First Feature"

# 4. Build (auto-advances all phases)
/gsd-t-wave
```

**Time to first feature:** ~1-2 hours (if partition is well-designed)

---

## 6. References & Learning Resources

### Spec Kit Official Resources

- **GitHub Repository:** https://github.com/github/spec-kit
- **Official Documentation:** https://github.github.io/spec-kit/
- **Spec-Driven Development Essay:** [spec-driven.md](https://github.com/github/spec-kit/blob/main/spec-driven.md)
- **Community Extensions:** https://speckit-community.github.io/extensions/ (100+ extensions)
- **Community Presets:** https://github.github.io/spec-kit/community/presets.html
- **Video Overview:** [YouTube: Spec Kit in Action](https://www.youtube.com/watch?v=a9eR1xsfvHg)

### GSD-T Official Resources

- **GitHub Repository:** https://github.com/Tekyz-Inc/get-stuff-done-teams
- **NPM Package:** https://www.npmjs.com/package/@tekyzinc/gsd-t
- **Command Reference:** Run `/gsd-t-help` in Claude Code
- **README:** [GSD-T-README.md](https://github.com/Tekyz-Inc/get-stuff-done-teams/blob/main/README.md)

---

## 7. Your Project: "HDD-GSD2-Hybrid-Framework"

Your project name suggests a **hybrid approach combining both frameworks**:

- **HDD** = Hybrid Domain-Driven (development)
- **GSD2** = Get Stuff Done v2 (with Spec Kit integration)

This positions your project to:

1. **Start with Spec Kit** — Define clear requirements + constitution
2. **Decompose via GSD-T** — Partition into exclusive-ownership domains
3. **Execute in parallel** — Use GSD-T task-level parallelism
4. **Monitor + learn** — GSD-T rules engine, cross-project ELO rankings
5. **Scale gracefully** — Add teams without rewriting workflows

**Recommended Workflow:**
```
Spec Kit: /speckit.constitution
         /speckit.specify
         /speckit.plan
            ↓
GSD-T:   /gsd-t-partition (decompose into domains)
         /gsd-t-plan (per-domain tasks)
         gsd-t parallel (execute)
         /gsd-t-verify
```

---

## Appendix: Additional Resources

### Research Paper

- **Gloaguen et al. (2026):** "Evaluating AGENTS.md: Are Repository-Level Context Files Helpful for Coding Agents?" *arXiv:2602.11988v1*
  - Found: Minimal, developer-written context improves success by 4% while increasing cost by 19%
  - Recommendation: Include only essential requirements (not overviews or generic patterns)

### Related Frameworks & Patterns

- **Diátaxis Documentation Framework** — Used by Spec Kit for docs authoring
- **V-Model Development** — Spec Kit extension for paired dev/test specs
- **Domain-Driven Design (DDD)** — Foundational to GSD-T domain decomposition
- **Test-Driven Development (TDD)** — GSD-T integrates test-sync into workflow
- **Agile Methodology** — Both frameworks support iterative, human-in-the-loop execution

---

**Document Version:** 1.0
**Last Updated:** May 2026
**Status:** Research Complete
