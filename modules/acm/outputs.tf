output "certificate_arn" {
  description = "ARN of the ACM certificate"
  value       = var.domain_name != "" ? aws_acm_certificate_validation.wordpress[0].certificate_arn : ""
}

output "certificate_domain_name" {
  description = "Domain name of the certificate"
  value       = var.domain_name != "" ? aws_acm_certificate.wordpress[0].domain_name : ""
}

output "certificate_status" {
  description = "Status of the certificate"
  value       = var.domain_name != "" ? aws_acm_certificate.wordpress[0].status : ""
}
