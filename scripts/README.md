# Scaffolding Scripts — Hybrid Framework Automation

This directory contains the complete scaffolding system for creating production-ready projects with the HDD-GSD2 hybrid framework (Spec-Kit + GSD-v1 + GSD-2) integrated into VS Code.

---

## Overview: The Scaffolding Pipeline

```
create-new-project.sh (MAIN ORCHESTRATOR)
    ├─ Validates prerequisites (git, node, npm, gh)
    ├─ Prompts for: project name, parent directory, language, GitHub settings
    ├─ Creates project directory and copies scaffold scripts
    │
    ├─→ scaffold-project.sh (BASE INFRASTRUCTURE)
    │   ├─ Git initialisation (branch: main)
    │   ├─ Directory structure (src, tests, docs, specs, scripts, etc.)
    │   ├─ AGENTS.md (AI agent context—single source of truth)
    │   ├─ .vscode/ (workspace settings, recommended extensions)
    │   ├─ .github/ (PR templates, issue templates, CI workflows)
    │   ├─ Language-specific scaffolds (tsconfig.json, package.json, Makefile, etc.)
    │   ├─ .gitignore (OWASP-aligned secret & large-file protection)
    │   ├─ .env.example (shape of env vars, no real values)
    │   └─ README.md, CONTRIBUTING.md, CHANGELOG.md, LICENSE stubs
    │
    ├─→ scaffold-hybrid-framework.sh (3-LAYER FRAMEWORK)
    │   ├─ Layer 1 — Spec-Kit (specs/ directory + constitution, requirements, features, ADRs)
    │   ├─ Layer 2 — GSD-v1 (.planning/ directory + PROJECT.md, ROADMAP.md, STATE.md, DECISIONS.md)
    │   ├─ Layer 3 — GSD-2 (.gsd/ directory + PREFERENCES.md + SQLite state machine)
    │   └─ Optional: Install CLI tools (specify-cli via uv, gsd-pi via npm)
    │
    ├─ Placeholder substitution (PROJECT_NAME, OWNER/REPO, etc.)
    ├─ GitHub repo creation (gh CLI, optional)
    ├─ Initial git commit and push
    └─ Cleanup: Delete temporary scaffold scripts from project
```

---

## Scripts Explained

### 1. **create-new-project.sh** (Main Orchestrator)

**Purpose**: End-to-end bootstrap of a new VS Code project with all three hybrid framework layers.

**Entry Point**: 
```bash
bash scripts/create-new-project.sh <project-name> [options]
```

**Options**:
- `--dir <path>` — Parent directory (default: `$HOME`)
- `--private` — Create private GitHub repo (default)
- `--public` — Create public GitHub repo
- `--org <org>` — Create repo under GitHub organisation
- `--no-github` — Skip GitHub repo creation
- `--install-clis` — Install Spec-Kit and GSD-2 CLI tools
- `--force` — Overwrite existing scaffold files
- `--description "<text>"` — GitHub repo description

**Examples**:
```bash
# Minimal: creates ~/my-api with private GitHub repo
bash scripts/create-new-project.sh my-api

# Custom directory, public repo, under org
bash scripts/create-new-project.sh my-api \
  --dir ~/projects \
  --public \
  --org my-org

# Local-only (no GitHub)
bash scripts/create-new-project.sh my-api --no-github

# Full install with CLI tools
bash scripts/create-new-project.sh my-api --install-clis
```

**What it does**:
1. Validates prerequisites (git, node, npm, optional: gh CLI)
2. Prompts for project name, parent directory, language, GitHub settings
3. Creates `$PARENT_DIR/$PROJECT_NAME/` directory
4. Runs `scaffold-project.sh` (base infrastructure)
5. Runs `scaffold-hybrid-framework.sh` (3-layer framework)
6. Substitutes placeholders (PROJECT_NAME, OWNER/REPO, etc.)
7. Creates GitHub repo (if gh CLI available and authenticated)
8. Makes initial commit and pushes to remote
9. Cleans up temporary scaffold scripts

**Result**: Production-ready project with:
- ✅ Full directory structure
- ✅ Language-specific setup (TypeScript, Go, Ruby, C, Python)
- ✅ AGENTS.md + VS Code customizations
- ✅ Spec-Kit: constitution.md, requirements.md, features/, ADRs
- ✅ GSD-v1: PROJECT.md, ROADMAP.md, STATE.md, DECISIONS.md
- ✅ GSD-2: .gsd/PREFERENCES.md + state machine ready
- ✅ GitHub integration (optional)

---

### 2. **scaffold-project.sh** (Base Infrastructure)

**Purpose**: Create the foundational project structure that all projects need.

**Called by**: `create-new-project.sh` (automatically) or standalone
**Interactive**: Yes, unless PROJECT_DIR and PROJECT_LANG are exported

**Usage**:
```bash
# Standalone (interactive prompts)
bash scripts/scaffold-project.sh

# Non-interactive (from orchestrator)
export PROJECT_DIR=/path/to/project
export PROJECT_LANG=go
bash scripts/scaffold-project.sh [--force]
```

