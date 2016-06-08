cd /make-centos-bootstick
cp cobbler/var/* /var/lib/cobbler/

sed -i 's@proxy_url_ext: ""@proxy_url_ext: "'${HTTP_PROXY}'"@g' /etc/cobbler/settings
#AND DO THE OTHER SEDDY THINGS.

#Start Cobbler
httpd
cobblerd

#Download latest boot loaders
cobbler get-loaders --force
cp -a /var/lib/cobbler/loaders cobbler/var/

#Create partial mirror for cobbler installation
mkdir -p ./cobbler-repo
repotrack -a x86_64 -p ./cobbler-repo/ ipxe-bootimgs cobbler cobbler-web perl-LockFile-Simple perl-IO-Compress perl-Compress-Raw-Zlib perl-Digest-MD5 perl-Digest-SHA perl-Net-INET6Glue perl-LWP-Protocol-https
createrepo cobbler-repo/

#Create mirrors for debian repositories.
mkdir -p /var/repositories/
#
echo \
"Codename: xenial 
Components: universe 
Architectures: amd64" > /var/repositories/distributions 

reprepro -b /var/repositories includedeb xenial ~/kubernetes/builds/*.deb



./make-centos-bootstick -k ./ks.cfg -c ./syslinux.cfg -s ./k8splash.png loop0


