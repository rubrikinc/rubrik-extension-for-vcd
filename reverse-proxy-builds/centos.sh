#!/bin/bash

#Script Config Variables
DIR="/etc/tls".
DIRCRT="/etc/tls/crt"
DIRKEY="/etc/tls/key"
CACHE="/var/nginx"
CACHESUB="/var/cache/nginx/"

echo "Installing Packages from Yum..."
echo "Creating nginx.repo file..."
sudo bash -c 'cat <<EOM >/etc/yum.repos.d/nginx.repo
[nginx]
name=nginx repo
baseurl=http://nginx.org/packages/mainline/centos/7/\$basearch/
gpgcheck=0
enabled=1
EOM'

echo "Installing Packages"
sudo yum install -y epel-release policycoreutils
sudo yum install -y nginx policycoreutils-2.5-29.el7.x86_64

echo "Adding Firewall-cmd rules..."
sudo firewall-cmd --permanent --zone=public --add-service=http
sudo firewall-cmd --permanent --zone=public --add-service=https
sudo firewall-cmd --reload

echo "Setting nginx.conf config..."
sudo rm /etc/nginx/nginx.conf
sudo mkdir /etc/nginx/sites-enabled

sudo bash -c 'cat <<EOM >/etc/nginx/nginx.conf

user nginx;
worker_processes 1;
worker_rlimit_nofile 1024;

pid        /var/run/nginx.pid;
error_log  /var/log/nginx/error.log error;

events {
  accept_mutex on;
  accept_mutex_delay 500ms;
  worker_connections 1024;
}

