output "vpc_id" {
  description = "ID of the VPC."
  value       = aws_vpc.this.id
}

output "public_subnet_ids" {
  description = "Public subnet IDs."
  value       = aws_subnet.public[*].id
}

output "app_subnet_ids" {
  description = "Private app subnet IDs."
  value       = aws_subnet.app[*].id
}

output "db_subnet_ids" {
  description = "Isolated database subnet IDs."
  value       = aws_subnet.db[*].id
}

output "nat_public_ips" {
  description = "Elastic IPs of the NAT Gateway(s). App servers appear on the internet as these."
  value       = aws_eip.nat[*].public_ip
}
