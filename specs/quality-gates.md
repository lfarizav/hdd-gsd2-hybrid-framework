# Quality Gates

> **Purpose:** Defines mandatory checkpoints before work advances from one
> phase to the next. These gates are the mechanical enforcement of the
> constitution's definition of done.
>
> **Integration:** GSD-2 PREFERENCES.md references these gate commands.
> All gates must pass before a GSD-2 slice is marked complete.

---

## Gate Definitions

### Gate 1 — Spec Review (before planning starts)

**When:** After `specs/requirements.md` is written, before GSD-v1 planning.
**Who:** Human review required.
**Checks:**

- [ ] All requirements have acceptance criteria (Gherkin or equivalent)
- [ ] Requirements are consistent with `specs/constitution.md`
- [ ] Non-functional requirements are measurable
- [ ] `/speckit.clarify` has been run and all ambiguities resolved
- [ ] `/speckit.analyze` has been run and no cross-spec drift detected

**Block condition:** Any unchecked item above blocks planning from starting.

---

### Gate 2 — Plan Review (before execution starts)

**When:** After `.planning/ROADMAP.md` is written, before GSD-2 auto mode.
**Who:** Human review required.
**Checks:**

- [ ] All milestones map back to requirements (traceability matrix complete)
- [ ] Each slice contains 1-7 tasks
- [ ] Each task fits in one 200K context window
- [ ] Must-haves are specified for every task
- [ ] Verification commands are configured in `.gsd/PREFERENCES.md`
- [ ] `specs/constitution.md` exists and has no placeholder text

**Block condition:** Any unchecked item above blocks GSD-2 `auto` mode.

---

### Gate 3 — Automated (runs on every GSD-2 task completion)

**When:** After every GSD-2 task execution, automatically.
**Who:** GSD-2 auto-verify (configured in `.gsd/PREFERENCES.md`).
**Commands run:**

```bash
go test -coverprofile=coverage.out ./...   # tests pass
go tool cover -func=coverage.out           # verify ≥ 80% statement coverage
golangci-lint run ./...                    # lint clean
go vet ./...                               # static analysis
go build ./...                             # compiles without errors
```

**Block condition:** Any command exits non-zero → GSD-2 auto-retries up to 3 times, then pauses for human intervention.

---

### Gate 4 — Milestone Review (before next milestone starts)

**When:** After all slices in a milestone are marked complete.
**Who:** Human review required.
**Checks:**

- [ ] All acceptance criteria from `specs/requirements.md` verified
- [ ] DECISIONS.md updated with architectural decisions made during execution
- [ ] KNOWLEDGE.md updated with lessons learned
- [ ] Coverage report reviewed (`coverage/lcov-report/index.html`)
- [ ] Security review completed (run `/security` agent or `govulncheck ./...`)

**Command:**

```bash
gsd export --html           # generates HTML milestone report
```

**Block condition:** Any unchecked item blocks the next milestone from starting.

---

## Gate Command Reference

```bash
# Spec-Kit gates (run during Definition phase)
specify clarify             # Surface ambiguities before planning
specify analyze             # Cross-spec consistency check

# Automated gate (run on every task — also in CI)
go test -coverprofile=coverage.out ./...
go tool cover -func=coverage.out
golangci-lint run ./...
go vet ./...
go build ./...

# GSD-2 reporting (run after each milestone)
gsd export --html

# GSD-2 forensics (run when a task is stuck)
gsd forensics
```
