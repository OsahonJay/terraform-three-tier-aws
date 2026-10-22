variable "aws_region" {
  description = "AWS region to deploy into."
  type        = string
  default     = "eu-west-2"
}

variable "project" {
  description = "Project name, used in resource names and tags."
  type        = string
  default     = "three-tier"
}

variable "environment" {
  description = "Environment name."
  type        = string
  default     = "dev"

  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "environment must be dev, staging or prod."
  }
}

variable "owner" {
  description = "Owner tag value."
  type        = string
  default     = "osahon"
}

variable "az_count" {
  description = "Number of availability zones to use. Must match the length of each subnet CIDR list."
  type        = number
  default     = 2
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC."
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidrs" {
  description = "Public subnets (web tier, web ALB, NAT), one per AZ."
  type        = list(string)
  default     = ["10.0.10.0/24", "10.0.11.0/24"]
}

variable "app_subnet_cidrs" {
  description = "Private app subnets, one per AZ."
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "db_subnet_cidrs" {
  description = "Isolated DB subnets, one per AZ."
  type        = list(string)
  default     = ["10.0.21.0/24", "10.0.22.0/24"]
}

variable "single_nat_gateway" {
  description = "true = one NAT Gateway (cheaper), false = one per AZ (survives an AZ failure)."
  type        = bool
  default     = true
}

variable "instance_type" {
  description = "EC2 instance type for web and app servers."
  type        = string
  default     = "t3.micro"
}

variable "web_asg" {
  description = "Web tier Auto Scaling sizes."
  type = object({
    min     = number
    max     = number
    desired = number
  })
  default = { min = 2, max = 4, desired = 2 }
}

variable "app_asg" {
  description = "App tier Auto Scaling sizes."
  type = object({
    min     = number
    max     = number
    desired = number
  })
  default = { min = 2, max = 4, desired = 2 }
}

variable "app_port" {
  description = "Port the app servers listen on."
  type        = number
  default     = 8080
}

variable "db_engine_version" {
  description = "RDS MySQL major version."
  type        = string
  default     = "8.4"
}

variable "db_instance_class" {
  description = "RDS instance class."
  type        = string
  default     = "db.t3.micro"
}

variable "db_allocated_storage" {
  description = "RDS storage in GiB."
  type        = number
  default     = 20
}

variable "db_name" {
  description = "Initial database name."
  type        = string
  default     = "appdb"
}

variable "db_username" {
  description = "RDS master username."
  type        = string
  default     = "appadmin"
}

variable "db_multi_az" {
  description = "Run an RDS standby in a second AZ. Doubles DB cost; off for the lab."
  type        = bool
  default     = false
}
