# GSD-2 vs Spec-Kit: Detailed Comparison

**Document Date:** May 1, 2026
**GSD-2 Version:** v2.78.1
**Spec-Kit Version:** v0.8.4

---

## Executive Summary

| Criterion | GSD-2 | Spec-Kit |
|-----------|-------|----------|
| **Primary Role** | Autonomous project execution engine | Specification-driven development framework |
| **Focus** | *How to build* (reliable automation) | *What to build* (clear intent) |
| **Use Case** | "Run auto mode, walk away" | "Turn specs into code systematically" |
| **Language** | TypeScript (Pi SDK) | Python (CLI) |
| **Model Agnostic** | Yes (20+ LLM providers) | Yes (30+ AI agents) |
| **Automation Level** | **State machine** (deterministic) | **Prompt loop** (heuristic) |
| **Best For** | Long-running, unattended builds | Enterprise spec governance, multi-agent teams |

---

## Feature-by-Feature Breakdown

### 1. Core Purpose & Philosophy

#### **GSD-2**
- **Mantra:** "One command. Walk away. Come back to built project with clean git history."
- **Philosophy:** Specifications are ephemeral; automation and reliability are eternal
- **Problem Solved:** LLM-based coding loops lose context, make mistakes, can't recover from crashes
- **Solution:** Standalone TypeScript app with database-authoritative state, fresh session per task, crash recovery

#### **Spec-Kit**
- **Mantra:** "Build high-quality software faster by starting with spec, not vibes."
- **Philosophy:** Rich specifications are the foundation; specifications + implementation should stay in sync
- **Problem Solved:** Vibe coding (no spec) → unmaintainable; specs (no automation) → stale
- **Solution:** Python CLI that guides multi-phase spec creation, then hands off to agent for implementation

**Tactical Difference:**
- **GSD-2:** Trusts the agent to execute well; focuses on context management and crash recovery
- **Spec-Kit:** Doesn't trust the agent to infer intent; demands explicit multi-phase spec creation first

---

### 2. Workflow Structure

#### **GSD-2 Phases**

```
Plan (research + decompose)
  → Execute (per task)
  → Complete (summary + commit)
  → Reassess (replan if needed)
  → Validate (reconciliation gate)
  ↓ (next slice)
```

**Characteristics:**
- Tight loop (one slice at a time)
- Integrated research (within planning)
- No separate "spec" phase (agents write plans, not specs)
- Post-execution reassessment (adaptive)
- Designed for autonomous execution (can run `auto` mode unattended for hours)

#### **Spec-Kit Phases**

```
Constitution (principles)
  → Specify (what to build)
  → Clarify (resolve ambiguities)
  → Plan (technical approach)
  → Analyze (cross-artifact consistency)
  → Tasks (break into units)
  → Implement (build code)
  → Review / Verify (quality gates)
```

**Characteristics:**
- Front-loaded spec phase (constitution, specification, clarification)
- Explicit separation of intent (spec) from implementation (code)
- Optional quality gates (clarify, analyze, checklist)
- Designed for multi-phase deliberation (humans involved at each gate)
- Extension-based verification (not built-in)

**Key Difference:**
- **GSD-2:** Plan *inside* execution loop (spec-less, plan-based)
- **Spec-Kit:** Plan *before* execution starts (spec-first)

---

### 3. Runtime Architecture

#### **GSD-2**

**Stack:**
- TypeScript + Pi SDK (coding agent harness)
- SQLite database (authoritative state)
- Rust N-API for performance-critical ops (grep, glob, git, diff)
- 24 bundled extensions (browser, search, MCP, voice, etc.)
- 5 specialized subagents (scout, researcher, worker, js-pro, ts-pro)

**State Management:**
```
SQLite (authoritative)
  ↓
Markdown projections (.gsd/*.md)
  ↓
Rendered for review, prompts, git history
```

