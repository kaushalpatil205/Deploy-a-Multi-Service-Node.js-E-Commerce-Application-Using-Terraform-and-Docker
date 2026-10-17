output "vpc_id" {
  description = "The ID of the custom VPC"
  value       = aws_vpc.ecommerce_vpc.id
}

output "public_subnet_id" {
  description = "The ID of the public subnet"
  value       = aws_subnet.ecommerce_public_subnet.id
}

output "security_group_id" {
  description = "The ID of the security group"
  value       = aws_security_group.ecommerce_sg.id
}

output "ec2_instance_id" {
  description = "The ID of the provisioned EC2 instance"
  value       = aws_instance.ecommerce_server.id
}

output "ec2_public_ip" {
  description = "The public IP address of the EC2 instance"
  value       = aws_instance.ecommerce_server.public_ip
}

output "ec2_public_dns" {
  description = "The public DNS name of the EC2 instance"
  value       = aws_instance.ecommerce_server.public_dns
}

output "frontend_url_port_80" {
  description = "Public URL for E-Commerce Frontend on Port 80"
  value       = "http://${aws_instance.ecommerce_server.public_ip}:80"
}

output "frontend_url_port_3000" {
  description = "Public URL for E-Commerce Frontend on Port 3000"
  value       = "http://${aws_instance.ecommerce_server.public_ip}:3000"
}

output "user_service_url" {
  description = "Direct URL for User Service"
  value       = "http://${aws_instance.ecommerce_server.public_ip}:3001"
}

output "user_service_health" {
  description = "Health endpoint for User Service"
  value       = "http://${aws_instance.ecommerce_server.public_ip}:3001/health"
}

output "product_service_url" {
  description = "Direct URL for Product Service"
  value       = "http://${aws_instance.ecommerce_server.public_ip}:3002"
}

output "product_service_health" {
  description = "Health endpoint for Product Service"
  value       = "http://${aws_instance.ecommerce_server.public_ip}:3002/health"
}

output "cart_service_url" {
  description = "Direct URL for Cart Service"
  value       = "http://${aws_instance.ecommerce_server.public_ip}:3003"
}

output "cart_service_health" {
  description = "Health endpoint for Cart Service"
  value       = "http://${aws_instance.ecommerce_server.public_ip}:3003/health"
}

output "order_service_url" {
  description = "Direct URL for Order Service"
  value       = "http://${aws_instance.ecommerce_server.public_ip}:3004"
}

output "order_service_health" {
  description = "Health endpoint for Order Service"
  value       = "http://${aws_instance.ecommerce_server.public_ip}:3004/health"
}
