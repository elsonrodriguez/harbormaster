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
mkdir -p /var/repositories/config
#
echo \
"Codename: xenial 
Components: universe 
Architectures: amd64" > /var/repositories/config/distributions 

#distributions
#Codename: xenial
#Components: universe
#Architectures: amd64
#Tracking: minimal 
#Update: xenial

#updates
#Name: xenial 
#Components: universe 
#Method: http://archive.ubuntu.com/ubuntu
#VerifyRelease: blindtrust



#adds debian packages to repo
reprepro -b /var/repositories includedeb xenial ~/kubernetes/builds/*.deb

#tries to mirror repo
#reprepro -b /var/repositories xenial update

#60 gigs...
#./cobbler/bin/debmirror -v -p --no-check-gpg  -h archive.ubuntu.com -r ubuntu -d xenial -s universe -a amd64 --method=http --nosource /tmp/adf

./make-centos-bootstick -k ./ks.cfg -c ./syslinux.cfg -s ./k8splash.png loop0


