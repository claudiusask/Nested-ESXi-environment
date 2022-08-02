provider "vsphere" {
  vsphere_server    = var.vsphere_server
  user              = var.vsphere_user
  password          = var.vsphere_password

  # If you have a self-signed cert
  allow_unverified_ssl = true
}

/* resource "vsphere_license" "licenseKey" {
  license_key = var.vcenter_license
} */

# Creates the Datacenter
resource "vsphere_datacenter" "Datacenter" {
  name       = var.datacenter
}

# uses the datacenter created previously 
data "vsphere_datacenter" "XLabDatacenter" {
  name = var.datacenter
  depends_on = [vsphere_datacenter.Datacenter]
}

# Creates a cluster for ESXi hosts
resource "vsphere_compute_cluster" "compute_cluster" {
  name            = var.cluster
  datacenter_id   = data.vsphere_datacenter.XLabDatacenter.id
  drs_enabled          = true
  drs_automation_level = "fullyAutomated"
  ha_enabled = true
}

#----DISTRIBUED SWITCH----
resource "vsphere_distributed_virtual_switch" "dvs" {
  name          = "DVS-Nested"
  datacenter_id = "${data.vsphere_datacenter.XLabDatacenter.id}"

  uplinks         = ["uplink1", "uplink2", "uplink3", "uplink4", "uplink5", "uplink6"]
  active_uplinks  = ["uplink1", "uplink2", "uplink3", "uplink4", "uplink5", "uplink6"]
  }

resource "vsphere_distributed_port_group" "MGMT_VMK" {
  name = "MGMT VMK"
  distributed_virtual_switch_uuid = vsphere_distributed_virtual_switch.dvs.id
  active_uplinks = ["uplink1", "uplink2" ]
}
resource "vsphere_distributed_port_group" "vMotion_VMK" {
  name = "vMotion VMK"
  distributed_virtual_switch_uuid = vsphere_distributed_virtual_switch.dvs.id
  active_uplinks = ["uplink3", "uplink4" ]
}
resource "vsphere_distributed_port_group" "vData" {
  name = "vData"
  distributed_virtual_switch_uuid = vsphere_distributed_virtual_switch.dvs.id
  active_uplinks = ["uplink5", "uplink6" ]
}