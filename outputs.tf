output "web_url" {
  description = "Open this in a browser. It is the public web ALB."
  value       = "http://${module.web_alb.dns_name}"
}

output "app_alb_dns" {
  description = "Internal app ALB. Only resolvable and reachable from inside the VPC."
  value       = module.app_alb.dns_name
}

output "db_endpoint" {
  description = "RDS hostname. Only reachable from the app tier."
  value       = module.database.address
}

output "db_secret_arn" {
  description = "Secrets Manager secret holding the DB credentials."
  value       = module.database.master_user_secret_arn
}

output "nat_public_ips" {
  description = "Public IPs the private app servers use for outbound traffic."
  value       = module.network.nat_public_ips
}

output "flow_log_group" {
  description = "CloudWatch log group with VPC flow logs. Look for REJECT lines when debugging."
  value       = module.network.flow_log_group
}

output "vpc_id" {
  description = "VPC ID."
  value       = module.network.vpc_id
}

output "web_asg_name" {
  description = "Web tier Auto Scaling group."
  value       = module.web_tier.asg_name
}

output "app_asg_name" {
  description = "App tier Auto Scaling group."
  value       = module.app_tier.asg_name
}
