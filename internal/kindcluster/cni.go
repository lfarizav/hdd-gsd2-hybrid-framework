package kindcluster

import (
	"context"
	"fmt"
	"log/slog"
	"os"
)

// InstallCalicoNS installs Calico CNI into the named cluster using the Tigera
// Operator approach (two manifest apply steps) and waits for all pods in the
// calico-system namespace to become Ready.
//
// exec is injected so unit tests can replace kubectl calls with a mock.
func InstallCalicoNS(ctx context.Context, kubeconfig string, clusterName string, exec Executor) error {
	// Validate kubectl is available before touching any cluster state.
	if _, err := exec(ctx, "kubectl", "version", "--client", "--output=json"); err != nil {
		return fmt.Errorf("kubectl not found or not executable: %w", err)
	}

	// Validate the kubeconfig exists before proceeding.
	if _, err := os.Stat(kubeconfig); err != nil {
		return fmt.Errorf("kubeconfig %q: %w", kubeconfig, err)
	}

	slog.InfoContext(ctx, "installing Calico CNI",
		"version", CalicoVersion,
		"cluster", clusterName,
		"operator-url", CalicoOperatorURL,
	)

	// Step 1: Install the Tigera Operator.
	if out, err := exec(ctx, "kubectl",
		"--kubeconfig", kubeconfig,
		"create", "-f", CalicoOperatorURL,
	); err != nil {
		return fmt.Errorf("applying Calico operator manifest: %w: %s", err, out)
	}

	// Step 2: Apply Calico custom resources (triggers pod deployment).
	if out, err := exec(ctx, "kubectl",
		"--kubeconfig", kubeconfig,
		"create", "-f", CalicoResourcesURL,
	); err != nil {
		return fmt.Errorf("applying Calico custom resources: %w: %s", err, out)
	}

	// Wait for calico-system pods to become Ready.
	slog.InfoContext(ctx, "waiting for Calico pods",
		"namespace", CalicoNamespace,
		"timeout", DefaultWaitTimeout,
	)

	if out, err := exec(ctx, "kubectl",
		"--kubeconfig", kubeconfig,
		"wait", "--for=condition=Ready", "pod", "--all",
		"--namespace", CalicoNamespace,
		"--timeout", DefaultWaitTimeout.String(),
	); err != nil {
		return fmt.Errorf("Calico pods not ready within %s: %w: %s", DefaultWaitTimeout, err, out)
	}

	slog.InfoContext(ctx, "Calico CNI installed and ready", "cluster", clusterName)
	return nil
}
