# Architecture

This document describes the high-level design of the Agentic Engineering Scaffolding for VS Code, including system components, data flows, and key architectural decisions.

---

## Overview

The project is designed as a **bootstrapping system** that generates production-ready multi-language projects with integrated AI agent support. The architecture emphasizes:

- **Single Source of Truth** — One configuration file for all AI agents
- **Modularity** — Independent concerns (security, testing, documentation)
- **Automation** — Minimal manual setup through idempotent scripts
- **Multi-language** — Go, TypeScript, Python, Ruby, and C supported
- **Hybrid Framework** — Three complementary layers eliminate LLM hallucination at every phase of delivery

---

## System architecture

```mermaid
graph TB
    subgraph User["👤 Developer"]
        Clone["1. Clone<br/>repository"]
        Scaffold["2. Run scaffold<br/>script"]
    end

    subgraph Engine["⚙️ Scaffold Engine"]
        Parser["Config Parser"]
        Generator["File Generator"]
        Symlink["Symlink Creator"]
        Validation["Validation"]
    end

    subgraph Output["📦 Generated Project"]
        Config["Configuration<br/>(language-specific)"]
        Instructions["AGENTS.md +<br/>3 symlinks"]
        Code["Source code<br/>skeleton"]
        Workflows["CI/CD workflows"]
        Tests["Test structure"]
        AgentFiles[".github/agents/<br/>.github/skills/"]
    end

    subgraph Runtime["🚀 Runtime"]
        DevTools["VS Code<br/>Extensions<br/>Settings"]
        Agents["AI Agents<br/>read AGENTS.md"]
        Quality["Quality gates<br/>lint, test, type-check"]
        Security["Pre-commit<br/>hooks"]
    end

    Clone --> Scaffold
    Scaffold --> Parser
    Parser --> Generator
    Generator --> Symlink
    Symlink --> Validation
    Validation -->|Success| Output
    Validation -->|Failure| Scaffold

    Output --> Runtime
    Instructions -.->|all tools read| Agents
    Config -.->|activates| Quality
    Config -.->|activates| Security

    style Scaffold fill:#51cf66,color:#fff
    style Instructions fill:#4c6ef5,color:#fff,stroke:#000,stroke-width:2px
    style Agents fill:#ffa94d,color:#000
    style Quality fill:#9775fa,color:#fff
    style Security fill:#ff6b6b,color:#fff
```

---

## Core components

### 1. Scaffold Engine

**Entry point**: `scripts/create-new-project.sh`
**Base scaffold**: `scripts/scaffold-project.sh`
**Hybrid layers**: `scripts/scaffold-hybrid-framework.sh`

**Purpose**: `create-new-project.sh` is the single interactive entry point. It auto-updates the framework, then orchestrates the two sub-scripts in sequence.

**Key features**:
- Fully interactive — no positional arguments
- Auto-updates framework before scaffolding (`update-framework.sh`)
- `--force` flag for safe re-execution
- Skips unchanged files
- Creates `.github/agents/` (4 role-based personas) and `.github/skills/`
- Supports Go, TypeScript, Python, Ruby, and C

**Execution flow**:
```bash
create-new-project.sh
  └─ update-framework.sh          # Pull latest framework
  └─ scaffold-project.sh          # Base infrastructure
     ├─ Directories, AGENTS.md, .vscode
     ├─ .github/agents/ + .github/skills/
     └─ Language-specific files
  └─ scaffold-hybrid-framework.sh # 3-layer framework
     ├─ specs/  (Spec-Kit)
     ├─ .planning/ (GSD-v1)
     └─ .gsd/   (GSD-2)
```

### 2. Single Source of Truth (AGENTS.md)

**Location**: `AGENTS.md` + 3 symlinks

**Purpose**: Unified guidance for all AI agents (GitHub Copilot, Claude Code, Cursor, Windsurf).

**Architecture**:
```mermaid
graph LR
    AGENTS["AGENTS.md<br/>(Primary)"]

    CLAUDE["CLAUDE.md<br/>(Symlink)"]
    INST[".instructions.md<br/>(Symlink)"]
    COPILOT[".github/<br/>copilot-instructions.md<br/>(Symlink)"]

    AGENTS -->|OS resolves| CLAUDE
    AGENTS -->|OS resolves| INST
    AGENTS -->|OS resolves| COPILOT

    COPILOT -->|Copilot reads| Tool1["GitHub Copilot"]
    CLAUDE -->|Other tools read| Tool2["Claude Code<br/>Cursor<br/>Windsurf"]

    style AGENTS fill:#4c6ef5,color:#fff,stroke:#000,stroke-width:3px
    style CLAUDE fill:#4c6ef5,color:#fff
    style INST fill:#4c6ef5,color:#fff
    style COPILOT fill:#4c6ef5,color:#fff
```