**What it creates**:

| File / Directory | Purpose |
|---|---|
| `.git/` | Git repository (branch: main) |
| `AGENTS.md` | AI agent context (minimal, non-redundant requirements) |
| `.vscode/settings.json` | Workspace settings (formatting, linting, testing) |
| `.vscode/extensions.json` | Recommended extensions for the team |
| `.github/pull_request_template.md` | PR template |
| `.github/ISSUE_TEMPLATE/bug.md` | Issue templates |
| `.github/workflows/` | CI/CD stubs (test, build, lint) |
| `.gitignore` | OWASP-aligned (secrets, large files, build outputs) |
| `.env.example` | Environment variable shape (no real values) |
| `.editorconfig` | Cross-editor formatting rules |
| `README.md` | Project description stub |
| `CONTRIBUTING.md` | Contribution guidelines |
| `CHANGELOG.md` | Semantic versioning changelog |
| `LICENSE` | MIT license (default) |
| `package.json` | (TypeScript/Node.js only) |
| `tsconfig.json` | (TypeScript only) |
| `jest.config.js` | (TypeScript only) |
| `go.mod` | (Go only) |
| `Makefile` | (Go only) |
| `src/`, `tests/`, `docs/`, `specs/`, `scripts/` | Standard directories |
| `.understand-anything/` | Codebase intelligence (knowledge graph) |

**Design Principles**:
- **Idempotent**: Safe to re-run; checks for existing files
- **Language-aware**: Creates different stubs for Go, TypeScript, Python, etc.
- **OWASP-aligned**: Blocks secrets and binaries from git
- **Agent-friendly**: AGENTS.md contains minimal, focused requirements (per arXiv:2602.11988)

**Options**:
- `--force` — Overwrite existing scaffold files (not git history or .env)

---

### 3. **scaffold-hybrid-framework.sh** (3-Layer Framework)

**Purpose**: Install the hybrid framework layers (Spec-Kit + GSD-v1 + GSD-2) on top of an existing project.

**Called by**: `create-new-project.sh` (automatically) or standalone
**Prerequisites**: `scaffold-project.sh` must have been run first (checks for `AGENTS.md`)
**Interactive**: No (non-interactive by default)

**Usage**:
```bash
# Standalone (must be in project directory with AGENTS.md)
cd /path/to/project
bash /path/to/scaffold-hybrid-framework.sh [options]

# Or from create-new-project.sh (automatic)
```

**Options**:
- `--force` — Overwrite existing scaffold files
- `--install-clis` — Also install Spec-Kit CLI (via uv) and GSD-2 CLI (via npm)

**What it creates**:

#### Layer 1 — Spec-Kit (Requirements → Code)
Solves: **Ambiguity at the requirements level**

```
specs/
├── constitution.md       # Project identity, scope, principles
├── requirements.md       # REQ-001, REQ-002... with Gherkin scenarios
├── quality-gates.md      # Gate criteria (architecture, testing, docs)
├── features/
│   └── FEAT-001-*.md     # Acceptance criteria (AC-001, AC-002...)
├── adr/
│   ├── 0001-decision.md  # Architecture Decision Records
│   └── ...
└── README.md
```

#### Layer 2 — GSD-v1 (Planning → Roadmap)
Solves: **Context pollution within a session**

```
.planning/
├── config.json           # Project metadata
├── PROJECT.md            # Overview, teams, milestones
├── REQUIREMENTS.md       # Mapping from specs/
├── ROADMAP.md            # Milestones (M001...), Slices (S01...), Tasks (T1...)
├── STATE.md              # Current execution state
├── DECISIONS.md          # Historical decisions and rationale
├── KNOWLEDGE.md          # Domain knowledge, patterns, lessons
├── research/             # Referenced articles, studies
└── memory/               # Persistent context between sessions
```

#### Layer 3 — GSD-2 (Execution → State Machine)
Solves: **State amnesia across sessions**

```
.gsd/
├── PREFERENCES.md        # Agent preferences and context
├── gsd.db               # SQLite state machine (created on first run)
└── checkpoints/         # Snapshot checkpoints
```

**Prerequisites Check**:
- ✅ `AGENTS.md` exists (from scaffold-project.sh)
- ✅ `uv` available (Python; optional warn if missing)
- ✅ `npm` available (already required)
- ✅ `git` available (already required)
- ✅ `specify` CLI (optional; installed if --install-clis)
- ✅ `gsd` CLI (optional; installed if --install-clis)

---

### 4. **update-framework.sh** (Framework Updates)

**Purpose**: Auto-update the framework to the latest version from GitHub.

**Usage**:
```bash
bash scripts/update-framework.sh [--force]
```

**Options**:
- `--force` — Stash uncommitted changes automatically (default: prompt)

**What it does**:
1. Checks git status (warns if uncommitted changes)
2. Fetches latest from origin/main
3. Reports if updates available (behind/ahead)
4. Pulls latest and shows summary
5. Lists modified files

---

## Language Support Matrix

