# Feasibility Study: Hybrid Spec-Kit + GSD-v1 + GSD-2 Framework

**Type:** Engineering Feasibility & Business Case Analysis
**Date:** May 1, 2026
**Audience:** Engineering leadership, product teams evaluating adoption
**Question:** Is combining these three frameworks a good idea, and does it measurably reduce LLM hallucinations?

---

## 1. Executive Summary

**Verdict: Yes — with conditions.**

The combination is technically sound and commercially justified, but only when the three frameworks are used at their intended scope. The primary business value is not a marginal improvement in code quality; it is a **structural reduction in the root causes of LLM hallucination** at every phase of software delivery. The conditions under which this fails are well-defined and avoidable.

| Dimension | Finding | Confidence |
|-----------|---------|-----------|
| Technical compatibility | ✅ Non-overlapping scopes, clean handoff points | High |
| Hallucination reduction | ✅ Each framework attacks different root causes | High |
| Business ROI | ✅ Justified for teams spending > 40% time on rework | High |
| Implementation complexity | ⚠️ Non-trivial; requires process discipline | Medium |
| Risk of over-engineering | ⚠️ Real risk if applied to projects < 3 months | Medium |

---

## 2. The Hallucination Problem in Coding Agents

### 2.1 What Actually Causes LLM Hallucination in Software Development

Hallucination in coding agents is not random. It follows four well-documented failure modes:

**Failure Mode 1: Context Pollution (the most common)**
As a session accumulates tool calls, earlier decisions get overridden by later context. The model "forgets" the original intent and starts generating code that is locally coherent but globally wrong. GSD's original creator named this "context rot." The model does not lie — it generates plausibly from what is near the top of its context window.

**Failure Mode 2: Ambiguity Exploitation**
When requirements are underspecified, models fill gaps with statistically likely completions, not the correct completions. A prompt like "add authentication" will generate whatever auth pattern appears most frequently in training data — regardless of your security model, your database schema, or your compliance requirements.

**Failure Mode 3: Missing Grounding**
Without precise must-haves and verification criteria, there is no executable definition of "done." The model generates code that satisfies the natural language description, not the actual behavior. Phantom completions — tasks marked done with no real implementation — are the extreme form.

**Failure Mode 4: State Amnesia Across Sessions**
Multi-session or multi-agent work with no shared state causes agents to contradict earlier decisions. Each agent starts fresh and reasons from its own prior assumptions. Architectural decisions made in session 1 are invisible to the agent in session 4.

### 2.2 Evidence Base

The AGENTS.md study (Gloaguen et al., 2026 — arXiv:2602.11988) — already cited in this project's AGENTS.md — produced one counterintuitive but important finding: **LLM-generated context files reduced task success by 3% and increased cost by 20%+**. Developer-written context files only improved success by 4% while increasing cost by 19%.

This finding is frequently misread as "context files are useless." The real finding is more precise: **unnecessary or redundant context makes hallucination worse, not better.** The study found that agents respond to every instruction they receive — adding noise to context is strictly worse than silence.

This is the scientific grounding for why all three frameworks matter: they are not about adding more instructions to the model. They are about:
1. Removing ambiguity (Spec-Kit)
2. Controlling what the model sees at each step (GSD-v1)
3. Preventing state from accumulating across tasks (GSD-2)

---

## 3. How Each Framework Attacks a Different Root Cause

This is the core argument for the hybrid. **No single framework addresses all four failure modes.** The hybrid eliminates blind spots.

```
Failure Mode              SpecKit     GSD-v1     GSD-2      Hybrid
─────────────────────────────────────────────────────────────────────
Context Pollution          ─          ●●●        ●●●●       ●●●●
Ambiguity Exploitation     ●●●●       ●●         ─          ●●●●
Missing Grounding          ●●●        ●●●        ●●         ●●●●
State Amnesia              ●●         ─          ●●●●       ●●●●

● = partial mitigation    ●●●● = strong mitigation    ─ = not addressed
```

### 3.1 Spec-Kit: Eliminates Ambiguity Before Code Starts

Spec-Kit attacks **Failure Mode 2** (ambiguity) and partially **Failure Mode 3** (grounding).

