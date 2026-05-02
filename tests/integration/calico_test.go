//go:build integration

package integration_test

import (
	"context"
	"os"
	"os/exec"
	"testing"

	"github.com/lfarizav/heritage/internal/kindcluster"
	"github.com/stretchr/testify/require"
)

// TestCalicoInstall provisions a real kind cluster and installs Calico CNI.
// Requires: docker, kind, kubectl available in PATH.
// Run with: go test -tags=integration ./tests/integration -run TestCalicoInstall -v
func TestCalicoInstall(t *testing.T) {
	for _, tool := range []string{"docker", "kind", "kubectl"} {
		if _, err := exec.LookPath(tool); err != nil {
			t.Skipf("%s not found in PATH — skipping integration test", tool)
		}
	}

	clusterName := "calico-test-ci"
	cfg := kindcluster.ClusterConfig{
		ClusterName:   clusterName,
		ControlPlanes: 1,
		Workers:       1,
		PodCIDR:       kindcluster.DefaultPodCIDR,
	}

	ctx := context.Background()

	// Provision cluster.
	t.Log("Creating kind cluster...")
	require.NoError(t, kindcluster.CreateCluster(ctx, cfg, kindcluster.RealExec))

	t.Cleanup(func() {
		// Always delete the test cluster, even if assertions fail.
		kindcluster.RealExec(ctx, "kind", "delete", "cluster", "--name", clusterName) //nolint:errcheck
	})

	// Resolve kubeconfig.
	kubeconfig := os.Getenv("KUBECONFIG")
	if kubeconfig == "" {
		home, err := os.UserHomeDir()
		require.NoError(t, err)
		kubeconfig = home + "/.kube/config"
	}

	// Install Calico.
	t.Log("Installing Calico CNI...")
	err := kindcluster.InstallCalicoNS(ctx, kubeconfig, clusterName, kindcluster.RealExec)
	require.NoError(t, err)
}
