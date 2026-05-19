# edge-hello

Learning chart for a three-distribution edge topology:
CRC (OCP) as the GitOps hub, k3d and MicroShift as spokes.

## Structure

```
edge-hello/
├── Chart.yaml
├── values.yaml                 # defaults
├── values-ocp.yaml             # CRC / OpenShift overrides
├── values-k3s.yaml             # k3d overrides
├── values-microshift.yaml      # MicroShift overrides
└── templates/
    ├── _helpers.tpl
    ├── configmap.yaml          # nginx config + hello-world HTML
    ├── deployment.yaml
    ├── service.yaml
    ├── ingress.yaml            # k3s + MicroShift
    ├── route.yaml              # OCP only (route.openshift.io/v1)
    └── pvc.yaml                # disabled by default; enable in Phase 3
```

## Quick start — manual deploy (Phase 1)

```bash
# OCP / CRC
oc login -u kubeadmin https://api.crc.testing:6443
oc new-project edge-hello
helm upgrade --install edge-hello . -f values-ocp.yaml -n edge-hello
oc get route -n edge-hello   # get the auto-assigned URL

# k3d
kubectl config use-context k3d-edge-site-1
kubectl create namespace edge-hello
helm upgrade --install edge-hello . -f values-k3s.yaml -n edge-hello
# Add edge-hello.local to /etc/hosts pointing to 127.0.0.1
# curl http://edge-hello.local

# MicroShift
kubectl config use-context microshift-edge-1
kubectl create namespace edge-hello
helm upgrade --install edge-hello . -f values-microshift.yaml -n edge-hello
```

## Lint before applying

```bash
helm lint . -f values-ocp.yaml
helm lint . -f values-k3s.yaml
helm lint . -f values-microshift.yaml
```

## Render templates without applying (dry run)

```bash
helm template edge-hello . -f values-ocp.yaml | less
```

## Phase 3 — enable persistence

```bash
helm upgrade edge-hello . -f values-k3s.yaml \
  --set persistence.enabled=true \
  --set persistence.size=1Gi \
  -n edge-hello
```

## Phase 4 — enable read-only root filesystem

```bash
helm upgrade edge-hello . -f values-k3s.yaml \
  --set securityContext.readOnlyRootFilesystem=true \
  -n edge-hello
# nginx writes to /tmp and /var/run — both mounted as emptyDir already.
```
