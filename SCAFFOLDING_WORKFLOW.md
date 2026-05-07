# Framework Scaffolding Workflow — Complete Guide

## TL;DR: The Single Command That Does Everything

```bash
# This ONE command creates a complete, production-ready project with:
# ✅ Full directory structure (Git, VS Code, GitHub integration)
# ✅ Language-specific setup (TypeScript, Go, Python, Ruby, C)
# ✅ 3-layer hybrid framework (Spec-Kit + GSD-v1 + GSD-2)
# ✅ Quality gates + CI/CD workflows
# ✅ AI agent context (AGENTS.md + VS Code customizations)
# ✅ Agent personas (.github/agents/) + skills (.github/skills/)

# Run from the framework directory — interactive, prompts for everything:
bash scripts/create-new-project.sh
```

---

## Which Script Generates the Whole Scaffold?

**Answer: `create-new-project.sh` is the MAIN ORCHESTRATOR**

It's the only entry point you ever need. It calls the other scripts in sequence:

```
create-new-project.sh (YOU ARE HERE)
├─ Validates prerequisites
├─ Prompts for project name, language, GitHub settings
├─ Calls scaffold-project.sh
│  └─ Creates base infrastructure (directories, AGENTS.md, .vscode, etc.)
└─ Calls scaffold-hybrid-framework.sh
   └─ Adds 3-layer framework (Spec-Kit, GSD-v1, GSD-2)
```

### The 4 Scripts

| Script                       | Purpose                                        | When to Use                        | Called By             |
| ---------------------------- | ---------------------------------------------- | ---------------------------------- | --------------------- |
| **create-new-project.sh**    | **Main entry point** — orchestrates everything | Every new project                  | You (user)            |
| scaffold-project.sh          | Creates base infrastructure                    | Standalone if you need raw project | create-new-project.sh |
| scaffold-hybrid-framework.sh | Adds hybrid framework layers                   | Standalone for existing projects   | create-new-project.sh |
| update-framework.sh          | Updates framework to latest version            | Periodic maintenance               | You (user)            |

---

## Step-by-Step Execution Flow

### Step 0: Auto-Update Framework (create-new-project.sh)

```bash
# Pulls latest framework changes before scaffolding:
bash scripts/update-framework.sh
```

### Step 1: Interactive Prompts (create-new-project.sh)

```bash
# Prompts collected (no positional arguments):
# - Project name
# - Parent directory (default: $HOME)
# - Language: Go / TypeScript / Python / Ruby / C
# - GitHub: create remote repo? public/private? org?
```

### Step 2: Run scaffold-project.sh

**What it creates:**

- Git repo (branch: main)
- Directory structure: `src/`, `tests/`, `docs/`, `specs/`, `scripts/`
- AGENTS.md (AI agent context)
- .vscode/ (workspace settings + recommended extensions)
- .github/ (PR templates, issue templates, CI workflows)
- Language-specific files:
  - TypeScript: `package.json`, `tsconfig.json`, `jest.config.js`, `eslint.config.js`
  - Go: `go.mod`, `Makefile`, `cmd/`, `internal/`
  - Python: `pyproject.toml`, `Makefile`, `venv/`
  - Ruby: `Gemfile`, `Rakefile`
  - C: `Makefile`, `src/`, `tests/`
- .gitignore (OWASP-aligned)
- .env.example (shape, no values)
- README.md, CONTRIBUTING.md, CHANGELOG.md, LICENSE
- .understand-anything/ (codebase intelligence)

**Files created: ~30-50 depending on language**

### Step 3: Run scaffold-hybrid-framework.sh

**Layer 1 — Spec-Kit (Specification-driven development)**

```
specs/
├── constitution.md          # Project identity
├── requirements.md          # REQ-001, REQ-002... (Gherkin scenarios)
├── quality-gates.md         # Gate criteria
├── features/
│   └── FEAT-001-*.md       # Acceptance criteria (AC-001, AC-002...)
├── adr/
│   └── 0001-decision.md    # Architecture decisions
└── README.md
```

**Layer 2 — GSD-v1 (Planning & context engineering)**

```
.planning/
├── config.json             # Project metadata
├── PROJECT.md              # Overview + teams + milestones
├── ROADMAP.md              # Milestones + Slices + Tasks
├── STATE.md                # Current execution state
├── DECISIONS.md            # Historical decisions
├── KNOWLEDGE.md            # Domain knowledge
├── research/               # Referenced articles
└── memory/                 # Persistent context
```

**Layer 3 — GSD-2 (Autonomous execution)**

```
.gsd/
├── PREFERENCES.md          # Agent preferences
├── gsd.db                  # SQLite state machine (created on first run)
└── checkpoints/            # Snapshots
```

**Additional VS Code customizations:**

```
.github/
├── agents/                 # fix-agent.agent.md, lint-agent.agent.md
├── instructions/           # general.instructions.md, go.instructions.md
├── skills/                 # Custom skill definitions
├── prompts/                # go-review.prompt.md, etc.
├── hooks/                  # Pre/post-commit hooks
└── workflows/              # quality-gate.yml
```

