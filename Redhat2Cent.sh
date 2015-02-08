#!/bin/bash
# written by eastsideslc 2-7-2015. Version 1.3

tarloc=/tmp/Redhat2Cent

remove_RHN() {
echo "The next step will remove this server from the RHN service and remove all Redhat packages"
echo "Do you want to continue?  type yes if you do"
read removevar
if [ $removevar = "yes" ];
        then echo "Removing all Redhat components.."
                mv /etc/redhat-release /etc/old_redhat-release_old
                rpm -e --nodeps redhat-release
                rpm -e rhn-client-tools rhn-setup rhn-check rhn-virtualization-common rhnsd redhat-logos yum-rhn-plugin redhat-release-notes
        else
                echo "Doing nothing and exiting now"
                exit
fi
}

migratecent() {
echo "Clearing yum cache..."
echo
yum clean all
echo "cloning latest Redhat2Cent from github.  These files will reside in /tmp/Redhat2Cent/centos_migration/"
git clone https://github.com/eastsideslc/Redhat2Cent/ $tarloc
tar xzvf $tarloc/centos_migration_files.tgz -C $tarloc
echo "Import GPG key..."
rpm --import $tarloc/RPM-GPG-KEY-CentOS-5
echo "Installing fastestmirror module for yum..."
rpm -ivh $tarloc/yum-fastestmirror-1.1.16-21.el5.centos.noarch.rpm
echo "Installing CentOS Release Notes RPM"
rpm -Uvh --force $tarloc/centos-release-notes-5.10-0.i386.rpm
echo "Installing CentOS Release RPM"
rpm -Uvh --force $tarloc/centos-release-5-10.el5.centos.i386.rpm
echo "Installing yum 3.2.22-40 RPM"
rpm -Uvh --force $tarloc/yum-3.2.22-40.el5.centos.noarch.rpm
echo "Installing yum updatesd 0.9-5 RPM"
rpm -Uvh --force $tarloc/yum-updatesd-0.9-5.el5.noarch.rpm
echo "Installing EPEL 5.4 repo..."
rpm -ivh $tarloc/epel-release-5-4.noarch.rpm
echo "Running yum update..."
yum -y update
if [ ! -f /usr/share/gdm/themes/RHEL ];
        then
                echo "Creating shared Redhat and CentOS gnome themes..."
                mkdir /usr/share/gdm/themes/RHEL/
                cp -pR /usr/share/gdm/themes/CentOSCubes/* /usr/share/gdm/themes/RHEL/
                cp -p /usr/share/gdm/themes/RHEL/CentOSCubes.xml /usr/share/gdm/themes/RHEL/RHEL.xml
                cp -p /usr/share/gdm/themes/TreeFlower/background.png /usr/share/gdm/themes/RHEL/background2.png
        else
                echo "RHEL themes already exist.  Skipping this step.  Ping author if you see weirdness in Gnome."
fi
}


migratecent_6 () {
echo "Installing EPEL 6 repo..."
rpm -Uvh http://download.fedoraproject.org/pub/epel/6/x86_64/epel-release-6-8.noarch.rpm
echo "The next step will remove this server from the RHN service and remove all Redhat packages"
rpm -e --nodeps redhat-release-server
rpm -e --nodeps redhat-release
rpm -e --nodeps redhat-indexhtml
yum remove rhnlib abrt-plugin-bugzilla redhat-release-notes*

echo "Installing Cent packages..."
rpm -Uvh http://mirror.centos.org/centos/6/os/x86_64/Packages/centos-release-6-6.el6.centos.12.2.x86_64.rpm
rpm -Uvh http://mirror.centos.org/centos/6/os/x86_64/Packages/centos-indexhtml-6-2.el6.centos.noarch.rpm
rpm -Uvh http://mirror.centos.org/centos/6/os/x86_64/Packages/yum-plugin-fastestmirror-1.1.30-30.el6.noarch.rpm
rpm -Uvh http://mirror.centos.org/centos/6/os/x86_64/Packages/yum-3.2.29-60.el6.centos.noarch.rpm
echo "Cleaning yum DB..."
yum clean all
yum upgrade
echo "Finished!"
}


if [ `whoami` = root ]; then echo "Running as root...";else echo "you must be root to run this script";exit;fi
echo "Determining Redhat version..."
if [ -f /usr/bin/lsb_release ];
        then
                osver=`lsb_release -rs | cut -f1 -d.`
        else
                if [ -f /etc/issue ];
                                        then
                                                osver=`egrep -o '[0-9.]{1,}' /etc/issue|awk -F . '{print $1}'`
                                        else
                                                echo "This OS is not Redhat 5 or 6. Exiting."
                                                exit
                fi
fi

echo "Do you want to continue and migrate your system? type yes to continue"
read readvar
if [ $readvar = "yes" ] && [ $osver -eq 5 ];
        then echo "Migration to CentOS from Redhat 5 will start now..."
                remove_RHN
                migratecent

elif [ $readvar = "yes" ] && [ $osver -eq 6 ];
        then
                echo "Migration to CentOS from Redhat 6 will start now..."
                                migratecent_6
        exit
fi


