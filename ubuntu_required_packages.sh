#This is used to generate /mirror/required, which contains the packages needed to install package sin ubuntu/seeds/required.
#The results of this command are used to determine which debian packages to include in the debmirror command against universe.

#Must be run on Ubuntu

#TODO Either make this an automated process to generate the debmirror command, or figure out how to get apt working on Centos to work better with apt, or switch everything to an ubuntu distro.

mkdir -p /mirror/
cp ubuntu/seeds /mirror/
germinate -d xenial,xenial-updates  -a amd64 -c universe --no-installer   -s seeds -S file:///mirror/