**Content structure**:
- **Testing**: Language-specific test framework, 80% coverage requirement
- **Code style**: Language-specific conventions (Go: gofmt/goimports; TS: ESLint+Prettier)
- **Git workflow**: Branch naming, Conventional Commits, squash-merge policy
- **Boundaries**: What agents can and cannot do
- **Security**: OWASP compliance, secret handling

### 3. Specialized Agents

**Concept**: Each agent has a specific role and reads from AGENTS.md.

**Agents**:

| Agent | Role | Reads From | Output |
|-------|------|-----------|--------|
| Lint Agent | Fix code style | `AGENTS.md` | Formatted source files (language-specific) |
| Test Agent | Write tests | `AGENTS.md` | Unit/integration test files |
| Docs Agent | Write documentation | `AGENTS.md` | API docs, architecture guides |
| Security Agent | Review vulnerabilities | `AGENTS.md` | Security audit report |

**Invocation**:
```bash
@copilot /lint          # Fix style issues
@copilot /test          # Generate or fix tests
@copilot /docs          # Write documentation
@copilot /security      # Security review
```

### 4. Configuration Layer

**Purpose**: Consistent tool behavior across all developers and CI/CD environments.

**Key files by language**:

| Language | Files | Purpose |
|----------|-------|---------|
| **Go** | `go.mod`, `Makefile` | Module definition, build/test targets |
| **TypeScript** | `tsconfig.json`, `jest.config.js`, `eslint.config.js`, `.prettierrc.json` | Type safety, testing, linting, formatting |
| **Python** | `pyproject.toml`, `Makefile` | Package config, build/test targets |
| **All** | `.editorconfig`, `.vscode/settings.json` | Editor consistency |

**Configuration chain**:
```mermaid
graph LR
    AGENTS["AGENTS.md<br/>(Defines standards)"]
    AGENTS -->|generates| Config["Language config files"]
    Config -->|enforces| Tools["Dev tools<br/>(language-specific)"]
    Tools -->|guide| Output["Output<br/>Tested<br/>Formatted"]

    style AGENTS fill:#4c6ef5,color:#fff
    style Config fill:#51cf66,color:#fff
    style Tools fill:#ffa94d,color:#000
    style Output fill:#20c997,color:#fff
```

### 5. Security Layer

**Pre-commit hooks**: Block secrets before they reach git.

**Mechanism**:
```mermaid
graph LR
    Dev["Developer<br/>git commit"]
    Pre["Pre-commit hook<br/>executes"]
    Check[\"Scan for secrets<br/>API keys<br/>certificates<br/>tokens\"]

    Dev --> Pre
    Pre --> Check

    Check -->|❌ Found| Block["Reject commit<br/>Show error"]
    Check -->|✅ Clear| Allow["Allow commit<br/>Continue"]

    style Pre fill:#ff6b6b,color:#fff
    style Block fill:#ff6b6b,color:#fff
    style Allow fill:#51cf66,color:#fff
```

**Files**:
- `.github/hooks/pre-commit` — Bash script that detects patterns
- `.gitignore` — Exclude `.env`, `*.key`, etc.
- `.env.example` — Template for safe configuration

### 6. Quality Gates

**Automated checks** to maintain code quality:

```mermaid
graph TB
    Code["Code changes"]

    subgraph Checks["🧪 Quality Checks"]
        Lint["Language linter<br/>(gofmt / eslint)"]
        Type["Static analysis<br/>(go vet / tsc)"]
        Test["Language tests<br/>80% coverage"]
    end

    CI["CI/CD Pipeline<br/>GitHub Actions"]

    Code --> Checks
    Checks -->|All pass| Merge["✅ Merge allowed"]
    Checks -->|Any fail| Block["❌ Merge blocked"]

    CI -.->|runs on| Checks

    style Merge fill:#51cf66,color:#fff
    style Block fill:#ff6b6b,color:#fff
    style CI fill:#ffa94d,color:#000
```

---

## Directory structure

