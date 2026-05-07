# Getting Started with Agentic Engineering Scaffolding

This guide walks you through setting up your first agentic engineering project using this scaffolding system.

---

## What you'll learn

By the end of this guide, you'll have:

✅ A production-ready project (Go, TypeScript, Python, Ruby, or C)
✅ Integrated AI agent support (GitHub Copilot, Claude, Cursor)
✅ `.github/agents/` — domain-specific agent personas
✅ `.github/skills/` — custom Copilot skills
✅ Automated testing with 80% coverage threshold
✅ Security hardening with pre-commit hooks
✅ GitHub CI/CD workflows
✅ Hybrid framework: Spec-Kit + GSD-v1 + GSD-2 installed and ready

---

## Prerequisites

- **Git** — [Download](https://git-scm.com/)
- **VS Code** — [Download](https://code.visualstudio.com/)
- **Node.js** 22+ — [Download](https://nodejs.org/) _(required for TypeScript projects; optional otherwise)_
- **Go** 1.22+ — [Download](https://go.dev/dl/) _(required for Go projects)_
- **GitHub CLI** (`gh`) — [Download](https://cli.github.com/) _(optional, for GitHub repo creation)_
- **GitHub account** (optional, but recommended for CI/CD)

---

## Step 1: Clone the framework

```bash
git clone https://github.com/lfarizav/hdd-gsd2-hybrid-framework.git
cd hdd-gsd2-hybrid-framework
```

---

## Step 2: Create a new project (single command)

```bash
bash scripts/create-new-project.sh
```

The script is **fully interactive** — it will prompt you for everything:

```
  Project name: my-awesome-api
  Where to create it? [/home/user]: /home/user
  Language? [1=TypeScript 2=Go 3=Ruby 4=C 5=Python]: 2
  Create GitHub repo? [y/N]: n
  Install hybrid framework CLIs? [y/N]: n
```

**What happens automatically:**
1. Framework checks for updates and pulls the latest version
2. Creates the project directory
3. Runs `scaffold-project.sh` — base infrastructure (80–120 files)
4. Runs `scaffold-hybrid-framework.sh` — 3-layer hybrid framework
5. Creates initial git commit
6. _(optional)_ Creates GitHub repo via `gh` CLI

**What gets created:**

```mermaid
graph LR
    Script["create-new-project.sh"] --> Base["Base scaffold"]
    Script --> Hybrid["Hybrid framework"]

    Base --> Code["💻 Source skeleton<br/>src/ or cmd/internal/"]
    Base --> Instructions["📋 AGENTS.md<br/>+ symlinks"]
    Base --> GitHub["🤝 .github/<br/>agents/ skills/ workflows/"]
    Base --> Security["🔐 pre-commit hook<br/>.env.example"]

    Hybrid --> Spec["Layer 1: Spec-Kit<br/>specs/"]
    Hybrid --> Plan["Layer 2: GSD-v1<br/>.planning/"]
    Hybrid --> Exec["Layer 3: GSD-2<br/>.gsd/"]

    style Script fill:#51cf66,color:#fff
    style Base fill:#4c6ef5,color:#fff
    style Hybrid fill:#9775fa,color:#fff
    style Instructions fill:#4c6ef5,color:#fff,stroke:#000,stroke-width:2px
    style GitHub fill:#ffa94d,color:#000
```

> **Note:** `scaffold-project.sh` and `scaffold-hybrid-framework.sh` are framework tools.
> They stay in the framework directory — **never copied to your project**.

**What this creates** (15 files across 3 layers):

```
Layer 1 — Spec-Kit (Definition)
  specs/constitution.md          ← Fill in first — everything cascades from here
  specs/requirements.md          ← Gherkin-style feature requirements
  specs/quality-gates.md         ← 4 gates: Spec Review, Plan Review, Auto, Milestone
  .specify/memory/GOVERNANCE.md  ← Constitutional context loaded by Spec-Kit agents
  .specify/memory/ARCHITECTURE.md ← Architecture context

Layer 2 — GSD-v1 (Planning)
  .planning/config.json          ← Model, verification commands, constitution path
  .planning/PROJECT.md           ← Project overview for planning agents
  .planning/REQUIREMENTS.md      ← Planning-level breakdown of requirements
  .planning/ROADMAP.md           ← Milestone → slice → task hierarchy
  .planning/STATE.md             ← Current planning state snapshot
  .planning/DECISIONS.md         ← Append-only architectural decision log
  .planning/KNOWLEDGE.md         ← Project knowledge (minimal — per arXiv:2602.11988)

Layer 3 — GSD-2 (Execution)
  .gsd/PREFERENCES.md            ← Model routing, budget ceiling, auto-verify config
```

**Critical first action** — fill in the constitution:

```bash
# Open and replace ALL placeholder text
nano specs/constitution.md
```

> The constitution is the load-bearing document. Vague constitution → vague results at every phase.

---

## Step 3: Configure environment variables

```bash
cd /path/to/your-new-project

# Copy the template
cp .env.example .env

# Edit with your values
nano .env
```

**`.env.example` contains**:
```env
# Database
DATABASE_URL=postgresql://user:pass@localhost:5432/mydb

# API
API_PORT=3000
NODE_ENV=development

# Secrets (NEVER commit .env)
API_KEY=your-secret-key-here
```

**⚠️ Important**: Never commit `.env` — it's in `.gitignore` automatically.

---

## Step 4: Verify setup with tests

**For Go projects:**
```bash
go test ./...
go vet ./...
gofmt -w ./...
```

**For TypeScript projects:**
```bash
npm test
npm run lint
npm run typecheck
```

**Expected output (Go)**:
```
ok  	github.com/OWNER/my-awesome-api/internal/...  0.123s
coverage: 82.4% of statements
```

---

## Step 5: Open in VS Code

```bash
code /path/to/your-new-project
```

**Your VS Code is now configured** with:
- `.github/agents/` — docs, lint, test, security agent personas
- `.github/skills/` — troubleshoot, agent-customization skills
- `.vscode/` — workspace settings, recommended extensions, tasks
- `AGENTS.md` — AI agent context (symlinked from `.github/copilot-instructions.md`)

---

## Step 7: Start coding with your AI assistant

Open any file in `src/` and start chatting with your AI assistant:

### With GitHub Copilot

```
@copilot /lint

> This will run the lint agent and fix code style issues
```

### With specialized agents

```bash
@copilot /test          # Generate or fix tests
@copilot /docs          # Write documentation
@copilot /security      # Review for vulnerabilities
```

---

## Your first feature: Adding a logger utility

Let's create a simple logging utility and test it:

### 1. Create the logger

**File**: `src/lib/logger.ts`

```typescript
export interface LogEntry {
  level: 'info' | 'warn' | 'error'
  message: string
  timestamp: Date
}

export function createLogger() {
  return {
    info: (message: string): LogEntry => ({
      level: 'info',
      message,
      timestamp: new Date(),
    }),
    warn: (message: string): LogEntry => ({
      level: 'warn',
      message,
      timestamp: new Date(),
    }),
    error: (message: string): LogEntry => ({
      level: 'error',
      message,
      timestamp: new Date(),
    }),
  }
}
```

### 2. Write a test

**File**: `tests/unit/logger.test.ts`

```typescript
import { createLogger } from '../../src/lib/logger'

describe('Logger', () => {
  it('should log info message', () => {
    const logger = createLogger()
    const result = logger.info('Test message')

    expect(result.level).toBe('info')
    expect(result.message).toBe('Test message')
    expect(result.timestamp).toBeInstanceOf(Date)
  })
})
```

### 3. Run tests and see coverage

```bash
npm test
npm test:coverage
```

**Result**:
```
✓ Logger utility passes all tests
✓ Coverage: 100% (exceeds 80% threshold)
```

---

## Next steps

### 1. Review project standards

Read [AGENTS.md](../AGENTS.md) to understand:
- Code style rules
- Testing requirements
- Security boundaries
- Git workflow

### 2. Explore the structure

```
src/
├── lib/              ← Utilities (no side effects)
├── types/            ← TypeScript interfaces
├── api/              ← HTTP routes
├── db/               ← Database layer
├── middleware/       ← Request handlers
└── services/         ← Business logic

tests/
├── unit/             ← Fast, isolated tests
├── integration/      ← Component interaction tests
└── e2e/              ← End-to-end workflows
```

### 3. Set up Git

```bash
# Initialize git (if not already done)
git init

# Configure user (for commits)
git config user.name "Your Name"
git config user.email "you@example.com"

# Make first commit
git add .
git commit -m "chore: initial project scaffold"

# Create main branch
git branch -M main

# Connect to GitHub (optional)
git remote add origin https://github.com/YOU/REPO.git
git push -u origin main
```

### 4. Enable pre-commit hooks

The scaffold includes a pre-commit hook that blocks secrets. Enable it:

```bash
chmod +x .github/hooks/pre-commit
git config core.hooksPath .github/hooks
```

Now, if you try to commit `.env` or API keys, git will block it:

```bash
$ git commit -m "add config"
❌ REJECTED: .env detected in commit
```

### 5. Start the hybrid workflow

With the hybrid framework installed (Step 3), follow the three-phase workflow:

**Phase 1 — Define (Spec-Kit)**

```bash
# Fill in specs/constitution.md (required — no placeholders)
# Write specs/requirements.md with Gherkin acceptance criteria
specify clarify     # surface ambiguities before planning
specify analyze     # cross-spec consistency check
# Review specs/quality-gates.md Gate 1 checklist
```

**Phase 2 — Plan (GSD-v1)**

```bash
npx get-shit-done-cc@latest
# Or use /gsd-discuss-phase in your IDE
# Populate .planning/ROADMAP.md with milestones, slices, XML task plans
# Review specs/quality-gates.md Gate 2 checklist
```

**Phase 3 — Execute (GSD-2)**

```bash
gsd             # step-by-step mode (recommended first time)
gsd auto        # autonomous mode (after Gate 2 sign-off)
gsd status      # check progress
gsd export --html  # generate milestone report
```

**For the full workflow, see [HYBRID_FRAMEWORK_GUIDE.md](../HYBRID_FRAMEWORK_GUIDE.md) and [docs/FEASIBILITY_STUDY.md](FEASIBILITY_STUDY.md).**

### 6. Work with your AI assistant

Use unified agent instructions from `AGENTS.md`:

```bash
# Ask Copilot to lint your code
@copilot /lint

# Ask Claude to write tests
@copilot /test

# Ask your IDE to generate docs
@copilot /docs

# Ask any agent to review security
@copilot /security
```

All agents read from the same `AGENTS.md` file, so they follow consistent standards.

---

## Common workflows

### Adding a new feature

```mermaid
graph LR
    A["Create feature branch"] --> B["Edit src/"]
    B --> C["Write tests"]
    C --> D["Run: npm test<br/>npm lint<br/>npm typecheck"]
    D -->|Fail| B
    D -->|Pass| E["git commit<br/>-m 'feat: ...'"]
    E --> F["git push"]
    F --> G["Open Pull Request"]
    G --> H["GitHub Actions runs<br/>CI/CD"]
    H -->|Fail| B
    H -->|Pass| I["✅ Merge"]

    style A fill:#51cf66,color:#fff
    style I fill:#20c997,color:#fff
    style B fill:#4c6ef5,color:#fff
    style D fill:#ffa94d,color:#000
    style H fill:#ffa94d,color:#000
```

### Debugging a failing test

```bash
# Run tests with verbose output
npm test -- --verbose

# Run a single test file
npm test -- tests/unit/logger.test.ts

# Run with debugging info
node --inspect-brk node_modules/.bin/jest --runInBand
```

### Checking code quality

```bash
# Check coverage
npm test:coverage

# View coverage report
open coverage/lcov-report/index.html
```

### Syncing with latest scaffold

```bash
# Pull latest changes
git pull origin main

# Re-run scaffold to update configuration
bash scripts/scaffold-project.sh

# The scaffold is idempotent — safe to run multiple times
```

---

## Troubleshooting

### Issue: Tests fail with "Cannot find module"

**Solution**: Ensure TypeScript is compiled:
```bash
npm run build
npm test
```

### Issue: ESLint complains about TypeScript syntax

**Solution**: Update `.eslintrc`:
```json
{
  "parser": "@typescript-eslint/parser",
  "plugins": ["@typescript-eslint"]
}
```

### Issue: Symlinks not working on Windows

**Solution**: Use Windows Subsystem for Linux (WSL) or enable developer mode:
```bash
# In Windows (Administrator):
fsutil behavior set SymlinkEvaluation L2L:1 1L:1
```

### Issue: Pre-commit hook not running

**Solution**: Set the hooks path:
```bash
git config core.hooksPath .github/hooks
chmod +x .github/hooks/pre-commit
```

---

## Advanced topics

### Customizing AGENTS.md

All agents read from `AGENTS.md`. To modify behavior:

1. Edit `AGENTS.md`
2. Symlinks auto-resolve (no manual sync needed)
3. All tools immediately see the change

Example: Add a rule about async functions:

```markdown
## Code style (additions)

- Always use `async`/`await` over `.then()`
- Avoid nested `async` — use `Promise.all()` instead
```

### Setting up GitHub Actions

The scaffold includes `.github/workflows/ci.yml`. To activate:

1. Push to GitHub
2. Go to **Settings** → **Actions** → **Enable**
3. All PRs will run: `lint` → `test` → `typecheck`

### Using environment variables

In your code:

```typescript
const dbUrl = process.env.DATABASE_URL
if (!dbUrl) {
  throw new Error('DATABASE_URL is required')
}
```

In tests:

```typescript
beforeAll(() => {
  process.env.DATABASE_URL = 'test-db-url'
})
```

---

## Made with ❤️ by Luis Felipe Ariza Vesga

This scaffolding system was created to eliminate setup friction and help developers focus on building great features with AI assistance.

---

## Resources

- [Project README](../README.md) — Overview and quick start
- [Hybrid Framework Guide](../HYBRID_FRAMEWORK_GUIDE.md) — Full three-layer integration guide
- [Feasibility Study](FEASIBILITY_STUDY.md) — Research basis for the hybrid approach
- [Architecture Guide](architecture.md) — System design, components, and hybrid layer model
- [Contributing Guide](../CONTRIBUTING.md) — Development workflow and standards
- [AGENTS.md](../AGENTS.md) — Agent guidance and boundaries
- [TypeScript Handbook](https://www.typescriptlang.org/docs/) — Language reference
- [Jest Documentation](https://jestjs.io/docs/getting-started) — Testing framework
- [Conventional Commits](https://www.conventionalcommits.org/) — Commit message standard

**Questions?** Open an issue on GitHub! 🚀
