package main

import (
	"context"
	"fmt"
	"os"

	"github.com/lfarizav/heritage/internal/imageload"
	"github.com/lfarizav/heritage/internal/kindcluster"
)

// run is the testable entry point. main() delegates to it so tests can call
// run without triggering os.Exit.
func run(args []string) error {
	cfg, err := kindcluster.ParseFlags(args)
	if err != nil {
		return err
	}

	// Resolve images directory: flag wins over env var.
	imagesDir := cfg.ImagesDir
	if imagesDir == "" {
		imagesDir = os.Getenv("IMAGES_DIR")
	}

	ctx := context.Background()

	// Pre-flight: validate air-gap images directory before touching the cluster.
	if imagesDir != "" {
		if err := imageload.ValidateAirGap(ctx, imagesDir); err != nil {
			return fmt.Errorf("air-gap validation failed: %w", err)
		}
	}

	// Idempotency: check if cluster already exists before any state changes.
	exists, err := kindcluster.ClusterExists(ctx, cfg.ClusterName, kindcluster.RealExec)
	if err != nil {
		return fmt.Errorf("checking cluster existence: %w", err)
	}
	if exists {
		if !cfg.DeleteExisting {
			return fmt.Errorf("cluster %q already exists — run with --delete-existing to recreate", cfg.ClusterName)
		}
		if err := kindcluster.DeleteCluster(ctx, cfg.ClusterName, kindcluster.RealExec); err != nil {
			return fmt.Errorf("deleting existing cluster: %w", err)
		}
	}

	if err := kindcluster.CreateCluster(ctx, cfg, kindcluster.RealExec); err != nil {
		return fmt.Errorf("creating cluster: %w", err)
	}

	// Load images after cluster creation, before Calico install.
	if imagesDir != "" {
		archives, err := imageload.ListArchives(imagesDir)
		if err != nil {
			kindcluster.RealExec(ctx, "kind", "delete", "cluster", "--name", cfg.ClusterName) //nolint:errcheck
			return fmt.Errorf("listing image archives: %w", err)
		}
		for _, archive := range archives {
			if err := imageload.LoadImagesFromArchive(ctx, archive, cfg.ClusterName, kindcluster.RealExec); err != nil {
				kindcluster.RealExec(ctx, "kind", "delete", "cluster", "--name", cfg.ClusterName) //nolint:errcheck
				return fmt.Errorf("loading images: %w", err)
			}
		}
	}

	// Resolve kubeconfig: prefer KUBECONFIG env, fall back to default path.
	kubeconfig := fmt.Sprintf("%s/.kube/config", os.Getenv("HOME"))
	if kc := os.Getenv("KUBECONFIG"); kc != "" {
		kubeconfig = kc
	}

	if err := kindcluster.InstallCalicoNS(ctx, kubeconfig, cfg.ClusterName, kindcluster.RealExec); err != nil {
		return fmt.Errorf("installing Calico CNI: %w", err)
	}

	return nil
}

func main() {
	if err := run(os.Args[1:]); err != nil {
		fmt.Fprintf(os.Stderr, "error: %v\n", err)
		os.Exit(1)
	}
}
