# Changelog

All notable changes to this project are documented here.

Format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).
Versioning follows [Semantic Versioning](https://semver.org/).

---

## [Unreleased]

### Added

#### Hybrid Framework (Spec-Kit + GSD-v1 + GSD-2)

- `scripts/scaffold-hybrid-framework.sh` — new idempotent script that installs the three-layer hybrid framework on top of an existing project scaffold. Supports `--force` and `--install-clis` flags.
- `specs/constitution.md` — project constitution template; cascades values to every downstream planning and execution agent.
- `specs/requirements.md` — Gherkin-style feature requirements template with traceability matrix.
- `specs/quality-gates.md` — four-gate quality system (Spec Review → Plan Review → Automated → Milestone Review) covering the full Spec-Kit → GSD-v1 → GSD-2 lifecycle.
- `.specify/memory/GOVERNANCE.md` — constitutional context pre-loaded by Spec-Kit agents before every lifecycle command.
- `.specify/memory/ARCHITECTURE.md` — architecture context pre-loaded by Spec-Kit before `/speckit.plan` and `/speckit.implement`.
- `.planning/config.json` — GSD-v1 configuration including model, verification commands, and constitution path.
- `.planning/PROJECT.md` — project overview template pre-loaded by all GSD-v1 planning agents.
- `.planning/REQUIREMENTS.md` — planning-level requirements derived from Spec-Kit output.
- `.planning/ROADMAP.md` — milestone → slice → XML task plan template compatible with GSD-2's `/gsd` command.
- `.planning/STATE.md` — current planning state snapshot; updated at start and end of each planning session.
- `.planning/DECISIONS.md` — append-only architectural decision log; pre-loaded by every GSD-2 execution agent to prevent state amnesia.
- `.planning/KNOWLEDGE.md` — minimal project knowledge base (per arXiv:2602.11988 — verbose knowledge bases hurt agent performance).
- `.gsd/PREFERENCES.md` — GSD-2 configuration: model routing per phase, budget ceiling, auto-verify commands, stuck detection, crash recovery, and hybrid framework integration settings.
- `docs/FEASIBILITY_STUDY.md` — research-backed feasibility study establishing the business case for the hybrid framework, with LLM hallucination root cause analysis and ROI model.

#### Documentation improvements

- `docs/GETTING_STARTED.md` — added Step 3 (Install the hybrid framework) and Step 5.5 (Start the hybrid workflow); updated resources list.
- `docs/architecture.md` — added Hybrid Framework Architecture section with layer model, handoff diagram, per-layer file tables, and ADR-006 (hybrid sequential phases).
- `README.md` — updated Quick Start (6 steps including hybrid scaffold), updated scaffold section to document both scripts and their outputs, updated docs index with hybrid framework section.
- `CHANGELOG.md` — this entry.

### Changed

- `.gitignore` — added hybrid framework patterns: `.gsd/gsd.db`, `.gsd/*.lock`, `.gsd/reports/`, `.specify/cache/`.

---

## [0.1.0] — Initial scaffold

### Added
- Initial project scaffold (`scripts/scaffold-project.sh`)
- TypeScript strict mode, Jest + ts-jest, ESLint, Prettier
- AGENTS.md with minimal, research-backed agent guidance (arXiv:2602.11988)
- Symlinks: `CLAUDE.md`, `.instructions.md`, `.github/copilot-instructions.md` → `AGENTS.md`
- GitHub Actions CI/CD and security workflows
- VS Code settings, extensions, and task definitions
- Pre-commit hook blocking secrets (OWASP A02)
- Source code skeleton: `src/api/`, `src/db/`, `src/lib/`, `src/middleware/`, `src/services/`, `src/types/`
- Test structure: `tests/unit/`, `tests/integration/`, `tests/e2e/`
- Documentation: `docs/architecture.md`, `docs/api.md`, `docs/GETTING_STARTED.md`
