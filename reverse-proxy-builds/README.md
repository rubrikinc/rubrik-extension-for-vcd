# Nginx Reverse Proxy Automated Builds

## Debian

* Debian Script Coming Soon

## RHEL/CentOS

`rhel_proxy.sh` is an automated bash script to build the reverse proxy on CentOS 7; this can be adapted to RHEL with a few minor adjustments to change the repo to point to the official RHEL repo for installing Nginx.

Pre-Requsities:

Find and replace the following placeholders:

`<Reverse Proxy DNS/IP Addresds e.g. rproxy.rubrikdemo.com>`: This will be the DNS or IP Address of the Proxy Server
`<Upstream Server Placeholder>`: This will be the DNS or IP or the Rubrik Cluster

The script will do the following:
* Setup the Nginx Repo
* Install Epel-Release, PolicyCoreUtils for managing SELinux
* permit 80 and 443 in firewall-cmd
* Re-write the global Nginx config
* Create the Sites-Enabled Proxy Config
* Create the TLS Certificate Folders
* Generate Self-Signed Certs (This can be removed - remove code between the `------` lines)
    * There will be a guide setup point here to setup the certificate passphrases and values
* Setup Cache Directories for Nginx Cache
* Configure SELinux to permit httpd_t and rate limit
* Start Nginx Services

## Docker

* Dockerfile/Compose Coming Soon

## Kubernetes

* K8s Coming Soon
