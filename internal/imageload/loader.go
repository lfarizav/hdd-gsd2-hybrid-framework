// Package imageload implements image archive loading for air-gap kind clusters.
// All images must be pre-loaded into cluster nodes before any workload runs,
// because air-gap deployments have no internet access (ADR-002).
package imageload

import (
	"archive/tar"
	"compress/gzip"
	"context"
	"fmt"
	"io"
	"log/slog"
	"os"
	"path/filepath"
	"strings"

	"github.com/lfarizav/heritage/internal/kindcluster"
)

// LoadImagesFromArchive injects a Docker image tar.gz archive into all nodes
// of the named kind cluster using `kind load image-archive`.
//
// The operation is idempotent: kind skips images already present on nodes.
func LoadImagesFromArchive(ctx context.Context, archivePath string, clusterName string, exec kindcluster.Executor) error {
	if err := validateArchive(archivePath); err != nil {
		return fmt.Errorf("validating archive %q: %w", archivePath, err)
	}

	slog.InfoContext(ctx, "loading image archive into cluster",
		"archive", archivePath,
		"cluster", clusterName,
	)

	out, err := exec(ctx, "kind", "load", "image-archive", archivePath, "--name", clusterName)
	if err != nil {
		return fmt.Errorf("kind load image-archive: %w: %s", err, out)
	}

	slog.InfoContext(ctx, "image archive loaded successfully",
		"archive", archivePath,
		"cluster", clusterName,
	)
	return nil
}

// validateArchive checks that archivePath exists, is readable, and contains a
// valid tar (or gzipped tar) stream.
func validateArchive(archivePath string) error {
	info, err := os.Stat(archivePath)
	if err != nil {
		return fmt.Errorf("archive not found: %w", err)
	}
	if info.IsDir() {
		return fmt.Errorf("%q is a directory, expected a .tar or .tar.gz file", archivePath)
	}

	f, err := os.Open(archivePath)
	if err != nil {
		return fmt.Errorf("cannot open archive: %w", err)
	}
	defer f.Close()

	return validateTarReader(f)
}

// validateTarReader attempts to read the first entry of a tar or gzipped-tar
// stream. An error here means the file is corrupt or not a tar archive.
func validateTarReader(r io.Reader) error {
	// Try gzip-wrapped tar first.
	gz, err := gzip.NewReader(r)
	if err == nil {
		tr := tar.NewReader(gz)
		if _, err := tr.Next(); err != nil && err != io.EOF {
			return fmt.Errorf("invalid gzipped tar content: %w", err)
		}
		return nil
	}

	// Fall back to plain tar (seek back to start if possible, else fail).
	if s, ok := r.(io.Seeker); ok {
		if _, err := s.Seek(0, io.SeekStart); err != nil {
			return fmt.Errorf("cannot seek archive: %w", err)
		}
		tr := tar.NewReader(r)
		if _, err := tr.Next(); err != nil && err != io.EOF {
			return fmt.Errorf("invalid tar content: %w", err)
		}
		return nil
	}

	return fmt.Errorf("archive is neither a valid .tar nor .tar.gz file")
}

// ListArchives returns the paths of all .tar and .tar.gz files in dir.
func ListArchives(dir string) ([]string, error) {
	entries, err := os.ReadDir(dir)
	if err != nil {
		return nil, fmt.Errorf("reading images directory %q: %w", dir, err)
	}

	var archives []string
	for _, e := range entries {
		if e.IsDir() {
			continue
		}
		name := e.Name()
		if strings.HasSuffix(name, ".tar") || strings.HasSuffix(name, ".tar.gz") {
			archives = append(archives, filepath.Join(dir, name))
		}
	}
	return archives, nil
}
