// Package kindcluster provides types and constants for provisioning kind clusters.
package kindcluster

import "time"

// Cluster defaults — all values live here so main.go has no hardcoded strings.
const (
	DefaultClusterName   = "heritage"
	DefaultControlPlanes = 1
	DefaultWorkers       = 2
	DefaultPodCIDR       = "10.244.0.0/16"

	// CalicoVersion is pinned per ADR-002 research: v3.32.0 verified against
	// kind v0.31.0. Update here (and regenerate manifests) before bumping.
	CalicoVersion = "v3.32.0"

	calicoBase         = "https://raw.githubusercontent.com/projectcalico/calico/" + CalicoVersion + "/manifests"
	CalicoOperatorURL  = calicoBase + "/tigera-operator.yaml"
	CalicoResourcesURL = calicoBase + "/custom-resources.yaml"
	CalicoNamespace    = "calico-system"

	DefaultWaitTimeout = 5 * time.Minute

	maxClusterNameLen = 63
)

// ClusterConfig holds all parameters required to provision a kind cluster.
type ClusterConfig struct {
	ClusterName    string
	ControlPlanes  int
	Workers        int
	PodCIDR        string
	KubeConfig     string
	ImagesDir      string // optional; directory of .tar image archives for air-gap deployments
	DeleteExisting bool   // if true, delete and recreate an existing cluster
}
