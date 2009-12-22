#!/bin/bash

###############################################################################
# @author Radu Cotescu                                                        #
# @version 1.1 Thu Oct 22 22:45:20 EEST 2009                                  #
#                                                                             #
# For further details visit:                                                  #
#   http://radu.cotescu.com/?p=505                                            #
#                                                                             #
# This script will help you install VMWare Server 2.0.1 on Ubuntu 9.04 and    #
# 8.10.                                                                       #
# This script must be run with super-user privileges.                         #
# Usage: ./vmware-install-script.sh [PATH TO VMWARE ARCHIVE]                  #
# If you do not specify the PATH the script will scan the current folder for  #
# VMware server archive and if doesn't find anything it will exit.            #
###############################################################################

VMWARE_HOME=$1
PATCH=vmware-config-patch.txt

display_usage() {
	echo "This script must be run with super-user privileges."
	echo -e "\nUsage: ./vmware-install-script.sh [PATH TO VMWARE ARCHIVE]\n"
	echo "If you do not specify the PATH the script will scan the current folder"
	echo "for VMware server archive and if doesn't find anything it will exit."
	exit 1
}

check_usage() {
	if [ ! $params -le 1 ]
	then
		display_usage
	fi
	if [[ ($param == "--help") ||  $param == "-h" ]]
	then
		display_usage
	fi
}

check_user() {
	if [[ $USER != "root" ]]; then
		echo "This script must be run as root!"
		exit 1
	fi
}

set_workspace() {
	if [[ -z "$VMWARE_HOME" ]] ; then
		VMWARE_HOME=`pwd`
	fi
	VMWARE_ARCHIVE=`ls $VMWARE_HOME 2> /dev/null | egrep "^(VMware-server-2.0.[0-9]-)[0-9]*.[A-Za-z0-9_]*.tar.gz"`
}

check_archive() {
	if [[ -z $VMWARE_ARCHIVE ]]; then
		echo -e "There is no archive containing VMware Server in the path you indicated!\n"
		exit 1
	else
		echo -e "You have VMware Server archive: \n\t$VMWARE_ARCHIVE"
	fi
}

install() {
	echo "Downloading patch file..."
	wget http://codebin.cotescu.com/vmware/$PATCH -O "$VMWARE_HOME/$PATCH" 2> /dev/null
	echo "Checking patch download..."
	if [ ! -r "$VMWARE_HOME/$PATCH" ]; then
		echo "The download of $PATCH from http://codebin.cotescu.com/vmware/ failed!"
		echo "Check your internet connection. :("
		exit 1
	fi
	LINUX_HEADERS="linux-headers-`uname -r`"
	check=`dpkg-query -W -f='${Status} ${Version}\n' $LINUX_HEADERS 2> /dev/null | egrep "^install"`
	if [[ -z $check ]]; then
		echo Installing build-essential and linux-headers-`uname -r`...
		apt-get -y install build-essential patch linux-headers-`uname -r`
	fi
	if [ ! -e "$VMWARE_HOME/vmware-server-distrib" ]
	then
		echo Extracting the contents of $VMWARE_ARCHIVE
		tar zxf "$VMWARE_HOME/$VMWARE_ARCHIVE" -C "$VMWARE_HOME"
	fi
	patch "$VMWARE_HOME/vmware-server-distrib/bin/vmware-config.pl" "$VMWARE_HOME/$PATCH"
	$VMWARE_HOME/vmware-server-distrib/vmware-install.pl
}

clean() {
	echo "Housekeeping..."
	rm -rf "$VMWARE_HOME/vmware-server-distrib" "$VMWARE_HOME/$PATCH"
	echo "Thank you for using the script!"
	echo "Author: Radu Cotescu"
	echo "http://radu.cotescu.com"
}

params=$#
param=$1
check_usage params param
check_user
set_workspace
check_archive
install
clean
exit 0

