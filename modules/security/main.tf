# Each tier only accepts traffic from the tier directly in front of it:
# internet -> web ALB -> web servers -> app ALB -> app servers -> RDS
# No SSH anywhere. Shell access is through SSM Session Manager.

resource "aws_security_group" "web_alb" {
  #checkov:skip=CKV2_AWS_5:False positive. Attached to ALBs, launch templates and RDS in other modules, which checkov cannot follow
  name        = "${var.name}-web-alb-sg"
  description = "Public web ALB: HTTP from the internet"
  vpc_id      = var.vpc_id
  tags        = merge(var.tags, { Name = "${var.name}-web-alb-sg" })
}

resource "aws_security_group" "web" {
  #checkov:skip=CKV2_AWS_5:False positive. Attached to ALBs, launch templates and RDS in other modules, which checkov cannot follow
  name        = "${var.name}-web-server-sg"
  description = "Web servers: HTTP from the web ALB only"
  vpc_id      = var.vpc_id
  tags        = merge(var.tags, { Name = "${var.name}-web-server-sg" })
}

resource "aws_security_group" "app_alb" {
  #checkov:skip=CKV2_AWS_5:False positive. Attached to ALBs, launch templates and RDS in other modules, which checkov cannot follow
  name        = "${var.name}-app-alb-sg"
  description = "Internal app ALB: HTTP from web servers only"
  vpc_id      = var.vpc_id
  tags        = merge(var.tags, { Name = "${var.name}-app-alb-sg" })
}

resource "aws_security_group" "app" {
  #checkov:skip=CKV2_AWS_5:False positive. Attached to ALBs, launch templates and RDS in other modules, which checkov cannot follow
  name        = "${var.name}-app-server-sg"
  description = "App servers: app port from the app ALB only"
  vpc_id      = var.vpc_id
  tags        = merge(var.tags, { Name = "${var.name}-app-server-sg" })
}

resource "aws_security_group" "db" {
  #checkov:skip=CKV2_AWS_5:False positive. Attached to ALBs, launch templates and RDS in other modules, which checkov cannot follow
  name        = "${var.name}-db-sg"
  description = "RDS MySQL: 3306 from app servers only"
  vpc_id      = var.vpc_id
  tags        = merge(var.tags, { Name = "${var.name}-db-sg" })
}

# Web ALB
resource "aws_vpc_security_group_ingress_rule" "web_alb_http" {
  #checkov:skip=CKV_AWS_260:Intentional. This is the public entry point; the internet must reach the web ALB on 80 (HTTPS needs a domain, see README)
  security_group_id = aws_security_group.web_alb.id
  description       = "HTTP from the internet"
  ip_protocol       = "tcp"
  from_port         = 80
  to_port           = 80
  cidr_ipv4         = "0.0.0.0/0"
}

resource "aws_vpc_security_group_egress_rule" "web_alb_to_web" {
  security_group_id            = aws_security_group.web_alb.id
  description                  = "Forward to web servers"
  ip_protocol                  = "tcp"
  from_port                    = 80
  to_port                      = 80
  referenced_security_group_id = aws_security_group.web.id
}

# Web servers
resource "aws_vpc_security_group_ingress_rule" "web_from_alb" {
  #checkov:skip=CKV_AWS_260:False positive. Source is a security group, not 0.0.0.0/0
  security_group_id            = aws_security_group.web.id
  description                  = "HTTP from the web ALB"
  ip_protocol                  = "tcp"
  from_port                    = 80
  to_port                      = 80
  referenced_security_group_id = aws_security_group.web_alb.id
}

resource "aws_vpc_security_group_egress_rule" "web_all" {
  security_group_id = aws_security_group.web.id
  description       = "Package installs, SSM, and calls to the app ALB"
  ip_protocol       = "-1"
  cidr_ipv4         = "0.0.0.0/0"
}

# App ALB
resource "aws_vpc_security_group_ingress_rule" "app_alb_from_web" {
  #checkov:skip=CKV_AWS_260:False positive. Source is a security group, not 0.0.0.0/0
  security_group_id            = aws_security_group.app_alb.id
  description                  = "HTTP from web servers"
  ip_protocol                  = "tcp"
  from_port                    = 80
  to_port                      = 80
  referenced_security_group_id = aws_security_group.web.id
}

resource "aws_vpc_security_group_egress_rule" "app_alb_to_app" {
  security_group_id            = aws_security_group.app_alb.id
  description                  = "Forward to app servers"
  ip_protocol                  = "tcp"
  from_port                    = var.app_port
  to_port                      = var.app_port
  referenced_security_group_id = aws_security_group.app.id
}

# App servers
resource "aws_vpc_security_group_ingress_rule" "app_from_alb" {
  security_group_id            = aws_security_group.app.id
  description                  = "App port from the app ALB"
  ip_protocol                  = "tcp"
  from_port                    = var.app_port
  to_port                      = var.app_port
  referenced_security_group_id = aws_security_group.app_alb.id
}

resource "aws_vpc_security_group_egress_rule" "app_all" {
  security_group_id = aws_security_group.app.id
  description       = "Outbound via NAT (packages, SSM, Secrets Manager) and to RDS"
  ip_protocol       = "-1"
  cidr_ipv4         = "0.0.0.0/0"
}

# Database. No egress rules at all: RDS never needs to start a connection.
resource "aws_vpc_security_group_ingress_rule" "db_from_app" {
  security_group_id            = aws_security_group.db.id
  description                  = "MySQL from app servers"
  ip_protocol                  = "tcp"
  from_port                    = 3306
  to_port                      = 3306
  referenced_security_group_id = aws_security_group.app.id
}