### Step 4: Agent Personas + Skills (scaffold-project.sh)

```bash
# Writes to .github/agents/:
#   docs-agent.md, lint-agent.md, test-agent.md, security-agent.md
# Writes to .github/skills/:
#   README.md, troubleshoot.md, agent-customization.md
```

### Step 5: Placeholder Substitution (create-new-project.sh)

```bash
# Replace generic placeholders with real values:
PROJECT_NAME → my-awesome-api
OWNER/REPO → lfarizav/my-awesome-api
PROJECT_TITLE → My Awesome API (title-cased)
GITHUB_USER → (detected from gh auth)
```

### Step 6: GitHub Integration (create-new-project.sh)

```bash
# If gh CLI available and authenticated:
gh repo create $OWNER/$PROJECT_NAME --${VISIBILITY} --description "..."
git remote add origin https://github.com/$OWNER/$PROJECT_NAME.git
git branch -M main
git push -u origin main
```

> **Note:** Scaffold scripts live only in the framework (`scripts/`). They are NEVER copied into the new project. Run `bash scripts/update-framework.sh` from any project to pull the latest scaffold improvements.

---

## What Gets Created: File Count & Organization

**Total files created: ~80-120 depending on language & options**

```
project-name/
├── .git/                          # Git repository
├── .github/
│   ├── agents/                    # VS Code custom agents (3 files)
│   ├── instructions/              # AI agent instructions (2 files)
│   ├── skills/                    # go-test-doctor/ SKILL.md
│   ├── prompts/                   # go-review.prompt.md
│   ├── hooks/                     # format.json, guard.json
│   ├── workflows/                 # quality-gate.yml
│   ├── pull_request_template.md
│   └── ISSUE_TEMPLATE/
├── .gsd/                          # GSD-2 state machine layer
│   ├── PREFERENCES.md
│   └── gsd.db (created on first run)
├── .planning/                     # GSD-v1 planning layer
│   ├── config.json
│   ├── PROJECT.md
│   ├── ROADMAP.md
│   ├── STATE.md
│   ├── DECISIONS.md
│   ├── KNOWLEDGE.md
│   └── research/
├── .specify/                      # Spec-Kit extension points
│   ├── extensions/
│   ├── features/
│   ├── memory/
│   ├── presets/
│   └── templates/
├── .understand-anything/          # Codebase intelligence
│   ├── .understandignore
│   ├── meta.json
│   └── knowledge-graph.json
├── .vscode/
│   ├── settings.json
│   ├── extensions.json
│   └── launch.json
├── .gitignore                     # OWASP-aligned
├── .editorconfig
├── .env.example
├── AGENTS.md                      # AI agent context ⭐ PRIMARY
├── README.md
├── CONTRIBUTING.md
├── CHANGELOG.md
├── LICENSE (MIT)
│
├── specs/                         # Spec-Kit Layer 1
│   ├── constitution.md
│   ├── requirements.md
│   ├── quality-gates.md
│   ├── features/
│   │   └── FEAT-001-*.md
│   └── adr/
│       └── 0001-decision.md
│
├── docs/
├── src/                           # Language-specific
├── tests/                         # Language-specific
├── scripts/
│   ├── update-framework.sh        # (if desired)
│   └── README.md                  # (if desired)
│
├── go.mod (Go)
├── go.sum (Go)
├── Makefile (Go)
├── cmd/ (Go)
├── internal/ (Go)
│
├── package.json (TypeScript)
├── tsconfig.json (TypeScript)
├── jest.config.js (TypeScript)
├── eslint.config.js (TypeScript)
│
├── pyproject.toml (Python)
├── Makefile (Python)
│
└── ... (language-specific files)
```

---

## Quality Gates: What's Checked

### Gate 1: Specification Completeness ✅

- `specs/constitution.md` exists
- `specs/requirements.md` exists
- `specs/features/` directory with at least one feature
- `specs/adr/` directory with ADRs
- Gherkin scenarios in requirements

### Gate 2: Planning Completeness ✅

- `.planning/PROJECT.md` references M001 (milestones)
- `.planning/ROADMAP.md` has Slices (S01, S02...)
- `.planning/ROADMAP.md` has Tasks (T1, T2...)
- `.planning/STATE.md` exists
- `.gsd/PREFERENCES.md` exists

### Gate 3: Execution Completeness ✅ (Language-dependent)

- **Go**: `go test -race ./... ` exits 0
- **Go**: Coverage ≥80% (checked with `go tool cover`)
- **Go**: `go vet ./...` passes
- **Go**: `gofmt -l ./...` is empty (all files formatted)
- **TypeScript**: `npm test` passes
- **TypeScript**: Coverage ≥80%
- **Python**: `pytest` passes
- **Python**: `mypy` passes (type checking)

---

## Command Cheat Sheet

### Creating Projects

```bash
# Always fully interactive — prompts for everything
# Run from the framework directory:
bash scripts/create-new-project.sh

# Force overwrite of existing project
bash scripts/create-new-project.sh --force

# Show help
bash scripts/create-new-project.sh --help
```

### Framework Maintenance

