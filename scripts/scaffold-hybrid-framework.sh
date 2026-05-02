#!/usr/bin/env bash
# =============================================================================
# scaffold-hybrid-framework.sh
# =============================================================================
# PURPOSE:
#   Installs and scaffolds the three-layer hybrid framework on top of an
#   existing project created by scaffold-project.sh:
#
#     Layer 1 — Spec-Kit  (github/spec-kit, 92.1K ⭐)
#       Specification-driven development. Executable specs govern code.
#       Files created: specs/constitution.md, specs/requirements.md,
#                      specs/quality-gates.md, specs/features/,
#                      .specify/memory/GOVERNANCE.md,
#                      .specify/memory/ARCHITECTURE.md
#
#     Layer 2 — GSD-v1   (gsd-build/get-shit-done, 59.3K ⭐)
#       Context engineering + atomic planning for AI coding agents.
#       Files created: .planning/config.json, .planning/PROJECT.md,
#                      .planning/REQUIREMENTS.md, .planning/ROADMAP.md,
#                      .planning/STATE.md, .planning/DECISIONS.md,
#                      .planning/KNOWLEDGE.md, .planning/research/
#
#     Layer 3 — GSD-2    (gsd-build/gsd-2, 7K ⭐)
#       Autonomous state-machine execution with SQLite-backed state.
#       Files created: .gsd/PREFERENCES.md
#
# DESIGN RATIONALE (Feasibility Study — docs/FEASIBILITY_STUDY.md):
#   Each framework targets a distinct root cause of LLM hallucination:
#     • Spec-Kit  → ambiguity at the requirements level
#     • GSD-v1   → context pollution within a session
#     • GSD-2    → state amnesia across sessions
#   No single framework covers all failure modes. The hybrid has no blind
#   spots. See docs/FEASIBILITY_STUDY.md for full evidence base.
#
# HANDOFF MODEL (linear, no simultaneous operation):
#   Spec-Kit (Define) → GSD-v1 (Plan) → GSD-2 (Execute)
#   Each layer produces files that the next layer consumes. The two systems
#   (v1 and v2) are never active in the same phase; GSD-2 takes over after
#   .planning/ is reviewed and approved.
#
# PREREQUISITES:
#   • bash scripts/scaffold-project.sh  already run (project exists)
#   • uv       — Python package manager  https://docs.astral.sh/uv/
#   • npm      — Node.js package manager (already required by this project)
#   • git      — Version control (already required)
#
# OPTIONAL (CLIs are checked but not force-installed by default):
#   • specify  — Spec-Kit CLI   (install with: uv tool install specify-cli)
#   • gsd      — GSD-2 CLI     (install with: npm install -g gsd-pi@latest)
#   GSD-v1 requires no global install (uses npx).
#
# IDEMPOTENCY:
#   Safe to re-run. Checks for existing files before creating. Use --force
#   to overwrite generated files (never touches .env, gsd.db, or git).
#
# USAGE:
#   bash scripts/scaffold-hybrid-framework.sh [--force] [--install-clis]
#
#   --force          Overwrite existing scaffold files
#   --install-clis   Also install specify-cli (uv) and gsd-pi (npm)
#
# =============================================================================

set -euo pipefail

# ── Colours ──────────────────────────────────────────────────────────────────
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
BLUE='\033[0;34m'
BOLD='\033[1m'
RESET='\033[0m'

FORCE=false
INSTALL_CLIS=false
for arg in "$@"; do
  [[ "$arg" == "--force" ]]        && FORCE=true
  [[ "$arg" == "--install-clis" ]] && INSTALL_CLIS=true
done

# ── Helpers ───────────────────────────────────────────────────────────────────
info()    { echo -e "${CYAN}[INFO]${RESET}  $*"; }
success() { echo -e "${GREEN}[OK]${RESET}    $*"; }
warn()    { echo -e "${YELLOW}[WARN]${RESET}  $*"; }
error()   { echo -e "${RED}[ERROR]${RESET} $*" >&2; exit 1; }
layer()   { echo -e "\n${BLUE}${BOLD}$*${RESET}"; }

write_file() {
  local path="$1"
  local content
  content=$(cat)

  if [[ -f "$path" && "$FORCE" == false ]]; then
    warn "Skipped (already exists): $path"
    return
  fi

  mkdir -p "$(dirname "$path")"
  printf '%s\n' "$content" > "$path"
  success "Created: $path"
}

make_dir() {
  local dir="$1"
  if [[ -d "$dir" ]]; then
    warn "Skipped (already exists): $dir/"
  else
    mkdir -p "$dir"
    touch "$dir/.gitkeep"
    success "Created: $dir/"
  fi
}

# ── Resolve root ──────────────────────────────────────────────────────────────
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
cd "$ROOT_DIR"

