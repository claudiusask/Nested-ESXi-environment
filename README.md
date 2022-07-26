# Nested-ESXi-environment
Nested ESXi 7.0.3 environment with vsphere, 2 ESXi hosts with iSCSi on windows server 2016.

I have a base system Dell R620 with 200-GB ram, 1tb-SSD, 4-tb HDD. The plan is to install ESXi 7.0.3 and install nested ESXi on this base system. One vCenter vSphere Client version 7.0.3.00300 is deployed from windows machine directly on the base system on SSD on the the same subnet as of base system, which is my home network. Install two ESXi's on this base system on the home subnet as base system. My home network is my homelab network which is different from the family use network. Homelab or home network has DD-WRT router with DHCP and DNS enabled.

The base ESXi's vmNetwork has Promiscuous mode, MAC address changes and Forget Transmits switched to ACCEPT. Do this only in lab not in production, actually nested ESXi is not supported in production

Microsoft iSCSI:-
- Install windows server 2016 with 90GB or 100GB disk, 2vcpu and 4GB ram. The network is the home network.
- After finishing installation and updating the windows server, shutdown the server 2016 VM and add another disk wich for me is around 2.5-TB. This 2.5-TB is going to be used by iSCSi.
  There are many options to use but this fit's my use case as I don't have much time to setup iSCSi thats why I choose Windows server 2016 iSCSi which is just click and deploy, I know it's not that flashy like vSAN which almost eveyone is using in their homelab's. The windows server 2016 has 180-days trial which is sufficent for my lab use case.
  - Go to Disk Manager on Server 2016, make the 2.5-TB drive online and initialize it, formate it and make it ready for iSCSi target.
  - Go to server Manager -> click Manage on the top right -> click add roles and features -> Go to Server Roles -> click to expand File & storage services
 -> Expand file & iscsi services -> check the iSCSi target server along with File Server and Storage services, later two is usually installed with server 2016 installation.
  - Now go to main window of Windows server 2016 Server Manager and cilck on File and Storage Services on the left side -> Click iSCSi and click create iscsi -> select the initialized 2.5-TB drive, give it a name. Select size, I used all of the 2.5-TB and choose fixed size -> specify Taget name -> Add servers ( two ESXi's server which are deployed in the later steps ) with IP address -> Disable CHAP because this is homelab but Security is important later I switch it on -> confirm everything and wait for the process to complete. For me it took almost 4 to 5 hours for 2.5-TB HDD 7.2K drive.
  
DD-WRT Configuration:-
  - add the vCenter appliance and both of the esxi's ip address in dd-wrt DNS server so we use FQDN which is required for vCenter.

NESTED ESXi's:-
  - Install two esxi, esxi-01 and esxi-02. We can use terraform to configure but initially I did it manually with network setup on the homelab network which is home subnet.
  - each ESXi had 6 virtual nics. 2 for Management, 2 for Data and 2 for vMotion.
  - 8 vcpu for each esxi
  - Enabled the hardware assisted virtualization.
  - 10-GB THIN storage is enough for basic esxi system OS installation.
  - 64-GB RAM for each.

Installation of ESXi:-
  - when the installation finishes we reboot the esxi vm.
  - Go to main configuration and setup static IP, hostname, Domain and DNS which is homelab network in my case.
  - OPTIONAL - Add all of the nics to the vSwitch0.

iSCSI on both ESXi:-
  - login to the esxi's and do the following on both of the esxi's go to storage -> Adapters -> Software iSCSI -> enable.
  - Add port binding -> vmk1 and give it another ip different from MGMT I gave .21 for .11 esxi host-1. Similar to this .22 for .12 esxi host-2.
  - Dynamiz Target -> add Windows Server 2016 IP address, which is .08 in my case.
  - ONLY on one of the ESXi - I did this is esxi-1, Go to datastore and add new datastore and select the 2.5TB HDD which is iSCSI from windows server 2016. Reboot all of the other esxi hosts so the datastore can be added automatically to them aswell. 

Join both esxi to vCenter:-
 - OPTIONAL- Create separate Datacenter for base esxi and join my base esxi to this vCenter.
 - Create new DataCenter EXAMPLE: LabDatacenter, and create a cluster with nothing activated.
 - Join both esxi's to this new Cluster which is under LabDatacenter.
 - Create new Virtual Distributed switch and Don't create any Default port groups, we will create them manually.
 - Create port groups under VDS( virtual Distributed switch ).
 - In our lab we don't need vSAN so we just make two port groups: Management, Data and vMotion. Management is for esxi managements, Data is for vmNetworks and vMotion is for VM motions.
 - right click VDS and select add or Manage hosts and select the two hosts -> set all 6 nics to the associated uplinks -> Manage vmKernel adapters and select 2 nics for vmk0 for management at the same window select vmk1 and assign vMotion vmkernel adapter. 
 - Right click VM network in the labCluster and click Migrate vm to another network and select vData.
 - At the moment all of the 6 uplinks are connected to all thre port groups. We need to change it and assign 2 nics for Management, 2 nics for vData and 2 nics for vMotion. We can do this with going to VDS -> config -> topology and right click to Edit each vmk -> goto Teaming and failover and activate only nic-1 and nic-2 for Management -> nic-3 and nic-4 for vMotion -> nic-5 and nic-6 for vData. the rest of the nics in each of vmk we can move them to unused uplinks.
 
  
