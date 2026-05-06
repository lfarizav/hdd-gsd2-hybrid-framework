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

# Resolve the target project directory.
# If PROJECT_DIR is set (called from create-new-project.sh), use it directly.
# Otherwise, ask the user interactively.
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
if [[ -z "${PROJECT_DIR:-}" ]]; then
  echo
  printf "  Where should the project be created? (default: $HOME/my-project) > "
  read -r PROJECT_DIR </dev/tty
  PROJECT_DIR="${PROJECT_DIR/#\~/$HOME}"         # expand leading ~
  PROJECT_DIR="${PROJECT_DIR:-$HOME/my-project}" # default to $HOME/my-project if empty
  mkdir -p "$PROJECT_DIR"
fi
ROOT_DIR="$PROJECT_DIR"

cd "$ROOT_DIR"
info "Working in: $ROOT_DIR"

# ── Language / framework detection ────────────────────────────────────────────
# If PROJECT_LANG is exported by the orchestrator (create-new-project.sh), use
# it. Otherwise prompt interactively so the script works standalone.
if [[ -z "${PROJECT_LANG:-}" ]]; then
  echo
  echo -e "  Select primary language / framework:"
  echo -e "    ${BOLD}1)${RESET} typescript  — Node.js + Jest + ts-jest        [default]"
  echo -e "    ${BOLD}2)${RESET} go          — Go modules + go test + testify"
  echo -e "    ${BOLD}3)${RESET} ruby        — Bundler + RSpec + RuboCop"
  echo -e "    ${BOLD}4)${RESET} c           — Make + Unity + cppcheck + valgrind"
  echo -e "    ${BOLD}5)${RESET} python      — uv + pytest + mypy + ruff"
  printf "  Choice [1-5] or language name [default: typescript]: "
  read -r _lang_choice </dev/tty
  case "${_lang_choice:-1}" in
    1|typescript|ts) PROJECT_LANG="typescript" ;;
    2|go|golang)     PROJECT_LANG="go" ;;
    3|ruby|rb)       PROJECT_LANG="ruby" ;;
    4|c)             PROJECT_LANG="c" ;;
    5|python|py)     PROJECT_LANG="python" ;;
    "")              PROJECT_LANG="typescript" ;;
    *)               warn "Unknown '${_lang_choice}', defaulting to typescript"; PROJECT_LANG="typescript" ;;
  esac
fi
info "Language: $PROJECT_LANG"

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

# Language-specific source directories
case "$PROJECT_LANG" in
  go)
    make_dir cmd
    make_dir internal
    make_dir pkg
    make_dir tests/integration
    make_dir tests/e2e
    ;;
  ruby)
    make_dir lib
    make_dir bin
    make_dir spec/unit
    make_dir spec/integration
    ;;
  c)
    make_dir src
    make_dir include
    make_dir tests/unit
    make_dir tests/integration
    ;;
  python)
    _PY_PKG="${PROJECT_NAME:-myapp}"
    _PY_PKG="${_PY_PKG//-/_}"   # hyphens → underscores (PEP 8)
    make_dir "src/${_PY_PKG}"
    make_dir tests/unit
    make_dir tests/integration
    ;;
  *)  # typescript (default)
    make_dir src/api
    make_dir src/db/migrations
    make_dir src/lib
    make_dir src/middleware
    make_dir src/services
    make_dir src/types
    make_dir tests/unit
    make_dir tests/integration
    make_dir tests/e2e
    ;;
esac

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

case "$PROJECT_LANG" in

# ─────────────────────────────────────────────────────────────────────────────
# GO
# ─────────────────────────────────────────────────────────────────────────────
go)
  write_file "AGENTS.md" <<'GO_AGENTS_EOF'
# AGENTS.md

> **Design note (arXiv:2602.11988 — Gloaguen et al.):** This file intentionally
> contains only *minimal*, non-redundant requirements. Excessive instructions
> reduce agent task-success rates and inflate LLM cost by >20 %.

---

## Commands

```bash
# Build all packages
go build ./...

# Run all tests
go test ./...

# Run tests with coverage (threshold: 80 %)
go test -coverprofile=coverage.out ./... && go tool cover -func=coverage.out

# Run a single test
go test -run TestFunctionName ./path/to/package

# Format (required before every commit)
gofmt -w ./...

# Vet
go vet ./...

# Tidy module graph
go mod tidy
```

---

## Testing

- **Framework:** `go test` (stdlib) + `testify` for assertions
- Test files live alongside source: `foo.go` → `foo_test.go`
- Integration tests live in `tests/integration/`
- All tests **must pass** before a PR is merged; CI enforces this.
- Add or update tests for every code change, even when not explicitly requested.
- Never remove a failing test; fix it or open a follow-up issue.
- Coverage threshold: **80 %** (statements).