**Session Model:**
- Fresh session per task (clean context window)
- Pre-inlined dispatch prompt (task plan, prior summaries, roadmap, decisions)
- All mutable state persisted to database
- No in-memory state survives across sessions

#### **Spec-Kit**

**Stack:**
- Python CLI
- Pluggable agent integrations (Copilot, Claude Code, Cursor, etc.)
- Extensible template system (core templates + extensions + presets)
- Community extensions (100+ available)
- Markdown-centric artifacts

**State Management:**
```
Markdown specs (authoritative)
  ↓
(Agent reads and implements)
  ↓
Code generated
  ↓
(Drift detection via extensions)
```

**Session Model:**
- Agent session per phase (e.g., `/speckit.implement`)
- Agent reads specs, implements, returns code
- Specs remain canonical (not database)
- Extensions can reconcile drift

**Key Difference:**
- **GSD-2:** Database is authoritative, markdown is derivative
- **Spec-Kit:** Markdown is authoritative, database doesn't exist (only spec artifacts)

---

### 4. Git Strategy

#### **GSD-2**

**Built-In Git Management:**
- **Worktree Isolation:** Each milestone in separate directory (`.gsd/worktrees/<MID>/`)
- **Sequential Commits:** One commit per task (derived from task summary)
- **Squash Merge:** All slice work squash-merged to main as one clean commit
- **Deterministic:** GSD controls git, not the agent
- **Meaningful Messages:** Commits say what was built (not "fix bug")

**Result on Git Log:**
```
docs(M001/S04): workflow documentation and examples
fix(M001/S03): bug fixes and doc corrections
feat(M001/S02): API endpoints and middleware
feat(M001/S01): data model and type system
```

#### **Spec-Kit**

**Git as Code Artifact:**
- No built-in git management
- Agent commits are whatever the agent does (varies by integration)
- Extensions (e.g., `spec-kit-git-strategy`) can enforce conventions
- Focus: spec artifacts should be in git (not code artifacts)

**Recommended Practice:**
- Commit specs to git (`.specify/specs/`)
- Code artifacts handled by standard dev workflow
- Extensions can reconcile spec-to-code drift

**Key Difference:**
- **GSD-2:** Git is infrastructure (automatic, deterministic)
- **Spec-Kit:** Git is code artifact (agent-managed, variable)

---

### 5. Crash Recovery & Reliability

#### **GSD-2**

**Built-In Recovery (Sophisticated):**
1. **Lock File:** `auto.lock` tracks current unit (PID lock)
2. **Session Forensics:** Next `/gsd auto` reads surviving session file, synthesizes briefing
3. **Database Recovery:** SQLite survives; state rebuilds from DB
4. **Worktree Recovery:** Ancestry guards, stash-by-ref recovery
5. **Headless Auto-Restart:** Exponential backoff (5s → 10s → 30s cap, 3 retries)
6. **Provider Error Retry:** Transient errors auto-resume; permanent errors pause

**Example:**
```bash
# Overnight run crashes at 03:15 AM
gsd headless auto --max-restarts 3

# At 03:16 AM, GSD auto-restarts with exponential backoff
# At 03:25 AM, if still failing, it exits with code 1
# Next run (04:00 AM) resumes from database state
```

#### **Spec-Kit**

**Recovery (Basic):**
- No built-in crash recovery
- Agent session loss means re-run the phase
- Can resume from spec artifacts (agent re-reads specs)
- Extensions can add sophisticated recovery (not built-in)

**Key Difference:**
- **GSD-2:** Expects crashes, handles them gracefully
- **Spec-Kit:** Assumes agent sessions complete; restart from specs

---

### 6. Cost Tracking & Budget

#### **GSD-2**

**Built-In Cost Management:**
```yaml
budget_ceiling: 50.00
budget_enforcement: pause  # warn | pause | halt
```

**Dashboard Shows:**
- Per-unit cost breakdown (phase, slice, task, model)
- Per-model cost (compare providers)
- Cumulative session cost
- Cost projections
- Budget pressure (50% → 75% → 90% thresholds trigger model downgrading)

