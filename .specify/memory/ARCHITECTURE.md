# Architecture Context

> Loaded by Spec-Kit Memory Loader before `/speckit.plan` and `/speckit.implement`.
> Contains stable architectural decisions. Update after each milestone Gate 4 review.

## Layer Model

```
Layer 1 — Spec-Kit   specs/           Definition (what to build)
Layer 2 — GSD-v1     .planning/       Planning (how to guide building)
Layer 3 — GSD-2      .gsd/            Execution (how to build autonomously)
```

## Source Code Structure

```
src/
  api/          HTTP route handlers
  db/           Database layer (migrations + queries)
  lib/          Pure utilities (no side effects)
  middleware/   Request handlers (auth, logging, error)
  services/     Business logic (domain-specific)
  types/        TypeScript interfaces and enums
```

## Testing Strategy

| Layer | Location | Tools | Scope |
|-------|----------|-------|-------|
| Unit | tests/unit/ | Jest + ts-jest | Pure functions, utilities |
| Integration | tests/integration/ | Jest | Service + DB interaction |
| E2E | tests/e2e/ | Jest / Playwright | Full request/response cycles |

## Key Decisions

> Append decisions here after Gate 4 reviews. Do not overwrite — append only.

| Date | Decision | Rationale |
|------|----------|-----------|
| <!-- DATE --> | Initial architecture established | See docs/architecture.md |
