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
  name: "YOUR_PROJECT_NAME"
  purpose: "One-sentence description of what this project does and for whom."
  owner: "YOUR_NAME / YOUR_TEAM"
  repository: "https://github.com/OWNER/REPO"
```

---

## Non-Negotiable Values

> These are the absolute constraints. Any generated code, plan, or spec that
> violates a value here must be rejected and regenerated.

1. **Security-first** — All data encrypted at rest and in transit. No secrets in source code.
2. **User trust** — Clear privacy disclosures. No dark patterns. No silent data collection.
3. **Testability** — Every public API has corresponding tests. Coverage threshold: 80%.
4. **Readability over cleverness** — Descriptive names. Functional patterns. No `any`.
5. **Minimal instructions** — Per arXiv:2602.11988, only specify what agents cannot discover.

---

## Technology Constraints

```yaml
technology:
  language: TypeScript (strict mode)
  runtime: Node.js 22+
  testing: Jest + ts-jest
  linting: ESLint + Prettier
  style:
    quotes: single
    semicolons: false
    indent: 2 spaces
  patterns:
    preferred: functional
    avoid: class (unless modelling a domain entity)
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

| Gate | Requirement | Enforced By |
|------|------------|-------------|
| Tests pass | `npm test` exits 0 | CI/CD + GSD-2 auto-verify |
| Coverage | ≥ 80% branches + lines | Jest threshold |
| Lint clean | `npm run lint` exits 0 | CI/CD + pre-commit |
| Type-check | `npm run typecheck` exits 0 | CI/CD |
| No secrets | Pre-commit scan passes | `.github/hooks/pre-commit` |

---

## Compliance Requirements

> List any regulatory, legal, or organisational compliance requirements.
> Examples: GDPR, HIPAA, SOC 2, WCAG 2.1, internal security policy.

- [ ] **GDPR** — if handling EU personal data
- [ ] **OWASP ASVS Level 1** — application security minimum
- [ ] *(add your requirements here)*

---

## Architecture Principles

1. **Single responsibility** — each module has one reason to change.
2. **Explicit over implicit** — configuration, dependencies, and errors are explicit.
3. **Fail fast** — validate at system boundaries; throw on invalid state.
4. **Stateless services** — business logic is pure; side effects are pushed to edges.

---

## Definition of Done

A task is complete when:
- [ ] Code compiles without errors (`npm run typecheck`)
- [ ] All tests pass (`npm test`)
- [ ] Coverage threshold maintained (`npm test -- --coverage`)
- [ ] Lint clean (`npm run lint`)
- [ ] AGENTS.md boundaries respected
- [ ] No `TODO` comments left without a linked issue

---

## Revision History

| Date | Author | Change |
|------|--------|--------|
| <!-- DATE --> | <!-- AUTHOR --> | Initial constitution |
