# 📐 Multi-Service E-Commerce System Architecture

This document details the complete end-to-end cloud and container architecture for the Node.js Multi-Service E-Commerce Application provisioned on AWS using Terraform and Docker.

---

## Architecture Diagram (Mermaid)

```mermaid
graph TD
    %% ─── Styling Classes ────────────────────────────────────────────
    classDef client   fill:#e1f5fe,stroke:#0288d1,stroke-width:2px,color:#000
    classDef igw      fill:#fff9c4,stroke:#f9a825,stroke-width:2px,color:#000
    classDef vpc      fill:#e8eaf6,stroke:#3f51b5,stroke-width:2px,color:#000
    classDef subnet   fill:#ede7f6,stroke:#512da8,stroke-width:2px,color:#000
    classDef sg       fill:#fce4ec,stroke:#c2185b,stroke-width:2px,color:#000
    classDef ec2      fill:#fff3e0,stroke:#f57c00,stroke-width:2px,color:#000
    classDef docker   fill:#e0f2f1,stroke:#00796b,stroke-width:2px,color:#000
    classDef service  fill:#e8f5e9,stroke:#388e3c,stroke-width:2px,color:#000
    classDef hub      fill:#e3f2fd,stroke:#1565c0,stroke-width:2px,color:#000
    classDef tf       fill:#f3e5f5,stroke:#7b1fa2,stroke-width:2px,color:#000

    %% ─── External Users & Registries ────────────────────────────────
    Client(("Web User / Browser<br>(HTTP Traffic)")):::client
    Dev(("DevOps Engineer<br>(Terraform & Git)")):::client
    DockerHub[("Docker Hub Registry<br>kaushalpatil205/*<br>• ecommerce-frontend<br>• ecommerce-user-service<br>• ecommerce-product-service<br>• ecommerce-cart-service<br>• ecommerce-order-service")]:::hub

    %% ─── Terraform Automation ───────────────────────────────────────
    subgraph IAC ["Terraform Infrastructure as Code"]
        TF_CLI["Terraform v1.9+<br>main.tf | variables.tf | outputs.tf<br>terraform apply"]:::tf
    end

    %% ─── AWS Cloud Infrastructure ───────────────────────────────────
    subgraph AWS ["AWS Cloud Region: ap-south-1 (Mumbai)"]
        direction TB

        %% Internet Gateway
        IGW["AWS Internet Gateway<br>(ecommerce-igw)"]:::igw

        %% VPC Boundary
        subgraph VPC ["VPC: 10.0.0.0/16 (ecommerce-vpc)"]
            direction TB

            %% Public Subnet
            subgraph SUBNET ["Public Subnet: 10.0.1.0/24 (ap-south-1a)"]
                direction TB

                %% Security Group Boundary
                subgraph SG ["Security Group: ecommerce-sg"]
                    direction TB
                    SG_RULES["Inbound Rules:<br>• TCP 80 & 3000 (Frontend Web)<br>• TCP 3001 (User Service)<br>• TCP 3002 (Product Service)<br>• TCP 3003 (Cart Service)<br>• TCP 3004 (Order Service)<br>• TCP 22 (SSH Admin)<br>• Internal All (Self SG)"]:::sg

                    %% EC2 Instance Boundary
                    subgraph EC2 ["AWS EC2 Instance: t3.medium (Ubuntu 22.04 LTS)"]
                        direction TB
                        HOST_INFO["Host Public IP / DNS<br>Docker Engine 24+ & Docker Compose"]:::ec2

                        %% Docker Network Boundary
                        subgraph DOCKER_NET ["Docker Bridge Network (ecommerce-net)"]
                            direction LR

                            %% Frontend Container
                            FE["Container: frontend<br>Port 80 / 3000:80<br>React + Nginx<br>Status: 'Frontend is Live'"]:::service

                            %% Microservices Containers
                            US["Container: user-service<br>Port 3001:3001<br>Node.js / Express<br>'User Service Running'"]:::service

                            PS["Container: product-service<br>Port 3002:3002<br>Node.js / Express<br>'Product Service Running'"]:::service

                            CS["Container: cart-service<br>Port 3003:3003<br>Node.js / Express<br>'Cart Service Running'"]:::service

                            OS["Container: order-service<br>Port 3004:3004<br>Node.js / Express<br>'Order Service Running'"]:::service

                            DB[("Container: mongodb<br>Port 27017:27017<br>Mongo 6 Database<br>Data Persistence")]:::docker
                        end
                    end
                end
            end
        end
    end

    %% ─── Traffic Flows & Dependencies ───────────────────────────────
    Dev ==>|"1. terraform apply"| TF_CLI
    TF_CLI ==>|"Provisions VPC, Subnet, IGW, SG, EC2"| AWS
    TF_CLI -.->|"User-Data pulls images"| DockerHub

    Client -->|"HTTP GET :80 / :3000"| IGW
    Client -->|"API GET :3001 - :3004"| IGW
    IGW --> SG_RULES
    SG_RULES --> FE
    SG_RULES --> US
    SG_RULES --> PS
    SG_RULES --> CS
    SG_RULES --> OS

    FE -.->|"Proxy / Direct API"| US
    FE -.->|"Proxy / Direct API"| PS
    FE -.->|"Proxy / Direct API"| CS
    FE -.->|"Proxy / Direct API"| OS

    US -->|"Mongoose URI"| DB
    PS -->|"Mongoose URI"| DB
    CS -->|"Mongoose URI"| DB
    OS -->|"Mongoose URI"| DB

    DockerHub ==>|"Pulls 5 Images"| EC2
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
