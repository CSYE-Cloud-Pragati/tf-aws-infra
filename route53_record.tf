resource "aws_route53_record" "webapp_alias" {
  zone_id = var.route53_zone_id # Provide your hosted zone ID (can be looked up via a data source)
  name    = var.domain_name     # e.g., "dev.pragatianrote.me" or "demo.pragatianrote.me"
  type    = "A"

  alias {
    name                   = aws_lb.webapp_alb.dns_name
    zone_id                = aws_lb.webapp_alb.zone_id
    evaluate_target_health = true
  }
}
