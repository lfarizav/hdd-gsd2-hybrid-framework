# Usage Guide

## Quick Start

```bash
# Default: 1 control-plane + 2 workers, cluster named "heritage"
./kind-cluster

# Custom topology
./kind-cluster --control-planes 3 --workers 3 --cluster-name my-cluster

# Air-gap deployment (pre-load images from a local directory)
./kind-cluster --images-dir /opt/heritage/images

# Delete and recreate an existing cluster
./kind-cluster --delete-existing

# Help
./kind-cluster --help
```

---

## Flags

| Flag | Default | Description |
|------|---------|-------------|
| `--control-planes` | `1` | Number of control-plane nodes (≥1) |
| `--workers` | `2` | Number of worker nodes (≥0) |
| `--cluster-name` | `heritage` | Kind cluster name (DNS-1123 label, max 63 chars) |
| `--images-dir` | `""` | Path to directory of `.tar` image archives. Overrides `IMAGES_DIR` env var |
| `--delete-existing` | `false` | Delete and recreate the cluster if it already exists |

---

## Environment Variables

| Variable | Description |
|----------|-------------|
| `IMAGES_DIR` | Path to pre-downloaded image archives (same as `--images-dir`). The flag wins if both are set. |
| `KUBECONFIG` | Path to kubeconfig file. Defaults to `$HOME/.kube/config`. |

---

## Provisioning Order

The binary performs these steps in sequence:

1. **Validate flags** — rejects invalid inputs before any side effects
2. **Validate air-gap images** — if `IMAGES_DIR` or `--images-dir` is set, confirms all required archives are present
3. **Check idempotency** — if cluster already exists, exits with an error (unless `--delete-existing`)
4. **Create kind cluster** — generates a kind config YAML with the specified topology and calls `kind create cluster`
5. **Load image archives** — injects each `.tar` archive into every cluster node via `kind load image-archive`
6. **Install Calico CNI** — applies Tigera Operator and custom-resources manifests; waits up to 5 minutes for `calico-system` pods

---

## Examples

### Minimal single-node cluster
```bash
./kind-cluster --control-planes 1 --workers 0 --cluster-name dev
```

### HA cluster with air-gap images
```bash
export IMAGES_DIR=/opt/heritage/images
./kind-cluster --control-planes 3 --workers 3 --cluster-name prod-ha
```

### Recreate after a failed run
```bash
./kind-cluster --delete-existing --cluster-name heritage
```

### Verify after provisioning
```bash
kubectl get nodes
kubectl get pods -n calico-system
```

---

## Pod CIDR

The default pod CIDR is `10.244.0.0/16`, which Calico uses by default when installed via Tigera Operator. This value is hardcoded in `internal/kindcluster/config.go` as `DefaultPodCIDR` and is not currently configurable via flag (reserved for a future enhancement).
