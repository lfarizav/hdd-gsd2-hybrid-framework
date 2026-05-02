# Decision Log

> **Append-only.** Never overwrite or delete entries.
> Every architectural or design decision made during planning or execution
> is recorded here. This file is pre-loaded for every GSD-2 execution agent
> to prevent state amnesia across sessions.
>
> **Format:** ADR-lite (Decision, Context, Consequences).

---

## ADR-001 — Adopt Hybrid Framework (Spec-Kit + GSD-v1 + GSD-2)

**Date:** <!-- FILL IN -->  
**Status:** Accepted  
**Decision:** Implement the three-layer hybrid framework as the primary development methodology for this project.

**Context:** The team identified that LLM hallucinations were the primary source of rework in AI-assisted development. Research (Gloaguen et al., 2026; arXiv:2602.11988) confirmed that targeted, minimal context outperforms verbose context. Each framework targets a distinct hallucination root cause.

**Consequences:**
- (+) Structural hallucination reduction at requirements, planning, and execution levels
- (+) Clear handoff points between phases; no framework conflicts
- (-) Requires discipline to follow the sequential phase model
- (-) Setup overhead; not appropriate for projects < 6 weeks

**Reference:** `docs/FEASIBILITY_STUDY.md`

---

## ADR-002 — M001-S01-T01: Research Phase Completes (All Findings Verified)

**Date:** 2025-01-08  
**Status:** Verified  
**Decision:** All research questions for heritage project answered with citations to official documentation only.

**Context:** Constitution value #6 (research-mandatory) requires all technical decisions backed by evidence. M001-S01-T01 researched:
- kind image loading architecture (pre-load via `kind load docker-image` post-cluster creation)
- Calico pod CIDR defaults (10.244.0.0/16, configured via Tigera Operator)
- Air-gap deployment requirements (all images pre-loaded; `:latest` tag forbidden)
- Go 1.22+ error handling (errors.Is/As wrapping via fmt.Errorf("%w", err))

**Evidence:**
- kind quick-start: https://kind.sigs.k8s.io/docs/user/quick-start/#loading-an-image-into-your-cluster
- Calico operator install: https://docs.tigera.io/calico/latest/getting-started/kubernetes/self-managed-onprem/onpremises
- Go 1.13 errors: https://go.dev/blog/go1.13-errors
- Effective Go: https://go.dev/doc/effective_go

**Consequences:**
- (+) All architectural decisions now grounded in official sources (no guessing)
- (+) Air-gap constraint identified early (`:latest` tags forbidden; imagePullPolicy required)
- (+) Go error handling pattern established (fmt.Errorf with %w, errors.Is/As)
- (+) Ready for M001-S01-T02 (Go module setup with verified dependency versions)
- (-) None identified

**Reference:** `.planning/research/M001-S01-research.md` (research findings complete)

---

## ADR-003 — M001-S01-T02: Go Module Setup Complete

**Date:** 2026-05-02  
**Status:** Accepted  
**Decision:** Go module `github.com/lfarizav/heritage` initialised with Go 1.26.2; testify v1.11.1 pinned as the sole direct test dependency.

**Context:** Task M001-S01-T02 required initialising the Go project structure: `go.mod`, directory layout (`cmd/kind-cluster`, `internal/kindcluster`, `internal/imageload`, `tests/unit`, `tests/integration`), a minimal `cmd/kind-cluster/main.go`, and a table-driven unit test (`tests/unit/example_test.go`) to validate the module is importable. The Makefile was updated to scope `go test`, `go vet`, and `golangci-lint` to `./cmd/... ./internal/... ./tests/...` to avoid false-positive coverage noise from third-party Go files in `node_modules`.

**Consequences:**
- (+) `go mod tidy && go test ./cmd/... ./internal/... ./tests/... && go build ./cmd/kind-cluster` all pass
- (+) testify v1.11.1 pinned; no floating latest dependency at runtime
- (+) Makefile `GO_PKGS` variable isolates project packages from node_modules
- (+) Ready for M001-S01-T03 (CI/CD workflow) and M001-S02 (CLI implementation)
- (-) `cmd/kind-cluster/main.go` is a stub; 0% coverage is expected until S02 implements real logic

**Reference:** `go.mod`, `tests/unit/example_test.go`, `Makefile` (GO_PKGS variable)

---

## ADR-004 — M001-S01-T03: CI/CD Configuration Complete

**Date:** 2026-05-02  
**Status:** Accepted  
**Decision:** Go CI job added to `.github/workflows/ci.yml` alongside the existing Node/TypeScript job. Coverage threshold (80%) is enforced on `./internal/...` packages only; the check is skipped while no internal packages exist (setup phase).

**Context:** Task M001-S01-T03 required a CI pipeline that runs `go test`, `go vet`, `golangci-lint`, and `go build` on every push/PR. Three design choices were made:
1. **Single workflow file** — Go job added to the existing `ci.yml` (not a separate file) to keep CI surface minimal.
2. **Coverage scope** — Threshold applies to `./internal/...` only, not the CLI stub. Guard: `go list ./internal/... | wc -l == 0` → skip. This avoids false failures during S01 when no library code exists yet.
3. **golangci-lint via action** — `golangci/golangci-lint-action@v8` used for automatic version management; `.golangci.yml` excludes `node_modules/` and `vendor/`.

