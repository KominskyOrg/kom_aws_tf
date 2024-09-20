resource "aws_route53_zone" "primary" {
  name = "jaredkominsky.com"
}

resource "aws_route53_record" "alb_record_dev" {
  zone_id = aws_route53_zone.primary.zone_id
  name    = "${var.env}.jaredkominsky.com"
  type    = "A"

  alias {
    name                   = aws_lb.app_alb.dns_name
    zone_id                = aws_lb.app_alb.zone_id
    evaluate_target_health = true
  }
}

resource "aws_lb" "app_alb" {
  name               = "app-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [module.eks.cluster_security_group_id]
  subnets            = var.public_subnets

  enable_deletion_protection = false

  tags = merge(var.tags, {
    "Name" = "app-alb"
  })
}