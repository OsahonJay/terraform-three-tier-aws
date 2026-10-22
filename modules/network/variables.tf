variable "name" {
  description = "Prefix used in resource names."
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC."
  type        = string
}

variable "azs" {
  description = "Availability zones to spread subnets across."
  type        = list(string)
}

variable "public_subnet_cidrs" {
  description = "One public subnet CIDR per AZ (web tier, ALB, NAT)."
  type        = list(string)
}

variable "app_subnet_cidrs" {
  description = "One private app subnet CIDR per AZ."
  type        = list(string)
}

variable "db_subnet_cidrs" {
  description = "One isolated database subnet CIDR per AZ."
  type        = list(string)
}

variable "single_nat_gateway" {
  description = "true = one shared NAT Gateway (cheap), false = one per AZ (resilient)."
  type        = bool
}

variable "flow_log_retention_days" {
  description = "Days to keep VPC flow logs in CloudWatch."
  type        = number
  default     = 7
}

variable "tags" {
  description = "Tags applied to every resource in the module."
  type        = map(string)
  default     = {}
}