| Path | Purpose | Contains |
|------|---------|----------|
| `scripts/` | Bootstrap & utilities | `scaffold-project.sh` |
| `src/` | Application source code | TypeScript modules |
| `src/api/` | HTTP handlers | Route controllers |
| `src/db/` | Database layer | Models, migrations, queries |
| `src/lib/` | Shared utilities | Logger, helpers (no side effects) |
| `src/middleware/` | Request handlers | Auth, logging, error handling |
| `src/services/` | Business logic | Domain-specific logic |
| `src/types/` | Type definitions | Interfaces, enums |
| `tests/` | Test suites | Unit, integration, e2e tests |
| `docs/` | Documentation | Architecture, API reference |
| `specs/` | Specifications | ADRs, RFCs |
| `.github/` | GitHub integration | Workflows, templates, CODEOWNERS |
| `.vscode/` | Editor config | Settings, extensions, tasks |

---

## Data flow: Development workflow

```mermaid
graph LR
    Dev["Developer"] -->|edits| Code["Code<br/>src/"]
    Code -->|on save| Editor["VS Code<br/>settings"]
    Editor -->|runs| Format["Prettier<br/>format"]
    Format -->|runs| Lint["ESLint<br/>check"]
    Lint -->|runs| Type["TypeScript<br/>check"]
    Type -->|errors?| DevLoop["Fix issues"]
    DevLoop -->|edit| Code
    Type -->|pass| Test["language test<br/>(go test / npm test)"]
    Test -->|coverage ok?| Commit["git commit"]
    Commit -->|runs| PreCommit["Pre-commit hook<br/>scan secrets"]
    PreCommit -->|secrets?| Block["Reject"]
    PreCommit -->|clear| Push["git push"]
    Push -->|triggers| CI["GitHub Actions<br/>CI/CD"]
    CI -->|runs| CITest["Lint + Test<br/>+ Type-check"]
    CITest -->|pass| PR["PR approved<br/>✅ Ready to merge"]
    CITest -->|fail| Notify["Notify developer"]
    Notify -->|fix| Code

    style Dev fill:#51cf66,color:#fff
    style PR fill:#20c997,color:#fff
    style Block fill:#ff6b6b,color:#fff
    style CI fill:#ffa94d,color:#000
```

---

## Hybrid Framework Architecture

The project implements a **three-layer hybrid framework** that targets the four root causes of LLM hallucination in software development. Each layer is active in a different phase; no two layers operate simultaneously.

```mermaid
graph LR
    subgraph Layer1["Layer 1 — Spec-Kit (Define)"]
        SK1["specs/constitution.md"]
        SK2["specs/requirements.md"]
        SK3["specs/quality-gates.md"]
        SK4[".specify/memory/"]
    end

    subgraph Layer2["Layer 2 — GSD-v1 (Plan)"]
        GV1[".planning/ROADMAP.md"]
        GV2[".planning/DECISIONS.md"]
        GV3[".planning/KNOWLEDGE.md"]
        GV4[".planning/config.json"]
    end

    subgraph Layer3["Layer 3 — GSD-2 (Execute)"]
        G2[".gsd/PREFERENCES.md"]
        G2db[".gsd/gsd.db (SQLite)"]
    end

    Layer1 -->|Gate 1 sign-off| Layer2
    Layer2 -->|Gate 2 sign-off| Layer3

    style Layer1 fill:#4c6ef5,color:#fff
    style Layer2 fill:#51cf66,color:#fff
    style Layer3 fill:#ffa94d,color:#000
```

### Layer 1 — Spec-Kit: Eliminates Ambiguity

**Root cause addressed:** Ambiguity exploitation — the model fills underspecified requirements with training priors.

| File | Purpose |
|------|---------|
| `specs/constitution.md` | Non-negotiable values; cascades to every downstream decision |
| `specs/requirements.md` | Gherkin-style acceptance criteria; verifiable, not vague |
| `specs/quality-gates.md` | 4 mandatory gates before phase transitions |
| `.specify/memory/GOVERNANCE.md` | Constitutional context pre-loaded by Spec-Kit agents |
| `.specify/memory/ARCHITECTURE.md` | Architecture context; updated after each milestone |

**Install:** `uv tool install specify-cli --from 'git+https://github.com/github/spec-kit.git'`

### Layer 2 — GSD-v1: Controls Context at Execution Time

**Root cause addressed:** Context pollution — accumulated session garbage overrides earlier decisions.

