data "aws_availability_zones" "available" {
  state = "available"
}

# Latest Amazon Linux 2023 AMI, published by AWS as a public SSM parameter.
data "aws_ssm_parameter" "al2023" {
  name = "/aws/service/ami-amazon-linux-latest/al2023-ami-kernel-default-x86_64"
}

locals {
  name = "${var.project}-${var.environment}"
  azs  = slice(data.aws_availability_zones.available.names, 0, var.az_count)

  tags = {
    Project     = var.project
    Environment = var.environment
    Owner       = var.owner
    ManagedBy   = "terraform"
  }
}

# ---------------------------------------------------------------------------
# Networking: VPC, subnets, IGW, NAT, route tables
# ---------------------------------------------------------------------------
module "network" {
  source = "./modules/network"

  name                = local.name
  vpc_cidr            = var.vpc_cidr
  azs                 = local.azs
  public_subnet_cidrs = var.public_subnet_cidrs
  app_subnet_cidrs    = var.app_subnet_cidrs
  db_subnet_cidrs     = var.db_subnet_cidrs
  single_nat_gateway  = var.single_nat_gateway
}

module "security" {
  source = "./modules/security"

  name     = local.name
  vpc_id   = module.network.vpc_id
  app_port = var.app_port
}

# ---------------------------------------------------------------------------
# Data tier: RDS MySQL in the isolated DB subnets
# ---------------------------------------------------------------------------
module "database" {
  source = "./modules/database"

  name               = local.name
  subnet_ids         = module.network.db_subnet_ids
  security_group_ids = [module.security.db_sg_id]
  engine_version     = var.db_engine_version
  instance_class     = var.db_instance_class
  allocated_storage  = var.db_allocated_storage
  db_name            = var.db_name
  username           = var.db_username
  multi_az           = var.db_multi_az
}

# ---------------------------------------------------------------------------
# Logic tier: internal ALB + app servers in private subnets
# ---------------------------------------------------------------------------
module "app_alb" {
  source = "./modules/alb"

  name               = "${local.name}-app"
  internal           = true
  vpc_id             = module.network.vpc_id
  subnet_ids         = module.network.app_subnet_ids
  security_group_ids = [module.security.app_alb_sg_id]
  target_port        = var.app_port
  health_check_path  = "/health"
}

data "aws_iam_policy_document" "app_secrets" {
  statement {
    sid       = "ReadDbCredentials"
    actions   = ["secretsmanager:GetSecretValue"]
    resources = [module.database.master_user_secret_arn]
  }
}

module "app_tier" {
  source = "./modules/compute"

  name               = "${local.name}-app"
  tier               = "app"
  ami_id             = data.aws_ssm_parameter.al2023.insecure_value
  instance_type      = var.instance_type
  subnet_ids         = module.network.app_subnet_ids
  security_group_ids = [module.security.app_sg_id]
  target_group_arns  = [module.app_alb.target_group_arn]
  min_size           = var.app_asg.min
  max_size           = var.app_asg.max
  desired_capacity   = var.app_asg.desired
  tags               = local.tags

  attach_extra_policy = true
  extra_policy_json   = data.aws_iam_policy_document.app_secrets.json

  user_data = templatefile("${path.module}/templates/app_user_data.sh.tftpl", {
    aws_region    = var.aws_region
    app_port      = var.app_port
    db_host       = module.database.address
    db_port       = module.database.port
    db_name       = module.database.db_name
    db_secret_arn = module.database.master_user_secret_arn
  })
}

# ---------------------------------------------------------------------------
# Presentation tier: internet-facing ALB + Apache web servers
# ---------------------------------------------------------------------------
module "web_alb" {
  source = "./modules/alb"

  name               = "${local.name}-web"
  internal           = false
  vpc_id             = module.network.vpc_id
  subnet_ids         = module.network.public_subnet_ids
  security_group_ids = [module.security.web_alb_sg_id]
  target_port        = 80
  health_check_path  = "/health.html"
}

module "web_tier" {
  source = "./modules/compute"

  name               = "${local.name}-web"
  tier               = "web"
  ami_id             = data.aws_ssm_parameter.al2023.insecure_value
  instance_type      = var.instance_type
  subnet_ids         = module.network.public_subnet_ids
  security_group_ids = [module.security.web_sg_id]
  target_group_arns  = [module.web_alb.target_group_arn]
  min_size           = var.web_asg.min
  max_size           = var.web_asg.max
  desired_capacity   = var.web_asg.desired
  tags               = local.tags

  user_data = templatefile("${path.module}/templates/web_user_data.sh.tftpl", {
    app_alb_dns = module.app_alb.dns_name
  })
}
