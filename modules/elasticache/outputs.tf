output "redis_primary_endpoint" {
  description = "Primary endpoint for the Redis cluster"
  value       = aws_elasticache_cluster.redis.cache_nodes[0].address
}

output "redis_reader_endpoint" {
  description = "Reader endpoint for the Redis cluster (same as primary for single node)"
  value       = aws_elasticache_cluster.redis.cache_nodes[0].address
}

output "redis_port" {
  description = "Port of the Redis cluster"
  value       = aws_elasticache_cluster.redis.cache_nodes[0].port
}

output "redis_replication_group_id" {
  description = "ID of the Redis cluster"
  value       = aws_elasticache_cluster.redis.cluster_id
}

output "redis_configuration_endpoint" {
  description = "Configuration endpoint for the Redis cluster (single node - same as primary)"
  value       = aws_elasticache_cluster.redis.cache_nodes[0].address
}

output "redis_auth_token_enabled" {
  description = "Whether Redis AUTH is enabled"
  value       = false  # Single cluster doesn't support auth token in this configuration
}

output "redis_encryption_at_rest" {
  description = "Whether encryption at rest is enabled"
  value       = false  # Single cluster basic configuration
}

output "redis_encryption_in_transit" {
  description = "Whether encryption in transit is enabled"
  value       = false  # Single cluster basic configuration
}
