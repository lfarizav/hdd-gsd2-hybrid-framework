# Contributing

Thank you for helping improve this project! This guide will help you get started with development, follow best practices, and understand the project's standards.

## Overview

This project is a **scaffolding tool for agentic engineering** in VS Code. When you contribute, you're helping developers around the world accelerate their AI-assisted development journey.

## Getting started

1. **Fork the repo** and create a branch: `feat/<your-feature>`, `fix/<bug>`, or `docs/<topic>`
2. **Install dependencies**: `npm install`
3. **Copy environment**: `cp .env.example .env` and populate it
4. **Make your changes** and add tests (if applicable)
5. **Run all checks**: `npm test && npm run lint && npm run typecheck`
6. **Open a pull request** with a clear description

## Development workflow

### Before you start

Read [AGENTS.md](AGENTS.md) for the project's exact standards:
- **Code style**: TypeScript strict mode, single quotes, no semicolons, 2-space indent
- **Testing**: Jest + ts-jest, 80% coverage threshold
- **Boundaries**: What you can and cannot change
- **Security**: OWASP compliance, secrets protection

### Making changes

1. **Create a feature branch**:
   ```bash
   git checkout -b feat/my-awesome-feature
   ```

2. **Edit files** following the code style guide in AGENTS.md

3. **Test locally**:
   ```bash
   npm run typecheck    # Catch type errors
   npm run lint         # Fix style issues
   npm test             # Run unit tests
   npm test:coverage    # Check 80% threshold
   ```

4. **Format code**:
   ```bash
   npm run format       # Auto-format with Prettier
   ```

### Commit messages

Follow [Conventional Commits](https://www.conventionalcommits.org/):

```
feat: add new validation helper to logger
fix: correct off-by-one in pagination
docs: update architecture diagram
test: add coverage for edge cases
refactor: simplify type exports
chore: update dependencies
```

**Good commit message**:
```
feat: implement unified agent instruction system

- Create AGENTS.md as single source of truth
- Add symlinks for all agent tools
- Update scaffold script to generate symlinks
- Add validation tests for symlink creation

Closes #42
```

**Avoid**:
```
fixed stuff          ❌ Too vague
WIP                  ❌ Work in progress; add to feature branch
Update files         ❌ No context
```

## Pull request process

### Before submitting

- [ ] All tests pass: `npm test`
- [ ] No lint errors: `npm run lint`
- [ ] Types check: `npm run typecheck`
- [ ] Coverage ≥ 80%: `npm test:coverage`
- [ ] Code formatted: `npm run format`
- [ ] AGENTS.md followed
- [ ] Commit messages are conventional

### PR title format

Use [Conventional Commits](https://www.conventionalcommits.org/) in the PR title:

```
feat: add symlink validation in scaffold script
fix: prevent secrets from being committed
docs: improve README with architecture diagrams
```

### PR description template

```markdown
## Description
Brief explanation of the change and why it's needed.

## Type of change
- [ ] Bug fix
- [ ] New feature
- [ ] Documentation
- [ ] Security improvement

## Related issues
Closes #123

## Testing
Describe how you tested this change:
- [ ] Unit tests added
- [ ] Integration tests added
- [ ] Manual testing steps

## Screenshots (if applicable)
Add screenshots for UI changes.

## Security considerations
Does this change affect security? How?
```

## Security vulnerabilities

**Do not** open a public issue for security vulnerabilities.

Instead, email **security@yourproject.com** with:
1. Description of the vulnerability
2. Steps to reproduce
3. Potential impact
4. Suggested fix (if any)

## Code review guidelines

### For reviewers

- **Be constructive**: Suggest improvements, don't criticize
- **Check for**: Type safety, test coverage, OWASP compliance
- **Verify**: No hardcoded secrets, no `any` types
- **Follow**: AGENTS.md standards and boundaries

### For contributors

- **Respond to feedback**: Address all review comments
- **Ask questions**: Unclear feedback? Ask for clarification
- **Stay focused**: Keep PRs small (< 400 lines); split large changes

## Project structure

```
├── src/              # Source code (TypeScript)
├── tests/            # Test suites (unit, integration, e2e)
├── docs/             # Documentation
├── scripts/          # Utility scripts (scaffold, etc.)
├── .github/          # GitHub workflows and templates
├── AGENTS.md         # Single source of truth for agents
├── README.md         # Project overview
└── tsconfig.json     # TypeScript configuration
```

## Using specialized agents

The project includes specialized agents for different tasks:

```bash
# Lint agent — fixes code style automatically
@copilot /lint

# Test agent — generates or fixes unit/integration tests
@copilot /test

# Docs agent — writes API docs and architecture guides
@copilot /docs

# Security agent — reviews code for OWASP Top 10 vulnerabilities
@copilot /security
```

See [AGENTS.md](AGENTS.md) for details.

## Questions?

- **Documentation**: Check [README.md](README.md), [docs/architecture.md](docs/architecture.md)
- **Standards**: See [AGENTS.md](AGENTS.md)
- **Chat**: Open an issue with the `question` label

---

## Made with ❤️

This project was created by **Luis Felipe Ariza Vesga** to help developers and teams accelerate their agentic engineering journey with AI assistants in Visual Studio Code.

Thank you for contributing! 🚀
