output "hosted_zone_id" {
  description = "ID of the Route53 hosted zone"
  value       = var.create_hosted_zone ? aws_route53_zone.main[0].zone_id : var.existing_zone_id
}

output "hosted_zone_name_servers" {
  description = "Name servers for the hosted zone"
  value       = var.create_hosted_zone ? aws_route53_zone.main[0].name_servers : []
}