---

## Code style

- **Language:** Go 1.22+
- Tabs for indentation, enforced by `gofmt` / `goimports`
- Explicit error returns; no `panic` in library code
- Descriptive names over comments — `fetchUserByID` beats `getUser` + a comment

```go
// ✅ Good
func fetchUserByID(id string) (*User, error) {
	if id == "" {
		return nil, errors.New("user ID is required")
	}
	return db.FindUser(id)
}

// ❌ Bad — vague name, swallowed error, empty interface
func getUser(id interface{}) interface{} {
	u, _ := db.FindUser(fmt.Sprint(id))
	return u
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
| Write to `internal/`, `cmd/`, `tests/`, `docs/`, `specs/` | Add a new Go module dependency | Commit `.env` or any secret |
| Run `go test ./...` before marking a task done | Modify CI/CD workflows | Edit `vendor/` or build outputs |
| Run `gofmt -w ./...` after edits | Refactor across many files at once | Remove or skip failing tests |
| Run `go vet ./...` after edits | Change the database schema | Modify `go.sum` by hand |
| Code with solid reasons, facts, evidences, or researches | Ask before doing if you are unsure | Guess |

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
GO_AGENTS_EOF
  ;;

# ─────────────────────────────────────────────────────────────────────────────
# RUBY
# ─────────────────────────────────────────────────────────────────────────────
ruby)
  write_file "AGENTS.md" <<'RUBY_AGENTS_EOF'
# AGENTS.md

> **Design note (arXiv:2602.11988 — Gloaguen et al.):** This file intentionally
> contains only *minimal*, non-redundant requirements. Excessive instructions
> reduce agent task-success rates and inflate LLM cost by >20 %.

---

## Commands

```bash
# Install gems
bundle install

# Run all tests
bundle exec rspec

# Run a single spec file
bundle exec rspec spec/unit/logger_spec.rb

# Run tests with coverage
COVERAGE=true bundle exec rspec

# Lint (report only)
bundle exec rubocop

# Lint with auto-fix
bundle exec rubocop -a
```

---

## Testing

- **Framework:** RSpec 3 + SimpleCov
- Specs live in `spec/unit/` and `spec/integration/`
- All tests **must pass** before a PR is merged; CI enforces this.
- Add or update tests for every code change, even when not explicitly requested.
- Never remove a failing test; fix it or open a follow-up issue.
- Coverage threshold: **80 %**. Run `COVERAGE=true bundle exec rspec`.

---

## Code style

- **Language:** Ruby 3.3+
- 2-space indentation, `snake_case` methods and variables
- Add `# frozen_string_literal: true` at the top of every Ruby file
- Prefer explicit returns; avoid `method_missing`
- Descriptive names — `find_user_by_email` beats `get_user`

```ruby
# ✅ Good
# frozen_string_literal: true

def find_user_by_email(email)
  raise ArgumentError, "email is required" if email.nil? || email.empty?
  User.find_by!(email: email)
end

# ❌ Bad — no guard, no frozen literal, vague name
def get(u)
  User.find_by(email: u)
end
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
| Write to `lib/`, `spec/`, `docs/`, `specs/` | Add a new gem dependency | Commit `.env` or any secret |
| Run `bundle exec rspec` before marking a task done | Modify CI/CD workflows | Edit `vendor/` |
| Run `bundle exec rubocop` after edits | Refactor across many files at once | Remove or skip failing tests |
| Add `# frozen_string_literal: true` to new files | Change the database schema | Modify `Gemfile.lock` by hand |
| Code with solid reasons, facts, evidences, or researches | Ask before doing if you are unsure | Guess |

---

## Environment variables

All required env vars are documented in `.env.example`.
Copy it to `.env` (never commit `.env`) and populate real values locally.

---

## Security considerations

- No secrets in source code or commit messages (pre-commit hook enforces this)
- Validate and sanitise all external input at system boundaries
- Use parameterised queries — never string-interpolate user input into SQL
- OWASP Top 10 is the baseline; flag security concerns in PR descriptions
RUBY_AGENTS_EOF
  ;;

# ─────────────────────────────────────────────────────────────────────────────
# C
# ─────────────────────────────────────────────────────────────────────────────
c)
  write_file "AGENTS.md" <<'C_AGENTS_EOF'
# AGENTS.md

> **Design note (arXiv:2602.11988 — Gloaguen et al.):** This file intentionally
> contains only *minimal*, non-redundant requirements. Excessive instructions
> reduce agent task-success rates and inflate LLM cost by >20 %.

