# 📐 Multi-Service E-Commerce System Architecture

This document details the cloud and container architecture for the Node.js Multi-Service E-Commerce Application provisioned on AWS using Terraform and Docker.

---

## Architecture Diagram (Mermaid)

```mermaid
graph TD
    %% ─── Styling Classes ────────────────────────────────────────────
    classDef client   fill:#e1f5fe,stroke:#0288d1,stroke-width:2px,color:#000
    classDef igw      fill:#fff9c4,stroke:#f9a825,stroke-width:2px,color:#000
    classDef svc      fill:#e8f5e9,stroke:#388e3c,stroke-width:2px,color:#000
    classDef hub      fill:#e3f2fd,stroke:#1565c0,stroke-width:2px,color:#000
    classDef tf       fill:#f3e5f5,stroke:#7b1fa2,stroke-width:2px,color:#000

    %% ─── External Layer (Horizontal) ────────────────────────────────
    subgraph EXT ["External Layer (Clients, IaC & Registry)"]
        direction LR
        Client(("Browser / Client<br>HTTP Traffic")):::client
        TF["Terraform v1.9+<br>IaC Automation"]:::tf
        Hub[("Docker Hub Registry<br>kaushalpatil205/*")]:::hub
    end

    %% ─── AWS Cloud Network & Compute ────────────────────────────────
    subgraph AWS ["AWS Cloud (ap-south-1) — VPC 10.0.0.0/16 | Public Subnet 10.0.1.0/24 | SG: 80, 3000-3004, 22"]
        direction TB
        IGW["AWS Internet Gateway (ecommerce-igw)"]:::igw

        subgraph EC2 ["EC2 Host: t3.medium (Ubuntu 22.04) — Docker Engine"]
            direction TB
            FE["Frontend Container: React + Nginx<br>Ports 80 & 3000 | 'Frontend is Live'"]:::svc

            subgraph MICRO ["Backend Microservices (Bridge Network: ecommerce-net)"]
                direction LR
                US["User Service<br>:3001"]:::svc
                PS["Product Service<br>:3002"]:::svc
                CS["Cart Service<br>:3003"]:::svc
                OS["Order Service<br>:3004"]:::svc
                DB[("MongoDB 6<br>:27017")]:::client
            end
        end
    end

    %% ─── Connections ────────────────────────────────────────────────
    Client -->|"HTTP :80 / :3000"| IGW
    Client -->|"API :3001-:3004"| IGW
    TF ==>|"terraform apply"| AWS
    Hub -.->|"Pulls 5 Images"| EC2
    IGW --> FE
    IGW --> MICRO
    FE -.->|"Internal API Proxy"| MICRO
    US --> DB
    PS --> DB
    CS --> DB
    OS --> DB
```

---

## 🏛️ Architecture Highlights

| Layer | Component | Implementation Details |
|---|---|---|
| **Cloud Provider** | AWS (Amazon Web Services) | Region: `ap-south-1` (Mumbai) |
| **Network (VPC)** | Custom VPC | CIDR: `10.0.0.0/16`, DNS Hostnames Enabled |
| **Subnet** | Public Subnet | CIDR: `10.0.1.0/24`, AZ: `ap-south-1a`, Auto-assign Public IP |
| **Routing** | Internet Gateway & Route Table | Route `0.0.0.0/0` targeting IGW for two-way public Internet access |
| **Firewall (SG)** | `ecommerce-sg` | Allows Inbound 80, 3000, 3001, 3002, 3003, 3004, 22 and internal SG traffic |
| **Compute** | AWS EC2 `t3.medium` | 2 vCPUs, 4 GB RAM, 25 GB gp3 root storage, Ubuntu 22.04 LTS |
| **Container Engine**| Docker & Docker Compose | Container isolation on user-defined bridge network `ecommerce-net` |
| **Frontend** | React + Nginx | Multi-stage build, static serving on ports 80 and 3000, API reverse-proxying |
| **User Service** | Node.js Express (`user-service`) | Port 3001, handles user profiles, auth JWT, healthcheck `/health` |
| **Product Service**| Node.js Express (`product-service`)| Port 3002, product catalog, categories, inventory management |
| **Cart Service** | Node.js Express (`cart-service`) | Port 3003, active user cart, item addition and validation |
| **Order Service** | Node.js Express (`order-service`) | Port 3004, order processing, payments gateway simulation |
| **Database** | MongoDB 6 Container | Port 27017, internal persistence volume for catalog and order data |
