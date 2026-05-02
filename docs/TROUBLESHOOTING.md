# Troubleshooting

## Error: `kind not found` or `exec: no such file or directory: kind`

**Cause:** The `kind` binary is not installed or not in `$PATH`.

**Fix:**
```bash
# Verify:
which kind || echo "kind not found"

# Install kind v0.31.0 (Linux amd64):
curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.31.0/kind-linux-amd64
chmod +x ./kind && sudo mv ./kind /usr/local/bin/kind
kind version
```

---

## Error: `cluster "heritage" already exists — run with --delete-existing to recreate`

**Cause:** A kind cluster with the same name already exists from a previous run.

**Fix:**
```bash
# Option A: delete manually
kind delete cluster --name heritage

# Option B: use the flag
./kind-cluster --delete-existing
```

---

## Error: `air-gap validation failed: required image archive "calico-node.tar" not found`

**Cause:** `IMAGES_DIR` is set but the required `.tar` archives are missing.

**Fix:**
```bash
# Check what's in your images directory
ls -lh "$IMAGES_DIR"

# Pull and save the missing image:
docker pull calico/node:v3.32.0
docker save calico/node:v3.32.0 -o "$IMAGES_DIR/calico-node.tar"
```

Required archives: `calico-node.tar`, `calico-cni.tar`, `calico-kube-controllers.tar`.

---

## Error: `kubectl not found or not executable`

**Cause:** `kubectl` is not installed or not in `$PATH`.

**Fix:**
```bash
# Linux:
curl -LO "https://dl.k8s.io/release/$(curl -Ls https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
chmod +x kubectl && sudo mv kubectl /usr/local/bin/
kubectl version --client
```

---

## Error: `Calico pods not ready within 5m0s`

**Cause:** Calico CNI pods in `calico-system` did not reach `Ready` state within the timeout.

**Diagnose:**
```bash
kubectl get pods -n calico-system
kubectl describe pod -n calico-system <pod-name>
kubectl logs -n calico-system <pod-name>
```

**Common causes:**
- Docker not running or out of resources
- Network bridge conflicts (another cluster using overlapping CIDR)
- Image pull failure in an air-gap environment (check `imagePullPolicy: IfNotPresent` is set)

---

## Error: `kubeconfig "/home/user/.kube/config": no such file or directory`

**Cause:** kind creates or merges the kubeconfig after cluster creation; if this path doesn't exist, kind may not have written it yet.

**Fix:**
```bash
mkdir -p ~/.kube
kind export kubeconfig --name heritage
kubectl get nodes
```

---

## General debugging

```bash
# Show all kind clusters
kind get clusters

# Stream kind cluster logs
kind export logs --name heritage /tmp/kind-logs
ls /tmp/kind-logs

# Reset everything
kind delete cluster --name heritage
docker system prune -f
```
