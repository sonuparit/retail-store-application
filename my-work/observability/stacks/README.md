# 🚀 Centralized logging with Loki

[intro] 1 line

## 📑 Table of Contents

1. [Overview]()
2. [Architecture]()
3. [Repository Structure]()
4. [Deployment Guide]()
5. [Tech Stack]()
6. [What This Project Demonstrates]()
7. [Architectural Decisions]()
8. [My Implementations]()
  - [Metrics Observability]()
  - [Centralized Logging]()
  - [Alerting Pipeline]()
  - [Multi-Environment Monitoring]()
9. [Operational Outcomes]()
10. [Challenges & Solutions]()
11. [What I Learned]()
12. [Why This Matters]()
13. [What's Next]()
14. [Final Thoughts]()

## Overview

[intro] 1 line

[Content] bullet points

## Architecture

[intro] 1 line

![alt text](screenshots/ss01.jpg)

## Repository Structure

[intro] 1 line

[repo structure]

## Deployment Guide

[intro] 1 line

[Points with bullets]

## Tech Stack

[intro] 1 line

[Content] bullet points

## What This Project Demonstrates

[intro] 1 line

[Points with bullets]

## Architectural Decisions

[intro] 1 line

[Points with bullets]

# ⚙️ My Implementations

## 📊 Monitoring Stack Deployment

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

---

## 🔍 ServiceMonitor-Based Metrics Discovery

Implemented Kubernetes-native monitoring using `ServiceMonitor` resources instead of annotation-based scraping.

Created dedicated `ServiceMonitor` manifests for microservices to enable:
- automatic target discovery
- Prometheus Operator integration
- environment-aware monitoring
- declarative observability configuration

```yaml
apiVersion: monitoring.coreos.com/v1
kind: ServiceMonitor
```

---

## 🧪 Operational Validation on Single Microservice

Before scaling observability cluster-wide, initially tested monitoring integration on a single microservice (Catalog).

Validated:
- metrics endpoint exposure
- Prometheus target discovery
- ServiceMonitor selectors
- Grafana metric visibility
- Kubernetes service-to-target resolution

This reduced debugging complexity and enabled controlled observability rollout.

---

## 🧩 Helmified ServiceMonitors for Multi-Environment Deployment

Converted observability resources into reusable Helm templates to support scalable multi-service and multi-environment deployments.

Helmified:
- labels
- Services
- ServiceMonitors
- environment metadata
- namespace-aware monitoring

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

This enabled:
- reusable monitoring architecture
- centralized observability
- environment-aware metrics discovery
- cross-service visibility
- simplified GitOps workflows
- scalable Kubernetes monitoring

---

## 💾 Loki & Promtail Deployment with Persistent Storage

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

---

## 🪵 Centralized Logging via Loki

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

and:

```logql
{env="stage"}
```

---

## 🏷️ Helmified Environment & Application Labeling Strategy

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


## ⚔️ Troubleshooting & Operational Problem Solving

Resolved multiple production-oriented observability challenges during implementation, including:

- Prometheus target discovery failures
- ServiceMonitor selector mismatches
- incorrect ServiceMonitor port configuration
- environment label propagation
- Promtail CrashLoopBackOff
- Loki integration issues
- Linux filesystem watcher exhaustion
- Kubernetes service-to-container port mapping confusion

This significantly improved operational understanding of:
- Prometheus Operator internals
- Kubernetes networking
- Centralized logging architecture
- Linux kernel tuning
- Observability scaling considerations

---

## 📊 Observability Validation

Validated the complete observability pipeline through:

- Prometheus Targets
- Grafana Dashboards
- Loki Explore
- LogQL Queries
- PromQL Queries

Successfully verified:
- metrics scraping
- multi-environment monitoring
- centralized logging
- live log ingestion
- application-level telemetry
- Kubernetes metadata enrichment

---

## Operational Outcomes

[intro] 1 line

[Content] bullet points

## ⚔️ Challenges & Solutions

[intro] 1 line

### 1. Prometheus Annotations Were Not Being Scraped

- **⚔️ Challenge:**\
Initially, application pods exposed Prometheus annotations like:

  ```yaml
  prometheus.io/scrape: "true"
  prometheus.io/port: "8080"
  prometheus.io/path: "/actuator/prometheus"
  ```

  However, no application metrics appeared in Prometheus targets.

- **🔍 Root Cause:**\
  The cluster was deployed using `kube-prometheus-stack`, which relies on the **Prometheus Operator** and primarily discovers targets using:

  - `ServiceMonitor`
  - `PodMonitor`

  instead of annotation-based scraping.

- **✅ Solution:**\
  Implemented dedicated `ServiceMonitor` resources for each microservice.

  ```yaml
  apiVersion: monitoring.coreos.com/v1
  kind: ServiceMonitor
  ```

  **This enabled:**
  - Kubernetes-native metric discovery
  - Declarative monitoring configuration
  - Automatic target generation by Prometheus Operator

---

### 2. ServiceMonitor Validation Failure

- **⚔️ Challenge:**\
  ArgoCD synchronization failed with:

  ```text
  spec.endpoints[0].port in body must be of type string
  ```

- **🔍 Root Cause:**\
  `ServiceMonitor.endpoints.port` was incorrectly configured using an integer:

  ```yaml
  port: 8080
  ```

  instead of a Service port name.

- **✅ Solution:**\
  Updated ServiceMonitor configuration to use named ports:

  ```yaml
  port: http
  ```

  which matched the Kubernetes Service port definition.

### 3. Label-Based Environment Monitoring

- **⚔️ Challenge:**\
  Metrics and logs needed to be separated cleanly between:

  - dev
  - stage
  - prod

  environments.

- **🔍 Root Cause:**\
  Without environment labels, observability data becomes difficult to filter and query across multiple namespaces.

- **✅ Solution:**\
  Implemented namespace-driven environment labels through Helm templating.

  ```yaml
  env: {{ .Release.Namespace }}
  ```

  This enabled environment-aware queries such as:

  ```promql
  {env="stage"}
  ```

  and:

  ```logql
  {env="prod"}
  ```

### 4. Loki + Promtail Centralized Logging Integration

- **⚔️ Challenge:**\
  Implementing centralized logging with:

  - Loki
  - Promtail
  - Grafana

  while maintaining Kubernetes-native discovery and metadata labeling.

- **🔍 Root Cause:**\
  Promtail requires:

  - proper Kubernetes service discovery
  - relabeling
  - metadata enrichment
  - filesystem log access

  for accurate log ingestion.

- **✅ Solution:**\
  Configured Promtail with:

  - Kubernetes pod discovery
  - relabeling
  - namespace labels
  - app labels
  - container labels

  ```yaml
  relabel_configs:
    - source_labels:
        - __meta_kubernetes_namespace
      target_label: namespace
  ```

  This enabled:

  - centralized logging
  - label-based filtering
  - multi-environment log queries
  - Grafana Explore integration

### 5. Promtail CrashLoopBackOff (`too many open files`)

- **⚔️ Challenge:**\
  Promtail repeatedly crashed with:

  ```text
  failed to make file target manager: too many open files
  ```

- **🔍 Root Cause:**\
  Promtail creates filesystem watchers for Kubernetes container logs.  
  The node-level Linux inotify limits were too low for:

  - multiple namespaces
  - monitoring stack logs
  - microservices
  - cluster-wide log discovery

- **✅ Solution:**\
  Increased Linux kernel inotify limits:

  ```bash
  fs.inotify.max_user_instances=10000
  fs.inotify.max_user_watches=1048576
  ```

  <details>
  <summary>
  Make the changes permanent
  </summary>

  The `sysctl -w` command only changes the limits in memory. If your node reboots, the error will return. To make them permanent:

  1. Open the configuration file:

  ```bash
  sudo nano /etc/sysctl.conf

  ```

  1. Add these lines to the bottom of the file:

  ```text
  fs.inotify.max_user_instances=10000
  fs.inotify.max_user_watches=1048576

  ```

  1. Save and exit, then apply them:

  ```bash
  sudo sysctl -p

  ```

  </details>

  **Additionally:**\
  optimized Promtail discovery scope to reduce unnecessary log ingestion.

  This resolved:

  - Promtail CrashLoopBackOff
  - file descriptor exhaustion
  - filesystem watcher saturation

### 6. Multi-Environment Observability Architecture

- **⚔️ Challenge:**\
  Avoid repetitive monitoring manifests for every microservice and needed production-oriented observability across:

  - multiple namespaces
  - multiple environments
  - multiple microservices

- **🔍 Root Cause:**\
  Hardcoded monitoring resources increase operational overhead and reduce scalability.

- **✅ Solution:**\
  Implemented reusable Helm templating for:

  - labels
  - Services
  - ServiceMonitors
  - environment-aware metadata

  This enabled:

  - reusable deployment patterns
  - scalable monitoring architecture
  - cleaner GitOps workflows

## What I Learned

[intro] 1 line

[Content] bullet points

## Why This Matters

[intro] 1 line

[Content] bullet points

## What's Next

[intro] 1 line

[Content] bullet points

## Final Thoughts

[Outro] 2 lines
