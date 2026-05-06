# GitHub Copilot Instructions

This file provides context and guidance for GitHub Copilot when working in this repository.

## Project Overview

**HDD-GSD2 Hybrid Framework** — Research-backed scaffolding system for AI-assisted development in VS Code, combining three layers:

1. **Spec-Kit** (`/specs`) — Constitution, requirements, feature specs, ADRs
2. **GSD-v1** (`/.planning`) — Project state, roadmap, decisions
3. **GSD-2** (`/.gsd`) — Preferences, state machine, observability

**Language:** Go 1.22+ (primary) + Bash (scripts) + TypeScript (selected utilities)

## When coding

### Go Code
- Follow AGENTS.md testing, code style, and git workflow guidelines
- Use `go test ./...` before marking work done
- Coverage threshold: **80%** (statements)
- See AGENTS.md for naming, error handling, and comment standards

### Bash Scripts
- POSIX-compatible (Bash 4+)
- Non-blocking operations with fallback behavior
- Interactive prompts require user confirmation
- Use absolute paths for script dependencies
- Test with actual input before committing

### TypeScript (limited)
- See `.github/agents/lint-agent.md` for TypeScript style
- Strict mode, no `any` without `@ts-expect-error`
- camelCase for vars/functions, PascalCase for types

## Key Boundaries

✅ **Always:**
- Check AGENTS.md before starting work
- Run tests and lint checks before committing
- Follow branch naming: `feat/`, `fix/`, `chore/`, `docs/`
- Use Conventional Commits for PR titles

⚠️ **Ask first:**
- Adding dependencies (Go modules, npm packages)
- Modifying CI/CD workflows or build scripts
- Refactoring across many files at once

🚫 **Never:**
- Commit `.env` or secrets
- Edit `vendor/` or build outputs
- Remove failing tests (fix or create follow-up issue)
- Force-push to `main`

## Useful References

- [AGENTS.md](../../AGENTS.md) — Full testing/style/workflow guidelines
- [.github/agents/](./agents/) — Domain-specific agent definitions
- [docs/scripts/README.md](../../docs/scripts/README.md) — Scaffolding scripts guide
- [tests/](../../tests/) — Examples of test patterns

## Commands

```bash
# Testing
go test ./...
go test -coverprofile=coverage.out ./... && go tool cover -func=coverage.out

# Code quality
gofmt -w ./...
go vet ./...

# Framework automation
bash scripts/update-framework.sh
bash scripts/create-new-project.sh

# Scripts validation
bash -n scripts/*.sh  # syntax check
```

## When in doubt

- Check [AGENTS.md](../../AGENTS.md) — it has minimal requirements optimized for agent clarity
- Look at existing code in `internal/`, `cmd/`, or `tests/` for patterns
- Ask questions in commit messages or PR descriptions for clarity
