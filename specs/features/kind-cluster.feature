Feature: Kind cluster provisioner
  # REQ-001 — Kind Cluster Provisioner with Calico CNI and Pre-downloaded Images
  # Ref: specs/requirements.md#REQ-001

  Background:
    Given kind and kubectl are installed on the host
    And the pre-downloaded image archive is present at IMAGES_DIR

  Scenario: Create a single control-plane cluster (default)
    When the operator runs: ./scripts/kind-cluster.sh --control-planes 1 --workers 2
    Then a kind cluster named "heritage" is created
    And it has exactly 1 control-plane node and 2 worker nodes
    And all nodes reach Ready state within 5 minutes
    And Calico CNI is installed and all calico-system pods reach Running state
    And no image is pulled from the internet during provisioning

  Scenario: Create a HA control-plane cluster
    When the operator runs: ./scripts/kind-cluster.sh --control-planes 3 --workers 3
    Then a kind cluster with 3 control-plane nodes and 3 workers is created
    And all nodes reach Ready state within 5 minutes
    And Calico CNI is installed and all calico-system pods reach Running state

  Scenario: Missing pre-downloaded images directory
    Given IMAGES_DIR does not exist or is empty
    When the operator runs: ./scripts/kind-cluster.sh --control-planes 1 --workers 1
    Then the script exits with a non-zero status code
    And a human-readable error message is printed to stderr

  Scenario: Invalid control-plane count
    When the operator runs: ./scripts/kind-cluster.sh --control-planes 0 --workers 1
    Then the script exits with a non-zero status code
    And the error message states "control-plane count must be >= 1"

  Scenario: Idempotent re-run on existing cluster
    Given a "heritage" cluster already exists
    When the operator runs: ./scripts/kind-cluster.sh --control-planes 1 --workers 2
    Then the script exits with a non-zero status code
    And the error message states the cluster already exists and suggests --delete-existing