**Token Optimization:**
```yaml
token_profile: budget    # 40-60% savings
  # vs.
token_profile: quality   # 0% savings (full context)
```

**Example Output:**
```
M001-abc123 | S01 | T01:execute-task | claude-opus-4-6 | $1.23
M001-abc123 | S01 | T01:verification | claude-haiku | $0.05
M001-abc123 | S02 | T01:execute-task | claude-sonnet-4-6 | $0.34
─────────────────────────────────────────────────────
Total M001: $5.67 | Projected: $12.34/milestone
```

#### **Spec-Kit**

**Cost Tracking (Via Extensions):**
- `spec-kit-token-analyzer` — captures token usage
- No built-in cost dashboard
- Must use extensions for budget ceilings
- Model selection is agent's responsibility (not coordinated)

**Key Difference:**
- **GSD-2:** Cost is first-class citizen (built-in visibility + budget controls)
- **Spec-Kit:** Cost is observable (via extensions), not managed

---

### 7. Verification & Quality Gates

#### **GSD-2**

**Built-In Verification:**
```yaml
verification_commands:
  - npm run lint
  - npm run test
  - npm run typecheck
  - npm run build
verification_auto_fix: true
verification_max_retries: 2
```

**How It Works:**
1. After task execution, run each command sequentially
2. If command fails, agent sees output and attempts auto-fix
3. Retry up to `verification_max_retries` times
4. If still failing, pause auto mode with error details

**Built-In Quality Checks:**
- Artifacts exist (files on disk)
- Imports resolve (cross-task wiring)
- Truths are observable (behavioral tests)

#### **Spec-Kit**

**Verification (Via Extensions):**
- `spec-kit-verify` — verify code against spec
- `spec-kit-review` — comprehensive code review
- `spec-kit-qa` — systematic QA testing
- `spec-kit-spectest` — auto-generate test scaffolds

**How It Works:**
1. Extensions run after `/speckit.implement`
2. Check spec artifacts against implementation
3. File findings (optional human gate)
4. Implement fixes (optional)

**Key Difference:**
- **GSD-2:** Verification is build step (automatic after every task)
- **Spec-Kit:** Verification is phase gate (optional, after implementation)

---

### 8. Model Selection & Routing

#### **GSD-2**

**Per-Phase Model Selection:**
```yaml
models:
  research: claude-sonnet-4-6
  planning:
    model: claude-opus-4-6
    fallbacks:
      - openrouter/z-ai/glm-5
      - openrouter/minimax/minimax-m2.5
  execution: claude-sonnet-4-6
  execution_simple: claude-haiku-4-5-20250414
  completion: claude-sonnet-4-6
```

**Complexity Routing (Automatic):**
- Tasks classified as simple/standard/complex (heuristic, sub-millisecond)
- Simple tasks route to cheap model (`execution_simple`)
- Standard/complex tasks route to `execution` model
- Learning from outcomes improves routing

**Budget Pressure Downgrading:**
```
Budget at 50% → start using tier-down models
Budget at 75% → aggressive downgrading
Budget at 90% → critical downgrading
```

**Fallback Chain:**
- Primary model fails (rate limit, quota) → try fallback 1 → try fallback 2
- Automatic, transparent to user

#### **Spec-Kit**

**Agent-Specific Model Selection:**
- Each integration (Copilot, Claude Code, Cursor) has its own model routing
- No centralized model selection
- Spec-Kit can't cross-integrate models (one agent = one model flow)

**Per-Phase (Via Extensions):**
- Extensions can implement phase-specific routing
- Not built-in

**Key Difference:**
- **GSD-2:** Centralized model routing (cost optimization is designed-in)
- **Spec-Kit:** Model is per-agent (agent picks its own)

---

### 9. Autonomy & Unattended Execution

#### **GSD-2**

