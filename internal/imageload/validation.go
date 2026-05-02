package imageload

import (
	"context"
	"fmt"
	"os"
	"path/filepath"
)

// RequiredImageFiles lists the tar archives expected in the images directory.
// These correspond to the images needed before any workload can run in an
// air-gap cluster. Update this list whenever a new required image is added
// (ADR-002: no :latest tags; all images must be pre-loaded).
var RequiredImageFiles = []string{
	"calico-node.tar",
	"calico-cni.tar",
	"calico-kube-controllers.tar",
}

// ValidateAirGap checks that imagesDir (or IMAGES_DIR env var) exists, is
// readable, and contains all required image archives.
func ValidateAirGap(_ context.Context, imagesDir string) error {
	dir := imagesDir
	if dir == "" {
		dir = os.Getenv("IMAGES_DIR")
	}
	if dir == "" {
		return fmt.Errorf("images directory not specified: set --images-dir flag or IMAGES_DIR environment variable")
	}

	info, err := os.Stat(dir)
	if err != nil {
		return fmt.Errorf("images directory %q: %w", dir, err)
	}
	if !info.IsDir() {
		return fmt.Errorf("%q is not a directory", dir)
	}

	for _, required := range RequiredImageFiles {
		path := filepath.Join(dir, required)
		if _, err := os.Stat(path); err != nil {
			return fmt.Errorf("required image archive %q not found in %q: %w", required, dir, err)
		}
	}

	return nil
}
