# WordPress Infrastructure on AWS with Aurora Serverless

This project sets up a highly scalable and cost-effective WordPress website infrastructure on AWS using Terraform. The architecture includes EC2 Auto Scaling, Aurora Serverless (MySQL), Elastic File System (EFS), Application Load Balancer (ALB), CloudFront CDN, and Route 53 DNS.

## 🏗️ Architecture Overview

The infrastructure consists of:

- **VPC**: Multi-AZ setup with public, private, and database subnets
- **EC2 Auto Scaling**: Auto-scaling WordPress application servers in private subnets
- **Aurora Serverless**: Serverless MySQL database with automatic scaling
- **ElastiCache Redis**: In-memory caching for improved performance
- **EFS**: Shared file system for WordPress files across instances
- **ALB**: Application Load Balancer with health checks
- **CloudFront**: Global CDN for improved performance
- **Route 53**: DNS management with domain routing
- **Security Groups**: Layered security with least-privilege access

## 📁 Project Structure

```
├── main.tf                    # Main Terraform configuration
├── variables.tf               # Input variables
├── outputs.tf                 # Output values
├── providers.tf               # Provider configurations
├── modules/
│   ├── vpc/                   # VPC, subnets, gateways
│   ├── security/              # Security groups
│   ├── efs/                   # Elastic File System
│   ├── rds/                   # Aurora Serverless cluster
│   ├── elasticache/           # Redis cluster for caching
│   ├── autoscaling/           # Auto Scaling group & launch template
│   ├── alb/                   # Application Load Balancer
│   ├── cloudfront/            # CloudFront distribution
│   └── route53/               # DNS records
├── environments/
│   ├── dev/                   # Development environment configs
│   └── prod/                  # Production environment configs
└── scripts/
    └── wordpress-userdata.sh  # WordPress installation script
```

## 🚀 Quick Start

### Prerequisites

1. AWS CLI configured with appropriate permissions
2. Terraform >= 1.0 installed
3. An AWS key pair for SSH access (optional)
4. Domain name and SSL certificate in ACM (optional)

### S3 Backend Setup (Recommended)

Before deploying your infrastructure, set up remote state storage in S3 for better collaboration and state management:

1. **Automated Setup** (Recommended):

   ```bash
   ./scripts/setup-backend.sh
   ```

2. **Manual Setup**:
   ```bash
   cd bootstrap
   terraform init
   terraform apply
   ```

This creates:

- S3 buckets for state storage (encrypted with versioning)
- DynamoDB tables for state locking
- Proper security configurations

After setup, your environments will automatically use S3 for state storage.

### Deployment Steps

1. **Clone the repository**:

   ```bash
   git clone <repository-url>
   cd lodge104.net
   ```

2. **Configure variables**:

   ```bash
   # For production
   cp environments/prod/terraform.tfvars.example environments/prod/terraform.tfvars

   # For development
   cp environments/dev/terraform.tfvars.example environments/dev/terraform.tfvars

   # Edit the .tfvars file with your specific values
   nano environments/prod/terraform.tfvars
   ```

3. **Initialize Terraform**:

   ```bash
   terraform init
   ```

4. **Plan the deployment**:

   ```bash
   terraform plan -var-file="environments/prod/terraform.tfvars"
   ```

5. **Apply the configuration**:
   ```bash
   terraform apply -var-file="environments/prod/terraform.tfvars"
   ```

## ⚙️ Configuration

### Required Variables

| Variable           | Description              | Example            |
| ------------------ | ------------------------ | ------------------ |
| `project_name`     | Name of the project      | `"lodge104"`       |
| `db_password`      | Aurora database password | `"SecurePass123!"` |
| `domain_name`      | Your domain name         | `"lodge104.net"`   |
| `redis_auth_token` | Redis AUTH token         | `"RedisToken123!"` |

### 🔐 Team Configuration with Parameter Store

For team collaboration, store shared configuration in **AWS Systems Manager Parameter Store** instead of local terraform.tfvars files:

**Benefits:**

- ✅ **Secure Storage**: Encrypted parameters with KMS
- ✅ **Team Access**: IAM-controlled parameter access
- ✅ **Audit Trail**: CloudTrail logging of all changes
- ✅ **Version History**: Track parameter changes over time
- ✅ **Cost Effective**: Free tier for standard parameters

**Setup Process:**

1. **Store team parameters** using the management script:

   ```bash
   ./scripts/manage-parameters.sh wordpress prod us-east-1 setup
   ```

2. **List existing parameters**:

   ```bash
   ./scripts/manage-parameters.sh wordpress prod us-east-1 list
   ```

3. **Deploy using Parameter Store**:
   ```bash
   terraform apply -var="use_parameter_store=true" -var="project_name=wordpress" -var="environment=prod"
   ```

**Parameter Store Structure:**

```
/wordpress/prod/project_name     (String)
/wordpress/prod/domain_name      (String)
/wordpress/prod/vpc_cidr         (String)
/wordpress/prod/db_password      (SecureString)
/wordpress/prod/redis_auth_token (SecureString)
/wordpress/prod/instance_type    (String)
/wordpress/prod/desired_capacity (String)
```

