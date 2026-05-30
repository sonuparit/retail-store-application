# 🚀 Production-Oriented PostgreSQL Persistence for Orders service

A production-oriented Kubernetes implementation focused on persistent PostgreSQL storage, StatefulSet behavior, and durable cloud-backed data management using Persistent Volumes (PV), Persistent Volume Claims (PVC), and AWS EBS.

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
  - [Orders](https://github.com/sonuparit/retail-store-reverse-engineered/tree/main/my-work/04-applications/kubernetes/ind-svc-test/orders-postgreSQL-test) ← (📍 You are here )
  - [UI](https://github.com/sonuparit/retail-store-reverse-engineered/tree/main/my-work/04-applications/kubernetes/ind-svc-test/ui-test)
- [Helm Templating](https://github.com/sonuparit/retail-store-reverse-engineered/tree/main/my-work/04-applications/kubernetes/helm-template)
- [Full App Deployment via Helmfile](https://github.com/sonuparit/retail-store-reverse-engineered/tree/main/my-work/04-applications/kubernetes/helmfile-deploy)
- [Multi-Environment GitOps via ArgoCD](https://github.com/sonuparit/retail-store-reverse-engineered/tree/main/my-work/04-applications/kubernetes/argocd-deploy)

### 📊 Production & Observability

- [Monitoring & Observability](https://github.com/sonuparit/retail-store-reverse-engineered/tree/main/my-work/03-observability)
- [Production-Grade GitOps Workflow](https://github.com/sonuparit/retail-store-reverse-engineered/tree/main/my-work)

## 📖 Overview

*This implementation focused on transitioning the Orders service from ephemeral mock storage to a production-oriented PostgreSQL persistence architecture within Kubernetes.*

*The primary objective was to validate durable storage behavior, StatefulSet orchestration patterns, and cloud-backed persistence using AWS EBS-integrated Persistent Volumes and Persistent Volume Claims.*

## ⚙️ Core Implementation

- *Created all resources for **`Orders`** service*

    ![alt text](screenshots/screenshot20.png)

- *Replaced in-memory / local postgreSQL image storage with **`persistent PostgreSQL database storage`***

    ![alt text](screenshots/screenshot15.png)

- *Attached EBS volume to **`persist the data after cluster dispose`** using **`PV and PVC`***

    ![alt text](screenshots/screenshot02.png)

    ![alt text](screenshots/screenshot13.png)

    ![alt text](screenshots/screenshot14.png)

- Implemented Pod-level `fsGroup` security context configuration to ensure PostgreSQL containers received correct read/write permissions on attached EBS-backed storage volumes

    ![alt text](screenshots/screenshot19.png)

- *Implemented **`PGDATA`** env variable variable to mitigate **`drive not empty`**) error*

## 🏛️ Architectural Decisions

### RabbitMQ

RabbitMQ integration was intentionally excluded to reduce unnecessary stateful infrastructure complexity during this implementation phase.

The primary focus remained on:

- Kubernetes orchestration
- persistent storage behavior
- infrastructure automation
- CI/CD workflows
- operational reliability

### The Decision

- *I chose to keep the application logic synchronous to my `GOAL` to ensure the fully automated infrastructure workflows remains the star of the show.*

### PostgreSQL (PV & PVC)

Order-related data required durable persistence beyond pod or cluster lifecycle events. To support production-oriented storage behavior, AWS EBS-backed Persistent Volumes and Persistent Volume Claims were implemented for PostgreSQL state management.

### The Decision

- *Adopted **`persistent PostgreSQL`** storage for the orders service.*

## ⚔️ Challenges & Solutions

### Problem

***PostgreSQL Initialization Failure on EBS Volumes:***\
*While implementing persistent storage for the orders-db service using AWS EBS volumes, the PostgreSQL container failed to initialize with the following error:*

```bash
initdb: error: directory "/var/lib/postgresql/data" exists but is not empty (lost+found found)
```

![alt text](screenshots/screenshot17.png)

- ***Technical Root Cause:***\
*Block Storage Metadata: AWS EBS volumes (ext4/xfs) automatically include a lost+found directory at the mount point root.*

- ***PostgreSQL Initialization Constraints:***\
*The initdb utility requires a completely empty directory to initialize a new database cluster to prevent accidental data overwrites.*

- ***Permission Mismatch:***\
*By default, EBS volumes are mounted with root ownership, preventing the postgres user (UID 999) from creating sub-directories.*

### The Engineered Solution

***I resolved this by implementing a two-tier configuration strategy in the Kubernetes `StatefulSet`:***

1. ***Decoupling Storage Root from Data Root (`PGDATA`):***\
*Instead of using the volume mount point root as the data directory, I utilized the PGDATA environment variable to point PostgreSQL to a **`sub-directory:`***

    - ***Mount Path**: **`/var/lib/postgresql/data`** (Points to the EBS hardware)*

        ![alt text](screenshots/screenshot18.png)

    - ***PGDATA Path**: **`/var/lib/postgresql/data/pgdata`** (A clean sub-folder managed by Postgres)*

    ***This bypasses the lost+found folder conflict while ensuring all data still persists on the EBS volume.***

    ![alt text](screenshots/screenshot11.png)

2. ***Automated Volume Ownership (`fsGroup`):***\
*To handle the permission handshake between the AWS infrastructure and the Linux container, I configured a **`Pod-level Security Context`**:*

    ```yml
    securityContext:
        fsGroup: 999
    ```

    ![alt text](screenshots/screenshot04.png)

    *This instructs Kubernetes to recursively change the ownership of the EBS volume to the postgres group ID upon attachment, ensuring the database process has the necessary read/write privileges without manual intervention.*

------------------------------------------------------------------------

## 📈 Operational Outcomes

**Zero-Touch Persistence:**\
*Successfully integrated AWS EBS with a StatefulSet, ensuring database records survive Pod restarts or node failures without manual data recovery.*

**Resolved Storage Collisions:**\
*Automated the bypass of the lost+found block storage error by reconfiguring the `PGDATA` path, allowing for seamless automated database initialization.*

**Infrastructure-as-Code Security:**\
*Implemented Pod-level Security Contexts (fsGroup), enforcing the Principle of Least Privilege by ensuring the container only accesses necessary storage volumes without requiring root permissions.*

**Production-Ready Stability:**\
*Achieved a stable "Ready" state for the retail-app data tier, handling the complex handshake between AWS infrastructure and Kubernetes storage primitives.*

![alt text](screenshots/screenshot25.png)

## 🎓 Key Learnings

*Moving from a stateless mock environment to a persistent production-grade architecture taught me that the `devil is in the details` of the infrastructure handshake. Here are my core takeaways:*

**1. Decoupling Storage from Logic:**

- *I learned that managing state in Kubernetes isn't just about attaching a disk.Iit’s about managing the lifecycle of data. Implementing PVs and PVCs taught me how to abstract physical storage (AWS EBS) from the application pods, ensuring data outlives the compute.*

**2. Navigating the "Impedance Mismatch" of Cloud Storage:**

- *The `lost+found error` was a masterclass in how Linux filesystems and database engines interact. I learned that production-ready configurations require a deep understanding of how tools like `initdb` behave, leading me to use `PGDATA` sub-directories as a standard practice for clean initializations.*

**3. Security-First Infrastructure:**

- *My experience with fsGroup reinforced the importance of the Principle of Least Privilege. I realized that solving Permission Denied errors by using `chmod 777` is a debt-heavy shortcut. Instead, I focused on using Kubernetes Security Contexts to handle volume ownership gracefully and securely.*

**4. StatefulSet Nuances:**

- *Working with PostgreSQL in K8s highlighted why StatefulSets are preferred over Deployments for databases. I gained a better grasp of stable network identifiers and the necessity of ordered, graceful deployments when dealing with persistent data.*

**6. Production-Oriented Thinking over Local Success:**

- *Transitioned from it works locally to it survives restarts, failures, and redeployments, focusing on durability, reproducibility, and zero-touch recovery.*

![alt text](screenshots/screenshot28.png)

## 🔭 Next Phase

*UI Service testing and deployment [(read here)](../ui-test/)*

## 📸 Screenshots

- *Setting up the EBS File system*

    ![alt text](screenshots/screenshot03.png)

- *Kind Config to mount storage to EC2*

    ![alt text](screenshots/screenshot07.png)

- *Mounting EBS to EC2*

    ![alt text](screenshots/screenshot08.png)

- *Creating KinD cluster*

    ![alt text](screenshots/screenshot16.png)

- *Running orders service on K8s*

    ![alt text](screenshots/screenshot23.png)

- *Successful implementation of orders service*

    ![alt text](screenshots/screenshot25.png)

- *Persisted PostgreSQL data on EBS*

    ![alt text](screenshots/screenshot28.png)

- *Wrapping up the session*

    ![alt text](screenshots/screenshot29.png)
