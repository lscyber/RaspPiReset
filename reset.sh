#!/bin/bash
#Welcome to the Raspberry Pi Reset Script - Version 1.0 BETA
#Last Compiled by Kevin Schulmeister on 5/1/16
#This script was designed for the Lee's Summit School District Raspberry Pi's
#This script also includes detailed tutorials and comments for others to learn basic scripting

#The following makes sure the script is ran as root
#This is required because some commands in this script require root privileges
#The \e[91m potion of the text changes the output color to red for any characters after the m
#The EUID varible shows which user ran the script. Root's EUID is 0, so if the EUID matched 0, the script was ran by root.
if (( $EUID != 0 )); then
	echo
	echo -e "\e[91m !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
	echo -e " ERROR: THIS SCRIPT MUST BE RAN AS ROOT"
	echo -e " TRY TO RERUN THIS SCRIPT USING THE SUDO COMMAND"
	echo -e " EXITING"
	echo -e " !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
	echo -e "\e[39m"
	exit
fi

#For a nice experience while running the script, it will occasionally clear the screen.
#In a terminal window, the user will still be able to scroll up and view what had been cleared.
clear

#This portion of the script informs the user to everything the script will be changing
#then confirms with the user they want to continue. If a user enters a Y or y, the script breaks out
#of the while loop, and continues with the script. If the user enters a N or n, the script exits out
#without error. If the user enters anything else, it will let the user know and restart the loop at the top.
#This analysis of the yn1 variable is done in a CASE. Each entry of the CASE is checked in order. If it
#matches, it runs the entries and continues down the list unless specified otherwise. The * entry is anything.
while true; do
	echo
	echo
	echo -e '\e[92m ****************************************************************************'
	echo -e '   Welcome to the Raspberry Pi Reset Script - Version 1.0 BETA'
	echo -e '   Compiled by Kevin Schulmeister on 5/1/16'
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
	echo -e "      7.  Reset Pi's user to default"
	echo -e '      8.  Setup LCD display script for displaying IP address'
	echo -e '      9.  Download and Replace IoT Dev Labs scripts'
	echo -e '      10. Download and Replace GrovePi scripts'
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

#This portion of the script will enable tutorials and pauses in the script.
#It is setting the variable tutorial to either 0 or 1.
#Once again, a CASE is used to check for Yy or Nn.
while true; do
	read -p " Do you want to run this script with tutorials? [y/n] " yn2
	case $yn2 in
		[Yy]* ) echo -e "   **Tutorials have been enabled and will be shown in \e[93mYellow\e[39m**"; tutorial="1"; echo; break;;
		[Nn]* ) echo "   **Tutorials have been disabled**"; tutorial="0"; echo; break;;
		* ) echo " Please answer yes or no."; echo;
	esac
done

#This portion of the script is changing the hostname of the Raspberry Pi in 3 locations
#It is setting the hostname using the hostname command, and changing the hostname in the
#/etc/hosts and /etc/hostname files. These 3 locations must be changed to effectively 
#change the hostname of a system. For this, it will use the SED command
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

#Start Extend the file system to maximize storage space
echo
echo -e '\e[92m =========================================================='
echo -e '   Step 2: Extend the file system to maximize storage space'
echo -e ' =========================================================='
echo -e '\e[39m'
if [ $tutorial = "1" ]; then
	echo -e "\e[93m In computer networking, a hostname is a label that is assigned\n to a device connected to a computer network and is used to identify\n the device in various forms of electronic communications such as\n the World Wide Web.\n"
	echo -e " An example hostname would looks like the following: raspberrypi.local\n"
	echo -e " With the .local domain name, you can use the hostname to connect\n to this device from another device on the same network.\n"
	echo -e '\e[39m'
	read -p " Press Enter to continue . . . " pressenter
	echo
fi
chmod 775 raspi-expand-rootfs.sh
./raspi-expand-rootfs.sh
#End Extend the file system to maximize storage space

#Start Clean out Pi's home directory. 
#For the LSR7 Pi's, we want to make sure nothing is left
#in Pi's directory so a clean start can be made. The rm -rf removes everything in the directory
#then deleted the folder itself. The folder is remade using the MKDIR command, then given Pi's
#user the permission to use it with the CHOWN command.
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
tar zxC /home/ -f pi.tar.gz
mkdir /home/pi/Desktop
mkdir /home/pi/Documents
mkdir /home/pi/Downloads
mkdir /home/pi/Music
mkdir /home/pi/Public
mkdir /home/pi/Templates
mkdir /home/pi/Videos
chown -R pi:pi /home/pi
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
	echo -e "\e[93m Now that the package list has been updated from the repositories"
	echo -e " it is time to update any packages currently installed using"
	echo -e " the available packages online."
	echo -e " This process can take some time."
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
	echo -e "\e[93m Tight VNC Server will allow the Raspberry Pi"
	echo -e ' to be accessed remotely using the Graphical User Interface.'
	echo -e '\e[39m'
	read -p ' Press Enter to continue . . . ' Pressenter
fi
sudo apt-get install tightvncserver -y
#Copy startup script and enable vncserver
sudo cp ./vncserver /etc/init.d/vncserver
sudo chmod 755 /etc/init.d/vncserver
sudo update-rc.d vncserver defaults
#End Install and Configure Tight VNC Server











#Copy startup script and enable printing of hostname and ip to Grove Pi LCD connected to I2C port
if [ $tutorial = "1" ]; then clear; fi
echo
echo -e '\e[92m =========================================================='
echo -e " Step 8: Setup LCD display script for displaying IP address"
echo -e ' =========================================================='
echo -e '\e[39m'
if [ $tutorial = "1" ]; then
	echo -e "\e[93m This script will display the Pi's IP address"
	echo -e ' on the LCD display connected to the Grove Pi'
	echo -e ' This script was initially created by Chris Soukup'
	echo -e '\e[39m'
	read -p ' Press Enter to continue . . . ' Pressenter
fi
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
