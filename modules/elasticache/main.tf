# ElastiCache Subnet Group
resource "aws_elasticache_subnet_group" "redis" {
  name       = "${var.project_name}-redis-subnet-group"
  subnet_ids = var.subnet_ids

  tags = {
    Name        = "${var.project_name}-redis-subnet-group"
    Environment = var.environment
  }
}

# ElastiCache Parameter Group
resource "aws_elasticache_parameter_group" "redis" {
  family = var.parameter_group_family
  name   = "${var.project_name}-redis-params"

  # WordPress-optimized Redis parameters
  parameter {
    name  = "maxmemory-policy"
    value = "allkeys-lru"
  }

  parameter {
    name  = "timeout"
    value = "300"
  }

  parameter {
    name  = "tcp-keepalive"
    value = "60"
  }

  tags = {
    Name        = "${var.project_name}-redis-params"
    Environment = var.environment
  }
}

# ElastiCache Redis Replication Group
resource "aws_elasticache_replication_group" "redis" {
  replication_group_id         = "${var.project_name}-redis"
  description                  = "Redis cluster for ${var.project_name} WordPress"
  
  # Redis Configuration
  node_type            = var.node_type
  port                 = var.port
  parameter_group_name = aws_elasticache_parameter_group.redis.name
  
  # Cluster Configuration
  num_cache_clusters         = var.num_cache_clusters
  automatic_failover_enabled = var.automatic_failover_enabled
  multi_az_enabled          = var.multi_az_enabled
  
  # Network & Security
  subnet_group_name  = aws_elasticache_subnet_group.redis.name
  security_group_ids = var.security_group_ids
  
  # Backup & Maintenance
  snapshot_retention_limit = var.snapshot_retention_limit
  snapshot_window         = var.snapshot_window
  maintenance_window      = var.maintenance_window
  
  # Encryption
  at_rest_encryption_enabled = var.at_rest_encryption_enabled
  transit_encryption_enabled = var.transit_encryption_enabled
  auth_token                = var.auth_token_enabled ? var.auth_token : null
  
  # Engine Version
  engine_version = var.engine_version
  
  # Auto Minor Version Upgrade
  auto_minor_version_upgrade = var.auto_minor_version_upgrade

  tags = {
    Name        = "${var.project_name}-redis"
    Environment = var.environment
  }

  lifecycle {
    ignore_changes = [num_cache_clusters]
  }
}

# CloudWatch Log Group for Redis slow log (if enabled)
resource "aws_cloudwatch_log_group" "redis_slow" {
  count             = var.log_deliveries.slow_log ? 1 : 0
  name              = "/aws/elasticache/redis/${var.project_name}"
  retention_in_days = 7

  tags = {
    Name        = "${var.project_name}-redis-logs"
    Environment = var.environment
  }
}