### Optional Variables

| Variable                   | Description           | Default            |
| -------------------------- | --------------------- | ------------------ |
| `instance_type`            | EC2 instance type     | `"t3.micro"`       |
| `min_size`                 | Min ASG size          | `1`                |
| `max_size`                 | Max ASG size          | `5`                |
| `ssl_certificate_arn`      | ACM certificate ARN   | `""`               |
| `redis_node_type`          | Redis instance type   | `"cache.t3.micro"` |
| `redis_num_cache_clusters` | Number of Redis nodes | `2`                |

## 🏷️ Aurora Serverless Features

This implementation uses Aurora Serverless v1 with the following benefits:

- **Automatic Scaling**: Scales between 1-16 ACUs based on demand
- **Auto-Pause**: Pauses during inactivity to save costs
- **No Instance Management**: Fully serverless database
- **MySQL Compatibility**: Works with standard WordPress installations

## 🚀 Redis Caching Features

ElastiCache Redis provides significant performance improvements:

- **Object Caching**: Reduces database queries by caching WordPress objects
- **Session Storage**: Stores user sessions for better scalability
- **Multi-AZ Replication**: High availability with automatic failover
- **Encryption**: Both in-transit and at-rest encryption supported
- **Redis AUTH**: Password protection for secure access
- **WordPress Integration**: Automatic configuration with Redis Object Cache plugin

### Performance Benefits

- **Page Load Speed**: Up to 10x faster page loads with object caching
- **Database Load Reduction**: 80-90% reduction in database queries
- **Session Persistence**: Maintains user sessions across multiple servers
- **Scalability**: Better handling of concurrent users and traffic spikes

## 🌐 WordPress Multi-site Configuration

This infrastructure is configured to support WordPress Multi-site with subdomain-based sites:

### Multi-site Features

- **Subdomain Support**: Automatically handles `*.yourdomain.com` subdomains
- **Wildcard SSL**: ACM certificate covers all subdomains
- **CloudFront Integration**: CDN handles all subdomains seamlessly
- **Shared File System**: EFS ensures consistent files across all sites

### WordPress Multi-site Settings

The userdata script automatically configures WordPress with:

```php
define('WP_ALLOW_MULTISITE', true);
define('MULTISITE', true);
define('SUBDOMAIN_INSTALL', true);
define('DOMAIN_CURRENT_SITE', 'yourdomain.com');
define('COOKIE_DOMAIN', '.yourdomain.com');
```

### DNS Configuration

- **Root Domain**: `yourdomain.com` → Main WordPress site
- **WWW Subdomain**: `www.yourdomain.com` → Redirects to main site
- **Wildcard Subdomain**: `*.yourdomain.com` → WordPress Multi-site subsites

### SSL Certificate Management

The ACM module automatically creates certificates for:

- Root domain (`yourdomain.com`)
- WWW subdomain (`www.yourdomain.com`)
- Wildcard subdomain (`*.yourdomain.com`)

## 🌐 CloudFront Caching Configuration

The CloudFront distribution includes environment-specific caching settings optimized for development vs. production workflows.

### Caching Strategies

**Development Environment (`environments/dev/terraform.tfvars`):**

- **Short Cache Times**: 5-minute default TTL for quick content updates
- **Forward All Cookies**: Easier debugging and development workflow
- **Forward Query Strings**: Better visibility into request parameters
- **Price Class 100**: Cost-effective edge locations

**Production Environment (`environments/prod/terraform.tfvars`):**

- **Long Cache Times**: 24-hour default TTL for optimal performance
- **Whitelist Cookies**: Only forward necessary WordPress cookies
- **Minimal Query Forwarding**: Better cache hit ratios
- **Price Class 200**: Enhanced global performance

### Cache Behaviors

1. **Static Assets** (`*.css`, `*.js`, `/wp-content/uploads/*`): Maximum cache time
2. **WordPress Admin** (`/wp-admin/*`, `/wp-login.php`): No caching
3. **Dynamic Content**: Configurable TTL with cookie whitelisting

### Customization Variables

```hcl
# CloudFront Caching Settings
cloudfront_price_class      = "PriceClass_200"    # All, 200, or 100
cloudfront_default_ttl      = 86400               # Default cache time (seconds)
cloudfront_max_ttl          = 31536000            # Maximum cache time (seconds)
cloudfront_min_ttl          = 0                   # Minimum cache time (seconds)
cloudfront_admin_ttl        = 0                   # Admin area cache time
cloudfront_compress         = true                # Enable compression
cloudfront_query_string     = false               # Forward query strings
cloudfront_cookies_forward  = "whitelist"         # Cookie forwarding strategy
```

## 🔒 Security Features

