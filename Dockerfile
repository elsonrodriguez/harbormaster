FROM centos:7
MAINTAINER Elson Rodriguez

RUN yum install -y syslinux dosfstools e2fsprogs parted epel-release createrepo file
RUN yum install -y cobbler

RUN yum install -y perl-LockFile-Simple perl-IO-Compress perl-Compress-Raw-Zlib perl-Digest-MD5 perl-Digest-SHA perl-Net-INET6Glue perl-LWP-Protocol-https 

#K8S_VERSION 1.2.0

#COBBLER_IP 172.16.101.100
#NETWORK_ROUTER 172.16.101.2
#NETWORK_DOMAIN harbor0.group.company.com
#NETWORK_BOOTP_START 172.16.101.1
#NETWORK_BOOTP_END 172.16.101.254
#NETWORK_NETMASK 255.255.0.0
#NETWORK_SUBNET 172.16.101.0

#NUM_MASTERS 1

#OUTPUT_DIRECTORY /output

ENTRYPOINT [ "/create-k8s-key.sh" ]