| File | Purpose |
|------|---------|
| `.planning/ROADMAP.md` | Milestone → slice → XML task plans with explicit `<must_haves>` |
| `.planning/DECISIONS.md` | Append-only ADR log; pre-loaded by every execution agent |
| `.planning/KNOWLEDGE.md` | Minimal project facts (per arXiv:2602.11988) |
| `.planning/config.json` | Model, verification commands, constitution path |

**Key mechanism:** Fresh 200K context per subagent. Each task agent starts clean; orchestrator context stays lean.

**Install:** `npx get-shit-done-cc@latest` (no global install required)

### Layer 3 — GSD-2: State Machine Across Sessions

**Root cause addressed:** State amnesia — multi-session work contradicts earlier decisions.

| File | Purpose |
|------|---------|
| `.gsd/PREFERENCES.md` | Model routing per phase, budget ceiling, auto-verify commands |
| `.gsd/gsd.db` | SQLite state machine — authoritative source of truth (not committed) |

**Key mechanism:** All milestones, slices, tasks, and decisions live in SQLite. Markdown files are rendered projections, not runtime state.

**Install:** `npm install -g gsd-pi@latest`

### Handoff Model

```
Spec-Kit active:   ████████░░░░░░░░░░░░░░░░░░░░░
GSD-v1 active:     ░░░░░███████████░░░░░░░░░░░░░
GSD-2 active:      ░░░░░░░░░░░░░░████████████░░░
                   │             │             │
                   Define        Plan          Execute
                   (Gate 1)      (Gate 2)      (Gate 3+4)
```

No two frameworks are active simultaneously. Handoffs are file-based — no API integration, no shared runtime. Each framework reads files the previous framework wrote.

### Scaffold Scripts

| Script | Purpose | Files created |
|--------|---------|--------------|
| `scripts/create-new-project.sh` | **Main entry point** — interactive orchestrator | — |
| `scripts/scaffold-project.sh` | Base project (dirs, AGENTS.md, agents, skills, CI/CD) | ~50 |
| `scripts/scaffold-hybrid-framework.sh` | Three-layer hybrid framework | ~30 |

---

## Key architectural decisions

### 1. Single Source of Truth via Symlinks

**Decision**: Use symlinks instead of file copies for `AGENTS.md`.

**Rationale**:
- Avoids duplication and drift
- Changes to AGENTS.md auto-reflect everywhere
- No manual syncing required

**Trade-off**: Symlinks may not work on all Windows setups (mitigated by .github/workflows/validate-symlinks.yml).

### 2. Minimal, Research-Backed Instructions

**Decision**: Include only essential guidance in AGENTS.md.

**Rationale**: Per arXiv:2602.11988 (Gloaguen et al., 2026), excessive instructions reduce agent task success by >20%.

**Trade-off**: Developers need to review documentation for detailed guidance; not all patterns are encoded in AGENTS.md.

### 3. Idempotent Scaffold Script

**Decision**: Script can be run multiple times safely.

**Rationale**:
- Developers can re-run to update scaffolding
- No risk of accidental file loss
- Explicit `--force` flag for overwrites

**Trade-off**: Slight complexity in bash script to detect and skip unchanged files.

### 4. Multi-Language Support from Day One

**Decision**: Support Go, TypeScript, Python, Ruby, and C with the same scaffold.

**Rationale**:
- Teams choose the right language for the problem
- Agentic workflows are language-agnostic
- Quality gates (80% coverage, linting) apply universally

**Trade-off**: More conditional logic in scaffold scripts; tested across fewer language combinations.

### 6. Hybrid Framework: Sequential Phases, File-Based Handoffs

**Decision**: Spec-Kit → GSD-v1 → GSD-2 operate in strict sequence with file-based handoffs, never simultaneously.

**Rationale**: Each framework targets a different root cause of LLM hallucination. Overlapping operation creates split-brain state (markdown vs. SQLite). Sequential operation with gate reviews ensures quality without integration complexity. Evidence base: `docs/FEASIBILITY_STUDY.md`.

**Trade-off**: Requires process discipline; not suitable for projects shorter than 6 weeks (setup overhead exceeds benefit).

---

## See also

- [README.md](../README.md) — Project overview and quick start
- [AGENTS.md](../AGENTS.md) — Agent guidance and boundaries
- [Hybrid Framework Guide](../HYBRID_FRAMEWORK_GUIDE.md) — Full integration guide
- [Feasibility Study](FEASIBILITY_STUDY.md) — Research basis for the hybrid approach
- [API Reference](api.md) — Generated API documentation
- [CONTRIBUTING.md](../CONTRIBUTING.md) — Development workflow
