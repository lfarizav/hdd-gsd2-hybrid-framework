# Getting Started with Agentic Engineering Scaffolding

This guide walks you through setting up your first agentic engineering project using this scaffolding system.

---

## What you'll learn

By the end of this guide, you'll have:

✅ A production-ready TypeScript project
✅ Integrated AI agent support (GitHub Copilot, Claude, Cursor)
✅ Automated testing with 80% coverage threshold
✅ Code quality gates (linting, formatting, type-checking)
✅ Security hardening with pre-commit hooks
✅ GitHub CI/CD workflows

---

## Prerequisites

- **Node.js** 22+ — [Download](https://nodejs.org/)
- **Git** — [Download](https://git-scm.com/)
- **VS Code** — [Download](https://code.visualstudio.com/)
- **GitHub account** (optional, but recommended for CI/CD)

---

## Step 1: Clone and install

```bash
# Clone the repository
git clone https://github.com/OWNER/REPO.git
cd REPO

# Install dependencies
npm install
```

**What happens**:
- `node_modules/` is created with all dev tools (TypeScript, Jest, ESLint)
- `package-lock.json` is generated (commit this!)

---

## Step 2: Run the scaffold script

```bash
bash scripts/scaffold-project.sh
```

**What this creates** (51+ files):

```mermaid
graph LR
    Script["scaffold-project.sh"] --> Creates["Creates 51+ files"]

    Creates --> Config["⚙️ Configuration<br/>tsconfig.json<br/>jest.config.js<br/>eslint.config.js"]
    Creates --> Instructions["📋 Instructions<br/>AGENTS.md<br/>symlinks"]
    Creates --> Code["💻 Source code<br/>src/ skeleton<br/>tests/"]
    Creates --> GitHub["🤝 GitHub<br/>workflows<br/>templates"]
    Creates --> Security["🔐 Security<br/>pre-commit<br/>.env.example"]
    Creates --> Docs["📚 Documentation<br/>README.md<br/>CONTRIBUTING.md"]

    style Script fill:#51cf66,color:#fff
    style Creates fill:#51cf66,color:#fff
    style Config fill:#4c6ef5,color:#fff
    style Instructions fill:#4c6ef5,color:#fff,stroke:#000,stroke-width:2px
```

**Output**:
```
✓ Created 51 files
✓ Symlinks: CLAUDE.md → AGENTS.md
✓ Project structure ready
✓ Next: Configure .env
```

---

## Step 3: Configure environment variables

```bash
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

```bash
# Run all checks
npm test              # Run tests
npm run lint          # Check code style
npm run typecheck     # TypeScript check
npm run format        # Auto-format code
```

**Expected output**:
```
PASS  tests/unit/logger.test.ts
  ✓ logger exports a function (XX ms)
  ✓ logger handles errors (XX ms)

Test Suites: 1 passed, 1 total
Coverage: ✓ 80% (exceeds threshold)
```

---

## Step 5: Open in VS Code

```bash
code .
```

**First time in VS Code?** You'll see a notification:

```
"Recommended extensions for this workspace"

[Install] [Dismiss]
```

Click **[Install]** to get recommended tools:
- ESLint — Real-time code style checking
- Prettier — Code formatter
- Thunder Client or REST Client — API testing

**Your VS Code is now configured** with:
- TypeScript strict mode
- ESLint rules
- Prettier formatting
- Test runner integration

---

## Step 6: Start coding with your AI assistant

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

### 5. Work with your AI assistant

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

- [Project README](../README.md) — Overview
- [Architecture Guide](architecture.md) — System design
- [Contributing Guide](../CONTRIBUTING.md) — How to contribute
- [AGENTS.md](../AGENTS.md) — Agent standards and boundaries
- [TypeScript Handbook](https://www.typescriptlang.org/docs/) — Language reference
- [Jest Documentation](https://jestjs.io/docs/getting-started) — Testing framework
- [Conventional Commits](https://www.conventionalcommits.org/) — Commit message standard

**Questions?** Open an issue on GitHub! 🚀
