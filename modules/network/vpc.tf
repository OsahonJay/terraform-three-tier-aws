resource "aws_vpc" "this" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = merge(var.tags, { Name = "${var.name}-vpc" })

  lifecycle {
    precondition {
      condition = (
        length(var.public_subnet_cidrs) == length(var.azs) &&
        length(var.app_subnet_cidrs) == length(var.azs) &&
        length(var.db_subnet_cidrs) == length(var.azs)
      )
      error_message = "Each subnet CIDR list must have exactly one entry per availability zone."
    }
  }
}

# Strip every rule from the default security group so nothing can accidentally use it.
resource "aws_default_security_group" "default" {
  vpc_id = aws_vpc.this.id
  tags   = merge(var.tags, { Name = "${var.name}-default-sg-locked" })
}

# Presentation tier: holds the public web ALB, the web servers and the NAT Gateway.
resource "aws_subnet" "public" {
  count = length(var.azs)

  vpc_id                  = aws_vpc.this.id
  cidr_block              = var.public_subnet_cidrs[count.index]
  availability_zone       = var.azs[count.index]
  map_public_ip_on_launch = true

  tags = merge(var.tags, {
    Name = "${var.name}-public-${var.azs[count.index]}"
    Tier = "public"
  })
}

# Logic tier: internal app ALB and app servers. Outbound internet only through NAT.
resource "aws_subnet" "app" {
  count = length(var.azs)

  vpc_id            = aws_vpc.this.id
  cidr_block        = var.app_subnet_cidrs[count.index]
  availability_zone = var.azs[count.index]

  tags = merge(var.tags, {
    Name = "${var.name}-app-${var.azs[count.index]}"
    Tier = "app"
  })
}

# Data tier: RDS only. No route to the internet in either direction.
resource "aws_subnet" "db" {
  count = length(var.azs)

  vpc_id            = aws_vpc.this.id
  cidr_block        = var.db_subnet_cidrs[count.index]
  availability_zone = var.azs[count.index]

  tags = merge(var.tags, {
    Name = "${var.name}-db-${var.azs[count.index]}"
    Tier = "db"
  })
}
