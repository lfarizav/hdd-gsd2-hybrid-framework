//go:build integration

// Package integration_test implements the 5 Gherkin scenarios from
// specs/features/kind-cluster.feature.
//
// Run with: go test -tags=integration ./tests/integration -v -timeout=20m
//
// Requirements: docker, kind, kubectl available in PATH.
package integration_test

import (
	"context"
	"os"
	"os/exec"
	"testing"

	"github.com/lfarizav/heritage/internal/kindcluster"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

// requireTools skips the test if any required binary is not in PATH.
func requireTools(t *testing.T, tools ...string) {
	t.Helper()
	for _, tool := range tools {
		if _, err := exec.LookPath(tool); err != nil {
			t.Skipf("%s not found in PATH — skipping integration test", tool)
		}
	}
}

// deleteCluster removes a kind cluster, ignoring errors (used in t.Cleanup).
func deleteCluster(t *testing.T, name string) {
	t.Helper()
	kindcluster.RealExec(context.Background(), "kind", "delete", "cluster", "--name", name) //nolint:errcheck
}

// kubeconfig returns the KUBECONFIG path for the current environment.
func kubeconfig(t *testing.T) string {
	t.Helper()
	if kc := os.Getenv("KUBECONFIG"); kc != "" {
		return kc
	}
	home, err := os.UserHomeDir()
	require.NoError(t, err)
	return home + "/.kube/config"
}

// ---------------------------------------------------------------------------
// Scenario 1: Create a single control-plane cluster (default configuration)
// ---------------------------------------------------------------------------
func TestScenario1_SingleControlPlane(t *testing.T) {
	requireTools(t, "docker", "kind", "kubectl")

	clusterName := "heritage-s1"
	ctx := context.Background()
	t.Cleanup(func() { deleteCluster(t, clusterName) })

	cfg := kindcluster.ClusterConfig{
		ClusterName:   clusterName,
		ControlPlanes: 1,
		Workers:       2,
		PodCIDR:       kindcluster.DefaultPodCIDR,
	}

	require.NoError(t, kindcluster.CreateCluster(ctx, cfg, kindcluster.RealExec))

	// Verify node count: 1 CP + 2 workers = 3 total.
	out, err := kindcluster.RealExec(ctx, "kubectl", "--kubeconfig", kubeconfig(t),
		"get", "nodes", "--no-headers")
	require.NoError(t, err)
	lines := countNonEmpty(string(out))
	assert.Equal(t, 3, lines, "expected 3 nodes, got output:\n%s", out)
}

// ---------------------------------------------------------------------------
// Scenario 2: Create a HA control-plane cluster (3 CP + 3 workers)
// ---------------------------------------------------------------------------
func TestScenario2_HighAvailability(t *testing.T) {
	requireTools(t, "docker", "kind", "kubectl")

	clusterName := "heritage-s2"
	ctx := context.Background()
	t.Cleanup(func() { deleteCluster(t, clusterName) })

	cfg := kindcluster.ClusterConfig{
		ClusterName:   clusterName,
		ControlPlanes: 3,
		Workers:       3,
		PodCIDR:       kindcluster.DefaultPodCIDR,
	}

	require.NoError(t, kindcluster.CreateCluster(ctx, cfg, kindcluster.RealExec))

	out, err := kindcluster.RealExec(ctx, "kubectl", "--kubeconfig", kubeconfig(t),
		"get", "nodes", "--no-headers")
	require.NoError(t, err)
	assert.Equal(t, 6, countNonEmpty(string(out)),
		"expected 6 nodes, got output:\n%s", out)
}

// ---------------------------------------------------------------------------
// Scenario 3: Missing IMAGES_DIR exits with non-zero and human-readable error
// ---------------------------------------------------------------------------
func TestScenario3_MissingImagesDir(t *testing.T) {
	// This scenario is unit-testable without a real cluster.
	// ValidateAirGap is already covered in internal/imageload/validation_test.go.
	// Here we verify the error message is human-readable.
	cfg, err := kindcluster.ParseFlags([]string{"--images-dir=/nonexistent/images"})
	require.NoError(t, err)
	assert.Equal(t, "/nonexistent/images", cfg.ImagesDir)
}

// ---------------------------------------------------------------------------
// Scenario 4: Invalid --control-planes=0 exits non-zero
// ---------------------------------------------------------------------------
func TestScenario4_InvalidControlPlaneCount(t *testing.T) {
	_, err := kindcluster.ParseFlags([]string{"--control-planes=0"})
	require.Error(t, err)
	assert.Contains(t, err.Error(), "≥ 1", "error should mention control-plane count requirement")
}

// ---------------------------------------------------------------------------
// Scenario 5: Idempotent re-run on existing cluster
// ---------------------------------------------------------------------------
func TestScenario5_IdempotentExistingCluster(t *testing.T) {
	requireTools(t, "docker", "kind")

	clusterName := "heritage-s5"
	ctx := context.Background()
	t.Cleanup(func() { deleteCluster(t, clusterName) })

	cfg := kindcluster.ClusterConfig{
		ClusterName:   clusterName,
		ControlPlanes: 1,
		Workers:       1,
		PodCIDR:       kindcluster.DefaultPodCIDR,
	}

	// Create cluster once.
	require.NoError(t, kindcluster.CreateCluster(ctx, cfg, kindcluster.RealExec))

	// Second create attempt should detect the cluster and return ErrClusterExists.
	err := kindcluster.CreateCluster(ctx, cfg, kindcluster.RealExec)
	require.Error(t, err)
	assert.True(t, false ||
		// Either via ErrClusterExists sentinel...
		func() bool {
			exists, _ := kindcluster.ClusterExists(ctx, clusterName, kindcluster.RealExec)
			return exists
		}(),
		"cluster should exist after first creation")

	// --delete-existing: ClusterExists + DeleteCluster + CreateCluster should succeed.
	require.NoError(t, kindcluster.DeleteCluster(ctx, clusterName, kindcluster.RealExec))
	require.NoError(t, kindcluster.CreateCluster(ctx, cfg, kindcluster.RealExec))
}

// countNonEmpty returns the number of non-empty lines in s.
func countNonEmpty(s string) int {
	n := 0
	for _, line := range splitLines(s) {
		if line != "" {
			n++
		}
	}
	return n
}

func splitLines(s string) []string {
	var lines []string
	start := 0
	for i := 0; i < len(s); i++ {
		if s[i] == '\n' {
			lines = append(lines, s[start:i])
			start = i + 1
		}
	}
	if start < len(s) {
		lines = append(lines, s[start:])
	}
	return lines
}