- **Network Isolation**: WordPress servers in private subnets
- **Security Groups**: Restrictive firewall rules
- **Database Security**: Aurora in isolated database subnets
- **HTTPS**: Optional SSL/TLS termination at ALB and CloudFront
- **End-to-End Encryption**: Optional HTTPS from ALB to instances
- **Access Control**: SSH access from specific IP ranges

### 🔐 End-to-End Encryption Options

This infrastructure supports multiple SSL/TLS configurations:

**Option 1: SSL Termination at ALB (Default)**

- **Client ↔ CloudFront**: HTTPS with ACM certificate
- **CloudFront ↔ ALB**: HTTPS with ACM certificate
- **ALB ↔ Instances**: HTTP (within VPC)
- **Best for**: Cost-effective setup with good security

**Option 2: End-to-End Encryption (Production Recommended)**

- **Client ↔ CloudFront**: HTTPS with ACM certificate
- **CloudFront ↔ ALB**: HTTPS with ACM certificate
- **ALB ↔ Instances**: HTTPS with self-signed certificates
- **Best for**: Maximum security compliance requirements

Enable end-to-end encryption by setting:

```hcl
enable_https_backend = true
```

### SSL Certificate Management

- **ACM Integration**: Automatic wildcard certificate creation and validation
- **Auto-Renewal**: Certificates automatically renewed by AWS
- **Self-Signed Backend**: Generated automatically on instances for backend encryption

## 💰 Cost Optimization

- **Aurora Serverless**: Pay only for database usage
- **Auto Scaling**: Scale instances based on demand
- **CloudFront**: Reduce bandwidth costs
- **EFS**: Shared storage across instances
- **Spot Instances**: Optional cost savings (not implemented)

## 📊 Monitoring & Logging

- **CloudWatch**: Built-in metrics and alarms
- **ALB Health Checks**: Application-level monitoring
- **Auto Scaling Policies**: CPU-based scaling triggers
- **CloudFront Metrics**: CDN performance monitoring

## 🛠️ Customization

### Adding Custom Domains

1. Request an SSL certificate in AWS Certificate Manager
2. Update `ssl_certificate_arn` in your tfvars file
3. Update `domain_name` with your domain
4. Ensure your domain's nameservers point to Route 53

### Scaling Configuration

Modify these variables in your tfvars:

```hcl
min_size = 2
max_size = 10
desired_capacity = 3
min_capacity = 2  # Aurora Serverless
max_capacity = 16 # Aurora Serverless
```

### Multi-Environment Setup

Use different variable files for each environment:

```bash
# Development
terraform apply -var-file="environments/dev/terraform.tfvars"

# Production
terraform apply -var-file="environments/prod/terraform.tfvars"
```

## 🧹 Cleanup

To destroy the infrastructure:

```bash
terraform destroy -var-file="environments/prod/terraform.tfvars"
```

⚠️ **Warning**: This will permanently delete all resources and data.

## 📋 Post-Deployment

1. **Access WordPress**: Navigate to your ALB DNS name or domain
2. **Complete Setup**: Follow WordPress installation wizard
3. **Update DNS**: Point your domain to CloudFront (if using custom domain)
4. **Security**: Update WordPress admin password immediately

## 🔧 Troubleshooting

### Common Issues

1. **Database Connection Failed**: Check security group rules and subnet routing
2. **EFS Mount Errors**: Verify EFS mount targets in correct subnets
3. **Load Balancer 502 Errors**: Check target group health and security groups
4. **CloudFront Not Serving Content**: Verify origin settings and cache behaviors

### Useful Commands

```bash
# Check infrastructure state
terraform state list

# View specific resource
terraform state show module.rds.aws_rds_cluster.wordpress_aurora

# Refresh state
terraform refresh -var-file="environments/prod/terraform.tfvars"
```

## 📝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 🆘 Support

For issues and questions:

1. Check the troubleshooting section
2. Review AWS documentation
3. Open an issue in the repository
   terraform apply

   ```

   ```

4. **Access Your WordPress Site**: Once the infrastructure is provisioned, access your WordPress site using the ALB DNS name or the CloudFront distribution URL.

## 🔧 WordPress Multi-site Setup

After deployment, complete these steps to activate Multi-site:

### 1. Initial WordPress Setup

1. Complete the standard WordPress installation through the web interface
2. Create your admin user and set up the main site

### 2. Enable Multi-site Network

1. Access your WordPress admin dashboard
2. Go to **Tools → Network Setup**
3. Select **Sub-domains** installation type
4. Follow the WordPress Multi-site setup wizard

### 3. Add Network Sites

1. Go to **My Sites → Network Admin → Sites**
2. Click **Add New Site**
3. Create subsites like `blog.yourdomain.com`, `shop.yourdomain.com`, etc.

### 4. DNS Verification

- All subdomains automatically resolve through the wildcard DNS record
- SSL certificates are automatically validated and applied
- CloudFront handles caching for all subdomains

## Notes

- Ensure that you have the necessary permissions to create the resources in your AWS account.
- Modify the `terraform.tfvars` files in the respective environment directories to customize your setup.

For more detailed information on each module and configuration options, please refer to the individual module directories.