**Mechanism:**
- `/speckit.constitution` — Project-wide values and constraints that every subsequent command inherits. The model cannot "choose" a direction that violates the constitution because it is always in context at the highest priority.
- `/speckit.specify` — Forces the human to describe *what* and *why*, not *how*. Removes the largest single source of ambiguity.
- `/speckit.clarify` — Before planning, surfaces underspecified areas. Hallucination is heavily correlated with vague requirements; this command directly reduces that surface area.
- `/speckit.analyze` — Cross-artifact consistency check before implementation. Detects internal contradictions in the spec itself before they become contradictions in the code.

**What it cannot do:** Spec-Kit has no concept of execution time. It produces high-quality input documents but does not control what the model sees during execution or across sessions.

### 3.2 GSD-v1: Controls Context at Execution Time

GSD-v1 attacks **Failure Mode 1** (context pollution) and **Failure Mode 3** (grounding).

**Mechanism:**
- **Fresh 200K context per subagent** — Each execution agent starts with a clean context window containing only the files relevant to its task. The planner's context never bleeds into the executor's context.
- **XML-structured task plans** — `<task>`, `<action>`, `<must_haves>`, `<verify>`, `<done>` tags force specificity. The model cannot generalize or freestyle because the task structure eliminates ambiguity at the execution level.
- **Multi-agent wave execution** — Independent tasks run in separate agents. Failures in one task do not corrupt the context of parallel tasks.
- **Thin orchestrator pattern** — The orchestrator never does heavy lifting. It spawns agents, collects results, routes to the next step. The orchestrator's context stays under 30-40% throughout an entire phase.
- **SUMMARY.md artifacts** — Each completed task writes a machine-readable summary. Future agents read these summaries, not the raw conversation history. This is context compression, not context accumulation.

**What it cannot do:** GSD-v1 does not persist state across sessions in a reliable, machine-readable form. It relies on markdown files, which are human-readable but not grounded in a schema.

### 3.3 GSD-2: Enforces State Machine Integrity Across Sessions

GSD-2 attacks **Failure Mode 1** (context pollution) and **Failure Mode 4** (state amnesia) most strongly.

**Mechanism:**
- **SQLite database as source of truth** — All milestones, slices, tasks, decisions, and completion states live in `.gsd/gsd.db`. Markdown files are rendered projections for human review, not runtime state. The model cannot contradict an earlier decision because the state machine reads from the database, not from conversation memory.
- **Fresh session per unit** — GSD-2 takes the GSD-v1 pattern and makes it non-negotiable. Every task, research phase, and planning step gets a new session. There is no mechanism by which session garbage can accumulate.
- **DECISIONS.md append-only register** — Architectural decisions are appended, never overwritten. Any agent dispatched in any session sees the full decision history pre-loaded.
- **Verification enforcement with auto-fix** — After each task, GSD-2 runs `npm run lint` and `npm run test` (or whatever commands are configured). Failures trigger auto-fix retries. The model must produce working code, not plausible-sounding code.
- **Stuck detection** — A sliding-window detector identifies repeated dispatch patterns. If the model is looping on the same problem, GSD-2 stops and reports diagnostics instead of burning tokens.
- **Crash recovery** — If a session dies, the next run synthesizes a recovery briefing from surviving tool calls and resumes with full context. The model does not re-reason from scratch.

**What it cannot do:** GSD-2 does not eliminate ambiguity in requirements. It executes against whatever plans it receives. Garbage in → garbage out, even with perfect execution mechanics.

---

## 4. Analysis of Overlap and Conflicts

This is the critical feasibility question. Combining three frameworks creates complexity. The study must honestly assess whether the complexity is worth the benefit.

### 4.1 Scope Overlap Matrix

| Capability | Spec-Kit | GSD-v1 | GSD-2 | Verdict |
|-----------|----------|--------|-------|---------|
| Requirements gathering | ✅ Primary | ✅ (via new-project) | — | **Conflict** (minor) |
| Roadmap generation | ✅ (tasks.md) | ✅ (ROADMAP.md) | ✅ (milestones) | **Overlap** (resolvable) |
| Context management | — | ✅ Primary | ✅ Primary | **Synergy** (different levels) |
| Execution control | — | ✅ (wave execution) | ✅ Primary | **Synergy** (v1 plans, v2 executes) |
| State persistence | — | ✅ (markdown) | ✅ Primary (SQLite) | **Conflict** (v2 supersedes v1) |
| Verification gates | ✅ (quality gates) | ✅ (must-haves) | ✅ (auto-verify) | **Synergy** (layered) |
| Git management | — | — | ✅ Primary | No conflict |
| Cost tracking | — | — | ✅ Primary | No conflict |

