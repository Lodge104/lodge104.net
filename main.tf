# Main Terraform configuration for WordPress infrastructure

module "vpc" {
  source = "./modules/vpc"
  
  project_name          = var.project_name
  environment          = var.environment
  vpc_cidr             = var.vpc_cidr
  availability_zones   = var.availability_zones
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
  database_subnet_cidrs = var.database_subnet_cidrs
}

module "security" {
  source = "./modules/security"
  
  project_name       = var.project_name
  environment       = var.environment
  vpc_id            = module.vpc.vpc_id
  allowed_ip_ranges = ["0.0.0.0/0"]
}

module "efs" {
  source = "./modules/efs"
  
  project_name       = var.project_name
  environment       = var.environment
  subnet_ids        = module.vpc.private_subnet_ids
  security_group_id = module.security.efs_security_group_id
}

module "elasticache" {
  source = "./modules/elasticache"
  
  project_name       = var.project_name
  environment       = var.environment
  subnet_ids        = module.vpc.database_subnet_ids
  security_group_ids = [module.security.redis_security_group_id]
  node_type         = var.redis_node_type
  num_cache_clusters = var.redis_num_cache_clusters
  auth_token        = var.redis_auth_token
  auth_token_enabled = var.redis_auth_token != ""
}

module "rds" {
  source = "./modules/rds"
  
  project_name           = var.project_name
  environment           = var.environment
  cluster_identifier      = "${var.project_name}-${var.environment}-aurora"
  db_name                = var.db_name
  username               = var.db_username
  password               = var.db_password
  security_group_id      = module.security.database_security_group_id
  subnet_ids             = module.vpc.database_subnet_ids
  backup_retention_period = var.backup_retention_period
  skip_final_snapshot    = var.skip_final_snapshot
  deletion_protection    = var.deletion_protection
  auto_pause            = var.auto_pause
  max_capacity          = var.max_capacity
  min_capacity          = var.min_capacity
}

module "alb" {
  source = "./modules/alb"
  
  project_name         = var.project_name
  environment         = var.environment
  vpc_id              = module.vpc.vpc_id
  public_subnet_ids   = module.vpc.public_subnet_ids
  security_group_ids  = [module.security.alb_security_group_id]
  ssl_certificate_arn = module.acm.certificate_arn
  enable_ssl          = var.domain_name != ""  # Enable SSL if domain is provided
  
  # Backend HTTPS configuration
  enable_https_backend = var.enable_https_backend
  backend_port         = var.enable_https_backend ? 443 : 80
  backend_protocol     = var.enable_https_backend ? "HTTPS" : "HTTP"
}

module "autoscaling" {
  source = "./modules/autoscaling"
  
  project_name             = var.project_name
  environment             = var.environment
  instance_type           = var.instance_type
  min_size                = var.min_size
  max_size                = var.max_size
  desired_capacity        = var.desired_capacity
  subnet_ids              = module.vpc.private_subnet_ids
  target_group_arn        = module.alb.target_group_arn
  security_group_ids      = [module.security.web_security_group_id]
  
  # Database connection
  db_name                 = module.rds.db_name
  db_username             = module.rds.db_username
  db_password             = module.rds.db_password
  db_endpoint             = module.rds.db_endpoint
  
  # EFS
  efs_file_system_id      = module.efs.file_system_id
  
  # Key pair
  key_name                = var.key_name
  
  # AMI
  ami_id                  = var.ami_id
}

module "acm" {
  source = "./modules/acm"
  
  project_name     = var.project_name
  environment     = var.environment
  domain_name     = var.domain_name
  route53_zone_id = var.route53_zone_id
}

module "cloudfront" {
  source = "./modules/cloudfront"
  
  project_name        = var.project_name
  environment        = var.environment
  alb_domain_name    = module.alb.alb_dns_name
  
  # CloudFront configuration
  price_class        = var.cloudfront_price_class
  
  # Cache behaviors
  default_ttl        = var.cloudfront_default_ttl
  max_ttl           = var.cloudfront_max_ttl
  min_ttl           = var.cloudfront_min_ttl
}

module "route53" {
  source = "./modules/route53"
  
  project_name            = var.project_name
  environment            = var.environment
  domain_name            = var.domain_name
  cloudfront_domain_name = module.cloudfront.domain_name
  cloudfront_zone_id     = module.cloudfront.hosted_zone_id
  existing_zone_id       = var.route53_zone_id
  create_hosted_zone     = var.route53_zone_id == ""
}