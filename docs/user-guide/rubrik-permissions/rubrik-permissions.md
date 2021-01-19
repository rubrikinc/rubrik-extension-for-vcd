## Rubrik Permissions

Under the configuration of tenants, there is the capability to use both Global or a Rubrik Organisation; this allows the restriction under RBAC to restrict and permit actions in Rubrik using Rubrik Organisations. These steps are outlined entirely in the User Guide - `Chapter 4 - Multitenant Organizations`. 

For the VMware Cloud Director Plugin, the recommendation would be to consider the following when setting up the Organisation.

*Permit based on VMware Cloud Director Organisation or VDC*

When configuring the Organisation, we can permit access to any level in hierarchy within VMware Cloud Director:

* VMware Cloud Director Cell
* VMware Cloud Director Organisation
* VMware Cloud Director Organisation VDC

This allows permitting to all objects at each of these hierarchal points

![alt-text](../img/img16.png)

CDM 5.1.2 Specific Permissions
With additional RBAC control with CDM 5.1.2, permissions now need to be specified to allow instant recovery and exports.
Within the VCD View, we need to specify the Target VCD Organizations the Rubrik Organization has permission to restore into. Select the tab Target VCD Organizations and here we need to grant the VCD Cell, Org or VDC you wish to grant permissions that allow the users to restore into. For example:

![alt-text](../img/img51.png)

Since vApps are logical containers we should also consider permitting the folder created within the vCentre so that VM level actions can be performed, such as File/Folder Restore. This appears in a similar hierarchy to the VCD Components:

* vCenter
* Host
* Folder
* Individual VMs

Since VMware Cloud Director creates us a folder for all VMs, we can permission the specific folder for this organisation:

![alt-text](../img/img17.png)

Finally, we can then permission which SLAs are available the VMware Cloud Director plugin, this is on the next page inside the Organisation configuration:

![alt-text](../img/img18.png)

The alternative to this, is to use Global which requires the user account in Rubrik to be setup using Manage Authorization with the End-User role. You can see this in the Users section in Rubrik:

![alt-text](../img/img19.png)

And using Managed Authorization we can provide specific permissions:

![alt-text](../img/img20.png)

Return to [User Guide](../user-guide.md)
