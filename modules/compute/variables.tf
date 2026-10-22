variable "name" {
  description = "Prefix used in resource names and the instance Name tag."
  type        = string
}

variable "tier" {
  description = "Tier label (web or app). Used for tagging and filtering instances."
  type        = string
}

variable "ami_id" {
  description = "AMI for the instances."
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type."
  type        = string
}

variable "subnet_ids" {
  description = "Subnets the Auto Scaling group launches into."
  type        = list(string)
}

variable "security_group_ids" {
  description = "Security groups attached to each instance."
  type        = list(string)
}

variable "target_group_arns" {
  description = "ALB target groups the instances register with."
  type        = list(string)
}

variable "user_data" {
  description = "Rendered (not base64) user data script."
  type        = string
}

variable "min_size" {
  description = "Minimum instances."
  type        = number
}

variable "max_size" {
  description = "Maximum instances."
  type        = number
}

variable "desired_capacity" {
  description = "Instances to run on creation."
  type        = number
}

variable "cpu_target" {
  description = "Average CPU percentage the scaling policy aims for."
  type        = number
  default     = 60
}

variable "attach_extra_policy" {
  description = "Whether to attach extra_policy_json as an inline policy. Separate flag because the JSON may not be known at plan time."
  type        = bool
  default     = false
}

variable "extra_policy_json" {
  description = "Inline IAM policy JSON for tier-specific permissions."
  type        = string
  default     = ""
}

variable "tags" {
  description = "Tags applied to every resource in the module."
  type        = map(string)
  default     = {}
}