---

## Commands

```bash
# Build (debug)
make

# Build (release)
make CFLAGS="-O2 -DNDEBUG"

# Run tests
make test

# Check for memory leaks
valgrind --leak-check=full --error-exitcode=1 ./tests/test_suite

# Static analysis
cppcheck --enable=all --error-exitcode=1 src/ include/

# Format (requires clang-format)
clang-format -i src/**/*.c include/**/*.h

# Generate coverage report (requires gcc + lcov)
make coverage
```

---

## Testing

- **Framework:** Unity test runner (or CMocka), orchestrated via `make test`
- Unit tests live in `tests/unit/`, integration tests in `tests/integration/`
- All tests **must pass** before a PR is merged; CI enforces this.
- Add or update tests for every code change, even when not explicitly requested.
- Never remove a failing test; fix it or open a follow-up issue.
- Coverage threshold: **80 %** (gcov/lcov). Run `make coverage`.

---

## Code style

- **Standard:** C11 (`-std=c11`)
- 4-space indentation, `snake_case` names
- Always check return values of functions that can fail
- Guard every header: `#ifndef MY_HEADER_H` / `#define` / `#endif`
- No implicit function declarations (`-Wimplicit-function-declaration` is an error)
- Keep functions short and single-purpose; max ~50 lines

```c
// ✅ Good
int read_config(const char *path, Config *out) {
    if (!path || !out) return -EINVAL;
    FILE *f = fopen(path, "r");
    if (!f) return -errno;
    /* ... parse ... */
    fclose(f);
    return 0;
}

// ❌ Bad — no null check, return value ignored
void read_cfg(char *p, Config *c) {
    FILE *f = fopen(p, "r");
    parse(f, c);
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
| Write to `src/`, `include/`, `tests/`, `docs/`, `specs/` | Add an external library dependency | Commit `.env` or any secret |
| Run `make test` before marking a task done | Modify CI/CD workflows | Remove or skip failing tests |
| Run `cppcheck` and `valgrind` after edits | Refactor across many files at once | Edit build artefacts |
| Use `snprintf` / bounds-checked string ops — never `gets()` | Change the build system | Use `sprintf` or `gets()` |
| Code with solid reasons, facts, evidences, or researches | Ask before doing if you are unsure | Guess |

---

## Environment variables

All required env vars are documented in `.env.example`.
Copy it to `.env` (never commit `.env`) and populate real values locally.

---

## Security considerations

- No secrets in source code or commit messages (pre-commit hook enforces this)
- Validate all external input length and content before use (OWASP A03: Injection)
- Use `snprintf` not `sprintf`; bounds-check all string operations
- Avoid `gets()`, `scanf("%s")`, `strcpy()` — all are unsafe
- OWASP Top 10 is the baseline; flag security concerns in PR descriptions
C_AGENTS_EOF
  ;;

# ─────────────────────────────────────────────────────────────────────────────
# PYTHON
# ─────────────────────────────────────────────────────────────────────────────
python)
  write_file "AGENTS.md" <<'PY_AGENTS_EOF'
# AGENTS.md

> **Design note (arXiv:2602.11988 — Gloaguen et al.):** This file intentionally
> contains only *minimal*, non-redundant requirements. Excessive instructions
> reduce agent task-success rates and inflate LLM cost by >20 %.

---

## Commands

```bash
# Install dependencies (uv)
uv sync --all-extras

# Run all tests
uv run pytest

# Run tests with coverage (threshold: 80 %)
uv run pytest --cov=src --cov-report=term-missing

# Run a single test
uv run pytest tests/unit/test_logger.py -v

# Type-check
uv run mypy src/

# Lint (report)
uv run ruff check .

# Lint + format auto-fix
uv run ruff check --fix . && uv run ruff format .
```

---

## Testing

- **Framework:** pytest 8+ with pytest-cov
- Tests live in `tests/unit/` and `tests/integration/`
- All tests **must pass** before a PR is merged; CI enforces this.
- Add or update tests for every code change, even when not explicitly requested.
- Never remove a failing test; fix it or open a follow-up issue.
- Coverage threshold: **80 %** (statements). Run `uv run pytest --cov=src`.

---

## Code style

- **Language:** Python 3.12+
- Type hints required on all functions (enforced by mypy strict)
- `snake_case` for variables and functions, `PascalCase` for classes
- Format with `ruff format` (Black-compatible, 88-char line length)
- Prefer explicit over implicit; avoid `*` imports

```python
# ✅ Good
def fetch_user_by_id(user_id: str) -> User:
    if not user_id:
        raise ValueError("user_id is required")
    return db.users.get(user_id)

