# GSD v1 to v2 Evolution: Comprehensive Guide

> A complete technical guide comparing Get Shit Done (GSD) v1—the original prompt-based framework—with v2, the hybrid agentic engineering scaffold. This guide documents the original system, its evolution, and why v2 was needed.

---

## Table of Contents

1. [Executive Summary](#executive-summary)
2. [What is GSD v1: The Original Framework](#what-is-gsd-v1-the-original-framework)
3. [Architecture & Core Concepts](#architecture--core-concepts)
4. [Original Workflow Phases](#original-workflow-phases)
5. [File Structure (v1)](#file-structure-v1)
6. [Commands Available (v1)](#commands-available-v1)
7. [Key Principles & Philosophy](#key-principles--philosophy)
8. [Example: Complete v1 Workflow](#example-complete-v1-workflow)
9. [Limitations of v1](#limitations-of-v1)
10. [What Changed in v2](#what-changed-in-v2)
11. [v1 to v2 Comparison Matrix](#v1-to-v2-comparison-matrix)
12. [Migration Path](#migration-path)

---

## Executive Summary

| Aspect | GSD v1 | GSD v2 |
|--------|--------|--------|
| **Type** | Pure prompt-based meta-framework | Hybrid TypeScript scaffold + agents |
| **Installation** | `npx get-shit-done-cc@latest` | Clone repo + `bash scripts/scaffold-project.sh` |
| **Runtime Support** | 15+ coding agents (Claude, Codex, Gemini, etc.) | Integrated with VS Code, Cursor, Windsurf |
| **Project Artifacts** | `.planning/` markdown directory | `.planning/` + `.claude/` + `.github/` + source code |
| **State Management** | Manual markdown files (STATE.md, ROADMAP.md) | JSON config + markdown files |
| **Testing Framework** | External (user's choice) | Jest + ts-jest pre-configured |
| **Security** | Hooks-based (pre-commit) | Pre-commit + security scanning in CI/CD |
| **Scaling** | Single agent per session | Multi-agent orchestration with subagents |
| **Learning Curve** | Steep (unfamiliar workflow paradigm) | Gradual (scaffolded TypeScript project) |
| **Ideal For** | Creative solo developers | Teams, enterprises, production systems |

---

## What is GSD v1: The Original Framework

### Core Concept

GSD v1 is a **meta-prompting system** that applies context engineering and spec-driven development principles to Claude Code and other AI coding agents. Instead of asking Claude Code to "write a feature," GSD provides:

- Structured phases (discuss → plan → execute → verify)
- Rich context files (REQUIREMENTS.md, ROADMAP.md, STATE.md)
- Atomic task plans with XML structure
- Parallel execution with wave-based coordination
- Persistent verification to prevent hallucinations

**Original inspiration:**
> "I'm a solo developer. I don't write code — Claude Code does. Other spec-driven tools (BMAD, Speckit) are too enterprise-y. I built GSD because the complexity is in the system, not in my workflow."
> — TÂCHES (original creator)

### How v1 Worked: Claude Code Prompt System

GSD v1 distributed as **npm package** (`get-shit-done-cc`) containing:

1. **Skills/Commands** — 75+ slash commands installed to:
   - `~/.claude/skills/gsd-*/SKILL.md` (Claude Code 2.1.88+)
   - `./.claude/skills/gsd-*/SKILL.md` (local install)
   - `./.codex/skills/gsd-*/SKILL.md` (Codex)
   - `./.cline/rules.md` (Cline)

2. **Workflow Files** — Orchestration logic:
   - `commands/gsd/*.md` — Command entry points
   - `agents/*.md` — Specialized agents (planner, executor, verifier, debugger)
   - `workflows/*.md` — Phase workflow definitions

3. **Hook Scripts** — Node.js scripts for environment management:
   - `hooks/gsd-statusline.js` — Display current phase in terminal
   - `hooks/pre-commit` — Prevent secret leaks
   - `hooks/update-check.js` — Notify on new GSD version

### Installation Method

```bash
# Global install (all projects)
npx get-shit-done-cc@latest --claude --global

# Local install (this project only)
npx get-shit-done-cc@latest --claude --local

# Multi-runtime selection
npx get-shit-done-cc@latest  # Interactive prompt for runtime
```

**Supports 15+ runtimes:**
- Claude Code, OpenCode, Gemini CLI, Kilo, Codex, Copilot, Cursor
- Windsurf, Antigravity, Augment, Trae, Qwen Code, Hermes Agent, Cline, CodeBuddy

---

## Architecture & Core Concepts

### 1. Context Engineering

**Problem it solves:** Claude Code is incredibly powerful if you give it the right context. Most people don't.

GSD v1 loads context strategically based on phase:

| Artifact | Loaded By | Purpose | Size |
|----------|-----------|---------|------|
| PROJECT.md | All agents | Project vision, always loaded | ~500 bytes |
| REQUIREMENTS.md | Planner, executor, verifier | Scoped v1/v2 features with IDs | ~2KB |
| ROADMAP.md | All agents | Phase breakdown, status tracking | ~3KB |
| STATE.md | All agents | Decisions, blockers, session memory | ~2KB |
| {phase}-CONTEXT.md | Planner, executor | Implementation preferences locked in discuss-phase | ~1-2KB |
| {phase}-RESEARCH.md | Executor | Ecosystem knowledge from research agents | ~3-5KB |
| {phase}-{N}-PLAN.md | Executor | Atomic task with XML structure, fresh context | ~1-3KB per plan |

**Result:** Fresh 200K context window per subagent → no context rot degradation

### 2. XML Prompt Formatting

Every plan is structured XML, not freeform markdown:

```xml
<task type="auto">
  <name>Create login endpoint</name>
  <files>src/app/api/auth/login/route.ts</files>
  <action>
    Use jose for JWT (not jsonwebtoken - CommonJS issues).
    Validate credentials against users table.
    Return httpOnly cookie on success.
  </action>
  <verify>curl -X POST localhost:3000/api/auth/login returns 200 + Set-Cookie</verify>
  <done>Valid credentials return cookie, invalid return 401</done>
</task>
```

**Why XML?** Claude models show 15-20% higher accuracy with structured tags vs. freeform markdown.

### 3. Multi-Agent Orchestration

GSD v1 uses a **thin orchestrator pattern**:

```
┌─────────────────────────────────────┐
│  Main Session (30-40% context)      │
│  - Orchestrator (plan, delegate)    │
│  - User interaction (questions, etc) │
└──────────┬──────────────────────────┘
           │
    ┌──────┴────────────────────────┐
    │                               │
┌───▼─────────────────┐  ┌────────▼──────────────┐
│ Subagent A          │  │ Subagent B           │
│ (fresh 200K context)│  │ (fresh 200K context)  │
│ - Planner           │  │ - Executor           │
│ - Task execution    │  │ - Task execution     │
│ - Commit             │  │ - Commit             │
└─────────────────────┘  └──────────────────────┘
```

**Pattern:** Main session stays at 30-40% context. Work happens in fresh subagent windows. Quality stays high throughout a project.

### 4. Atomic Git Commits

Each task gets its own commit immediately after completion:

```bash
abc123f feat(01-01): implement validateSignature with timingSafeEqual
def456g feat(01-02): add Express middleware wrapper and 401 error format
hij789k feat(01-02): fix timeout-safe comparison for mismatched buffer lengths
```

**Benefits:**
- `git bisect` finds exact failing task
- Each task independently revertable
- Clear history for future Claude sessions
- Better observability in AI-automated workflows

---

## Original Workflow Phases

GSD v1 's core workflow had **6 main phases**:

### 1. Initialize Project (`/gsd-new-project`)

**What happens:**
- Questions → Research → Requirements → Roadmap

**Questions asked:**
1. **Vision** — "What are you building? Why does it matter?"
2. **Core priority** — "What's the single most important feature?"
3. **Boundaries** — "What's explicitly OUT of scope for v1?"
4. **Constraints** — "Any technical constraints? Team size?"

**Parallel research spawns 4 agents:**
- Stack researcher — ecosystem & library landscape
- Features researcher — common patterns & requirements
- Architecture researcher — system design patterns
- Pitfalls researcher — known failure modes & gotchas

**Output created:**
```
.planning/
  PROJECT.md          # "Webhook validator middleware for Express..."
  REQUIREMENTS.md     # REQ-001: Validate signature; REQ-002: Timing-safe...
  ROADMAP.md          # Phase 1 status: pending; Phase 2 status: pending
  STATE.md            # Session memory, decisions, blockers
  config.json         # Workflow preferences
  research/
    STACK.md          # "Node.js, Express, crypto..."
    FEATURES.md       # "HMAC-SHA256, timing-safe-equal..."
    ARCHITECTURE.md   # "Middleware pattern, Express plugin system..."
    PITFALLS.md       # "CommonJS/ESM mismatch, timing attack vectors..."
```

### 2. Discuss Phase (`/gsd-discuss-phase N`)

**What happens:**
- User shapes implementation BEFORE planning
- Surfaces gray areas (UI/UX/behavior decisions)
- Asks until preferences are locked in
- Creates CONTEXT.md (fed to planner)

**Example questions:**
- "How should invalid signatures be handled?" → "Reject with 401, log raw header"
- "Global or per-route tolerance window?" → "Global default, per-route override"
- "Library for HMAC?" → "Node crypto only, no extra deps"

**Output:** `{phase}-CONTEXT.md`

```markdown
## Implementation Decisions
- Invalid signatures → 401, log raw header
- Tolerance window → global default, per-route override via options
- HMAC library → Node.js built-in crypto
- Error format → { error: "invalid_signature", ts: <epoch> }
```

### 3. Plan Phase (`/gsd-plan-phase N`)

**What happens:**
1. Spawn 4 parallel research agents (same as new-project, phase-focused)
2. Planner reads CONTEXT.md + research findings
3. Planner creates atomic task plans (2-3 tasks per phase)
4. Plan-checker verifies each plan achieves phase goal
5. Revision loop if issues found (max 3 iterations)

**Plan-checker verifies 8 dimensions:**
1. Requirement coverage — All phase requirements covered?
2. Task completeness — Tasks achieve the goal?
3. Dependency correctness — Dependencies mapped correctly?
4. Key links — Files match ROADMAP promises?
5. Scope sanity — No silent requirement drops?
6. Must-haves derivation — Extracted from phase goal?
7. CLAUDE.md compliance — Project guidelines followed?
8. Nyquist validation — Test infrastructure in place?

**Output:** `{phase}-RESEARCH.md`, `{phase}-01-PLAN.md`, `{phase}-02-PLAN.md`, etc.

### 4. Execute Phase (`/gsd-execute-phase N`)

**What happens:**
1. Analyze plan dependencies → group into waves
2. Spawn fresh 200K executor per plan
3. Parallel execution (wave 1), then sequential dependency ordering
4. Atomic git commit per task
5. Verifier checks codebase against phase goals

**Wave execution example:**

```
Wave 1 (parallel):
  [Executor A] → 01-01-PLAN.md (core function)  ✓ committed
  [Executor B] → 01-02-PLAN.md (middleware)     ✓ committed

Wave 2 (sequential on Wave 1):
  [Executor C] → 01-03-PLAN.md (error handling) ✓ committed

[Verifier] Checking codebase against phase goals...
  REQ-001 validateSignature() ✓
  REQ-002 timing-safe compare ✓
  REQ-003 tolerance window ✓
  Status: PASS
```

**Output:** `{phase}-01-SUMMARY.md`, `{phase}-VERIFICATION.md`

### 5. Verify Work (`/gsd-verify-work N`)

**What happens:**
1. Extract testable deliverables from phase goal
2. Walk user through manual UAT (1 check at a time)
3. If issues found, generate fix plans automatically
4. Re-run execute until all checks pass

**Example interaction:**
```
[1/3] Can you require the middleware and pass it to an Express route?
> yes

[2/3] Does a request with valid signature return 200?
> yes

[3/3] Does a request with invalid signature return 401?
> no — I'm getting 500

[Diagnosing...] Root cause: TypeError when buffers differ. Fix: normalize to same length.
Fix plan created: 01-03-PLAN.md
Run /gsd-execute-phase 1 to apply.
```

**Output:** `{phase}-UAT.md`, fix plans if needed

### 6. Ship Phase (`/gsd-ship N`)

**What happens:**
- Create PR from verified phase work
- Auto-generate rich PR body from planning artifacts
- Push branch, create PR via `gh`, update STATE.md

**Output:** Pull Request with description

```markdown
# Phase 1 — Core middleware

Closes: (link to ROADMAP)

## What changed
- Added validateSignature() with timing-safe comparison
- Express middleware wrapper with 401 error handling
- Configurable replay-protection tolerance window

## Verification
- All requirements satisfied (REQ-001, REQ-002, REQ-003)
- Unit tests pass: npm test
- Manual UAT passed

## Checklist
- [x] Code written
- [x] Tests passing
- [x] Manual verification complete
- [x] No secrets in commit
```

---

## File Structure (v1)

A typical GSD v1 project after `/gsd-new-project`:

```
.planning/
  PROJECT.md              # Project vision (always loaded by all agents)
  REQUIREMENTS.md         # Scoped v1/v2 requirements with IDs + traceability
  ROADMAP.md              # Phase breakdown, status, success criteria
  STATE.md                # Decisions, blockers, session memory (YAML frontmatter)
  config.json             # Workflow config: mode, granularity, profiles, hooks

  research/               # Domain research from /gsd-new-project
    STACK.md              # Ecosystem, libraries, versions
    FEATURES.md           # Patterns, implementations, standards
    ARCHITECTURE.md       # System design, request flows, constraints
    PITFALLS.md           # Known failure modes, edge cases

  phases/
    01-core-middleware/
      CONTEXT.md          # Implementation decisions (from discuss-phase)
      RESEARCH.md         # Phase-specific research findings
      01-01-PLAN.md       # Task: create validateSignature core function
      01-01-SUMMARY.md    # Execution outcome & decision log
      01-02-PLAN.md       # Task: Express middleware wrapper
      01-02-SUMMARY.md    # Execution outcome
      VERIFICATION.md     # Post-execution verification results (UAT status)
      UAT.md              # Manual user acceptance test results
      .review-findings/   # Code review findings (from /gsd-code-review)

    02-advanced-features/
      CONTEXT.md
      RESEARCH.md
      02-01-PLAN.md
      02-01-SUMMARY.md
      VERIFICATION.md
      UAT.md

  workstreams/            # Parallel milestone work (v1.28+)
    feature-a/.planning/
      STATE.md
      ROADMAP.md
      phases/...

    feature-b/.planning/
      STATE.md
      ROADMAP.md
      phases/...

  spikes/                 # Feasibility experiments (v1.37+)
    001-sse-vs-websocket/
      README.md           # Verdict with evidence
      experiments/...
    MANIFEST.md

  sketches/               # HTML mockups (v1.37+)
    001-dashboard-layout/
      index.html          # 2-3 design variants
      themes/
        default.css       # Shared design tokens
    MANIFEST.md

  codebase/               # Brownfield analysis (from /gsd-map-codebase)
    STACK.md              # Technology stack
    ARCHITECTURE.md       # System components, data flow
    CONVENTIONS.md        # Code patterns, naming, structure
    STRUCTURE.md          # Directory organization

  todos/
    pending/              # Captured ideas awaiting work
    done/                 # Completed todos

  debug/
    001-login-button-unresponsive/
      FINDINGS.md         # Root cause analysis
      FIX-PLAN.md         # Proposed fixes
    resolved/

  intel/                  # Queryable codebase index (v1.32+)
    files.json            # File inventory
    exports.json          # Module exports
    symbols.json          # Symbols (functions, classes)
    patterns.json         # Recurring code patterns
    dependencies.json     # Dependency graph

  MILESTONES.md           # Completed milestone archive
  HANDOFF.json            # Session handoff for later resume
```

---

## Commands Available (v1)

### Core Workflow (6 commands)

| Command | Purpose | When to use |
|---------|---------|------------|
| `/gsd-new-project` | Full init: questions → research → requirements → roadmap | Starting a new feature |
| `/gsd-discuss-phase [N]` | Lock in implementation preferences before planning | Before every plan-phase |
| `/gsd-plan-phase [N]` | Research + plan + verify for a phase | After discuss-phase |
| `/gsd-execute-phase [N]` | Execute all plans in parallel waves | After plan-phase approval |
| `/gsd-verify-work [N]` | Manual UAT with auto-diagnosis | After execution |
| `/gsd-ship [N]` | Create PR from verified work | When phase is ready |

### Phase Management (8 commands)

| Command | Purpose |
|---------|---------|
| `/gsd-add-phase` | Append phase to roadmap |
| `/gsd-insert-phase [N]` | Insert urgent work between phases |
| `/gsd-edit-phase [N]` | Modify phase in place |
| `/gsd-remove-phase [N]` | Remove future phase, renumber |
| `/gsd-list-phase-assumptions [N]` | See Claude's intended approach before planning |
| `/gsd-plan-milestone-gaps` | Create phases to close audit gaps |

### Milestone Management (4 commands)

| Command | Purpose |
|---------|---------|
| `/gsd-new-milestone` | Start next version (questions → research → roadmap) |
| `/gsd-audit-milestone` | Verify milestone achieved definition of done |
| `/gsd-complete-milestone` | Archive, tag release |
| `/gsd-session-report` | Generate session summary |

### Quality & Review (7 commands)

| Command | Purpose |
|---------|---------|
| `/gsd-code-review [N]` | Peer review of current phase |
| `/gsd-code-review-fix [N]` | Fix critical findings, re-review |
| `/gsd-ui-phase [N]` | Generate UI design contract |
| `/gsd-ui-review [N]` | Retroactive 6-pillar visual audit |
| `/gsd-secure-phase [N]` | Security enforcement with threat-model-anchored verification |
| `/gsd-audit-uat` | Cross-phase verification debt tracking |

### Quick & Ad-Hoc (3 commands)

| Command | Purpose |
|---------|---------|
| `/gsd-quick` | Ad-hoc task (skips optional agents) |
| `/gsd-fast` | Trivial inline task (skips planning) |
| `/gsd-spike` | Throwaway feasibility experiment |

### Navigation & Help (5 commands)

| Command | Purpose |
|---------|---------|
| `/gsd-progress` | Where am I? What's next? |
| `/gsd-next` | Auto-detect state, run next step |
| `/gsd-help` | Show all commands |
| `/gsd-update` | Update GSD with changelog |
| `/gsd-join-discord` | Join community |

### Research & Analysis (5 commands)

| Command | Purpose |
|---------|---------|
| `/gsd-map-codebase [area]` | Analyze existing codebase before new-project |
| `/gsd-ingest-docs [dir]` | Scan mixed ADRs, PRDs, SPECs and bootstrap .planning/ |
| `/gsd-debug` | Systematic debugging with hypothesis testing |
| `/gsd-review-backlog` | Review and promote backlog items |
| `/gsd-stats` | Project statistics dashboard |

### Configuration (4 commands)

| Command | Purpose |
|---------|---------|
| `/gsd-settings` | Configure model profile & workflow agents |
| `/gsd-set-profile [profile]` | Switch model profile (quality/balanced/budget) |
| `/gsd-health [--repair]` | Validate .planning/ directory integrity |

**Total: 75+ commands in v1.39.x**

---

## Key Principles & Philosophy

### 1. Context Engineering > Prompting

> "Claude Code is incredibly powerful if you give it the context it needs. Most people don't."

Instead of better prompts, GSD focuses on **context layering**:
- Wrong context → brilliant Claude produces garbage
- Right context → brilliant Claude produces excellence
- **Goal:** Provide just-in-time context loaded exactly when needed

### 2. Thin Orchestrator Pattern

> "The orchestrator never does heavy lifting. It spawns agents, waits, integrates results."

Benefits:
- Main session stays responsive (30-40% context)
- Each subagent gets fresh 200K window
- Parallel execution where possible
- Zero context rot degradation

### 3. Spec-Driven Development

> "Describe what you want, let the system extract everything it needs to know."

Workflow:
1. User describes idea (not requirements list)
2. System asks clarifying questions (discuss)
3. System researches domain (plan)
4. System creates atomic plans (plan-verify)
5. Agents execute with no guessing (execute)
6. User verifies outcome (verify)

### 4. Atomic Git Commits

Every task → one commit immediately

Benefits:
- Bisect finds failing task
- Revertable at task level
- Clear history for future sessions
- Better observability

### 5. No Enterprise Theater

> "I'm not a 50-person software company. I don't want to play enterprise theater."

- No sprint ceremonies, story points, retrospectives
- No Jira, Asana, or project management overhead
- No "stakeholder syncs"
- Just: describe what you want, watch it get built

### 6. Vibecoding Prevention

> "Vibecoding has a bad reputation. You describe what you want, AI generates code, and you get inconsistent garbage that falls apart at scale."

GSD's answer:
- Context engineering prevents hallucination
- Verification prevents silent failures
- Plan-checking prevents wrong assumptions
- UAT catches implementation gaps

### 7. Quality ≠ Complexity

> "The complexity is in the system, not in your workflow."

- Simple: `/gsd-new-project`, `/gsd-plan-phase`, `/gsd-execute-phase`
- Complex: Behind the scenes (agents, hooks, multi-agent orchestration, context layering)
- Result: Reliable systems from simple commands

---

## Example: Complete v1 Workflow

### Scenario: Building a Webhook Validator for Express

```bash
# Step 1: Initialize project
/gsd-new-project

# Questions asked:
# > What are you building?
#   "A webhook signature validator middleware for Express"
# > Who are the users?
#   "Backend developers integrating webhooks from Stripe, GitHub, Shopify"
# > What's the core priority?
#   "Secure signature validation with replay attack prevention"
# > Boundaries?
#   "Out of scope: webhook retry logic, rate limiting"
# > Constraints?
#   "No extra dependencies, use Node.js crypto only"

# [Research agents run in parallel...]
# [Requirements extracted: REQ-001, REQ-002, REQ-003...]
# [Roadmap created with 2 phases...]

# Approve roadmap? [y/n]
y

# Output:
# .planning/PROJECT.md
# .planning/REQUIREMENTS.md
# .planning/ROADMAP.md
# .planning/research/{STACK,FEATURES,ARCHITECTURE,PITFALLS}.md

---

# Step 2: Discuss phase 1
/gsd-discuss-phase 1

# Questions asked:
# > How should invalid signatures be handled?
#   "Reject with 401, log the raw header for debugging"
# > Per-route or global tolerance window?
#   "Global default, but allow per-route override"
# > Library preference for HMAC?
#   "Node.js crypto only, no extra npm deps"

# Output:
# .planning/phases/01-core-middleware/CONTEXT.md

---

# Step 3: Plan phase 1
/gsd-plan-phase 1

# [Research agents investigate HMAC, timing-safe comparison, Express patterns...]
# [Planner creates 2 plans...]
# [Plan-checker verifies both achieve phase goal...]

# Output:
# .planning/phases/01-core-middleware/RESEARCH.md
# .planning/phases/01-core-middleware/01-01-PLAN.md  (core function)
# .planning/phases/01-core-middleware/01-02-PLAN.md  (middleware + error handling)

---

# Step 4: Execute phase 1
/gsd-execute-phase 1

# Wave 1 (parallel):
#   [Executor A] → 01-01-PLAN.md: create validateSignature()
#   [Executor B] → 01-02-PLAN.md: Express middleware + 401 handler
#
# Both committed atomically
# [Verifier] Checks: REQ-001 ✓, REQ-002 ✓, REQ-003 ✓

# Output:
# Git commits:
#   abc123 feat(01-01): implement validateSignature with timingSafeEqual
#   def456 feat(01-02): add Express middleware and 401 error handler
# .planning/phases/01-core-middleware/01-01-SUMMARY.md
# .planning/phases/01-core-middleware/01-02-SUMMARY.md
# .planning/phases/01-core-middleware/VERIFICATION.md

---

# Step 5: Verify work
/gsd-verify-work 1

# [1/3] Can you require and use the middleware?
# > yes
# [2/3] Does valid signature return 200?
# > yes
# [3/3] Does invalid signature return 401?
# > no — getting 500
# [Auto-diagnosing...] Root cause: buffers different lengths
# Fix plan created: 01-03-PLAN.md

/gsd-execute-phase 1  # Re-run to apply fix

/gsd-verify-work 1    # All checks pass now

# Output:
# .planning/phases/01-core-middleware/UAT.md
# .planning/phases/01-core-middleware/01-03-PLAN.md (fix)
# .planning/phases/01-core-middleware/01-03-SUMMARY.md

---

# Step 6: Ship it
/gsd-ship 1

# [Creates PR with auto-generated body from planning artifacts]
# [Tags milestone, pushes branch, opens PR]

# Output: Pull Request on GitHub

---

# Repeat for phase 2
/gsd-discuss-phase 2
/gsd-plan-phase 2
/gsd-execute-phase 2
/gsd-verify-work 2
/gsd-ship 2

---

# Done: complete and release
/gsd-audit-milestone    # Verify all requirements shipped
/gsd-complete-milestone # Archive, tag v1.0.0
```

---

## Limitations of v1

GSD v1 was incredibly powerful but had real constraints:

### 1. Installation & Onboarding Friction

**Problem:**
```bash
npx get-shit-done-cc@latest      # Installs 75+ files globally or locally
npm install get-shit-done-cc     # Adds to node_modules
~/.claude/skills/gsd-*/SKILL.md  # Scattered across home directory
```

- Complex installer with many edge cases (Windows paths, Docker, WSL)
- Hard to reason about what got installed where
- Version conflicts between global/local installs
- Different paths per runtime (Claude, Codex, Gemini, Cline)
- Learning curve: "How do I use this thing?"

### 2. No Integrated Development Environment

**Problem:**
- GSD provided workflow but no scaffold
- No TypeScript setup, no test framework, no ESLint
- Users had to bootstrap their own project
- "I have GSD commands but where do I put my code?"

### 3. Prompt-Only Approach

**Problem:**
- All logic lived in markdown files
- No programmatic APIs
- Hard to extend or customize
- Hooks were shell scripts (fragile on Windows)
- Version control nightmare (git diffs of 1000+ line prompt files)

### 4. Runtime Fragmentation

**Problem:**
- 15 different runtimes, each needed translation
- Claude Code skills vs Codex rules vs Gemini templates
- Per-runtime path rules, config formats, model names
- Maintenance burden (every feature = 15x implementation)

### 5. Single-Machine Limitations

**Problem:**
- No team collaboration
- No CI/CD integration
- SSH sessions had issues (no native UI)
- WSL/Docker installations fragile

### 6. Complex Installation Logic

**Problem:**
- 5000+ line installer (`bin/install.js`)
- Edge cases for every runtime + OS
- Local patch backup/reapply system
- Symlink/copy/hook management fragile

### 7. No Type Safety

**Problem:**
- JSON state files edited manually
- YAML frontmatter parsing brittle
- No validation of config structure
- Silent failures when config malformed

### 8. Hard to Debug

**Problem:**
- Issues were "agent produced wrong code"
- Hard to isolate: is it GSD, is it Claude, is it config?
- State corruption (STATE.md out of sync with git)
- `/gsd-forensics` command helped but was reactive

### 9. Learning Curve

**Problem:**
- Unfamiliar workflow paradigm (discuss → plan → execute → verify)
- 75+ commands to master
- "When do I use `/gsd-quick` vs `/gsd-spike`?"
- Documentation was 100+ pages

### 10. Monolithic Approach

**Problem:**
- Everything: planning, execution, verification, debugging, shipping
- No way to use "just the phase planning" without full GSD
- Tightly coupled to specific agent behaviors
- Hard to mix-and-match with other tools

---

## What Changed in v2

GSD v2 (`hdd-gsd2-hybrid-framework`) addresses all v1 limitations:

### 1. Integrated Project Scaffold

**v2 approach:**
```bash
git clone <repo>
bash scripts/scaffold-project.sh      # Single script, creates 51+ files
# Done: full TypeScript project + GSD integration
```

**What you get:**
- ✅ TypeScript `tsconfig.json` with strict mode
- ✅ Jest + ts-jest test setup (80% coverage threshold)
- ✅ ESLint + Prettier configured
- ✅ `.claude/`, `.github/`, `src/`, `tests/` structure
- ✅ GitHub workflows (CI/CD, security scanning)
- ✅ AGENTS.md (single source of truth, symlinked)
- ✅ Pre-commit hooks blocking secrets
- ✅ Ready-to-code in 5 minutes

### 2. Zero Installation Complexity

**v2 approach:**
```bash
# Option 1: Use the scaffold directly
git clone <repo> my-project
cd my-project
npm install

# Option 2: Don't use npm install at all
# Everything is version-controlled
# No global state, no PATH manipulation
```

**Benefits:**
- Reproducible across machines
- Docker-friendly
- CI/CD friendly
- No installer complexity

### 3. Hybrid Approach: Code + Prompts

**v1:** Everything is prompts
```bash
~/.claude/skills/gsd-new-project/SKILL.md  (big markdown file)
```

**v2:** Code + prompts working together
```
src/                           # Actual application code
  lib/logger.ts               # Typed utilities
  types/index.ts              # Domain types
  middleware/                 # Request handling

AGENTS.md                      # Unified agent instructions (single source)
.claude/skills/               # Project-specific agent skills
.github/agents/               # GitHub-specific agents
tsconfig.json                 # Type safety
jest.config.js               # Testing
```

### 4. Language Support

**v1:** Prompt-based, runtime-agnostic but fragmented
```
Claude Code → one variant
Codex → translation layer
Gemini → translation layer
...
```

**v2:** First-class TypeScript
```typescript
// Real types for configuration, state, etc
interface PhaseConfig {
  number: string
  name: string
  requirements: string[]
  status: 'pending' | 'in-progress' | 'complete'
}

// Type-safe utilities instead of string manipulation
export function updatePhaseStatus(phase: PhaseConfig, status: PhaseConfig['status']) {
  // ...
}
```

### 5. Multi-Agent as First-Class

**v1:** Agents were spawned via commands
**v2:** Multi-agent orchestration built into framework

```
agents/
  gsd-planner.md         # Typed agent with clear responsibilities
  gsd-executor.md
  gsd-debugger.md
  gsd-verifier.md
```

### 6. Single Source of Truth

**v1:** AGENTS.md + CLAUDE.md + .instructions.md (duplicates)
**v2:** Symlinks + version control
```bash
AGENTS.md                      # The truth
CLAUDE.md → AGENTS.md         # Symlink
.instructions.md → AGENTS.md   # Symlink
.github/copilot-instructions.md → ../AGENTS.md  # Symlink
```

All tools read the same file automatically.

### 7. Built-in Security

**v1:** Pre-commit hooks (shell scripts, fragile)
**v2:** Pre-commit + CI/CD scanning
```
hooks/pre-commit              # Git hook
.github/workflows/security.yml # CI scanning for secrets
```

### 8. Team-Ready

**v1:** Solo developer tool
**v2:** Team scaffolding
```
.github/
  CODEOWNERS          # Code ownership
  pull_request_template.md
  issue_templates/
  agents/             # Team-specific agents
```

### 9. Gradual Onboarding

**v1:** Master 75+ commands
**v2:** Start simple, grow into it
```bash
# Day 1: Run the scaffold, code works
# Week 1: Use AGENTS.md to guide Claude
# Month 1: Understand multi-agent orchestration
# 3 months: Customize agents for your team
```

### 10. Extensible Architecture

**v1:** Fork the repo, modify files
**v2:** Designed for customization
```
.claude/skills/my-skill/SKILL.md        # Add your own agents
.github/agents/my-team-agent.md          # Team-specific expertise
src/custom/                              # Your business logic
```

---

## v1 to v2 Comparison Matrix

| Category | GSD v1 | GSD v2 |
|----------|--------|--------|
| **Installation** | `npx get-shit-done-cc@latest` | `git clone && bash scripts/scaffold-project.sh` |
| **Package Size** | 50MB+ (75+ markdown files) | 2MB (TypeScript scaffold) |
| **Setup Time** | 10-15 min (with troubleshooting) | <5 min |
| **Runtimes Supported** | 15 (fragmented code) | 3+ (unified core) |
| **State Management** | Markdown files + YAML frontmatter | JSON config + markdown |
| **Type Safety** | None | Full TypeScript strict mode |
| **Testing** | User's choice | Jest pre-configured |
| **Linting** | User's choice | ESLint + Prettier pre-configured |
| **CI/CD** | None | GitHub workflows included |
| **Security** | Pre-commit hooks | Pre-commit + CI scanning |
| **Learning Curve** | Steep (75+ commands) | Gradual (core commands first) |
| **Single Developer** | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐ |
| **Team (3-5 devs)** | ⭐⭐ | ⭐⭐⭐⭐ |
| **Enterprise (10+ devs)** | ⭐ | ⭐⭐⭐ |
| **Debugging** | `/gsd-debug` + `/gsd-forensics` | Integrated with TypeScript tooling |
| **Extensibility** | Fork + modify | Custom skills in `.claude/` |
| **Version Control** | Git (complex diffs of prompts) | Git (tracked code changes) |
| **Documentation** | 100+ pages | Inline code + scaffold docs |
| **Community Support** | Discord (~1K members) | GitHub discussions + issues |

---

## Migration Path

### From v1 to v2: Three Strategies

#### Strategy 1: Fresh Project (Recommended)

Start a new project using v2 scaffold:

```bash
git clone https://github.com/lfarizav/hdd-gsd2-hybrid-framework new-project
cd new-project
bash scripts/scaffold-project.sh

# Start development
npm run dev
npm test
```

**When to use:** Starting from scratch, new team
**Effort:** 5 minutes
**Result:** Full v2 setup

#### Strategy 2: Import Existing GSD v1 Project

Existing v1 project? Import its planning structure:

```bash
# In your v1 project
/gsd-map-codebase                    # Analyze your codebase

# Now bootstrap v2
bash scripts/scaffold-project.sh

# Optionally migrate v1 artifacts
# Your .planning/ directory is still usable
# Copy over .planning/PROJECT.md, REQUIREMENTS.md, ROADMAP.md
```

**When to use:** Upgrading from v1
**Effort:** 15-30 minutes
**Result:** v2 structure + preserved planning history

#### Strategy 3: Hybrid Approach

Run both v1 and v2 features on same project:

```bash
# Your project has:
npm run build        # v2 TypeScript build
npm test            # v2 Jest tests
npm run lint        # v2 ESLint

# AND you can still use v1 workflow:
npx get-shit-done-cc --local    # Install v1 skills locally
/gsd-new-project                # v1 commands still work
```

**When to use:** Want to experiment with v2 gradually
**Effort:** 20-40 minutes
**Result:** Both frameworks available

### Mapping v1 Concepts to v2

| v1 Concept | v1 Location | v2 Location | v2 Evolution |
|------------|------------|------------|--------------|
| Project vision | `PROJECT.md` | `src/README.md` + `AGENTS.md` | Moves to code, instructions explicit |
| Requirements | `REQUIREMENTS.md` | `.planning/REQUIREMENTS.md` + `src/types/` | Types replace plain text |
| Roadmap | `ROADMAP.md` | `.planning/ROADMAP.md` + GitHub issues | Issues as phases |
| Phase planning | `.planning/phases/01-*` | `.planning/phases/01-*` (same) | Structure unchanged |
| Agents | `~/.claude/skills/gsd-*/` | `.claude/skills/` (local) | Integrated into scaffold |
| Config | `.planning/config.json` | `.planning/config.json` + `tsconfig.json` | JSON + TypeScript config |
| Tests | Manual | `tests/unit/`, `tests/integration/` | Integrated, 80% threshold |
| CI/CD | Manual | `.github/workflows/` | Pre-configured |
| Secrets | `.env.example` | Same | Pre-commit hook included |

---

## Summary

### GSD v1: The Pioneer

GSD v1 proved that context engineering + spec-driven development could reliably scale Claude Code from "I built a prototype" to "I shipped a production system."

**Key achievement:** **Eliminated vibecoding** through systematic planning, parallel execution, and continuous verification.

**What it did well:**
- Revolutionary workflow (discuss → plan → execute → verify)
- Context engineering (no context rot)
- Atomic commits + verifiable outcomes
- Multi-agent orchestration
- 75+ commands covering every use case

**What it couldn't do:**
- Team scaling
- CI/CD integration
- Type safety
- DX (developer experience)
- Easy installation

### GSD v2: The Scaffold

GSD v2 builds on v1's proven workflow but packages it as **production-ready framework**—with TypeScript, testing, security, and team capabilities built in.

**Key achievement:** **Democratized agentic engineering** by making it accessible to teams, not just solo developers.

**What v2 adds:**
- Integrated TypeScript scaffold
- Jest + ts-jest pre-configured
- GitHub workflows (CI/CD, security)
- Single source of truth (AGENTS.md + symlinks)
- Team-ready structure
- <5 min setup

**What v2 preserves:**
- Core workflow (discuss → plan → execute → verify)
- `.planning/` directory structure
- 75+ GSD v1 commands (still usable)
- Agent-first architecture

### The Evolution

```
GSD v1 (v1.39.1)          GSD v2 (Hybrid Framework)
├─ Pure prompt-based      ├─ Code + Prompts
├─ 75+ commands           ├─ Core commands + extensibility
├─ Solo developer focus   ├─ Team-ready
├─ Manual setup           ├─ Automatic scaffold
├─ Markdown state         ├─ JSON config + markdown
├─ No type safety         ├─ Full TypeScript strict
└─ Community: ~1K         └─ Enterprise-ready
```

### Recommendation

- **Starting fresh?** → Use **GSD v2**
- **Upgrading from v1?** → Start with **v2 scaffold**, import your `.planning/` directory
- **Solo developer who loves CLI?** → Keep using **v1**
- **Team building production system?** → Use **v2**
- **Want best of both?** → Use **v2 hybrid** (both installed locally)

---

## References

- **GSD v1 Original:** https://github.com/gsd-build/get-shit-done (v1.39.1 — latest)
- **GSD v1 CHANGELOG:** Full history v1.0.0 → v1.39.1 with 500+ commits
- **GSD v2 Hybrid:** https://github.com/lfarizav/hdd-gsd2-hybrid-framework
- **Research Paper:** Gloaguen et al. (2026), "Evaluating AGENTS.md," arXiv:2602.11988v1

---

**Made with ❤️**
This guide was created to help developers understand the evolution of Get Shit Done from its original prompt-based foundation to a modern, team-ready agentic engineering scaffold.
