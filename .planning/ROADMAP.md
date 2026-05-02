# Development Roadmap

> **GSD-v1 Planning Output → GSD-2 Execution Input.**
> Maps REQ-001 (Kind Cluster Provisioner) into executable milestones with research checkpoints.
> Each phase enforces constitution values: evidence-first, research-mandatory, no guessing.
>
> **Rule:** Each phase here = one GSD-2 milestone (4-10 slices).
> Each slice = 1-7 tasks. Each task must fit in one 200K context window.

---

## Milestone M001 — Kind Cluster Provisioner with Calico CNI

**GSD-2 command:** `gsd /gsd auto --milestone M001`
**Maps to:** `specs/requirements.md#REQ-001` + `specs/features/kind-cluster.feature`
**Target:** 4 slices across 2 weeks
**Success criteria:** All 5 Gherkin scenarios in feature file pass; 80%+ test coverage; zero hardcoded values

---

### Slice S01 — Research & Go Project Setup

> **Phase:** Gather facts, establish project structure, validate dependencies are current.
> This slice enforces constitution value #6 (research-mandatory, no guessing).

**Research Checkpoint (MUST COMPLETE BEFORE CODING):**

Before writing any code, the agent must:
1. Fetch official docs:
   - [kind.sigs.k8s.io](https://kind.sigs.k8s.io) — cluster config, image handling, best practices
   - [projectcalico.org](https://projectcalico.org) — CNI installation, pod CIDR requirements, version compatibility
   - [golang.org](https://golang.org/doc/effective_go) — current Go idioms (1.22+ features)
2. Search for peer-reviewed or official guidance on:
   - Air-gap Kubernetes deployments (what images are mandatory?)
   - Kind node bootstrap process (when can images be pre-loaded?)
   - Calico CNI vs other CNI plugins (why Calico for this project?)
3. Document findings in `.planning/research/M001-S01-research.md` (template in KNOWLEDGE.md)
4. Flag any uncertainties as clarification questions in DECISIONS.md

**Tasks:**

```xml
<task id="M001-S01-T01">
  <action>Research kind architecture and Calico CNI integration</action>
  <must_haves>
    <item>Research document `.planning/research/M001-S01-research.md` exists</item>
    <item>Documents: kind cluster lifecycle, image loading points, Calico pod CIDR defaults</item>
    <item>Any clarification questions recorded in `.planning/DECISIONS.md`</item>
    <item>Go 1.22+ latest patch version identified and recorded</item>
  </must_haves>
  <artifact>.planning/research/M001-S01-research.md</artifact>
  <truth>File exists, ≥3 peer-reviewed/official sources cited</truth>
  <verify>Verify research doc exists and is >500 words with citations</verify>
</task>

<task id="M001-S01-T02">
  <action>Initialize Go module and project structure</action>
  <must_haves>
    <item>go.mod exists with module name `github.com/lfarizav/heritage`</item>
    <item>Directories created: cmd/kind-cluster, internal/kindcluster, internal/imageload, tests/unit, tests/integration</item>
    <item>go.mod pins testify and any other dependencies to latest stable versions (verified against pkg.go.dev)</item>
    <item>No vendor/ or go.sum changes without rationale in git commit</item>
    <item>README.md root exists with one-sentence project description</item>
  </must_haves>
  <artifact>go.mod, cmd/, internal/, tests/, README.md</artifact>
  <truth>tests/unit/example_test.go passes with `go test ./...`</truth>
  <verify>go mod tidy && go test ./... && go build ./cmd/kind-cluster</verify>
</task>

<task id="M001-S01-T03">
  <action>Set up CI/CD verification for Go project</action>
  <must_haves>
    <item>.github/workflows/ci.yml exists (or .github/workflows/test.yml)</item>
    <item>CI runs: go test, go vet, golangci-lint, go build</item>
    <item>CI enforces 80% statement coverage via `go tool cover`</item>
    <item>.gsd/PREFERENCES.md configured with Go verification commands</item>
  </must_haves>
  <artifact>.github/workflows/ci.yml, .gsd/PREFERENCES.md</artifact>
  <truth>CI pipeline runs successfully on local push</truth>
  <verify>Act (or similar local CI tool) runs workflow without errors</verify>
</task>
```

---

### Slice S02 — CLI & Cluster Creation Core

> **Phase:** Implement main CLI entry point and core cluster creation logic.
> Research findings from S01 guide all design decisions.

**Tasks:**

```xml
<task id="M001-S02-T01">
  <action>Implement cmd/kind-cluster/main.go with flag parsing</action>
  <must_haves>
    <item>Accepts flags: --control-planes (default 1), --workers (default 2), --cluster-name (default "heritage")</item>
    <item>Validates: control-planes ≥ 1, workers ≥ 0, cluster-name is DNS-1123 compliant</item>
    <item>Exits with non-zero code and human-readable error on invalid input</item>
    <item>Uses flag.FlagSet or cobra (if chosen in research, document why)</item>
    <item>No hardcoded values; all constants defined in internal/kindcluster/config.go</item>
  </must_haves>
  <artifact>cmd/kind-cluster/main.go, internal/kindcluster/config.go</artifact>
  <truth>tests/unit/cli_test.go validates all flag combinations</truth>
  <verify>go test ./tests/unit -run TestCLI && go build ./cmd/kind-cluster</verify>
</task>

<task id="M001-S02-T02">
  <action>Implement internal/kindcluster/provisioner.go — cluster creation logic</action>
  <must_haves>
    <item>func CreateCluster(ctx context.Context, config ClusterConfig) error exists</item>
    <item>Generates kind cluster config YAML based on control-planes, workers count</item>
    <item>Calls `kind create cluster --config=...` via os/exec</item>
    <item>Returns error if: kind not installed, cluster already exists, cluster creation fails</item>
    <item>Logs all command invocations to logger (from research: choose slog or compatible stdlib)</item>
    <item>All errors are wrapped with context via errors.Is/errors.As or fmt.Errorf("%w")</item>
  </must_haves>
  <artifact>internal/kindcluster/provisioner.go</artifact>
  <truth>tests/unit/provisioner_test.go mocks exec calls, validates YAML generation, error handling</truth>
  <verify>go test ./internal/kindcluster -run TestCreateCluster && go test -coverprofile=coverage.out ./internal/kindcluster</verify>
</task>

<task id="M001-S02-T03">
  <action>Implement Calico CNI installation</action>
  <must_haves>
    <item>func InstallCalicoNS(ctx context.Context, kubeconfig string, clusterName string) error exists</item>
    <item>Applies Calico manifest via kubectl --kubeconfig flag</item>
    <item>Uses Calico version pinned in go.mod or as a constant (document why in config.go)</item>
    <item>Validates: kubectl is installed, kubeconfig exists, pod CIDR in kind config matches Calico expectations</item>
    <item>Waits for calico-system pods to reach Running state (max 5 minutes, configurable)</item>
    <item>Returns descriptive error if CNI installation fails</item>
  </must_haves>
  <artifact>internal/kindcluster/cni.go</artifact>
  <truth>tests/integration/calico_test.go validates installation against a real kind cluster (integration test only, not unit)</truth>
  <verify>go test ./tests/integration -run TestCalicoInstall (only if kind/docker available)</verify>
</task>

<task id="M001-S02-T04">
  <action>Write comprehensive unit tests for S02</action>
  <must_haves>
    <item>tests/unit/provisioner_test.go covers: valid config, cluster exists error, kind not found error</item>
    <item>tests/unit/cni_test.go mocks kubectl, validates manifest application logic</item>
    <item>All unit tests use table-driven tests (Go idiom)</item>
    <item>Coverage for provisioner.go and cni.go ≥ 85%</item>
    <item>Run `go test ./tests/unit -v` — all must pass</item>
  </must_haves>
  <artifact>tests/unit/provisioner_test.go, tests/unit/cni_test.go</artifact>
  <truth>go test -cover ./tests/unit reports ≥85% coverage</truth>
  <verify>go test ./tests/unit -v && go test -coverprofile=out.out ./tests/unit && go tool cover -html=out.out</verify>
</task>
```

---

### Slice S03 — Image Pre-loading & Air-Gap Support

> **Phase:** Implement image archive loading and air-gap validation.
> Ensures zero internet pulls during cluster bootstrap.

**Tasks:**

```xml
<task id="M001-S03-T01">
  <action>Implement internal/imageload/loader.go — image archive handling</action>
  <must_haves>
    <item>func LoadImagesFromArchive(ctx context.Context, archivePath string, clusterName string) error exists</item>
    <item>Accepts tar.gz archive of Docker images</item>
    <item>Uses `kind load image-archive` to inject images into cluster nodes</item>
    <item>Validates: archive exists, is readable, tar format is valid</item>
    <item>Logs each image being loaded (for observability)</item>
    <item>Returns error if load fails; does not silently continue</item>
    <item>Idempotent: if image already loaded, skip (no error)</item>
  </must_haves>
  <artifact>internal/imageload/loader.go</artifact>
  <truth>tests/unit/imageload_test.go mocks kind load, validates archive validation</truth>
  <verify>go test ./internal/imageload -run TestLoadImages</verify>
</task>

<task id="M001-S03-T02">
  <action>Implement air-gap validation</action>
  <must_haves>
    <item>func ValidateAirGap(ctx context.Context, imagesDir string) error exists</item>
    <item>Checks: IMAGES_DIR env var is set OR imagesDir parameter provided</item>
    <item>Checks: directory exists and is readable</item>
    <item>Checks: required image files are present (document which images in research)</item>
    <item>Returns structured error with actionable message if validation fails</item>
  </must_haves>
  <artifact>internal/imageload/validation.go</artifact>
  <truth>tests/unit/validation_test.go covers all error cases</truth>
  <verify>go test ./internal/imageload -run TestValidateAirGap</verify>
</task>

<task id="M001-S03-T03">
  <action>Integrate image loading into main provisioning flow</action>
  <must_haves>
    <item>cmd/kind-cluster/main.go calls LoadImagesFromArchive after cluster creation, before Calico install</item>
    <item>Main function handles image load errors gracefully: logs, cleans up cluster, exits non-zero</item>
    <item>Flag --images-dir added (optional, defaults to env IMAGES_DIR)</item>
    <item>No hardcoded image paths in code</item>
  </must_haves>
  <artifact>cmd/kind-cluster/main.go (updated), internal/imageload/integration.go</artifact>
  <truth>tests/integration/e2e_test.go validates full flow: cluster creation → image load → Calico install</truth>
  <verify>go test ./tests/integration -run TestE2E (if kind/docker available)</verify>
</task>

<task id="M001-S03-T04">
  <action>Write comprehensive tests for image loading</action>
  <must_haves>
    <item>tests/unit/imageload_test.go covers: valid archive, missing archive, corrupt archive, already-loaded image</item>
    <item>tests/unit/validation_test.go covers: IMAGES_DIR set, IMAGES_DIR missing, permissions errors</item>
    <item>Coverage for imageload/** ≥ 85%</item>
  </must_haves>
  <artifact>tests/unit/imageload_test.go, tests/unit/validation_test.go</artifact>
  <truth>go test -cover ./internal/imageload reports ≥85%</truth>
  <verify>go test ./internal/imageload -v && go test -coverprofile=out.out ./internal/imageload</verify>
</task>
```

---

### Slice S04 — Error Handling, Idempotency & Documentation

> **Phase:** Handle edge cases, ensure idempotent operations, document for users.

**Tasks:**

```xml
<task id="M001-S04-T01">
  <action>Implement idempotency and edge case handling</action>
  <must_haves>
    <item>func ClusterExists(ctx context.Context, clusterName string) (bool, error) exists</item>
    <item>Script checks if cluster already exists before attempting creation</item>
    <item>If cluster exists, returns error with message: "Cluster 'heritage' already exists. Run with --delete-existing to recreate."</item>
    <item>Implement optional --delete-existing flag to delete + recreate</item>
    <item>Script validates: kind installed, kubectl installed, kubeconfig paths valid</item>
    <item>All validation happens before any state-changing operation</item>
  </must_haves>
  <artifact>internal/kindcluster/checks.go</artifact>
  <truth>tests/unit/checks_test.go validates all edge cases</truth>
  <verify>go test ./internal/kindcluster -run TestCluster</verify>
</task>

<task id="M001-S04-T02">
  <action>Write integration tests for all Gherkin scenarios</action>
  <must_haves>
    <item>tests/integration/e2e_test.go implements all 5 scenarios from specs/features/kind-cluster.feature</item>
    <item>Scenario 1 (happy path, 1 cp + 2 workers): create cluster, verify nodes Ready, Calico running</item>
    <item>Scenario 2 (HA, 3 cp + 3 workers): create cluster, verify all 6 nodes Ready</item>
    <item>Scenario 3 (missing images): validates error handling when IMAGES_DIR missing</item>
    <item>Scenario 4 (invalid args): validates error on --control-planes=0</item>
    <item>Scenario 5 (idempotent): validates existing cluster detection + --delete-existing behavior</item>
    <item>Integration tests are marked with build tag `//go:build integration`</item>
  </must_haves>
  <artifact>tests/integration/e2e_test.go</artifact>
  <truth>All 5 scenarios pass; Gherkin scenarios map 1:1 to test cases</truth>
  <verify>go test -tags=integration ./tests/integration -v</verify>
</task>

<task id="M001-S04-T03">
  <action>Write user documentation</action>
  <must_haves>
    <item>docs/INSTALLATION.md: how to install kind, kubectl, Docker</item>
    <item>docs/USAGE.md: examples of running ./kind-cluster with different flags</item>
    <item>docs/TROUBLESHOOTING.md: common errors (kind not found, cluster exists, image load fails) with fixes</item>
    <item>cmd/kind-cluster/main.go has --help output that documents all flags</item>
    <item>Each file is ≥200 words and cites any external tools/versions</item>
  </must_haves>
  <artifact>docs/INSTALLATION.md, docs/USAGE.md, docs/TROUBLESHOOTING.md</artifact>
  <truth>README.md links to all three docs; --help is comprehensive</truth>
  <verify>./kind-cluster --help && test -f docs/*.md && wc -w docs/*.md</verify>
</task>

<task id="M001-S04-T04">
  <action>Final verification: all quality gates pass</action>
  <must_haves>
    <item>go test -coverprofile=coverage.out ./... passes, coverage ≥ 80%</item>
    <item>go vet ./... passes with zero warnings</item>
    <item>golangci-lint run ./... passes</item>
    <item>go build ./cmd/kind-cluster succeeds, binary created</item>
    <item>.planning/DECISIONS.md documents all research findings and decisions</item>
    <item>.planning/KNOWLEDGE.md documents lessons learned from this milestone</item>
    <item>All `// TODO` comments resolved or linked to issues</item>
  </must_haves>
  <artifact>Binary: cmd/kind-cluster/kind-cluster</artifact>
  <truth>All gates in specs/quality-gates.md Gate 3 pass</truth>
  <verify>go test -coverprofile=coverage.out ./... && go vet ./... && golangci-lint run ./... && go build ./cmd/kind-cluster && echo "M001 COMPLETE"</verify>
</task>
```

---

## Roadmap Status

| Milestone | Slices | Status | Gate | GSD-2 Mode |
|-----------|--------|--------|------|-----------|
| M001 | S01-S04 | ⬜ Not started | Awaiting Gate 2 review | Step (`/gsd`) or Auto (`/gsd auto`) |

---

## GSD-v1 → GSD-2 Handoff Checklist

Before running `gsd /gsd auto`:

- [ ] M001 has 4 complete slices with task definitions
- [ ] All task `<must_haves>` are specific and machine-verifiable
- [ ] Research checkpoint in S01-T01 is clearly documented
- [ ] `.gsd/PREFERENCES.md` verification commands configured for Go
- [ ] `specs/quality-gates.md` Gate 2 checklist signed off by human
- [ ] `specs/constitution.md` has no placeholder text; research-first values present
- [ ] `.planning/DECISIONS.md` has initial research findings recorded
- [ ] `.planning/research/` directory initialized with research templates