echo
echo -e "${BOLD}${BLUE}╔══════════════════════════════════════════════════════════╗${RESET}"
echo -e "${BOLD}${BLUE}║   Hybrid Framework Scaffold                              ║${RESET}"
echo -e "${BOLD}${BLUE}║   Spec-Kit  +  GSD-v1  +  GSD-2                         ║${RESET}"
echo -e "${BOLD}${BLUE}╚══════════════════════════════════════════════════════════╝${RESET}"
info "Working in: $ROOT_DIR"

# =============================================================================
# PHASE 0 — PREREQUISITES CHECK
# =============================================================================
layer "── Phase 0: Prerequisites ─────────────────────────────────────────────"

# Verify scaffold-project.sh has already been run
[[ -f "AGENTS.md" ]] || error "AGENTS.md not found. Run scaffold-project.sh first."
[[ -f "package.json" ]] || error "package.json not found. Run scaffold-project.sh first."
[[ -f "tsconfig.json" ]] || error "tsconfig.json not found. Run scaffold-project.sh first."
success "Base project scaffold detected"

# Check uv
if command -v uv &>/dev/null; then
  success "uv $(uv --version 2>/dev/null | head -1) — found"
else
  warn "uv not found. Spec-Kit CLI will not be installed."
  warn "To install uv: curl -LsSf https://astral.sh/uv/install.sh | sh"
fi

# Check npm
if command -v npm &>/dev/null; then
  success "npm $(npm --version) — found"
else
  error "npm not found. Install Node.js: https://nodejs.org/"
fi

# =============================================================================
# PHASE 1 — OPTIONAL CLI INSTALLATION
# =============================================================================
layer "── Phase 1: CLI Installation ──────────────────────────────────────────"

if [[ "$INSTALL_CLIS" == true ]]; then
  # Spec-Kit CLI via uv
  if command -v uv &>/dev/null; then
    if command -v specify &>/dev/null; then
      warn "specify CLI already installed — skipping"
    else
      info "Installing Spec-Kit CLI (specify)..."
      uv tool install specify-cli --from 'git+https://github.com/github/spec-kit.git'
      success "Spec-Kit CLI installed: specify"
    fi
  fi

  # GSD-2 CLI via npm
  if command -v gsd &>/dev/null; then
    warn "gsd CLI already installed — skipping"
  else
    info "Installing GSD-2 CLI (gsd-pi)..."
    npm install -g gsd-pi@latest
    success "GSD-2 CLI installed: gsd"
  fi

  # GSD-v1 uses npx — no global install required
  success "GSD-v1 (get-shit-done) uses npx — no install required"
else
  info "Skipping CLI installation (pass --install-clis to install)."
  info "Manual install commands:"
  info "  Spec-Kit: uv tool install specify-cli --from 'git+https://github.com/github/spec-kit.git'"
  info "  GSD-2:    npm install -g gsd-pi@latest"
  info "  GSD-v1:   npx get-shit-done-cc@latest (no global install needed)"
fi

# =============================================================================
# PHASE 2 — LAYER 1: SPEC-KIT
# =============================================================================
layer "── Phase 2: Spec-Kit Layer ────────────────────────────────────────────"
info "Creating specification-driven development structure..."

# ── specs/ directories ───────────────────────────────────────────────────────
make_dir specs/features
make_dir specs/adr
make_dir specs/rfc

# ── .specify/ (Spec-Kit working directory) ───────────────────────────────────
make_dir .specify/memory
make_dir .specify/features
make_dir .specify/templates
make_dir .specify/extensions
make_dir .specify/presets

# ── specs/constitution.md ────────────────────────────────────────────────────
write_file "specs/constitution.md" <<'CONSTITUTION_EOF'
# Project Constitution

> **Purpose:** This constitution is the load-bearing document of the hybrid
> framework. Every Spec-Kit command, every GSD-v1 plan, and every GSD-2 slice
> cascades from the values and constraints defined here.
>
> **How to use:** Fill in the sections below. Do not leave placeholders in
> production. The model will generate code consistent with whatever you write
> here — vague constitutions produce vague results.

---

## Project Identity

```yaml
project:
  name: "YOUR_PROJECT_NAME"
  purpose: "One-sentence description of what this project does and for whom."
  owner: "YOUR_NAME / YOUR_TEAM"
  repository: "https://github.com/OWNER/REPO"
```

---

## Non-Negotiable Values

> These are the absolute constraints. Any generated code, plan, or spec that
> violates a value here must be rejected and regenerated.

1. **Security-first** — All data encrypted at rest and in transit. No secrets in source code.
2. **User trust** — Clear privacy disclosures. No dark patterns. No silent data collection.
3. **Testability** — Every public API has corresponding tests. Coverage threshold: 80%.
4. **Readability over cleverness** — Descriptive names. Functional patterns. No `any`.
5. **Minimal instructions** — Per arXiv:2602.11988, only specify what agents cannot discover.

---

## Technology Constraints

```yaml
technology:
  language: TypeScript (strict mode)
  runtime: Node.js 22+
  testing: Jest + ts-jest
  linting: ESLint + Prettier
  style:
    quotes: single
    semicolons: false
    indent: 2 spaces
  patterns:
    preferred: functional
    avoid: class (unless modelling a domain entity)
```

