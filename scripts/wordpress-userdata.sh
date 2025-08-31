#!/bin/bash

# Update system
yum update -y

# Install utilities
yum install -y amazon-efs-utils wget

# Install Apache web server
yum install -y httpd

# Install PHP 8 and required extensions
amazon-linux-extras install -y php8.0
yum install -y php-mysqlnd php-fpm php-xml php-mbstring php-json php-gd php-zip php-redis

# Install mod_ssl for HTTPS support
yum install -y mod_ssl openssl

# Generate self-signed SSL certificate for backend encryption
mkdir -p /etc/ssl/private
openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
    -keyout /etc/ssl/private/apache-selfsigned.key \
    -out /etc/ssl/certs/apache-selfsigned.crt \
    -subj "/C=US/ST=State/L=City/O=Organization/CN=${primary_domain}"

# Set proper permissions on SSL files
chmod 600 /etc/ssl/private/apache-selfsigned.key
chmod 644 /etc/ssl/certs/apache-selfsigned.crt

# Start and enable Apache
systemctl start httpd
systemctl enable httpd

# Create EFS mount point
mkdir -p /var/www/efs

# Mount EFS file system
echo "${efs_file_system_id}.efs.$(curl -s http://169.254.169.254/latest/meta-data/placement/availability-zone | sed 's/[a-z]$//).amazonaws.com:/ /var/www/efs efs defaults,_netdev" >> /etc/fstab
mount -a

