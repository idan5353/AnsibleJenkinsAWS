output "vpc_id" {
  description = "VPC ID"
  value       = aws_vpc.main.id
}

output "web_server_ips" {
  description = "Public IP addresses of web servers"
  value       = aws_instance.web[*].public_ip
}

output "web_server_ids" {
  description = "Instance IDs of web servers"
  value       = aws_instance.web[*].id
}

output "security_group_id" {
  description = "Security group ID"
  value       = aws_security_group.web.id
}