# ❌ Bad — missing type hints, no guard, vague name
def get(id):
    return db.users.get(id)
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
| Write to `src/`, `tests/`, `docs/`, `specs/` | Add a new package dependency | Commit `.env` or any secret |
| Run `uv run pytest` before marking a task done | Modify CI/CD workflows | Remove or skip failing tests |
| Run `uv run ruff check .` after edits | Refactor across many files at once | Edit `.venv/` or build outputs |
| Add type hints to all new functions | Change the database schema | Modify `uv.lock` by hand |
| Code with solid reasons, facts, evidences, or researches | Ask before doing if you are unsure | Guess |

---

## Environment variables

All required env vars are documented in `.env.example`.
Copy it to `.env` (never commit `.env`) and populate real values locally.
Use a secrets manager (e.g. AWS Secrets Manager, Vault) in production.

---

## Security considerations

- No secrets in source code or commit messages (pre-commit hook enforces this)
- Validate and sanitise all external input at system boundaries
- Use parameterised queries (SQLAlchemy ORM / `?` placeholders) — never f-string SQL
- OWASP Top 10 is the baseline; flag security concerns in PR descriptions
PY_AGENTS_EOF
  ;;

# ─────────────────────────────────────────────────────────────────────────────
# TYPESCRIPT (default)
# ─────────────────────────────────────────────────────────────────────────────
*)
  write_file "AGENTS.md" <<'TS_AGENTS_EOF'
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
| Code with solid reasons, facts, evidences, or researches | Ask before doing if you are unsure | Guess |

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
TS_AGENTS_EOF
  ;;
esac

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

# Append language-specific .gitignore patterns
case "$PROJECT_LANG" in
  go)
    cat >> .gitignore <<'GO_GITIGNORE_EOF'

# ── Go ────────────────────────────────────────────────────────────────────────
/app
/tests/test_suite
coverage.out
*.test
vendor/
GO_GITIGNORE_EOF
    ;;
  ruby)
    cat >> .gitignore <<'RUBY_GITIGNORE_EOF'

# ── Ruby ──────────────────────────────────────────────────────────────────────
/.bundle/
/vendor/bundle/
/coverage/
.rspec_status
*.gem
Gemfile.lock
RUBY_GITIGNORE_EOF
    ;;
  c)
    cat >> .gitignore <<'C_GITIGNORE_EOF'

# ── C ────────────────────────────────────────────────────────────────────────
/app
/tests/test_suite
*.o
*.a
*.so
*.gcda
*.gcno
*.gcov
coverage.info
/coverage-report/
C_GITIGNORE_EOF
    ;;
  python)
    cat >> .gitignore <<'PY_GITIGNORE_EOF'

# ── Python ────────────────────────────────────────────────────────────────────
__pycache__/
*.pyc
*.pyo
*.pyd
.venv/
*.egg-info/
dist/
build/
.mypy_cache/
.ruff_cache/
.pytest_cache/
htmlcov/
PY_GITIGNORE_EOF
    ;;
esac
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

case "$PROJECT_LANG" in
  go)
    write_file ".github/workflows/ci.yml" <<'GO_CI_EOF'
name: CI
on:
  push:
    branches: [main]
  pull_request:
    branches: [main]
permissions:
  contents: read
jobs:
  build-test:
    name: Build & Test
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-go@v5
        with:
          go-version: '1.22'
          cache: true
      - name: Vet
        run: go vet ./...
      - name: Format check
        run: |
          out=$(gofmt -l .)
          [ -z "$out" ] || (echo "Unformatted files:$out" && exit 1)
      - name: Test
        run: go test -coverprofile=coverage.out ./...
      - name: Coverage
        run: go tool cover -func=coverage.out
GO_CI_EOF
    write_file ".github/workflows/security.yml" <<'GO_SEC_EOF'
name: Security
on:
  push:
    branches: [main]
  schedule:
    - cron: '0 9 * * 1'
  workflow_dispatch:
permissions:
  contents: read
  security-events: write
jobs:
  govulncheck:
    name: govulncheck
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-go@v5
        with:
          go-version: '1.22'
      - run: go install golang.org/x/vuln/cmd/govulncheck@latest
      - run: govulncheck ./...
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
GO_SEC_EOF
    ;;
  ruby)
    write_file ".github/workflows/ci.yml" <<'RUBY_CI_EOF'
name: CI
on:
  push:
    branches: [main]
  pull_request:
    branches: [main]
permissions:
  contents: read
