terraform {
  required_version = ">= 1.0.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

# 1. Custom VPC
resource "aws_vpc" "ecommerce_vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name        = "${var.app_name}-vpc"
    Environment = "production"
    ManagedBy   = "Terraform"
    Project     = "HeroVired-DevOps-SkillTest-3"
  }
}

# 2. Internet Gateway
resource "aws_internet_gateway" "ecommerce_igw" {
  vpc_id = aws_vpc.ecommerce_vpc.id

  tags = {
    Name        = "${var.app_name}-igw"
    Environment = "production"
    ManagedBy   = "Terraform"
  }
}

# 3. Public Subnet
resource "aws_subnet" "ecommerce_public_subnet" {
  vpc_id                  = aws_vpc.ecommerce_vpc.id
  cidr_block              = var.public_subnet_cidr
  availability_zone       = var.availability_zone
  map_public_ip_on_launch = true

  tags = {
    Name        = "${var.app_name}-public-subnet"
    Environment = "production"
    ManagedBy   = "Terraform"
  }
}

# 4. Route Table
resource "aws_route_table" "ecommerce_public_rt" {
  vpc_id = aws_vpc.ecommerce_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.ecommerce_igw.id
  }

  tags = {
    Name        = "${var.app_name}-public-rt"
    Environment = "production"
    ManagedBy   = "Terraform"
  }
}

# 5. Route Table Association
resource "aws_route_table_association" "ecommerce_public_assoc" {
  subnet_id      = aws_subnet.ecommerce_public_subnet.id
  route_table_id = aws_route_table.ecommerce_public_rt.id
}

# 6. Security Group for Multi-Service Architecture
resource "aws_security_group" "ecommerce_sg" {
  name        = "${var.app_name}-security-group"
  description = "Security Group for E-commerce Multi-Service Application on Docker"
  vpc_id      = aws_vpc.ecommerce_vpc.id

  # SSH for remote management
  ingress {
    description = "SSH administration"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Inbound HTTP (port 80) to Frontend
  ingress {
    description = "Frontend HTTP access (Port 80)"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Inbound HTTP (port 3000) to Frontend (React default)
  ingress {
    description = "Frontend React access (Port 3000)"
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Inbound User Service (Port 3001)
  ingress {
    description = "User Service (Port 3001)"
    from_port   = 3001
    to_port     = 3001
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Inbound Product Service (Port 3002)
  ingress {
    description = "Product Service (Port 3002)"
    from_port   = 3002
    to_port     = 3002
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Inbound Cart Service (Port 3003)
  ingress {
    description = "Cart Service (Port 3003)"
    from_port   = 3003
    to_port     = 3003
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Inbound Order Service (Port 3004)
  ingress {
    description = "Order Service (Port 3004)"
    from_port   = 3004
    to_port     = 3004
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Internal communication between all services in same security group
  ingress {
    description = "Internal service communication"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    self        = true
  }

  # Outbound all traffic
  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "${var.app_name}-sg"
    Environment = "production"
    ManagedBy   = "Terraform"
  }
}

# 7. Ubuntu 22.04 LTS AMI Data Source
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# 8. EC2 Instance Hosting Docker Containers
resource "aws_instance" "ecommerce_server" {
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = var.instance_type
  subnet_id                   = aws_subnet.ecommerce_public_subnet.id
  vpc_security_group_ids      = [aws_security_group.ecommerce_sg.id]
  associate_public_ip_address = true
  key_name                    = var.key_name != "" ? var.key_name : null

  root_block_device {
    volume_size           = 25
    volume_type           = "gp3"
    delete_on_termination = true
    tags = {
      Name = "${var.app_name}-root-volume"
    }
  }

  user_data = <<-EOF
              #!/bin/bash
              set -ex

              # 1. Update and install prerequisites
              apt-get update -y
              apt-get install -y ca-certificates curl gnupg lsb-release git

              # 2. Add Docker official GPG key and repository
              mkdir -p /etc/apt/keyrings
              curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
              echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null

              # 3. Install Docker Engine, CLI and Compose
              apt-get update -y
              apt-get install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin
              systemctl enable docker
              systemctl start docker
              usermod -aG docker ubuntu

              # 4. Add 2GB Swap space for stability with 5 Node.js services
              fallocate -l 2G /swapfile
              chmod 600 /swapfile
              mkswap /swapfile
              swapon /swapfile
              echo '/swapfile none swap sw 0 0' >> /etc/fstab

              # 5. Create Docker network
              docker network create ecommerce-net || true

              # 6. Run MongoDB container for backend database support
              docker run -d --name mongodb --restart always \
                --network ecommerce-net \
                -p 27017:27017 \
                -v mongodb_data:/data/db \
                mongo:6

              # 7. Pull and Run Dockerized Services from Docker Hub
              DOCKER_USER="${var.dockerhub_username}"

              # Backend 1: User Service (Port 3001)
              docker pull $DOCKER_USER/ecommerce-user-service:latest || true
              docker run -d --name user-service --restart always \
                --network ecommerce-net \
                -p 3001:3001 \
                -e PORT=3001 \
                -e MONGODB_URI=mongodb://mongodb:27017/ecommerce_users \
                -e JWT_SECRET=productionjwtsecretkey \
                $DOCKER_USER/ecommerce-user-service:latest

              # Backend 2: Product Service (Port 3002)
              docker pull $DOCKER_USER/ecommerce-product-service:latest || true
              docker run -d --name product-service --restart always \
                --network ecommerce-net \
                -p 3002:3002 \
                -e PORT=3002 \
                -e MONGODB_URI=mongodb://mongodb:27017/ecommerce_products \
                $DOCKER_USER/ecommerce-product-service:latest

              # Backend 3: Cart Service (Port 3003)
              docker pull $DOCKER_USER/ecommerce-cart-service:latest || true
              docker run -d --name cart-service --restart always \
                --network ecommerce-net \
                -p 3003:3003 \
                -e PORT=3003 \
                -e MONGODB_URI=mongodb://mongodb:27017/ecommerce_carts \
                $DOCKER_USER/ecommerce-cart-service:latest

              # Backend 4: Order Service (Port 3004)
              docker pull $DOCKER_USER/ecommerce-order-service:latest || true
              docker run -d --name order-service --restart always \
                --network ecommerce-net \
                -p 3004:3004 \
                -e PORT=3004 \
                -e MONGODB_URI=mongodb://mongodb:27017/ecommerce_orders \
                $DOCKER_USER/ecommerce-order-service:latest

              # Frontend Service: React App on Nginx (Port 80 and Port 3000)
              docker pull $DOCKER_USER/ecommerce-frontend:latest || true
              docker run -d --name frontend --restart always \
                --network ecommerce-net \
                -p 80:80 \
                -p 3000:3000 \
                $DOCKER_USER/ecommerce-frontend:latest

              # Log deployment complete
              echo "Deployment complete at $(date)" > /var/log/ecommerce_deployment.log
              docker ps >> /var/log/ecommerce_deployment.log
              EOF

  tags = {
    Name        = "${var.app_name}-server"
    Environment = "production"
    ManagedBy   = "Terraform"
    Project     = "HeroVired-DevOps-SkillTest-3"
  }
}
