# Aurora Serverless v2 Cluster
resource "aws_rds_cluster" "wordpress_aurora" {
  cluster_identifier      = var.cluster_identifier
  engine                 = "aurora-mysql"
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

  tags = {
    Name = "${var.project_name}-${var.environment}-aurora-serverless-v2"
  }
}

# Aurora Serverless v2 DB Instance
resource "aws_rds_cluster_instance" "wordpress_instance" {
  cluster_identifier   = aws_rds_cluster.wordpress_aurora.id
  instance_class       = "db.serverless"
  engine              = aws_rds_cluster.wordpress_aurora.engine
  engine_version      = aws_rds_cluster.wordpress_aurora.engine_version
  publicly_accessible = false

  tags = {
    Name = "${var.project_name}-${var.environment}-aurora-serverless-v2-instance"
  }
}

resource "aws_db_subnet_group" "wordpress_subnet_group" {
  name       = "${var.project_name}-${var.environment}-subnet-group"
  subnet_ids = var.subnet_ids

  tags = {
    Name = "${var.project_name}-${var.environment}-subnet-group"
  }
}