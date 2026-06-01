# ⚙️ Productionizing a Microservices Application (Reverse-Engineered) | In Progress

> [!NOTE]
> This project is based on an existing application that I reverse-engineered and enhanced — [original repo](https://github.com/aws-containers/retail-store-sample-app)

## 🚀 Project Goal

*The goal of this project is not just deployment, but to build a production-like DevOps ecosystem independently that showcases a strong understanding of real-world DevOps practices, including:*

- **Containerization**
- **Kubernetes Orchestration**
- **CI/CD Pipelines**
- **Real-Time Alerts**
- **Infrastructure as Code (IaC)**
- **Monitoring**
- **Automation**

## 📑 Table of Contents

- **[Objectives and Sub-goals](#-objectives-and-sub-goals)**
- **[What This Project Demonstrates](#-what-this-project-demonstrates)**
- **[Why I Chose This Project](#-why-i-chose-this-project)**
- **[Key Improvements Over Original System](#-key-improvements-over-original-system)**
- **[Current Status](#-current-status)**
- **[Key Engineering Work](#️-key-engineering-work)**

## 🎯 Objectives and Sub-goals

1. **📚 To understand the application architecture:**  
*Analyze and reverse-engineer the microservices architecture to gain a deep understanding of how the system works.*

2. **🐳 Containerization:**  
    - *Containerize all services using Docker.*
    - *Docker Compose Setup*
    - *Run and manage multi-container application locally using **`Docker Compose`.***

3. **☸️ Kubernetes Deployment:**  
*Deploy and manage the application in a **`Kubernetes cluster.`***

4. **ↈ CI/CD Implementation:**  
*Build complete **`CI/CD`** pipelines using:*
    - ***`GitOps`** approach **`(ArgoCD)`***
    - ***`Jenkins approach`** (traditional pipeline)*

5. **📧 Notification System:**  
*Integrate **`email and Slack notifications`** for pipeline events and alerts.*

6. **🏗️ Infrastructure as Code (IaC):**  
*Provision infrastructure using **`Terraform`** for automated and consistent environments.*

7. **📊 Observability:**  
*Implement monitoring and visualization using:*
    - ***`Prometheus`** (metrics collection)*
    - ***`Grafana`** (dashboard visualization)*

8. **⚡ Finally Full Automation:**  
*Automate complete infrastructure and application setup with `terraform apply`*

## 🧠 What This Project Demonstrates

- **Designed and deployed** a production-like microservices system on Kubernetes
- Implemented secure, **cloud-native integrations** (DynamoDB, EBS, IAM)
- Applied **real-world DevOps** practices: containerization, orchestration, IaC, and GitOps
- Built systems with **security-first, scalability-aware, and failure-resilient design**
- **Debugged and stabilized** distributed systems across infra, networking, and application layers

## 🕵 Why I Chose This Project

### 🧗‍♂️ This project is intentionally outside my comfort zone

*I am primarily proficient in **`Python`** and **`JavaScript`**, and deploying applications using these technologies is something I can do with confidence. However, I wanted to challenge myself with something more complex and unfamiliar.*

**💡 That’s why I chose a different technology with microservices architecture.**

### 📌 At the time of starting this project

- *I had **`no prior experience with Java`***
- *The system consists of **`5 independent microservices`***
- *The architecture is significantly more complex than typical projects*

**🧩 Instead of avoiding this gap, I decided to use it as an opportunity to grow.**

---

# 🎯 Implementation highlights

* GitOps-driven continuous delivery using ArgoCD with ApplicationSets for scalable multi-environment deployments (`dev`, `stage`, `prod`)
* Modular Kubernetes platform architecture using Helm, Helmfile, and Kustomize-based configuration management
* Layered separation of platform and application infrastructure for scalable orchestration and maintainability
* Dependency-aware deployment workflows with reconciliation, drift correction, and self-healing mechanisms
* Secure cloud-native secret management using External Secrets Operator, IAM roles, and IMDSv2-based credential-less authentication
* Principle of Least Privilege (PoLP), RBAC-aware segmentation, and hardened non-root container security practices
* Stateful and stateless workload engineering using PostgreSQL StatefulSets, DynamoDB integration, and persistent EBS-backed storage
* Environment-isolated storage, monitoring, logging, and telemetry workflows for operational separation and observability
* Kubernetes-native service discovery, networking, and production-grade runtime optimization
* Distributed systems troubleshooting across Kubernetes, IAM, storage, networking, CRDs, Helm templating, and init-container workflows
* Architecture reverse-engineering, dependency analysis, and infrastructure simplification for production-ready microservices platforms
* End-to-end validation of scalable, failure-resilient, cloud-native deployment architectures aligned with real-world DevOps practices

## 📊 Current Status

- ✅ Microservices containerized and orchestrated (**Docker → Kubernetes**)
- ✅ **Stateful + stateless** services implemented with production patterns
- ✅ Secure **cloud integrations** (IAM, Secrets Manager, IMDSv2, DynamoDB, EBS)
- 🚧 GitOps (**ArgoCD**) in progress...

## ⚙️ Key Engineering Work

### 1. 🏗️ App Architecture [(read here)](./my-work/architecture/)

- **Reverse-engineered** 5-service microservices architecture
- Mapped **service communication, dependencies, and API flows**
- Analyzed stateless, Kubernetes-oriented design (**tmpfs-based**)

### 2. 📦 Containerzation with Docker [(read here)](./my-work/docker/)

- **Reverse-engineered Dockerfiles** across all services
- Optimized base image (**AL2023-minimal, −190MB**)
- **Maintained compatibility** (dnf + glibc)
- Enforced **non-root** container execution

### 3. 🐳 Running app with docker-compose [(read here)](./my-work/docker-compose/)

- Reverse-engineered multi-service **Compose** setup
- Mapped **env variables** and **service** dependencies
- Built **unified setup** with shared network
- Validated system via **health checks & E2E testing**

### 4. ☸️ Kubernetes Deployment (in parts ↴) [(read more)](./my-work/kubernetes/)

#### 4.1 - Individual Microservice-level operational validation & enhancements [(read here)](./my-work/kubernetes/ind-svc-test/)

- **Carts service** [(read here)](./my-work/kubernetes/ind-svc-test/cart-dynamodb-test/)

  - Integrated **AWS DynamoDB** (replaced in-memory storage)
  - Enforced **production-safe design** (disabled auto table creation)
  - Applied **least-privilege** access (IAM + K8s secrets)
  - Eliminated **race conditions & infra drift**

- **Orders service** [(read here)](./my-work/kubernetes/ind-svc-test/orders-postgreSQL-test/)

  - Implemented **persistent PostgreSQL** (PV/PVC on AWS EBS)
  - Designed **stateful** workload (StatefulSet + storage)
  - Secured volume access (**fsGroup**, non-root)
  - Ensured **data durability** across restarts

- **Catalog service** [(read here)](./my-work/kubernetes/ind-svc-test/catalog-test/)

  - Removed **MariaDB** dependency (in-memory design)
  - Simplified service architecture
  - Decoupled DB from service via **source code analysis**

- **Checkout service** [(read here)](./my-work/kubernetes/ind-svc-test/checkout-test/)

  - Removed **Redis** dependency (stateless workflow)
  - **Simplified** service architecture
  - Derived minimal runtime config via **source code analysis**

- **UI service** [(read here)](./my-work/kubernetes/ind-svc-test/ui-test/)

  - Made service **environment-agnostic**
  - Decoupled **observability** from application logic

#### 4.2 - Full app deployment on Kubernetes

- **helmfile deployment** [(read here)](./my-work/kubernetes/helmfile-deploy/)

  - Designed modular **Helm charts with environment-based configs**
  - Implemented secure secrets flow (**AWS Secrets Manager + ESO**)
  - Enabled **credential-less** AWS access via IMDSv2 (IAM roles, no static keys)
  - Orchestrated **dependency-aware** deployments with Helmfile
  - Validated full-stack deployment via **service-level testing**
  - Debugged complex issues (**CRDs, IAM policies, init containers, templating**)

- **ArgoCD deployment** [(read here)](./my-work/kubernetes/argocd-deploy/)

  - Extended the Kubernetes deployment into a full **GitOps-based continuous delivery workflow**
  - Built **multi-environment deployments** (`dev`, `stage`, `prod`) using ArgoCD ApplicationSets
  - Separated **platform and application layers** for cleaner orchestration and scalability
  - Managed deployment ordering with **Sync Waves, Kustomize, and reconciliation-aware design**
  - Implemented **persistent multi-environment PostgreSQL storage** on external EBS-backed volumes
  - Solved complex operational issues involving **CRDs, Helm rendering, secret readiness, and storage isolation**
