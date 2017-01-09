# DataCentred Staging Compute Agent

## Description

Simple REST daemon which listens for VM related requests on a staging hypervisor
and enacts them.  It is in essence a simplified version of OpenStack compute
which is responsible for spawning (and installing) virtual machines and
provisioning tagged VLAN ports in Openvswitch.

All requests and responses are JSON formatted.
