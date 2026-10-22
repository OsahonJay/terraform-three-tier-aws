output "web_alb_sg_id" {
  description = "Security group for the public web ALB."
  value       = aws_security_group.web_alb.id
}

output "web_sg_id" {
  description = "Security group for web servers."
  value       = aws_security_group.web.id
}

output "app_alb_sg_id" {
  description = "Security group for the internal app ALB."
  value       = aws_security_group.app_alb.id
}

output "app_sg_id" {
  description = "Security group for app servers."
  value       = aws_security_group.app.id
}

output "db_sg_id" {
  description = "Security group for RDS."
  value       = aws_security_group.db.id
}
