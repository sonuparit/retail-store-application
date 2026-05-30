# 🚀 Docker Compose Orchestration for Microservices

A production-oriented Docker Compose orchestration setup focused on reverse engineering, understanding, and validating how independently containerized microservices communicate and operate within a unified runtime environment.

## 📑 Table of Contents

**🧭 Navigation:**

- [Implementation Roadmap](#️-implementation-roadmap)
- [Project Navigation](#-project-navigation)

**📘 Project Documentation:**

- [Overview](#-overview)
- [Tech Stack](#️-tech-stack)
- [Deployment Guide](#-deployment-guide)
- [What This Project Demonstrates](#-what-this-project-demonstrates)
- [Core Implementation](#️-core-implementation)
- [Key Learnings](#-key-learnings)
- [Conclusion](#-conclusion)
- [Next Phase](#-next-phase)

## 🗺️ Implementation Roadmap

<p align="left">
  <img src="./4-compose.jpg" width="80%"/>
</p>

## 🔗 Project Navigation

- [Root Directory](https://github.com/sonuparit/retail-store-reverse-engineered)

### 📖 Understanding Phase

- [Source Code Understanding](https://github.com/sonuparit/retail-store-reverse-engineered/tree/main/src-code)
- [Architecture Understanding](https://github.com/sonuparit/retail-store-reverse-engineered/tree/main/my-work/04-applications/architecture)
- [Containerization (Docker)](https://github.com/sonuparit/retail-store-reverse-engineered/tree/main/my-work/04-applications/docker)
- [Docker Compose Orchestration](https://github.com/sonuparit/retail-store-reverse-engineered/tree/main/my-work/04-applications/docker-compose) ← (📍 You are here )

### ☸️ Kubernetes Implementation Phase

- [Individual Service Testing](https://github.com/sonuparit/retail-store-reverse-engineered/tree/main/my-work/04-applications/kubernetes/ind-svc-test)
  - [Carts](https://github.com/sonuparit/retail-store-reverse-engineered/tree/main/my-work/04-applications/kubernetes/ind-svc-test/cart-dynamodb-test)
  - [Catalog](https://github.com/sonuparit/retail-store-reverse-engineered/tree/main/my-work/04-applications/kubernetes/ind-svc-test/catalog-test)
  - [Checkout](https://github.com/sonuparit/retail-store-reverse-engineered/tree/main/my-work/04-applications/kubernetes/ind-svc-test/checkout-test)
  - [Orders](https://github.com/sonuparit/retail-store-reverse-engineered/tree/main/my-work/04-applications/kubernetes/ind-svc-test/orders-postgreSQL-test)
  - [UI](https://github.com/sonuparit/retail-store-reverse-engineered/tree/main/my-work/04-applications/kubernetes/ind-svc-test/ui-test)
- [Helm Templating](https://github.com/sonuparit/retail-store-reverse-engineered/tree/main/my-work/04-applications/kubernetes/helm-template)
- [Full App Deployment via Helmfile](https://github.com/sonuparit/retail-store-reverse-engineered/tree/main/my-work/04-applications/kubernetes/helmfile-deploy)
- [Multi-Environment GitOps via ArgoCD](https://github.com/sonuparit/retail-store-reverse-engineered/tree/main/my-work/04-applications/kubernetes/argocd-deploy)

### 📊 Production & Observability

- [Monitoring & Observability](https://github.com/sonuparit/retail-store-reverse-engineered/tree/main/my-work/03-observability)
- [Production-Grade GitOps Workflow](https://github.com/sonuparit/retail-store-reverse-engineered/tree/main/my-work)

## 📌 Overview

> [!NOTE]
> This phase intentionally uses local development environment variables and secrets.
>
> In later Kubernetes phases, secrets were migrated to **AWS Secrets Manager** for production-grade secret handling.

*This phase focused on reverse engineering and orchestrating a production-style multi-service retail application using Docker Compose.*

*The objective was not only to run containers, but to understand how independently deployed microservices communicate, share configuration, manage dependencies, and operate within a unified runtime environment.*

## 🛠️ Tech Stack

- **Docker**
- **Docker Compose**
- **Microservices Architecture**

## 📦 Deployment Guide

- Clone the repo:

```yml
https://github.com/sonuparit/retail-store-reverse-engineered.git
```

- Navigate to Wrapper

```yml
cd retail-store-reverse-engineered/my-work/docker-compose/app-wrapper/
```

- Start All Services

```yml
docker compose up -d
```

This enabled seamless startup of all services with proper configuration.

![alt text](./screenshots/Screenshot02.png)

- Run `docker ps` command to get the port of UI

```yml
docker ps
```

![alt text](screenshots/screenshot23.png)

- After health check, access the app at port `8888`

  - for local development access at `localhost:8888`

  - for EC2 development access at `<EC2 public IP>:8888`

    ![alt text](./screenshots/Screenshot07.png)

### 5. Operational Validation

**Verified:**

- Service health and communication

    ![alt text](screenshots/screenshot03.png)

- Application functionality through end-to-end testing  

    ![alt text](./screenshots/app.gif)

- Stability of containerized environment  

    ![alt text](screenshots/performance.gif)

## 🧠 What This Project Demonstrates

**This implementation demonstrates practical understanding of:**

- *Multi-service orchestration using Docker Compose*
- *Container networking and service discovery*
- *Configuration-driven application architecture*
- *Environment variable management*
- *Service dependency coordination*
- *Runtime validation and debugging workflows*
- *Production-oriented microservices operation*

## ⚙️ Core Implementation

### 1. Compose Configuration Analysis

**Analyzed service orchestration patterns across all Docker Compose configurations, including:**

- *Service definitions*
- *Environment mappings*
- *Dependency chains*
- *Database connectivity*
- *Security-related configurations*
- *Container startup coordination*

### 2. Configuration Behavior Analysis

**Validated the operational purpose behind key orchestration directives, including:**

- *Port exposure strategy*
- *Internal service communication*
- *Restart policy behavior*
- *Build context separation*
- *Health check implementation*
- *Runtime environment isolation*

### 3. Environment Variable Discovery  

*Identified required environment variables by:*

- *Tracing source code*  
- *Mapping configuration usage across services*  
- *Ensuring correct runtime injection*  

### 4. Unified Multi-Service Orchestration

*Designed a modular Compose-based orchestration workflow using shared configuration and a centralized bridge network (**`main-app-net`**) to enable seamless communication across independently managed services.*

## 🎓 Key Learnings

- *How independently deployed microservices communicate within shared container networks*
- *Practical orchestration patterns using Docker Compose*
- *Runtime dependency coordination and startup sequencing*
- *Environment-driven configuration management*
- *Container health validation and operational debugging*
- *Reverse engineering and understanding production-style application setups*

## 📌 Conclusion

This phase was not only about orchestrating containers, but about understanding the operational behavior of distributed services within a shared runtime environment.

The reverse-engineering process strengthened my ability to analyze existing systems, validate runtime behavior, and reason about production-oriented orchestration workflows.

## 🔭 Next Phase

The next implementation phase transitions this Compose-based orchestration workflow into Kubernetes-native deployments, including:

*Individual service testing for Kubernetes deployment [(read here)](../kubernetes/)*
