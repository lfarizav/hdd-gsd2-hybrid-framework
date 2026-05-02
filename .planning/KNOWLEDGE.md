# Project Knowledge Base

> **Append-only shared knowledge.** Facts about this codebase that agents
> need to do their jobs correctly. Updated after every Gate 4 review.
>
> Keep entries SHORT. Per arXiv:2602.11988, verbose knowledge bases hurt
> rather than help. Each entry should be one fact an agent could not infer
> from reading source files.

---

## Framework & Tooling Facts

- **Test runner:** `go test` (stdlib). Run with `go test ./...`. Coverage: `go test -coverprofile=coverage.out ./... && go tool cover -func=coverage.out`. Threshold: 80% statements.
- **Linter:** `golangci-lint`. Run with `golangci-lint run ./...`. Config in `.golangci.yml` if needed.
- **Vet:** `go vet`. Run with `go vet ./...`. Catches common Go mistakes.
- **Build:** `go build ./cmd/kind-cluster`. Output: `./cmd/kind-cluster/kind-cluster` binary.
- **Formatter:** `gofmt` (enforces tabs) + `goimports` (auto-import management). Both baked into most editors.
- **Dependencies:** Manage via `go.mod` and `go get`. Verify versions against pkg.go.dev before pinning.

## Codebase Conventions

- **Packages:** organized by functionality. `internal/` for private packages, `cmd/` for CLI entry points.
- **Error handling:** Explicit `error` returns; no `panic` in library code. Wrap errors with `fmt.Errorf("%w", err)` for context.
- **Testing:** Table-driven tests preferred. Tests live in `*_test.go` files alongside source. Mock external calls (exec, kubectl, etc.).
- **Naming:** Descriptive names: `fetchUserByID` not `getUser` + a comment. Avoid `interface{}` unless genuinely polymorphic.
- **Logging:** Use stdlib `log` or `slog` (Go 1.21+). Log all command invocations and errors for observability.
- **Configuration:** Store in `internal/kindcluster/config.go`. No hardcoded values in business logic.

## Known Constraints

- **Air-gap deployments:** Must pre-load ALL cluster images before kind bootstrap. Document image list in research.
- **kind.sigs.k8s.io:** Kind version compatibility with Calico CNI must be validated during S01 research.
- **Calico CNI:** Pod CIDR in kind cluster config must match Calico's expectations (default 10.244.0.0/16).
- **Idempotency:** Script must detect existing cluster and fail gracefully unless --delete-existing flag is passed.

## Known Decisions

| Date | Decision | Rationale | Phase |
|------|----------|-----------|-------|
| 2026-05-02 | Use Go 1.22+ (not older) | Latest LTS version, security updates, performance improvements | Definition |
| 2026-05-02 | Research-first, no guessing | Constitution value #6: all coding backed by facts, peer-reviewed sources, official docs | Definition |

## Lessons Learned

> Append after each milestone Gate 4 review.

| Date | Lesson | Phase |
|------|--------|-------|
| 2026-05-02 | Hybrid framework + research-mandatory values reduce hallucination in M001 planning | Planning |
