#!/usr/bin/env bash
set -euxo pipefail

# Basic system setup
export DEBIAN_FRONTEND=noninteractive
apt-get update -y
apt-get install -y nginx ufw fail2ban vnstat

# Allow firewall rules locally
ufw allow OpenSSH
ufw allow 'Nginx Full'
ufw --force enable

# Display IP info and network usage
vnstat --create -i eth0 || true
systemctl enable --now vnstat

# Configure Nginx rate limiting (basic protection)
cat >/etc/nginx/conf.d/ratelimit.conf <<'EOF'
# Rate limiting configuration
limit_req_zone $binary_remote_addr zone=mylimit:10m rate=5r/s;

server {
    listen 80 default_server;
    listen [::]:80 default_server;
    server_name _;

    root /var/www/html;
    index index.html;

    location / {
        limit_req zone=mylimit burst=10 nodelay;
        try_files $uri $uri/ =404;
    }
}
EOF

# Test and reload nginx configuration
nginx -t && systemctl restart nginx

echo "VM startup complete. Nginx is running with rate limiting on port 80."
