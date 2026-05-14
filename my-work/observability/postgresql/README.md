# 🚀 PostgreSQL Exporter from Scratch

Built a production-oriented PostgreSQL monitoring setup from scratch using Prometheus, Kubernetes, Helm, and ArgoCD with automated multi-environment observability.

## Architecture

![alt text](screenshots/Arch.jpg)

## 📑 Table of Contents

1. [Overview](#-overview)
2. [What this Project Demonstrates](#-what-this-project-demonstrates)
3. [Architectural Decision](#️-architectural-decision)
4. [My Implementations](#️-my-implementations)
5. [Challenges & Solutions](#️-challenges-and-solutions)
6. [What I Learned](#-what-i-learned)
7. [What's Next](#-whats-next)
8. [Final thoughts](#-final-thoughts)

## 📌 Overview

This project implements PostgreSQL monitoring inside Kubernetes using `postgres-exporter`, Prometheus, Helm, and GitOps workflows.

### Key Highlights

- Built exporter setup completely from scratch
- Automated monitoring deployment using Helm and ArgoCD
- Implemented multi-environment observability
- Validated metrics in Prometheus and Grafana

## 🎯 What this Project Demonstrates

This project demonstrates practical Kubernetes observability, monitoring automation, and production troubleshooting skills.

### Core Demonstrations

- Prometheus exporter integration
- Kubernetes ServiceMonitor discovery
- Helm templating and reusable deployments
- GitOps workflows using ArgoCD
- Multi-environment monitoring strategy
- Production debugging and troubleshooting

## 🏗️ Architectural Decision

One of the major implementation decisions was selecting the correct exporter architecture for production-grade monitoring.

### Architecture Options Evaluated

#### 🌐 Option 1: `/probe` Based Architecture

- A centralized exporter scrapes multiple PostgreSQL instances dynamically using Prometheus relabeling and probe configurations.

  **Advantages**

  - Single exporter can monitor multiple PostgreSQL instances
  - Lower container and pod resource consumption
  - Centralized metrics collection approach
  - Easier to scale exporter management itself

  **Disadvantages**

  - Complex Prometheus relabeling configuration
  - Higher operational complexity
  - Difficult debugging and troubleshooting
  - More fragile in multi-environment setups
  - Increased dependency on dynamic target configuration
  - Single point of failure:
    - If exporter fails, monitoring for all databases is impacted
  - Less predictable behavior during production scaling

#### 📊 Option 2: `/metrics` Based Architecture

- Dedicated PostgreSQL exporter deployed alongside each PostgreSQL environment.

  **Advantages**

  - Simpler and cleaner implementation
  - Easier debugging and operational management
  - Environment-level isolation
  - Better production reliability
  - Stable Prometheus target discovery
  - Failure isolation:
    - If one exporter fails, other environments continue exposing metrics
  - Easier integration with Helm and ArgoCD workflows
  - More maintainable in GitOps-based infrastructure

  **Disadvantages**

  - Requires one exporter per PostgreSQL instance/environment
  - Slightly higher resource consumption
  - More Kubernetes objects to manage

### ✅ Final Decision

Selected the `/metrics` architecture due to its:

- Higher production reliability
- Better fault isolation
- Operational simplicity
- Easier troubleshooting
- Better compatibility with GitOps and multi-environment Kubernetes deployments

This approach aligned better with real-world production engineering practices and long-term maintainability goals.

## ⚙️ My Implementations

1. Installed the monitoring stack using Helm with the `kube-prometheus-stack` chart

    ```bash
    helm upgrade --install kube-prom-stack prometheus-community/kube-prometheus-stack \
        -n "${NAMESPACE}" \
        -f "${SCRIPT_DIR}/values-monitoring.yaml"
    ```

2. Designed and implemented PostgreSQL monitoring components completely from scratch
  
    - PostgreSQL Exporter Deployment
    - Service
    - ServiceMonitor
    - Secret

3. Initially implemented and validated the exporter in a single environment to verify
  
    - Database connectivity
    - Metrics exposure

      ![alt text](screenshots/ss07.png)

    - Prometheus target discovery

      ![alt text](screenshots/ss06.png)

    - Exporter stability
    - Grafana dashboard integration

      ![alt text](screenshots/ss05.png)

4. Troubleshot and resolved multiple real-world issues during implementation including:

    - Incorrect exporter configuration
    - Prometheus target discovery failures
    - ServiceMonitor label mismatches
    - PostgreSQL authentication problems

5. Converted the implementation into reusable Helm templates for standardized deployments.

    ![alt text](screenshots/ss03.png)

6. Integrated PostgreSQL monitoring directly into the application deployment layer.

7. Enabled fully automated multi-environment deployment using:
  
    - Helm charts
    - ArgoCD
    - ApplicationSet

8. Achieved environment-level observability for:
  
    - Development
    - Staging
    - Production

9. Validated metrics collection successfully in:
  
    - Prometheus UI
    - Grafana dashboards

10. Integrated Grafana PostgreSQL monitoring dashboard:
  
    - **Grafana Dashboard ID:** `9628`
    - Dashboard commonly used for PostgreSQL monitoring with `postgres_exporter`

## 🛠️ Challenges and Solutions

### 🔀 1. Kubernetes Service and Exporter Architecture Confusion

- **Challenge:**\
Initial confusion regarding why separate Services were required for:

  - PostgreSQL
  - postgres-exporter

- **Root Cause:**\
Exporter communication flow contains two independent networking paths:

  - exporter → PostgreSQL
  - Prometheus → exporter

  Each requires separate Service responsibilities.

- **Solution:**\
Implemented correct architecture:

  ```text
  postgres-exporter
          ↓
  orders-dev-headless:5432
          ↓
  PostgreSQL StatefulSet
  ```

  and:

  ```text
  Prometheus
          ↓
  postgres-exporter-service:9187
          ↓
  postgres-exporter pod
  ```

### ❌ 2. Exporter Connecting to Wrong Service

- **Challenge:**\
Exporter continuously failed with:

  ```text
  connection timed out
  ```

  and `/metrics` endpoint became unresponsive.

- **Root Cause:**\
Exporter was incorrectly configured to connect to the application Service:

  ```text
  orders-dev-service:8080
  ```

  instead of the PostgreSQL Service:

  ```text
  orders-dev-headless:5432
  ```

  DNS resolution succeeded, but traffic was routed to the application instead of PostgreSQL.

- **Solution:**\
Updated exporter `DATA_SOURCE_NAME` to use the PostgreSQL headless Service:

  ```text
  postgresql://orders_user:password@orders-dev-headless.dev.svc.cluster.local:5432/orders?sslmode=disable
  ```

### 🌍 3. Exporter Unable to Resolve PostgreSQL Host

- **Challenge:**\
`postgres-exporter` failed with DNS resolution errors:

  ```text
  lookup orders-dev-db.dev.svc.cluster.local: no such host
  ```

- **Root Cause:**\
Exporter was configured with an incorrect Kubernetes Service hostname. The Service selector label was mistakenly used instead of the actual Kubernetes Service name.

- **Solution:**\
Verified available Services using:

  ```bash
  kubectl get svc -n dev
  ```

  Updated exporter connection string to use the correct PostgreSQL headless Service:

  ```text
  orders-dev-headless.dev.svc.cluster.local
  ```

### 🔐 4. PostgreSQL Monitoring Permission Issues

- **Challenge:**\
Exporter connected to PostgreSQL but metric collection behavior remained unstable.

- **Root Cause:**\
Monitoring user lacked required monitoring privileges for PostgreSQL system views.

- **Solution:**\
Granted PostgreSQL monitoring role:

  ```sql
  GRANT pg_monitor TO orders_user;
  ```

  This enabled exporter access to:

  - `pg_stat_database`
  - `pg_stat_activity`
  - monitoring views
  - internal database statistics

### 🎯 5. ServiceMonitor Discovery Validation

- **Challenge:**\
Needed to validate whether Prometheus was successfully scraping exporter metrics.

- **Solution:**\
Verified:

  - exporter Service endpoints
  - ServiceMonitor configuration
  - Prometheus targets
  - `/metrics` endpoint accessibility

  Validated exporter health using:

  ```text
  pg_up 1
  ```

  which confirmed successful PostgreSQL connectivity and metrics collection.

## 🧠 What I Learned

This project improved my understanding of Kubernetes monitoring architecture, Prometheus discovery workflows, and production-grade observability design.

### Major Learnings

- `/probe` vs `/metrics` architecture differences
- Kubernetes Service and DNS behavior
- Prometheus target discovery
- ServiceMonitor configuration
- PostgreSQL monitoring permissions
- GitOps-based monitoring deployments
- Fault isolation and monitoring reliability

## 🚀 What's Next

Moving forward, this setup will be extended with:

1. Implement centralized logging using **`Loki`**
2. Add alerting and notification integrations using **`Email/Slack`**
3. Provision infrastructure using **`Terraform`**
4. Fully automate the workflow from **`terraform apply`** to **application deployment**

## 💭 Final Thoughts

This project was a strong hands-on learning experience in building production-grade observability systems using Kubernetes and Prometheus.

Beyond simply deploying an exporter, the implementation required architectural decision-making, debugging real infrastructure issues, automating deployments, and designing monitoring workflows that remain reliable across multiple environments.
