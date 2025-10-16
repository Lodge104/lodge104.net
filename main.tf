# Main Terraform configuration for WordPress infrastructure

module "vpc" {
  source = "./modules/vpc"
  
  project_name          = var.project_name
  environment          = "prod"
  vpc_cidr             = var.vpc_cidr
  availability_zones   = var.availability_zones
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
  database_subnet_cidrs = var.database_subnet_cidrs
}

module "security" {
  source = "./modules/security"
  
  project_name       = var.project_name
  environment       = "prod"
  vpc_id            = module.vpc.vpc_id
  allowed_ip_ranges = ["0.0.0.0/0"]
}

module "efs" {
  source = "./modules/efs"
  
  project_name       = var.project_name
  environment       = "prod"
  subnet_ids        = module.vpc.private_subnet_ids
  security_group_id = module.security.efs_security_group_id
}

# module "elasticache" {
#   source = "./modules/elasticache"
#   
#   project_name       = var.project_name
#   environment       = "prod"
#   subnet_ids        = module.vpc.database_subnet_ids
#   security_group_ids = [module.security.redis_security_group_id]
#   node_type         = var.redis_node_type
#   num_cache_clusters = var.redis_num_cache_clusters
#   auth_token        = var.redis_auth_token
#   auth_token_enabled = var.redis_auth_token != ""
# }

module "rds" {
  source = "./modules/rds"
  
  cluster_identifier      = "${var.project_name}-aurora"
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
  environment         = "prod"
  vpc_id              = module.vpc.vpc_id
  public_subnet_ids   = module.vpc.public_subnet_ids
  security_group_ids  = [module.security.alb_security_group_id]
  ssl_certificate_arn = module.acm.certificate_arn
  enable_https_listener = var.domain_name != "" ? true : false
  
  # Backend HTTPS configuration
  enable_https_backend = var.enable_https_backend
  backend_port         = var.enable_https_backend ? 443 : 80
  backend_protocol     = var.enable_https_backend ? "HTTPS" : "HTTP"
}

module "autoscaling" {
  source = "./modules/autoscaling"
  
  project_name       = var.project_name
  environment       = "prod"
  ami_id            = data.aws_ami.amazon_linux_2.id
  instance_type     = var.instance_type
  key_name          = "wordpress-key" # You'll need to create this key pair
  security_group_ids = [module.security.web_server_security_group_id]
  subnet_ids        = module.vpc.private_subnet_ids
  target_group_arn  = module.alb.target_group_arn
  efs_file_system_id = module.efs.file_system_id
  db_endpoint       = module.rds.cluster_endpoint
  db_name           = var.db_name
  db_username       = var.db_username
  db_password       = var.db_password
  redis_endpoint    = ""  # ElastiCache temporarily disabled
  redis_port        = "6379"
  redis_auth_token  = ""
  primary_domain    = var.domain_name
  enable_https_backend = var.enable_https_backend
  min_size          = var.min_size
  max_size          = var.max_size
  desired_capacity  = var.desired_capacity
}

module "acm" {
  source = "./modules/acm"
  
  project_name     = var.project_name
  environment     = "prod"
  domain_name     = var.domain_name
  route53_zone_id = var.route53_zone_id
}

module "cloudfront" {
  source = "./modules/cloudfront"
  
  project_name         = var.project_name
  environment         = "prod"
  alb_domain_name     = module.alb.alb_dns_name
  domain_name         = var.domain_name
  ssl_certificate_arn = module.acm.certificate_arn
  
  # CloudFront caching configuration
  price_class      = var.cloudfront_price_class
  default_ttl      = var.cloudfront_default_ttl
  max_ttl          = var.cloudfront_max_ttl
  min_ttl          = var.cloudfront_min_ttl
  admin_ttl        = var.cloudfront_admin_ttl
  compress         = var.cloudfront_compress
  query_string     = var.cloudfront_query_string
  cookies_forward  = var.cloudfront_cookies_forward
}

module "route53" {
  source = "./modules/route53"
  
  project_name           = var.project_name
  environment           = "prod"
  domain_name           = var.domain_name
  cloudfront_domain_name = module.cloudfront.cloudfront_domain_name
  cloudfront_zone_id    = module.cloudfront.cloudfront_hosted_zone_id
}