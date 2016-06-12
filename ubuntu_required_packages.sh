#This is used to generate /mirror/required, which contains the packages needed to install package sin ubuntu/seeds/required.
#The results of this command are used to determine which debian packages to include in the debmirror command against universe.

#Must be run on Ubuntu

#TODO Either make this an automated process to generate the debmirror command, or figure out how to get apt working on Centos to work better with apt, or switch everything to an ubuntu distro.

mkdir -p /mirror/
cp ubuntu/seeds /mirror/
germinate -d xenial,xenial-updates  -a amd64 -c universe --no-installer   -s seeds -S file:///mirror/



#another pattern
apt-get --print-uris --yes install koan  | grep ^\' | cut -d\' -f2 >downloads.list

#then just pass that download list to curl, and add the debian packages via reprepro.

#for main packages, do a compare against the install media
for i in `cat founddebs `; do basename $i ; done > founddebbase
   22  cat founddebbase  | sort > sortedfound
   23  cat test.debs  | sort > sortedneeded
comm -3  sortedneeded  sortedfound 
for i in `cat needed` ; do cat maindownloads | grep $i ; done
