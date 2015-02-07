#!/bin/bash
# written by eastsideslc 2-7-2015. Version 1.1

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
git clone https://github.com/eastsideslc/Redhat2Cent/ /tmp/Redhat2Cent/
chmod -R 744 /tmp/Redhat2Cent/
if [ -f /tmp/Redhat2Cent/centos_migration/centos_migration_files.tgz ];
        then
                mkdir /tmp/centos_migration
                tar xzvf /tmp/Redhat2Cent/centos_migration/centos_migration_files.tgz -C /tmp/centos_migration/
        else
                echo "tarball not found in /tmp/Redhat2Cent/centos_migration/centos_migration_files.tgz"
                exit
fi
echo "Import GPG key..."
rpm --import /tmp/centos_migration/RPM-GPG-KEY-CentOS-5
echo "Installing fastestmirror module for yum..."
rpm -ivh /tmp/centos_migration/yum-fastestmirror-1.1.16-21.el5.centos.noarch.rpm
echo "Installing CentOS Release Notes RPM"
rpm -Uvh --force /tmp/centos_migration/centos-release-notes-5.10-0.i386.rpm
echo "Installing CentOS Release RPM"
rpm -Uvh --force /tmp/centos_migration/centos-release-5-10.el5.centos.i386.rpm
echo "Installing yum 3.2.22-40 RPM"
rpm -Uvh --force /tmp/centos_migration/yum-3.2.22-40.el5.centos.noarch.rpm
echo "Installing yum updatesd 0.9-5 RPM"
rpm -Uvh --force /tmp/centos_migration/yum-updatesd-0.9-5.el5.noarch.rpm
echo "Installing EPEL 5.4 repo..."
rpm -ivh /tmp/centos_migration/epel-release-5-4.noarch.rpm
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

remove_RHN_6 () {
        echo "Redhat 6 funcitonality not here yet."
}

migratecent_6 () {
        echo "Redhat 6 funcitonality not here yet."
}

if [ `whoami` = root ]; then echo "Running as root...";else echo "you must be root to run this script";exit;fi
echo "Determining Redhat version..."
if [ -f /usr/bin/lsb_release ];
        then
                OSVER=`lsb_release -rs | cut -f1 -d.`
        else
                if [ -f /etc/issue ];
                                        then
                                                OSVER=`egrep -o '[0-9.]{1,}' /etc/issue|awk -F . '{print $1}'`
                                        else
                                                echo "This OS is not Redhat 5 or 6. Exiting."
                                                exit
                fi
fi

echo "Do you want to continue and migrate your system? type yes to continue"
read readvar
if [ $readvar = "yes" ] && [ $OSVER -eq 5 ];
        then echo "Migration to CentOS from Redhat 5 will start now..."
                remove_RHN
                migratecent

elif [ $readvar = "yes" ] && [ $OSVER -eq 6 ];
        then
                echo "Migration to CentOS from Redhat 6 will start now..."
                remove_RHN_6
                migratecent_6
        exit
fi

