output "asg_name" {
  description = "Name of the Auto Scaling group."
  value       = aws_autoscaling_group.this.name
}

output "role_name" {
  description = "IAM role attached to the instances."
  value       = aws_iam_role.this.name
}
