FROM centos:7
MAINTAINER Elson Rodriguez

RUN yum install -y syslinux dosfstools e2fsprogs parted epel-release createrepo file
RUN yum install -y cobbler

ENTRYPOINT [ "/create-k8s-key.sh" ]
