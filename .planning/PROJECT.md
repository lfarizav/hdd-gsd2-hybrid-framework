# Project Overview

> **GSD-v1 project context.** This file is loaded by every planning agent.
> Keep it accurate and concise — it sets the frame for all execution decisions.

## Project

**Name:** heritage
**Purpose:** Deploys a Kubernetes cluster using kind with Calico CNI and pre-downloaded images, supporting N control-plane nodes and M worker nodes.
**Owner:** Luis Felipe Ariza Vesga
**Repository:** https://github.com/lfarizav/hdd-gsd2-hybrid-framework.git

## Current Status

| Phase | Status | Notes |
|-------|--------|-------|
| Definition (Spec-Kit) | ✅ Complete | REQ-001 fully specified in `specs/requirements.md` |
| Planning (GSD-v1) | 🔄 In progress | Creating ROADMAP.md with research checkpoints |
| Execution (GSD-2) | ⬜ Not started | Waiting on GSD-v1 Gate 2 review |

## Architecture in One Paragraph

Heritage is a shell-based provisioning tool that creates multi-node Kubernetes clusters using kind (Kubernetes in Docker) with Calico as the CNI plugin. It supports air-gap deployments by pre-loading all required container images before cluster bootstrap. It does NOT provide production cluster hardening, persistent storage, or cloud provider integration—those are out-of-scope. Core components: `cmd/kind-cluster` (CLI), `internal/kindcluster` (orchestration), `internal/imageload` (image management), `tests/` (comprehensive tests).

## Key Constraints

- Go 1.22+ — no `interface{}` without justification
- 80% statement coverage enforced by `go test -cover`
- Code with solid reasons, facts, evidence, or research — never guess
- Research mandatory: check latest Go stdlib, kind, Calico docs before coding
- OWASP Top 10 is the security baseline
- All secrets managed via environment variables, never committed to git

## Links

| Resource | Path |
|----------|------|
| Constitution | `specs/constitution.md` |
| Requirements | `specs/requirements.md` |
| Quality Gates | `specs/quality-gates.md` |
| Architecture | `docs/architecture.md` |
| Feasibility Study | `docs/FEASIBILITY_STUDY.md` |
