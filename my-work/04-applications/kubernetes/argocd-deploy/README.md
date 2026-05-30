# 🚀 ArgoCD-Based Deployment on K8s

This project demonstrates a production-style GitOps workflow using ArgoCD and Kubernetes, focused on multi-environment deployments, secret management, persistent storage, and real-world deployment orchestration challenges.

## 📑 Table of Contents

**🧭 Navigation:**

- [Implementation Roadmap](#️-implementation-roadmap)
- [Project Navigation](#-project-navigation)

**📘 Project Documentation:**

- [Overview](#-overview)
- [Repository Architecture](#️-repository-architecture)
- [Deployment Guide](#-deployment-guide)
- [What this Project Demonstrates](#-what-this-project-demonstrates)
- [Core Implementation](#️-core-implementation)
- [Challenges & Solutions](#️-challenges--solutions)
- [Operational Outcomes](#-operational-outcomes)
- [Key Learnings](#-key-learnings)
- [Conclusion](#-conclusion)
- [Next Phase](#-next-phase)

## 🗺️ Implementation Roadmap

<p align="left">
  <img src="./8-ArgoCD.jpg" width="80%"/>
</p>

## 🔗 Project Navigation

- [Root Directory](https://github.com/sonuparit/retail-store-reverse-engineered)

### 📖 Understanding Phase

- [Source Code Understanding](https://github.com/sonuparit/retail-store-reverse-engineered/tree/main/src-code)
- [Architecture Understanding](https://github.com/sonuparit/retail-store-reverse-engineered/tree/main/my-work/04-applications/architecture)
- [Containerization (Docker)](https://github.com/sonuparit/retail-store-reverse-engineered/tree/main/my-work/04-applications/docker)
- [Docker Compose Orchestration](https://github.com/sonuparit/retail-store-reverse-engineered/tree/main/my-work/04-applications/docker-compose)

### ☸️ Kubernetes Implementation Phase

- [Individual Service Testing](https://github.com/sonuparit/retail-store-reverse-engineered/tree/main/my-work/04-applications/kubernetes/ind-svc-test)
  - [Carts](https://github.com/sonuparit/retail-store-reverse-engineered/tree/main/my-work/04-applications/kubernetes/ind-svc-test/cart-dynamodb-test)
  - [Catalog](https://github.com/sonuparit/retail-store-reverse-engineered/tree/main/my-work/04-applications/kubernetes/ind-svc-test/catalog-test)
  - [Checkout](https://github.com/sonuparit/retail-store-reverse-engineered/tree/main/my-work/04-applications/kubernetes/ind-svc-test/checkout-test)
  - [Orders](https://github.com/sonuparit/retail-store-reverse-engineered/tree/main/my-work/04-applications/kubernetes/ind-svc-test/orders-postgreSQL-test)
  - [UI](https://github.com/sonuparit/retail-store-reverse-engineered/tree/main/my-work/04-applications/kubernetes/ind-svc-test/ui-test)
- [Helm Templating](https://github.com/sonuparit/retail-store-reverse-engineered/tree/main/my-work/04-applications/kubernetes/helm-template)
- [Full App Deployment via Helmfile](https://github.com/sonuparit/retail-store-reverse-engineered/tree/main/my-work/04-applications/kubernetes/helmfile-deploy)
- [Multi-Environment GitOps via ArgoCD](https://github.com/sonuparit/retail-store-reverse-engineered/tree/main/my-work/04-applications/kubernetes/argocd-deploy) ← (📍 You are here )

### 📊 Production & Observability

- [Monitoring & Observability](https://github.com/sonuparit/retail-store-reverse-engineered/tree/main/my-work/03-observability)
- [Production-Grade GitOps Workflow](https://github.com/sonuparit/retail-store-reverse-engineered/tree/main/my-work)

## 📖 Overview

This project implements a production-oriented GitOps workflow using ArgoCD and Kubernetes with support for:

- Multi-environment deployments (`dev`, `stage`, `prod`)
- Secret management using External Secrets Operator
- Persistent PostgreSQL storage
- Helm-based application templating
- Deployment dependency orchestration
- Reconciliation-aware Kubernetes workflows

The setup uses:

- **ArgoCD** for GitOps-based continuous delivery
- **Helm** for reusable application templating
- **Kustomize** for platform orchestration
- **External Secrets Operator** with AWS Secrets Manager
- **kind cluster running on EC2**
- **EBS-backed persistent storage** for stateful workloads

The primary goal was to understand how GitOps and Kubernetes systems behave under real operational conditions instead of only deploying sample applications.

## 🏗️ Repository Architecture

> [!NOTE]
> The repository structure evolved significantly after introducing the observability layer and platform-wide operational components.

The earlier implementation details are preserved below to document the architectural evolution of the platform and the transition toward a more production-oriented operational design.

<details>
<summary>📂 Earlier Repository Architecture (Pre-Observability Refactor)
</Summary>

> [!NOTE]
> This structure reflects the repository organization before the observability and platform-layer refactor.

| Directory | Purpose |
|---|---|
| `kind-cluster/` | Contains kind cluster configuration with volume mounts and ArgoCD installation values |
| `platform/` | Holds platform-level infrastructure components such as External Secrets Operator, ClusterSecretStore, and Kustomize orchestration |
| `argocd-project/` | Defines ArgoCD Projects and root applications responsible for managing GitOps deployment boundaries and sync behavior |
| `envs/` | Stores environment-specific Helm values for `dev`, `stage`, and `prod` deployments |
| `apps/` | Contains ArgoCD ApplicationSet definitions and Helm charts for deploying application workloads |
| `screenshots/` | Includes deployment screenshots, sync visuals used for documentation |

```bash
repo*
├── README.md
├── kind-cluster/
│   ├── argocd-install-values.yaml
│   ├── kind-config.yml
│   ├── steps to install argocd.txt
│   └── values/
│
├── platform/
│   ├── cluster-secret-store.yaml
│   ├── external-secrets-app.yaml
│   └── kustomization.yaml
│
├── argocd-project/
│   ├── argocd-project.yml
│   └── platform.yml
│
├── envs/
│   ├── dev/
│   ├── prod/
│   └── stage/
│
├── apps/
│   ├── application-set.yml
│   └── charts/
│
└── screenshots/
```

</details>

## 📦 Deployment Guide

### Latest Deployment Guide → [(follow here)](../../../)

<details>
<summary>📦 Earlier Deployment Workflow  (Pre-Observability Refactor)
</Summary>

> [!NOTE]
> This deployment workflow reflects the earlier repository architecture before the platform and observability restructuring.

This section demonstrates deployment of the complete multi-environment GitOps setup on a kind cluster running on EC2.

### Prerequisites

**Infra:**

1. ***`EC2 instance`** (recommended flex.large for multi env)*

    ![alt text](screenshots/screenshot50.png)

2. ***`EBS volume`** attached to EC2 and mounted for orders service*

    ![alt text](screenshots/screenshot17.png)

3. ***`Dynamodb`** for carts service with:*

    ```bash
    table: Item   |  index: idx_global_cutomerId
       id: id     |    key: customerId
    ```

    ![alt text](screenshots/screenshot33.png)

4. ***`AWS Sercrets Manager`** with secrets configured:*

    ![alt text](screenshots/screenshot04.png)

5. ***`IAM role for EC2`** with permissions:*

    ![alt text](screenshots/screenshot30.png)

    - dynamodb read and write access
    - secrets manager read access

6. ***`Metadata response hop limit`** for EC2 set to: `3`*

    ![alt text](screenshots/screenshot32.png)

**Tools:**

1. Docker installed and running
2. kubectl
3. helm
4. Kind

**Steps:**

1. Clone the repo and get into `argocd-deploy`

    ```bash
    git clone https://github.com/sonuparit/retail-store-reverse-engineered.git

    cd /retail-store-reverse-engineered/my-work/kubernetes/argocd-deploy/
    ```

    ![alt text](screenshots/screenshot52.png)

2. Create KinD Cluster with these configs

    ```bash
    kind create cluster --name retail --config kind-config.yml
    ```

    ![alt text](screenshots/screenshot37.png)

3. Install ArgoCD with configs:

    - cd into kind-cluster:

      ```bash
      cd retail-store-reverse-engineered/my-work/kubernetes/argocd-deploy/kind-cluster
      ```

    - Add ArgoCD repo to helm:

      ```bash
      helm repo add argo https://argoproj.github.io/argo-helm
      helm repo update
      ```

    - Install ArgoCD:

      ```bash
      helm install argocd argo/argo-cd -n argocd -f argocd-install-values.yaml --create-namespace
      ```

      ![alt text](screenshots/ss07.png)

    - Check ArgoCD status:

      ```bash
      kubectl get all -n argocd
      ```

4. Fetch ArgoCD Password and Login:

    - Open a port for ArgoCD:

       ![alt text](screenshots/ss19.png)

    - Fetch ArgoCD password:

      ```bash
      kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d
      ```

    - Open ArgoCD in browser

      ![alt text](screenshots/ss20.png)

5. Install/Create project then platform:

    - Apply project

      ```bash
      kubectl apply -f argocd-project.yml -n argocd
      ```

    - Apply platform to install ESO and create ClusterSecetStore

      ```bash
      kubectl apply -f platform.yml -n argocd
      ```

      ![alt text](screenshots/ss14.png)

6. Deploy the apps

    - cd into apps:

      ```bash
      cd retail-store-reverse-engineered/my-work/kubernetes/argocd-deploy/apps
      ```

    - Deploy the apps:

      ```bash
      kubectl apply -f application-set.yml -n argocd
      ```

      ![alt text](screenshots/ss17.png)

7. Verify Deployment Status:

    - Verify Kubernetes resources:

      ![alt text](screenshots/ss47.png)

    - Verify ArgoCD synchronization:

      ![alt text](screenshots/ss21.png)

    - Check for Secrets:

      ![alt text](screenshots/ss02.png)

      ![alt text](screenshots/ss01.png)

    - Wait for Kubernetes Reconciliation:

      ![alt text](screenshots/ss22.png)

    - confirm multi-env deployment

      ![alt text](screenshots/ss43.png)

8. Access the application:

    - Open port for each env:

      ![alt text](screenshots/ss39.png)

    - Run port-forward commands for each env

      ```bash
      kubectl port-forward svc/ui-dev-service -n argocd 9090:80 --address=0.0.0.0
      ```

      ```bash
      kubectl port-forward svc/ui-stage-service -n argocd 8080:80 --address=0.0.0.0
      ```

    - Access the application:

      ![alt text](screenshots/ss41.png)

    - Validate end-to-end application workflow:

      ![alt text](screenshots/ss30.png)

9. Validate multi-env persistent storage on external EBS volume:

    ![alt text](screenshots/ss36.png)

**Result:**

Successfully deployed and validated a multi-environment Kubernetes application stack using ArgoCD on a kind cluster with persistent EBS-backed storage.

</details>

## 🧠 What This Project Demonstrates

This project demonstrates hands-on experience with:

- GitOps-based continuous delivery using ArgoCD
- Multi-environment Kubernetes deployments
- Helm templating and reusable chart architecture
- Platform vs application layer separation
- Kubernetes reconciliation and sync orchestration
- ArgoCD Sync Waves and dependency management
- External Secrets Operator integration with AWS Secrets Manager
- Stateful PostgreSQL workloads with persistent storage
- Environment-level storage isolation
- Helm rendering and path resolution debugging
- Deployment race condition troubleshooting
- Scalable GitOps repository organization

## ⚙️ Core Implementation

Implemented the following architectural and operational patterns:

- Built a GitOps workflow using ArgoCD with automated sync-based deployments
- Organized repositories into platform, application, and environment layers for cleaner scalability
- Implemented ArgoCD ApplicationSets for dynamic multi-environment deployments
- Integrated External Secrets Operator with AWS Secrets Manager for centralized Kubernetes secret injection
- Managed deployment dependencies using ArgoCD Sync Waves
- Used `ServerSideApply=true` to handle large CRD deployments safely
- Implemented persistent PostgreSQL storage backed by external EBS volumes
- Designed per-environment storage isolation to avoid cross-environment conflicts
- Mounted EBS-backed host storage into kind nodes using `extraMounts` for persistent state retention across cluster recreation

## ⚔️ Challenges & Solutions

Building this ArgoCD-based GitOps setup taught me much more than just “deploying apps.”
Most of the work was actually around handling orchestration edge cases, Helm behavior, Kubernetes reconciliation, and dependency management across environments.

### 1. Managing Deployment Order Across Platform Components

**Challenge:**

Some resources depended on others being available first:

- CRDs had to exist before dependent resources
- External Secrets Operator had to become ready before ClusterSecretStore
- Applications needed secrets before startup

Without proper orchestration, deployments failed during sync.

**Solution:**

I separated the platform and application layers and enforced deployment order using:

- ArgoCD Sync Waves
- Kustomize
- ServerSideApply
- SkipDryRunOnMissingResource

This ensured CRDs, controllers, webhooks, and secret providers became available in the correct order before applications synced.

**Key Engineering Problems Solved:**

1. **✅ Metadata Size Limit**

    - Large CRDs exceeded Kubernetes’ annotation size limit (262KB) during normal apply operations.

    **Solution:** Used:

    ```yaml
      ServerSideApply=true
    ```

2. **✅ Resource Validation Race Condition**

    - ClusterSecretStore attempted validation before **ESO webhooks** were fully ready.

    **Solution:** Used sync waves:

    ```yaml
    argocd.argoproj.io/sync-wave: "-1"
    # and later waves for dependent resources.
    ```

3. **✅ Unknown Resource Validation Loop**

    - ArgoCD tried validating CRDs before they existed.

    **Solution:** Added:

    ```yaml
    SkipDryRunOnMissingResource=true
    # to allow initial reconciliation to proceed safely.
    ```

### 2. ArgoCD Couldn’t Detect Helm Charts

**Challenge:**

1. **ArgoCD failed with:**

    - **Chart.yaml not found**\
        even though Helm charts existed inside nested directories.

    - **Root Cause**

      - ArgoCD does not recursively search for Helm charts.
      - It expects Chart.yaml exactly at the path defined in:

          ```yaml
          spec.source.path
          ```

**Solution:**

- Instead of pointing to a parent directory, I dynamically mapped each chart path:

  ```yaml
  path: my-work/kubernetes/argocd-deploy/apps/{{chartPath}}
  ```

- **The chart must exist exactly at that location**.

### 3. Helm Path Resolution & Template Rendering Pitfalls

While working with Helm templating, I hit multiple issues that exposed how Helm actually processes files internally.

- Incorrect valueFiles Relative Paths

**Challenge:**

1. ArgoCD sync failed because Helm values files could not be found.

**Root Cause:**

- valueFiles paths are resolved relative to the chart directory — not the repository root.

**Solution:**

- Adjusted paths based on actual chart depth:

  ```yaml
  helm:
    valueFiles:
      - ../../../envs/{{env}}/{{name}}.yaml
  ```

### 4. External Secrets Readiness vs Deployment Timing

**Challenge:**

- Applications started before Kubernetes Secrets were created by External Secrets Operator, causing startup failures.

**The Real Problem:**

- The sequence looked like this:

  - Application deployment starts
  - ExternalSecret begins reconciliation
  - Secret does not exist yet
  - Pod starts anyway
  - Application crashes

**This exposed an important Kubernetes concept:**

- Deployment order does not guarantee runtime readiness.

**Approaches I Evaluated:**

1. **Helm Hooks + Waiting Jobs**

    - Use Jobs to block deployment until secrets existed.

    **Tradeoff**

    - extra RBAC
    - extra ServiceAccounts
    - operational complexity

2. **ArgoCD Health Checks**

    - Considered custom Lua health checks inside ArgoCD.

    **Tradeoff**

    - Cleaner GitOps approach, but required admin-level ArgoCD access.

3. **Init Containers**

    - Use lightweight init containers to wait until mounted secret files appear.

    **Tradeoff**

    - same complexity as helm jobs, but better control.

4. **Native Kubernetes Reconciliation (Final Choice)**

    - Ultimately, I chose to trust Kubernetes reconciliation behavior instead of over-engineering the workflow.

    - The application initially restarted a few times while secrets were being created, then stabilized automatically once reconciliation completed.

**Result:**

- No custom waiting scripts
- No unnecessary orchestration complexity
- Platform handled recovery naturally
- Deployment stabilized within minutes

### 5. Multi-Environment Persistent Storage on a Single kind Cluster

**Challenge:** I wanted:

- dev
- stage
- prod

  all running **simultaneously** on a single **kind cluster** while keeping **persistent PostgreSQL data isolated** and durable.

**Architecture:**

- kind cluster running on EC2
- External AWS EBS volume mounted on host
- Mounted into kind nodes using extraMounts
- PostgreSQL StatefulSets using PVCs
- Manual dynamic provisioning using hostPath

**Core Problem:**

Running multiple environments on the same shared storage introduced risks of:

- data overlap
- PVC conflicts
- accidental environment contamination

**Solution:**

I implemented environment-level storage isolation:

```yaml
/mnt/postgre-data/
  ├── orders-dev
  ├── orders-stage
  └── orders-prod
```

Each environment had:

- dedicated PV
- dedicated PVC
- isolated storage directory

**Result:**

- ✅ Multiple environments running simultaneously
- ✅ Persistent data survives cluster recreation
- ✅ No cross-environment storage conflicts
- ✅ Better understanding of Kubernetes persistence internals

**Key Takeaways:**

- GitOps is more than deployment automation — it’s dependency orchestration
- Kubernetes reconciliation is extremely powerful when trusted correctly
- Helm rendering behavior can create subtle production issues
- Storage isolation should happen at the infrastructure layer
- Cluster lifecycle and data lifecycle are completely separate concerns

## 📈 Operational Outcomes

- *Implemented a production-oriented GitOps workflow using **`ArgoCD`**, **`Helm`**, and **`Kustomize`***

- *Validated simultaneous multi-environment deployments on a single Kubernetes cluster*

- *Established separation between platform infrastructure, applications, and environment configurations*

- *Improved deployment reliability through sync-wave orchestration and reconciliation-aware design*

- *Integrated centralized secret management using **`External Secrets Operator`** and **`AWS Secrets Manager`***

- *Implemented persistent EBS-backed PostgreSQL storage with environment-level isolation*

- *Reduced orchestration complexity by leveraging native Kubernetes reconciliation behavior*

- *Improved understanding of Helm rendering internals, GitOps synchronization flow, and Kubernetes runtime behavior*

- *Designed a scalable repository structure aligned with production GitOps practices*

## 🎓 Key Learnings

- ArgoCD manages desired state — not runtime readiness
- Kubernetes reconciliation can eliminate unnecessary orchestration complexity
- Deployment order and application readiness are separate concerns
- Helm path resolution becomes increasingly important in large GitOps repositories
- Stateful workloads require infrastructure-level storage isolation
- Multi-environment Kubernetes deployments require strict configuration separation
- GitOps scalability depends heavily on repository structure and dependency organization
- Kubernetes troubleshooting often requires validating infrastructure, orchestration, and runtime layers independently

### 💡 Key Takeaway

GitOps is not just deployment automation — it is designing systems that reconcile, recover, and scale predictably.

## 📌 Conclusion

This project evolved beyond a simple ArgoCD deployment setup into a deeper exploration of Kubernetes orchestration, reconciliation behavior, persistent storage design, and GitOps dependency management.

The most valuable learning came from debugging synchronization failures, handling runtime race conditions, and understanding how distributed Kubernetes systems recover under operational constraints.

Building the platform manually provided deeper visibility into Kubernetes internals that are often abstracted away in managed environments.

## 🔭 Next Phase

*Implementation of Observability layer [(read here)](../../../03-observability/)*
