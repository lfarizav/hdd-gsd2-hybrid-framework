package kindcluster

import (
	"flag"
	"fmt"
	"regexp"
)

// dns1123Re validates a DNS-1123 label: lowercase alphanumerics and hyphens,
// must start and end with an alphanumeric, max 63 characters.
var dns1123Re = regexp.MustCompile(`^[a-z0-9]([a-z0-9-]{0,61}[a-z0-9])?$|^[a-z0-9]$`)

// ParseFlags parses CLI arguments and returns a populated ClusterConfig.
// Exported so tests can call it without going through os.Exit.
func ParseFlags(args []string) (ClusterConfig, error) {
	fs := flag.NewFlagSet("kind-cluster", flag.ContinueOnError)

	controlPlanes := fs.Int("control-planes", DefaultControlPlanes, "number of control-plane nodes (≥1)")
	workers := fs.Int("workers", DefaultWorkers, "number of worker nodes (≥0)")
	clusterName := fs.String("cluster-name", DefaultClusterName, "kind cluster name (DNS-1123 label, max 63 chars)")
	imagesDir := fs.String("images-dir", "", "directory containing .tar image archives (overrides IMAGES_DIR env var)")
	deleteExisting := fs.Bool("delete-existing", false, "delete and recreate the cluster if it already exists")

	if err := fs.Parse(args); err != nil {
		return ClusterConfig{}, err
	}

	if *controlPlanes < 1 {
		return ClusterConfig{}, fmt.Errorf("--control-planes must be ≥ 1, got %d", *controlPlanes)
	}
	if *workers < 0 {
		return ClusterConfig{}, fmt.Errorf("--workers must be ≥ 0, got %d", *workers)
	}
	if err := ValidateClusterName(*clusterName); err != nil {
		return ClusterConfig{}, err
	}

	return ClusterConfig{
		ClusterName:    *clusterName,
		ControlPlanes:  *controlPlanes,
		Workers:        *workers,
		PodCIDR:        DefaultPodCIDR,
		ImagesDir:      *imagesDir,
		DeleteExisting: *deleteExisting,
	}, nil
}

// ValidateClusterName returns an error if name is not a valid DNS-1123 label.
func ValidateClusterName(name string) error {
	if name == "" {
		return fmt.Errorf("--cluster-name must not be empty")
	}
	if len(name) > maxClusterNameLen {
		return fmt.Errorf("--cluster-name must be ≤ %d characters, got %d", maxClusterNameLen, len(name))
	}
	if !dns1123Re.MatchString(name) {
		return fmt.Errorf("--cluster-name %q is not DNS-1123 compliant: must match lowercase alphanumerics and hyphens", name)
	}
	return nil
}
