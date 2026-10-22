resource "aws_db_subnet_group" "this" {
  name        = "${var.name}-db-subnets"
  description = "Isolated DB subnets across two AZs"
  subnet_ids  = var.subnet_ids
  tags        = merge(var.tags, { Name = "${var.name}-db-subnets" })
}

resource "aws_db_instance" "this" {
  identifier     = "${var.name}-mysql"
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

  tags = merge(var.tags, { Name = "${var.name}-mysql", Tier = "db" })
}
