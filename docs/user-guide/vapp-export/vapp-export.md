## vApp Exports
Exporting some or all VMs from one vApp to another vApp or VDC
   
### Exporting the VMs

Within Export, the functionality exists to perform the following actions:

* Export all VMs from one vApp to a new vApp
* Export some VMs from one vApp to a new vApp
* Export some VMs from one vApp to an existing vApp

We can use this to migrate VMs between vApps or VDCs; select the vApp we want to start the export for, and select `Export vApp` - this will open a wizard which will ask to confirm either a `Full vApp` export or a `Partial vApp` export.

Full vApp Exports, must always go to a new vApp, but we can still export all VMs in partial an existing vApp, therefore when choosing `Partial vApp` we will present the option to choose either `New` or `Existing`:

![alt-text](../img/image40.png)

Select either `New vApp` or `Existing vApp` and select the VMs to export:

**Full and New vApp Export**

![alt-text](../img/image45.png)

Selecting `Next` will ask us to choose a snapshot to restore from, select a snapshot with the relevant date or protection point:

![alt-text](../img/image42.png)

Select `Next` and we will be presented with a list of VDCs available for export:

![alt-text](../img/image46.png)

Finally, we will be asked to configure Network Settings, Name the new vApp and also suffix the VMs (Blank will not suffix anything other than an generated 4 letter string):

![alt-text](../img/image47.png)

**Partial and Existing vApp Export**

![alt-text](../img/image41.png)

Selecting `Next` will ask us to choose a snapshot to restore from, select a snapshot with the relevant date or protection point:

![alt-text](../img/image42.png)

Since we choose `Existing vApp` we will now list the vApps that we have permissions to restore to, choose the relevant vApp:

![alt-text](../img/image43.png)

Finally, we get the same options to configure the network as we do during Instant Recovery however, we can also specify a suffix to identify the VMs with, select the relevant network settings and Done to complete the export:

![alt-text](../img/image44.png)

We can use the `Events` Button to track progress of this export.

Return to [User Guide](https://github.com/rubrikinc/rubrik-extension-for-vcd/blob/master/docs/user-guide/user-guide.md)


