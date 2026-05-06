# Project Constitution

> **Purpose:** This constitution is the load-bearing document of the hybrid
> framework. Every Spec-Kit command, every GSD-v1 plan, and every GSD-2 slice
> cascades from the values and constraints defined here.
>
> **How to use:** Fill in the sections below. Do not leave placeholders in
> production. The model will generate code consistent with whatever you write
> here — vague constitutions produce vague results.

---

## Project Identity

```yaml
project:
  name: 'heritage'
  purpose: 'Deploys a Kubernetes cluster using kind with Calico CNI and pre-downloaded images, supporting N control-plane nodes and M worker nodes.'
  owner: 'Luis Felipe Ariza Vesga'
  repository: 'https://github.com/lfarizav/hdd-gsd2-hybrid-framework.git'
```

---

## Non-Negotiable Values

> These are the absolute constraints. Any generated code, plan, or spec that
> violates a value here must be rejected and regenerated.

1. **Security-first** — All data encrypted at rest and in transit. No secrets in source code.
2. **User trust** — Clear privacy disclosures. No dark patterns. No silent data collection.
3. **Testability** — Every public API has corresponding tests. Coverage threshold: 80%.
4. **Readability over cleverness** — Descriptive names. Explicit error handling. No `interface{}` without justification.
5. **Minimal instructions** — Per arXiv:2602.11988, only specify what agents cannot discover.
6. **Guess** — If the model is unsure about a requirement or detail, it must ask for clarification instead of making assumptions. It also must make a research on internet to get facts and evidence before coding.
7. **Use old or deprecated libraries** — Never use old or deprecated libraries, as they may have security vulnerabilities or lack support. Always check for the latest stable versions of dependencies and ensure they are actively maintained.

---

## Technology Constraints

```yaml
technology:
  language: Go 1.22+
  runtime: Go 1.22+
  testing: go test (stdlib) + testify for assertions
  linting: golangci-lint
  style:
    formatting: gofmt + goimports (tabs, enforced by gofmt)
    errors: explicit error returns, no panic in library code
  patterns:
    preferred: packages, interfaces, explicit error handling
    avoid: global mutable state, init() side-effects
```

---

## Security Baseline

- OWASP Top 10 is the minimum security standard.
- Parameterised queries only — never interpolate user input into SQL.
- Validate and sanitise all external input at system boundaries.
- Pre-commit hook blocks secrets before they reach git.
- Production secrets managed via secrets manager (AWS Secrets Manager, Vault, etc.).

---

## Quality Gates

| Gate        | Requirement                       | Enforced By                |
| ----------- | --------------------------------- | -------------------------- |
| Tests pass  | `go test ./...` exits 0           | CI/CD + GSD-2 auto-verify  |
| Coverage    | ≥ 80% statements                  | `go test -cover ./...`     |
| Lint clean  | `golangci-lint run ./...` exits 0 | CI/CD + pre-commit         |
| Build clean | `go build ./...` exits 0          | CI/CD                      |
| No secrets  | Pre-commit scan passes            | `.github/hooks/pre-commit` |

---

## Compliance Requirements

> List any regulatory, legal, or organisational compliance requirements.
> Examples: GDPR, HIPAA, SOC 2, WCAG 2.1, internal security policy.

- [ ] **GDPR** — if handling EU personal data
- [ ] **OWASP ASVS Level 1** — application security minimum
- [ ] _(add your requirements here)_

---

## Architecture Principles

1. **Single responsibility** — each module has one reason to change.
2. **Explicit over implicit** — configuration, dependencies, and errors are explicit.
3. **Fail fast** — validate at system boundaries; throw on invalid state.
4. **Stateless services** — business logic is pure; side effects are pushed to edges.

---

## Definition of Done

A task is complete when:

- [ ] Code compiles without errors (`go build ./...`)
- [ ] All tests pass (`go test ./...`)
- [ ] Coverage threshold maintained (`go test -coverprofile=coverage.out ./... && go tool cover -func=coverage.out`)
- [ ] Lint clean (`golangci-lint run ./...`)
- [ ] AGENTS.md boundaries respected
- [ ] No `TODO` comments left without a linked issue
