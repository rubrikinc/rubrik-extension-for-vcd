# Quick Start Guide: Rubrik Extension for vCloud Director

Introducing the vCloud Director Extension for Rubrik. This Repo will provide steps for Installing, Configuring and Using the Extension with Rubrik. This includes installation and configuration of the Lifecycle Management Plug-in for versions of vCloud Director prior to 9.7.

Please find the GitBook for this plugin [here](https://rubrik.gitbook.io/vcd-extension-for-rubrik/)

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
* A Linux server or Container is required to run [nginx](https://www.nginx.com/), or another preferred reverse proxy. This guide currently only includes steps for installing and configuring nginx.
* The VMware [Lifecycle Management Plug-in](https://github.com/vmware/vcd-ext-sdk/tree/master/ui/plugin-lifecycle) is used to install the Rubrik Extension for vCloud Director. Steps to build and install this plug-in are detailed below.

## Upgrading from 1.0.x

If the extension is already in use, we can upgrade the extension simply by installing through the existing Plugin Lifecycle Manager. 
You can upload to the plugin and disable to the previous version (1.0.x can be deleted after you are happy the upgrade is working).

:exclamation: Prior to allowing the extension for use, we will need to update the metadata as we now encrpyt the the username field as well as the password.

To perform these steps, open the `Settings` tab in provider view and first hit `Authenticate` and login. Once logged in, press `close` and select `Delete Metadata`.

Complete the wizard for the tenants you are adding metadata for and also selecting a Rubrik Organization:

* Use `Global` if you are not using any Rubrik Organization
* Select the relevant Rubrik Organization from the drop-down which is configured with the vApps and VM required.

Features are also new which allow white-label and Dashboard features on a per-tenant basis, use the sliders to enable the feature.

Select `Next` and `Confirm` to save the new metadata.

Open a tenant to confirm the vApps load in the `Protection` tab and the White-label/Dashboard features work as intended.

### Reverse Proxy

Before we can use the plugin, we need a Reverse Proxy between vCD and Rubrik, installation guides for this can be found in the Gitbook or [here](reverse-proxy/reverse-proxy.md)

### User Guide

For instructions on using the plugin, please refer to the Gitbook or the User guide section [here](user-guide/user-guide.md)