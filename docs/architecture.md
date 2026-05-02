# Architecture

This document describes the high-level design of the Agentic Engineering Scaffolding for VS Code, including system components, data flows, and key architectural decisions.

---

## Overview

The project is designed as a **bootstrapping system** that generates production-ready TypeScript projects with integrated AI agent support. The architecture emphasizes:

- **Single Source of Truth** — One configuration file for all AI agents
- **Modularity** — Independent concerns (security, testing, documentation)
- **Automation** — Minimal manual setup through idempotent scripts
- **Type Safety** — TypeScript strict mode enforced from day one

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
        Config["Configuration<br/>tsconfig.json<br/>jest.config.js<br/>eslint.config.js"]
        Instructions["AGENTS.md +<br/>3 symlinks"]
        Code["Source code<br/>skeleton"]
        Workflows["CI/CD workflows"]
        Tests["Test structure"]
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

### 1. Scaffold Script

**Location**: `scripts/scaffold-project.sh`

**Purpose**: Idempotent project generator that creates 51+ files.

**Key features**:
- Runs without dependencies (pure bash)
- `--force` flag for safe re-execution
- Skips unchanged files
- Creates directory structure
- Generates configuration files
- Establishes symlinks for single source of truth

**Pseudocode**:
```bash
scaffold_project() {
  1. Create directory structure
  2. Parse configuration templates
  3. Generate configuration files
     → tsconfig.json, jest.config.js, eslint.config.js
  4. Create AGENTS.md (central guidance)
  5. Create symlinks (CLAUDE.md, .instructions.md, etc.)
  6. Create source code skeleton
  7. Create test structure
  8. Create GitHub workflows
  9. Validate all files created successfully
}
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
- **Testing**: Jest configuration, 80% coverage requirement
- **Code style**: TypeScript strict, single quotes, no semicolons, 2-space indent
- **Git workflow**: Branch naming, Conventional Commits, squash-merge policy
- **Boundaries**: What agents can and cannot do
- **Security**: OWASP compliance, secret handling

### 3. Specialized Agents

**Concept**: Each agent has a specific role and reads from AGENTS.md.

**Agents**:

| Agent | Role | Reads From | Output |
|-------|------|-----------|--------|
| Lint Agent | Fix code style | `AGENTS.md` | Fixed TypeScript/config files |
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

**Key files**:

| File | Purpose | Behavior |
|------|---------|----------|
| `tsconfig.json` | TypeScript compiler | Strict mode, ES2020 target, JSDoc support |
| `jest.config.js` | Test runner | `ts-jest` preset, 80% coverage threshold |
| `eslint.config.js` | Code linter | Flat config, @typescript-eslint parser |
| `.prettierrc.json` | Code formatter | Single quotes, no semicolons, 2-space indent |
| `.editorconfig` | Editor settings | Indent style, line endings, trim whitespace |

**Inheritance chain**:
```mermaid
graph LR
    AGENTS["AGENTS.md<br/>(Defines standards)"]
    AGENTS -->|generates| Config["Configuration files<br/>tsconfig.json<br/>jest.config.js<br/>eslint.config.js"]
    Config -->|enforces| Tools["Dev tools<br/>TypeScript<br/>Jest<br/>ESLint<br/>Prettier"]
    Tools -->|guide| Output["Output<br/>Type-safe<br/>Tested<br/>Formatted"]

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
    Check["Scan for secrets<br/>API keys<br/>certificates<br/>credentials"]

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
        Lint["ESLint<br/>Code style"]
        Type["TypeScript<br/>Type checking"]
        Test["Jest<br/>Unit tests<br/>80% coverage"]
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
    Type -->|pass| Test["npm test<br/>Jest"]
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

### 4. TypeScript Strict Mode from Day One

**Decision**: No `any` types, no optional properties, full type safety.

**Rationale**:
- Catches bugs at compile time
- Improves code quality
- Aligns with agentic engineering best practices

**Trade-off**: Requires more upfront type definitions; may feel verbose initially.

### 5. GitHub Actions for CI/CD

**Decision**: Built-in GitHub automation; no external CI systems required.

**Rationale**:
- Works out-of-the-box for GitHub repos
- Standard in the ecosystem
- Minimal configuration

**Trade-off**: Less flexibility than specialized CI systems; requires GitHub.

---

## Made with ❤️ by Luis Felipe Ariza Vesga

This architecture was designed to accelerate agentic engineering adoption by eliminating setup friction and providing a principled foundation for AI-assisted development.

---

## See also

- [README.md](../README.md) — Project overview and quick start
- [AGENTS.md](../AGENTS.md) — Agent guidance and boundaries
- [API Reference](api.md) — Generated API documentation
- [CONTRIBUTING.md](../CONTRIBUTING.md) — Development workflow
