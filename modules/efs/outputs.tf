output "file_system_id" {
  description = "ID of the EFS file system"
  value       = aws_efs_file_system.wordpress_efs.id
}

output "file_system_dns_name" {
  description = "DNS name of the EFS file system"
  value       = aws_efs_file_system.wordpress_efs.dns_name
}

output "file_system_arn" {
  description = "ARN of the EFS file system"
  value       = aws_efs_file_system.wordpress_efs.arn
}

output "mount_target_ids" {
  description = "IDs of the EFS mount targets"
  value       = aws_efs_mount_target.wordpress_efs_mount[*].id
}