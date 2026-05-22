# 🚀 Observability layer Implementation

Challenges and Solutions section only

## 📑 Table of Contents [(Read full contect here)](./README.md)

- [Challenges & Solutions]()
  - [PostgreSQL Exporter]()
  - [Prometheus Metrics Collection]()
  - [Loki Log Aggregation]()
  - [Alerting Pipeline]()
  - [Multi-Environment Monitoring]()
  - [GitOps CD with ArgoCD]()

## ⚔️ Challenges & Solutions

This project involved building and operating a production-style Kubernetes observability platform, requiring deep troubleshooting across networking, GitOps, monitoring, logging, alerting, RBAC, and deployment orchestration layers.

### 1. PostgreSQL Exporter

- ### 🔀 1.1 Kubernetes Service and Exporter Architecture Confusion

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

---

- ### ❌ 1.2 Exporter Connecting to Wrong Service

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

---

- ### 🌍 1.3 Exporter Unable to Resolve PostgreSQL Host

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

---

- ### 🔐 1.4 PostgreSQL Monitoring Permission Issues

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

---

### 2. Prometheus Metrics Collection

- ### 2.1 ServiceMonitor Validation Failure

  - **⚔️ Challenge:**\
    ArgoCD synchronization failed with:

    ```text
    spec.endpoints[0].port in body must be of type string
    ```

  - **🔍 Analysis:**\
    Prometheus Operator validates `ServiceMonitor` resources against a strict schema. During synchronization, ArgoCD rejected the manifest because the `port` field expected a Kubernetes Service port name rather than a numeric container port.

  - **🧠 Root Cause:**\
    `ServiceMonitor.endpoints.port` was incorrectly configured using an integer:

    ```yaml
    port: 8080
    ```

    instead of a Service port name.

  - **✅ Solution:**\
    Updated the `ServiceMonitor` configuration to use named ports:

    ```yaml
    port: http
    ```

    which matched the Kubernetes Service port definition.

    **This enabled:**

    - Successful ArgoCD synchronization
    - Proper Prometheus target discovery
    - Schema-compliant `ServiceMonitor` resources

  - **📚 Lesson Learned:**\
    In Kubernetes observability stacks, `ServiceMonitor.endpoints.port` must reference the Kubernetes Service port **name**, not the numeric container port. Aligning Service definitions and monitoring resources consistently helps avoid validation and synchronization failures.

---

- ### 2.2 Prometheus Annotations Were Not Being Scraped

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
    Implemented dedicated `ServiceMonitor` resources for each microservice and hemified it.

    ```yaml
    apiVersion: monitoring.coreos.com/v1
    kind: ServiceMonitor
    ```

    **This enabled:**
    - Kubernetes-native metric discovery
    - Declarative monitoring configuration
    - Automatic target generation by Prometheus Operator

    - **📚 Lesson Learned:**\
    Kubernetes observability behavior depends heavily on the monitoring architecture being used. In Prometheus Operator-based stacks, annotation-based scraping alone is insufficient; `ServiceMonitor` and `PodMonitor` resources become the primary mechanism for scalable, declarative target discovery.

---

- ### 🔁 2.3 Containers Restarting Repeatedly

  - **⚔️ Challenge:**\
    After introducing observability and metrics collection components, application pods started restarting continuously.

  - **🔍 Analysis:**\
    The additional metrics exporters and monitoring integrations increased the application's startup and stabilization time.

  - **🧠 Root Cause:**\
    The liveness probe configuration was too aggressive and started health checks before the application became fully stable.

  - **✅ Solution:**\
    Increased the liveness probe `initialDelaySeconds` to provide sufficient startup time before health checks began.

    **This enabled:**
    - Stable application initialization
    - Reduced unnecessary restarts
    - Improved pod lifecycle reliability

  - **📚 Lesson Learned:**\
    Overly aggressive liveness probes can unintentionally trigger restart loops. Probe timings should always align with realistic application startup behavior, especially after introducing monitoring, sidecars, or exporters.

---

### 3. Loki Log Aggregation

