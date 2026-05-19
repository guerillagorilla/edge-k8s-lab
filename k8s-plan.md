# K8s Edge Learning Plan

Five phases, roughly 2–3 weeks each. All phases build on the same lab topology — you're not rebuilding, you're adding depth.

**Targets:** `OCP/CRC` · `k3d` · `MicroShift`

---

## Phase 1 — Lab Foundation + Distribution Survey `~2 weeks`

Stand up all three distributions. Deploy the same hello-world Helm chart to each. The goal is to see the topology alive and understand how the three distributions differ before adding GitOps.

```
CRC (OCP)          ← deploy manually with oc
k3d edge-site-1    ← deploy manually with kubectl
UTM/RHEL VM        ← MicroShift, deploy with kubectl
```

- [ ] **Install and validate all three distributions** `all`
  - `crc start`, `k3d cluster create`, MicroShift RPM on RHEL 9 in UTM VM
- [ ] **Write a simple Helm chart (nginx + ConfigMap)** `all`
  - Deployment, Service, Ingress/Route — parameterized by target type
- [ ] **Create GitHub repo with chart + values files per target** `all`
  - `values-ocp.yaml`, `values-k3s.yaml`, `values-microshift.yaml`
- [ ] **Compare how ingress/routing works across all three** `OCP` `k3d` `MicroShift`
  - OCP Route vs Traefik Ingress vs MicroShift router — hit each endpoint
- [ ] **Get comfortable with `oc` vs `kubectl` differences** `OCP`
  - Projects vs namespaces, `oc new-app`, image streams, `oc status`

---

## Phase 2 — GitOps with ArgoCD `~2 weeks`

Install ArgoCD in CRC via OperatorHub. Register k3d and MicroShift as remote targets. Drive all deployments from Git — no more manual `kubectl apply`.

```
GitHub repo (Helm charts)
        ↓
ArgoCD in CRC  ← the hub
├──▶ k3d edge-site-1
└──▶ MicroShift VM
```

- [ ] **Install OpenShift GitOps via OperatorHub** `OCP`
  - Learn the OLM operator install flow — this is how OCP teams do everything
- [ ] **Register k3d and MicroShift clusters in ArgoCD** `k3d` `MicroShift`
  - `argocd cluster add` — understand kubeconfig merging and contexts
- [ ] **Deploy the Helm chart to all three targets via ArgoCD Applications** `all`
  - One Application per target, each pointing to its values file
- [ ] **Practice the full GitOps loop** `all`
  - Push a change → watch ArgoCD detect drift → sync → verify rollout
- [ ] **Trigger a rollback via ArgoCD** `all`
  - Revert a commit, force sync, confirm previous version restored

---

## Phase 3 — Storage, Stateful Workloads, and Debugging `~2-3 weeks`

The deepest phase technically — and where the JD puts heavy weight. Deploy stateful workloads, then deliberately break and recover them. CSI behavior and PV lifecycle are core operator skills.

- [ ] **Deploy Postgres with a PVC via Helm** `OCP` `k3d`
  - k3d uses local-path provisioner; OCP has its own storage class — compare behavior
- [ ] **Deliberately break PVC binding and recover** `all`
  - Delete a PV, orphan a PVC, understand `Terminating` stuck states and finalizers
- [ ] **Set resource limits and observe scheduler behavior** `all`
  - `requests` vs `limits`, OOMKilled pods, Pending due to insufficient resources
- [ ] **Add liveness and readiness probes, then break them** `all`
  - Understand CrashLoopBackOff, probe failure cascades, and restart policies
- [ ] **Explore logs: kubectl/oc logs, previous container logs, events** `all`
  - `kubectl get events --sort-by=.lastTimestamp` is your best debugging friend

---

## Phase 4 — Security Hardening and SCCs `~1-2 weeks`

OCP's Security Context Constraints are one of the biggest sources of friction when moving workloads from vanilla k8s to OpenShift. This phase is about understanding why things fail and how to fix them properly.

- [ ] **Run a pod that fails SCC and debug it** `OCP`
  - Deploy an image that runs as root — watch it fail, read the SCC error, fix it
- [ ] **Apply Pod Security Admission in k3d (restricted mode)** `k3d`
  - Closest k3s analog to SCCs — label a namespace and watch enforcement
- [ ] **Configure non-root, read-only filesystem containers** `all`
  - `runAsNonRoot`, `readOnlyRootFilesystem`, `drop: [ALL]` capabilities
- [ ] **TLS and cert management** `OCP` `k3d`
  - cert-manager in k3d; OCP's built-in service CA; understand certificate rotation

---

## Phase 5 — Air-Gap Simulation and Multi-Arch `~2 weeks`

Most candidates skip this entirely, which makes it a real differentiator. Simulating air-gapped operations and multi-arch image handling maps directly to edge deployments in constrained environments.

- [ ] **Stand up a local Harbor or plain Docker registry** `k3d` `MicroShift`
  - Mirror your workload images to it; configure `imagePullSecrets`
- [ ] **Simulate air-gap: block external registry access, run ArgoCD sync** `k3d`
  - Use k3d `--no-lb` or network policy to block external pulls — see what breaks
- [ ] **Build and push a multi-arch image (amd64 + arm64)** `all`
  - `docker buildx`, manifest lists — understand how edge nodes pull the right arch
- [ ] **Pre-pull and bundle images for offline deployment** `MicroShift`
  - `docker save` / `load` workflow; understand how MicroShift handles disconnected installs