**Designed for True Autonomous Execution:**
```bash
# Set up overnight execution
gsd headless auto --timeout 3600000 --max-restarts 3 &
# Go to sleep 😴

# Wake up to completed milestone
```

**Safety Mechanisms:**
- Timeouts (soft/idle/hard) prevent runaway execution
- Stuck detection (sliding-window pattern analysis) pauses on loops
- Artifact verification retries (cap at 3 attempts)
- Provider error recovery (auto-resume on transient errors)
- Budget ceilings (pause before overspending)

**Parallel Execution:**
```yaml
parallel:
  enabled: true
  max_workers: 2
  budget_ceiling: 50.00
```

Can run multiple milestones simultaneously in separate worktrees.

#### **Spec-Kit**

**Designed for Deliberative Development:**
- Human review gates at each phase
- `/speckit.clarify` — interactive questions
- `/speckit.analyze` — consistency checks (human reviews findings)
- `/speckit.implement` — human can pause and steer

**Limited Autonomous Execution:**
- Extensions like `spec-kit-ralph` enable autonomous implementation loops
- Not the default (human-centric by design)
- No multi-milestone orchestration

**Key Difference:**
- **GSD-2:** Designed for 100% autonomous execution (with safety guardrails)
- **Spec-Kit:** Designed for human-in-the-loop (autonomy is opt-in via extensions)

---

### 10. Team Workflows

#### **GSD-2**

**Unique Milestone IDs:**
```yaml
unique_milestone_ids: true  # produces M001-ush8s3 instead of M001
```

**Team Workflow:**
1. Developer A: `gsd /gsd new-milestone feature-api` → M001-abc123 (worktree A)
2. Developer B: `gsd /gsd new-milestone feature-ui` → M001-xyz789 (worktree B)
3. Both work simultaneously, push independently
4. Merge conflicts minimized (separate worktrees)
5. GitHub Sync coordinates milestones to Issues

#### **Spec-Kit**

**Squad Workflows (Via Extension):**
- `spec-kit-squad` — bootstrap agent team from spec
- `spec-kit-maqa` — multi-agent QA (coordinator → developer → QA)
- Extensions coordinate team (not built-in)

**Team Spec Sharing:**
- Commit `.specify/specs/` to git
- All team members work from same spec
- No isolation (unlike GSD-2 worktrees)

**Key Difference:**
- **GSD-2:** Isolation-first (worktrees prevent conflicts)
- **Spec-Kit:** Coordination-first (shared specs, agent orchestration)

---

### 11. Extension Ecosystem

#### **GSD-2**

**Extensions (Capability-Based):**
- Add new commands (`/gsd mcp`, `/gsd forensics`)
- Add new tools (MCP servers, custom agents)
- Loaded at runtime via resource-loader

**Example Extensions:**
- `gsd-extensions/google-search` (reference implementation)
- `gsd-extensions/browser-tools` (web automation)
- MCP client integration

**Bundled (24 Extensions):**
- All loaded automatically
- Can be disabled via environment vars

**Customization:**
- Minimal (extensions are capability-add, not behavior-override)

#### **Spec-Kit**

**Extensions (Template/Workflow-Based):**
- Add new commands (`/speckit.custom-command`)
- Add new phases/templates
- Extend existing workflows

**Presets (Behavior-Override):**
- Customize spec templates
- Override terminology
- Enforce organizational standards

**Ecosystem:**
- 100+ community extensions
- 50+ community presets
- Extensive marketplace

**Customization:**
- Deep (template override + preset stacking)

**Key Difference:**
- **GSD-2:** Fewer extensions, lower customization surface, focus on capabilities
- **Spec-Kit:** Many extensions, high customization, focus on organizational governance

---

### 12. Use Case Alignment

#### **Choose GSD-2 If:**
- ✅ You want to build autonomous agents that work unattended
- ✅ You need crash recovery and cost tracking built-in
- ✅ You want clean git history automatically
- ✅ You're building teams with parallel milestone execution
- ✅ You have long-running tasks (8+ hours)
- ✅ You want fresh context per task (no context bloat)
- ✅ You prefer state machines over prompt loops
- ✅ You're comfortable with less customization (standard workflow)