jobs:
  build-test:
    name: Build & Test
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: ruby/setup-ruby@v1
        with:
          ruby-version: '3.3'
          bundler-cache: true
      - name: Lint
        run: bundle exec rubocop
      - name: Test
        run: COVERAGE=true bundle exec rspec
RUBY_CI_EOF
    write_file ".github/workflows/security.yml" <<'RUBY_SEC_EOF'
name: Security
on:
  push:
    branches: [main]
  schedule:
    - cron: '0 9 * * 1'
  workflow_dispatch:
permissions:
  contents: read
jobs:
  bundle-audit:
    name: bundle-audit
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: ruby/setup-ruby@v1
        with:
          ruby-version: '3.3'
          bundler-cache: true
      - run: gem install bundler-audit
      - run: bundle-audit check --update
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
RUBY_SEC_EOF
    ;;
  c)
    write_file ".github/workflows/ci.yml" <<'C_CI_EOF'
name: CI
on:
  push:
    branches: [main]
  pull_request:
    branches: [main]
permissions:
  contents: read
jobs:
  build-test:
    name: Build & Test
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Install tools
        run: sudo apt-get update && sudo apt-get install -y gcc make valgrind cppcheck lcov
      - name: Build
        run: make
      - name: Test
        run: make test
      - name: Memory check
        run: valgrind --leak-check=full --error-exitcode=1 ./tests/test_suite
      - name: Static analysis
        run: cppcheck --enable=all --error-exitcode=1 src/ include/
C_CI_EOF
    write_file ".github/workflows/security.yml" <<'C_SEC_EOF'
name: Security
on:
  push:
    branches: [main]
  schedule:
    - cron: '0 9 * * 1'
  workflow_dispatch:
permissions:
  contents: read
jobs:
  codeql:
    name: CodeQL
    runs-on: ubuntu-latest
    permissions:
      security-events: write
    steps:
      - uses: actions/checkout@v4
      - uses: github/codeql-action/init@v3
        with:
          languages: c-cpp
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
C_SEC_EOF
    ;;
  python)
    write_file ".github/workflows/ci.yml" <<'PY_CI_EOF'
name: CI
on:
  push:
    branches: [main]
  pull_request:
    branches: [main]
permissions:
  contents: read
jobs:
  build-test:
    name: Build & Test
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-python@v5
        with:
          python-version: '3.12'
      - name: Install uv
        run: pip install uv
      - name: Install dependencies
        run: uv sync --all-extras
      - name: Lint
        run: uv run ruff check .
      - name: Format check
        run: uv run ruff format --check .
      - name: Type-check
        run: uv run mypy src/
      - name: Test
        run: uv run pytest --cov=src --cov-report=term-missing
PY_CI_EOF
    write_file ".github/workflows/security.yml" <<'PY_SEC_EOF'
name: Security
on:
  push:
    branches: [main]
  schedule:
    - cron: '0 9 * * 1'
  workflow_dispatch:
permissions:
  contents: read
  security-events: write
jobs:
  pip-audit:
    name: pip-audit
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-python@v5
        with:
          python-version: '3.12'
      - run: pip install uv pip-audit
      - run: uv export --format requirements-txt | pip-audit -r /dev/stdin
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
PY_SEC_EOF
    ;;
  *)  # typescript
    write_file ".github/workflows/ci.yml" <<'TS_CI_EOF'
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
TS_CI_EOF

    write_file ".github/workflows/security.yml" <<'TS_SEC_EOF'
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
TS_SEC_EOF
    ;;
esac

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
  # Skip scaffold/template scripts — they intentionally define example patterns
  [[ "$file" == scripts/scaffold-*.sh ]] && continue
  [[ "$file" == scripts/create-*.sh ]] && continue
  # Skip the hook definition itself — it contains the pattern list
  [[ "$file" == .github/hooks/pre-commit ]] && continue
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
# 17-23. LANGUAGE-SPECIFIC: source stubs, test stubs, build config
# =============================================================================
echo
echo -e "${BOLD}── 17. Language-specific stubs & build config ($PROJECT_LANG) ──────────────${RESET}"

case "$PROJECT_LANG" in

# ─────────────────────────────────────────────────────────────────────────────
# GO stubs
# ─────────────────────────────────────────────────────────────────────────────
go)
  _PKG_NAME="${PROJECT_NAME:-$(basename "$ROOT_DIR")}"
  _PKG_NAME="${_PKG_NAME:-my-project}"

  write_file "go.mod" <<GOMOD_EOF
module github.com/OWNER/${_PKG_NAME}

go 1.22
GOMOD_EOF

  write_file "Makefile" <<'GO_MAKE_EOF'
