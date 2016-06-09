#!/bin/bash

rsync -avc /source/ ${BUILD_DIRECTORY} 

cd ${BUILD_DIRECTORY}
cp -a cobbler/var/* /var/lib/cobbler/

sed -i 's@proxy_url_ext: ""@proxy_url_ext: "'${HTTP_PROXY}'"@g' /etc/cobbler/settings
#AND DO THE OTHER SEDDY THINGS.

#Start Cobbler
httpd
cobblerd

#Download latest boot loaders
cobbler get-loaders --force
cp -a /var/lib/cobbler/loaders cobbler/var/

#Create partial mirror for cobbler installation, this can be revised/updated by using ubuntu_required_packages.sh
mkdir -p ./cobbler-repo
repotrack -a x86_64 -p ./cobbler-repo/ ipxe-bootimgs cobbler cobbler-web perl-LockFile-Simple perl-IO-Compress perl-Compress-Raw-Zlib perl-Digest-MD5 perl-Digest-SHA perl-Net-INET6Glue perl-LWP-Protocol-https
createrepo cobbler-repo/

# Adds debian packages to Kubernetes repo
mkdir -p ubuntu/repos/kubernetes
reprepro -b ubuntu/repos/kubernetes includedeb xenial ${BUILD_DIRECTORY}/kubernetes/builds/*.deb

# Mirror Universe, 60 gigs...
#./cobbler/bin/debmirror -v -p --no-check-gpg  -h archive.ubuntu.com -r ubuntu -d xenial -s universe -a amd64 --method=http --nosource ubuntu/repos/universe

# Mirror just what we need from universe
./cobbler/bin/debmirror -v -p --no-check-gpg  -h archive.ubuntu.com -r ubuntu -d xenial -s universe -a amd64 --method=http --nosource ubuntu/repos/universe --exclude='/*'  --include=ceph-fs-common --include=gir1.2-libosinfo-1.0  --include=koan   --include=libosinfo-1.0-0  --include=python-ethtool --include=python-koan  --include=virtinst

# Mirror Docker Repo
./cobbler/bin/debmirror -v -p --no-check-gpg  -h apt.dockerproject.org -r repo -d ubuntu-xenial -s main -a amd64 --method=http --nosource ubuntu/repos/docker-repo

# Copy Ansible scripts
# 

# Create blank image. Should refactor this to happen right when everything's been downloaded for actual size estimate.
dd if=/dev/zero of=${OUTPUT_DIRECTORY}/${OUTPUT_IMAGE_NAME} bs=1M count=8000

kpartx -a ${OUTPUT_DIRECTORY}/${OUTPUT_IMAGE_NAME}
# Create usb image
./make-centos-bootstick -k ./ks.cfg -c ./syslinux.cfg -s ./k8splash.png loop0
