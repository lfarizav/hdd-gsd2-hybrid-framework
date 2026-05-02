# Requirements

> **Purpose:** Translates the constitution into verifiable feature requirements.
> Each requirement maps to one or more GSD-v1 planning phases and GSD-2 slices.
>
> **Format:** Use Gherkin-style Given/When/Then for testable requirements.
> Assign each a unique ID for traceability (REQ-001, REQ-002 ...).

---

## Functional Requirements

### REQ-001 — Kind Cluster Provisioner with Calico CNI and Pre-downloaded Images

**Priority:** HIGH
**Phase:** Spec-Kit → GSD-v1 phase 1 → GSD-2 M001-S01

**Description:**
Provide a shell script (`scripts/kind-cluster.sh`) that creates a kind-based Kubernetes cluster with N control-plane nodes and M worker nodes. The cluster uses Calico as the CNI plugin and requires no live image pulls at runtime — all required container images must be pre-loaded into kind nodes from a local archive or registry mirror.

**Acceptance Criteria:**

```gherkin
Feature: Kind cluster provisioner

  Scenario: Create a multi-node cluster with defaults
    Given kind and kubectl are installed
    And the pre-downloaded image archive is present at IMAGES_DIR
    When the operator runs: ./scripts/kind-cluster.sh --control-planes 1 --workers 2
    Then a kind cluster named "heritage" is created
    And it has 1 control-plane node and 2 worker nodes
    And Calico CNI is installed and all pods reach Running state
    And no image is pulled from the internet during provisioning

  Scenario: Create a HA control-plane cluster
    Given kind and kubectl are installed
    And the pre-downloaded image archive is present at IMAGES_DIR
    When the operator runs: ./scripts/kind-cluster.sh --control-planes 3 --workers 3
    Then a kind cluster with 3 control-plane nodes and 3 workers is created
    And all nodes reach Ready state within 5 minutes
    And Calico CNI is installed and all pods reach Running state

  Scenario: Missing pre-downloaded images
    Given kind and kubectl are installed
    And IMAGES_DIR does not exist or is empty
    When the operator runs: ./scripts/kind-cluster.sh --control-planes 1 --workers 1
    Then the script exits with a non-zero status code
    And a human-readable error message is printed to stderr

  Scenario: Invalid node count arguments
    Given the script is invoked with --control-planes 0
    Then the script exits with a non-zero status code
    And an error message states control-plane count must be >= 1
```

**Out of scope:**
- Cloud provider integration (EKS, GKE, AKS)
- Persistent volume provisioning
- Production TLS certificate management

---

## Non-Functional Requirements

| ID | Category | Requirement | Measurement |
|----|----------|-------------|-------------|
| NFR-001 | Provisioning speed | Cluster reaches Ready state within 5 minutes | Timed in CI on standard hardware |
| NFR-002 | Air-gap compliance | Zero image pulls from internet during provisioning | Verified with network namespace isolation in tests |
| NFR-003 | Idempotency | Re-running the script on an existing cluster is safe (no crash, clear message) | Validated by integration test |
| NFR-004 | Observability | All script errors printed to stderr with actionable messages | Validated by unit tests on helper functions |

---

## Traceability Matrix

| Requirement | Spec-Kit Feature | GSD-v1 Phase | GSD-2 Slice | Test File |
|-------------|-----------------|-------------|-------------|-----------|
| REQ-001 | `specs/features/kind-cluster.feature` | `.planning/ROADMAP.md#P1` | `M001-S01` | `internal/kindcluster/kind_cluster_test.go` |

---

## Revision History

| Date | Author | Change |
|------|--------|--------|
| 2026-05-02 | Luis Felipe Ariza Vesga | Initial requirements — REQ-001 kind cluster provisioner |
