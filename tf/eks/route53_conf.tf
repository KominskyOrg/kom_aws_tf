data "aws_route53_zone" "primary" {
  name = "jaredkominsky.com"
}

resource "aws_route53_record" "alb_dns_record" {
  zone_id = data.aws_route53_zone.primary.zone_id
  name    = "${local.infra_env}.jaredkominsky.com"
  type    = "A"

  alias {
    name                   = kubernetes_ingress_v1.app_ingress.status.0.load_balancer.0.ingress.0.hostname
    zone_id                = "Z35SXDOTRQ7X7K"
    evaluate_target_health = true
  }

  depends_on = [
    kubernetes_ingress_v1.app_ingress
  ]
}
