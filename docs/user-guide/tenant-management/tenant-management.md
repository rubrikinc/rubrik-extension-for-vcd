# Tenant Management

## Adding the Plugin to a Tenant

When sharing the plugin to a tenant via the VMware Lifecycle Management plugin, the plugin will require credentials configured for Rubrik so that the tenant can communicate with Rubrik to perform these self-service capabilities.

Open the Rubrik vCloud Director Plugin and Navigate to `Settings` and if not already, `Authenticate` with Rubrik by selecting `Authenticate`; provide the `Proxy Address`, `Username` and `Password` *Or* `API Token`.
 
Once authenticated, select `Add/Update Cluster Credentials` - This will open up a wizard:

![alt-text](../img/image15.png)

You can now select the vCloud Director Organisation to add credentials for a specific vCloud Director Tenant. 
Once select, you can now choose the Rubrik Organisation; we have 2 options at this point:
* `Global` - This will not specify the Rubrik Organisation and login as if the user is not in a Rubrik Organisation. To control permissions you will need to use the 
* `Rubrik Organsation` - There will a list of Rubrik Organisations that you can specify for the vCloud Director Tenant

After confirming these 2 dropdown fields, we need to the Nginx Proxy and either specify a Username and Password or an API Token. Finally, we can toggle on/off the Dashboard and Remove the Rubrik Branding, with the `Whitelabel` toggle.

Press next to save these values in the vCloud Director Tenant under the `Organization VDC`.

Once the Tenant now logins via the vCloud Director Tenant URL, they will be able to load the plugin and use it with their existing vCloud Director RBAC permissions and permissions that have been assigned by Rubrik.

### vCloud Director RBAC Permissions

The Rubrik vCloud Director Plugin uses the existing user's permissions in vCloud director and therefore only displays vApps that the user has permission to inside of vCloud Director. This ensures they are not able to perform other actions on vApps they do not have permission to from vCloud Director within the plugin.

Return to [User Guide](https://github.com/rubrikinc/rubrik-extension-for-vcd/blob/master/docs/user-guide/user-guide.md)