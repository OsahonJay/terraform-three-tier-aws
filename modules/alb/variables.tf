variable "name" {
  description = "Prefix used in resource names. Keep it under 28 characters (ALB name limit is 32)."
  type        = string

  validation {
    condition     = length(var.name) <= 28
    error_message = "name must be 28 characters or fewer so the ALB and target group names fit AWS limits."
  }
}

variable "internal" {
  description = "true for an internal ALB, false for internet-facing."
  type        = bool
}

variable "vpc_id" {
  description = "VPC for the target group."
  type        = string
}

variable "subnet_ids" {
  description = "Subnets the ALB is placed in (at least two AZs)."
  type        = list(string)
}

variable "security_group_ids" {
  description = "Security groups attached to the ALB."
  type        = list(string)
}

variable "target_port" {
  description = "Port the targets listen on."
  type        = number
}

variable "health_check_path" {
  description = "Path the target group health check requests."
  type        = string
}

variable "tags" {
  description = "Tags applied to every resource in the module."
  type        = map(string)
  default     = {}
}
