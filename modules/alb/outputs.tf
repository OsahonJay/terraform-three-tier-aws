output "dns_name" {
  description = "DNS name of the load balancer."
  value       = aws_lb.this.dns_name
}

output "target_group_arn" {
  description = "ARN of the target group, passed to the Auto Scaling group."
  value       = aws_lb_target_group.this.arn
}