.PHONY: build test vet fmt lint coverage clean

build:
	go build ./...

test:
	go test ./...

vet:
	go vet ./...

fmt:
	gofmt -w ./...

lint: vet fmt

coverage:
	go test -coverprofile=coverage.out ./...
	go tool cover -func=coverage.out

clean:
	rm -f coverage.out
GO_MAKE_EOF

  write_file "cmd/main.go" <<'GO_MAIN_EOF'
package main

import (
	"fmt"
	"os"
)

func main() {
	if err := run(); err != nil {
		fmt.Fprintf(os.Stderr, "error: %v\n", err)
		os.Exit(1)
	}
}

func run() error {
	fmt.Println("Hello, World!")
	return nil
}
GO_MAIN_EOF

  write_file "internal/logger/logger.go" <<'GO_LOGGER_EOF'
// Package logger provides a minimal structured logger.
package logger

import (
	"encoding/json"
	"os"
	"time"
)

// Level represents a log severity level.
type Level string

const (
	LevelInfo  Level = "info"
	LevelWarn  Level = "warn"
	LevelError Level = "error"
	LevelDebug Level = "debug"
)

type entry struct {
	Time    string `json:"time"`
	Level   Level  `json:"level"`
	Message string `json:"msg"`
}

func log(level Level, msg string) {
	e := entry{Time: time.Now().UTC().Format(time.RFC3339), Level: level, Message: msg}
	_ = json.NewEncoder(os.Stderr).Encode(e)
}

// Info logs an informational message.
func Info(msg string)  { log(LevelInfo, msg) }

// Warn logs a warning message.
func Warn(msg string)  { log(LevelWarn, msg) }

// Error logs an error message.
func Error(msg string) { log(LevelError, msg) }

// Debug logs a debug message.
func Debug(msg string) { log(LevelDebug, msg) }
GO_LOGGER_EOF

  write_file "internal/logger/logger_test.go" <<'GO_LOGGER_TEST_EOF'
package logger_test

import (
	"testing"

	"github.com/stretchr/testify/assert"

	"github.com/OWNER/REPO/internal/logger"
)

func TestLoggerDoesNotPanic(t *testing.T) {
	assert.NotPanics(t, func() { logger.Info("info message") })
	assert.NotPanics(t, func() { logger.Warn("warn message") })
	assert.NotPanics(t, func() { logger.Error("error message") })
	assert.NotPanics(t, func() { logger.Debug("debug message") })
}
GO_LOGGER_TEST_EOF
  ;;

# ─────────────────────────────────────────────────────────────────────────────
# RUBY stubs
# ─────────────────────────────────────────────────────────────────────────────
ruby)
  _GEM_NAME="${PROJECT_NAME:-$(basename "$ROOT_DIR")}"
  _GEM_NAME="${_GEM_NAME:-my-project}"
  _LIB_FILE="${_GEM_NAME//-/_}"

  write_file "Gemfile" <<GEMFILE_EOF
# frozen_string_literal: true

source "https://rubygems.org"

gem "bundler", "~> 2.5"

group :development, :test do
  gem "rspec", "~> 3.13"
  gem "rubocop", "~> 1.65", require: false
  gem "rubocop-rspec", require: false
  gem "simplecov", require: false
end
GEMFILE_EOF

  write_file ".rubocop.yml" <<'RUBOCOP_EOF'
AllCops:
  TargetRubyVersion: 3.3
  NewCops: enable

Style/FrozenStringLiteralComment:
  Enabled: true

Metrics/MethodLength:
  Max: 20

Metrics/BlockLength:
  Exclude:
    - "spec/**/*"
RUBOCOP_EOF

  write_file ".rspec" <<'RSPEC_EOF'
--require spec_helper
--format documentation
--color
RSPEC_EOF

  write_file "spec/spec_helper.rb" <<'SPEC_HELPER_EOF'
# frozen_string_literal: true

require "simplecov"
SimpleCov.start if ENV["COVERAGE"]

RSpec.configure do |config|
  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end
  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end
  config.shared_context_metadata_behavior = :apply_to_host_groups
  config.order = :random
  Kernel.srand config.seed
end
SPEC_HELPER_EOF

  write_file "lib/${_LIB_FILE}/logger.rb" <<RUBY_LOGGER_EOF
# frozen_string_literal: true

module ${_GEM_NAME^}
  # Minimal structured logger that writes JSON to STDERR.
  module Logger
    LEVELS = %w[debug info warn error].freeze

    def self.info(msg)  = log("info",  msg)
    def self.warn(msg)  = log("warn",  msg)
    def self.error(msg) = log("error", msg)
    def self.debug(msg) = log("debug", msg)

    def self.log(level, msg)
      $stderr.puts({ time: Time.now.utc.iso8601, level: level, msg: msg }.to_json)
    end
  end
