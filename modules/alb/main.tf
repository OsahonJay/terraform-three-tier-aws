resource "aws_lb" "this" {
  #checkov:skip=CKV_AWS_150:Deletion protection would block terraform destroy in a lab
  #checkov:skip=CKV_AWS_91:Access logs need a dedicated S3 bucket and policy; out of scope for the lab, flow logs cover network debugging
  #checkov:skip=CKV2_AWS_28:WAF costs about $5/month plus per-rule fees; out of scope for the lab
  #checkov:skip=CKV2_AWS_20:HTTPS needs a domain and ACM certificate, not part of this lab (see README)
  name                       = "${var.name}-alb"
  internal                   = var.internal
  load_balancer_type         = "application"
  security_groups            = var.security_group_ids
  subnets                    = var.subnet_ids
  drop_invalid_header_fields = true

  tags = merge(var.tags, { Name = "${var.name}-alb" })
}

resource "aws_lb_target_group" "this" {
  #checkov:skip=CKV_AWS_378:ALB to instance traffic stays inside the VPC; TLS is terminated at the ALB once a certificate exists
  name                 = "${var.name}-tg"
  port                 = var.target_port
  protocol             = "HTTP"
  target_type          = "instance"
  vpc_id               = var.vpc_id
  deregistration_delay = 30

  health_check {
    path                = var.health_check_path
    matcher             = "200"
    interval            = 15
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 3
  }

  tags = merge(var.tags, { Name = "${var.name}-tg" })
}

resource "aws_lb_listener" "http" {
  #checkov:skip=CKV_AWS_2:HTTPS needs a domain and ACM certificate, not part of this lab (see README)
  #checkov:skip=CKV_AWS_103:HTTPS needs a domain and ACM certificate, not part of this lab (see README)
  load_balancer_arn = aws_lb.this.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.this.arn
  }

  tags = var.tags
}
