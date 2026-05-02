# GSD-2: Comprehensive Technical Guide

**Last Updated:** May 2026
**Source:** Official GSD-2 Repository (https://github.com/gsd-build/gsd-2)
**Version:** v2.78.1 (Latest)

---

## Table of Contents

1. [Official Definition & Purpose](#1-official-definition--purpose)
2. [Core Architecture](#2-core-architecture)
3. [Workflow/Phases](#3-workflowphases)
4. [Configuration](#4-configuration)
5. [CLI Commands](#5-cli-commands)
6. [Integration Points with AI Tools](#6-integration-points-with-ai-tools)
7. [Key Files & Structure](#7-key-files--structure)
8. [Best Practices](#8-best-practices)
9. [Example Workflows](#9-example-workflows)
10. [Relationship to Spec-Kit](#10-relationship-to-spec-kit)

---

## 1. Official Definition & Purpose

### What is GSD-2?

**GSD-2** (Get Shit Done 2) is **a TypeScript application that transforms AI agents into autonomous, long-running project builders**. It evolved from the original GSD v1 (a prompt framework for Claude Code) into a real engineering system with state management, context control, and crash recovery.

**Key Evolution from v1 → v2:**

| Aspect | v1 | v2 |
|--------|----|----|
| **Runtime** | Claude Code slash commands (prompt framework) | Standalone CLI via Pi SDK |
| **Context** | Hope the LLM doesn't fill up | Fresh session per task, programmatic control |
| **Automation** | "Auto mode" was LLM calling itself in a loop | State machine reading `.gsd/` database |
| **Crash Recovery** | None | Lock files + session forensics |
| **Git** | LLM writes git commands (unreliable) | Worktree isolation, sequential commits, squash merge |
| **Cost Tracking** | None | Per-unit token/cost ledger with dashboard |
| **Stuck Detection** | None | Sliding-window pattern analysis |
| **Verification** | Manual | Automated lint/test with auto-fix retries |

### Core Purpose

**One command. Walk away. Come back to a built project with clean git history.**

```bash
npm install -g gsd-pi && gsd
```

GSD-2 enables:
- **Autonomous milestone execution** — entire features built without human intervention
- **Clean git history** — squash-merged commits derived from task summaries
- **Cost transparency** — per-unit token/cost breakdown with budget ceilings
- **Context precision** — fresh session per task with only relevant files pre-loaded
- **Crash resilience** — recovery from crashes mid-execution
- **Adaptive planning** — roadmap reassessment after each slice based on learnings

---

## 2. Core Architecture

### System Components

```
gsd (CLI binary)
  └─ loader.ts          Sets PI_PACKAGE_DIR, GSD env vars, dynamic-imports cli.ts
      └─ cli.ts         Wires SDK managers, loads extensions, starts InteractiveMode
          ├─ headless.ts     Headless orchestrator (spawns RPC child, auto-responds)
          ├─ onboarding.ts   First-run setup wizard (LLM provider + tool keys)
          ├─ wizard.ts       Env hydration from stored auth.json credentials
          ├─ app-paths.ts    ~/.gsd/agent/, ~/.gsd/sessions/, auth.json
          └─ resource-loader.ts  Syncs bundled extensions + agents
              └─ src/resources/
                  ├─ extensions/gsd/    Core GSD extension (auto, state, commands)
                  ├─ extensions/...     23 supporting extensions
                  ├─ agents/            scout, researcher, worker, js-pro, ts-pro
                  └─ GSD-WORKFLOW.md    Manual bootstrap protocol
```

### Key Design Principles

#### 1. **DB-Authoritative Project State**
- SQLite database (`gsd.db`) at project root is the **single source of truth**
- Stores: milestones, slices, tasks, requirements, decisions, summaries, completion status
- `.gsd/` markdown files are **rendered projections** for review, prompts, git history
- On crash, the database survives; markdown is regenerated from DB state
- **No silent markdown fallback** unless explicitly enabled with `GSD_ALLOW_MARKDOWN_DERIVE_FALLBACK=1`

#### 2. **Two-File Loader Pattern**
```typescript
// loader.ts — sets env vars, ZERO SDK imports
process.env.PI_PACKAGE_DIR = path.join(process.env.GSD_HOME, 'pkg')
process.env.GSD_VERSION = '2.78.1'
// dynamic import ensures PI_PACKAGE_DIR is set BEFORE SDK code evaluates
const { main } = require('./cli.ts')

// cli.ts — NOW safe to static-import SDK
import { Pi } from 'pi-sdk'
```
This prevents collision between GSD's `src/` and Pi's theme resolution.

#### 3. **Fresh Session Per Unit**
Every dispatch creates a new agent session:
- Clean 200k-token context window (no accumulated garbage)
- Pre-inlined prompt with only what the LLM needs (task plan, prior summaries, roadmap excerpt, decisions)
- No in-memory state survives across sessions
- Enables crash recovery and multi-terminal steering

#### 4. **Lazy Provider Loading**
- LLM provider SDKs (Anthropic, OpenAI, Google, etc.) are lazy-loaded on first use
- Reduces cold-start time significantly — only the provider you use gets loaded

#### 5. **Always-Overwrite Sync**
- Bundled extensions and agents sync to `~/.gsd/agent/` on **every launch** (not just first run)
- `npm update -g` takes effect immediately

### Dispatch Pipeline (Auto Mode)

```
1. Derive project state from SQLite database
2. Determine next unit type and ID (research, plan, execute, complete, reassess, etc.)
3. Classify task complexity → select model tier (light/standard/heavy)
4. Apply budget pressure adjustments (50%, 75%, 90% thresholds)
5. Check routing history for adaptive adjustments
6. Dynamic model routing → select cheapest model for tier
7. Resolve effective model (with fallbacks)
8. Check pending captures → triage if needed
9. Build dispatch prompt (with inline level compression)
10. Create fresh agent session
11. Inject prompt and let LLM execute
12. On completion: snapshot metrics, verify artifacts, persist state
13. Loop to step 1
```

### Bundled Extensions (24 Total)

| Category | Extensions |
|----------|------------|
| **Core** | GSD (workflow engine, auto mode, commands, dashboard) |
| **Web** | Browser Tools (Playwright), Search the Web (Brave/Tavily/Jina), Google Search (Gemini), Context7 (docs) |
| **Execution** | Background Shell, Async Jobs, Subagent, GitHub, Mac Tools |
| **Integration** | MCP Client, Remote Questions (Slack/Discord/Telegram), GitHub Sync, Ollama |
| **Input** | Voice (speech-to-text), Ask User Questions, Secure Env Collect |
| **Developer** | LSP, Language Server Protocol integrations |
| **System** | Slash Commands, Universal Config, AWS Auth, Claude Code CLI, cmux |

### Bundled Agents (5 Specialized)

| Agent | Role |
|-------|------|
| **Scout** | Fast codebase recon — compressed context for handoff |
| **Researcher** | Web research — finds and synthesizes current information |
| **Worker** | General-purpose execution in an isolated context window |
| **JavaScript Pro** | JavaScript-specialized execution and debugging |
| **TypeScript Pro** | TypeScript-specialized execution and debugging |

### Native Engine (Performance-Critical, Rust N-API)

- **grep** — ripgrep-backed content search
- **glob** — gitignore-aware file discovery
- **ps** — cross-platform process tree management
- **highlight** — syntect-based syntax highlighting
- **ast** — structural code search via ast-grep
- **diff** — fuzzy text matching and unified diff generation
- **text** — ANSI-aware text measurement and wrapping
- **html** — HTML-to-Markdown conversion
- **image** — decode, encode, resize images
- **fd** — fuzzy file path discovery
- **clipboard** — native clipboard access
- **git** — libgit2-backed git read operations
- **parser** — GSD file parsing and frontmatter extraction

---

## 3. Workflow/Phases

### The Loop (Per Slice)

```
Plan (with integrated research)
  → Execute (per task)
  → Complete
  → Reassess Roadmap
  → Next Slice
                                ↓ (all slices done)
                        Validate Milestone → Complete Milestone
```

### Phase Breakdown

#### **Plan Phase**
- **Scouts the codebase** — discovers structure, dependencies, patterns
- **Researches relevant docs** — web research, framework documentation
- **Decomposes slice into tasks** — each task must fit in one context window
- **Defines must-haves** — mechanically verifiable outcomes (artifacts, truths, key links)
- **Output:** `S##-PLAN.md` with task list and verification criteria

#### **Execute Phase**
- **Runs each task in fresh context** — only relevant files pre-loaded
- **Per-task:** fresh session, complete isolation, focused prompt
- **Runs configured verification commands** (e.g., `npm run lint`, `npm run test`)
- **Auto-fix retries** — agent sees verification output and attempts fixes
- **Output:** `T##-SUMMARY.md` with YAML frontmatter + narrative

#### **Complete Phase**
- **Writes slice summary** — what was built, decisions made, learnings
- **Generates UAT script** — user acceptance test for human validation
- **Marks roadmap** — updates `M###-ROADMAP.md` with completion status
- **Commits to git** — with meaningful message derived from task summaries

#### **Reassess Roadmap Phase**
- **Checks if plan still makes sense** — given what was learned during execution
- **Reorders/adds/removes slices** — if new information changes priorities
- **Optional** — skipped with `budget` or `balanced` token profiles

#### **Validate Milestone Phase**
- **Reconciliation gate** — runs after all slices complete
- **Compares roadmap success criteria against actual results**
- **Catches gaps** before sealing the milestone
- **Prevents false "milestone complete"** states

### Project Hierarchy

```
Milestone  →  a shippable version (4-10 slices)
  Slice    →  one demoable vertical capability (1-7 tasks)
    Task   →  one context-window-sized unit of work
```

**Iron Rule:** A task must fit in one context window. If it can't, it's two tasks.

### Deep Planning Mode (Optional)

Enable with `planning_depth: deep` in preferences.

```
Workflow Preferences
  → Project Context (PROJECT.md)
  → Requirements Discussion (REQUIREMENTS.md)
  → Research Decision (research-decision.json)
  → [Optional] Project Research (STACK.md, FEATURES.md, ARCHITECTURE.md, PITFALLS.md)
  → Milestone Context/Roadmap
```

Creates structured project understanding before milestone-level planning.

---

## 4. Configuration

### Preferences Files

**Locations:**
- **Global:** `~/.gsd/PREFERENCES.md` (all projects)
- **Project:** `.gsd/PREFERENCES.md` (current project only)

**Format:** YAML frontmatter in markdown

```yaml
---
version: 1

# Model selection (per-phase)
models:
  research: claude-sonnet-4-6
  planning:
    model: claude-opus-4-6
    fallbacks:
      - openrouter/z-ai/glm-5
  execution: claude-sonnet-4-6
  execution_simple: claude-haiku-4-5-20250414
  completion: claude-sonnet-4-6

# Token optimization
token_profile: balanced  # budget | balanced | quality

# Timeouts
auto_supervisor:
  soft_timeout_minutes: 20
  idle_timeout_minutes: 10
  hard_timeout_minutes: 30

# Budget
budget_ceiling: 50.00
budget_enforcement: pause  # warn | pause | halt

# Verification
verification_commands:
  - npm run lint
  - npm run test
verification_auto_fix: true
verification_max_retries: 2

# Git
git:
  isolation: none           # none | worktree | branch
  auto_push: false
  merge_strategy: squash
  commit_docs: true
  manage_gitignore: true

# Skills
skill_discovery: suggest    # auto | suggest | off
always_use_skills:
  - debug-like-expert
skill_rules:
  - when: task involves authentication
    use: [clerk]

# Advanced
planning_depth: light       # light | deep
unique_milestone_ids: true  # avoid collisions in teams
auto_report: true           # generate HTML reports
---
```

### Key Settings

| Setting | Type | Purpose |
|---------|------|---------|
| `models.*` | string or object | Per-phase model selection with optional fallbacks |
| `token_profile` | string | `budget`, `balanced`, or `quality` — coordinates model tier, phase skipping, context compression |
| `auto_supervisor.*` | object | Soft/idle/hard timeout thresholds |
| `budget_ceiling` | number | USD ceiling — auto mode pauses when reached |
| `verification_commands` | array | Shell commands to run after task execution |
| `verification_auto_fix` | boolean | Auto-retry on verification failures (default: true) |
| `git.isolation` | string | `none`, `worktree`, or `branch` — git workflow mode |
| `skill_discovery` | string | `auto`, `suggest`, or `off` |
| `planning_depth` | string | `light` or `deep` — enable staged project discovery |
| `unique_milestone_ids` | boolean | Generate unique milestone names with random suffix |
| `reactive_execution` | object | Enable parallel task dispatch within slices |

### Global API Keys

**Stored in:** `~/.gsd/agent/auth.json`
**Manage with:** `/gsd config`

**Supported keys:**
- `TAVILY_API_KEY` — web search (non-Anthropic models)
- `BRAVE_API_KEY` — web search (non-Anthropic models)
- `CONTEXT7_API_KEY` — library/framework documentation
- `JINA_API_KEY` — page extraction

### Agent Instructions

Place `AGENTS.md` file in any directory for persistent behavioral guidance:

```markdown
# AGENTS.md

## Coding Standards
- Use TypeScript strict mode
- Prefer functional patterns over classes
- Single quotes, no semicolons, 2-space indent

## Architectural Decisions
- API follows RESTful conventions
- Frontend uses Vite + vanilla JS (minimal deps)
- SQLite for local persistence

## Domain Terminology
- "Milestone" = shippable version
- "Slice" = vertical capability
- "Task" = one context-window-sized unit

## Workflow Preferences
- Always run lint + test before committing
- Write detailed commit messages (not "fix bug")
```

Pi core loads `AGENTS.md` automatically (with `CLAUDE.md` as fallback) at both user and project levels.

---

## 5. CLI Commands

### Core Commands

| Command | Description |
|---------|------------|
| `/gsd` | **Step mode** — execute one unit at a time, pause between each with wizard |
| `/gsd next` | Explicit step mode (same as bare `/gsd`) |
| `/gsd auto` | **Autonomous mode** — research, plan, execute, commit, repeat until milestone done |
| `/gsd new-project [--deep]` | Bootstrap a project with staged discovery |
| `/gsd quick` | Execute a quick task, skip planning overhead |
| `/gsd stop` | Stop auto mode gracefully |

### Steering Commands (Work Alongside Auto Mode)

| Command | Description |
|---------|------------|
| `/gsd discuss` | Discuss architecture and decisions (doesn't stop auto) |
| `/gsd steer` | Hard-steer plan documents during execution |
| `/gsd rethink` | Conversational project reorganization |
| `/gsd status` | Real-time progress dashboard (`Ctrl+Alt+G` also works) |
| `/gsd queue` | Queue future milestones for execution |
| `/gsd capture "..."` | Fire-and-forget thought capture (auto-triaged between tasks) |

### Workflow Commands

| Command | Description |
|---------|------------|
| `/gsd migrate` | Migrate v1 `.planning` directory to `.gsd` format |
| `/gsd mode` | Switch workflow mode (solo/team) with coordinated defaults |
| `/gsd workflow` | List, run, install, info, validate workflow plugins |
| `/gsd start <template>` | Launch bundled workflow template (bugfix, release, etc.) |
| `/gsd prefs` | Model selection, timeouts, budget ceiling, preferences wizard |

### Diagnostics Commands

| Command | Description |
|---------|------------|
| `/gsd forensics` | Full-access GSD debugger — anomaly detection, unit traces, metrics, LLM-guided investigation |
| `/gsd doctor` | Runtime health checks — surfaces issues across widget, visualizer, reports |
| `/gsd logs` | Browse activity, debug, and metrics logs |
| `/gsd keys` | API key manager — list, add, remove, test, rotate, doctor |
| `/gsd help` | Categorized command reference |

### Reporting & Export

| Command | Description |
|---------|------------|
| `/gsd export --html` | Generate HTML report for current/completed milestone |
| `/gsd export --html --all` | Generate reports for all milestones |
| `/gsd visualizer` | Open workflow visualizer — progress, deps, metrics, timeline tabs |

### Git & Worktree

| Command | Description |
|---------|------------|
| `/worktree` (`/wt`) | Git worktree lifecycle — create, switch, merge, remove |
| `/gsd worktree` (`/gsd wt`) | TUI worktree management — list, merge, clean, remove |
| `/gsd cleanup` | Archive phase directories from completed milestones |

### Voice & System

| Command | Description |
|---------|------------|
| `/voice` | Toggle real-time speech-to-text (macOS, Linux) |
| `/exit` | Graceful shutdown — save session state |
| `/kill` | Kill GSD process immediately |
| `/clear` | Start a new session (alias for `/new`) |

### Keyboard Shortcuts

| Shortcut | Action |
|----------|--------|
| `Ctrl+Alt+G` | Toggle dashboard overlay |
| `Ctrl+Alt+V` | Toggle voice transcription |
| `Ctrl+Alt+B` | Show background shell processes |
| `Alt+V` | Paste clipboard image (macOS) |
| `Escape` | Pause auto mode (resume with `/gsd auto`) |

### Headless & CI/CD

| Command | Description |
|---------|------------|
| `gsd headless [cmd]` | Run `/gsd` commands without TUI (CI, cron, scripts) |
| `gsd headless auto --timeout 600000` | Run auto mode in CI with timeout |
| `gsd headless new-milestone --context spec.md --auto` | Create and execute milestone end-to-end |
| `gsd headless next` | One unit at a time (cron-friendly) |
| `gsd headless query` | Instant JSON snapshot — state, next dispatch, costs (no LLM, ~50ms) |
| `gsd --continue` (`-c`) | Resume the most recent session |
| `gsd --worktree` (`-w`) | Launch isolated worktree session for active milestone |
| `gsd sessions` | Interactive session picker — browse and resume any saved session |

### Config & Setup

| Command | Description |
|---------|------------|
| `gsd config` | Re-run setup wizard (LLM provider + tool keys) |
| `gsd update` | Update GSD to the latest version |
| `gsd login` | Select and authenticate with LLM provider |
| `/model` | Switch models or view auth mode |
| `/mcp` | MCP server status and connectivity |

---

## 6. Integration Points with AI Tools

### AI Coding Agents Supported (20+)

**First-Class (Built-In):**
- Anthropic (Claude Code, Claude.ai)
- OpenAI (ChatGPT, o1, GPT-4, etc.)
- Google Gemini (Gemini 2.0, Gemini Pro)
- GitHub Copilot
- Amazon Bedrock
- Azure OpenAI
- OpenRouter (100+ models via single API)
- Groq
- Cerebras
- Mistral
- xAI (Grok)
- HuggingFace Inference API
- Ollama (local models)
- Vercel AI Gateway

**Per-Phase Model Selection:**
```yaml
models:
  research: openrouter/deepseek/deepseek-r1  # fast research
  planning:
    model: claude-opus-4-6                   # expensive, high-quality planning
    fallbacks:
      - openrouter/z-ai/glm-5
  execution: claude-sonnet-4-6               # balanced
  completion: claude-haiku-4-5-20250414      # cheap, fast completion
```

### Extension Ecosystem

**Installed via:** `gsd extensions install <name>`

#### Marketplace Extensions (100+)
- **Process Orchestration:** MAQA (multi-agent QA), Conduct, Fleet, Squad Bridge
- **Code Review:** Review, Staff Review, Security Review, Red Team
- **Integration:** Jira, Azure DevOps, GitHub Issues, Linear, Trello, Confluence
- **Visibility:** Status Report, Project Health, What-if Analysis, Token Analyzer
- **Workflow:** Bugfix, Ship Release, Plan Review Gate, Checkpoint
- **Testing:** SpecTest, QA Testing, Verify Tasks

#### Example: Installing an Extension
```bash
specify extension add spec-kit-maqa-ext
```

### MCP Server Integration

GSD connects to external MCP servers via `.mcp.json` or `.gsd/mcp.json`:

```json
{
  "mcpServers": {
    "my-server": {
      "type": "stdio",
      "command": "/absolute/path/to/python3",
      "args": ["/absolute/path/to/server.py"],
      "env": {
        "API_URL": "http://localhost:8000"
      }
    }
  }
}
```

Verify: `mcp_discover(server="my-server")`

### Remote Questions (Async Human Input)

Route decisions to Slack, Discord, or Telegram for headless auto mode:

```yaml
remote_questions:
  channel: slack
  channel_id: "C1234567890"
  timeout_minutes: 15
  poll_interval_seconds: 10
```

**Telegram Commands During Auto Mode:**
- `/pause` — pause after current unit
- `/resume` — continue auto mode
- `/status` — current milestone and cost
- `/progress` — roadmap overview
- `/log [n]` — last n activity entries

### GitHub Sync

Auto-sync milestones, slices, and tasks to GitHub Issues:

```yaml
github:
  enabled: true
  repo: "owner/repo"
  labels: [gsd, auto-generated]
  project: "Project ID"
```

**Commands:**
- `/github-sync bootstrap` — initial setup
- `/github-sync status` — show sync mapping

---

## 7. Key Files & Structure

### Project Root Structure

```
project/
├── .gsd/                              # GSD runtime state (local, .gitignore)
│   ├── gsd.db                         # SQLite database (AUTHORITATIVE)
│   ├── gsd.db-wal / -shm              # WAL sidecars
│   ├── auto.lock                      # Crash detection sentinel (PID lock)
│   ├── state-manifest.json            # Workflow state for recovery
│   ├── STATE.md                       # Quick-glance dashboard (derived from DB)
│   ├── metrics.json                   # Per-developer token/cost accumulator
│   ├── activity/                      # Raw JSONL session dumps (crash recovery)
│   ├── runtime/                       # Unit execution records
│   │   └── research-decision.json     # Deep-mode marker (research | skip)
│   ├── journal/                       # Daily-rotated event journal
│   ├── worktrees/                     # Git worktree working copies
│   ├── parallel/                      # Parallel orchestration IPC & worker status
│   ├── reports/                       # Generated HTML reports
│   │
│   # SHARED ARTIFACTS (commit to git)
│   ├── PREFERENCES.md                 # Project preferences (team configs)
│   ├── PROJECT.md                     # Living doc — what project is RIGHT NOW
│   ├── REQUIREMENTS.md                # Project-level capability contract
│   ├── DECISIONS.md                   # Append-only register of arch decisions
│   ├── KNOWLEDGE.md                   # Cross-session rules, patterns, lessons
│   ├── RUNTIME.md                     # Runtime context (endpoints, env vars)
│   ├── research/
│   │   ├── STACK.md                   # Deep-mode: technology stack
│   │   ├── FEATURES.md                # Deep-mode: feature norms
│   │   ├── ARCHITECTURE.md            # Deep-mode: architecture
│   │   └── PITFALLS.md                # Deep-mode: pitfalls
│   │
│   # MILESTONES
│   ├── milestones/
│   │   ├── M001-abc123/               # Milestone folder (if unique_milestone_ids: true)
│   │   │   ├── M001-ROADMAP.md        # Slice plan with checkboxes
│   │   │   ├── M001-CONTEXT.md        # User decisions from discuss phase
│   │   │   ├── M001-RESEARCH.md       # Codebase research
│   │   │   ├── S01-PLAN.md            # Slice 01 task decomposition
│   │   │   ├── S01-UAT.md             # Slice 01 UAT script
│   │   │   ├── T01-PLAN.md            # Task 01 plan + verification criteria
│   │   │   └── T01-SUMMARY.md         # Task 01 YAML frontmatter + narrative
│   │   └── M002-xyz789/
│   │       └── ...
│   │
│   ├── completed-units*.json          # Prevents re-running completed units
│   └── continue.md                    # Session-specific interrupted-work marker
│
├── .gitignore                         # Excludes runtime state
├── AGENTS.md                          # Coding standards, arch guidance
├── CLAUDE.md                          # Fallback for AGENTS.md
├── package.json
├── tsconfig.json
└── src/
    └── (your project files)
```

### Suggested .gitignore

```bash
# ── GSD: Runtime / Ephemeral (per-developer, per-session) ──────────────────

# Crash detection sentinel
.gsd/auto.lock

# Auto-mode dispatch tracker
.gsd/completed-units*.json

# State manifest
.gsd/state-manifest.json

# Derived state projection (regenerated from DB)
.gsd/STATE.md

# Per-developer token/cost accumulator
.gsd/metrics.json

# Raw JSONL session dumps
.gsd/activity/

# Unit execution records
.gsd/runtime/

# Git worktree working copies
.gsd/worktrees/

# Parallel orchestration IPC
.gsd/parallel/

# SQLite database and WAL (local only)
.gsd/gsd.db*

# Daily-rotated event journal
.gsd/journal/

# Doctor run history
.gsd/doctor-history.jsonl

# Workflow event log
.gsd/event-log.jsonl

# Generated HTML reports (regenerable via /gsd export --html)
.gsd/reports/

# Session-specific interrupted-work markers
.gsd/milestones/**/continue.md
.gsd/milestones/**/*-CONTINUE.md

# ── GSD: Shared Artifacts (COMMIT TO GIT) ────────────────────────────────

# DO NOT ignore these — they're team-readable project context:
!.gsd/PREFERENCES.md
!.gsd/PROJECT.md
!.gsd/REQUIREMENTS.md
!.gsd/DECISIONS.md
!.gsd/KNOWLEDGE.md
!.gsd/RUNTIME.md
!.gsd/research/
!.gsd/milestones/
```

### File Purpose Reference

| File | Purpose | Scope |
|------|---------|-------|
| `gsd.db` | Authoritative runtime state | Local (ignore) |
| `STATE.md` | Quick-glance dashboard | Local (ignore) |
| `PROJECT.md` | Living doc — vision, users, constraints | Shared (commit) |
| `REQUIREMENTS.md` | Capability contract (R### requirements) | Shared (commit) |
| `DECISIONS.md` | Append-only arch decision register | Shared (commit) |
| `KNOWLEDGE.md` | Cross-session rules, patterns, learnings | Shared (commit) |
| `RUNTIME.md` | API endpoints, env vars, services | Shared (commit) |
| `M###-ROADMAP.md` | Slice plan with checkboxes, risk levels | Shared (commit) |
| `M###-CONTEXT.md` | User decisions from discuss phase | Shared (commit) |
| `S##-PLAN.md` | Slice task decomposition + must-haves | Shared (commit) |
| `S##-UAT.md` | Slice acceptance test script | Shared (commit) |
| `T##-PLAN.md` | Task plan + verification criteria | Shared (commit) |
| `T##-SUMMARY.md` | Task outcome (YAML frontmatter + narrative) | Shared (commit) |

---

## 8. Best Practices

### Workflow Patterns

#### **Pattern 1: Two-Terminal Steering**

**Terminal 1 — Let It Build:**
```bash
gsd
/gsd auto
```

**Terminal 2 — Steer While It Works:**
```bash
gsd
/gsd discuss      # talk through architecture
/gsd status       # check progress
/gsd queue        # queue next milestone
```

Both terminals read/write the same `.gsd/` files. Steering decisions are picked up at the next phase boundary — **no need to stop auto mode**.

#### **Pattern 2: Headless Overnight Execution**

```bash
# Run auto mode in CI with crash auto-restart
gsd headless auto --timeout 600000 --max-restarts 3

# Or one unit at a time for cron
gsd headless next
```

Crashes trigger exponential backoff (5s → 10s → 30s cap). Combined with crash recovery, enables true "fire and forget" overnight execution.

#### **Pattern 3: Team Collaboration with Unique Milestone IDs**

```yaml
# .gsd/PREFERENCES.md
---
version: 1
unique_milestone_ids: true
---
```

Generates milestone names like `M001-ush8s3` instead of `M001`, avoiding collisions when teammates work on the same repo.

### Configuration Best Practices

#### **Cost-Conscious Development**
```yaml
---
version: 1
token_profile: budget          # skip research/reassess phases, use cheap models
budget_ceiling: 25.00          # pause before overspending
models:
  research: claude-haiku-4-5-20250414
  planning: claude-sonnet-4-6
  execution: claude-haiku-4-5-20250414
---
```

#### **High-Quality Execution**
```yaml
---
version: 1
token_profile: quality         # all phases, prefer expensive models
models:
  research: claude-opus-4-6
  planning: claude-opus-4-6
  execution: claude-sonnet-4-6
  completion: claude-sonnet-4-6
---
```

#### **Balanced (Default)**
```yaml
---
version: 1
token_profile: balanced        # all phases, standard model selection
models:
  research: claude-sonnet-4-6
  planning: claude-opus-4-6
  execution: claude-sonnet-4-6
---
```

#### **Verification-Heavy Projects**
```yaml
---
verification_commands:
  - npm run lint
  - npm run test
  - npm run typecheck
  - npm run build
verification_auto_fix: true
verification_max_retries: 3
---
```

### Architectural Decision Logging

Always capture decisions in `DECISIONS.md`:

```markdown
# DECISIONS.md

## ADR-001: Use SQLite for Persistence

**Date:** 2026-05-01
**Status:** Accepted

### Context
Project needs local data storage without external dependencies.

### Decision
Use SQLite — embedded, zero-setup, battle-tested.

### Consequences
- ✅ No server to manage
- ✅ Full ACID guarantees
- ⚠️ Limited to single-process writes (mitigated by GSD's state machine)
```

Agents read this on every dispatch and respect prior decisions.

### Project Knowledge Management

Use `KNOWLEDGE.md` for rules and patterns that future sessions should follow:

```markdown
# KNOWLEDGE.md

## Rule: API Response Format
Always wrap API responses in `{ data, errors }` envelope. Never return raw arrays.

## Pattern: Component Testing
Use `@testing-library/react` for component tests, never snapshot tests.

## Lesson: Pitfall — N+1 Queries
Learned the hard way: always batch database queries. Single queries in a loop cause performance degradation.
```

Add entries with `/gsd knowledge rule|pattern|lesson <description>`.

### Git Strategy

#### **Worktree Isolation (Recommended for Serious Work)**
```yaml
---
git:
  isolation: worktree           # each milestone in separate directory
  merge_strategy: squash        # combine all commits into one
  auto_push: true               # push to remote
  commit_docs: true             # commit .gsd/ artifacts
---
```

**Result on `git log`:**
```
docs(M001/S04): workflow documentation and examples
fix(M001/S03): bug fixes and doc corrections
feat(M001/S02): API endpoints and middleware
feat(M001/S01): data model and type system
```

#### **Branch Isolation (Submodule-Heavy Repos)**
```yaml
---
git:
  isolation: branch             # work on milestone/<MID> branch in-place
  merge_strategy: squash
---
```

#### **No Isolation (Hot-Reload Workflows)**
```yaml
---
git:
  isolation: none               # work on current branch, no worktree
---
```

### Skill Discovery & Routing

```yaml
---
skill_discovery: suggest              # suggest skills but don't auto-install

always_use_skills:
  - debug-like-expert                 # always use this skill

prefer_skills:
  - frontend-design                   # use this when relevant

skill_rules:
  - when: task involves authentication
    use: [clerk]
  - when: frontend styling work
    prefer: [frontend-design]
  - when: working with legacy code
    avoid: [aggressive-refactor]
---
```

---

## 9. Example Workflows

### Workflow 1: Build an E-Commerce Feature (Start-to-Finish)

**Step 1: Define the Project**
```bash
cd my-shop
gsd
/gsd new-project --deep
```

Captures: vision, users, constraints, tech stack, requirements.

**Step 2: Queue Milestones**
```
/gsd queue M001-api-gateway
/gsd queue M002-product-catalog
/gsd queue M003-shopping-cart
```

**Step 3: Auto-Execute First Milestone**
```
/gsd auto
```

GSD executes all slices in M001:
- S01: Core API structure
- S02: Authentication
- S03: Rate limiting
- (etc.)

Each slice flows: Plan → Execute → Complete → Reassess → Next Slice

**Step 4: Monitor from Another Terminal**
```
gsd
/gsd status         # real-time dashboard
/gsd discuss        # architecture decisions
```

**Step 5: When Complete**
- Milestone is squash-merged to main
- HTML report generated in `.gsd/reports/`
- Next milestone auto-starts (if configured)

### Workflow 2: Autonomous Overnight Build (CI/CD)**

```bash
#!/bin/bash
# deploy.sh — run in CI pipeline

# Install GSD
npm install -g gsd-pi@latest

# Initialize project (first run only)
gsd config <<< ""  # skip all prompts

# Run auto mode with timeout
gsd headless auto --timeout 3600000 --max-restarts 3

# Query final state
gsd headless query | jq '.cost, .status'

# Generate report
gsd headless export --html
```

**Result:** Complete milestone built overnight, commits pushed, PRs created, report generated.

### Workflow 3: Incremental Team Development (Unique IDs)**

**Setup (Once):**
```bash
git clone https://github.com/myteam/project.git
cd project

# Enable unique milestone IDs
cat > .gsd/PREFERENCES.md << 'EOF'
---
version: 1
unique_milestone_ids: true
git:
  auto_push: true
---
EOF

git add .gsd/PREFERENCES.md
git commit -m "chore: enable unique milestone IDs for team workflows"
```

**Developer A:**
```bash
gsd
/gsd new-milestone api-enhancements    # creates M001-abc123
/gsd auto                              # works in worktree
```

**Developer B (Same Time):**
```bash
gsd
/gsd new-milestone ui-redesign         # creates M001-xyz789
/gsd auto                              # different worktree
```

**Result:** Both developers work simultaneously on different milestones without conflicts. Merge to main happens independently per milestone.

### Workflow 4: Bugfix-Specific Workflow

```bash
gsd
/gsd start bugfix                  # launches bugfix template
```

**Guides through:**
1. Capture bug description
2. Reproduce the issue
3. Identify root cause
4. Implement minimal fix
5. Add regression test
6. Verify fix

---

## 10. Relationship to Spec-Kit

### Comparison Matrix

| Aspect | **Spec-Kit** | **GSD-2** |
|--------|------------|---------|
| **Purpose** | Spec-driven development (intent → execution) | Autonomous project completion (milestone → built) |
| **Workflow** | Constitution → Spec → Plan → Tasks → Implement | Discuss → Plan → Execute → Complete → Reassess |
| **Runtime** | Python CLI (`specify`) | TypeScript CLI (`gsd`) / Pi SDK |
| **State** | Markdown-centric specifications | SQLite database (authoritative) + markdown projections |
| **Model Agnostic** | Yes (30+ agent integrations) | Yes (20+ LLM providers) |
| **Extension System** | Extensions + Presets (template-based customization) | Extensions + Agents (capability-based customization) |
| **Git Strategy** | Managed by agent (unreliable) | Worktree isolation + squash merge (deterministic) |
| **Crash Recovery** | Basic | Sophisticated (lock files, session forensics, auto-restart) |
| **Cost Tracking** | Via extensions | Built-in per-unit dashboard |
| **Verification** | Via extensions | Built-in (lint/test with auto-fix retries) |
| **Autonomous Execution** | Via `/speckit.implement` loop | Native auto-mode state machine |

### How They Complement Each Other

**GSD-2 is the execution layer; Spec-Kit is the specification layer.**

```
Spec-Kit (What to Build)
    ↓
    /speckit.specify    → spec.md
    /speckit.plan       → plan.md
    /speckit.tasks      → tasks.md
    ↓
GSD-2 (How to Build It)
    ↓
    /gsd new-project --context spec.md
    /gsd auto           → implements tasks.md
    ↓
    Milestone Complete ← clean git history + reports
```

**Ideal Stack:**
1. **Use Spec-Kit** to clarify requirements and create a rich specification
2. **Feed spec.md to GSD-2** with `/gsd new-project --context spec.md`
3. **GSD-2 executes** the plan autonomously
4. **GitHub Issues Integration** syncs progress back to Spec-Kit artifacts

### Tactical Differences

**Spec-Kit Strengths:**
- Rich requirement governance (constitution, compliance frameworks)
- Extensible workflow (extensions + presets are very customizable)
- Great for enterprise/regulated environments

**GSD-2 Strengths:**
- True autonomous execution (state machine, not LLM self-loop)
- Native crash recovery and cost tracking
- Designed for long-running, unattended builds
- Context management (fresh session per task)

---

## Quick Reference: Most Common Commands

```bash
# Setup
npm install -g gsd-pi
gsd /login
gsd config

# Start project
gsd /gsd new-project --deep    # staged discovery
gsd /gsd new-milestone M001    # add milestone

# Step mode (default)
gsd                            # run one unit, pause
gsd /gsd next

# Auto mode
gsd /gsd auto                  # run until done

# Monitor / Steer
gsd /gsd status                # real-time dashboard
gsd /gsd discuss               # architecture decisions
gsd /gsd queue M002            # queue next milestone

# Diagnostics
gsd /gsd forensics             # post-mortem investigation
gsd /gsd doctor                # health checks
gsd /gsd logs                  # activity logs

# CI / Headless
gsd headless auto --timeout 3600000
gsd headless query             # instant JSON state
gsd headless export --html     # generate report

# Configuration
gsd /gsd prefs                 # edit preferences
gsd /model                     # switch models
gsd /gsd keys                  # manage API keys
```

---

## Resources

- **Official Repository:** https://github.com/gsd-build/gsd-2
- **Documentation:** https://github.com/gsd-build/gsd-2/tree/main/docs
- **Discord Community:** https://discord.com/invite/nKXTsAcmbT
- **NPM Package:** https://www.npmjs.com/package/gsd-pi
- **Latest Release:** v2.78.1 (as of May 2026)

---

**Document Version:** 1.0
**Last Verified:** May 1, 2026
**GSD-2 Version:** v2.78.1 (Latest)
