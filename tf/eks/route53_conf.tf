data "aws_route53_zone" "primary" {
  name = "jaredkominsky.com"
}

resource "aws_route53_record" "alb_dns_record" {
  zone_id = data.aws_route53_zone.primary.zone_id
  name    = "${var.env}.jaredkominsky.com"
  type    = "A"

  alias {
    name                   = module.alb.dns_name
    zone_id                = module.alb.zone_id
    evaluate_target_health = true
  }

  depends_on = [
    module.alb,
    kubernetes_ingress_v1.app_ingress
  ]
}