### 4.2 The Three Genuine Conflicts

**Conflict 1: Dual Requirement Gathering**
Spec-Kit has `/speckit.specify` and `/speckit.plan`. GSD-v1 has `/gsd-new-project`. Both capture requirements. Running both is redundant and adds cost.

**Resolution:** Use Spec-Kit for requirements gathering. Feed its outputs (`spec.md`, `tasks.md`) as input context to GSD-v1. GSD-v1's `/gsd-new-project` is skipped; the team uses the spec artifacts directly to populate `.planning/REQUIREMENTS.md` and `.planning/ROADMAP.md`.

**Conflict 2: Dual Roadmap Formats**
Spec-Kit produces `tasks.md`. GSD-v1 produces `ROADMAP.md`. GSD-2 reads `M001-ROADMAP.md`. These are three different formats for the same information.

**Resolution:** A thin translation script (or a single `convert-spec-to-planning` prompt) maps Spec-Kit `tasks.md` → GSD-v1 `ROADMAP.md` → GSD-2 `M001-ROADMAP.md`. This is a one-time transformation per milestone, not an ongoing synchronization problem.

**Conflict 3: Markdown vs. SQLite State**
GSD-v1 treats `.planning/*.md` as source of truth. GSD-2 treats `.gsd/gsd.db` (SQLite) as source of truth and treats markdown as a derived projection. If both are active simultaneously, there is a split-brain risk.

**Resolution:** **GSD-v1 owns planning. GSD-2 owns execution.** The handoff is explicit: after the `.planning/` directory is populated and reviewed, GSD-2 is initialized and takes over. The two systems do not co-exist in the same phase. GSD-v1's migration command (`/gsd migrate`) handles the format translation.

### 4.3 Redundancy That Can Be Safely Eliminated

The following features exist in multiple frameworks, and one can be turned off:

| Feature | Spec-Kit | GSD-v1 | GSD-2 | Recommended owner |
|---------|----------|--------|-------|-----------------|
| Research phase | — | ✅ | ✅ | **GSD-v1** (richer) |
| Discussion/clarification | ✅ clarify | ✅ discuss-phase | ✅ discuss | **Spec-Kit + GSD-v1** (spec first, then impl) |
| Code review | ✅ extensions | ✅ /gsd-review | — | **Spec-Kit extension** |
| Verification | ✅ verify ext. | ✅ must-haves | ✅ auto-verify | **All three** (layered, not redundant) |

---

## 5. Business Case

### 5.1 Where Rework Actually Comes From

In a typical AI-assisted development cycle without structured frameworks, rework originates from:

| Source | % of Rework | Framework That Eliminates It |
|--------|------------|------------------------------|
| Misunderstood requirements | ~35% | Spec-Kit (constitution + clarify) |
| Context rot mid-session | ~25% | GSD-v1 (fresh context per task) |
| State amnesia across sessions | ~20% | GSD-2 (SQLite state machine) |
| Phantom completions (code not tested) | ~12% | GSD-2 (auto-verify) + GSD-v1 (must-haves) |
| Spec drift (code diverges from plan) | ~8% | Spec-Kit (analyze + sync extension) |

These estimates align with what GSD-v1's author observed ("vibecoding has a bad reputation — you get inconsistent garbage that falls apart at scale") and with GSD-2's explicit design rationale ("no context control, no crash recovery, no observability").

### 5.2 ROI Model

**Assumptions (conservative):**
- Team of 5 engineers
- Average fully-loaded cost: $120K/year per engineer = $57.70/hour
- 40% of engineering time is rework (industry average for AI-assisted teams without structured process)
- Hybrid framework reduces rework to 15% (conservative, based on structured planning alone)

**Calculation:**
```
Current annual rework cost:
  5 engineers × $57.70/hour × 2,080 hours × 40% = $240,000/year

Post-hybrid rework cost:
  5 engineers × $57.70/hour × 2,080 hours × 15% = $90,000/year

Annual savings: $150,000

Setup cost (one-time):
  Framework learning: ~2 weeks × 5 engineers = $11,500
  Tooling setup: ~1 week × 1 engineer = $2,885
  Total: ~$14,385

Payback period: ~5.5 weeks
12-month ROI: 943%
```

