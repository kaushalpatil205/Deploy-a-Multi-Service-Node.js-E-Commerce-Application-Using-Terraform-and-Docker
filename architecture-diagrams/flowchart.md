# 🚀 Multi-Service E-Commerce Deployment Flowchart

This document details the deployment workflow for containerizing the microservices, pushing to Docker Hub, provisioning cloud infrastructure via Terraform, and verifying live services.

---

## Deployment Flowchart (Mermaid)

```mermaid
flowchart LR
    %% ─── Styling Classes ────────────────────────────────────────────
    classDef startend fill:#e1f5fe,stroke:#0288d1,stroke-width:2px,color:#000
    classDef check    fill:#fff3e0,stroke:#f57c00,stroke-width:2px,color:#000
    classDef success  fill:#e8f5e9,stroke:#388e3c,stroke-width:2px,color:#000

    Start(["Start"]):::startend --> P1
    
    subgraph P1 ["Phase 1: App Setup & Dockerization"]
        direction TB
        A1["1. Clone Repo & Add Endpoints<br>GET / & GET /health"]
        A2["2. Create 5 Dockerfiles<br>Frontend + 4 Microservices"]
        A3["3. Local Docker Build & Test<br>docker compose up -d"]
        A1 --> A2 --> A3
    end

    P1 --> C1{"Local Test<br>Passed?"}:::check
    C1 -- Yes --> P2

    subgraph P2 ["Phase 2: Registry & IaC"]
        direction TB
        B1["4. Tag & Push to Docker Hub<br>kaushalpatil205/*"]
        B2["5. Write Terraform Manifests<br>VPC, Subnet, IGW, SG, EC2"]
        B3["6. Validate & Preview Plan<br>terraform init & plan"]
        B1 --> B2 --> B3
    end

    P2 --> P3

    subgraph P3 ["Phase 3: Provision & Deploy"]
        direction TB
        D1["7. terraform apply -auto-approve"]
        D2["8. Cloud-Init User Data<br>Install Docker & Pull Images"]
        D3["9. Auto-Run 5 Containers<br>Ports: 80, 3000-3004"]
        D1 --> D2 --> D3
    end

    P3 --> P4

    subgraph P4 ["Phase 4: Verify & Document"]
        direction TB
        E1["10. Probing & Verification<br>Browser 'Frontend is Live' & curls"]
        E2["11. Evidence Screenshots<br>12 Verifiable Evidence Captures"]
        E3["12. Generate PDF & README<br>Clean PDF & GitHub Sync"]
        E1 --> E2 --> E3
    end

    P4 --> Done(["Assessment Complete (50/50)"]):::success
```

---

## 📋 Deployment Stages Breakdown

1. **Phase 1: Source & Containerization**: Add root sample endpoints (`GET /`) and `/health` checks across all 4 Node.js backend microservices and React frontend. Build and verify all Docker containers locally.
2. **Phase 2: Registry Distribution & IaC**: Tag all 5 images under `kaushalpatil205` and publish to Docker Hub. Author modular Terraform configurations (`main.tf`, `variables.tf`, `outputs.tf`).
3. **Phase 3: Automated Cloud Orchestration**: Execute `terraform apply` to provision VPC, Subnet, Security Group, and EC2 with automated cloud-init bootstrap pulling and running containers.
4. **Phase 4: Probing & Documentation**: Verify live browser UI on port 80/3000 ("Frontend is Live"), probe all backend service ports, generate clean documentation and PDF.
