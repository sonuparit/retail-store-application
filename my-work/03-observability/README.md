# 🚀 Kubernetes Observability Layer

This implementation focuses on production-oriented Kubernetes observability practices including centralized monitoring, logging, alerting, telemetry collection, and operational visibility across multi-environment workloads.

## 📑 Table of Contents

- [Overview](#-overview)
- [Architecture](#-architecture)
- [Metrics & Observability Flow](#-metrics--observability-flow)
- [Repository Structure](#-repository-structure)
- [Tech Stack](#️-tech-stack)
- [Core Features](#-core-features)
- [Implementation Highlights](#️-implementation-highlights)
- [Architectural Decisions](#️-architectural-decisions)
- [Operational Outcomes](#-operational-outcomes)
- [Challenges & Solutions](#️-challenges--solutions)
- [Key Learnings](#-key-learnings)
- [Future Improvements](#-future-improvements)
- [Screenshots](#-screenshots)

## 📖 Overview

The observability stack integrates:

- Prometheus + Grafana for metrics and visualization
- Loki + Promtail for centralized logging
- Alertmanager for alert routing
- PostgreSQL monitoring through exporter-based telemetry collection

The implementation focuses on:

- centralized observability workflows
- multi-environment telemetry isolation
- Kubernetes-native monitoring
- scalable metrics collection
- centralized logging architecture
- operational troubleshooting visibility

## 📊 Metrics & Observability Flow

- ### Metrics Flow

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

- ### Logs Flow

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
├── 9-Observe.jpg
├── README.md
├── alertmanager
├── challenges_&_solutions.md
├── kube-state-metrics
├── loki
├── manifests
├── postgresql
├── prometheus-stack
└── screenshots
```

## 🛠️ Tech Stack

- ### 📊 Monitoring & Metrics

  - Prometheus
  - Prometheus Operator
  - kube-prometheus-stack
  - Grafana
  - postgres-exporter
  - kube-state-metrics

- ### 📜 Logging

  - Loki
  - Promtail
  - Grafana Explore

- ### 🚨 Alerting

  - Alertmanager
  - Slack Webhooks
  - Email Notifications

## 🎯 Core Features

- Centralized metrics collection using Prometheus
- Centralized logging using Loki + Promtail
- Real-time alerting with Alertmanager
- PostgreSQL telemetry collection using `postgres-exporter`
- Kubernetes-native monitoring using `ServiceMonitor`
- Environment-aware monitoring and logging
- Helm-based reusable observability configuration
- Multi-environment observability workflows
- Centralized Grafana dashboards and log exploration

## ⚙️ Implementation Highlights

### 1. 📊 Monitoring Stack Deployment

Installed a production-oriented monitoring stack using:

- Prometheus
- Grafana
- Alertmanager
- Node Exporter
- kube-state-metrics

via:

```bash
kube-prometheus-stack
```

This enabled:

- Kubernetes cluster monitoring
- centralized metrics collection
- Prometheus Operator integration
- Grafana dashboard support
- ServiceMonitor CRDs

### 2. 🔍 ServiceMonitor-Based Metrics Discovery

Implemented Kubernetes-native monitoring using `ServiceMonitor` resources instead of annotation scraping.

```yaml
apiVersion: monitoring.coreos.com/v1
kind: ServiceMonitor
```

This enabled:

- automatic target discovery
- environment-aware monitoring
- declarative observability configuration
- Prometheus Operator integration
  ![alt text](./screenshots/ss32.png)

### 3. 🧩 Helmified Multi-Environment Monitoring

Converted observability resources into reusable Helm templates for scalable multi-environment deployments.

Successfully implemented centralized monitoring for:

- carts
- checkout
- orders
- catalog
- ui

across:

- dev
- stage
- prod

  ![alt text](./screenshots/ss98.png)

This improved:

- observability scalability
- environment-aware telemetry
- reusable monitoring workflows
- cross-service visibility

### 4. 💾 Loki & Promtail Logging Pipeline

Implemented centralized Kubernetes logging using:

- Loki
- Promtail
- Grafana Explore

with:

- PVC-backed persistence
- Kubernetes log discovery
- label-based querying
- namespace-aware filtering

Example LogQL queries:

```logql
{app="carts"}
```

![alt text](./screenshots/ss106.png)

and:

```logql
{namespace="dev"}
```

![alt text](./screenshots/ss04.png)

### 5. 🏷️ Environment-Aware Labeling Strategy

Standardized observability metadata labeling using Helm templates:

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

---

### 6. 📊 Observability Validation

Validated the observability pipeline through:

- Prometheus Targets
- Grafana Dashboards
- Loki Explore
- LogQL Queries
- PromQL Queries
- Slack Notifications
- Email Alerting

Successfully verified:

- metrics scraping
- centralized logging
- live log ingestion
- telemetry collection
- Kubernetes metadata enrichment

## 🏗️ Architectural Decisions

### 1. Prometheus Operator-Based Monitoring

Used `kube-prometheus-stack` with `ServiceMonitor` CRDs for Kubernetes-native metrics discovery.

Why

- declarative monitoring
- scalable metrics discovery
- Prometheus Operator integration
- easier long-term maintainability

### 2. Centralized Logging Architecture

Implemented:

- Loki for storage
- Promtail for collection
- Grafana for querying

Why

- centralized cluster-wide logging
- label-based querying
- easier cross-service debugging

### 3. Environment-Based Observability Segregation

Implemented namespace-aware labeling for:

- metrics
- logs
- telemetry queries

Why

- cleaner multi-environment isolation
- faster troubleshooting
- safer operational workflows

---

### 4. Helm-Based Observability Standardization

Standardized observability resources through reusable Helm templates.

Why

- reduced configuration duplication
- scalable environment management
- reusable observability workflows

## 📈 Operational Outcomes

- Achieved centralized monitoring across multiple Kubernetes environments
- Implemented cluster-wide centralized logging and log aggregation
- Enabled environment-aware metrics and log isolation
- Improved troubleshooting visibility through unified observability workflows
- Standardized observability configuration using reusable Helm templates
- Improved operational visibility into PostgreSQL and Kubernetes workloads
- Integrated real-time alert delivery through Slack and email notifications

## ⚔️ Challenges & Solutions

### Summary Only (Read full section - [here](./challenges_&_solutions.md))

| Area                    | Challenge                                   | Solution                                          |
| ----------------------- | ------------------------------------------- | ------------------------------------------------- |
| Prometheus              | ServiceMonitors silently ignored            | Reordered CRD installation lifecycle              |
| Loki                    | Promtail crashed with `too many open files` | Tuned Linux inotify kernel limits                 |
| Alertmanager            | Pods never created                          | Fixed Operator validation + storage configuration |
| Postgre Exporter        | Exporter architecture confusion             | Created architecture validation diagrams          |
| Multi-env Observability | Logs/metrics mixed across environments      | Implemented environment-aware labeling            |

## 🧠 Key Learnings

- Learned how Prometheus Operator manages monitoring through CRDs and reconciliation
- Improved understanding of Kubernetes networking and service discovery
- Gained hands-on experience troubleshooting exporter-based telemetry pipelines
- Learned how Linux kernel limits affect log aggregation systems
- Improved observability design through structured labeling and metadata enrichment
- Strengthened troubleshooting methodology through runtime validation and telemetry analysis

## 🤖 Future Improvements

- EKS deployment
- Terraform provisioning
- Distributed tracing integration
- Automated backup and disaster recovery workflows

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
