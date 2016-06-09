FROM centos:7
MAINTAINER Elson Rodriguez

ADD . /source
RUN chmod +x /source/*.sh
RUN chmod +x /source/cobbler/bin/debmirror

RUN yum install -y syslinux dosfstools e2fsprogs parted epel-release createrepo file
RUN yum install -y cobbler reprepro

RUN yum install -y perl-LockFile-Simple perl-IO-Compress perl-Compress-Raw-Zlib perl-Digest-MD5 perl-Digest-SHA perl-Net-INET6Glue perl-LWP-Protocol-https 

ENV K8S_VERSION 1.2.0
ENV K8S_CLUSTER_IP_RANGE 192.168.0.0/16
ENV K8S_NODE_POD_CIDR 10.244.X.3

ENV COBBLER_IP 172.16.101.100
ENV NETWORK_ROUTER 172.16.101.2
ENV NETWORK_DOMAIN harbor0.group.company.com
ENV NETWORK_BOOTP_START 172.16.101.1
ENV NETWORK_BOOTP_END 172.16.101.254
ENV NETWORK_NETMASK 255.255.0.0
ENV NETWORK_SUBNET 172.16.101.0
ENV NETWORK_UPSTREAMDNS 8.8.8.8

ENV NUM_MASTERS 1

ENV BUILD_DIRECTORY /build
ENV OUTPUT_DIRECTORY /output
ENV OUTPUT_IMAGE_NAME harbormaster.img
ENV BUILD_DIRECTORY /build

ENV CENTOS_ISO_URL http://mirrors.cmich.edu/centos/7/isos/x86_64
ENV CENTOS_ISO_NAME CentOS-7-x86_64-NetInstall-1511.iso

ENV UBUNTU_ISO_URL http://mirror.pnl.gov/releases/16.04
ENV UBUNTU_ISO_NAME ubuntu-16.04-server-amd64.iso

ENTRYPOINT [ "/source/make-k8s-key.sh" ]