---

## Security Baseline

- OWASP Top 10 is the minimum security standard.
- Parameterised queries only — never interpolate user input into SQL.
- Validate and sanitise all external input at system boundaries.
- Pre-commit hook blocks secrets before they reach git.
- Production secrets managed via secrets manager (AWS Secrets Manager, Vault, etc.).

---

## Quality Gates

| Gate | Requirement | Enforced By |
|------|------------|-------------|
| Tests pass | `npm test` exits 0 | CI/CD + GSD-2 auto-verify |
| Coverage | ≥ 80% branches + lines | Jest threshold |
| Lint clean | `npm run lint` exits 0 | CI/CD + pre-commit |
| Type-check | `npm run typecheck` exits 0 | CI/CD |
| No secrets | Pre-commit scan passes | `.github/hooks/pre-commit` |

---

## Compliance Requirements

> List any regulatory, legal, or organisational compliance requirements.
> Examples: GDPR, HIPAA, SOC 2, WCAG 2.1, internal security policy.

- [ ] **GDPR** — if handling EU personal data
- [ ] **OWASP ASVS Level 1** — application security minimum
- [ ] *(add your requirements here)*

---

## Architecture Principles

1. **Single responsibility** — each module has one reason to change.
2. **Explicit over implicit** — configuration, dependencies, and errors are explicit.
3. **Fail fast** — validate at system boundaries; throw on invalid state.
4. **Stateless services** — business logic is pure; side effects are pushed to edges.

---

## Definition of Done

A task is complete when:
- [ ] Code compiles without errors (`npm run typecheck`)
- [ ] All tests pass (`npm test`)
- [ ] Coverage threshold maintained (`npm test -- --coverage`)
- [ ] Lint clean (`npm run lint`)
- [ ] AGENTS.md boundaries respected
- [ ] No `TODO` comments left without a linked issue

---

## Revision History

| Date | Author | Change |
|------|--------|--------|
| <!-- DATE --> | <!-- AUTHOR --> | Initial constitution |
CONSTITUTION_EOF

# ── specs/requirements.md ─────────────────────────────────────────────────────
write_file "specs/requirements.md" <<'REQS_EOF'
# Requirements

> **Purpose:** Translates the constitution into verifiable feature requirements.
> Each requirement maps to one or more GSD-v1 planning phases and GSD-2 slices.
>
> **Format:** Use Gherkin-style Given/When/Then for testable requirements.
> Assign each a unique ID for traceability (REQ-001, REQ-002 ...).

---

## Functional Requirements

### REQ-001 — [FEATURE NAME]

**Priority:** HIGH | MEDIUM | LOW
**Phase:** Spec-Kit → GSD-v1 phase 1 → GSD-2 M001-S01

**Description:**
> Replace this with a clear, one-paragraph description of what the feature does.

**Acceptance Criteria:**

```gherkin
Feature: [FEATURE NAME]

  Scenario: [Happy path]
    Given [initial context / state]
    When  [action performed]
    Then  [expected outcome]

  Scenario: [Error case]
    Given [initial context / state]
    When  [invalid action or edge case]
    Then  [expected error handling]
```

**Out of scope:**
- List anything explicitly excluded from this requirement.

---

## Non-Functional Requirements

| ID | Category | Requirement | Measurement |
|----|----------|-------------|-------------|
| NFR-001 | Performance | API response time < 200ms for p95 | Measured in load tests |
| NFR-002 | Reliability | 99.9% uptime in production | Monitored via health checks |
| NFR-003 | Security | All endpoints authenticated | Verified by security agent |
| NFR-004 | Observability | All errors logged with stack traces | Validated by logger tests |

---

## Traceability Matrix

| Requirement | Spec-Kit Feature | GSD-v1 Phase | GSD-2 Slice | Test File |
|-------------|-----------------|-------------|-------------|-----------|
| REQ-001 | `specs/features/` | `.planning/ROADMAP.md#P1` | `M001-S01` | `tests/unit/` |

---

## Revision History

| Date | Author | Change |
|------|--------|--------|
| <!-- DATE --> | <!-- AUTHOR --> | Initial requirements |
REQS_EOF

# ── specs/quality-gates.md ────────────────────────────────────────────────────
write_file "specs/quality-gates.md" <<'GATES_EOF'
# Quality Gates

> **Purpose:** Defines mandatory checkpoints before work advances from one
> phase to the next. These gates are the mechanical enforcement of the
> constitution's definition of done.
>
> **Integration:** GSD-2 PREFERENCES.md references these gate commands.
> All gates must pass before a GSD-2 slice is marked complete.

---

## Gate Definitions

### Gate 1 — Spec Review (before planning starts)

**When:** After `specs/requirements.md` is written, before GSD-v1 planning.
**Who:** Human review required.
**Checks:**