**Evidence:**
- golangci-lint-action: https://github.com/golangci/golangci-lint-action
- actions/setup-go: https://github.com/actions/setup-go
- Gate logic verified locally: `internal_pkgs=0` → skip ✅

**Consequences:**
- (+) Every push runs test + vet + lint + build on Go code
- (+) Coverage threshold auto-activates once `internal/` packages contain statements
- (+) `.golangci.yml` prevents node_modules noise in linter output
- (+) `.gsd/PREFERENCES.md` updated with Go verification commands for manual execution
- (-) Coverage threshold is vacuously satisfied during S01; meaningful enforcement begins in S02

**Reference:** `.github/workflows/ci.yml` (go-ci job), `.golangci.yml`, `.gsd/PREFERENCES.md`

---

## ADR-005 — M001-S02: CLI & Cluster Core Complete

**Date:** 2026-05-02  
**Status:** Accepted  
**Decision:** Implemented CLI flag parsing, kind cluster provisioner, Calico CNI installer, and all unit tests. Coverage is 91.9% (threshold: 85%).

**Context:** Four design decisions were made:

1. **Executor injection pattern** — `type Executor func(ctx, name, args...) ([]byte, error)` is defined in `internal/kindcluster/exec.go` and injected into `CreateCluster` and `InstallCalicoNS`. This avoids `os/exec` mocking via reflection and keeps test setup to a simple function literal.

2. **Flag parsing in `internal/kindcluster/flags.go`** — Moving `ParseFlags` and `ValidateClusterName` out of `package main` allows `tests/unit/cli_test.go` to import and test them without shelling out to the binary.

3. **ErrClusterExists sentinel** — `errors.New("cluster already exists")` allows callers to distinguish the "already exists" case (recoverable with `--delete-existing`) from generic kind failures, using `errors.Is`.

4. **Calico Tigera Operator approach** — Two-step install (`tigera-operator.yaml` then `custom-resources.yaml`) per ADR-002 research. Version pinned as constant `CalicoVersion = "v3.32.0"` in `config.go`.

**Consequences:**
- (+) All unit tests pass; 91.9% coverage on `./internal/kindcluster`
- (+) Integration test in `tests/integration/calico_test.go` is tagged `//go:build integration` and skips automatically unless docker/kind/kubectl are present
- (+) `cmd/kind-cluster` is a thin wrapper; all logic is in `internal/`
- (-) `CreateCluster` has two untestable branches (OS-level `os.CreateTemp` and `f.WriteString` failures); both are acceptable at this coverage level

**Reference:** `internal/kindcluster/`, `cmd/kind-cluster/main.go`, `tests/unit/cli_test.go`, `internal/kindcluster/provisioner_test.go`, `internal/kindcluster/cni_test.go`

---

## ADR-006 — M001-S03 + S04: Image Pre-loading, Idempotency & Documentation Complete

**Date:** 2026-05-02  
**Status:** Accepted  
**Decision:** Implemented air-gap image loading (`internal/imageload/`), idempotency checks (`ClusterExists`, `DeleteCluster`), integrated the full provisioning flow in `cmd/kind-cluster/main.go`, wrote integration tests for all 5 Gherkin scenarios, and created user documentation (INSTALLATION.md, USAGE.md, TROUBLESHOOTING.md).

**Key design decisions:**

1. **`ValidateAirGap` before cluster creation** — Pre-flight validation runs before any state-changing operation. If images are missing, the binary exits before creating the cluster, avoiding partial-provisioning cleanup.

2. **`--images-dir` flag + `IMAGES_DIR` env** — Flag takes precedence; env var is the fallback. Both ultimately resolve in `main.go` before calling `LoadImagesFromArchive`. No hardcoded paths.

3. **`ListArchives` + per-archive load loop** — Instead of passing a directory to kind, each `.tar`/`.tar.gz` is loaded individually, giving precise per-image error reporting.

4. **`ClusterExists` via `kind get clusters`** — Output parsing is intentional; kind has no structured JSON output for this command. The exact-name match guards against prefix collisions.

5. **Integration tests build-tagged** — `//go:build integration` keeps unit CI fast. Tests skip automatically when docker/kind/kubectl are absent.

**Final quality gate results:**
- `go build ./cmd/kind-cluster` ✅
- `go vet ./cmd/... ./internal/... ./tests/...` ✅  
- `go test ./internal/... ./tests/unit/...` — all pass ✅
- Coverage: **92.5%** (threshold: 80%) ✅
- Docs: `docs/INSTALLATION.md`, `docs/USAGE.md`, `docs/TROUBLESHOOTING.md` ✅

**Reference:** `internal/imageload/`, `internal/kindcluster/checks.go`, `cmd/kind-cluster/main.go`, `tests/integration/e2e_test.go`, `docs/`
