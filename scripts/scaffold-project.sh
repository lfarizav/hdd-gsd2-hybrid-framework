#!/usr/bin/env bash
# =============================================================================
# scaffold-project.sh
# =============================================================================
# PURPOSE:
#   Bootstraps the full project structure for this repository, including:
#     - Git initialisation & default branch naming
#     - Directory layout (src, tests, docs, specs, scripts, support-documents)
#     - AGENTS.md  →  the single source of truth for AI coding agent context
#     - .github/copilot-instructions.md  →  symlink to AGENTS.md so GitHub
#       Copilot reads the same file without a second copy to maintain
#     - .github templates (PR, issues) and CI/CD workflow stubs
#     - .vscode workspace settings and recommended extensions
#     - .gitignore with OWASP-aligned secret and large-file protection
#     - .env.example documenting required environment variables (no real values)
#     - .editorconfig for consistent cross-editor formatting
#     - README.md, CONTRIBUTING.md, CHANGELOG.md, and LICENSE stubs
#
# DESIGN PRINCIPLES (sourced from):
#   • arXiv:2602.11988 — "Evaluating AGENTS.md" (Gloaguen et al., 2026)
#       Key finding: AGENTS.md must contain MINIMAL, non-redundant requirements.
#       Unnecessary instructions *reduce* agent task-success and raise LLM cost
#       by >20 %. Effective files focus on specific tooling commands, boundaries,
#       and testing instructions — not codebase overviews that agents can discover.
#   • GitHub blog (Nigh, 2025) — Lessons from 2,500+ repos
#       Six core areas: commands, testing, project structure, code style,
#       git workflow, and explicit boundaries (always / ask first / never).
#   • agents.md spec — AGENTS.md is standard Markdown, tool-agnostic, and
#       recognised by Codex, Claude Code, Cursor, Windsurf, Gemini CLI, etc.
#
# SECURITY:
#   - .gitignore blocks .env, *.key, *.pem, secrets/, and common large-file
#     extensions so secrets and binaries are never accidentally committed.
#   - .env.example documents shape without values (OWASP: Sensitive Data Exposure).
#
# IDEMPOTENCY:
#   The script is safe to re-run: it checks for existing files/dirs before
#   creating them and only writes new content where nothing exists.
#
# USAGE:
#   bash scripts/scaffold-project.sh [--force]
#
#   --force   Overwrite existing scaffold files (NOT git history or .env).
#
# =============================================================================

set -euo pipefail

# ── Colours ──────────────────────────────────────────────────────────────────
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
BOLD='\033[1m'
RESET='\033[0m'

FORCE=false
for arg in "$@"; do
  [[ "$arg" == "--force" ]] && FORCE=true
done

# ── Helpers ───────────────────────────────────────────────────────────────────
info()    { echo -e "${CYAN}[INFO]${RESET}  $*"; }
success() { echo -e "${GREEN}[OK]${RESET}    $*"; }
warn()    { echo -e "${YELLOW}[WARN]${RESET}  $*"; }
error()   { echo -e "${RED}[ERROR]${RESET} $*" >&2; exit 1; }

# Write a file only when it does not yet exist, or when --force is set.
# Usage: write_file <path> <<'EOF' ... EOF
write_file() {
  local path="$1"; shift
  local content
  content=$(cat)                          # read stdin

  if [[ -f "$path" && "$FORCE" == false ]]; then
    warn "Skipped (already exists): $path"
    return
  fi

  mkdir -p "$(dirname "$path")"
  printf '%s\n' "$content" > "$path"
  success "Created: $path"
}

# Create a directory only when it does not yet exist.
make_dir() {
  local dir="$1"
  if [[ -d "$dir" ]]; then
    warn "Skipped (already exists): $dir/"
  else
    mkdir -p "$dir"
    # Touch a .gitkeep so empty directories are tracked by git.
    touch "$dir/.gitkeep"
    success "Created: $dir/"
  fi
}

# Resolve the repo root to the directory that contains this script's parent.
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

cd "$ROOT_DIR"
info "Working in: $ROOT_DIR"

# =============================================================================
# 1. INITIALISE GIT
# =============================================================================
echo
echo -e "${BOLD}── 1. Git initialisation ─────────────────────────────────────────────────${RESET}"

if [[ ! -d ".git" ]]; then
  git init --initial-branch=main
  success "Git repository initialised (branch: main)"
else
  warn "Git already initialised — skipping."
fi

# =============================================================================
# 2. DIRECTORY LAYOUT
# =============================================================================
echo
echo -e "${BOLD}── 2. Directory layout ───────────────────────────────────────────────────${RESET}"

# Source directories
make_dir src/api
make_dir src/db/migrations
make_dir src/lib
make_dir src/middleware
make_dir src/services
make_dir src/types

# Test directories  (unit / integration / e2e mirrors the test pyramid)
make_dir tests/unit
make_dir tests/integration
make_dir tests/e2e

# Documentation for humans (agents use AGENTS.md, not this folder)
make_dir docs

# Formal specifications, ADRs, and RFC documents
make_dir specs

# Scripts (this very file lives here)
# Already exists because this script is inside scripts/ — no-op if so.
make_dir scripts

# Supporting research materials
make_dir support-documents

# GitHub-specific customisations
make_dir .github/ISSUE_TEMPLATE
make_dir .github/workflows
make_dir .github/agents
make_dir .github/prompts
make_dir .github/hooks

# =============================================================================
# 3. AGENTS.md
# =============================================================================
# Research-backed rationale (arXiv:2602.11988):
#   ✓ Include:  exact build/test commands, specific tooling, style rules, boundaries
#   ✗ Omit:    directory tree overviews, prose the agent can discover itself,
#              generic best-practice reminders already in model training data
# =============================================================================
echo
echo -e "${BOLD}── 3. AGENTS.md ──────────────────────────────────────────────────────────${RESET}"

write_file "AGENTS.md" <<'AGENTS_EOF'
# AGENTS.md

> **Design note (arXiv:2602.11988 — Gloaguen et al.):** This file intentionally
> contains only *minimal*, non-redundant requirements. Excessive instructions
> reduce agent task-success rates by making tasks harder and inflate LLM cost
> by >20 %. Include only what an agent cannot discover on its own.

---

## Commands

```bash
# Install dependencies
npm install

# Build (TypeScript → dist/)
npm run build

# Watch mode during development
npm run dev

# Run the full test suite
npm test

# Run a single test file
npm test -- --testPathPattern=<pattern>

# Lint (auto-fix)
npm run lint -- --fix

# Type-check only (no emit)
npm run typecheck

# Format
npm run format
```

---

## Testing

