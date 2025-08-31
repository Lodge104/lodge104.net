output "cluster_endpoint" {
  description = "Aurora Serverless cluster endpoint"
  value       = aws_rds_cluster.wordpress_aurora.endpoint
}

output "cluster_reader_endpoint" {
  description = "Aurora Serverless cluster reader endpoint"
  value       = aws_rds_cluster.wordpress_aurora.reader_endpoint
}

output "cluster_port" {
  description = "Aurora Serverless cluster port"
  value       = aws_rds_cluster.wordpress_aurora.port
}

output "cluster_database_name" {
  description = "Aurora Serverless database name"
  value       = aws_rds_cluster.wordpress_aurora.database_name
}

output "cluster_master_username" {
  description = "Aurora Serverless master username"
  value       = aws_rds_cluster.wordpress_aurora.master_username
  sensitive   = true
}

output "cluster_id" {
  description = "Aurora Serverless cluster identifier"
  value       = aws_rds_cluster.wordpress_aurora.cluster_identifier
}