| Language | Tooling | Scaffolds | Notes |
|---|---|---|---|
| **TypeScript** | npm, Jest, ts-jest, ESLint, Prettier | `package.json`, `tsconfig.json`, `jest.config.js`, `.prettierrc` | Default option |
| **Go** | go modules, go test, testify, gofmt, go vet | `go.mod`, `Makefile`, `cmd/`, `internal/` | Production-ready |
| **Python** | uv, pytest, mypy, ruff | `pyproject.toml`, `Makefile`, `venv/` | Modern tooling |
| **Ruby** | Bundler, RSpec, RuboCop | `Gemfile`, `Rakefile` | Community support |
| **C** | Make, Unity, cppcheck, valgrind | `Makefile`, `src/`, `tests/` | Embedded systems |

---

## Workflow: From Project Creation to Code Execution

### Phase 0: Pre-flight
```bash
# Check prerequisites, authenticate gh CLI
gh auth login
```

### Phase 1: Create Project
```bash
# Single command creates everything
bash scripts/create-new-project.sh my-awesome-api --install-clis
```

### Phase 2: Define Specification (Spec-Kit)
```bash
# Edit specs/ layer to capture requirements
vi my-awesome-api/specs/requirements.md
vi my-awesome-api/specs/features/FEAT-001-users.md

# Validate spec completeness
cd my-awesome-api && npm run quality-gate:spec
```

### Phase 3: Plan Execution (GSD-v1)
```bash
# Plan milestones and roadmap
vi .planning/ROADMAP.md

# Create task assignments
npx gsd-build --phase planning --output .planning/
```

### Phase 4: Autonomous Execution (GSD-2)
```bash
# Execute with state machine awareness
npx gsd-2 --mode execute --state .gsd/gsd.db

# Quality Gate 3 validates everything
npm run quality-gate:execution
```

### Phase 5: Continuous Integration
```bash
# CI workflows (GitHub Actions) enforce gates on every push
# .github/workflows/quality-gate.yml runs:
#   - go test -race ./...
#   - go test -cover (≥80% threshold)
#   - go vet ./...
#   - gofmt -l ./...
```

---

## Best Practices

### ✅ Do
- Run scaffold scripts with `--force` if you need to regenerate files
- Keep AGENTS.md minimal and focused (per arXiv:2602.11988 research)
- Use `update-framework.sh --force` for non-interactive updates
- Commit all files in `.planning/`, `specs/`, `.gsd/` to git (they're specs, not generated)
- Activate VS Code customizations (`AGENTS.md`, `.instructions.md`, etc.)

### 🚫 Don't
- Edit `AGENTS.md` and `scaffold-*.sh` simultaneously (race condition)
- Force-push to main after creating GitHub repo (breaks integration)
- Delete `.understand-anything/` — it's the codebase intelligence layer
- Commit `.env` (always use `.env.example`)
- Ignore Quality Gate failures — they're your safety net

---

## Troubleshooting

### "gh CLI not found"
**Solution**: Install from https://cli.github.com/, then run `gh auth login`

### "npm ERR! EACCES: permission denied"
**Solution**: Use `--install-clis` flag, or manually: `uv tool install specify-cli && npm install -g gsd-pi@latest`

### "scaffold-project.sh not found"
**Solution**: Ensure you're running from the framework root: `cd /home/lfarizav/hdd-gsd2-hybrid-framework`

### "Project directory already exists"
**Solution**: Either:
1. Choose a different name: `bash scripts/create-new-project.sh different-name`
2. Use `--force` to overwrite: `bash scripts/create-new-project.sh my-project --force`

### "go.mod: invalid go version"
**Solution**: Edit `go.mod` and update `go` version to 1.22 or later

---

## References

- **Research**: arXiv:2602.11988 — "Evaluating AGENTS.md" (Gloaguen et al., 2026)
- **Spec-Kit**: https://github.com/github/spec-kit (92.1K ⭐)
- **GSD-v1**: https://github.com/gsd-build/get-shit-done (59.3K ⭐)
- **GSD-2**: https://github.com/gsd-build/gsd-2 (7K ⭐)
- **Framework Design**: [HYBRID_FRAMEWORK_GUIDE.md](../HYBRID_FRAMEWORK_GUIDE.md)

---

## Quick Reference

| Task | Command |
|------|---------|
| Create new project | `bash scripts/create-new-project.sh <name> [options]` |
| Update framework | `bash scripts/update-framework.sh [--force]` |
| Scaffold base (standalone) | `bash scripts/scaffold-project.sh [--force]` |
| Scaffold hybrid (standalone) | `bash scripts/scaffold-hybrid-framework.sh [--force]` |
| Show create help | `bash scripts/create-new-project.sh --help` |
| List framework versions | `git log --oneline -10` |
| Check for updates | `git fetch origin && git status` |

---

**Made with ❤️ by Luis Felipe Ariza Vesga**

The scaffolding system is designed to make agentic engineering effortless, reducing setup time from hours to minutes while ensuring quality gates and best practices are built-in from day one.