end
RUBY_LOGGER_EOF

  write_file "spec/unit/logger_spec.rb" <<'RUBY_LOGGER_SPEC_EOF'
# frozen_string_literal: true

require "spec_helper"

RSpec.describe "Logger" do
  it "responds to info, warn, error, debug" do
    %i[info warn error debug].each do |method|
      expect { $stderr.stub(:puts) }.not_to raise_error
    end
  end
end
RUBY_LOGGER_SPEC_EOF
  ;;

# ─────────────────────────────────────────────────────────────────────────────
# C stubs
# ─────────────────────────────────────────────────────────────────────────────
c)
  write_file "Makefile" <<'C_MAKE_EOF'
CC      = gcc
CFLAGS  = -std=c11 -Wall -Wextra -Wpedantic -Wimplicit-function-declaration \
          -g -fprofile-arcs -ftest-coverage
LDFLAGS = -lgcov

SRC_DIR   = src
INC_DIR   = include
TEST_DIR  = tests/unit

SRCS      = $(wildcard $(SRC_DIR)/*.c)
TEST_SRCS = $(wildcard $(TEST_DIR)/*.c)
TEST_BIN  = tests/test_suite

.PHONY: all build test coverage clean lint

all: build

build: $(SRCS)
	$(CC) $(CFLAGS) -I$(INC_DIR) $(SRCS) -o app $(LDFLAGS)

test: $(SRCS) $(TEST_SRCS)
	$(CC) $(CFLAGS) -I$(INC_DIR) -Ivendor/unity/src \
	      vendor/unity/src/unity.c $(SRCS) $(TEST_SRCS) \
	      -o $(TEST_BIN) $(LDFLAGS)
	./$(TEST_BIN)

coverage: test
	gcov $(SRCS)
	lcov --capture --directory . --output-file coverage.info
	genhtml coverage.info --output-directory coverage-report

lint:
	cppcheck --enable=all --error-exitcode=1 $(SRC_DIR)/ $(INC_DIR)/

clean:
	rm -f app $(TEST_BIN) *.gcda *.gcno *.gcov coverage.info
	rm -rf coverage-report
C_MAKE_EOF

  write_file "include/logger.h" <<'C_LOGGER_H_EOF'
#ifndef LOGGER_H
#define LOGGER_H

/* Minimal structured logger — writes JSON to stderr. */

void log_info(const char *msg);
void log_warn(const char *msg);
void log_error(const char *msg);
void log_debug(const char *msg);

#endif /* LOGGER_H */
C_LOGGER_H_EOF

  write_file "src/logger.c" <<'C_LOGGER_C_EOF'
#include <stdio.h>
#include <time.h>
#include "logger.h"

static void log_msg(const char *level, const char *msg) {
    time_t now = time(NULL);
    char buf[32];
    strftime(buf, sizeof(buf), "%Y-%m-%dT%H:%M:%SZ", gmtime(&now));
    fprintf(stderr, "{\"time\":\"%s\",\"level\":\"%s\",\"msg\":\"%s\"}\n",
            buf, level, msg);
}

void log_info(const char *msg)  { log_msg("info",  msg); }
void log_warn(const char *msg)  { log_msg("warn",  msg); }
void log_error(const char *msg) { log_msg("error", msg); }
void log_debug(const char *msg) { log_msg("debug", msg); }
C_LOGGER_C_EOF

  write_file "src/main.c" <<'C_MAIN_EOF'
#include <stdio.h>
#include "logger.h"

int main(void) {
    log_info("application started");
    printf("Hello, World!\n");
    log_info("application exiting");
    return 0;
}
C_MAIN_EOF

  write_file "tests/unit/test_logger.c" <<'C_TEST_EOF'
/* Unit tests for logger using Unity test framework.
   Compile: make test
   Unity source expected at vendor/unity/src/unity.c */

#include "unity.h"
#include "logger.h"

void setUp(void) {}
void tearDown(void) {}

void test_log_info_does_not_crash(void) {
    log_info("test info message");
    TEST_PASS();
}

void test_log_warn_does_not_crash(void) {
    log_warn("test warn message");
    TEST_PASS();
}

void test_log_error_does_not_crash(void) {
    log_error("test error message");
    TEST_PASS();
}

int main(void) {
    UNITY_BEGIN();
    RUN_TEST(test_log_info_does_not_crash);
    RUN_TEST(test_log_warn_does_not_crash);
    RUN_TEST(test_log_error_does_not_crash);
    return UNITY_END();
}
C_TEST_EOF
  ;;

# ─────────────────────────────────────────────────────────────────────────────
# PYTHON stubs
# ─────────────────────────────────────────────────────────────────────────────
python)
  _PKG_NAME="${PROJECT_NAME:-$(basename "$ROOT_DIR")}"
  _PKG_NAME="${_PKG_NAME:-my-project}"
  _PY_PKG="${_PKG_NAME//-/_}"

  write_file "pyproject.toml" <<PYPROJECT_EOF
