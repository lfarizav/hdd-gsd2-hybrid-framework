# GSD-2 Preferences

> Configures GSD-2's autonomous execution behaviour for this project.
> Changes here take effect on the next `gsd` invocation.
>
> For full documentation: https://github.com/gsd-build/gsd-2

---

## Models

> Assign different models to different phases for cost/quality balance.
> Supported: claude-opus-4-5, claude-sonnet-4-5, gpt-4o, gemini-2.5-pro

```yaml
models:
  planning:      claude-opus-4-5        # milestones + slices + roadmap
  research:      claude-opus-4-5        # scout + researcher agents
  execution:     claude-sonnet-4-5      # worker, js-pro, ts-pro agents
  verification:  claude-sonnet-4-5      # post-task verification
```

---

## Budget Ceiling

> GSD-2 tracks cost per task, slice, and milestone. Set ceilings to prevent
> runaway spending on stuck tasks.

```yaml
budget:
  maxCostPerTask:      0.50     # USD; pause and report if exceeded
  maxCostPerSlice:     2.00     # USD
  maxCostPerMilestone: 10.00    # USD
  currency: USD
```

---

## Verification Commands

> Run after EVERY task completion. All must exit 0 for the task to be
> marked complete. Non-zero exit → auto-retry up to maxRetries times.
> These implement specs/quality-gates.md Gate 3.

```yaml
verification:
  commands:
    - npm test -- --coverage
    - npm run lint
    - npm run typecheck
    - npm run build
  autoFix: true                 # retry with auto-fix instructions on failure
  maxRetries: 3                 # attempts before pausing for human review
```

---

## Execution Behaviour

```yaml
execution:
  stuckDetection: true          # sliding-window detector for repeated patterns
  stuckThreshold: 3             # consecutive identical dispatches = stuck
  crashRecovery: true           # synthesise briefing and resume on crash
  worktreeIsolation: false      # set true if using git worktrees per milestone
  parallelSlices: false         # set true only when slices have no shared state
```

---

## Context Loading

> Files pre-loaded into every execution agent context.
> Keep this list MINIMAL per arXiv:2602.11988.

```yaml
context:
  always:
    - AGENTS.md                         # project-wide agent boundaries
    - .planning/DECISIONS.md            # prevent state amnesia
    - .planning/KNOWLEDGE.md            # project-specific facts
    - specs/constitution.md             # non-negotiable values
  perMilestone:
    - .planning/ROADMAP.md              # task plans for active milestone
    - .specify/memory/ARCHITECTURE.md   # architecture context
```

---

## Reporting

```yaml
reporting:
  htmlReportOnMilestoneComplete: true   # gsd export --html
  summaryOnTaskComplete: true           # write SUMMARY.md per completed task
  costTrackingEnabled: true
```

---

## Hybrid Framework Integration

```yaml
hybrid:
  constitutionRequired: true            # block auto mode if specs/constitution.md
                                        # contains placeholder text
  gate2ChecklistRequired: true          # block auto mode if Gate 2 unchecked
  roadmapSource: .planning/ROADMAP.md   # GSD-v1 handoff document
  decisionsLog: .planning/DECISIONS.md  # append-only decision registry
  knowledgeBase: .planning/KNOWLEDGE.md # project knowledge
```