# Create WordPress directory in EFS if it doesn't exist
if [ ! -d "/var/www/efs/wordpress" ]; then
    mkdir -p /var/www/efs/wordpress
    
    # Download and extract WordPress
    cd /tmp
    wget https://wordpress.org/latest.tar.gz
    tar -xzf latest.tar.gz
    cp -r wordpress/* /var/www/efs/wordpress/
    
    # Set proper permissions
    chown -R apache:apache /var/www/efs/wordpress/
    chmod -R 755 /var/www/efs/wordpress/
    
    # Create wp-config.php
    cp /var/www/efs/wordpress/wp-config-sample.php /var/www/efs/wordpress/wp-config.php
    
    # Configure database connection
    sed -i "s/database_name_here/${db_name}/g" /var/www/efs/wordpress/wp-config.php
    sed -i "s/username_here/${db_username}/g" /var/www/efs/wordpress/wp-config.php
    sed -i "s/password_here/${db_password}/g" /var/www/efs/wordpress/wp-config.php
    sed -i "s/localhost/${db_endpoint}/g" /var/www/efs/wordpress/wp-config.php
    
    # Add additional WordPress configurations
    echo "define('FS_METHOD', 'direct');" >> /var/www/efs/wordpress/wp-config.php
    echo "define('WP_DEBUG', false);" >> /var/www/efs/wordpress/wp-config.php
    
    # WordPress Multi-site Configuration
    echo "define('WP_ALLOW_MULTISITE', true);" >> /var/www/efs/wordpress/wp-config.php
    echo "define('MULTISITE', true);" >> /var/www/efs/wordpress/wp-config.php
    echo "define('SUBDOMAIN_INSTALL', true);" >> /var/www/efs/wordpress/wp-config.php
    echo "define('DOMAIN_CURRENT_SITE', '${primary_domain}');" >> /var/www/efs/wordpress/wp-config.php
    echo "define('PATH_CURRENT_SITE', '/');" >> /var/www/efs/wordpress/wp-config.php
    echo "define('SITE_ID_CURRENT_SITE', 1);" >> /var/www/efs/wordpress/wp-config.php
    echo "define('BLOG_ID_CURRENT_SITE', 1);" >> /var/www/efs/wordpress/wp-config.php
    
    # Cookie domain for multi-site
    echo "define('COOKIE_DOMAIN', '.${primary_domain}');" >> /var/www/efs/wordpress/wp-config.php
    
    # Configure Redis Object Cache (if Redis endpoint is provided)
    if [ ! -z "${redis_endpoint}" ]; then
        echo "define('WP_REDIS_HOST', '${redis_endpoint}');" >> /var/www/efs/wordpress/wp-config.php
        echo "define('WP_REDIS_PORT', ${redis_port});" >> /var/www/efs/wordpress/wp-config.php
        echo "define('WP_REDIS_DATABASE', 0);" >> /var/www/efs/wordpress/wp-config.php
        echo "define('WP_REDIS_TIMEOUT', 1);" >> /var/www/efs/wordpress/wp-config.php
        echo "define('WP_REDIS_READ_TIMEOUT', 1);" >> /var/www/efs/wordpress/wp-config.php
        
        # Add Redis AUTH token if provided
        if [ ! -z "${redis_auth_token}" ]; then
            echo "define('WP_REDIS_PASSWORD', '${redis_auth_token}');" >> /var/www/efs/wordpress/wp-config.php
        fi
        
        # Enable Redis Object Cache
        echo "define('WP_CACHE', true);" >> /var/www/efs/wordpress/wp-config.php
        
        # Download and install Redis Object Cache plugin
        cd /var/www/efs/wordpress/wp-content/plugins/
        wget https://downloads.wordpress.org/plugin/redis-cache.latest-stable.zip
        unzip redis-cache.latest-stable.zip
        rm redis-cache.latest-stable.zip
        chown -R apache:apache redis-cache/
        chmod -R 755 redis-cache/
        
        # Create object-cache.php drop-in
        cp redis-cache/includes/object-cache.php /var/www/efs/wordpress/wp-content/object-cache.php
        chown apache:apache /var/www/efs/wordpress/wp-content/object-cache.php
    fi
    
    # Generate WordPress salts
    SALTS=$(curl -s https://api.wordpress.org/secret-key/1.1/salt/)
    sed -i '/AUTH_KEY/,/NONCE_SALT/d' /var/www/efs/wordpress/wp-config.php
    echo "$SALTS" | sed -i '/DB_COLLATE/r /dev/stdin' /var/www/efs/wordpress/wp-config.php
    
    # Clean up
    rm -rf /tmp/latest.tar.gz /tmp/wordpress
fi

# Create symlink from web root to WordPress in EFS
rm -rf /var/www/html
ln -s /var/www/efs/wordpress /var/www/html

# Configure Apache for WordPress Multi-site
cat > /etc/httpd/conf.d/wordpress.conf << EOF
# HTTP Virtual Host (always available)
<VirtualHost *:80>
    DocumentRoot /var/www/html
    ServerName ${primary_domain}
    ServerAlias *.${primary_domain}
    
    <Directory /var/www/html>
        Options Indexes FollowSymLinks
        AllowOverride All
        Require all granted
    </Directory>
    
    # WordPress Multi-site rewrite rules
    RewriteEngine On
    RewriteBase /
    RewriteRule ^index\.php$ - [L]
    
    # Add a trailing slash to /wp-admin
    RewriteRule ^wp-admin$ wp-admin/ [R=301,L]
    
    RewriteCond %%{REQUEST_FILENAME} -f [OR]
    RewriteCond %%{REQUEST_FILENAME} -d
    RewriteRule ^ - [L]
    RewriteRule ^(wp-(content|admin|includes).*) $1 [L]
    RewriteRule ^(.*\.php)$ $1 [L]
    RewriteRule . index.php [L]
    
    ErrorLog logs/wordpress_error.log
    CustomLog logs/wordpress_access.log combined
</VirtualHost>

EOF

# Add HTTPS Virtual Host if HTTPS backend is enabled
if [ "${enable_https_backend}" = "true" ]; then
    cat >> /etc/httpd/conf.d/wordpress.conf << EOF

# HTTPS Virtual Host for end-to-end encryption
<VirtualHost *:443>
    DocumentRoot /var/www/html
    ServerName ${primary_domain}
    ServerAlias *.${primary_domain}
    
    # SSL Configuration
    SSLEngine on
    SSLCertificateFile /etc/ssl/certs/apache-selfsigned.crt
    SSLCertificateKeyFile /etc/ssl/private/apache-selfsigned.key
    
    # Modern SSL configuration
    SSLProtocol all -SSLv2 -SSLv3 -TLSv1 -TLSv1.1
    SSLCipherSuite ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-CHACHA20-POLY1305:ECDHE-RSA-CHACHA20-POLY1305:DHE-RSA-AES128-GCM-SHA256:DHE-RSA-AES256-GCM-SHA384
    SSLHonorCipherOrder off
    SSLSessionTickets off
    
    <Directory /var/www/html>
        Options Indexes FollowSymLinks
        AllowOverride All
        Require all granted
    </Directory>
    
    # WordPress Multi-site rewrite rules
    RewriteEngine On
    RewriteBase /
    RewriteRule ^index\.php$ - [L]
    
    # Add a trailing slash to /wp-admin
    RewriteRule ^wp-admin$ wp-admin/ [R=301,L]
    
    RewriteCond %%{REQUEST_FILENAME} -f [OR]
    RewriteCond %%{REQUEST_FILENAME} -d
    RewriteRule ^ - [L]
    RewriteRule ^(wp-(content|admin|includes).*) $1 [L]
    RewriteRule ^(.*\.php)$ $1 [L]
    RewriteRule . index.php [L]
    
    ErrorLog logs/wordpress_ssl_error.log
    CustomLog logs/wordpress_ssl_access.log combined
</VirtualHost>

EOF
fi

# Enable Apache rewrite module
sed -i 's/#LoadModule rewrite_module modules\/mod_rewrite.so/LoadModule rewrite_module modules\/mod_rewrite.so/' /etc/httpd/conf/httpd.conf

# Set proper SELinux contexts
setsebool -P httpd_can_network_connect 1
setsebool -P httpd_use_nfs 1

# Restart Apache
systemctl restart httpd

# Install CloudWatch agent
wget https://s3.amazonaws.com/amazoncloudwatch-agent/amazon_linux/amd64/latest/amazon-cloudwatch-agent.rpm
rpm -U ./amazon-cloudwatch-agent.rpm

echo "WordPress installation completed successfully!"