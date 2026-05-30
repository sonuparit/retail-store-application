# 🚀 Production-Oriented Validation of the UI Service

A production-oriented Kubernetes implementation focused on validating environment-agnostic service behavior, separating observability concerns from application logic, and simplifying runtime dependencies within a microservices architecture.

## 📑 Table of Contents

- [Implementation Roadmap](#️-implementation-roadmap)
- [Project Navigation](#-project-navigation)
- [Overview](#-overview)
- [Core Implementation](#️-core-implementation)
- [Architectural Decisions](#️-architectural-decisions)
- [Challenges & Solutions](#️-challenges--solutions)
- [Operational Outcomes](#-operational-outcomes)
- [Key Learnings](#-key-learnings)
- [Next Phase](#-next-phase)
- [Screenshots](#-screenshots)

## 🗺️ Implementation Roadmap

<p align="left">
  <img src="../5-Kubernetes.jpg" width="80%"/>
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
  - [UI](https://github.com/sonuparit/retail-store-reverse-engineered/tree/main/my-work/04-applications/kubernetes/ind-svc-test/ui-test) ← (📍 You are here )
- [Helm Templating](https://github.com/sonuparit/retail-store-reverse-engineered/tree/main/my-work/04-applications/kubernetes/helm-template)
- [Full App Deployment via Helmfile](https://github.com/sonuparit/retail-store-reverse-engineered/tree/main/my-work/04-applications/kubernetes/helmfile-deploy)
- [Multi-Environment GitOps via ArgoCD](https://github.com/sonuparit/retail-store-reverse-engineered/tree/main/my-work/04-applications/kubernetes/argocd-deploy)

### 📊 Production & Observability

- [Monitoring & Observability](https://github.com/sonuparit/retail-store-reverse-engineered/tree/main/my-work/03-observability)
- [Production-Grade GitOps Workflow](https://github.com/sonuparit/retail-store-reverse-engineered/tree/main/my-work)

## 📖 Overview

*This implementation focused on validating the UI service within Kubernetes while intentionally separating runtime observability concerns from application-layer logic.*

*The primary objective was to maintain an environment-agnostic application design and shift infrastructure visibility responsibilities toward dedicated observability tooling.*

## ⚙️ Core Implementation

*Analyzed application runtime dependencies and infrastructure-awareness patterns within Kubernetes environments.*

- *Removed environment-detection variables to preserve application-level environment abstraction*

    ![alt text](screenshots/screenshot07.png)

- *Created and validated all required Kubernetes deployment resources*

    ![alt text](screenshots/screenshot08.png)

## 🏛️ Architectural Decisions

***Context:***

*The UI service relied on environment-based auto-detection using runtime variables to identify its execution environment. While functional, `this mixed observability concerns with the application code`, which I prefer to keep separate*

***Rationale:***

- *Application should not be `aware of its execution environment`*
- *Mixing application logic with observability increases unnecessary complexity and state management.*
- *Results in mixed logs that don’t directly relate to each other*
- *Better to use tools like **`Prometheus`** to maintain separation of concerns*
- *Can be good for local development.*

### The Decision

*Removed the internal metadata provider to later implement **`Prometheus-based service discovery`**, offloading observability to the infrastructure layer where it belongs.*

## ⚔️ Challenges & Solutions

The primary challenge involved identifying hidden abstraction layers responsible for runtime environment introspection and understanding how infrastructure-awareness was embedded within application behavior.

***My approach:***

- *Analyzed source code, to better understand the code behavior (**`KubernetesMetadataProvider.java`**)*

    ![alt text](screenshots/screenshot03.png)

- Removed runtime environment-detection variables responsible for infrastructure introspection behavior

## 📈 Operational Outcomes

*Successfully validated the UI service within Kubernetes while maintaining an environment-agnostic runtime model.*

*This implementation improved separation of concerns by decoupling infrastructure observability behavior from application-layer logic and reinforced cleaner operational architecture boundaries.*

## 🎓 Key Learnings

- *Learned to enforce **`clear separation of concerns`** by decoupling observability from application logic, improving system clarity and maintainability.*

- *Recognized that applications should remain **`environment-agnostic`**, avoiding implicit dependencies on runtime context.*

- *Learned to **`validate systems incrementally`** — testing services in isolation before full orchestration improved reliability and debugging clarity.*

- *Gained **`hands-on experience in reverse engineering systems`** — an invaluable skill for translating legacy applications into scalable microservices architectures.*

## 🔭 Next Phase

*Helm templating all micro services [(read here)](../../helm-template/)*

## 📸 Screenshots

- *Created all K8s resources and validated them*

    ![alt text](screenshots/screenshot08.png)

- *Deployed single service to validate it's operational*

    ![alt text](screenshots/screenshot01.png)

- Result:

    ![alt text](screenshots/screenshot02.png)
