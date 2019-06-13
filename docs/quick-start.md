# Quick Start Guide: Rubrik Extension for vCloud Director

## Patch Notes - 1.1.0

### Existing Features

* On Demand Snapshots
* Assign SLA Protection
* Recover vApp
* File Recovery
* Export vApp
* Credential Management

### New Features for 1.1.0
* Dashboard Feature
    * Protected vApps
    * SLA Summary
    * Summary Graphs
* Reporting 
    * SLA Compliance - Details
    * Capacity Over Time - Details
    * Protection/Recovery Tasks - Details
* Username Encryption Added for Metadata
* Branding/White-label added
* Ability to see Events per vApp
* Event Series - In depth task details
* Provider Authentication Moved inside Modal
* Rubrik Organisation Support - Global and Org both supported

### Bug Fixes
* Fixed a bug with metadata updating/deleting
* Fixed a bug with vApps containing `+` symbols
* Fixed Issues with Tenant access to 2x vCD Cells in Rubrik with a same named vApp
* Fixed Issues with SLAs not loading - Rubrik Version (4.2 and 5.0+) detection added including SLAv2 Support
* Re-written Data Population for Protection Data-grid - async callbacks
* Polaris Managed SLAs temporarily hidden - Breaking On-Demand and SLA Assignment
* File Recovery Form Crashes after running Export (Refresh to Fix)
* Export Showing Fields to name vApp when Restoring to existing
* Export Not resetting all fields on cancel

## Introduction to the Rubrik Extension for vCloud Director

