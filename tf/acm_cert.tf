# Request a Wildcard ACM Certificate
resource "aws_acm_certificate" "wildcard_cert" {
  domain_name       = "*.jaredkominsky.com"
  validation_method = "DNS"

  lifecycle {
    create_before_destroy = true
  }

  tags = local.tags
}

# Retrieve the Route53 Hosted Zone
data "aws_route53_zone" "primary" {
  name = "jaredkominsky.com"
}

# Create DNS Validation Records
resource "aws_route53_record" "cert_validation" {
  for_each = {
    for dvo in aws_acm_certificate.wildcard_cert.domain_validation_options : dvo.domain_name => {
      name  = dvo.resource_record_name
      type  = dvo.resource_record_type
      value = dvo.resource_record_value
    }
  }

  zone_id = data.aws_route53_zone.primary.zone_id
  name    = each.value.name
  type    = each.value.type
  ttl     = 60
  records = [each.value.value]
}

# Validate the ACM Certificate
resource "aws_acm_certificate_validation" "wildcard_cert_validation" {
  certificate_arn         = aws_acm_certificate.wildcard_cert.arn
  validation_record_fqdns = [for record in aws_route53_record.cert_validation : record.fqdn]
}
