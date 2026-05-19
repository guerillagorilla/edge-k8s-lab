# edge-k8s-lab

A hands-on lab for learning Kubernetes across a hub-spoke topology using
**OpenShift Local (CRC)** as the hub and **k3d** as a lightweight edge site.

## Repo layout

```
edge-k8s-lab/
├── charts/
│   └── edge-hello/         # multi-distro hello-world Helm chart
├── argocd/                 # ArgoCD Application manifests (Phase 2)
├── docs/                   # notes, diagrams, phase writeups
└── README.md
```

## Lab phases

| Phase | Goal |
|-------|------|
| 1 | Deploy edge-hello on CRC and k3d; understand per-distro differences (Routes vs Ingress, SCCs vs standard PSA) |
| 2 | GitOps with ArgoCD: hub manages edge site via ApplicationSet |
| 3 | Scheduler behaviour, resource limits, OOM, probe failures |
| 4 | Security hardening: read-only root fs, SCC tuning on OCP, PSA on k3d |

## Quick start

```bash
# OCP / CRC
helm upgrade --install edge-hello charts/edge-hello -f charts/edge-hello/values-ocp.yaml

# k3d
helm upgrade --install edge-hello charts/edge-hello -f charts/edge-hello/values-k3s.yaml
```

## Prerequisites

- [CRC](https://developers.redhat.com/products/openshift-local/overview) + a Red Hat pull secret
- [k3d](https://k3d.io) + kubectl
- Helm 3
