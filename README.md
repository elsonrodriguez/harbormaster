# Harbormaster 

Harbormaster is a tool to bootstrap Kubernetes on Bare Metal

# Requirements

- Docker
- A minimum of 3 servers on the same network
- Full control over DHCP/PXE for that network
- A way to attach a boot image to your servers.

# Overview

The overall steps are as follows

- Build the Docker Image
- Configure settings via environment variables
- Run the Docker Image
- Use the resulting boot image via a USB key or IPMI to provision Harbormaster
- Harbormaster uses PXE to provision any machine on its network as a Kubernetes cluster member

## Build Container Image

Build the image using the included Docker file.

```
docker build -t harbormaster .
```

## Configure Settings

This tool takes settings via environment variables, please see the Dockerfile for reference.

There are many environment variables, so an envfile is prefered, an example file containing commonly modified variables is provided in `./networksettings`

```
COBBLER_IP=192.168.100.100

ENABLE_PROXY=true

NETWORK_GATEWAY=192.168.100.2
NETWORK_DOMAIN=harbor0.group.company.com
NETWORK_BOOTP_START=192.168.100.5
NETWORK_BOOTP_END=192.168.100.254
NETWORK_NETMASK=255.255.255.0
NETWORK_SUBNET=192.168.100.0
NETWORK_UPSTREAMDNS=10.248.2.1
NETWORK_DNS_REVERSE=192.168.100
```

## Run the Container

Run the container with your settings by issuing the following command:

```
docker run --env-file=./networksettings -v ~/harbormaster-output/:/output/ -v ~/harbormaster-build/:/build/ -it --privileged --rm --entrypoint=/bin/bash harbormaster
```

This will result in many reusable temporary files output into `~/harbormaster-build/`, and one build artifact in `~/harbormaster-output/`: 

```
ls -1sh ~/harbormaster-output/
total 36008448
24576000 harbormaster.img
```

## Boot Image 

The image can be written to a USB drive, converted to a virtual disk, or mounted via IPMI.

### Writing the image

In unix-like operating systems, you can issue the following:

```
dd if=~/harbormaster-output/harbormaster.img of=/dev/USB_DEVICE bs=5m
```

### Converting to a Virtual Disk

If you want to test the image on a virtual machine, you can use Virtualbox:

```
VBoxManage convertfromraw harbormaster.img harbormaster.vmdk --format VMDK
```

You can now attach the image as a second hard drive to a VM to provision Harbormaster.

### Mount via IPMI

Many IPMI implementations allow you to mount the resulting image as a USB drive. It may also work mounted as a remote hard drive.

## Provision Harbormaster

Once attached to a server and set as the primary boot device, the image will provision a Cobbler server.

Once provisioning is finished, you can now build out your cluster.

## Provision Kubernetes Cluster

Provision your Kubernetes cluster by booting machines via PXE. It is best if you turn on one machine and wait for it to finish, this first machine will automatically be provisioned as a Master.

All machines after that will be provisioned as nodes.
