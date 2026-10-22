variable "name" {
  description = "Prefix used in resource names."
  type        = string
}

variable "subnet_ids" {
  description = "DB subnets. RDS requires at least two AZs."
  type        = list(string)

  validation {
    condition     = length(var.subnet_ids) >= 2
    error_message = "RDS needs subnets in at least two availability zones."
  }
}

variable "security_group_ids" {
  description = "Security groups attached to the DB instance."
  type        = list(string)
}

variable "engine_version" {
  description = "MySQL version. A major version like 8.4 lets RDS choose the current minor."
  type        = string
}

variable "instance_class" {
  description = "RDS instance class."
  type        = string
}

variable "allocated_storage" {
  description = "Storage in GiB. Autoscaling allows up to double this."
  type        = number
}

variable "db_name" {
  description = "Initial database name."
  type        = string
}

variable "username" {
  description = "Master username. The password is generated and kept in Secrets Manager."
  type        = string
}

variable "multi_az" {
  description = "Run a standby in a second AZ. Doubles the DB cost."
  type        = bool
}

variable "backup_retention_period" {
  description = "Days of automated backups to keep."
  type        = number
  default     = 1
}

variable "skip_final_snapshot" {
  description = "Skip the final snapshot on destroy. true is only acceptable for labs."
  type        = bool
  default     = true
}

variable "deletion_protection" {
  description = "Block deletion of the DB instance."
  type        = bool
  default     = false
}

variable "tags" {
  description = "Tags applied to every resource in the module."
  type        = map(string)
  default     = {}
}