- [ ] All requirements have acceptance criteria (Gherkin or equivalent)
- [ ] Requirements are consistent with `specs/constitution.md`
- [ ] Non-functional requirements are measurable
- [ ] `/speckit.clarify` has been run and all ambiguities resolved
- [ ] `/speckit.analyze` has been run and no cross-spec drift detected

**Block condition:** Any unchecked item above blocks planning from starting.

---

### Gate 2 — Plan Review (before execution starts)

**When:** After `.planning/ROADMAP.md` is written, before GSD-2 auto mode.
**Who:** Human review required.
**Checks:**

- [ ] All milestones map back to requirements (traceability matrix complete)
- [ ] Each slice contains 1-7 tasks
- [ ] Each task fits in one 200K context window
- [ ] Must-haves are specified for every task
- [ ] Verification commands are configured in `.gsd/PREFERENCES.md`
- [ ] `specs/constitution.md` exists and has no placeholder text

**Block condition:** Any unchecked item above blocks GSD-2 `auto` mode.

---

### Gate 3 — Automated (runs on every GSD-2 task completion)

**When:** After every GSD-2 task execution, automatically.
**Who:** GSD-2 auto-verify (configured in `.gsd/PREFERENCES.md`).
**Commands run:**

```bash
npm test -- --coverage     # tests pass + 80% coverage threshold
npm run lint               # ESLint clean
npm run typecheck          # TypeScript strict mode clean
npm run build              # compiles without errors
```

**Block condition:** Any command exits non-zero → GSD-2 auto-retries up to 3 times, then pauses for human intervention.

---

### Gate 4 — Milestone Review (before next milestone starts)

**When:** After all slices in a milestone are marked complete.
**Who:** Human review required.
**Checks:**

- [ ] All acceptance criteria from `specs/requirements.md` verified
- [ ] DECISIONS.md updated with architectural decisions made during execution
- [ ] KNOWLEDGE.md updated with lessons learned
- [ ] Coverage report reviewed (`coverage/lcov-report/index.html`)
- [ ] Security review completed (run `/security` agent or `npm audit`)

**Command:**

```bash
gsd export --html           # generates HTML milestone report
```

**Block condition:** Any unchecked item blocks the next milestone from starting.

---

## Gate Command Reference

```bash
# Spec-Kit gates (run during Definition phase)
specify clarify             # Surface ambiguities before planning
specify analyze             # Cross-spec consistency check

# Automated gate (run on every task — also in CI)
npm test -- --coverage
npm run lint
npm run typecheck
npm run build

# GSD-2 reporting (run after each milestone)
gsd export --html

# GSD-2 forensics (run when a task is stuck)
gsd forensics
```
GATES_EOF

# ── .specify/memory/GOVERNANCE.md ────────────────────────────────────────────
write_file ".specify/memory/GOVERNANCE.md" <<'GOV_EOF'
# Governance Context

> This file is loaded by Spec-Kit's Memory Loader extension before every
> lifecycle command. It provides stable constitutional context to the LLM.
> Keep it SHORT and PRECISE — per arXiv:2602.11988, unnecessary context
> increases cost and reduces task success.

## Active Constitution

See: `specs/constitution.md`

## Active Quality Gates

See: `specs/quality-gates.md`

## Framework Handoff Rules

1. Spec-Kit owns the Definition phase. Output: `specs/*.md`.
2. GSD-v1 owns the Planning phase. Input: `specs/requirements.md`. Output: `.planning/ROADMAP.md`.
3. GSD-2 owns the Execution phase. Input: `.planning/ROADMAP.md`. Output: code + DECISIONS.md.
4. Only one framework is active at a time. No simultaneous operation.

## Non-Negotiables (constitutional cascade)

- TypeScript strict mode — `any` is never acceptable
- Tests before marking a task done — `npm test` must pass
- No secrets in source code or commit messages
- Minimal AGENTS.md — only requirements agents cannot discover themselves
GOV_EOF

# ── .specify/memory/ARCHITECTURE.md ──────────────────────────────────────────
write_file ".specify/memory/ARCHITECTURE.md" <<'ARCH_EOF'
# Architecture Context

> Loaded by Spec-Kit Memory Loader before `/speckit.plan` and `/speckit.implement`.
> Contains stable architectural decisions. Update after each milestone Gate 4 review.

## Layer Model

```
Layer 1 — Spec-Kit   specs/           Definition (what to build)
Layer 2 — GSD-v1     .planning/       Planning (how to guide building)
Layer 3 — GSD-2      .gsd/            Execution (how to build autonomously)
```

## Source Code Structure

```
src/
  api/          HTTP route handlers
  db/           Database layer (migrations + queries)
  lib/          Pure utilities (no side effects)
  middleware/   Request handlers (auth, logging, error)
  services/     Business logic (domain-specific)
  types/        TypeScript interfaces and enums
```

## Testing Strategy

| Layer | Location | Tools | Scope |
|-------|----------|-------|-------|
| Unit | tests/unit/ | Jest + ts-jest | Pure functions, utilities |
| Integration | tests/integration/ | Jest | Service + DB interaction |
| E2E | tests/e2e/ | Jest / Playwright | Full request/response cycles |

