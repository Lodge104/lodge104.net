output "redis_primary_endpoint" {
  description = "Primary endpoint for the Redis replication group"
  value       = aws_elasticache_replication_group.redis.primary_endpoint_address
}

output "redis_reader_endpoint" {
  description = "Reader endpoint for the Redis replication group"
  value       = aws_elasticache_replication_group.redis.reader_endpoint_address
}

output "redis_port" {
  description = "Port of the Redis cluster"
  value       = aws_elasticache_replication_group.redis.port
}

output "redis_replication_group_id" {
  description = "ID of the Redis replication group"
  value       = aws_elasticache_replication_group.redis.replication_group_id
}

output "redis_configuration_endpoint" {
  description = "Configuration endpoint for the Redis cluster (if cluster mode enabled)"
  value       = aws_elasticache_replication_group.redis.configuration_endpoint_address
}

output "redis_auth_token_enabled" {
  description = "Whether Redis AUTH is enabled"
  value       = var.auth_token_enabled
}

output "redis_encryption_at_rest" {
  description = "Whether encryption at rest is enabled"
  value       = var.at_rest_encryption_enabled
}

output "redis_encryption_in_transit" {
  description = "Whether encryption in transit is enabled"
  value       = var.transit_encryption_enabled
}
