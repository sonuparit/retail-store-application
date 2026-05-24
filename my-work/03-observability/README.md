# 🚀 Observability layer Implementation

> [!NOTE]
> Beyond this implementation, the Application layer of the project was deployed on AWS EKS Auto Mode, Terraform-provisioned infrastructure, and full ArgoCD-driven GitOps CI/CD workflows. [(View Implementation)](https://github.com/sonuparit/terraform-gitops-pipeline)

This section of project implements a production-style Kubernetes observability and GitOps platform focused on monitoring, centralized logging, alerting, deployment orchestration, and multi-environment management.

## 📑 Table of Contents

1. [Overview](#-overview)
2. [Architecture](#-architecture)
3. [Metrics & Observability Flow](#-metrics--observability-flow)
4. [Repository Structure](#-repository-structure)
5. [Tech Stack](#️-tech-stack)
6. [Core Features](#-core-features)
7. [Implementation Highlights](#️-implementation-highlights)
8. [Deployment Guide](#-deployment-guide)
9. [Architectural Decisions](#️-architectural-decisions)
10. [Operational Outcomes](#-operational-outcomes)
11. [Challenges & Solutions](#️-challenges--solutions)
    - Summary Only
    - Read full section [(here)](./challenges_&_solutions.md)
12. [Key Learnings](#-key-learnings)
13. [Future Improvements](#-future-improvements)
14. [Screenshots](#-screenshots)

## 📖 Overview

The platform integrates:

- Prometheus + Grafana for metrics and visualization
- Loki + Promtail for centralized logging
- Alertmanager for real-time alerting
- ArgoCD for GitOps-based continuous deployment
- PostgreSQL monitoring through exporter-based telemetry collection

It was designed to simulate real-world operational workflows including:

- multi-environment deployments (`dev`, `stage`, `prod`)
- dependency-aware deployments
- layered repository architecture
- RBAC-aware GitOps management
- Kubernetes-native observability practices

## 🗼 Architecture

![alt text](screenshots/arch.jpg)

## 📊 Metrics & Observability Flow

### Metrics flow

  ```text
  Application
    ↓
  Service
    ↓
  ServiceMonitor
    ↓
  Prometheus
    ↓
  Grafana / Alertmanager
  ```

### Logs flow

  ```text
  Container Logs
    ↓
  Promtail
    ↓
  Loki
    ↓
  Grafana Explore
  ```

## 📂 Repository Structure

```txt
.
├── README.md
├── alertmanager
│   ├── application
│   ├── infrastructure
│   ├── kubernetes
│   ├── secrets
│   └── test
├── argocd
│   ├── service-monitors
│   └── services
├── kube-state-metrics
├── loki
├── manifests
├── postgresql
├── prometheus-stack
└── screenshots

```

## 🛠️ Tech Stack

### ☸️ Container Orchestration

- Kubernetes
- Kind (Kubernetes in Docker)

### 🚀 GitOps & Deployment

- ArgoCD
- Helm
- Helm Charts

### 📦 Infrastructure & Platform

- External Secrets Operator (ESO)

### 📊 Monitoring & Metrics

- Prometheus
- Prometheus Operator
- kube-prometheus-stack
- Grafana
- postgres-exporter
- kube-state-metrics

### 📜 Logging & Observability

- Loki
- Promtail
- Grafana Explore

### 🚨 Alerting

- Alertmanager
- Slack Webhooks
- Email Notifications

### 🗄️ Database

- PostgreSQL

### 🔐 Security & Access Control

- RBAC
- ArgoCD Projects
- Principle of Least Privilege (PoLP)

### 🌐 Networking & Service Discovery

- Kubernetes Services
- Headless Services
- CoreDNS

### ⚙️ Automation & Scripting

- Bash
- YAML
- Lua (ArgoCD Health Checks)

### 🧩 CI/CD & Configuration Management

- GitOps Workflow
- Declarative Kubernetes Manifests
- Environment-based Helm templating

### 🖥️ Operating System & Runtime

- Linux
- Docker

### 🔍 Observability Concepts Implemented

- Centralized Logging
- Metrics Collection
- Multi-Environment Monitoring
- Dependency-Aware Deployments
- Health-Based Rollout Synchronization
- Environment Labeling
- Runtime Telemetry Collection

## 🎯 Core Features

This platform implements a production-style Kubernetes observability and GitOps workflow focused on scalability, operational visibility, deployment reliability, and multi-environment management.

- GitOps-based continuous deployment using ArgoCD
- Multi-environment Kubernetes deployments (`dev`, `stage`, `prod`)
- Centralized metrics collection using Prometheus
- Centralized logging using Loki + Promtail
- Real-time alerting with Alertmanager
- PostgreSQL monitoring using `postgres-exporter`
- Grafana dashboards for metrics visualization
- Environment-aware monitoring and logging
- Kubernetes-native monitoring using `ServiceMonitor`
- Layered deployment orchestration
- Helm-based reusable deployments
- RBAC-aware ArgoCD Project segmentation
- Centralized observability workflows
- Declarative Kubernetes configuration management

## ⚙️ Implementation Highlights

### 📊 Monitoring Stack Deployment

Installed a production-oriented monitoring stack using Helm charts:

- Prometheus
- Grafana
- Alertmanager
- Node Exporter
- kube-state-metrics

via:

```bash
kube-prometheus-stack
```

This provided:

- Centralized metrics collection
- Kubernetes cluster monitoring
- Grafana dashboard integration
- Prometheus Operator support
- Alertmanager
- ServiceMonitor CRDs

### 🔍 ServiceMonitor-Based Metrics Discovery

Implemented Kubernetes-native monitoring using `ServiceMonitor` resources instead of annotation-based scraping.

Created dedicated `ServiceMonitor` manifests for microservices to enable:

![alt text](./screenshots/ss32.png)

- automatic target discovery
- Prometheus Operator integration
- environment-aware monitoring
- declarative observability configuration

```yaml
apiVersion: monitoring.coreos.com/v1
kind: ServiceMonitor
```

### 🧪 Operational Validation on Single Microservice

Before scaling observability cluster-wide, initially tested monitoring integration on a single microservice (Catalog).

Validated:

- metrics endpoint exposure
- Prometheus target discovery
- ServiceMonitor selectors
- Grafana metric visibility
- Kubernetes service-to-target resolution

This reduced debugging complexity and enabled controlled observability rollout.

### 🧩 Helmified ServiceMonitors for Multi-Environment Deployment

Converted observability resources into reusable Helm templates to support scalable multi-service and multi-environment deployments.

![alt text](screenshot33-1.png)

Helmified:

- labels
- Services
- ServiceMonitors
- environment metadata
- namespace-aware monitoring

![alt text](./screenshots/ss97.png)

Successfully implemented centralized metrics aggregation for:

- carts
- checkout
- orders
- catalog
- ui

across env:

- dev
- stage
- prod

![alt text](./screenshots/ss98.png)

This enabled:

- reusable monitoring architecture
- centralized observability
- environment-aware metrics discovery
- cross-service visibility
- simplified GitOps workflows
- scalable Kubernetes monitoring

### 💾 Loki & Promtail Deployment with Persistent Storage

Installed Loki and Promtail using Helm charts with custom `values.yaml` configuration.

Implemented:

- PVC-backed persistent storage
- filesystem-based log retention
- Promtail Kubernetes discovery
- resource-aware deployment configuration

This ensured:

- persistent log storage
- centralized log ingestion
- scalable observability architecture

### 📝 Centralized Logging via Loki

Implemented centralized Kubernetes logging using:

- Loki
- Promtail
- Grafana Explore

to aggregate logs from all microservices into a centralized observability platform.

Enabled:

- label-based log querying
- namespace-aware filtering
- application-specific log searches
- real-time log visibility

using LogQL queries such as:

```logql
{app="carts"}
```

![alt text](./screenshots/ss106.png)

and:

```logql
{namespace="dev"}
```

![alt text](./screenshots/ss04.png)

### 🏷️ Helmified Environment & Application Labeling Strategy

Helmified Kubernetes metadata labeling to standardize observability across multiple microservices and environments.

Implemented reusable labels for:

- application identification
- environment separation
- namespace-aware observability

using:

```yaml
metadata:
  labels:
    app: {{ .Chart.Name }}
    env: {{ .Release.Namespace }}
```

This enabled:

- clean metrics filtering
- centralized log separation
- multi-environment observability
- Grafana label-based queries
- reusable environment-aware deployments

### ⚔️ Troubleshooting & Operational Problem Solving

Resolved multiple production-oriented observability challenges during implementation, including:

- Prometheus target discovery failures
- ServiceMonitor selector mismatches
- Incorrect ServiceMonitor port configuration
- Environment label propagation
- Promtail CrashLoopBackOff
- Loki integration issues
- Linux filesystem watcher exhaustion
- Kubernetes service-to-container port mapping confusion
- Understood Postgre exporter architecture

This significantly improved operational understanding of:

- Prometheus Operator internals
- Kubernetes networking
- Centralized logging architecture
- Linux kernel tuning
- Observability scaling considerations
- Postgre exporter

### 📊 Observability Validation

Validated the complete observability pipeline through:

- Prometheus Targets
- Grafana Dashboards
- Loki Explore
- LogQL Queries
- PromQL Queries
- Custom alerting
- Email & Slack Notification

Successfully verified:

- metrics scraping
- multi-environment monitoring
- centralized logging
- live log ingestion
- application-level telemetry
- Kubernetes metadata enrichment

## 📦 Deployment Guide

This section walks through deploying the full multi-environment GitOps setup on a kind Kubernetes cluster running on EC2.

> [!NOTE]
> Kind was used for cost-efficient local Kubernetes simulation and rapid environment iteration.

### Prerequisites

**Infra:**

1. ***`EC2 instance`** (recommended flex.large for multi env)*

2. ***`EBS volume`** attached to EC2 and mounted for persistence services*

3. ***`Dynamodb`** for carts service with:*

    ```bash
    table: Item   |  index: idx_global_cutomerId
        id: id     |    key: customerId
    ```

    ![alt text](screenshots/screenshot33.png)

4. ***`AWS Sercrets Manager`** with secrets configured:*

5. ***`IAM role for EC2`** with permissions:*

    - dynamodb read and write access
    - secrets manager read access

6. ***`Metadata response hop limit`** for EC2 set to: `5`*

**Tools:**

1. Docker installed and running
2. kubectl
3. helm
4. Kind

**Steps:**

1. Clone the repo and get into `bootstrap`

    ```bash
    git clone https://github.com/sonuparit/retail-store-reverse-engineered.git

    cd /retail-store-reverse-engineered/my-work/bootstrap/
    ```

2. Run the script:

    ```bash
    chmod 700 bootstrap.sh
    bash bootstrap.sh
    ```

3. Once ArgoCD shows all apps green in UI, run second script:

    ```bash
    chmod 700 port-forward.sh
    bash port-forward.sh
    ```

4. Follow the instructions:

## 🏗️ Architectural Decisions

The platform was designed around GitOps, layered infrastructure separation, and production-style observability practices to improve scalability, operational reliability, and maintainability.

### 1. GitOps-First Deployment Model

- **The Decision:**\
  Adopted ArgoCD as the single deployment controller to ensure declarative, continuously reconciled infrastructure and application delivery.

- **Why:**

  - Centralized deployment management
  - Drift detection and reconciliation
  - Improved deployment consistency
  - Easier environment scalability

---

### 2. Layered Repository Architecture

- **The Decision:**\
  Separated the repository into dedicated layers:

  - Infrastructure Layer
  - Platform Layer
  - Observability Layer
  - Application Layer

- **Why:**

  - Clear separation of concerns
  - Easier dependency management
  - Safer permission boundaries
  - Improved operational maintainability

---

### 3. Dependency-Aware Deployment Sequencing

- **The Decision:**\
  Implemented layered deployment synchronization using:

  - ArgoCD Sync Waves
  - Custom Lua Health Checks

- **Why:**

  - Prevent race conditions
  - Ensure foundational services become healthy before dependent deployments
  - Improve deployment reliability

---

### 4. Prometheus Operator-Based Monitoring

- **The Decision:**\
  Used `kube-prometheus-stack` with:

  - `ServiceMonitor`

  instead of annotation-only scraping.

- **Why:**

  - Kubernetes-native target discovery
  - Declarative monitoring configuration
  - Better scalability and maintainability

---

### 5. Environment-Based Observability Segregation

- **The Decision:**\
  Implemented namespace-driven environment labeling for:

  - Metrics
  - Logs
  - Queries

- **Why:**

  - Clean multi-environment separation
  - Faster troubleshooting
  - Safer production observability workflows

---

### 6. Centralized Logging Architecture

- **The Decision:**\
  Implemented:

  - Loki for log storage
  - Promtail for log collection
  - Grafana for log exploration

  with Kubernetes metadata enrichment and relabeling.

- **Why:**

  - Centralized cluster-wide logging
  - Label-based querying
  - Easier debugging across environments and services

---

### 7. Exporter-Based Telemetry Collection

- **The Decision:**\
  Used dedicated exporters such as:

  - `postgres-exporter`

- **Why:**

  - Decoupled observability architecture
  - Standardized Prometheus metrics exposure
  - Easier monitoring scalability

---

### 8. Principle of Least Privilege (PoLP)

- **The Decision:**\
  Implemented scoped ArgoCD Projects and resource separation.

- **Why:**

  - Reduced blast radius
  - Safer GitOps operations
  - Better production-grade security posture

---

### 9. Helm-Based Configuration Standardization

- **The Decision:**\
  Standardized deployments using reusable Helm templating.

- **Why:**

  - Environment consistency
  - Reduced configuration duplication
  - Easier scaling across multiple environments

---

### 10. Kubernetes-Native Observability Stack

- **The Decision:**\
  Built the entire monitoring and logging pipeline using Kubernetes-native controllers and CRDs.

- **Why:**

  - Better ecosystem integration
  - Declarative infrastructure management
  - Easier operational automation
  - Production-style observability workflows

---

## 📈 Operational Outcomes

This implementation resulted in a production-style Kubernetes observability platform with improved deployment reliability, centralized visibility, and scalable operational workflows.

- Achieved centralized monitoring across multiple Kubernetes environments
- Implemented cluster-wide centralized logging and log aggregation
- Enabled environment-aware metrics and log isolation for `dev`, `stage`, and `prod`
- Reduced deployment instability through dependency-aware synchronization
- Improved troubleshooting efficiency using unified observability workflows
- Automated deployment reconciliation through GitOps practices
- Standardized observability configuration using reusable Helm templates
- Improved operational visibility into PostgreSQL and Kubernetes workloads
- Established scalable repository organization through layered architecture
- Integrated real-time alert delivery through Slack and email pipelines

## ⚔️ Challenges & Solutions

This project involved building and operating a production-style Kubernetes observability platform, requiring deep troubleshooting across networking, GitOps, monitoring, logging, alerting, RBAC, and deployment orchestration layers.

### Summary Only (Read full section - [here](./challenges_&_solutions.md))

| Area | Challenge | Solution |
|---|---|---|
| ArgoCD | Layered deployments executed simultaneously | Implemented Lua-based health checks for dependency-aware sync |
| Postgre Exporter | Confusion with architecture and exporter not working | Removed confusion by creating Architecture diagram, then Implemented it |
| Prometheus | ServiceMonitors silently ignored | Reordered CRD installation lifecycle |
| Loki | Promtail crashed with `too many open files` | Tuned Linux inotify kernel limits |
| Alertmanager | Pods never created | Fixed Operator validation + storage configuration |
| Multi-env Observability | Logs/metrics mixed across environments | Designed environment-aware labels |

## 🧠 Key Learnings

Building and operating this platform significantly improved my understanding of production-grade Kubernetes observability and GitOps workflows.

- Learned how Prometheus Operator manages monitoring through CRDs and reconciliation loops
- Improved understanding of Kubernetes DNS, Services, and inter-service communication
- Gained hands-on experience troubleshooting exporter-based telemetry pipelines
- Learned how Linux kernel limits impact large-scale log aggregation systems
- Improved understanding of Kubernetes Operator validation and reconciliation behavior
- Learned how deployment orchestration depends on accurate health signaling
- Strengthened GitOps architecture and dependency-management practices
- Improved troubleshooting methodology by validating runtime behavior over UI assumptions
- Learned practical RBAC and Principle of Least Privilege implementation strategies
- Improved observability design through structured labeling and metadata enrichment

## 🤖 Future Improvements

- EKS deployment
- Terraform Provisioning
- Full CI/CD using GitHub Actions
- Add automated backup and disaster recovery workflows

## 📸 Screenshots

ArgoCD ServiceMonitors

![alt text](screenshots/ss17.png)

Postgre exporter

![alt text](screenshots/ss07.png)

Custom Prometheus alerts

![alt text](screenshots/ss03.png)

Prometheus and ArgoCD

![alt text](screenshots/ss16.png)

Apps Metrics

![alt text](screenshots/ss91.png)

Apps Logs

![alt text](screenshots/ss105.png)

ArgoCD Metrics

![alt text](screenshots/ss74.png)

ArgoCD Logs

![alt text](screenshots/ss50.png)

Prometheus Alert Simulation

![alt text](screenshots/ss34.png)

Alert Manager

![alt text](screenshots/ss40.png)

Slack Notification

![alt text](screenshots/ss36.png)

Email Notification

![alt text](screenshots/ss37.png)

Kubernetes Dashboard

![alt text](screenshots/ss05.png)

PostgreSQL

![alt text](screenshots/ss46.png)

3 env deployment

![alt text](screenshots/ss19.png)

Deployment verification

![alt text](screenshots/ss48.png)

Node Exporter

![alt text](screenshots/ss64.png)

API Server

![alt text](screenshots/ss66.png)

Kube-state-matrics

![alt text](screenshots/ss70.png)