## Key Decisions

> Append decisions here after Gate 4 reviews. Do not overwrite — append only.

| Date | Decision | Rationale |
|------|----------|-----------|
| <!-- DATE --> | Initial architecture established | See docs/architecture.md |
ARCH_EOF

# =============================================================================
# PHASE 3 — LAYER 2: GSD-V1
# =============================================================================
layer "── Phase 3: GSD-v1 Layer ─────────────────────────────────────────────"
info "Creating context-engineering planning structure..."

make_dir .planning/research

# ── .planning/config.json ─────────────────────────────────────────────────────
write_file ".planning/config.json" <<'CONFIG_EOF'
{
  "project": "YOUR_PROJECT_NAME",
  "description": "One-sentence description of your project",
  "model": "claude-opus-4-5",
  "maxTokens": 200000,
  "parallelExecution": true,
  "constitutionFile": "specs/constitution.md",
  "requirementsFile": "specs/requirements.md",
  "verificationCommands": [
    "npm test -- --coverage",
    "npm run lint",
    "npm run typecheck",
    "npm run build"
  ],
  "gsd2RoadmapOutput": ".gsd/STATE.md",
  "hybridFramework": {
    "enabled": true,
    "specKitConstitution": "specs/constitution.md",
    "specKitRequirements": "specs/requirements.md",
    "specKitQualityGates": "specs/quality-gates.md",
    "handoffToGSD2": ".planning/ROADMAP.md"
  }
}
CONFIG_EOF

# ── .planning/PROJECT.md ──────────────────────────────────────────────────────
write_file ".planning/PROJECT.md" <<'PROJECT_EOF'
# Project Overview

> **GSD-v1 project context.** This file is loaded by every planning agent.
> Keep it accurate and concise — it sets the frame for all execution decisions.

## Project

**Name:** YOUR_PROJECT_NAME
**Purpose:** One-sentence description of what this project does and for whom.
**Owner:** YOUR_NAME / YOUR_TEAM
**Repository:** https://github.com/OWNER/REPO

## Current Status

| Phase | Status | Notes |
|-------|--------|-------|
| Definition (Spec-Kit) | 🔄 In progress | `specs/constitution.md` populated |
| Planning (GSD-v1) | ⬜ Not started | Waiting on Spec-Kit Gate 1 review |
| Execution (GSD-2) | ⬜ Not started | Waiting on GSD-v1 Gate 2 review |

## Architecture in One Paragraph

> Write 2-4 sentences describing the system. What does it do, what does it
> NOT do, and what are the key technical components? This paragraph is read
> by every execution agent.

## Key Constraints

- TypeScript strict mode — `any` is forbidden
- 80% test coverage enforced by CI
- All secrets managed via environment variables, never committed to git
- OWASP Top 10 is the security baseline

## Links

| Resource | Path |
|----------|------|
| Constitution | `specs/constitution.md` |
| Requirements | `specs/requirements.md` |
| Quality Gates | `specs/quality-gates.md` |
| Architecture | `docs/architecture.md` |
| Feasibility Study | `docs/FEASIBILITY_STUDY.md` |
PROJECT_EOF

# ── .planning/REQUIREMENTS.md ─────────────────────────────────────────────────
write_file ".planning/REQUIREMENTS.md" <<'PLANREQS_EOF'
# Planning Requirements

> **Source:** Derived from `specs/requirements.md` (Spec-Kit layer).
> This file is the GSD-v1 interpretation of those requirements — broken into
> planning phases. Edit `specs/requirements.md` first; then update this file.
>
> **Handoff rule:** Spec-Kit Gate 1 must be signed off before populating this.

---

## Phase Breakdown

### Phase 1 — [MILESTONE NAME]

**Maps to:** REQ-001, REQ-002 (from specs/requirements.md)
**Scope:** What will be built in this phase?
**Must-haves:**
- [ ] [Specific, verifiable outcome 1]
- [ ] [Specific, verifiable outcome 2]
- [ ] All verification commands pass (`npm test`, `npm run lint`, `npm run typecheck`)

**Out of scope for this phase:**
- [What is explicitly deferred to a later phase]

---

### Phase 2 — [MILESTONE NAME]

*(Fill in after Phase 1 is complete)*

---

## Traceability

| GSD-v1 Phase | Spec-Kit Requirement | GSD-2 Milestone |
|-------------|---------------------|----------------|
| Phase 1 | REQ-001 | M001 |

---

## Changes from Spec-Kit Output

> Log any intentional divergence from `specs/requirements.md` here.
> Each divergence requires explicit justification and must not violate the constitution.

| Spec-Kit Requirement | Change | Justification |
|---------------------|--------|--------------|
| *(none yet)* | — | — |
PLANREQS_EOF

# ── .planning/ROADMAP.md ──────────────────────────────────────────────────────
write_file ".planning/ROADMAP.md" <<'ROADMAP_EOF'
# Development Roadmap

