# Development Roadmap

> **GSD-v1 Planning Output → GSD-2 Execution Input.**
> This is the primary handoff document. GSD-2 reads this to initialise
> its milestone/slice/task hierarchy. Format must be compatible with
> GSD-2's `/gsd` command.
>
> **Rule:** Each phase here = one GSD-2 milestone (4-10 slices).
> Each slice = 1-7 tasks. Each task must fit in one 200K context window.

---

## Milestone M001 — [PHASE NAME]

**GSD-2 command:** `gsd /gsd auto --milestone M001`  
**Maps to:** `.planning/REQUIREMENTS.md#phase-1`  
**Target:** [TIMEFRAME]

### Slice S01 — [SLICE NAME]

> Description: What this slice delivers.

**Tasks:**

```xml
<task id="M001-S01-T01">
  <action>Implement [SPECIFIC ACTION]</action>
  <must_haves>
    <item>File `src/[path].ts` exists and compiles</item>
    <item>`npm test` passes with coverage ≥ 80%</item>
    <item>No `any` types in implementation</item>
  </must_haves>
  <artifact>src/[path].ts</artifact>
  <truth>tests/unit/[path].test.ts</truth>
  <verify>npm test -- --testPathPattern=[path]</verify>
</task>
```

### Slice S02 — [SLICE NAME]

> *(Add after S01 is complete)*

---

## Milestone M002 — [PHASE NAME]

*(Add after M001 Gate 4 review is complete)*

---

## Roadmap Status

| Milestone | Slices | Status | GSD-2 Mode |
|-----------|--------|--------|-----------|
| M001 | S01-S0N | ⬜ Not started | Step (`/gsd`) or Auto (`/gsd auto`) |

---

## GSD-v1 → GSD-2 Handoff Checklist

Before running `gsd /gsd auto`:

- [ ] This file has at least one complete milestone with ≥ 1 slice
- [ ] All task `<must_haves>` are specific and machine-verifiable
- [ ] `.gsd/PREFERENCES.md` verification commands configured
- [ ] `specs/quality-gates.md` Gate 2 checklist signed off
- [ ] `specs/constitution.md` has no placeholder text remaining
