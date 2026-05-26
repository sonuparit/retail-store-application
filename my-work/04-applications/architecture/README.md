# 🏗️ Reverse Engineered to gain Architectural Understanding

This project is a retail store application built using a microservices architecture (5 services). I reverse-engineered the system to gain a deep understanding of service communication, dependencies, and Kubernetes-oriented design patterns.

## 📑 Table of contents

1. **[Overview](#-overview)**
2. **[App Architecture](#️-app-architecture-original)**
3. **[What I Discovered](#-what-i-discovered)**
4. **[Why this design?](#-why-this-design)**
5. **[Why This Project Matters](#-why-this-project-matters)**
6. **[Next Steps](#-next-steps)**

## 📌 Overview

**Performed architectural analysis of the application by studying:**

* *Application source code*
* *Service dependencies*
* *Environment variables and runtime configurations*
* *API communication patterns*
* *Containerization requirements*

**This process helped map the end-to-end service flow and identify how microservices interact within a Kubernetes-oriented environment.**

## 🏗️ App Architecture (Original)

![alt text](screenshots/architecture.png)

| Component            | Language |  Description                            |
| -------------------- | -------- | --------------------------------------- |
| UI                   | Java     | Store user interface                    |
| Catalog              | Go       | Product catalog API                     |
| Cart                 | Java     | User shopping carts API                 |
| Orders               | Java     | User orders API                         |
| Checkout             | Node     | API to orchestrate the checkout process |

### 🧠 What I Discovered

**Architecture Insights:**

* *Stateless microservices architecture*
* *Cloud-native service design patterns*
* *Container-oriented application structure*
* *Internal API-based service communication*
* *Kubernetes-friendly workload separation*
* *Ephemeral workload design*
* *Supports optional integration with external databases if needed*

### 💡 Why this design?

**This architecture appears intentionally optimized for:**

* *State/Stateless workload orchestration*
* *Production oriented workflows*
* *Reduced infrastructure dependency management*
* *Cloud-native deployment environments*
* *Rapid experimentation in Kubernetes ecosystems*
* *Service-level isolation and modularity*

### 💡 Why This Project Matters

**This reverse-engineering process strengthened my understanding of:**

* *Distributed system architecture*
* *Microservices communication patterns*
* *Container-first application design*
* *Kubernetes-oriented deployment models*
* *Service dependency mapping*
* *Operational considerations in cloud-native environments*

**It also established the architectural foundation required for later implementation phases involving containerization, orchestration, GitOps workflows, observability, and infrastructure automation.**

### 📌 Conclusion

This architectural analysis phase provided a strong foundation for understanding how modern cloud-native microservices are structured, deployed, and orchestrated within Kubernetes-oriented environments.

The project served as a practical entry point into distributed systems design, containerized workloads, service communication patterns, and production-style application architecture.

---

## 🔧 Next Steps

1. *Deep dive into **`Dockerfile optimization`** [(read here)](../docker/)*
2. *Refactor setup for production-ready Docker Compose*
3. *Implement Kubernetes deployments*
4. *Add email notification system*
5. *Build a CI/CD pipeline*
6. *Integrate monitoring (Prometheus + Grafana)*
7. *Full Automation via terrafom and GitOps workflows***
