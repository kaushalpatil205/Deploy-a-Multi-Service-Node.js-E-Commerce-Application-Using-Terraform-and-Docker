variable "aws_region" {
  description = "AWS region for provisioning resources"
  type        = string
  default     = "ap-south-1"
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidr" {
  description = "CIDR block for the public subnet"
  type        = string
  default     = "10.0.1.0/24"
}

variable "availability_zone" {
  description = "Availability zone for the public subnet"
  type        = string
  default     = "ap-south-1a"
}

variable "instance_type" {
  description = "EC2 instance type for hosting Docker containers"
  type        = string
  default     = "t3.medium"
}

variable "key_name" {
  description = "Optional EC2 Key Pair name for SSH access"
  type        = string
  default     = ""
}

variable "dockerhub_username" {
  description = "Docker Hub username where images are pushed"
  type        = string
  default     = "kaushal2052devops"
}

variable "app_name" {
  description = "Application name prefix for resource tags"
  type        = string
  default     = "ecommerce-store"
}