**Example Users:**
- Teams using Claude Code / Copilot for autonomous coding
- CI/CD pipelines that run overnight builds
- Startups building features at scale
- Enterprises prioritizing reliability over governance

#### **Choose Spec-Kit If:**
- ✅ You need rich specification governance
- ✅ You want explicit phase gates for review
- ✅ You must comply with regulations (traceability)
- ✅ You need deep workflow customization (presets)
- ✅ You have multi-team coordination (squad workflows)
- ✅ Your org enforces process discipline
- ✅ You want extensive extension ecosystem
- ✅ You need spec-to-code drift detection

**Example Users:**
- Enterprise software teams
- Regulated industries (healthcare, finance)
- Teams with process compliance requirements
- Organizations with governance frameworks

---

### 13. Ideal Usage Pattern: Combined Stack

**Workflow:**

```
1. Use Spec-Kit to Define the Vision
   /speckit.constitution   → team principles
   /speckit.specify        → clear requirements
   /speckit.clarify        → resolve ambiguities
   /speckit.plan           → technical approach
   ↓ export spec.md

2. Feed to GSD-2 for Execution
   gsd /gsd new-project --context spec.md
   gsd /gsd auto           → build milestone autonomously
   ↓

3. Spec-Kit Post-Implementation (Optional)
   /speckit.verify         → check code against spec
   /speckit.retrospective  → drift analysis & lessons
   ↓

4. GitHub Sync Bridges Both
   GSD auto-syncs to Issues
   Spec-Kit can read Issues for feedback loop
```

**Complementary Strengths:**
- **Spec-Kit:** Excellent for upfront clarity (constitution, requirements)
- **GSD-2:** Excellent for reliable execution (autonomy, crash recovery, cost tracking)
- **Together:** Best practices for enterprise (clear specs + autonomous execution)

---

## Migration Path (If Needed)

### From Spec-Kit to GSD-2

**Step 1: Extract Spec as Context**
```bash
# From Spec-Kit project
cat .specify/specs/spec.md > /tmp/feature-spec.md
```

**Step 2: Initialize GSD-2 Project**
```bash
gsd /gsd new-project --context /tmp/feature-spec.md
```

**Step 3: Let GSD-2 Autonomously Execute**
```bash
gsd /gsd auto
```

### From GSD-2 to Spec-Kit (Reverse)

**Step 1: Export GSD-2 Project Context**
```bash
cat .gsd/PROJECT.md .gsd/REQUIREMENTS.md .gsd/DECISIONS.md > /tmp/project-context.md
```

**Step 2: Initialize Spec-Kit Project**
```bash
specify init my-project --integration copilot
/speckit.specify < /tmp/project-context.md
```

**Step 3: Use Spec-Kit for Next Phase**
```bash
/speckit.plan
/speckit.tasks
```

---

## Conclusion

| Dimension | GSD-2 | Spec-Kit | Winner |
|-----------|-------|----------|--------|
| **Autonomous Execution** | 9/10 | 5/10 | GSD-2 |
| **Spec Governance** | 6/10 | 10/10 | Spec-Kit |
| **Cost Transparency** | 10/10 | 5/10 | GSD-2 |
| **Customization** | 5/10 | 9/10 | Spec-Kit |
| **Crash Recovery** | 10/10 | 3/10 | GSD-2 |
| **Team Coordination** | 8/10 | 9/10 | Spec-Kit |
| **Ease of Setup** | 7/10 | 8/10 | Spec-Kit |
| **Extensibility** | 6/10 | 10/10 | Spec-Kit |

**Recommendation:** Use **Spec-Kit for planning** (clarity, governance), then **GSD-2 for execution** (automation, reliability). They complement each other perfectly.