The following section outlines how to get started using the Rubrik Extension for vCloud Director. This includes installation and configuration of the plug-in, as well as how to import the [Lifecycle Management Plug-in](https://github.com/vmware/vcd-ext-sdk/tree/master/ui/plugin-lifecycle), configure credentials and leverage role-based access control (RBAC).

Workflow for installing the extension:
1. Install and Configure Nginx Reverse Proxy
2. Create a Certificate for Nginx Reverse Proxy
3. Build the VMware vCD Lifecycle Management Plug-in
4. Install the VMware vCD Lifecycle Management Plug-in
5. Deploy the Rubrik Extension for vCloud Directory
6. Configure the Rubrik Extension for vCloud Directory

### Rubrik Prerequisites

* Rubrik CDM 4.2+: Supports vCD 8.10 - 9.1
  * vCD 9.5 works with the exception of the "Export vApp" function
* Rubrik CDM 5.0: Supports vCD 8.10 - 9.5
* Rubrik CDM must be configured with a valid SSL Certificate
  * SSL Certificates that are self signed need to be trusted by the client before the extension will work
* Rubrik CDM must have the vCloud Director (vCD) Cell Registered. Refer to Rubrik User Guide Section: "Adding a vCloud Director instance".
* Rubrik Credentials are required to perform tasks via the Extension. Refer to "Using the Extension" Section.

### Additional Prerequisites

* vCD must be version 9.1.0.2 or newer. This is required due to earlier versions not supporting RxJS and HTTPClient.
* A Linux server is required to run [nginx](https://www.nginx.com/), or another preferred reverse proxy. This guide currently only includes steps for installing and configuring nginx.
* The VMware [Lifecycle Management Plug-in](https://github.com/vmware/vcd-ext-sdk/tree/master/ui/plugin-lifecycle) is used to install the Rubrik Extension for vCloud Director. Steps to build and install this plug-in are detailed below.

## Upgrading from 1.0.x

If the extension is already in use, we can upgrade the extension simply by installing through the existing Plugin Lifecycle Manager. 
You can upload to the plugin and disable to the previous version (1.0.x can be deleted after you are happy the upgrade is working).

:exclamation: Prior to allowing the extension for use, we will need to update the metadata as we now encrpyt the the username field as well as the password.

To perform these steps, open the `Settings` tab in provider view and first hit `Authenticate` and login. Once logged in, press `close` and select `Add/Update Metadata`.

Complete the wizard for the tenants you are adding metadata for and also selecting a Rubrik Organization:

* Use `Global` if you are not using any Rubrik Organization
* Select the relevant Rubrik Organization from the drop-down which is configured with the vApps and VM required.

Features are also new which allow white-label and Dashboard features on a per-tenant basis, use the sliders to enable the feature.

Select `Next` and `Confirm` to save the new metadata.

Open a tenant to confirm the vApps load in the `Protection` tab and the White-label/Dashboard features work as intended.

## Installing and Configuring Nginx Reverse Proxy

In order to commnuicate with Rubrik CDM, we need to proxy via nginx due to [CORS](https://en.wikipedia.org/wiki/Cross-origin_resource_sharing) restricting access directly. This is a temporary measure until CORS can be whitelisted directly on Rubrik, at which point the reverse proxy will no longer be needed.

The steps below can be used to install and configure nginx on an RPM-based linux distribution, e.g. RHEL or CentOS. If you are starting from scratch on a new server, configure the network settings, then install and configure nginx based on the following steps.

1. Create the nginx yum repository

```
vi /etc/yum.repos.d/nginx.repo
```

2. Add the following to the nginx.repo file

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

3. Install the packages

```
sudo yum update -y
sudo yum install -y nginx
```

You should have confirmation that the packages installed successfully.

4. Change directories to the Sites Enabled

```
cd /etc/nginx/sites-enabled
```

5. Create a new nginx site with a name of the linux host

```
sudo touch rbk-rproxy.domain.com.conf
```

6. Open the file for editing:

```
sudo vi rbk-rproxy.domain.com.conf
```

7. Paste the following config (press `i` first to allow vi to write):

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

Save the file and exit (in vi hit `esc` to leave `insert` mode and type `:wq!` follwed by return to save and quit)

8. Change to the `conf.d` directory

```
cd ../conf.d
```

9. Create the proxy configuration file

```
sudo touch proxy-upstream.conf
```

10. Edit this file with `sudo vi proxy-upstream.conf`, and add the following content targetting the rubrik cluster DNS name or IP

```
upstream proxy {
     server     <Rubrik DNS Name e.g. dc-rbk01.domain.com>:443 fail_timeout=10s;
   }
```

## Create a Certificate for Nginx Reverse Proxy

Follow the instructions on this blog post to create a self-signed certificate: [https://www.humankode.com/ssl/create-a-selfsigned-certificate-for-nginx-in-5-minutes](https://www.humankode.com/ssl/create-a-selfsigned-certificate-for-nginx-in-5-minutes). Once complete, restart the Nginx services `sudo nginx -s reload`. This completes the Reverse Proxy Configuration.

## Building the VMware vCD Lifecycle Management Plug-in

In order to upload the Rubrik plugin to vCD, we need to build and install the VMware Lifecycle Management Plug-in. This is used for managing and updating 3rd party plugins. In order to do this, we need access to an RPM-based Linux machine. 

1. Connect to the Linux machine you will use to build the plugin, and install the necessary prerequisites. You will install Apache Maven via `yum` so the appropriate dependencies are installed, then uninstall it. The build process depends on a newer version of Maven than the one available via `yum`, so you will download the recent release and install it.
```
sudo yum update -y
sudo yum install -y git maven wget epel-release GConf2
sudo yum remove -y maven
sudo yum update -y
sudo yum install -y python2-pip
sudo pip install configparser
wget http://mirror.olnevhost.net/pub/apache/maven/maven-3/3.6.0/binaries/apache-maven-3.6.0-bin.tar.gz
tar xvfz apache-maven-3.6.0-bin.tar.gz
export PATH=$(pwd)/apache-maven-3.6.0/bin:$PATH
```

2. Install Google Chrome

```
wget https://dl.google.com/linux/direct/google-chrome-stable_current_x86_64.rpm
sudo yum localinstall -y google-chrome-stable_current_x86_64.rpm
```

3. Install Yarn

```
curl --silent --location https://dl.yarnpkg.com/rpm/yarn.repo | sudo tee /etc/yum.repos.d/yarn.repo
curl --silent --location https://rpm.nodesource.com/setup_8.x | sudo bash -
sudo yum -y install yarn
```

4. Clone the [vCD Extension SDK](https://github.com/vmware/vcd-ext-sdk) from Github and begin the build process.

```
git clone https://github.com/vmware/vcd-ext-sdk.git
cd vcd-ext-sdk/java
mvn install
cd ../ui/api-client
mvn generate-sources
yarn
```

5. Edit the `packages/sdk/karma.conf.js` file to pass additional configuration parameters to Chrome. Find this line:

```
browsers: ['ChromeHeadless'],
```

Replace the line above with:

```
browsers: ['HeadlessChrome'],
customLaunchers:{
    HeadlessChrome:{
        base: 'ChromeHeadless',
        flags: [
        '--no-sandbox',
        '--headless',
        '--disable-gpu',
        '--disable-translate',
        '--disable-extensions'
        ]
    }
},
```

6. Complete the build

```
yarn bootstrap
cd ../plugin-lifecycle
yarn build
```

## Installing the VMware vCD Lifecycle Management Plug-in

1. Before you deploying the extension, create a credential template for use

`cp ./ui_ext_api.ini.template ./ui_ext_api.ini` 

2. Edit `ui_ext_api.ini`, fill in the correct parameters and save the file

```
vcduri=https://<vcd-cell-dns-address>
username=<administrator account>
organization=System
password=<administrator password>
```

3. Run `yarn deploy` to deploy the plug-in to vCD based on the parameters you specified. You can confirm that plug-in installation was successful by logging into the HTML5 Provider Tenant portal (`https://yourvcd.domain.com/provider`) and verify that `Plugin Lifecycle Management` is in the humburger dropdown:

![alt-text](/docs/img/image1.png)

Once confirmed, we can then start configuration of the Rubrik extension

## Deploy Rubrik Extension

1. Download the latest release from [https://github.com/rubrikinc/rubrik-extension-for-vcd/releases](https://github.com/rubrikinc/rubrik-extension-for-vcd/releases)

2. Open `Plugin Lifecycle Management` from the HTML5 Provider Portal

![alt-text](/docs/img/image1.png)

Once open, you should see a menu as per below:

![alt-text](/docs/img/image2.png)

3. Press the `upload` button and you will be prompted with an option to select a file to upload; press this button and navigate to the zip file and confirm you can see the scope of the plug-in.

![alt-text](/docs/img/image3.png)

4. Press Next, and confirm the scope of the plug-in (Note: This can be changed later after the plug-in is installed).

![alt-text](/docs/img/image4.png)

5. If you have selected `Scope for Tenants` you will then be brought to a tenant screen; select the tenants that require access to the plug-in.

![alt-text](/docs/img/image5.png)

6. Finally, finish the wizard and confirm you can see Rubrik under the name column inside the plug-ins window. You will now have a new menu item in the hamburger dropdown entitled `Data Management`. To confirm the plug-in is working and the reverse proxy is working, browse to `Data Management` and open the `Settings` Tab:

![alt-text](/docs/img/image6.png)

In this window, enter the Reverse Proxy address, a Rubrik Username and Password and Press Authorize - the Token field should populate once completed. Browse back to `Protection` and confirm that vApps load in the UI:

![alt-text](/docs/img/image7.png)

The plug-in installation is now complete and the buttons at the top of the screen control the actions for the following:

## Using the Extension

The provider portal provides additional functionality beyond what the tenant can see. Using this portal, you will need to login to Rubrik via the settings tab and using the `Configure Rubrik Credentials` form.

### Setting Up Tenant Permissions

Open the extension from the Provider portal, and browse into the Settings Tab.

Use the Add Credentials to assign credentials to a Tenant; the tenant will be informed to contact an admin to setup credentials until this is completed.

![alt-text](/docs/img/image8.png)

### Rubrik Permissions

Since the vCD portal generates a token from the credentials entered, we can use Rubrik Multi-Tenancy to control features and access to various features.

It's recommended that if SLAs are to be restricted the credentials for the Tenant should also be restricted to their Archival Targers, SLAs and VMs within Rubrik. This is outlined in the Rubrik User Guide `Chapter 4 - Multitenant Organizations`. The plug-in will use the user's existing permissions from vCD to ensure we remain compliant with the existing RBAC models.