- ### 3.1 Promtail CrashLoopBackOff (`too many open files`)

  - **⚔️ Challenge:**\
    Promtail repeatedly crashed with:

    ```text
    failed to make file target manager: too many open files
    ```

  - **🔍 Analysis:**\
    Promtail dynamically watches Kubernetes container log files using Linux `inotify` watchers. As cluster-wide log discovery expanded across multiple namespaces and services, the number of filesystem watchers increased significantly, eventually exhausting the node's default kernel limits.

  - **🧠 Root Cause:**\
    Promtail creates filesystem watchers for Kubernetes container logs.
    The node-level Linux `inotify` limits were too low for:

    - multiple namespaces
    - monitoring stack logs
    - microservices
    - cluster-wide log discovery

  - **✅ Solution:**\
    Increased Linux kernel `inotify` limits:

    ```bash
    fs.inotify.max_user_instances=10000
    fs.inotify.max_user_watches=1048576
    ```

    <details>
    <summary>
    Make the changes permanent
    </summary>

    The `sysctl -w` command only changes the limits in memory. If your node reboots, the error will return. To make them permanent:

    - Open the configuration file:

      ```bash
      sudo nano /etc/sysctl.conf
      ```

    - Add these lines to the bottom of the file:

      ```text
      fs.inotify.max_user_instances=10000
      fs.inotify.max_user_watches=1048576
      ```

    - Save and exit, then apply them:

      ```bash
      sudo sysctl -p
      ```

    </details>

    **Additionally:**
    Optimized Promtail discovery scope to reduce unnecessary log ingestion and excessive filesystem watchers.

    **This resolved:**

    - Promtail `CrashLoopBackOff`
    - File descriptor exhaustion
    - Filesystem watcher saturation
    - Unstable log collection behavior

  - **📚 Lesson Learned:**\
    Log aggregation systems operating at cluster scale can quickly exhaust default Linux kernel watcher limits. Production-grade observability setups should include proactive tuning of `inotify` and file descriptor limits, especially when using node-level agents like Promtail that monitor large numbers of container log files.

---

- ### 3.2 Loki + Promtail Centralized Logging Integration

  - **⚔️ Challenge:**\
    Implementing centralized logging with:

    - Loki
    - Promtail
    - Grafana

    while maintaining Kubernetes-native discovery and metadata labeling.

  - **🔍 Analysis:**\
    Building an effective centralized logging pipeline in Kubernetes requires more than simple log collection. Logs must be dynamically discovered, enriched with Kubernetes metadata, and labeled consistently so they can be queried efficiently across namespaces, applications, and environments within Grafana.

  - **🧠 Root Cause:**\
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

    **This enabled:**

    - Centralized logging across the cluster
    - Label-based filtering
    - Multi-environment log queries
    - Grafana Explore integration
    - Easier debugging and troubleshooting workflows

  - **📚 Lesson Learned:**\
    Centralized logging becomes significantly more powerful when logs are enriched with Kubernetes metadata. Proper relabeling and structured labeling strategies are critical for scalable observability, efficient querying, and operational visibility in production-grade Kubernetes environments.

---

### 4. Alerting Pipeline

- ### 4.1 Alertmanager Did Not Deploy Initially

  - **⚔️ Challenge:**\
    Alertmanager resources were deployed through the `kube-prometheus-stack`, but the Alertmanager Pod did not appear in the cluster.

  - **🔍 Analysis:**\
    The Prometheus Operator validates Alertmanager configuration before creating underlying Kubernetes resources such as Secrets, StatefulSets, and Pods. If the configuration contains validation or structural issues, the Operator silently refuses to proceed with deployment, resulting in missing Alertmanager Pods even though Helm deployment itself appears successful.

  - **🧠 Root Cause:**\
    Multiple configuration issues prevented the Prometheus Operator from successfully reconciling the Alertmanager Custom Resource:

    - Receiver configuration existed but contained no valid integration
    - `storageClassName` was not explicitly defined for persistent storage
    - YAML indentation inconsistencies broke Helm value rendering

    Specifically:

    ```yaml
    receivers:
      - name: default-receiver
    ```

    created an invalid Alertmanager configuration because the receiver had no integration defined.

    Additionally:

    ```yaml
    volumeClaimTemplate:
    ```

    lacked an explicit:

    ```yaml
    storageClassName:
    ```

    which caused PVC provisioning issues on the cluster.

  - **✅ Solution:**\
    Fixed all validation and configuration issues by:

    - Adding a placeholder `webhook_config` to satisfy Alertmanager receiver validation

    - Explicitly defining:

      ```yaml
      storageClassName: standard
      ```

    - Correcting YAML indentation and commented block alignment

    This allowed the Prometheus Operator to:

    - Validate the Alertmanager configuration
    - Generate the Alertmanager Secret
    - Create the StatefulSet
    - Successfully deploy the Alertmanager Pod

    **This enabled:**

    - Successful Alertmanager deployment
    - Proper StatefulSet creation
    - Persistent storage provisioning
    - Stable alerting infrastructure initialization

  - **📚 Lesson Learned:**\
    Operator-based Kubernetes platforms rely heavily on strict configuration validation before resource reconciliation. Even small YAML formatting issues, incomplete receiver definitions, or missing storage specifications can completely block deployment pipelines without immediately obvious errors. Understanding the reconciliation flow of Kubernetes Operators is critical for troubleshooting production-grade observability stacks.

