package kindcluster

import (
	"bytes"
	"context"
	"errors"
	"fmt"
	"log/slog"
	"os"
	"strings"
)

// ErrClusterExists is returned when the target cluster already exists.
// Callers can use errors.Is to detect this and offer --delete-existing.
var ErrClusterExists = errors.New("cluster already exists")

// CreateCluster provisions a kind cluster according to cfg.
// exec is injected so unit tests can replace it with a mock.
func CreateCluster(ctx context.Context, cfg ClusterConfig, exec Executor) error {
	yaml := KindConfigYAML(cfg)

	f, err := os.CreateTemp("", "kind-config-*.yaml")
	if err != nil {
		return fmt.Errorf("creating temporary kind config: %w", err)
	}
	defer os.Remove(f.Name())

	if _, err := f.WriteString(yaml); err != nil {
		f.Close()
		return fmt.Errorf("writing kind config to %s: %w", f.Name(), err)
	}
	f.Close()

	slog.InfoContext(ctx, "creating kind cluster",
		"name", cfg.ClusterName,
		"control-planes", cfg.ControlPlanes,
		"workers", cfg.Workers,
		"pod-cidr", cfg.PodCIDR,
	)

	out, err := exec(ctx, "kind", "create", "cluster",
		"--name", cfg.ClusterName,
		"--config", f.Name(),
	)
	if err != nil {
		if bytes.Contains(out, []byte("already exist")) {
			return fmt.Errorf("%w: %q — use --delete-existing to recreate", ErrClusterExists, cfg.ClusterName)
		}
		return fmt.Errorf("kind create cluster: %w: %s", err, out)
	}

	slog.InfoContext(ctx, "kind cluster created", "name", cfg.ClusterName)
	return nil
}

// KindConfigYAML generates the kind cluster configuration YAML.
// Exported for testing so callers can assert on the generated document.
func KindConfigYAML(cfg ClusterConfig) string {
	var b strings.Builder
	b.WriteString("kind: Cluster\napiVersion: kind.x-k8s.io/v1alpha4\n")
	b.WriteString("networking:\n")
	fmt.Fprintf(&b, "  podSubnet: %q\n", cfg.PodCIDR)
	b.WriteString("nodes:\n")
	for range cfg.ControlPlanes {
		b.WriteString("- role: control-plane\n")
	}
	for range cfg.Workers {
		b.WriteString("- role: worker\n")
	}
	return b.String()
}
