# Installation Guide

This guide covers installing the prerequisites for `kind-cluster`: Docker, kind, and kubectl.

---

## Prerequisites

| Tool | Minimum Version | Purpose |
|------|----------------|---------|
| Docker | 24.0+ | Runs kind node containers |
| kind | v0.31.0 | Creates and manages local Kubernetes clusters |
| kubectl | v1.28+ | Applies manifests; waits for pod readiness |
| Go | 1.22+ | Builds the `kind-cluster` binary |

---

## Docker

Follow the official Docker Engine installation guide for your OS:
- **Linux (Ubuntu/Debian):** https://docs.docker.com/engine/install/ubuntu/
- **macOS:** Install Docker Desktop from https://docs.docker.com/desktop/mac/

Verify: `docker version`

---

## kind

kind (Kubernetes IN Docker) v0.31.0 is the tested version for this project.

```bash
# Linux/macOS (amd64)
curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.31.0/kind-linux-amd64
chmod +x ./kind
sudo mv ./kind /usr/local/bin/kind

# macOS (Apple Silicon)
curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.31.0/kind-darwin-arm64
chmod +x ./kind
sudo mv ./kind /usr/local/bin/kind
```

Verify: `kind version`

Reference: https://kind.sigs.k8s.io/docs/user/quick-start/#installation

---

## kubectl

```bash
# Linux (amd64)
curl -LO "https://dl.k8s.io/release/$(curl -Ls https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
chmod +x kubectl
sudo mv kubectl /usr/local/bin/kubectl

# macOS
brew install kubectl
```

Verify: `kubectl version --client`

Reference: https://kubernetes.io/docs/tasks/tools/

---

## Build the kind-cluster binary

```bash
git clone https://github.com/lfarizav/heritage.git
cd heritage
go build -o kind-cluster ./cmd/kind-cluster
./kind-cluster --help
```

---

## Air-gap image archives

For air-gap deployments, pre-download the required Calico images as `.tar` archives and place them in a directory:

```bash
mkdir -p /opt/heritage/images

# Pull and save each required image
docker pull calico/node:v3.32.0
docker save calico/node:v3.32.0 -o /opt/heritage/images/calico-node.tar

docker pull calico/cni:v3.32.0
docker save calico/cni:v3.32.0 -o /opt/heritage/images/calico-cni.tar

docker pull calico/kube-controllers:v3.32.0
docker save calico/kube-controllers:v3.32.0 -o /opt/heritage/images/calico-kube-controllers.tar
```

Then set the `IMAGES_DIR` environment variable or use the `--images-dir` flag when running the binary.