> **GSD-v1 Planning Output → GSD-2 Execution Input.**
> This is the primary handoff document. GSD-2 reads this to initialise
> its milestone/slice/task hierarchy. Format must be compatible with
> GSD-2's `/gsd` command.
>
> **Rule:** Each phase here = one GSD-2 milestone (4-10 slices).
> Each slice = 1-7 tasks. Each task must fit in one 200K context window.

---

## Milestone M001 — [PHASE NAME]

**GSD-2 command:** `gsd /gsd auto --milestone M001`
**Maps to:** `.planning/REQUIREMENTS.md#phase-1`
**Target:** [TIMEFRAME]

### Slice S01 — [SLICE NAME]

> Description: What this slice delivers.

**Tasks:**

```xml
<task id="M001-S01-T01">
  <action>Implement [SPECIFIC ACTION]</action>
  <must_haves>
    <item>File `src/[path].ts` exists and compiles</item>
    <item>`npm test` passes with coverage ≥ 80%</item>
    <item>No `any` types in implementation</item>
  </must_haves>
  <artifact>src/[path].ts</artifact>
  <truth>tests/unit/[path].test.ts</truth>
  <verify>npm test -- --testPathPattern=[path]</verify>
</task>
```

### Slice S02 — [SLICE NAME]

> *(Add after S01 is complete)*

---

## Milestone M002 — [PHASE NAME]

*(Add after M001 Gate 4 review is complete)*

---

## Roadmap Status

| Milestone | Slices | Status | GSD-2 Mode |
|-----------|--------|--------|-----------|
| M001 | S01-S0N | ⬜ Not started | Step (`/gsd`) or Auto (`/gsd auto`) |

---

## GSD-v1 → GSD-2 Handoff Checklist

Before running `gsd /gsd auto`:

- [ ] This file has at least one complete milestone with ≥ 1 slice
- [ ] All task `<must_haves>` are specific and machine-verifiable
- [ ] `.gsd/PREFERENCES.md` verification commands configured
- [ ] `specs/quality-gates.md` Gate 2 checklist signed off
- [ ] `specs/constitution.md` has no placeholder text remaining
ROADMAP_EOF

# ── .planning/STATE.md ────────────────────────────────────────────────────────
write_file ".planning/STATE.md" <<'STATE_EOF'
# Planning State

> **Current snapshot of where we are in the planning phase.**
> Update this file at the start and end of each GSD-v1 planning session.

## Current Phase

**Active layer:** Spec-Kit (Definition)
**Next step:** Complete `specs/constitution.md` → run `/speckit.clarify` → Gate 1 review

## Completed

- [x] Base project scaffolded (`scripts/scaffold-project.sh`)
- [x] Hybrid framework scaffolded (`scripts/scaffold-hybrid-framework.sh`)
- [x] Feasibility study completed (`docs/FEASIBILITY_STUDY.md`)

## In Progress

- [ ] `specs/constitution.md` — fill in project identity and constraints
- [ ] `specs/requirements.md` — write feature requirements with acceptance criteria

## Blocked

*(None)*

## Decisions Made This Session

> Append decisions here. Format: `[DATE] [DECISION] — [RATIONALE]`

---

## Session Log

| Date | Action | Output |
|------|--------|--------|
| <!-- DATE --> | Hybrid framework scaffolded | All three layer directories created |
STATE_EOF

# ── .planning/DECISIONS.md ────────────────────────────────────────────────────
write_file ".planning/DECISIONS.md" <<'DECISIONS_EOF'
# Decision Log

> **Append-only.** Never overwrite or delete entries.
> Every architectural or design decision made during planning or execution
> is recorded here. This file is pre-loaded for every GSD-2 execution agent
> to prevent state amnesia across sessions.
>
> **Format:** ADR-lite (Decision, Context, Consequences).

---

## ADR-001 — Adopt Hybrid Framework (Spec-Kit + GSD-v1 + GSD-2)

**Date:** <!-- FILL IN -->
**Status:** Accepted
**Decision:** Implement the three-layer hybrid framework as the primary development methodology for this project.

**Context:** The team identified that LLM hallucinations were the primary source of rework in AI-assisted development. Research (Gloaguen et al., 2026; arXiv:2602.11988) confirmed that targeted, minimal context outperforms verbose context. Each framework targets a distinct hallucination root cause.

**Consequences:**
- (+) Structural hallucination reduction at requirements, planning, and execution levels
- (+) Clear handoff points between phases; no framework conflicts
- (-) Requires discipline to follow the sequential phase model
- (-) Setup overhead; not appropriate for projects < 6 weeks

**Reference:** `docs/FEASIBILITY_STUDY.md`

---

## ADR-002 — [YOUR NEXT DECISION TITLE]

**Date:** <!-- DATE -->
**Status:** Proposed | Accepted | Superseded
**Decision:** *(Fill in as architectural decisions are made)*

**Context:** *(What problem are you solving? What alternatives were considered?)*

**Consequences:**
- (+) *(benefits)*
- (-) *(trade-offs)*
DECISIONS_EOF

