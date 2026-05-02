# Governance Context

> This file is loaded by Spec-Kit's Memory Loader extension before every
> lifecycle command. It provides stable constitutional context to the LLM.
> Keep it SHORT and PRECISE — per arXiv:2602.11988, unnecessary context
> increases cost and reduces task success.

## Active Constitution

See: `specs/constitution.md`

## Active Quality Gates

See: `specs/quality-gates.md`

## Framework Handoff Rules

1. Spec-Kit owns the Definition phase. Output: `specs/*.md`.
2. GSD-v1 owns the Planning phase. Input: `specs/requirements.md`. Output: `.planning/ROADMAP.md`.
3. GSD-2 owns the Execution phase. Input: `.planning/ROADMAP.md`. Output: code + DECISIONS.md.
4. Only one framework is active at a time. No simultaneous operation.

## Non-Negotiables (constitutional cascade)

- TypeScript strict mode — `any` is never acceptable
- Tests before marking a task done — `npm test` must pass
- No secrets in source code or commit messages
- Minimal AGENTS.md — only requirements agents cannot discover themselves
