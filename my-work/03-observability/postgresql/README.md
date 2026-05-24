# 🚀 PostgreSQL Exporter from Scratch

Built a production-oriented PostgreSQL monitoring setup from scratch using Prometheus, Kubernetes, Helm, and ArgoCD with automated multi-environment observability.

## 📑 Table of Contents

1. [Overview](#-overview)
2. [Architecture](#️-architecture)
3. [Core Features](#-core-features)
4. [Implementation Highlights](#️-implementation-highlights)
5. [Architectural Decisions](#-architectural-decisions)
6. [Operational Outcomes](#-operational-outcomes)
7. [Challenges & Solutions](#️-challenges-and-solutions)
8. [Key Learnings](#-key-learnings)
9. [Future Improvements](#-future-improvements)

## 📖 Overview

This project implements PostgreSQL monitoring inside Kubernetes using `postgres-exporter`, Prometheus, Helm, and GitOps workflows.

- Built exporter setup completely from scratch
- Automated monitoring deployment using Helm and ArgoCD
- Implemented multi-environment observability
- Validated metrics in Prometheus and Grafana

## 🏗️ Architecture

![alt text](screenshots/Arch.jpg)

## 🎯 Core Features

This project demonstrates practical Kubernetes observability, monitoring automation, and production troubleshooting skills.

- Prometheus exporter integration
- Kubernetes ServiceMonitor discovery
- Helm templating and reusable deployments
- GitOps workflows using ArgoCD
- Multi-environment monitoring strategy
- Production debugging and troubleshooting

## ⚙️ Implementation Highlights

1. Installed the monitoring stack using Helm with the `kube-prometheus-stack` chart

    ```bash
    helm upgrade --install kube-prom-stack prometheus-community/kube-prometheus-stack \
        -n "${NAMESPACE}" \
        -f "values-monitoring.yaml"
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

## 🧠 Architectural Decisions

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

## 📈 Operational Outcomes

This implementation resulted in a reusable, GitOps-driven PostgreSQL monitoring workflow for Kubernetes environments.

- Automated PostgreSQL metrics collection using `postgres-exporter`
- Enabled Prometheus monitoring through `ServiceMonitor`
- Implemented reusable Helm-based deployments
- Integrated monitoring into ArgoCD GitOps workflows
- Achieved environment-aware observability across `dev`, `stage`, and `prod`
- Validated metrics visibility in Prometheus and Grafana

## 🛠️ Challenges and Solutions

### 🔀 1. Kubernetes Service and Exporter Architecture Confusion

- **⚔️ Challenge:**\
    Initial confusion regarding why separate Services were required for:

  - PostgreSQL
  - postgres-exporter
  
- **🔍 Analysis:**\
    To understand the problem deeply, I created the Architecture diagram

- **🧠 Root Cause:**\
    Exporter communication flow contains two independent networking paths:

- exporter → PostgreSQL
- Prometheus → exporter

  Each requires separate Service responsibilities.

- **✅ Solution:**\
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
  
    **This enabled:**

  - Clear separation of exporter traffic and database traffic
  - Proper Prometheus metrics scraping
  - Correct Kubernetes Service design for observability workflows
  - Better understanding of exporter-based monitoring architecture
  - Reliable PostgreSQL metrics collection through Prometheus

- **📚 Lesson Learned:**\
  Observability components often introduce additional network paths and service boundaries. Understanding the communication flow between exporters, applications, and monitoring systems is critical for designing correct Kubernetes Service architectures and avoiding misconfigured monitoring pipelines.

### ❌ 2. Exporter Connecting to Wrong Service

- **⚔️ Challenge:**\
    Exporter continuously failed with:

    ```text
    connection timed out
    ```

    and `/metrics` endpoint became unresponsive.

- **🔍 Analysis:**\
    I was using wrong service and port to parse metrics

- **🧠 Root Cause:**\
    Exporter was incorrectly configured to connect to the application Service:

    ```text
    orders-dev-service:8080
    ```

    instead of the PostgreSQL Service:

    ```text
    orders-dev-headless:5432
    ```

    DNS resolution succeeded, but traffic was routed to the application instead of PostgreSQL.

- **✅ Solution:**\
    Updated exporter `DATA_SOURCE_NAME` to use the PostgreSQL headless Service:

    ```text
    postgresql://orders_user:password@orders-dev-headless.dev.svc.cluster.local:5432/orders?sslmode=disable
    ```

    **This enabled:**

  - Successful PostgreSQL metrics collection
  - Stable exporter connectivity
  - Functional `/metrics` endpoint exposure
  - Proper service-to-service communication inside Kubernetes
  - Reliable Prometheus scraping workflow

- **📚 Lesson Learned:**\
    In Kubernetes environments, successful DNS resolution does not guarantee correct service routing. Exporters must target the actual backend service they are designed to monitor, otherwise metrics pipelines can fail silently despite apparently healthy network connectivity.

### 🌍 3. Exporter Unable to Resolve PostgreSQL Host

- **⚔️ Challenge:**\
    `postgres-exporter` failed with DNS resolution errors:

- **🔍 Analysis:**\
    Ran:

    ```text
    lookup orders-dev-db.dev.svc.cluster.local
    ```  

    Result: no such host
  
- **🧠 Root Cause:**\
    Exporter was configured with an incorrect Kubernetes Service hostname. The Service selector label was mistakenly used instead of the actual Kubernetes Service name.

- **✅ Solution:**\
    Verified available Services using:

    ```bash
    kubectl get svc -n dev
    ```

    Updated exporter connection string to use the correct PostgreSQL headless Service:

    ```text
    orders-dev-headless.dev.svc.cluster.local
    ```

- **📚 Lesson Learned:**\
    Kubernetes DNS resolution depends entirely on actual Service resource names, not labels or selectors. Verifying Service discovery directly through Kubernetes resources is essential when troubleshooting inter-service communication and exporter connectivity issues.

### 🔐 4. PostgreSQL Monitoring Permission Issues

- **⚔️ Challenge:**\
    Exporter connected to PostgreSQL but metric collection no working.

- **🔍 Analysis:**\
    Exporter was successfully establishing TCP connectivity with PostgreSQL, but metric queries against PostgreSQL monitoring views were failing due to insufficient database permissions.

    Connection-level health appeared normal, however exporter logs showed authorization-related failures when accessing internal statistics views.

- **🧠 Root Cause:**\
    Monitoring user lacked required monitoring privileges for PostgreSQL system views.

- **✅ Solution:**\
    Granted PostgreSQL monitoring role:

    ```sql
    GRANT pg_monitor TO orders_user;
    ```

    This enabled exporter access to:

  - `pg_stat_database`
  - `pg_stat_activity`
  - monitoring views
  - internal database statistics
  
    **This enabled:**

  - Successful PostgreSQL metrics exposure
  - Access to internal database performance statistics
  - Stable Prometheus scraping
  - Improved database observability
  - Visibility into PostgreSQL runtime activity and health

- **📚 Lesson Learned:**\
      Successful database connectivity alone is insufficient for observability workflows. Monitoring systems often require elevated read permissions to access internal performance and statistics views needed for production-grade telemetry collection.

## 🎓 Key Learnings

This project improved my understanding of Kubernetes monitoring architecture, Prometheus discovery workflows, and production-grade observability design.

- `/probe` vs `/metrics` architecture differences
- Kubernetes Service and DNS behavior
- Prometheus target discovery
- ServiceMonitor configuration
- PostgreSQL monitoring permissions
- GitOps-based monitoring deployments
- Fault isolation and monitoring reliability

## 🚀 Future Improvements

Moving forward, this setup will be extended with:

1. Implement centralized logging using **`Loki`**
2. Add alerting and notification integrations using **`Email/Slack`**
3. Provision infrastructure using **`Terraform`**
4. Fully automate the workflow from **`terraform apply`** to **application deployment**
