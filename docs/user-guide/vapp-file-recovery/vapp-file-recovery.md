## vApp Virtual Machine File Recovery

### File Recovery on a Virtual Machine

Within the Plugin, File Restores are now possible on a Per VM basis. We can choose the vApp pertaining the Virtual Machine and select `Recover Files` - This will take us into the File Recovery wizard.

First, we must select the VM that had the file we are trying to restore:

![alt-text](../img/image36.png)

Select `Next` will take us into the view to search for files, Enter a filename in the field that states `Enter Filename to search for:` and press `Search`. This will go find all files that contain this text and return a list which you can use the dropdown to choose:

![alt-text](../img/image37.png)

After selecting the file, we need to specify the version (this will only show the unique files i.e. ones that have changed from snapshot to snapshot):

![alt-text](../img/image38.png)

After selecting `Next`, we are presented with the restore options, these are as follows:

* Overwrite Original
* Restore to Separate Folder

Regardless of which option selected, we will then be asked to the provide the following restore method:

* `RBS Backup Service` - Rubrik Backup Service is a connector running on the VM that allows Rubrik to interact at a service level, if selected, the file recovery is only possible the Service is running
* `Use VM Guest Credentials` - Using VM Guest Credentials will use the VM login details via VMware Tools to restore the file

Finally, if we restore to a separate folder,  we will also need to provide the path for a successful restore:

![alt-text](../img/image39.png)

Return to [User Guide](https://github.com/rubrikinc/rubrik-extension-for-vcd/blob/master/docs/user-guide/user-guide.md)
