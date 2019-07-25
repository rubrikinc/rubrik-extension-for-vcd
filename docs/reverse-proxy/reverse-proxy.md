# Reverse Proxy Install Guide

## Scripted Build for Installing and Configuring the Nginx Reverse Proxy

Coming Soon.

## Manually Installing and Configuring Nginx Reverse Proxy

The steps below can be used to install and configure Nginx on an RPM-based linux distribution, e.g. RHEL or CentOS. If you are starting from scratch on a new server, configure the network settings, then install and configure Nginx based on the following steps.
Create the Nginx yum repository
```
vi /etc/yum.repos.d/nginx.repo
```

Add the following to the nginx.repo file
```
CentOS:
[nginx]
name=nginx repo
baseurl=http://nginx.org/packages/mainline/centos/7/$basearch/
gpgcheck=0
enabled=1
RHEL:
[nginx]
name=nginx repo
baseurl=http://nginx.org/packages/mainline/rhel/7/$basearch/
gpgcheck=0
enabled=1
```

Install the packages

```
sudo yum update -y
sudo yum install -y nginx
```

You should have confirmation that the packages installed successfully.
Change directories to the Sites Enabled
```
cd /etc/nginx/sites-enabled
```

Create a new nginx site with a name of the linux host
```
sudo touch rbk-rproxy.domain.com.conf
```

Open the file for editing:
```
sudo vi rbk-rproxy.domain.com.conf
```
Update the the placeholder in the config below<reverse proxy FQDN> with the FQDN you will be using for this Reverses Proxy e.g. rbk-proxy.rubrik.com.
Paste the following config (press i first to allow vi to write):
```
server {
  listen       *:443 ssl;
  server_name  <reverse proxy FQDN>;
  
  location / {
  if ($request_method ~* "(GET|POST|PATCH|DELETE)") {
    add_header "Access-Control-Allow-Origin" "$http_origin" always;
    add_header "Access-Control-Allow-Headers" "Authorization, Origin, X-Requested-With, Content-Type, Accept";
    }
    # Preflighted requests
    if ($request_method = OPTIONS ) {
      add_header "Access-Control-Allow-Origin" "$http_origin" always;
      add_header "Access-Control-Allow-Methods" "GET, POST, OPTIONS, HEAD,, PATCH, DELETE";
      add_header "Access-Control-Allow-Headers" "Authorization, Origin, X-Requested-With, Content-Type, Accept, x-vcloud-authorization";
      return 200;
    }
  proxy_pass https://proxy;
  proxy_redirect     off;
  proxy_set_header   Host $host;
  proxy_set_header   X-Real-IP $remote_addr;
  proxy_set_header   X-Forwarded-For $proxy_add_x_forwarded_for;
  proxy_set_header   X-Forwarded-Host $server_name;
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
  ```

Save the file and exit (in vi hit esc to leave insert mode and type :wq! followed by return to save and quit)
Change to the conf.d directory

```
cd ../conf.d
```

Create the proxy configuration file

```
sudo touch proxy-upstream.conf
```

Edit this file with sudo vi proxy-upstream.conf, and add the following content targeting the Rubrik cluster DNS name or IP; update the placeholder <Rubrik DNS Name> with you 

```
upstream proxy {
     server     <Rubrik DNS Name>:443 fail_timeout=10s;
   }
   ```
   
## Create a Certificate for Nginx Reverse Proxy

Follow the instructions on this blog post to create a self-signed certificate: https://www.humankode.com/ssl/create-a-selfsigned-certificate-for-nginx-in-5-minutes. 
Once complete, restart the Nginx services:

```
sudo nginx -s reload
```

This completes the Reverse Proxy Configuration.