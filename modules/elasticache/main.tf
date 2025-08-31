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

# ElastiCache Redis Cluster (Single Node for Dev)
resource "aws_elasticache_cluster" "redis" {
  cluster_id           = "${var.project_name}-redis"
  engine               = "redis"
  node_type            = var.node_type
  port                 = var.port
  parameter_group_name = aws_elasticache_parameter_group.redis.name
  
  # Network & Security
  subnet_group_name    = aws_elasticache_subnet_group.redis.name
  security_group_ids   = var.security_group_ids
  
  # Engine Version
  engine_version = var.engine_version

  tags = {
    Name        = "${var.project_name}-redis"
    Environment = var.environment
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
