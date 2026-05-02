package kindcluster

import (
	"context"
	"fmt"
	"strings"
)

// ClusterExists reports whether a kind cluster with the given name is already
// running. It calls `kind get clusters` and scans the output for an exact
// name match.
func ClusterExists(ctx context.Context, clusterName string, exec Executor) (bool, error) {
	out, err := exec(ctx, "kind", "get", "clusters")
	if err != nil {
		return false, fmt.Errorf("kind get clusters: %w: %s", err, out)
	}
	for _, line := range strings.Split(strings.TrimSpace(string(out)), "\n") {
		if strings.TrimSpace(line) == clusterName {
			return true, nil
		}
	}
	return false, nil
}

// DeleteCluster removes the named kind cluster.
func DeleteCluster(ctx context.Context, clusterName string, exec Executor) error {
	out, err := exec(ctx, "kind", "delete", "cluster", "--name", clusterName)
	if err != nil {
		return fmt.Errorf("kind delete cluster %q: %w: %s", clusterName, err, out)
	}
	return nil
}
