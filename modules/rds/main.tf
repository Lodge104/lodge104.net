# Aurora Serverless Cluster
resource "aws_rds_cluster" "wordpress_aurora" {
  cluster_identifier      = var.cluster_identifier
  engine                 = "aurora-mysql"
  engine_mode            = "serverless"
  engine_version         = var.aurora_engine_version
  database_name          = var.db_name
  master_username        = var.username
  master_password        = var.password
  db_subnet_group_name   = aws_db_subnet_group.wordpress_subnet_group.name
  vpc_security_group_ids = [var.security_group_id]
  backup_retention_period = var.backup_retention_period
  preferred_backup_window = var.backup_window
  preferred_maintenance_window = var.maintenance_window
  skip_final_snapshot    = var.skip_final_snapshot
  deletion_protection    = var.deletion_protection

  scaling_configuration {
    auto_pause               = var.auto_pause
    max_capacity            = var.max_capacity
    min_capacity            = var.min_capacity
    seconds_until_auto_pause = var.seconds_until_auto_pause
  }

  tags = {
    Name = "wordpress-aurora-serverless"
  }
}

resource "aws_db_subnet_group" "wordpress_subnet_group" {
  name       = "wordpress-subnet-group"
  subnet_ids = var.subnet_ids

  tags = {
    Name = "wordpress-subnet-group"
  }
}