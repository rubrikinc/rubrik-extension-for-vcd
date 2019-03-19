# Quick Start Guide: Rubrik Add-On for vCloud Director

## Introduction to the Rubrik Add-On for vCloud Director

The following section outlines how to get started using the Rubrik Plugin for vCloud Director, including installation and configuration of the plugin as well as how to import the Lifecycle Management plugin, Configure Credentials and leverage RBAC.

## Installing the Rubrik Add-On for vCloud Director

* vCD Instance must be running vCD 9.1.0.2 or newer - This is required due to earlier versions not supporting RxJS and HTTPClient.
* The VMware Lifecycle Management Plugin should be installed and accessible - See section 'VMware LCM' for installation steps

## Prerequisites

### Rubrik Pre-Requisites

* Rubrik must be running CDM 4.2+ for upto vCD 9.1 (9.5 works with the exception of Export)
* Rubrik must be running CDM 5.0+ for vCD 9.1, 9.5
* Rubrik must be configured with a valid SSL Certificate*
* Rubrik must have the vCD Cell Registered - Refer to Rubrik User Guide Section: Adding a vCloud Director instance
* Rubrik Credentials are required to perform tasks via the Extension - Refer to Rubrik Credentials Section

*SSL Certificates that are self signed need to be trusted by the client before the extension will work.

### Additional Pre-Requisites

A Linux server is required to run nginx or any preferred reverse proxy. This guide currently only includes steps for nginx.

### Configuration

#### Nginx Reverse Proxy

In order to reach Rubrik, we need to proxy via Nginx due to CORS restricting access directly. This is a temporary measure until CORS can be whitelisted directly on Rubrik, at which point, the reverse proxy will become redundant.

First, lets build a linux server to host Nginx (rpm only in this guide)

Once we have our server configured with Network Settings, we'll need to install the Nginx Packages:

RHEL:

Create the nginx yum repository:

```
vi /etc/yum.repos.d/nginx.repo
```

Add the following to the file:

CentOS:
```
[nginx]
name=nginx repo
baseurl=http://nginx.org/packages/mainline/centos/7/$basearch/
gpgcheck=0
enabled=1
```

RHEL:
```
[nginx]
name=nginx repo
baseurl=http://nginx.org/packages/mainline/rhel/7/$basearch/
gpgcheck=0
enabled=1
```

Install the packages:

```
sudo yum install nginx
```

You should have confirmation that the packages installed successfully.

Change directories to the Sites Enabled:

```
cd /etc/nginx/sites-enabled
```

Create a new nginx site with a name of the linux host e.g.:

```
sudo touch rbk-rproxy.domain.com.conf
```

Open the file for editing:

```
sudo vi rbk-rproxy.domain.com.conf
```

Paste the following config (press `insert` first to allow vi to write):

```
server {
  listen       *:443 ssl;
  server_name  <reverse proxy dns address>;
  
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

Save the file and exit (in vi hit `esc` to leave `insert` mode and type `:wq!` and hit return to save and quit)

Drop out of the `sites-enabled directory` with `cd..` and browse to:

```
cd ./conf.d
```

Create a new file:

```
sudo touch proxy-upstream.conf
```

Edit this file with `sudo vi proxy-upstream.conf` and add the following content targetting the rubrik cluster DNS name or IP:

```
upstream proxy {
     server     <Rubrik DNS Name e.g. dc-rbk01.domain.com>:443 fail_timeout=10s;
   }
```

Finally, restart the Nginx services `sudo nginx -s reload`

That completes the Reverse Proxy Configuration.

### Installing Lifecycle Management

In order to upload the vCD plugin, we need to install the VMware Lifecycle Management plugin which is used for managing and updating 3rd party plugins. In order to do this, we need access to a terminal and a machine with Java.

Run the following commands from a termainal:

```
git clone https://github.com/vmware/vcd-ext-sdk.git
cd vcd-ext-sdk/java
mvn install
cd ../ui/api-client
mvn generate-sources
yarn
yarn bootstrap
cd ../plugin-lifecycle
yarn build
```

### Deploy LCM

Before you can deploy the extension, we need to create a credential template for use:

Copy `ui_ext_api.ini.template` and paste naming the file `ui_ext_api.ini` e.g. `cp ./ui_ext_api.ini.template ./ui_ext_api.ini`

Once completed, open the file with a text editor and populate the fields:

```
vcduri=https://<vcd-cell-dns-address>
username=<administrator account>
organization=System
password=<administrator password>
```

Save the file. Once saved, run the command `yarn deploy` from within the `plugin-lifecycle` folder and confirm success.

You can confirm that this was successful by logging into the HTML5 Provider Tenant and determine if `Plugin Lifecycle Management` is in the humburger dropdown:

![alt-text](/docs/img/image1.png)

Once confirmed, we can then start configuration of the Rubrik Extension

### Deploy Rubrik Extension

Download the latest release from the Release Tab: https://github.com/rubrikinc/rubrik-extension-for-vcd/releases

We now need to upload this to vCD - start by opening the `Plugin Lifecycle Management` from the HTML5 Provider Portal

![alt-text](/docs/img/image1.png)

Once open, you should see a menu as per below:

![alt-text](/docs/img/image2.png)

Press the `upload` button and you will be prompted with an option to select a file to upload; press this button and navigate to the zip file and confirm you can see the scope of the plugin.

![alt-text](/docs/img/image3.png)

Press Next, and confirm the scope of the plugin (Note: This can be changed later after the plugin is installed).

![alt-text](/docs/img/image4.png)

If you have selected `Scope for Tenants` you will then be brought to a tenant screen; select the tenants that require access to the plugin.

![alt-text](/docs/img/image5.png)

Finally, Finish the Wizard and confirm you can see Rubrik under the name column inside the Plugins window.

You will now have a new menu item in the hamburger dropdown entitled `Data Management`.

To confirm the plugin is working and reverse proxy is working, browse to `Data Management` and open the `Settings` Tab:

![alt-text](/docs/img/image6.png)

In this window, enter the Reverse Proxy address, a Rubrik Username and Password and Press Authorize - the Token field should populate once completed. Browse back to `Protection` and confirm that vApps load in the UI:

![alt-text](/docs/img/image7.png)

The plugin installation is now complete and the buttons at the top of the screen control the actions for the following:

* On Demand Snapshots
* Assign SLA Protection
* Recover vApp
* File Recovery
* Export vApp
* Credential Management

### Using the extension as a Provider

The provider portal provides additional functionlity than the tenant can see. Using this portal, you will need to login to Rubrik via the settings tab and using the `Configure Rubrik Credentials` form.

### Setting Up Tenant Permissions

Open the extension from the Provider portal, and browse into the Settings Tab.

Use the Add Credentials to assign credentials to a Tenant; the tenant will be informed to contact an admin to setup credentials until this is completed.

![alt-text](/docs/img/image8.png)

### Rubrik Permissions

Since the vCD portal generates a token from the credentials entered, we can use Rubrik Multi-Tenancy to control features and access to various features.

It's recommended that if SLAs are to be restricted the credentials for the Tenant should also be restricted to their Archival Targers, SLAs and VMs within Rubrik.

This is outlined in the Rubrik User Guide Chapter 4 - Multitenant Organizations. We will use the user's existing permissions from vCloud Director to ensure we remain compliant with the existing RBAC models.