---

- ### 4.2 Alertmanager Status Columns Showing Blank

  - **⚔️ Challenge:**\
    The following command did not show `AVAILABLE` or `READY` values for Alertmanager:

    ```bash
    kubectl get alertmanager -n observability
    ```

  - **🔍 Analysis:**\
    Initial troubleshooting included:

    ```bash
    kubectl get pods -n observability
    kubectl logs -n observability <pod-name>
    ```

    No pod failures, crash loops, or log errors were found. The Alertmanager UI was accessible, alerts were being routed correctly, and both email and Slack notifications were functioning as expected.

  - **? Root Cause:**\
    The blank `AVAILABLE` and `READY` columns were not caused by an Alertmanager failure.

    These columns are custom printer columns defined by the Prometheus Operator CRD, not native Kubernetes status fields. The values are derived from the `status:` section of the Alertmanager Custom Resource.

    Since the operator was not populating those specific status fields, `kubectl` displayed empty values even though the Alertmanager stack was fully operational.

  - **✅ Solution:**\
    Validated the actual runtime state instead of relying solely on CRD printer columns:

    ```bash
    kubectl get pods -n observability
    kubectl get sts -n observability
    ```

    **Confirmed that:**
    - StatefulSets were healthy
    - Pods were running correctly
    - Alertmanager UI was operational
    - Alerts were firing successfully
    - Notification pipelines were working end-to-end

    The issue was ultimately identified as a CRD/operator status-reporting limitation rather than an infrastructure or deployment problem.

  - **📚 Lesson Learned:**\
    *This troubleshooting process took nearly a full day and reinforced an important operational lesson: **Kubernetes UI/status output should always be validated against the actual runtime behavior of the system.***

---

### 5. Multi-Environment Monitoring

- ### 5.1 Label-Based Multi-Environment Monitoring

  - **⚔️ Challenge:**\
    Metrics and logs needed to be separated cleanly between:

    - dev
    - stage
    - prod

    environments.

  - **🔍 Analysis:**\
    In multi-environment Kubernetes clusters, observability data from different namespaces can quickly become mixed together. Without standardized environment labeling, filtering metrics and logs becomes inefficient, making troubleshooting, debugging, and operational analysis significantly harder.

  - **🧠 Root Cause:**\
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

    **This enabled:**

    - Clean environment-level observability separation
    - Faster troubleshooting workflows
    - Safer production monitoring
    - Simplified cross-environment filtering
    - Consistent labeling across metrics and logs

  - **📚 Lesson Learned:**\
    Consistent labeling is foundational for scalable observability. Environment-aware metadata should be standardized early in platform design to support efficient querying, operational clarity, and long-term maintainability across multi-environment Kubernetes deployments.

---

### 6. GitOps CD with ArgoCD

- ### 6.1 Architectural Refactor for GitOps Adoption

  - **⚔️ Challenge:**\
    Initial infrastructure provisioning relied on sequential Bash scripts for ArgoCD, applications, monitoring, and logging deployments. While functional during iterative development, the approach was not aligned with GitOps workflows.

  - **🔍 Analysis:**\
    To implement GitOps properly, ArgoCD needed to become the single deployment controller responsible for continuous reconciliation and application lifecycle management.

  - **🧠 Root Cause:**\
    The repository structure was originally optimized for imperative script-based deployments rather than declarative GitOps operations.

  - **✅ Solution:**\
    Refactored the repository architecture to support GitOps-driven deployments through ArgoCD.

    **This enabled:**
    - Declarative infrastructure and application management
    - Cleaner deployment workflows
    - Easier environment scalability
    - Centralized synchronization via ArgoCD

  - **📚 Lesson Learned:**\
    Design repositories around the target operational model from the beginning. Retrofitting architecture later becomes significantly more expensive.

