# Route53 Hosted Zone
resource "aws_route53_zone" "main" {
  count = var.create_hosted_zone ? 1 : 0
  name  = var.domain_name

  tags = {
    Name        = "${var.project_name}-hosted-zone"
    Environment = var.environment
  }
}

# Route53 Records for CloudFront
resource "aws_route53_record" "root" {
  count   = var.domain_name != "" ? 1 : 0
  zone_id = var.create_hosted_zone ? aws_route53_zone.main[0].zone_id : var.existing_zone_id
  name    = var.domain_name
  type    = "A"

  alias {
    name                   = var.cloudfront_domain_name
    zone_id                = var.cloudfront_zone_id
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "www" {
  count   = var.domain_name != "" ? 1 : 0
  zone_id = var.create_hosted_zone ? aws_route53_zone.main[0].zone_id : var.existing_zone_id
  name    = "www.${var.domain_name}"
  type    = "A"

  alias {
    name                   = var.cloudfront_domain_name
    zone_id                = var.cloudfront_zone_id
    evaluate_target_health = false
  }
}

# Wildcard subdomain record for WordPress Multi-site
resource "aws_route53_record" "wildcard" {
  count   = var.domain_name != "" ? 1 : 0
  zone_id = var.create_hosted_zone ? aws_route53_zone.main[0].zone_id : var.existing_zone_id
  name    = "*.${var.domain_name}"
  type    = "A"

  alias {
    name                   = var.cloudfront_domain_name
    zone_id                = var.cloudfront_zone_id
    evaluate_target_health = false
  }
}