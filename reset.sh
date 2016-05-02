#!/bin/bash

#The following makes sure the script is ran as root
#This is required because some commands in this script require root privileges
#The \e[91m potion of the text changes the output color to red for any characters after the m
if (( $EUID != 0 )); then
	echo
	echo -e "\e[91m !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
	echo -e "ERROR: THIS SCRIPT MUST BE RAN AS ROOT"
	echo -e "TRY TO RERUN THIS SCRIPT USING THE SUDO COMMAND"
	echo -e "EXITING"
	echo -e "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
	echo -e "\e[39m"
	exit
fi
clear
while true; do
	echo
	echo
	echo -e '\e[92m ****************************************************************************'
	echo -e '   Welcome to the Raspberry Pi Reset Script - Version 1.0 BETA'
	echo -e '   Compiled by Kevin Schulmeister on 4/16/16'
	echo -e '   This script will reset and load the default configuration specfied below.'
	echo -e ' ****************************************************************************'
	echo -e '\e[39m'
	echo
	echo -e '\e[93m This script will do the following:'
	echo -e '      1.  Change the hostname to the specified hostname'
	echo -e '      2.  Extend the file system to maximize storage space'
	echo -e "      3.  **REMOVE ALL FILES FROM Pi's HOME DIRECTORY**"
	echo -e '      4.  Update the Raspbian repositories'
	echo -e '      5.  Update any installed packages using the repositories'
	echo -e '      6.  Install and Configure Tight VNC Server'
	echo -e '      7.  Setup LCD display script for displaying IP address'
	echo -e '      8.  Download and Replace IoT Dev Labs scripts'
	echo -e '      9.  Download and Replace GrovePi scripts'
	echo -e '      10. Reset desktop background to default'
	echo -e '\e[39m'
	echo -e '\e[91m A restart will be required at the end of this script.'
	echo -e '\e[39m'
	read -p " Do you want to continue? [y/n] " yn1
	case $yn1 in
		[Yy]* ) break;;
		[Nn]* ) echo; echo ' Goodbye!'; echo; exit 0;;
		* ) clear; echo -e "\e[91m Please answer yes or no.\e[39m"
	esac
done

while true; do
	read -p " Do you want to run this script with tutorials? [y/n] " yn2
	case $yn2 in
		[Yy]* ) echo -e "   **Tutorials have been enabled and will be shown in \e[93mYellow\e[39m**"; tutorial="1"; echo; break;;
		[Nn]* ) echo "   **Tutorials have been disabled**"; tutorial="0"; echo; break;;
		* ) echo " Please answer yes or no."; echo;
	esac
done

echo
echo -e '\e[92m ======================================================='
echo -e '   Step 1: Change the hostname to the specified hostname'
echo -e ' ======================================================='
echo -e '\e[39m'
if [ $tutorial = "1" ]; then
	echo -e "\e[93m In computer networking, a hostname is a label that is assigned\n to a device connected to a computer network and is used to identify\n the device in various forms of electronic communications such as\n the World Wide Web.\n"
	echo -e " An example hostname would looks like the following: raspberrypi.local\n"
	echo -e " With the .local domain name, you can use the hostname to connect\n to this device from another device on the same network.\n"
	echo -e '\e[39m'
fi
#This section askes for input from the user for what the hostname
#should be changed to. The IF statement checks to make sure there
#was something inputed and the varible is not NULL.
while true; do
	read -p " Enter the hostname you would like to apply: " newhostname
	if [ -z "$newhostname" ]; then
		echo -e "\e[91m !!!!!!!!!!!!!!!!!!!!!"
		echo -e "No Hostname Specified"
		echo -e "Try Again"
		echo -e "!!!!!!!!!!!!!!!!!!!!!!"
		echo -e "\e[39m"
	else
		break;
	fi
done
oldhostname="$( hostname )"
hostname $newhostname
sed -i "s/$oldhostname/$newhostname/g" /etc/hosts
sed -i "s/$oldhostname/$newhostname/g" /etc/hostname


