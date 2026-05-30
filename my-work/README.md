# 🚀 Production-Oriented GitOps Platform on Kubernetes

This project implements a production-oriented Kubernetes platform focused on GitOps-driven deployments, layered infrastructure separation, multi-environment orchestration, persistent workloads, and operational scalability.

The platform integrates:

* Kubernetes
* ArgoCD
* Helm
* External Secrets Operator
* PostgreSQL
* Centralized Observability
* Multi-Environment Deployments
* GitOps-based Continuous Delivery

---

# 📑 Table of Contents

1. [Overview](#-overview)
2. [Platform Architecture](#-platform-architecture)
3. [Repository Architecture](#-repository-architecture)
4. [Core Platform Capabilities](#-core-platform-capabilities)
5. [Deployment Workflow](#-deployment-workflow)
6. [Architectural Decisions](#️-architectural-decisions)
7. [Operational Outcomes](#-operational-outcomes)
8. [Challenges & Solutions](#️-challenges--solutions)
9. [Key Learnings](#-key-learnings)
10. [Platform Layers](#-platform-layers)
11. [Future Improvements](#-future-improvements)

---

# 📖 Overview

This platform was designed to simulate production-style Kubernetes and GitOps workflows while remaining lightweight enough for local experimentation and rapid iteration.

The implementation focuses on:

* Multi-environment deployments (`dev`, `stage`, `prod`)
* GitOps-based continuous reconciliation
* Dependency-aware deployment orchestration
* Layered platform architecture
* Stateful workload persistence
* Infrastructure separation
* Operational observability
* Kubernetes-native deployment workflows

The platform uses:

* **ArgoCD** for GitOps orchestration
* **Helm** for reusable templating
* **External Secrets Operator** for secret synchronization
* **Prometheus + Grafana** for observability
* **Loki + Promtail** for centralized logging
* **PostgreSQL** for stateful workloads
* **Kind Kubernetes cluster** running on EC2
* **EBS-backed persistent storage**

---

# 🗼 Platform Architecture

![alt text](screenshots/platform-architecture.jpg)

---

# 🏗️ Repository Architecture

The repository is organized into layered operational domains to improve scalability, maintainability, deployment separation, and platform ownership boundaries.

## Architectural Layers

| Layer             | Responsibility                                                               |
| ----------------- | ---------------------------------------------------------------------------- |
| `bootstrap/`      | Platform bootstrap scripts and deployment initialization                     |
| `platform/`       | Shared Kubernetes platform services and cluster-level dependencies           |
| `applications/`   | Multi-environment application workloads and deployment manifests             |
| `observability/`  | Monitoring, logging, telemetry, dashboards, and operational visibility       |
| `infrastructure/` | Persistent storage, infrastructure dependencies, and provisioning components |
| `screenshots/`    | Deployment validation and operational workflow screenshots                   |

## Repository Evolution

As the platform evolved, the repository structure was refactored to separate infrastructure, observability, platform services, and application workloads into dedicated operational layers.

This restructuring improved:

* Separation of concerns
* Deployment scalability
* GitOps maintainability
* Operational visibility integration
* Environment isolation
* Long-term platform extensibility

---

# 🎯 Core Platform Capabilities

* GitOps-based continuous deployment using ArgoCD
* Multi-environment Kubernetes deployments
* Layered infrastructure separation
* Dependency-aware deployment orchestration
* External Secrets Operator integration
* Stateful PostgreSQL workloads
* Persistent EBS-backed storage
* Centralized observability workflows
* Kubernetes-native monitoring and logging
* Environment-aware telemetry isolation
* Reusable Helm-based deployments
* Runtime reconciliation and recovery workflows
* RBAC-aware platform segmentation

---

# 📦 Deployment Workflow

This section outlines the deployment flow for the current platform architecture.

> [!NOTE]
> The repository structure evolved significantly as observability and platform-wide operational layers were introduced.

## 1. Infrastructure Preparation

Prepare required infrastructure components:

* EC2 instance
* Attached EBS volume
* DynamoDB table
* AWS Secrets Manager secrets
* IAM permissions

---

## 2. Cluster Bootstrap

Create the Kubernetes cluster and initialize required storage mounts and networking configuration.

```bash id="5j3lyq"
kind create cluster --name retail --config kind-config.yml
```

---

## 3. Platform Layer Deployment

Deploy shared platform services:

* ArgoCD
* External Secrets Operator
* ClusterSecretStore
* Shared Kubernetes resources

---

## 4. GitOps Initialization

Bootstrap:

* ArgoCD Projects
* Root applications
* Sync-wave orchestration
* Dependency-aware synchronization

---

## 5. Application Deployment

Deploy multi-environment workloads using:

* Helm charts
* ApplicationSets
* Namespace-aware configuration

---

## 6. Observability Stack Deployment

Deploy:

* Prometheus
* Grafana
* Loki
* Promtail
* Alertmanager
* Exporters

➡️ [View Observability Implementation](../03-observability/)

---

## 7. Runtime Validation

Validate:

* ArgoCD synchronization
* Kubernetes reconciliation
* Secret injection
* Persistent storage
* Metrics collection
* Centralized logging
* Multi-environment isolation

---

# 🏗️ Architectural Decisions

## 1. GitOps-First Deployment Model

### The Decision

Adopted ArgoCD as the primary deployment controller.

### Why

* Continuous reconciliation
* Drift detection
* Declarative deployments
* Environment scalability

---

## 2. Layered Repository Architecture

### The Decision

Separated the platform into:

* Infrastructure Layer
* Platform Layer
* Application Layer
* Observability Layer

### Why

* Clear operational boundaries
* Easier dependency management
* Reduced coupling
* Better maintainability

---

## 3. Dependency-Aware Synchronization

### The Decision

Implemented synchronization ordering using:

* ArgoCD Sync Waves
* Health-based orchestration
* Reconciliation-aware workflows

### Why

* Prevent race conditions
* Improve deployment reliability
* Ensure dependency readiness

---

## 4. Stateful Workload Persistence

### The Decision

Implemented persistent PostgreSQL workloads using EBS-backed storage.

### Why

* Durable application state
* Environment-level isolation
* Persistent cluster recreation workflows

---

## 5. Kubernetes-Native Operational Design

### The Decision

Relied heavily on Kubernetes-native controllers, reconciliation, and CRDs.

### Why

* Better ecosystem integration
* Reduced orchestration complexity
* Improved operational consistency

---

# 📈 Operational Outcomes

* Successfully implemented a production-oriented GitOps platform using Kubernetes and ArgoCD
* Validated simultaneous multi-environment deployments on a single cluster
* Established separation between infrastructure, platform, application, and observability layers
* Improved deployment reliability through dependency-aware synchronization
* Implemented persistent storage workflows for stateful workloads
* Integrated centralized monitoring, logging, and alerting pipelines
* Reduced orchestration complexity by leveraging Kubernetes reconciliation behavior
* Improved operational visibility across workloads and environments
* Established scalable repository organization aligned with platform-engineering practices

---

# ⚔️ Challenges & Solutions

This implementation introduced multiple platform-level orchestration and operational challenges while integrating GitOps workflows, observability, stateful workloads, and multi-environment deployments.

| Area                         | Challenge                                                      | Solution                                                        |
| ---------------------------- | -------------------------------------------------------------- | --------------------------------------------------------------- |
| GitOps Orchestration         | Applications synced before dependencies became healthy         | Implemented dependency-aware synchronization using Sync Waves   |
| Runtime Readiness            | Deployment order did not guarantee application readiness       | Relied on Kubernetes reconciliation behavior                    |
| Multi-Environment Deployment | Environment isolation became difficult as complexity increased | Implemented namespace-aware separation and layered architecture |
| Repository Scalability       | Platform growth created operational coupling                   | Refactored into dedicated platform layers                       |
| Stateful Workloads           | Persistent storage required environment isolation              | Implemented dedicated storage separation workflows              |
| Observability Integration    | Metrics and logging pipelines required centralized visibility  | Introduced platform-wide observability architecture             |

➡️ Detailed implementation-specific challenges are documented within their respective layers.

---

# 🧠 Key Learnings

* GitOps manages desired state — not runtime readiness
* Kubernetes reconciliation can eliminate unnecessary orchestration complexity
* Deployment order and runtime readiness are separate concerns
* Multi-environment deployments require strict operational separation
* Stateful workloads require infrastructure-aware persistence design
* Platform scalability depends heavily on repository architecture and operational boundaries
* Observability becomes critical as deployment complexity increases
* Kubernetes troubleshooting often requires validating infrastructure, orchestration, and runtime layers independently

---

# 🧩 Platform Layers

## 🚀 Platform & GitOps

* ArgoCD
* Helm
* Sync Waves
* Health Checks
* External Secrets Operator

## 📦 Applications

* carts
* catalog
* checkout
* orders
* ui

## 📊 Observability

* Prometheus
* Grafana
* Loki
* Promtail
* Alertmanager

➡️ [View Observability Layer](../03-observability/)

## 🗄️ Stateful Infrastructure

* PostgreSQL
* Persistent Volumes
* EBS-backed storage

---

# 🤖 Future Improvements

* EKS migration
* Terraform-based provisioning
* Full CI/CD automation
* Distributed tracing
* Backup and disaster recovery workflows
* Progressive delivery workflows
* Policy-as-code integration
