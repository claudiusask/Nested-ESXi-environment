vsphere_server     = "10.0.0.9"
vsphere_user       = "Administrator@vsphere.local"
vsphere_password   = "*******"
vcenter_license    = "*******"
datacenter         = "XZLabDatacenter"
datastore          = "iSCSI-Datastore"
cluster            = "XZLabCluster"
network_name       = "vData"

# EXPORT "vsphere_password" & "ssh_password" like below example:
# Also don't forget to put an extra space before the word "export" in below example, so the password won't be saved in bash history.
#-------------LINUX---EXAMPLE------------------#
# export TF_VAR_vsphere_password="YOUR-TOP-SECRET-PASSWORD"
# export TF_VAR_ssh_password="YOUR-TOP-SECRET-PASSWORD"
#-------------Windows---Powershell---Example---#
# $env:TF_VAR_vsphere_password="YOUR-TOP-SECRET-PASSWORD"
# $env:TF_VAR_ssh_password="YOUR-TOP-SECRET-PASSWORD"
