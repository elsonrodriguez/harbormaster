- USB Key Creator
-- Downloads Ubuntu 16 server iso
-- Downloads Centos server iso
-- Creates Ubuntu repo containing
--- docker 
--- etcd
--- kubernetes
--- ceph
--- koan
-- Creates cobbler configs by asking questions about network
--- IP Range
--- IP for cobbler
-- 
-- write everything to USB Key






docker run --env https_proxy=$HTTP_PROXY \
 --env http_proxy=$HTTP_PROXY \
 --env https_proxy=$HTTP_PROXY \
 --env http_proxy=$HTTP_PROXY \
 --env HTTP_PROXY=$HTTP_PROXY \
 --env HTTPS_PROXY=$HTTP_PROXY \
 --env NO_PROXY=$NO_PROXY \
 --env no_proxy=$NO_PROXY \
 -v /Users:/Users --privileged -it --rm centos:7  bash

packages required for creating key:
yum install -y syslinux dosfstools e2fsprogs parted epel-release createrepo file
yum install -y cobbler

cd /Users/eorodrig/oss/make-centos-bootstick
cp cobbler/var/* /var/lib/cobbler/

sed -i 's@proxy_url_ext: ""@proxy_url_ext: "'${HTTP_PROXY}'"@g' /etc/cobbler/settings
httpd
cobblerd
cobbler get-loaders --force

cp -a /var/lib/cobbler/loaders cobbler/var/

repotrack -a x86_64 -p /cobbler-repo/ ipxe-bootimgs cobbler cobbler-web perl-LockFile-Simple perl-IO-Compress perl-Compress-Raw-Zlib perl-Digest-MD5 perl-Digest-SHA perl-Net-INET6Glue perl-LWP-Protocol-https

mv /cobbler-repo .

createrepo cobbler-repo/

#dd if=/dev/zero of=kube-bootstrap.img bs=1M count=6000
kpartx -a ./harbormaster.img

./make-centos-bootstick -k ./ks.cfg -c ./syslinux.cfg -s ./k8splash.png loop0

### clone repo from iso
mkdir /mnt/cdrom
curl -O -L -z http://mirror.pnl.gov/releases/16.04/ubuntu-16.04-server-amd64.iso
mount -o loop ubuntu-16.04-server-amd64.iso /mnt/ubuntu
cobbler import --name=ubuntu-16.04 --path=/mnt/ubuntu  --breed=ubuntu --os-version=xenial --arch=x86_64

###to clone partial debian repo

docker run  -v /Users:/Users  -it --rm ubuntu bash
apt-get install apt-rdepends
apt-get download koan && apt-cache depends -i koan | awk '/Depends:/ {print $2}' | grep -v "\:any" |xargs  apt-get download

#debootstrap --arch=amd64 xenial /mnt/ubuntu http://archive.ubuntu.com/ubuntu

#germinate -d xenial,xenial-updates  -a amd64 -c universe --no-installer   -s seeds -S file:///germ/

#VBoxManage convertfromraw harbormaster.img harbormaster.vmdk --format VMDK


Custom repo needs:
- Docker
- Etcd
- Ceph mounting tools
- Kubernetes packages
- Koan