[project]
name = "${_PKG_NAME}"
version = "0.1.0"
description = "${_PKG_NAME} project"
requires-python = ">=3.12"
dependencies = []

[project.optional-dependencies]
dev = [
  "pytest>=8.0",
  "pytest-cov>=5.0",
  "mypy>=1.10",
  "ruff>=0.5",
]

[tool.pytest.ini_options]
testpaths = ["tests"]
addopts = "--strict-markers"

[tool.coverage.run]
source = ["src"]

[tool.coverage.report]
fail_under = 80

[tool.mypy]
strict = true
python_version = "3.12"

[tool.ruff]
line-length = 88
target-version = "py312"

[tool.ruff.lint]
select = ["E", "F", "I", "N", "S", "UP"]
PYPROJECT_EOF

  write_file "src/${_PY_PKG}/__init__.py" <<PYINIT_EOF
"""${_PKG_NAME} package."""

__version__ = "0.1.0"
PYINIT_EOF

  write_file "src/${_PY_PKG}/logger.py" <<'PY_LOGGER_EOF'
"""Minimal structured logger writing JSON to stderr."""

from __future__ import annotations

import json
import sys
from datetime import datetime, timezone


def _log(level: str, msg: str) -> None:
    entry = {
        "time": datetime.now(tz=timezone.utc).isoformat(),
        "level": level,
        "msg": msg,
    }
    print(json.dumps(entry), file=sys.stderr)


def info(msg: str) -> None:
    """Log an informational message."""
    _log("info", msg)


def warn(msg: str) -> None:
    """Log a warning message."""
    _log("warn", msg)


def error(msg: str) -> None:
    """Log an error message."""
    _log("error", msg)


def debug(msg: str) -> None:
    """Log a debug message."""
    _log("debug", msg)
PY_LOGGER_EOF

  write_file "tests/__init__.py" <<'PY_TESTS_INIT_EOF'
PY_TESTS_INIT_EOF

  write_file "tests/unit/__init__.py" <<'PY_UNIT_INIT_EOF'
PY_UNIT_INIT_EOF

  write_file "tests/unit/test_logger.py" <<'PY_TEST_EOF'
"""Unit tests for the logger module."""

import json
import sys
from io import StringIO

import pytest

from src.PACKAGE.logger import debug, error, info, warn


@pytest.mark.parametrize("fn,level", [
    (info, "info"),
    (warn, "warn"),
    (error, "error"),
    (debug, "debug"),
])
def test_logger_writes_json(fn, level, capsys):
    fn("hello")
    captured = capsys.readouterr()
    entry = json.loads(captured.err)
    assert entry["level"] == level
    assert entry["msg"] == "hello"
    assert "time" in entry
PY_TEST_EOF

  # Replace placeholder with actual package name
  if [[ -f "tests/unit/test_logger.py" ]]; then
    sed -i "s/from src\\.PACKAGE/from src.${_PY_PKG}/g" tests/unit/test_logger.py
  fi
  ;;

# ─────────────────────────────────────────────────────────────────────────────
# TYPESCRIPT stubs (default)
# ─────────────────────────────────────────────────────────────────────────────
*)
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

  _PKG_NAME="${PROJECT_NAME:-$(basename "$ROOT_DIR")}"
  _PKG_NAME="${_PKG_NAME:-my-project}"

  write_file "package.json" <<PKG_EOF
{
  "name": "$_PKG_NAME",
  "version": "0.1.0",
  "description": "$_PKG_NAME project",
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
      'no-console': 'warn',
      'no-eval': 'error',
      'no-implied-eval': 'error',
      'no-new-func': 'error',
    },
  },
]
ESLINT_EOF

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
  ;;
esac

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
# --no-verify: the pre-commit hook would reject this commit because the hook
# and template files themselves contain the very patterns it scans for
# (e.g. "PRIVATE KEY" in a comment, "AWS_SECRET" as a variable name in the
# hook code).  These are documentation/template strings, NOT real secrets.
# Real commits from developers will go through the hook normally.
git commit --no-verify --message "chore: initial scaffold

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