---

- ### 6.2 ArgoCD Project Permission Segmentation

  - **⚔️ Challenge:**\
    All deployments were initially running under ArgoCD's default project with broad cluster-wide permissions. I wanted to implement stricter project isolation and resource scoping.

  - **🔍 Analysis:**\
    Production-grade GitOps requires separation between cluster-scoped and namespace-scoped resources to enforce security boundaries and reduce blast radius.

  - **🧠 Root Cause:**\
    The repository lacked architectural separation between infrastructure, platform, observability, and application layers, making Principle of Least Privilege (PoLP) implementation difficult.

  - **✅ Solution:**\
    Re-architected the repository into dedicated deployment layers:
    - **Infrastructure Layer** → Kind, Terraform
    - **Platform Layer** → ESO and shared platform services
    - **Observability Layer** → Prometheus stack, exporters, logging
    - **Application Layer** → Business applications and services

    Implemented ArgoCD Projects with scoped permissions and controlled deployment boundaries.

    **This enabled:**
    - Principle of Least Privilege (PoLP)
    - Clear separation of concerns
    - Safer RBAC implementation
    - Better dependency management between layers
    - Production-grade GitOps organization

  - **📚 Lesson Learned:**\
    Strong architecture simplifies security, scalability, and operational control.

---

- ### 6.3 Layered Deployment Synchronization Failure

  - **⚔️ Challenge:**\
    ArgoCD was deploying all layers simultaneously despite sync wave configuration. Applications eventually recovered through Kubernetes reconciliation, but deployment ordering was unreliable.

  - **🔍 Analysis:**\
    Sync waves alone were insufficient because ArgoCD could not accurately determine application health states during deployment.

  - **🧠 Root Cause:**\
    Custom applications lacked health checks, preventing ArgoCD from validating readiness before progressing to dependent layers.

  - **✅ Solution:**\
    Implemented custom Lua health checks for ArgoCD to enforce proper health validation and layered deployment sequencing.

    **This enabled:**
    - Deterministic deployment ordering
    - Safer progressive rollouts
    - Reduced deployment instability
    - Reliable dependency-aware synchronization

  - **📚 Lesson Learned:**\
    Deployment orchestration is only as reliable as the health signals provided to the controller.

---

- ### 6.4 Lua Health Checks Not Taking Effect

  - **⚔️ Challenge:**\
    After implementing Lua health checks, ArgoCD still continued deploying layers in parallel.

  - **🔍 Analysis:**\
    The Lua scripts were valid, but ArgoCD was not applying the updated health configurations.

  - **🧠 Root Cause:**\
    ArgoCD Repo Server and ArgoCD Server required restarts to reload the newly applied project configurations and Lua health scripts.

  - **✅ Solution:**\
    Updated the ArgoCD installation automation to automatically restart:
    - ArgoCD Repo Server
    - ArgoCD Server

    after project and health configuration changes.

    **This enabled:**
    - Reliable health check enforcement
    - Consistent layered deployments
    - Fully automated configuration propagation

  - **📚 Lesson Learned:**\
    Configuration changes are ineffective unless the consuming services reload them correctly.

---

- ### 6.5 ArgoCD ServiceMonitors Missing in Prometheus

  - **⚔️ Challenge:**\
    ArgoCD ServiceMonitors existed in Kubernetes but were not visible in Prometheus, resulting in missing metrics collection.

  - **🔍 Analysis:**\
    No immediate errors were visible. After reapplying configurations post-monitoring stack deployment, the ServiceMonitors appeared and metrics collection resumed.

  - **🧠 Root Cause:**\
    ArgoCD attempted to create ServiceMonitor resources before the Prometheus Operator CRDs were installed. Since the CRDs did not yet exist, Kubernetes silently ignored the resources.

  - **✅ Solution:**\
    Removed ServiceMonitor creation from the ArgoCD Helm values configuration and moved monitoring resources into the dedicated Observability layer. Deployment sequencing ensured ServiceMonitors were only applied after Prometheus Operator CRDs became available.

    **This enabled:**
    - Reliable Prometheus target discovery
    - Stable metrics collection
    - Proper dependency-aware resource deployment
    - Cleaner observability architecture

  - **📚 Lesson Learned:**\
    CRD-dependent resources must only be deployed after their controllers and CRDs are fully available.
