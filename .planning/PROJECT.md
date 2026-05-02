# Project Overview

> **GSD-v1 project context.** This file is loaded by every planning agent.
> Keep it accurate and concise — it sets the frame for all execution decisions.

## Project

**Name:** YOUR_PROJECT_NAME  
**Purpose:** One-sentence description of what this project does and for whom.  
**Owner:** YOUR_NAME / YOUR_TEAM  
**Repository:** https://github.com/OWNER/REPO

## Current Status

| Phase | Status | Notes |
|-------|--------|-------|
| Definition (Spec-Kit) | 🔄 In progress | `specs/constitution.md` populated |
| Planning (GSD-v1) | ⬜ Not started | Waiting on Spec-Kit Gate 1 review |
| Execution (GSD-2) | ⬜ Not started | Waiting on GSD-v1 Gate 2 review |

## Architecture in One Paragraph

> Write 2-4 sentences describing the system. What does it do, what does it
> NOT do, and what are the key technical components? This paragraph is read
> by every execution agent.

## Key Constraints

- TypeScript strict mode — `any` is forbidden
- 80% test coverage enforced by CI
- All secrets managed via environment variables, never committed to git
- OWASP Top 10 is the security baseline

## Links

| Resource | Path |
|----------|------|
| Constitution | `specs/constitution.md` |
| Requirements | `specs/requirements.md` |
| Quality Gates | `specs/quality-gates.md` |
| Architecture | `docs/architecture.md` |
| Feasibility Study | `docs/FEASIBILITY_STUDY.md` |