- **Framework:** Jest + ts-jest
- Tests live under `tests/unit/`, `tests/integration/`, and `tests/e2e/`
- All tests **must pass** before a PR is merged; CI enforces this.
- Add or update tests for every code change, even when not explicitly requested.
- Never remove a failing test; fix it or open a follow-up issue.
- Coverage threshold: **80 %** (branches + lines). Run `npm test -- --coverage`.

---

## Code style

- **Language:** TypeScript (strict mode — `"strict": true` in tsconfig.json)
- Single quotes, no semicolons, 2-space indent (enforced by Prettier)
- Functional patterns preferred; avoid `class` unless modelling a domain entity
- Descriptive names over comments — `getUserById` beats `getUser` + a comment

```typescript
// ✅ Good
async function fetchUserById(id: string): Promise<User> {
  if (!id) throw new Error('User ID is required');
  return db.users.findOne({ id });
}

// ❌ Bad — vague name, missing guard, implicit any
async function getUser(id) {
  return db.users.findOne(id);
}
```

---

## Git workflow

- Branch naming: `feat/<slug>`, `fix/<slug>`, `chore/<slug>`, `docs/<slug>`
- PR titles follow [Conventional Commits](https://www.conventionalcommits.org/):
  `feat:`, `fix:`, `chore:`, `docs:`, `test:`, `refactor:`
- Squash-merge into `main`; keep a clean linear history
- **Never force-push to `main`**

---

## Boundaries

| ✅ Always | ⚠️ Ask first | 🚫 Never |
|-----------|--------------|---------|
| Write to `src/`, `tests/`, `docs/`, `specs/` | Add a new npm dependency | Commit `.env` or any secret |
| Run `npm test` before marking a task done | Modify CI/CD workflows | Edit `node_modules/` or `dist/` |
| Follow naming conventions above | Refactor across many files at once | Remove or skip failing tests |
| Use `npm run lint --fix` after edits | Change the database schema | Modify `package-lock.json` by hand |

---

## Environment variables

All required env vars are documented in `.env.example`.
Copy it to `.env` (never commit `.env`) and populate real values locally.
Use a secrets manager (e.g. AWS Secrets Manager, Vault) in production.

---

## Security considerations

- No secrets in source code or commit messages (pre-commit hook enforces this)
- Validate and sanitise all external input at system boundaries
- Use parameterised queries — never interpolate user input into SQL
- OWASP Top 10 is the baseline; flag security concerns in PR descriptions
AGENTS_EOF

# =============================================================================
# 4. .github/copilot-instructions.md  (symlink → AGENTS.md)
# =============================================================================
# GitHub Copilot reads .github/copilot-instructions.md for repository context.
# Rather than maintaining two files, we symlink it to AGENTS.md so there is
# exactly one source of truth.  Cross-tool compatibility:
#   • GitHub Copilot reads  .github/copilot-instructions.md
#   • OpenAI Codex reads    AGENTS.md at repo root
#   • Claude Code reads     CLAUDE.md  (we'll add that symlink too)
#   • Cursor, Windsurf etc. read AGENTS.md
# =============================================================================
echo
echo -e "${BOLD}── 4. copilot-instructions.md symlink ────────────────────────────────────${RESET}"

SYMLINK_TARGET=".github/copilot-instructions.md"
if [[ -L "$SYMLINK_TARGET" ]]; then
  warn "Symlink already exists: $SYMLINK_TARGET"
elif [[ -f "$SYMLINK_TARGET" ]]; then
  warn "$SYMLINK_TARGET is a regular file — leaving it in place (use --force to replace)"
else
  # Relative path: from .github/ the AGENTS.md is one level up
  ln -s ../AGENTS.md "$SYMLINK_TARGET"
  success "Symlink created: $SYMLINK_TARGET → ../AGENTS.md"
fi

# CLAUDE.md symlink for Claude Code compatibility
CLAUDE_SYMLINK="CLAUDE.md"
if [[ -L "$CLAUDE_SYMLINK" ]]; then
  warn "Symlink already exists: $CLAUDE_SYMLINK"
elif [[ -f "$CLAUDE_SYMLINK" ]]; then
  warn "$CLAUDE_SYMLINK is a regular file — leaving it in place"
else
  ln -s AGENTS.md "$CLAUDE_SYMLINK"
  success "Symlink created: $CLAUDE_SYMLINK → AGENTS.md"
fi

# =============================================================================
# 4b. .instructions.md  (symlink → AGENTS.md)
# =============================================================================
# VS Code Agent and other tools read .instructions.md at repo root.
# =============================================================================
echo
echo -e "${BOLD}── 4b. .instructions.md symlink ───────────────────────────────────────────${RESET}"

INSTRUCTIONS_FILE=".instructions.md"
if [[ -L "$INSTRUCTIONS_FILE" ]]; then
  warn "Symlink already exists: $INSTRUCTIONS_FILE"
elif [[ -f "$INSTRUCTIONS_FILE" ]]; then
  warn "$INSTRUCTIONS_FILE is a regular file — leaving it in place"
else
  ln -s AGENTS.md "$INSTRUCTIONS_FILE"
  success "Symlink created: $INSTRUCTIONS_FILE → AGENTS.md"
fi

# =============================================================================
# 5. .gitignore
# =============================================================================
# Security-first: blocks secrets, keys, and certificates (OWASP A02).
# Also blocks large binary/data files that should not be in git history.
# =============================================================================

write_file ".gitignore" <<'GITIGNORE_EOF'
# =============================================================================
# .gitignore — Security-first rules
# =============================================================================
# CRITICAL: secrets and credentials must NEVER be committed.
# If you accidentally commit a secret, rotate it immediately.
# =============================================================================

# ── Secrets & credentials (OWASP A02 — Cryptographic Failures) ──────────────
.env
.env.*
!.env.example           # .env.example is safe — it contains no real values
*.key
*.pem
*.p12
*.pfx
*.cert
*.crt
*.cer
*.csr
secrets/
credentials/
*_secrets.*
*secret*                # catches myapp_secret.json etc.
*credential*
*.token
auth.json
serviceAccountKey.json
gcp-key.json
aws-credentials

# ── API keys and config patterns ─────────────────────────────────────────────
.api_keys
api_keys.*
config/secrets.*
config/credentials.*

# ── Node.js ──────────────────────────────────────────────────────────────────
node_modules/
dist/
build/
.npm
*.log
npm-debug.log*
yarn-debug.log*
yarn-error.log*
pnpm-debug.log*
.pnpm-store/
.yarn/cache
.yarn/unplugged
.yarn/build-state.yml

# ── TypeScript ────────────────────────────────────────────────────────────────
*.tsbuildinfo
*.js.map

# ── Test & coverage ───────────────────────────────────────────────────────────
coverage/
.nyc_output/
*.lcov
test-results/
playwright-report/

# ── Large files & datasets ────────────────────────────────────────────────────
# Use Git LFS or external storage for these instead.
*.zip
*.tar
*.tar.gz
*.tgz
*.gz
*.bz2
*.7z
*.rar
*.iso
*.dmg
*.sqlite
*.sqlite3
*.db
*.dump
*.sql.gz
*.csv           # datasets can be large; store in data/ and exclude or use LFS
*.parquet
*.feather
*.h5
*.hdf5
*.npy
*.npz
*.bin           # model weights
*.onnx
*.pt
*.pth
*.ckpt
*.safetensors

# ── OS artefacts ──────────────────────────────────────────────────────────────
.DS_Store
.DS_Store?
._*
.Spotlight-V100
.Trashes
ehthumbs.db
Thumbs.db
desktop.ini

# ── IDEs & editors ────────────────────────────────────────────────────────────
.idea/
*.iml
*.ipr
*.iws
.eclipse/
*.sublime-workspace
*.sublime-project
.history/
*.swp
*.swo
*~

# ── VS Code (keep settings.json and extensions.json but not private state) ───
.vscode/launch.json       # can contain personal debug configs
!.vscode/settings.json
!.vscode/extensions.json
!.vscode/tasks.json

# ── Misc ──────────────────────────────────────────────────────────────────────
.cache/
tmp/
temp/
GITIGNORE_EOF

# =============================================================================
# 6. .env.example
# =============================================================================
# Documents the expected shape of .env without revealing real values.
# OWASP A02: never store credentials in source control.
# =============================================================================
echo
echo -e "${BOLD}── 6. .env.example ───────────────────────────────────────────────────────${RESET}"

write_file ".env.example" <<'ENV_EOF'
# =============================================================================
# .env.example
# =============================================================================
# Copy this file to .env and fill in real values for local development.
# NEVER commit .env — it is blocked by .gitignore.
# Use a secrets manager (AWS Secrets Manager, HashiCorp Vault, etc.) in prod.
# =============================================================================

# ── Application ──────────────────────────────────────────────────────────────
NODE_ENV=development
PORT=3000
LOG_LEVEL=debug

# ── Database ──────────────────────────────────────────────────────────────────
DATABASE_URL=postgresql://user:password@localhost:5432/mydb

# ── Authentication ────────────────────────────────────────────────────────────
JWT_SECRET=change-me-before-use
JWT_EXPIRES_IN=7d

# ── External APIs ─────────────────────────────────────────────────────────────
# Populate only the services your deployment uses.
OPENAI_API_KEY=
ANTHROPIC_API_KEY=
STRIPE_SECRET_KEY=
SENDGRID_API_KEY=

# ── Feature flags ─────────────────────────────────────────────────────────────
ENABLE_FEATURE_X=false
ENV_EOF

# =============================================================================
# 7. .github/pull_request_template.md
# =============================================================================
echo
echo -e "${BOLD}── 7. GitHub PR template ─────────────────────────────────────────────────${RESET}"

write_file ".github/pull_request_template.md" <<'PR_EOF'
## Description

<!--
  Explain the *why* — link the issue this resolves.
  Fixes #<issue-number>
-->

## Type of Change

- [ ] Bug fix (non-breaking change that fixes an issue)
- [ ] New feature (non-breaking change that adds functionality)
- [ ] Breaking change (fix or feature that causes existing behaviour to change)
- [ ] Refactor (no functional change)
- [ ] Documentation update
- [ ] Chore (dependency bumps, tooling, CI)

## How to Test

<!--
  Steps a reviewer can follow to verify this works.
  Include any required env vars or seed data.
-->

1.
2.
3.

## Checklist

- [ ] `npm test` passes locally (all tests green)
- [ ] `npm run lint` passes with no errors
- [ ] `npm run typecheck` passes
- [ ] New or updated tests cover the change
- [ ] No secrets or hardcoded credentials added
- [ ] Documentation updated if public API changed
- [ ] Self-reviewed diff for unintended changes
PR_EOF

# =============================================================================
# 8. .github/ISSUE_TEMPLATE files
# =============================================================================
echo
echo -e "${BOLD}── 8. GitHub Issue templates ────────────────────────────────────────────${RESET}"

write_file ".github/ISSUE_TEMPLATE/bug_report.md" <<'BUG_EOF'
---
name: Bug report
about: Something is broken
labels: bug, needs-triage
---

## Describe the bug

<!--  A clear and concise description of what the bug is. -->

## Steps to reproduce

1.
2.
3.

## Expected behaviour

## Actual behaviour

## Environment

- Node version:
- OS:
- Package version:

## Additional context

<!-- Screenshots, logs, related issues. -->
BUG_EOF

write_file ".github/ISSUE_TEMPLATE/feature_request.md" <<'FEAT_EOF'
---
name: Feature request
about: Suggest a new capability
labels: enhancement, needs-triage
---

## Problem to solve

<!-- What use-case or pain-point does this address? -->

## Proposed solution

<!-- Describe the feature and its expected behaviour. -->

## Alternatives considered

## Additional context
FEAT_EOF

write_file ".github/ISSUE_TEMPLATE/config.yml" <<'CFG_EOF'
blank_issues_enabled: false
contact_links:
  - name: Documentation
    url: https://github.com/OWNER/REPO/tree/main/docs
    about: Read the docs before opening an issue
CFG_EOF

# =============================================================================
# 9. .github/workflows  (CI and security stubs)
# =============================================================================
echo
echo -e "${BOLD}── 9. GitHub Actions workflows ───────────────────────────────────────────${RESET}"

write_file ".github/workflows/ci.yml" <<'CI_EOF'
# =============================================================================
# CI — runs on every push and pull request
# =============================================================================
name: CI

on:
  push:
    branches: [main]
  pull_request:
    branches: [main]

permissions:
  contents: read   # principle of least privilege

jobs:
  build-test:
    name: Build & Test
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Setup Node.js
        uses: actions/setup-node@v4
        with:
          node-version: '22'
          cache: 'npm'

      - name: Install dependencies
        run: npm ci

      - name: Lint
        run: npm run lint

      - name: Type-check
        run: npm run typecheck

      - name: Build
        run: npm run build

      - name: Test
        run: npm test -- --coverage

      - name: Upload coverage
        uses: codecov/codecov-action@v5
        if: always()
        with:
          fail_ci_if_error: false
CI_EOF

write_file ".github/workflows/security.yml" <<'SEC_EOF'
# =============================================================================
# Security scanning — runs weekly and on every push to main
# =============================================================================
name: Security

on:
  push:
    branches: [main]
  schedule:
    - cron: '0 9 * * 1'   # Every Monday at 09:00 UTC
  workflow_dispatch:

permissions:
  contents: read
  security-events: write   # needed for CodeQL to upload SARIF results

jobs:
  dependency-audit:
    name: npm audit
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with:
          node-version: '22'
          cache: 'npm'
      - run: npm ci --ignore-scripts
      - run: npm audit --audit-level=high

  codeql:
    name: CodeQL
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: github/codeql-action/init@v3
        with:
          languages: javascript-typescript
      - uses: github/codeql-action/autobuild@v3
      - uses: github/codeql-action/analyze@v3

  secret-scan:
    name: Secret scanning (gitleaks)
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
        with:
          fetch-depth: 0
      - uses: gitleaks/gitleaks-action@v2
        env:
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
SEC_EOF

# =============================================================================
# 10. .github/CODEOWNERS
# =============================================================================
echo
echo -e "${BOLD}── 10. CODEOWNERS ─────────────────────────────────────────────────────────${RESET}"

write_file ".github/CODEOWNERS" <<'CODEOWNERS_EOF'
# =============================================================================
# CODEOWNERS
# =============================================================================
# Each line is a file pattern followed by one or more owners.
# Owners are automatically requested for review on matching PRs.
# More info: https://docs.github.com/articles/about-code-owners
# =============================================================================

# Global fallback — replace with your team / GitHub username
*                   @your-org/core-team

# Infrastructure and CI
.github/            @your-org/platform-team
scripts/            @your-org/platform-team

# Security-sensitive areas require security team review
.env.example        @your-org/security-team
.github/workflows/  @your-org/security-team
CODEOWNERS_EOF

# =============================================================================
# 4c. .github/hooks/pre-commit  — prevent secrets from being committed
# =============================================================================
echo
echo -e "${BOLD}── 4c. Git pre-commit hook ───────────────────────────────────────────────${RESET}"

write_file ".github/hooks/pre-commit" <<'PRECOMMIT_EOF'
#!/bin/bash
# =============================================================================
# Pre-commit hook — blocks accidental secret commits (OWASP A02)
# =============================================================================
# Install:   ln -sf ../../.github/hooks/pre-commit .git/hooks/pre-commit
# Uninstall: rm .git/hooks/pre-commit
# =============================================================================

set -euo pipefail

RED='\033[0;31m'
YELLOW='\033[1;33m'
RESET='\033[0m'

# Patterns that should never be committed
FORBIDDEN_PATTERNS=(
  "PRIVATE KEY"
  "BEGIN CERTIFICATE"
  "api[_-]?key"
  "secret[_-]?key"
  "password[=:]"
  "token[=:]"
  "credentials"
  "AWS_SECRET"
  "STRIPE_SECRET"
)

# Files that should never be staged
FORBIDDEN_FILES=(
  ".env"
  "*.key"
  "*.pem"
  "*.p12"
  "*.pfx"
)

LEAKED=false

# Check for patterns in staged files
while IFS= read -r file; do
  [[ -z "$file" ]] && continue
  for pattern in "${FORBIDDEN_PATTERNS[@]}"; do
    if git show ":$file" 2>/dev/null | grep -qi "$pattern"; then
      echo -e "${RED}✗ Secret pattern detected in $file: $pattern${RESET}"
      LEAKED=true
    fi
  done
done < <(git diff --cached --name-only)

# Check for forbidden file paths in staged files
while IFS= read -r file; do
  [[ -z "$file" ]] && continue
  for forbidden in "${FORBIDDEN_FILES[@]}"; do
    if [[ "$file" == *"$forbidden" ]]; then
      echo -e "${RED}✗ Forbidden file staged: $file${RESET}"
      LEAKED=true
    fi
  done
done < <(git diff --cached --name-only)

if [[ "$LEAKED" == true ]]; then
  echo -e "${RED}Commit blocked: secrets detected. Check git diff --cached.${RESET}"
  exit 1
fi

exit 0
PRECOMMIT_EOF

chmod +x ".github/hooks/pre-commit"
success "Created & made executable: .github/hooks/pre-commit"

# Symlink into .git/hooks/ for use
if [[ -d ".git/hooks" ]]; then
  if [[ ! -f ".git/hooks/pre-commit" ]]; then
    ln -sf ../../.github/hooks/pre-commit .git/hooks/pre-commit
    success "Symlinked pre-commit hook into .git/hooks/"
  else
    warn ".git/hooks/pre-commit already exists — manual symlink needed: ln -sf ../../.github/hooks/pre-commit .git/hooks/pre-commit"
  fi
fi

# =============================================================================
# 4d. .github/prompts/  — custom agent prompt templates
# =============================================================================
echo
echo -e "${BOLD}── 4d. Agent prompt templates ─────────────────────────────────────────────${RESET}"

write_file ".github/prompts/README.md" <<'PROMPTS_EOF'
# Custom Agent Prompts

This directory contains reusable prompt templates for common agent workflows.
Reference these when creating new `.github/agents/*.md` files or asking agents to perform specific tasks.

## Usage

### Option 1: Direct reference in agent files
```markdown
See `.github/prompts/code-review.md` for how to structure code reviews.
```

### Option 2: Inline in agent instructions
Copy and adapt templates into your agent YAML frontmatter or `.github/agents/*.md`.

## Available prompts

- `code-review.md` — Guidelines for security and style review
- `testing.md` — Test generation and coverage strategy
- `documentation.md` — Auto-doc generation patterns
PROMPTS_EOF

write_file ".github/prompts/code-review.md" <<'CODEREVIEW_EOF'
# Code Review Prompt

When reviewing code:

1. **Security first** — flag:
   - Unvalidated user input (SQL injection, XSS)
   - Hardcoded secrets or credentials
   - Missing OWASP Top 10 controls
   - Privilege escalation risks

2. **Style & maintainability**:
   - Follow the project's code-style rules in AGENTS.md
   - Check naming conventions (camelCase, UPPER_SNAKE_CASE, etc.)
   - Ensure test coverage (target: ≥80%)
   - Flag overly complex functions (>10 lines → extract)

3. **Completeness**:
   - Tests pass and cover new code
   - No console.log() or debug code left
   - Error handling is explicit (don't swallow errors)
   - Database changes include migrations (if applicable)

4. **Performance**:
   - No N+1 queries without explanation
   - Caching strategy documented
   - Large file operations handled efficiently
CODEREVIEW_EOF

write_file ".github/prompts/testing.md" <<'TESTING_EOF'
# Testing Prompt

When generating or improving tests:

1. **Unit tests** (`tests/unit/`):
   - Test one function per describe block
   - Cover happy path + at least 2 error cases
   - Use descriptive test names: `should throw when email is missing`
   - Mock external dependencies

2. **Integration tests** (`tests/integration/`):
   - Test component interactions (e.g., API → DB)
   - Use test fixtures or factories, not live data
   - Clean up state after each test
   - Document why integration tests exist

3. **E2E tests** (`tests/e2e/`):
   - Reserved for critical user workflows only
   - Use realistic data
   - Assert on observable outcomes (UI, API responses)
   - Keep E2E tests < 10% of total test suite

4. **Coverage**:
   - Never remove a failing test
   - Target: ≥80% line + branch coverage
   - Report coverage with: `npm test -- --coverage`
TESTING_EOF

write_file ".github/prompts/documentation.md" <<'DOCUMENTATION_EOF'
# Documentation Prompt

When writing or updating docs:

1. **Audience**: Write for developers new to the codebase, not experts.

2. **Structure**:
   - Start with the "why" before the "how"
   - Use real code examples, not pseudo-code
   - Include before/after comparisons where helpful
   - Link to related docs instead of duplicating

3. **API docs**:
   - Document parameters with types and constraints
   - Show at least one working example
   - Document error cases explicitly
   - Note any breaking changes

4. **Readability**:
   - Use code syntax highlighting (`typescript`, `bash`, etc.)
   - Keep paragraphs to 3–4 sentences max
   - Use tables for structured information
   - Avoid jargon without defining it first
DOCUMENTATION_EOF

# =============================================================================
# 4e. .github/agents/  — individual agent personas
# =============================================================================
echo
echo -e "${BOLD}── 4e. Agent personas in .github/agents/ ──────────────────────────────────${RESET}"

write_file ".github/agents/test-agent.md" <<'TESTAGENT_EOF'
---
name: test-agent
description: Write and maintain unit and integration tests
---

You are a QA engineer specializing in test automation.

## Role

- You write comprehensive, deterministic unit and integration tests
- You understand the codebase and testing patterns
- Your goal: ensure every feature has passing tests before merging

## Project knowledge

- **Test framework:** Jest + ts-jest
- **Test locations:** `tests/unit/`, `tests/integration/`, `tests/e2e/`
- **Coverage goal:** ≥80% branches + lines

## Commands

- `npm test` — run all tests
- `npm test -- --testPathPattern=<pattern>` — run tests by filename
- `npm test -- --coverage` — run with coverage report

## Standards

- Test names are descriptive: `should return 404 when user not found`, not `test 1`
- Each describe block tests one function
- Use test fixtures (factories, mocks) for setup
- Happy path + at least 2 error cases per function
- Never remove a failing test without fixing it or getting approval

## Boundaries

- ✅ **Always:** Write to `tests/`, make tests pass, run coverage
- ⚠️ **Ask first:** Modify test framework config, add new dependencies
- 🚫 **Never:** Modify source code in `src/`, remove failing tests, skip assertions
TESTAGENT_EOF

write_file ".github/agents/lint-agent.md" <<'LINTAGENT_EOF'
---
name: lint-agent
description: Fix linting errors and enforce code style
---

You are a code quality engineer focused on consistency and style.

## Role

- You fix ESLint violations and formatting issues
- You ensure code follows the project's style guide
- Your goal: pass all lint checks before merge

## Project knowledge

- **Style rules:** See AGENTS.md (single quotes, 2-space indent, no semicolons)
- **Linter:** ESLint with TypeScript support
- **Formatter:** Prettier

## Commands

- `npm run lint` — check for violations
- `npm run lint -- --fix` — auto-fix all fixable violations
- `npm run format` — run Prettier
- `npm run typecheck` — verify TypeScript

## Standards

- Follow TypeScript strict mode
- Naming: camelCase for vars/functions, PascalCase for classes/types, UPPER_SNAKE_CASE for constants
- No `any` types without explicit `// @ts-expect-error` comment
- No unused imports, variables, or parameters

## Boundaries

- ✅ **Always:** Fix style, run lint --fix, pass all checks
- ⚠️ **Ask first:** Modify ESLint config, change naming conventions
- 🚫 **Never:** Change code logic to fix linting, disable rules with eslint-disable
LINTAGENT_EOF

write_file ".github/agents/docs-agent.md" <<'DOCSAGENT_EOF'
---
name: docs-agent
description: Write and maintain project documentation
---

You are a technical writer focused on clarity and completeness.

## Role

- You read code from `src/` and generate documentation
- You update README, API reference, and architecture docs
- Your goal: make the codebase understandable to newcomers

## Project knowledge

- **Tech Stack:** TypeScript, Jest, Express/Fastify (update as needed)
- **Doc locations:** `docs/` for human-facing, `AGENTS.md` for agents
- **Audience:** developers new to the project

## Commands

- None required — read code and write docs only

## Standards

- Write for clarity: one idea per paragraph, concrete examples
- Use real code snippets with syntax highlighting
- Include before/after comparisons where helpful
- Link to related docs; don't duplicate information
- Update docs when code changes significantly

## Boundaries

- ✅ **Always:** Write to `docs/`, follow markdown style, include examples
- ⚠️ **Ask first:** Before major restructuring of existing docs
- 🚫 **Never:** Modify source code in `src/`, commit unfinished draft docs
DOCSAGENT_EOF

write_file ".github/agents/security-agent.md" <<'SECAGENT_EOF'
---
name: security-agent
description: Review code for security vulnerabilities
---

You are a security engineer focused on OWASP best practices.

## Role

- You review code for common security vulnerabilities
- You flag credential exposure, injection risks, and auth issues
- Your goal: prevent security regressions

## Project knowledge

- **Baseline:** OWASP Top 10 (A01–A10)
- **Critical issues:** Hardcoded secrets, SQL injection, XSS, weak auth
- **Standards:** See AGENTS.md security section

## Commands

- `npm run lint` — catches some style issues
- Manual code review for logic flaws

## Standards

- Validate and sanitise all user input at system boundaries
- Use parameterised queries (never string interpolation in SQL)
- No secrets in source code or commit messages
- Error messages should not leak system details
- Authentication must validate tokens before processing requests

## Boundaries

- ✅ **Always:** Flag credential risks, injection vulnerabilities, weak auth
- ⚠️ **Ask first:** Before suggesting major refactors
- 🚫 **Never:** Approve commits with hardcoded secrets
SECAGENT_EOF

# =============================================================================
# 5. .github/CODEOWNERS
# =============================================================================
echo
echo -e "${BOLD}── 5. CODEOWNERS ──────────────────────────────────────────────────────────${RESET}"

write_file ".github/CODEOWNERS" <<'CODEOWNERS_EOF'
# =============================================================================
# CODEOWNERS
# =============================================================================
# Each line is a file pattern followed by one or more owners.
# Owners are automatically requested for review on matching PRs.
# More info: https://docs.github.com/articles/about-code-owners
# =============================================================================

# Global fallback — replace with your team / GitHub username
*                   @your-org/core-team

# Infrastructure and CI
.github/            @your-org/platform-team
scripts/            @your-org/platform-team

# Security-sensitive areas require security team review
.env.example        @your-org/security-team
.github/workflows/  @your-org/security-team
CODEOWNERS_EOF

# =============================================================================
# 11. .vscode/
# =============================================================================
echo
echo -e "${BOLD}── 11. VS Code workspace settings ────────────────────────────────────────${RESET}"

write_file ".vscode/settings.json" <<'VSCODE_SETTINGS_EOF'
{
  // ── Editor ────────────────────────────────────────────────────────────────
  "editor.formatOnSave": true,
  "editor.defaultFormatter": "esbenp.prettier-vscode",
  "editor.codeActionsOnSave": {
    "source.fixAll.eslint": "explicit",
    "source.organizeImports": "explicit"
  },
  "editor.rulers": [80, 120],
  "editor.tabSize": 2,
  "editor.insertSpaces": true,
  "editor.trimAutoWhitespace": true,

  // ── TypeScript ─────────────────────────────────────────────────────────────
  "typescript.tsdk": "node_modules/typescript/lib",
  "typescript.preferences.importModuleSpecifier": "relative",
  "typescript.inlayHints.parameterNames.enabled": "literals",
  "typescript.inlayHints.returnTypes.enabled": true,

  // ── Files ──────────────────────────────────────────────────────────────────
  "files.eol": "\n",
  "files.trimTrailingWhitespace": true,
  "files.insertFinalNewline": true,
  "files.exclude": {
    "node_modules": true,
    "dist": true,
    "coverage": true,
    ".nyc_output": true
  },

  // ── Search ──────────────────────────────────────────────────────────────────
  "search.exclude": {
    "node_modules": true,
    "dist": true,
    "coverage": true,
    "*.lock": true
  },

  // ── Testing ───────────────────────────────────────────────────────────────
  "jest.jestCommandLine": "npm test --",
  "jest.autoRun": "off",

  // ── Git ────────────────────────────────────────────────────────────────────
  "git.autofetch": true,
  "git.confirmSync": false,

  // ── Security: never show secrets in output ─────────────────────────────────
  "terminal.integrated.env.linux": {},
  "terminal.integrated.env.osx": {},
  "terminal.integrated.env.windows": {}
}
VSCODE_SETTINGS_EOF

write_file ".vscode/extensions.json" <<'VSCODE_EXT_EOF'
{
  // Recommended extensions for this project.
  // VS Code will prompt to install these when opening the workspace.
  "recommendations": [
    // ── Language support ───────────────────────────────────────────────────
    "dbaeumer.vscode-eslint",
    "esbenp.prettier-vscode",
    "ms-vscode.vscode-typescript-next",

    // ── Testing ────────────────────────────────────────────────────────────
    "orta.vscode-jest",
    "ms-playwright.playwright",

    // ── Git & GitHub ───────────────────────────────────────────────────────
    "eamodio.gitlens",
    "github.vscode-pull-request-github",
    "github.copilot",
    "github.copilot-chat",

    // ── Productivity ───────────────────────────────────────────────────────
    "streetsidesoftware.code-spell-checker",
    "gruntfuggly.todo-tree",
    "usernamehw.errorlens",
    "aaron-bond.better-comments",

    // ── Database ───────────────────────────────────────────────────────────
    "mtxr.sqltools",

    // ── Containers ─────────────────────────────────────────────────────────
    "ms-azuretools.vscode-docker",

    // ── Security ───────────────────────────────────────────────────────────
    "snyk-security.snyk-vulnerability-scanner"
  ]
}
VSCODE_EXT_EOF

write_file ".vscode/tasks.json" <<'VSCODE_TASKS_EOF'
{
  "version": "2.0.0",
  "tasks": [
    {
      "label": "Build",
      "type": "npm",
      "script": "build",
      "group": { "kind": "build", "isDefault": true },
      "presentation": { "reveal": "silent" },
      "problemMatcher": ["$tsc"]
    },
    {
      "label": "Test",
      "type": "npm",
      "script": "test",
      "group": { "kind": "test", "isDefault": true },
      "presentation": { "reveal": "always" },
      "problemMatcher": []
    },
    {
      "label": "Lint",
      "type": "npm",
      "script": "lint",
      "presentation": { "reveal": "silent" },
      "problemMatcher": ["$eslint-stylish"]
    },
    {
      "label": "Type-check",
      "type": "npm",
      "script": "typecheck",
      "presentation": { "reveal": "silent" },
      "problemMatcher": ["$tsc"]
    }
  ]
}
VSCODE_TASKS_EOF

# =============================================================================
# 12. .editorconfig  — cross-editor consistency
# =============================================================================
echo
echo -e "${BOLD}── 12. .editorconfig ──────────────────────────────────────────────────────${RESET}"

write_file ".editorconfig" <<'EDITORCONFIG_EOF'
# EditorConfig — https://editorconfig.org
root = true

[*]
charset = utf-8
end_of_line = lf
indent_style = space
indent_size = 2
trim_trailing_whitespace = true
insert_final_newline = true

[*.md]
trim_trailing_whitespace = false   # Markdown uses trailing spaces for line breaks

[Makefile]
indent_style = tab                 # Make requires tabs

[*.{yml,yaml}]
indent_size = 2
EDITORCONFIG_EOF

# =============================================================================
# 13. Root documentation files
# =============================================================================
echo
echo -e "${BOLD}── 13. Root documentation ────────────────────────────────────────────────${RESET}"

write_file "README.md" <<'README_EOF'
# Project Name

> One-sentence description of what this project does and why it exists.

[![CI](https://github.com/OWNER/REPO/actions/workflows/ci.yml/badge.svg)](https://github.com/OWNER/REPO/actions/workflows/ci.yml)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

---

## Quick start

```bash
# 1. Clone and install
git clone https://github.com/OWNER/REPO.git
cd REPO
npm install

# 2. Configure environment
cp .env.example .env
# Edit .env and fill in real values

# 3. Run in development mode
npm run dev

# 4. Run tests
npm test
```

## Documentation

- [Architecture](docs/architecture.md)
- [API Reference](docs/api.md)
- [Contributing](CONTRIBUTING.md)
- [Changelog](CHANGELOG.md)

## License

[MIT](LICENSE) © Your Name
README_EOF

write_file "CONTRIBUTING.md" <<'CONTRIBUTING_EOF'
# Contributing

Thank you for helping improve this project!

## Getting started

1. Fork the repo and create a branch: `feat/<your-feature>`
2. Install dependencies: `npm install`
3. Copy `.env.example` → `.env` and populate it
4. Make your changes, add tests
5. Run `npm test && npm run lint && npm run typecheck`
6. Open a pull request

## Development workflow

See [AGENTS.md](AGENTS.md) for the exact commands, code-style rules, and
boundaries used in this project.

## Commit messages

Follow [Conventional Commits](https://www.conventionalcommits.org/):

```
feat: add user authentication
fix: correct off-by-one in pagination
docs: update API reference for /users endpoint
```

## Security vulnerabilities

Please **do not** open a public issue for security vulnerabilities.
Email security@yourproject.com with a description and reproduction steps.
CONTRIBUTING_EOF

write_file "CHANGELOG.md" <<'CHANGELOG_EOF'
# Changelog

All notable changes to this project are documented here.

Format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).
Versioning follows [Semantic Versioning](https://semver.org/).

---

## [Unreleased]

### Added
- Initial project scaffold
CHANGELOG_EOF

write_file "LICENSE" <<'LICENSE_EOF'
MIT License

Copyright (c) 2026 Your Name

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
LICENSE_EOF

# =============================================================================
# 14. docs/  — human-readable documentation stubs
# =============================================================================
echo
echo -e "${BOLD}── 14. docs/ stubs ────────────────────────────────────────────────────────${RESET}"

write_file "docs/architecture.md" <<'ARCH_EOF'
# Architecture

> Document the high-level design decisions, system components, and data flows.

## Overview

<!-- TODO: Add architecture diagram (Mermaid or image) -->

## Directory structure

| Path | Purpose |
|------|---------|
| `src/api/` | HTTP route handlers and controllers |
| `src/db/` | Database models, migrations, and query helpers |
| `src/lib/` | Shared utilities with no external side effects |
| `src/middleware/` | Express/Fastify middleware (auth, logging, errors) |
| `src/services/` | Business logic layer |
| `src/types/` | TypeScript type definitions and interfaces |

## Key decisions

<!-- Use Architecture Decision Records (ADRs) in specs/ for significant decisions -->
ARCH_EOF

write_file "docs/api.md" <<'API_EOF'
# API Reference

> Auto-generated docs can be produced with `npm run docs` once configured.

## Base URL

```
http://localhost:3000/api/v1
```

## Authentication

All protected endpoints require a JWT in the `Authorization` header:

```
Authorization: Bearer <token>
```

## Endpoints

<!-- TODO: Document endpoints here or use OpenAPI/Swagger -->
API_EOF

write_file "docs/CONTRIBUTING.md" <<'DOCS_CONTRIBUTING_EOF'
# Documentation Contributing Guide

Documentation lives in `docs/`. Follow these conventions:

- Write for a developer audience new to this codebase
- Use concrete examples over abstract descriptions
- Keep files focused on a single topic
- Link to related docs rather than duplicating content
DOCS_CONTRIBUTING_EOF

# =============================================================================
# 15. specs/ — formal specifications and ADRs
# =============================================================================
echo
echo -e "${BOLD}── 15. specs/ stubs ───────────────────────────────────────────────────────${RESET}"

write_file "specs/README.md" <<'SPECS_EOF'
# Specifications

This directory contains formal specifications, Architecture Decision Records
(ADRs), and RFCs for significant design decisions.

## ADR format

```
specs/adr/
  0001-use-postgresql.md
  0002-jwt-authentication.md
```

Each ADR includes: **Status**, **Context**, **Decision**, **Consequences**.

## Naming convention

- `adr/NNNN-short-title.md` — Architecture Decision Records
- `rfc/NNNN-short-title.md` — Request For Comments (larger proposals)
SPECS_EOF

make_dir specs/adr
make_dir specs/rfc

# =============================================================================
# 16. support-documents/
# =============================================================================
echo
echo -e "${BOLD}── 16. support-documents/ ─────────────────────────────────────────────────${RESET}"

write_file "support-documents/README.md" <<'SUPPORT_EOF'
# Support Documents

Research notes, reference materials, and other supporting documents that
inform but are not part of the deployable codebase.

Files here are typically:
- Research papers and notes
- Design explorations
- Meeting notes
- External references

Large files (datasets, PDFs, etc.) should be stored in external storage
and referenced here by URL, not committed to git.
SUPPORT_EOF

# =============================================================================
# 17. Source stubs (TypeScript skeleton)
# =============================================================================
echo
echo -e "${BOLD}── 17. Source stubs ────────────────────────────────────────────────────────${RESET}"

write_file "src/types/index.ts" <<'TYPES_EOF'
// Central type exports.
// Define domain types here and import from 'src/types' across the codebase.

export interface User {
  id: string
  email: string
  createdAt: Date
}
TYPES_EOF

write_file "src/lib/logger.ts" <<'LOGGER_EOF'
// Minimal structured logger.
// Replace with pino, winston, or your preferred library.

const LOG_LEVEL = process.env.LOG_LEVEL ?? 'info'

export const logger = {
  info: (msg: string, data?: unknown) => {
    if (['info', 'debug'].includes(LOG_LEVEL)) console.log(JSON.stringify({ level: 'info', msg, ...toObj(data) }))
  },
  warn: (msg: string, data?: unknown) => {
    console.warn(JSON.stringify({ level: 'warn', msg, ...toObj(data) }))
  },
  error: (msg: string, data?: unknown) => {
    console.error(JSON.stringify({ level: 'error', msg, ...toObj(data) }))
  },
  debug: (msg: string, data?: unknown) => {
    if (LOG_LEVEL === 'debug') console.log(JSON.stringify({ level: 'debug', msg, ...toObj(data) }))
  },
}

function toObj(data: unknown): Record<string, unknown> {
  if (data == null) return {}
  if (typeof data === 'object') return data as Record<string, unknown>
  return { data }
}
LOGGER_EOF

# =============================================================================
# 18. Test stubs
# =============================================================================
echo
echo -e "${BOLD}── 18. Test stubs ─────────────────────────────────────────────────────────${RESET}"

write_file "tests/unit/logger.test.ts" <<'TEST_EOF'
import { logger } from '../../src/lib/logger'

describe('logger', () => {
  it('exposes info, warn, error, debug methods', () => {
    expect(typeof logger.info).toBe('function')
    expect(typeof logger.warn).toBe('function')
    expect(typeof logger.error).toBe('function')
    expect(typeof logger.debug).toBe('function')
  })
})
TEST_EOF

# =============================================================================
# 19. package.json  (Node/TypeScript project skeleton)
# =============================================================================
echo
echo -e "${BOLD}── 19. package.json ────────────────────────────────────────────────────────${RESET}"

write_file "package.json" <<'PKG_EOF'
{
  "name": "secondbrain",
  "version": "0.1.0",
  "description": "Second brain project",
  "private": true,
  "engines": {
    "node": ">=22"
  },
  "scripts": {
    "build": "tsc --project tsconfig.json",
    "dev": "ts-node --watch src/index.ts",
    "typecheck": "tsc --noEmit",
    "test": "jest",
    "test:watch": "jest --watch",
    "test:coverage": "jest --coverage",
    "lint": "eslint 'src/**/*.ts' 'tests/**/*.ts'",
    "format": "prettier --write 'src/**/*.ts' 'tests/**/*.ts' '*.md'",
    "format:check": "prettier --check 'src/**/*.ts' 'tests/**/*.ts'"
  },
  "devDependencies": {
    "@types/jest": "^29.5.0",
    "@types/node": "^22.0.0",
    "@typescript-eslint/eslint-plugin": "^8.0.0",
    "@typescript-eslint/parser": "^8.0.0",
    "eslint": "^9.0.0",
    "jest": "^29.5.0",
    "prettier": "^3.0.0",
    "ts-jest": "^29.1.0",
    "ts-node": "^10.9.0",
    "typescript": "^5.5.0"
  }
}
PKG_EOF

# =============================================================================
# 20. tsconfig.json
# =============================================================================
echo
echo -e "${BOLD}── 20. tsconfig.json ───────────────────────────────────────────────────────${RESET}"

write_file "tsconfig.json" <<'TS_EOF'
{
  "compilerOptions": {
    "target": "ES2022",
    "module": "commonjs",
    "lib": ["ES2022"],
    "outDir": "./dist",
    "rootDir": "./src",
    "strict": true,
    "esModuleInterop": true,
    "skipLibCheck": true,
    "forceConsistentCasingInFileNames": true,
    "resolveJsonModule": true,
    "declaration": true,
    "declarationMap": true,
    "sourceMap": true,
    "noUnusedLocals": true,
    "noUnusedParameters": true,
    "noImplicitReturns": true,
    "noFallthroughCasesInSwitch": true
  },
  "include": ["src/**/*"],
  "exclude": ["node_modules", "dist", "tests"]
}
TS_EOF

# =============================================================================
# 21. Jest configuration
# =============================================================================
echo
echo -e "${BOLD}── 21. Jest config ─────────────────────────────────────────────────────────${RESET}"

write_file "jest.config.js" <<'JEST_EOF'
/** @type {import('jest').Config} */
module.exports = {
  preset: 'ts-jest',
  testEnvironment: 'node',
  roots: ['<rootDir>/tests'],
  testMatch: ['**/*.test.ts'],
  collectCoverageFrom: ['src/**/*.ts', '!src/**/*.d.ts'],
  coverageThreshold: {
    global: {
      branches: 80,
      lines: 80,
    },
  },
  coverageReporters: ['text', 'lcov'],
}
JEST_EOF

# =============================================================================
# 22. ESLint flat config
# =============================================================================
echo
echo -e "${BOLD}── 22. ESLint config ────────────────────────────────────────────────────────${RESET}"

write_file "eslint.config.js" <<'ESLINT_EOF'
const tsParser = require('@typescript-eslint/parser')
const tsPlugin = require('@typescript-eslint/eslint-plugin')

module.exports = [
  {
    files: ['src/**/*.ts', 'tests/**/*.ts'],
    languageOptions: {
      parser: tsParser,
      parserOptions: {
        project: './tsconfig.json',
      },
    },
    plugins: {
      '@typescript-eslint': tsPlugin,
    },
    rules: {
      ...tsPlugin.configs['recommended'].rules,
      '@typescript-eslint/no-explicit-any': 'error',
      '@typescript-eslint/explicit-function-return-type': 'warn',
      'no-console': 'warn',           // use logger instead
      'no-eval': 'error',             // OWASP A03 injection prevention
      'no-implied-eval': 'error',
      'no-new-func': 'error',
    },
  },
]
ESLINT_EOF

# =============================================================================
# 23. Prettier config
# =============================================================================
echo
echo -e "${BOLD}── 23. Prettier config ──────────────────────────────────────────────────────${RESET}"

write_file ".prettierrc.json" <<'PRETTIER_EOF'
{
  "semi": false,
  "singleQuote": true,
  "trailingComma": "all",
  "printWidth": 100,
  "tabWidth": 2,
  "endOfLine": "lf"
}
PRETTIER_EOF

write_file ".prettierignore" <<'PRETTIERIGNORE_EOF'
node_modules/
dist/
coverage/
*.lock
PRETTIERIGNORE_EOF

# =============================================================================
# 24. .claudeignore  — tell Claude Code which files to skip
# =============================================================================
echo
echo -e "${BOLD}── 24. .claudeignore ────────────────────────────────────────────────────────${RESET}"

write_file ".claudeignore" <<'CLAUDEIGNORE_EOF'
# Files Claude Code should skip when indexing the repository.
# Keep this list focused on noise; don't exclude source files.

node_modules/
dist/
build/
coverage/
*.lock
*.log
.git/
CLAUDEIGNORE_EOF

# =============================================================================
# 25. Git initial commit
# =============================================================================
echo
echo -e "${BOLD}── 25. Initial git commit ───────────────────────────────────────────────────${RESET}"

git add -A
git commit --message "chore: initial scaffold

Generated by scripts/scaffold-project.sh

- AGENTS.md with minimal, research-backed agent context
- .github/copilot-instructions.md → ../AGENTS.md (symlink)
- CLAUDE.md → AGENTS.md (symlink)
- .github: PR template, issue templates, CI, security workflows
- .vscode: settings, extensions, tasks
- .gitignore: secrets and large-file protection
- .env.example: documented env vars without real values
- src/, tests/, docs/, specs/, scripts/, support-documents/
- package.json, tsconfig.json, jest.config.js, eslint.config.js

Scaffold principles based on arXiv:2602.11988 (Gloaguen et al., 2026):
AGENTS.md contains only minimal, non-redundant requirements."

echo
echo -e "${GREEN}${BOLD}============================================================${RESET}"
echo -e "${GREEN}${BOLD}  Scaffold complete!${RESET}"
echo -e "${GREEN}${BOLD}============================================================${RESET}"
echo
echo -e "  Next steps:"
echo -e "  1. ${CYAN}Update AGENTS.md${RESET} with your real build/test commands"
echo -e "  2. ${CYAN}Edit .env.example${RESET} to match your actual env vars"
echo -e "  3. ${CYAN}Update README.md${RESET} with your project description"
echo -e "  4. ${CYAN}Replace placeholders${RESET} in .github/CODEOWNERS and workflows"
echo -e "  5. ${CYAN}npm install${RESET} to pull down dev dependencies"
echo
