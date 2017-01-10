# DataCentred Staging Compute Agent

## Description

Simple REST daemon which listens for VM related requests on a staging hypervisor
and enacts them.  It is in essence a simplified version of OpenStack compute
which is responsible for spawning (and installing) virtual machines and
provisioning tagged VLAN ports in Openvswitch.

Virtual machines are provisioned to be as alike physical machines as possible.
Disk controllers for example are forced to use the virtio-scsi driver so they
appear as sdX in /dev and not vdX.  This also means the related directories are
present in /sys also.

## API

All requests and responses are JSON formatted.

All requests may respond with a 500 error, typically an exception was thrown and
more information can be gained from the server logs.

### GET /hosts

List all hosts on the hypervisor

#### Response

Code | Meaning
-----|--------
200  | Command success

Parameter | Type | Value
----------|------|------
id | String | Unique identifier
name | String | Libvirt domain name
state | String | State the host is in

### GET /hosts/:hostname

Probe the hypervisor for the existence of a libvirt domain for the specific
hostname.

#### Response

Code | Meaning
-----|--------
200  | Libvirt domain exists
404  | Libvirt domain does not exist

Parameter | Type | Value
----------|------|------
id | String | Unique identifier
name | String | Libvirt domain name
state | String | State the host is in

### POST /hosts/:hostname

Create the libvirt domain for the specified hostname.

#### Request

Parameter | Type | Flags | Value
----------|------|-------|-------
memory | Integer | Required | Amount of memory to allocate in MB
disks | Array[Integer] | Required | List of amounts of disk to allocate in GB
networks | Array[String] | Required | List of libvirt networks
install | Boolean | Optional | Whether to network install an operating system
location | String | Optional with _install_ | URL of libvirt network install location
cmdline | Strin | Optional with _install_ | Kernel command line parameters
console | Boolean | Optional with _install_ | Whether to show debug console

#### Response

Code | Meaning
-----|--------
200  | Libvirt domain has been successfully created
400  | Malformed JSON or missing required parameters
409  | Libvirt domain already exists

#### Example

    POST /hosts/ns.example.com/ HTTP/1.1

    {
      "memory":512,
      "disks":[
        8
      ],
      "networks":[
        "ns_example_com_vlan_10"
      ],
      "install":true,
      "location":"http://gb.archive.ubuntu.com/ubuntu/dists/xenial/main/installer-amd64"
    }

### DELETE /hosts/:hostname

Delete the libvirt domain and disks associated with a hostname

#### Response

Code | Meaning
-----|--------
200  | Domain successfully deleted
404  | Libvirt domain does not exist

### GET /networks

List all networks on the hypervisor

#### Response

Code | Meaning
-----|--------
200  | Command success

Parameter | Type | Value
----------|------|------
name | String | Libvirt network name
state | String | State the network is in
autostart | String | Whether the network starts on boot
persistent | String | Whether the network persists across reboot

### GET /networks/:networkname

Probe the hypervisor for the existence of a natwork for a specific host.

#### Response

Code | Meaning
-----|--------
200  | Libvirt vlan network exists for the host
404  | Libvirt vlan network doesn't exist for the host

### POST /networks/:networkname

Create the specified network

#### Request

Parameter | Type | Flags | Value
----------|------|-------|-------
bridge | String | Required | Openvswitch bridge to attach to
vlan | Integer | Required | VLAN tag to apply to the access port

#### Response

Code | Meaning
-----|--------
200  | Libvirt network has been successfully created
400  | Malformed JSON or missing required parameters
409  | Libvirt network already exists

#### Example

    POST /hosts/ns.example.com/networks/managment-network

    {
      "bridge":"br0",
      "vlan":10
    }

### DELETE /networks/:networkname

Delete the libvirt network

#### Response

Code | Meaning
-----|--------
200  | Network successfully deleted
404  | Network does not exist
