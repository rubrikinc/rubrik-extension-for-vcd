# Rubrik vCloud Director (vCD) Extensibility - Early Access#

This is the install guide for the Rubrik vCloud Director Extension

## Pre-Requisites ##

Before the extension can be installed, vCD and Rubrik must meet the following pre-requisites:

## vCD Pre-Requisites

* vCD Instance must be running vCD 9.1.0.2 - This is required due to earlier versions not supporting RxJS and HTTPClient.
* The VMware Lifecycle Management Plugin should be installed and accessible - See section 'VMware LCM' for installation steps

## Rubrik Pre-Requisites

* Rubrik must be running CDM 4.2+ for vCD 9.1+
* Rubrik must be running CDM 5.0+ for vCD 9.5+
* Rubrik must be configured with a valid SSL Certificate*
* Rubrik must have the vCD Cell Registered
* Rubrik Credentials are required to perform tasks via the Extension

*SSL Certificates that are self signed, need to be trusted by the client before the extension will work.

## Additional Pre-Requisites

* To resolve an issues with CORS Security, an Nginx or Apache Reverse Proxy must be configured and include the following in the configuration:
<!-- 
    add something here when we have a solution for persistent data
-->

Sites-Enabled:
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

Conf.d\proxy-upstream.conf

```
upstream proxy {
  server     <Rubrik DNS Name e.g. dc-rbk01.domain.com>:443 fail_timeout=10s;
}
```

** Note: There will be a script created to automate this section.

## Installation

Retrieve the latest version available from Releases within this github repo.
Open the Plugin Lifecycle Management extension and upload a new plugin.
You will be prompted to upload from a file, select `Rubrik_vCD_ext_v1.0.zip` and deploy.

During the installation you will have the option to select if Providers and Tenants are enabled for the plugin, follow the wizard and deploy to the revelant tenants and provider.

Once completed, a new menu item will appear in the Hamburger Menu - entitled Data Management and confirm data populates.

## Early Access Known Issues

* Moving back and forth between menus before previous calls finish, will present duplicate data
* Login form in use in settings until persistent credential storage has been implemented
* DNS Address for Reverse Proxy is hard-coded until action above is completed
* Upon completing File Restore, page refresh (f5) is required to fix the loading of the wizards
* Opening vApp Recovery after running File Restore will

# VMware LCM

Since this extension is reliant on the using VMware's Plugin Lifecycle Management, the following steps are required to install LCM:

## Obtain VMware SDK
First, we need to clone and build the latest VMware SDK (https://github.com/vmware/vcd-ext-sdk) and build the Plugin:

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

## Deploy LCM

Before you can deploy the extension, we need to create a credential template for use:

Copy `ui_ext_api.ini.template` and paste naming the file `ui_ext_api.ini` e.g. `cp ./ui_ext_api.ini.template ./ui_ext_api.ini`

Once completed, open the file with a text editor and populate the fields:

```
vcduri=https://<vcd-dns-address>
username=<administrator account>
organization=System
password=<administrator password>
```

Save the file. Once saved, run the command `yarn deploy` from within the `plugin-lifecycle` folder and confirm success.
