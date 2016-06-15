FROM centos:7
MAINTAINER Elson Rodriguez

RUN yum install -y syslinux dosfstools e2fsprogs parted epel-release createrepo file ed patch envsubst ruby gcc git rpm-build ruby-devel gettext
RUN yum install -y cobbler reprepro

RUN yum install -y perl-LockFile-Simple perl-IO-Compress perl-Compress-Raw-Zlib perl-Digest-MD5 perl-Digest-SHA perl-Net-INET6Glue perl-LWP-Protocol-https 

RUN gem install fpm -v 1.6.1

ADD . /source
RUN chmod +x /source/*.sh
RUN chmod +x /source/cobbler/bin/debmirror

RUN git clone https://github.com/elsonrodriguez/kubernetes-distro-packages.git /source/kubernetes-distro-packages
WORKDIR  /source/kubernetes-distro-packages
RUN git reset --hard 6dca0c48177c192b8b74d2455f726cf95fc29a12

ENV K8S_CLEAN_BUILD false
ENV K8S_VERSION 1.3.0-alpha.5
ENV K8S_CLUSTER_IP_RANGE 192.168.0.0/16
ENV K8S_NODE_POD_CIDR 10.244

# TODO: grab ip information as a cidr and infer the other variables.

ENV COBBLER_IP 172.16.101.100
ENV NETWORK_ROUTER 172.16.101.2
ENV NETWORK_DOMAIN harbor0.group.company.com
ENV NETWORK_BOOTP_START 172.16.101.5
ENV NETWORK_BOOTP_END 172.16.101.254
ENV NETWORK_NETMASK 255.255.0.0
#Need to figure out why we need this...
ENV NETWORK_NETMASK2 255.255.255.0
ENV NETWORK_SUBNET 172.16.101.0
ENV NETWORK_UPSTREAMDNS 8.8.8.8
ENV NETWORK_DNS_REVERSE 172.16.101

ENV NUM_MASTERS 1

ENV BUILD_DIRECTORY /build
ENV OUTPUT_DIRECTORY /output
ENV OUTPUT_IMAGE_NAME harbormaster.img

ENV CENTOS_ISO_URL http://mirrors.cmich.edu/centos/7/isos/x86_64
ENV CENTOS_ISO_NAME CentOS-7-x86_64-DVD-1511.iso

ENV UBUNTU_ISO_URL http://mirror.pnl.gov/releases/16.04
ENV UBUNTU_ISO_NAME ubuntu-16.04-server-amd64.iso

WORKDIR /source

ENTRYPOINT [ "/source/harbormaster-build.sh" ]