```bash
# Check for updates
cd ~/my-api
bash scripts/update-framework.sh

# Auto-update with stash
bash scripts/update-framework.sh --force

# Update in your projects
cd ~/hdd-gsd2-hybrid-framework
bash scripts/update-framework.sh
```

### Language-Specific

```bash
# Go projects
cd ~/my-api
go test -race ./...       # Run tests with race detection
go test -cover ./...      # Check coverage
go vet ./...              # Lint
gofmt -w ./...            # Format

# TypeScript projects
npm test                  # Run Jest tests
npm run build             # Compile
npm run lint              # ESLint
npm run typecheck         # TypeScript check

# Python projects
pytest                    # Run tests
mypy .                    # Type check
ruff check .              # Lint
```

---

## Workflow: From Idea to Production

### Phase 1: Create (5 minutes)

```bash
bash scripts/create-new-project.sh my-api --install-clis
cd my-api
git log --oneline -5  # See scaffolded commits
```

### Phase 2: Specify (1-2 hours)

```bash
# Edit specs/requirements.md with user stories
# Edit specs/features/FEAT-001-*.md with acceptance criteria
# Run Gate 1 validation
npm run quality-gate:spec  # or go run cmd/quality-gate/main.go gate1
```

### Phase 3: Plan (30 minutes)

```bash
# Edit .planning/ROADMAP.md with milestones and tasks
# Create .planning/DECISIONS.md for design decisions
# Run Gate 2 validation
npm run quality-gate:planning  # or go run cmd/quality-gate/main.go gate2
```

### Phase 4: Execute (2-3 days)

```bash
# Autonomous execution with GSD-2
npx gsd-2 --mode execute --state .gsd/gsd.db

# Or manual execution with test-driven development
# - Write failing tests (specs/features/)
# - Implement code
# - Commit + push
# - CI/CD validates Gate 3

# CI automatically runs:
# - go test -race (or npm test)
# - Coverage check (≥80%)
# - go vet / eslint (lint)
# - gofmt / prettier (format)
```

### Phase 5: Release

```bash
# Tag a release
git tag v1.0.0
git push origin v1.0.0

# GitHub Actions automatically:
# - Builds artifacts
# - Publishes to npm/GitHub Packages
# - Creates release notes
```

---

## Troubleshooting

### "Command not found: scaffold-project.sh"

**Solution**: Ensure you're in the framework directory:

```bash
cd /home/lfarizav/hdd-gsd2-hybrid-framework
bash scripts/create-new-project.sh my-api
```

### "gh CLI not found"

**Solution**: Install from https://cli.github.com/ and authenticate:

```bash
gh auth login
```

### "npm ERR! EACCES: permission denied"

**Solution**: Use `--install-clis` to let npm handle permissions, or:

```bash
npm install -g gsd-pi@latest
uv tool install specify-cli
```

### "Project directory already exists"

**Solution**: Use `--force` to overwrite:

```bash
bash scripts/create-new-project.sh my-api --force
```

### "go.mod: invalid go version"

**Solution**: Edit `go.mod` and update to Go 1.22+:

```bash
go mod edit -go=1.22
```

---

## Design Principles (Why This Approach?)

### 1. **Research-Backed** (arXiv:2602.11988)

- AGENTS.md contains minimal, non-redundant requirements
- Unnecessary instructions reduce LLM task-success by 3% and cost by 20%+

### 2. **Layered Architecture**

- **Spec-Kit** → Solves: Ambiguity at requirements level
- **GSD-v1** → Solves: Context pollution within a session
- **GSD-2** → Solves: State amnesia across sessions

### 3. **Language-Agnostic**

- One framework works for Go, TypeScript, Python, Ruby, C
- Language-specific configuration is automatic

### 4. **Quality-Gate Driven**

- Gate 1: Specification completeness
- Gate 2: Planning completeness
- Gate 3: Execution completeness (testing, linting, coverage)
- All gates automated and CI-enforced

### 5. **VS Code First**

- AGENTS.md is the single source of truth for AI agents
- VS Code customizations (agents, instructions, skills, hooks) are version-controlled
- Team sees consistent AI assistance across all projects

---

## Next Steps

1. **Create your first project:**

   ```bash
   bash scripts/create-new-project.sh
   ```

2. **Update framework periodically:**

   ```bash
   bash scripts/update-framework.sh
   ```

3. **Read full documentation:**
   - [scripts/README.md](scripts/README.md) — Technical details
   - [HYBRID_FRAMEWORK_GUIDE.md](HYBRID_FRAMEWORK_GUIDE.md) — Architecture
   - [docs/FEASIBILITY_STUDY.md](docs/FEASIBILITY_STUDY.md) — Research & evidence

---

**Made with ❤️ by Luis Felipe Ariza Vesga**

The scaffolding system is designed to eliminate setup friction and ensure every project starts with:

- ✅ Specification-driven development (Spec-Kit)
- ✅ Atomic planning (GSD-v1)
- ✅ Autonomous execution (GSD-2)
- ✅ Quality gates on every step
- ✅ AI agent support (VS Code Copilot)

Transform hours of setup into minutes of automation. 🚀