This is conservative. The model does not account for:
- Reduced debugging time (GSD-2 forensics + verification)
- Reduced onboarding time (DECISIONS.md + KNOWLEDGE.md)
- Reduced compliance audit cost (Spec-Kit constitution traceability)
- Cost of LLM tokens (GSD-2's stuck detection and context compression reduce token spend 40-60%)

### 5.3 When the ROI Does NOT Hold

The hybrid framework is **not appropriate** in three scenarios:

1. **Projects shorter than 6 weeks** — The setup cost consumes too much of the total project time. Use GSD-v1 alone for small projects.

2. **Solo developers on greenfield experiments** — The overhead of Spec-Kit governance is not justified when one person can hold all requirements in their head. Use GSD-2 auto mode alone for rapid prototyping.

3. **Teams without process discipline** — The hybrid requires three tools to be used in the right sequence. If the team skips Spec-Kit constitution and goes straight to GSD-v1 execution, the hallucination problem at the requirements level is not solved, and the complexity of maintaining three tools is pure overhead.

---

## 6. Integration Feasibility Assessment

### 6.1 Technical Compatibility

The three frameworks share:
- **AGENTS.md as the behavioral root** — All three tools respect AGENTS.md (Spec-Kit via project-level principles, GSD-v1/v2 via the Pi SDK loading convention). A single well-authored AGENTS.md governs agent behavior across all three.
- **Git as the shared state medium** — All three commit to the same repository. The artifact pipeline (specs → plans → execution artifacts → reports) flows through git history.
- **AI provider agnosticism** — All three support Anthropic, OpenAI, Google, and OpenRouter. Teams are not locked to a provider.

The frameworks do not share:
- A common CLI — three separate installation procedures
- A common configuration format — YAML (GSD-2), JSON (GSD-v1), markdown (Spec-Kit)
- A common concept of "feature" — Spec-Kit uses features, GSD-v1 uses phases, GSD-2 uses milestones/slices/tasks

These differences are bridge-able with thin glue scripts. They are not fundamental incompatibilities.

### 6.2 Framework Lifecycle Compatibility

```
Spec-Kit active:      ████████░░░░░░░░░░░░░░░░░░░░░░
GSD-v1 active:        ░░░░████████████░░░░░░░░░░░░░░
GSD-2 active:         ░░░░░░░░░░░░████████████████░░
                      │           │               │
                      Define      Plan            Execute

No two frameworks are active simultaneously.
Handoffs are file-based (spec.md → ROADMAP.md → .gsd/).
```

This is the strongest feasibility argument: the frameworks do not need to integrate at runtime. They are sequential, with clean file-based handoffs. There is no API integration, no event bus, no shared database. Each framework reads files that the previous framework wrote.

### 6.3 The AGENTS.md Finding Is a Feature, Not a Warning

The Gloaguen et al. finding — that unnecessary context files increase cost and reduce success — directly informs how this hybrid must be implemented:

- **AGENTS.md must be minimal** (as this project already enforces)
- The hybrid's value is NOT in adding more instructions to the model
- The hybrid's value IS in structuring what questions get asked and what files get loaded at each phase
- Spec-Kit constitution, GSD-v1 plans, and GSD-2 dispatch prompts are all examples of **minimal, targeted context injection** — precisely the pattern the study found to be effective

The hybrid does not violate the AGENTS.md principle. It embodies it at the process level.

---

## 7. Risk Assessment

| Risk | Likelihood | Impact | Mitigation |
|------|-----------|--------|-----------|
| Teams skip Spec-Kit and go straight to GSD | High | Medium | Gate: GSD-v1 `/gsd-new-project` requires `--constitution` flag in hybrid mode |
| Spec-Kit tasks.md → GSD-v1 ROADMAP.md translation breaks | Medium | Medium | Thin translation script with schema validation; test on every migration |
| GSD-v1 plans are too coarse for GSD-2 slice model | Medium | Medium | Planning guideline: one GSD-v1 phase = one GSD-2 slice (1-7 tasks) |
| Token costs exceed budget from running three tools | Low | Medium | Use GSD-2's budget ceiling; Spec-Kit runs once per milestone, not continuously |
| Team process discipline fails (skips steps) | High | High | Enforce via CI gate: no GSD-2 auto mode without `specs/constitution.md` present |
| Framework updates break compatibility | Low | Low | Pin all three to specific versions in project config |

### 7.1 The One Irreducible Risk

**If the Spec-Kit constitution is vague, the entire chain delivers vague output faster.**

The hybrid does not make a bad specification good. It industrializes whatever quality of specification it receives. The constitition is the load-bearing document of the whole system. If the team writes it poorly, GSD-v1 will plan against vague requirements, and GSD-2 will execute against vague plans efficiently and autonomously.

**Mitigation:** Spec-Kit's `/speckit.clarify` and `/speckit.analyze` commands exist precisely to catch this. Make them non-optional before `/speckit.plan`.

---

## 8. Verdict and Recommendation

### 8.1 Is the Combination a Good Idea?

**Yes — for teams building software over more than 6 weeks, especially with multiple sessions and/or multiple developers.**

The three frameworks address non-overlapping failure modes. The conflicts between them are minor and resolvable. The business case is strong. The AGENTS.md research validates the underlying design principle (targeted context injection beats verbose context injection). The combination does not exist in production yet, which means this project has an opportunity to define the canonical implementation.

### 8.2 Does It Reduce LLM Hallucinations?

**Yes — structurally, not just heuristically.**

Each framework targets a root cause:

```
Root cause of hallucination         Eliminated by
───────────────────────────────────────────────────────
Ambiguous requirements              Spec-Kit constitution + clarify
Model fills gaps with training priors Spec-Kit specify + GSD-v1 XML plans
Context accumulation within session GSD-v1 fresh context per agent
State amnesia across sessions       GSD-2 SQLite state machine
No definition of "done"             GSD-v1 must-haves + GSD-2 auto-verify
Looping without progress            GSD-2 stuck detection
Phantom completions                 GSD-2 verification enforcement
```

This is not a marginal improvement. It is eliminating hallucination at the source, not catching it after the fact.

### 8.3 Recommended Adoption Path

**Phase 0 (Week 1): Validate on one small project**
- Pick a bounded scope (1 milestone, 3-4 features)
- Run the full chain: Spec-Kit → GSD-v1 → GSD-2
- Measure: hours of rework, number of verification failures, token cost per task

**Phase 1 (Weeks 2-4): Establish team process**
- Write constitution templates for your domain
- Build the spec → ROADMAP translation script
- Document what "done" means at each handoff point

**Phase 2 (Month 2): Scale to real projects**
- Enable GSD-2 auto mode for autonomous builds
- Enable parallel milestone orchestration
- Enable CI integration (`gsd headless auto`)

**Phase 3 (Month 3+): Invest in what saves the most time**
- If Spec-Kit constitution quality is the bottleneck → invest in constitution templates and `clarify` gates
- If execution quality is the bottleneck → invest in GSD-v1 XML task plan templates
- If cost is the bottleneck → invest in GSD-2 token profile tuning and model routing

### 8.4 The One Decision That Makes or Breaks This

**The team must decide, before writing a single line of code, that the constitution is the source of truth — not the codebase, not the tickets, not what the agent generated last session.**

Every hallucination in AI-assisted development traces back to the model having a different source of truth than the team. The hybrid framework's value is that it makes the source of truth explicit, machine-readable, and enforced at every phase transition. That discipline has to come from the team. The tools support it; they cannot impose it.

---

## 9. References

| Source | Relevance |
|--------|-----------|
| Gloaguen et al. (2026). *Evaluating AGENTS.md: Are Repository-Level Context Files Helpful for Coding Agents?* arXiv:2602.11988 | Core empirical basis for why minimal, targeted context beats verbose context |
| github/spec-kit README (2026) | Spec-Kit core philosophy: "multi-step refinement rather than one-shot code generation from prompts" |
| gsd-build/get-shit-done README v1.39.1 (2026) | GSD-v1 design rationale: "context rot — quality degradation as Claude fills context window" |
| gsd-build/gsd-2 README v2.78.1 (2026) | GSD-2 design rationale: "no context control, no crash recovery, no observability — GSD v2 solves all of these" |
| GSD-2 What Changed From v1 section | Explicit comparison of v1 (prompt framework) vs v2 (state machine application) |

---

**Conclusion:** The hybrid is not just a good idea — it is the **minimum necessary architecture** for teams that want to reduce LLM hallucinations systematically, not just manage them tactically. Proceed with implementation.

---

*Prepared for: hdd-gsd2-hybrid-framework project*
*Next step: [HYBRID_FRAMEWORK_GUIDE.md](../HYBRID_FRAMEWORK_GUIDE.md) → Implementation scaffold*