# ── .planning/KNOWLEDGE.md ────────────────────────────────────────────────────
write_file ".planning/KNOWLEDGE.md" <<'KNOWLEDGE_EOF'
# Project Knowledge Base

> **Append-only shared knowledge.** Facts about this codebase that agents
> need to do their jobs correctly. Updated after every Gate 4 review.
>
> Keep entries SHORT. Per arXiv:2602.11988, verbose knowledge bases hurt
> rather than help. Each entry should be one fact an agent could not infer
> from reading source files.

---

## Framework & Tooling Facts

- **Test runner:** Jest + ts-jest. Run with `npm test`. Coverage threshold: 80% branches + lines.
- **Linter:** ESLint with `@typescript-eslint`. Run with `npm run lint`. Auto-fix: `npm run lint -- --fix`.
- **Type checker:** `tsc --noEmit`. Run with `npm run typecheck`.
- **Build:** `tsc`. Run with `npm run build`. Output in `dist/`.
- **Formatter:** Prettier. Single quotes, no semicolons, 2-space indent.

## Codebase Conventions

- Functional patterns preferred. Use `class` only for domain entities.
- Descriptive names: `getUserById` not `getUser` + a comment.
- No `any`. No `@ts-ignore` without an explanation comment.
- Validate at system boundaries only. No defensive checks inside pure functions.

## Known Constraints

> Add constraints discovered during execution that aren't obvious from specs.

*(None yet — append after first execution milestone)*

---

## Lessons Learned

> Append after each milestone Gate 4 review.

| Date | Lesson | Phase |
|------|--------|-------|
| <!-- DATE --> | Initial project setup complete | Definition |
KNOWLEDGE_EOF

# =============================================================================
# PHASE 4 — LAYER 3: GSD-2
# =============================================================================
layer "── Phase 4: GSD-2 Layer ──────────────────────────────────────────────"
info "Creating autonomous execution state structure..."

make_dir .gsd

# ── .gsd/PREFERENCES.md ───────────────────────────────────────────────────────
write_file ".gsd/PREFERENCES.md" <<'PREFS_EOF'
# GSD-2 Preferences

> Configures GSD-2's autonomous execution behaviour for this project.
> Changes here take effect on the next `gsd` invocation.
>
> For full documentation: https://github.com/gsd-build/gsd-2

---

## Models

> Assign different models to different phases for cost/quality balance.
> Supported: claude-opus-4-5, claude-sonnet-4-5, gpt-4o, gemini-2.5-pro

```yaml
models:
  planning:      claude-opus-4-5        # milestones + slices + roadmap
  research:      claude-opus-4-5        # scout + researcher agents
  execution:     claude-sonnet-4-5      # worker, js-pro, ts-pro agents
  verification:  claude-sonnet-4-5      # post-task verification
```

---

## Budget Ceiling

> GSD-2 tracks cost per task, slice, and milestone. Set ceilings to prevent
> runaway spending on stuck tasks.

```yaml
budget:
  maxCostPerTask:      0.50     # USD; pause and report if exceeded
  maxCostPerSlice:     2.00     # USD
  maxCostPerMilestone: 10.00    # USD
  currency: USD
```

---

## Verification Commands

> Run after EVERY task completion. All must exit 0 for the task to be
> marked complete. Non-zero exit → auto-retry up to maxRetries times.
> These implement specs/quality-gates.md Gate 3.

```yaml
verification:
  commands:
    - npm test -- --coverage
    - npm run lint
    - npm run typecheck
    - npm run build
  autoFix: true                 # retry with auto-fix instructions on failure
  maxRetries: 3                 # attempts before pausing for human review
```

---

## Execution Behaviour

```yaml
execution:
  stuckDetection: true          # sliding-window detector for repeated patterns
  stuckThreshold: 3             # consecutive identical dispatches = stuck
  crashRecovery: true           # synthesise briefing and resume on crash
  worktreeIsolation: false      # set true if using git worktrees per milestone
  parallelSlices: false         # set true only when slices have no shared state
```

---

## Context Loading

> Files pre-loaded into every execution agent context.
> Keep this list MINIMAL per arXiv:2602.11988.

```yaml
context:
  always:
    - AGENTS.md                         # project-wide agent boundaries
    - .planning/DECISIONS.md            # prevent state amnesia
    - .planning/KNOWLEDGE.md            # project-specific facts
    - specs/constitution.md             # non-negotiable values
  perMilestone:
    - .planning/ROADMAP.md              # task plans for active milestone
    - .specify/memory/ARCHITECTURE.md   # architecture context
```

---

## Reporting

```yaml
reporting:
  htmlReportOnMilestoneComplete: true   # gsd export --html
  summaryOnTaskComplete: true           # write SUMMARY.md per completed task
  costTrackingEnabled: true
```

---

## Hybrid Framework Integration

