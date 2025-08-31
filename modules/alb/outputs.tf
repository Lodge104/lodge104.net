output "alb_dns_name" {
  description = "DNS name of the ALB"
  value       = aws_lb.wordpress_alb.dns_name
}

output "alb_arn" {
  description = "ARN of the ALB"
  value       = aws_lb.wordpress_alb.arn
}

output "alb_zone_id" {
  description = "Zone ID of the ALB"
  value       = aws_lb.wordpress_alb.zone_id
}

output "target_group_arn" {
  description = "ARN of the target group"
  value       = aws_lb_target_group.wordpress.arn
}