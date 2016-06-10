#!/bin/bash

# Move files from container's staging directory to the build directory
rsync -avc /source/ ${BUILD_DIRECTORY} 

cd ${BUILD_DIRECTORY}
cp -a cobbler/var/* /var/lib/cobbler/

# Pass along proxy settings to the container's cobbler
sed -i 's@proxy_url_ext: ""@proxy_url_ext: "'${HTTP_PROXY}'"@g' /etc/cobbler/settings

# DO THE OTHER SEDDY THINGS.
envsubst < templates/ks.cfg > ks.cfg
envsubst < templates/cobbler/etc/dhcp.template.tmpl > cobbler/etc/dhcp.template
envsubst < templates/cobbler/etc/named.template.tmpl > cobbler/etc/named.template
envsubst < templates/cobbler/etc/settings.tmpl > cobbler/etc/settings

# Resolve provisioning templates

# Start Cobbler
httpd
cobblerd

# Download latest boot loaders
cobbler get-loaders --force
cp -a /var/lib/cobbler/loaders cobbler/var/


# Make k8s packages
cd kubernetes-distro-packages
./build_kubernetes.sh
./build_etcd.sh
cd ..
 
# Create partial mirror for cobbler installation
mkdir -p ./cobbler-repo
repotrack -a x86_64 -p ./cobbler-repo/ ipxe-bootimgs cobbler cobbler-web perl-LockFile-Simple perl-IO-Compress perl-Compress-Raw-Zlib perl-Digest-MD5 perl-Digest-SHA perl-Net-INET6Glue perl-LWP-Protocol-https
createrepo cobbler-repo/

# Adds debian packages to Kubernetes repo
mkdir -p ubuntu/repos/kubernetes
reprepro -b ubuntu/repos/kubernetes includedeb xenial ${BUILD_DIRECTORY}/kubernetes-distro-packages/kubernetes/builds/*.deb
reprepro -b ubuntu/repos/kubernetes includedeb xenial ${BUILD_DIRECTORY}/kubernetes-distro-packages/etcd/builds/*.deb

# Mirror Universe, 60 gigs...
#./cobbler/bin/debmirror -v -p --no-check-gpg  -h archive.ubuntu.com -r ubuntu -d xenial -s universe -a amd64 --method=http --nosource ubuntu/repos/universe

# Mirror just what we need from universe, this can be revised/updated by using ubuntu_required_packages.sh
./cobbler/bin/debmirror -v -p --no-check-gpg  -h archive.ubuntu.com -r ubuntu -d xenial -s universe -a amd64 --method=http --nosource ubuntu/repos/universe --exclude='/*'  --include=ceph-fs-common --include=gir1.2-libosinfo-1.0  --include=koan   --include=libosinfo-1.0-0  --include=python-ethtool --include=python-koan  --include=virtinst

# Mirror Docker Repo
./cobbler/bin/debmirror -v -p --no-check-gpg  -h apt.dockerproject.org -r repo -d ubuntu-xenial -s main -a amd64 --method=http --nosource ubuntu/repos/docker-repo

# Copy Ansible scripts
# 

# Create blank image. Should refactor this to happen right when everything's been downloaded for actual size estimate.
dd if=/dev/zero of=${OUTPUT_DIRECTORY}/${OUTPUT_IMAGE_NAME} bs=1M count=10000

# Creates loopback device for image.
# TODO: We should also get the resulting loopback device to pass into make-centos-bootstick.
kpartx -a ${OUTPUT_DIRECTORY}/${OUTPUT_IMAGE_NAME}

# Create usb image, this is a patched up thid party utility that needs to be refactored, and a PR sent back upstream.
./make-centos-bootstick -k ./ks.cfg -c ./syslinux.cfg -s ./k8splash.png loop0