http {

  include       /etc/nginx/mime.types;
  default_type  application/octet-stream;

  access_log  /var/log/nginx/access.log;

  sendfile    on;
  server_tokens off;

  types_hash_max_size 1024;
  types_hash_bucket_size 512;

  server_names_hash_bucket_size 64;
  server_names_hash_max_size 512;

  keepalive_timeout   65s;
  keepalive_requests  256;
  client_body_timeout 60s;
  send_timeout        60s;
  lingering_timeout   5s;
  tcp_nodelay         on;
  reset_timedout_connection on;

  gzip              on;
  gzip_comp_level   1;
  gzip_disable      msie6;
  gzip_min_length   1000;
  gzip_http_version 1.1;
  gzip_proxied      off;
  gzip_vary         off;

  open_file_cache max=50000 inactive=20s;
  open_file_cache_valid 30s;
  open_file_cache_min_uses 2;

  client_body_temp_path   /var/nginx/client_body_temp;
  client_max_body_size    512m;
  client_body_buffer_size 128k;
  proxy_temp_path         /var/nginx/proxy_temp;
  proxy_connect_timeout   90s;
  proxy_send_timeout      90s;
  proxy_read_timeout      90s;
  proxy_buffers           32 4k;
  proxy_buffer_size       8k;
  proxy_set_header        Host \$host;
  proxy_set_header        X-Real-IP \$remote_addr;
  proxy_set_header        X-Forwarded-For \$proxy_add_x_forwarded_for;
  proxy_set_header        Proxy "";
  proxy_headers_hash_bucket_size 64;

  include /etc/nginx/conf.d/*.conf;
  include /etc/nginx/sites-enabled/*;
}
EOM'

sudo bash -c 'cat <<EOM >/etc/nginx/sites-enabled/rbk-rproxy.domain.com.conf

proxy_cache_path /var/cache/nginx/RBK levels=1:2 keys_zone=RBK:1m inactive=24h  max_size=1g;

server {
  listen       *:443 ssl;
  server_name  <Reverse Proxy DNS/IP Addresds e.g. rproxy.rubrikdemo.com>;

  ssl on;
  ssl_certificate           /etc/tls/crt/STAR_wildcard.crt;
  ssl_certificate_key       /etc/tls/key/STAR_wildcard.key;
  ssl_session_cache         shared:SSL:50m;
  ssl_session_timeout       5m;
  ssl_protocols             TLSv1.2;
  ssl_ciphers               ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-AES256-GCM-SHA384:DHE-RSA-AES128-GCM-SHA256:DHE-DSS-AES128-GCM-SHA256:kEDH+AESGCM:ECDHE-RSA-AES128-SHA256:ECDHE-ECDSA-AES128-SHA256:ECDHE-RSA-AES128-SHA:ECDHE-ECDSA-AES128-SHA:ECDHE-RSA-AES256-SHA384:ECDHE-ECDSA-AES256-SHA384:ECDHE-RSA-AES256-SHA:ECDHE-ECDSA-AES256-SHA:DHE-RSA-AES128-SHA256:DHE-RSA-AES128-SHA:DHE-DSS-AES128-SHA256:DHE-RSA-AES256-SHA256:DHE-DSS-AES256-SHA:DHE-RSA-AES256-SHA:ECDHE-RSA-DES-CBC3-SHA:ECDHE-ECDSA-DES-CBC3-SHA:EDH-RSA-DES-CBC3-SHA:AES128-GCM-SHA256:AES256-GCM-SHA384:AES128-SHA256:AES256-SHA256:AES128-SHA:AES256-SHA:AES:CAMELLIA:DES-CBC3-SHA:!aNULL:!eNULL:!EXPORT:!DES:!RC4:!MD5:!PSK:!aECDH:!EDH-DSS-DES-CBC3-SHA:!KRB5-DES-CBC3-SHA;
  ssl_prefer_server_ciphers on;

  location / {
  if (\$request_method ~* "(GET|POST|PATCH|DELETE)") {
    add_header "Access-Control-Allow-Origin" "\$http_origin" always;
    add_header "Access-Control-Allow-Headers" "Authorization, Origin, X-Requested-With, Content-Type, Accept";
    }
    # Preflighted requests
    if (\$request_method = OPTIONS ) {
      add_header "Access-Control-Allow-Origin" "\$http_origin" always;
      add_header "Access-Control-Allow-Methods" "GET, POST, OPTIONS, HEAD,, PATCH, DELETE";
      add_header "Access-Control-Allow-Headers" "Authorization, Origin, X-Requested-With, Content-Type, Accept, x-vcloud-authorization";
      return 200;
    }
  proxy_pass https://proxy;
  proxy_redirect     off;
  proxy_set_header   Host \$host;
  proxy_set_header   X-Real-IP \$remote_addr;
  proxy_set_header   X-Forwarded-For \$proxy_add_x_forwarded_for;
  proxy_set_header   X-Forwarded-Host \$server_name;
  proxy_buffering        on;
  proxy_cache            RBK;
  proxy_cache_valid      200  1m;
  proxy_cache_use_stale  error timeout invalid_header updating http_500 http_502 http_503 http_504;
  proxy_ignore_headers Set-Cookie Cache-Control;
  proxy_connect_timeout       300;
  proxy_send_timeout          300;
  proxy_read_timeout          90m;
  send_timeout                300;
  }
}
upstream proxy {
  server     <Upstream Server Placeholder e.g. rbk01.rubrik.com>:443 fail_timeout=10s;
}
EOM'

echo "Setting up SSL Directory..."

if [ -d "$DIR" ]; then
  echo "/etc/tls directory exists, skipping folder creation..."
else
  sudo mkdir /etc/tls
fi

if [ -d "$DIRCRT" ]; then
  echo "/etc/tls/crt directory exists, skipping folder creation..."
else
  sudo mkdir /etc/tls/crt
fi

if [ -d "$DIRKEY" ]; then
  echo "/etc/tls/key directory exists, skipping folder creation..."
else
  sudo mkdir /etc/tls/key
fi

echo "Generating an SSL private key to sign your certificate..."
sudo openssl genrsa -des3 -out STAR_wildcard.key 1024

echo "Generating a Certificate Signing Request..."
sudo openssl req -new -key STAR_wildcard.key -out STAR_wildcard.csr

echo "Removing passphrase from key (for nginx)..."
sudo cp STAR_wildcard.key STAR_wildcard.key.org
sudo openssl rsa -in STAR_wildcard.key.org -out STAR_wildcard.key
sudo rm STAR_wildcard.key.org

echo "Generating certificate..."
sudo openssl x509 -req -days 365 -in STAR_wildcard.csr -signkey STAR_wildcard.key -out STAR_wildcard.crt

echo "Copying certificate (myssl.crt) to /etc/ssl/certs/"
sudo cp STAR_wildcard.crt /etc/tls/crt

echo "Copying key (myssl.key) to /etc/ssl/private/"
sudo cp STAR_wildcard.key /etc/tls/key

echo "Creating Nginx Cache Directories..."

if [ -d "$CACHE" ]; then
  echo "/var/nginx directory exists, skipping folder creation..."
else
  sudo mkdir /var/nginx
fi

if [ -d "$CACHESUB" ]; then
  echo "/var/cache/nginx/ directory exists, skipping folder creation..."
else
  sudo mkdir /var/cache/nginx/
fi

echo "Permitting SELinux Settings for HTTPD..."
semanage permissive -a httpd_t
setsebool -P httpd_setrlimit 1

echo "Restarting Services..."
sudo service nginx start

echo "Script completed. Confirm reverse proxy works by connecting to the URL defined"