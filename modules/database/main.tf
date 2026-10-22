resource "aws_db_subnet_group" "this" {
  name        = "${var.name}-db-subnets"
  description = "Isolated DB subnets across two AZs"
  subnet_ids  = var.subnet_ids
  tags        = merge(var.tags, { Name = "${var.name}-db-subnets" })
}

locals {
  identifier  = "${var.name}-mysql"
  log_exports = ["error", "slowquery"]
}

# Created by Terraform before the DB, so they get a retention period and are
# deleted on destroy. If RDS created them itself, they would linger forever.
resource "aws_cloudwatch_log_group" "rds" {
  #checkov:skip=CKV_AWS_158:AWS-managed encryption is sufficient for lab logs; a customer KMS key adds cost and key management
  #checkov:skip=CKV_AWS_338:Short retention keeps the lab cheap; production would keep logs for a year or more
  for_each = toset(local.log_exports)

  name              = "/aws/rds/instance/${local.identifier}/${each.value}"
  retention_in_days = var.log_retention_days
  tags              = var.tags
}

resource "aws_db_instance" "this" {
  #checkov:skip=CKV_AWS_157:Multi-AZ doubles DB cost; controlled by var.multi_az and off for the lab
  #checkov:skip=CKV_AWS_293:Deletion protection would block terraform destroy in a lab; controlled by var.deletion_protection
  #checkov:skip=CKV_AWS_118:Enhanced monitoring adds an IAM role and per-second metrics cost; basic CloudWatch metrics are enough here
  identifier     = local.identifier
  engine         = "mysql"
  engine_version = var.engine_version
  instance_class = var.instance_class

  allocated_storage     = var.allocated_storage
  max_allocated_storage = var.allocated_storage * 2
  storage_type          = "gp3"
  storage_encrypted     = true

  db_name  = var.db_name
  username = var.username
  # RDS generates the password and stores it in Secrets Manager.
  # It never appears in Terraform code, variables, or plan output.
  manage_master_user_password = true

  # Lets IAM roles log in with short-lived tokens instead of a password, if wanted later.
  iam_database_authentication_enabled = true

  enabled_cloudwatch_logs_exports = local.log_exports

  db_subnet_group_name   = aws_db_subnet_group.this.name
  vpc_security_group_ids = var.security_group_ids
  publicly_accessible    = false
  multi_az               = var.multi_az

  backup_retention_period    = var.backup_retention_period
  copy_tags_to_snapshot      = true
  auto_minor_version_upgrade = true
  apply_immediately          = true

  # Lab defaults so `terraform destroy` is clean. Flip both for anything real.
  skip_final_snapshot = var.skip_final_snapshot
  deletion_protection = var.deletion_protection

  tags = merge(var.tags, { Name = local.identifier, Tier = "db" })

  depends_on = [aws_cloudwatch_log_group.rds]
}