```yaml
hybrid:
  constitutionRequired: true            # block auto mode if specs/constitution.md
                                        # contains placeholder text
  gate2ChecklistRequired: true          # block auto mode if Gate 2 unchecked
  roadmapSource: .planning/ROADMAP.md   # GSD-v1 handoff document
  decisionsLog: .planning/DECISIONS.md  # append-only decision registry
  knowledgeBase: .planning/KNOWLEDGE.md # project knowledge
```
PREFS_EOF

# =============================================================================
# PHASE 5 — GITIGNORE UPDATES
# =============================================================================
layer "── Phase 5: .gitignore Updates ─────────────────────────────────────────"

GITIGNORE_ENTRY_HYBRID="
# ── Hybrid Framework (Spec-Kit + GSD-v1 + GSD-2) ─────────────────────────────
.gsd/gsd.db             # GSD-2 SQLite state — generated, not committed
.gsd/*.lock             # GSD-2 lock files
.gsd/reports/           # GSD-2 HTML reports — generated artifacts
.specify/cache/         # Spec-Kit cache
"

if grep -q "GSD-2 SQLite state" .gitignore 2>/dev/null; then
  warn ".gitignore already has hybrid framework entries — skipping"
else
  printf '%s\n' "$GITIGNORE_ENTRY_HYBRID" >> .gitignore
  success "Updated .gitignore with hybrid framework patterns"
fi

# =============================================================================
# PHASE 6 — SUMMARY
# =============================================================================
layer "── Summary ────────────────────────────────────────────────────────────"
echo
echo -e "${GREEN}${BOLD}╔══════════════════════════════════════════════════════════╗${RESET}"
echo -e "${GREEN}${BOLD}║   Hybrid Framework scaffold complete!                    ║${RESET}"
echo -e "${GREEN}${BOLD}╚══════════════════════════════════════════════════════════╝${RESET}"
echo
echo -e "${BOLD}Files created:${RESET}"
echo
echo -e "  ${BLUE}Layer 1 — Spec-Kit (Definition)${RESET}"
echo -e "    specs/constitution.md          ← Fill in project identity + values"
echo -e "    specs/requirements.md          ← Write feature requirements"
echo -e "    specs/quality-gates.md         ← Gate definitions (automated + manual)"
echo -e "    specs/features/                ← Gherkin feature files"
echo -e "    .specify/memory/GOVERNANCE.md  ← Constitutional context for Spec-Kit"
echo -e "    .specify/memory/ARCHITECTURE.md ← Architecture context"
echo
echo -e "  ${BLUE}Layer 2 — GSD-v1 (Planning)${RESET}"
echo -e "    .planning/config.json          ← GSD-v1 configuration"
echo -e "    .planning/PROJECT.md           ← Project overview for planning agents"
echo -e "    .planning/REQUIREMENTS.md      ← Planning-level requirements"
echo -e "    .planning/ROADMAP.md           ← Milestone/slice/task plans"
echo -e "    .planning/STATE.md             ← Current planning state"
echo -e "    .planning/DECISIONS.md         ← Append-only decision log"
echo -e "    .planning/KNOWLEDGE.md         ← Project knowledge base"
echo -e "    .planning/research/            ← Research artifacts"
echo
echo -e "  ${BLUE}Layer 3 — GSD-2 (Execution)${RESET}"
echo -e "    .gsd/PREFERENCES.md            ← Model, budget, verification config"
echo
echo -e "${BOLD}Next steps:${RESET}"
echo
echo -e "  ${CYAN}1. Fill in specs/constitution.md${RESET}"
echo -e "     Replace all placeholder text with your real project values."
echo -e "     This is the most important step — everything downstream cascades from it."
echo
echo -e "  ${CYAN}2. Write specs/requirements.md${RESET}"
echo -e "     Add Gherkin-style acceptance criteria for each feature."
echo
echo -e "  ${CYAN}3. Run Spec-Kit gate 1${RESET}"
echo -e "     specify clarify                  # surface ambiguities"
echo -e "     specify analyze                  # cross-spec consistency check"
echo -e "     Review specs/quality-gates.md Gate 1 checklist."
echo
echo -e "  ${CYAN}4. Run GSD-v1 planning phase${RESET}"
echo -e "     npx get-shit-done-cc@latest      # or via /gsd-discuss-phase in your IDE"
echo -e "     Populate .planning/ROADMAP.md with milestones, slices, and XML task plans."
echo
echo -e "  ${CYAN}5. Review Gate 2 checklist (specs/quality-gates.md)${RESET}"
echo -e "     Sign off before starting GSD-2 auto mode."
echo
echo -e "  ${CYAN}6. Run GSD-2 execution${RESET}"
echo -e "     gsd                              # step-by-step (recommended first time)"
echo -e "     gsd auto                         # autonomous (after Gate 2 sign-off)"
echo
echo -e "  ${CYAN}See docs/HYBRID_FRAMEWORK_GUIDE.md for full integration guide.${RESET}"
echo -e "  ${CYAN}See docs/FEASIBILITY_STUDY.md for the research evidence base.${RESET}"
echo