#Start Clean out Pi's home directory
if [ $tutorial = "1" ]; then clear; fi
echo
echo -e '\e[92m ======================================='
echo -e "   Step 3: Clean out Pi's home directory"
echo -e ' ======================================='
echo -e '\e[39m'
if [ $tutorial = "1" ]; then
	echo -e "\e[93m So there are not any modified files left after this script\n has been ran, this script will remove the /home/pi directory,\n then recreate it"
	echo -e '\e[39m'
	read -p " Press Enter to continue . . . " pressenter
	echo
fi
umount /home/pi/.gvfs 2> /dev/null
rm -rf /home/pi
mkdir /home/pi
chown pi:pi /home/pi
#End Clean out Pi's home directory

#Start Update the Raspbian repositories
if [ $tutorial = "1" ]; then clear; fi
echo
echo -e '\e[92m =========================================='
echo -e '   Step 4: Update the Raspbian repositories'
echo -e ' =========================================='
echo -e '\e[39m'
if [ $tutorial = "1" ]; then
	echo -e "\e[93m The Advanced Packaging Tool (or APT) works with core libraries\n to handle the installation and removal of software\n"
	echo -e " Updating the Raspbian repositories resynchronizes the package index\n files from their online sources. This downloads any new information\n that is available about new or updated packages available\n online.\n"
	echo -e " This does not effect any currently installed packages. Those packages\n will be updated in Step 5\n"
	echo -e " This may take a few minutes."
	echo -e "\e[39m"
	read -p " Press Enter to continue . . . " pressenter
	echo
fi
sudo apt-get update -y
#End Update the Raspbian repositories

#Start Update any installed packages using the repositories
if [ $tutorial = "1" ]; then clear; fi
echo
echo -e '\e[92m =============================================================='
echo -e '   Step 5: Update any installed packages using the repositories'
echo -e ' =============================================================='
echo -e '\e[39m'
if [ $tutorial = "1" ]; then
	echo -e "\e[93m Now that the package list has been updated from the repositories\n it is time to update any packages currently installed using\n the available packages online."
	echo -e "\e[39m"
	read -p " Press Enter to continue . . . " pressenter
fi
sudo apt-get upgrade -y
#End Update any installed packages using the repositories

#Start Install and Configure Tight VNC Server
#Install Tight VNC Packages
if [ $tutorial = "1" ]; then clear; fi
echo
echo -e '\e[92m ================================================='
echo -e " Step 6: Install and Configure Tight VNC Server"
echo -e ' =============================================='
echo -e '\e[39m'
if [ $tutorial = "1" ]; then
	echo -e '\e93m Tight VNC Server will allow the Raspberry Pi'
	echo -e ' to be accessed remotely using the Graphical User Interface.'
	echo -e '\e39m'
	read -p ' Press Enter to continue . . . ' Pressenter
fi
sudo apt-get install tightvncserver -y
#Copy startup script and enable vncserver
sudo cp ./vncserver /etc/init.d/vncserver
sudo chmod 755 /etc/init.d/vncserver
sudo update-rc.d vncserver defaults
#Extract vnc passwd and xstartup files into the pi user's home directory
tar zxC /home/pi -f vnc_files.tar.gz
#End Install and Configure Tight VNC Server

exit 0

#Copy startup script and enable printing of hostname and ip to Grove Pi LCD connected to I2C port
cp ./grove-get-ip.py ~pi/
sudo cp ./print_ip /etc/init.d/print_ip
sudo chmod 755 /etc/init.d/print_ip
sudo update-rc.d print_ip defaults


#Clone required projects from github to ~pi
cd ~pi
/usr/bin/git clone https://github.com/IoTDevLabs/iot-educ.git
cd ~pi/iot-educ/rpi
./install-python-packages.sh

cd ~pi
/usr/bin/git clone https://github.com/DexterInd/GrovePi
cd GrovePi/Script
sudo chmod +x install.sh
sudo ./install.sh

cd ~pi/GrovePi/Software/Python
sudo python setup.py install

reboot
