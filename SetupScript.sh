#!/bin/bash
#Welcome to the Raspberry Pi Setup Script - Version 1.0
#Last Compiled by Kevin Schulmeister on 12/3/16
#This script was designed for the Lee's Summit School District Raspberry Pi's
#This script also includes detailed tutorials and comments for others to learn basic scripting

#The following makes sure the script is ran as root (EUID 0).
#This is required because some commands in this script require root privileges
#The \e[91m potion of the text changes the output color to red for any characters after the m
#The EUID varible shows which user ran the script. Root's EUID is 0, so if the EUID matches 0, the script was ran by root.
if (( $EUID != 0 )); then
	echo
	echo -e "\e[91m !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
	echo -e " ERROR: THIS SCRIPT MUST BE RAN AS ROOT"
	echo -e " TRY TO RERUN THIS SCRIPT USING THE SUDO COMMAND"
	echo -e " EXITING"
	echo -e " !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
	echo -e "\e[39m" #Returns the console text to White.
	exit #Exits the script so nothing further is ran.
fi

#For a nice experience while running the script, it will occasionally clear the screen.
#In a terminal window, the user will still be able to scroll up and view what had been cleared.
clear

#This portion of the script informs the user to everything the script will be changing
#then confirms with the user they want to continue. If a user enters Y or y, the script breaks out
#of the while loop, and continues with the script. If the user enters a N or n, the script exits out
#without error. If the user enters anything else, it will let the user know and restart the loop at the top.

while true; do
	echo
	echo
	echo -e '\e[92m *****************************************'
	echo -e '   Welcome to the Raspberry Pi Setup Script - Version 1.0'
	echo -e '   Compiled by Kevin Schulmeister on 12/3/16'
	echo -e '   This script will reset and load the default configuration specified below.'
	echo -e ' *****************************************'
	echo -e '\e[39m'
	echo
	echo -e '\e[93m This script will do the following:'
	echo -e '     1.  Change the hostname to the specified hostname'
	echo -e '     2.  Extend the file system to maximize storage space'
	echo -e "     3.  **RESET PI'S USER TO DEFAULT"
	echo -e '     4.  Update the Raspbian repositories'
	echo -e '     5.  Update any installed packages using the repositories'
	echo -e '     6.  Install and Configure Tight VNC Server'
	echo -e '     7.  Setup LCD display script for displaying IP address'
	echo -e '     8.  Download and Replace IoT Dev Labs scripts'
	echo -e '     9.  Download and Replace GrovePi scripts'
	echo -e '     10. Finish up and Reboot'
	echo -e '\e[39m'
	echo -e '\e[91m A restart will be required at the end of this script.'
	echo -e ' Please save any open work, and close any open applications'
	echo -e ' before continuing. Any unsaved work may be lost.'
	echo -e '\e[39m'
	read -p " Do you want to continue? [y/n] " yn1
	case $yn1 in
		[Yy]* ) break;;
		[Nn]* ) echo; echo ' Goodbye!'; echo; exit 0;;
		* ) clear; echo -e "\e[91m Please answer yes or no.\e[39m";;
	esac
done

#Since there are a few extra resource files, this script will automatically
#download them from the specified Raspberry Pi Server image.
echo
read -p " Enter the IP address or URL of the Raspberry Pi Server: " ServerIPAddress
echo

#This portion of the script is changing the hostname of the Raspberry Pi in 3 locations
#It is setting the hostname using the hostname command, and changing the hostnam in the
#/etc/hosts and /etc/hostname files. These 3 locations must be changed to effectively
#change the hostname of the system. For this, it will use the SED command.
echo
echo -e '\e[92m ======================================================='
echo -e '   Step 1: Change the hostname to the specified hostname'
echo -e ' ======================================================'
echo -e '\e[39m'
echo -e '\e[93m In computer networking, a hostname is a label that is assigned'
echo -e ' to a device connected to a computer network and is used to identify'
echo -e ' the device in various forms of electronic communication such as'
echo -e ' the World Wide Web.'
echo
echo -e ' An example hostname would look like the following: raspberrypi.local'
echo -e ' With the .local domain name, you can use the hostname to connect'
echo -e ' to this device from another device on the same network'
echo
echo -e ' Leave the space blank to keep the current hostname'
echo -e '\e[39m'

#This section asks for input from the user for what the hostname
#should be changed to. The IF statement checks to make sure there
#was something inputed and the variable is not NULL.
read -p " Enter the hostname you would like to apply: " newhostname
if [ -z "$newhostname" ]; then
	echo -e '\e[91m !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!'
	echo -e 'No Hostname Specified. No Change Has Been Made.'
	echo -e " !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
	echo -e '\e[39m'
else
	oldhostname="$( hostname )"
	hostname $newhostname
	sed -i "s/$oldhostname/$newhostname/g" /etc/hosts
	sed -i "s/$oldhostname/$newhostname/g" /etc/hostname
fi


#This next section expands the file system.
#This resizes the root file system of a newly flashed Raspbian image.
#Directly equivalent to the expand_rootfs section of raspi-config

echo
echo -e '\e[92m =========================================================='
echo -e '   Step 2: Extend the file system to maximize storage space'
echo -e ' =========================================================='
echo -e '\e[39m'
echo -e '\e[93m This script will expand the current file system to use all of the available space'
echo -e ' on the SD card.'
echo -e '\e[39m'
read -p " Press Enter to continue . . . " pressenter
echo


#Taken from http://www.raspberrypi.org/wiki/doku.php/raspi-expand-rootfs
#Get the starting offset of the root partition
PART_START=$(parted /dev/mmcblk0 -ms unit s p | grep "^2" | cut -f 2 -d:)
[ "$PART_START" ] || return 1
#Return value will likely be error for fdisk as it fails to reload the
# partition table because the root fs is mounted
fdisk /dev/mmcblk0 <<EOF
p
d
2
n
p
2
$PART_START

p
w
EOF

#now set up an init.d script
cat <<\EOF > /etc/init.d/resize2fs_once &&
#!/bin/sh
### BEGIN INIT INFO
# Provides: resize2fs_once
# Required-Start:
# Required-Stop:
# Default-Start: 2 3 4 5 S
# Default-Stop:
# Short-Description: Resize the root filesystem to fill partition
# Description:
### END INIT INFO

. /lib/lsb/init-functions

case "\$1" in
	start)
		log_daemon_msg "Starting resize2fs_once" &&
		resize2fs /dev/mmcblk0p2 &&
		rm /etc/init.d/resize2fs_once &&
		update-rc.d resize2fs_once remove &&
		log_end_msg $?
		;;
	*)
		echo "Usage: \$0 start" >&2
		exit 3
		;;
esac
EOF
chmod +x /etc/init.d/resize2fs_once &&
update-rc.d resize2fs_once defaults &&
echo
echo "Root partition has been resized. The filesystem will be enlarged upon the next reboot"

echo
echo -e '\e[92m ===================================='
echo -e "   Step 3: Reset Pi's user to default"
echo -e ' ===================================='
echo -e '\e[39m'
echo -e '\e[93m This portion will remove /home/pi directory'
echo -e ' so there are not any modified files left after'
echo -e ' this script has been ran, and then recreates it'
echo -e '\e[39m'
read -p " Press Enter to continue . . . " pressenter

umount /home/pi/.gvfs 2> /dev/null
rm -rf /home/pi
wget http://$ServerIPAddress/pi.tar.gz
tar zxC /home/ -f pi.tar.gz
mkdir /home/pi/Desktop
mkdir /home/pi/Documents
mkdir /home/pi/Downloads
mkdir /home/pi/Music
mkdir /home/pi/Public
mkdir /home/pi/Templates
mkdir /home/pi/Videos
rm pi.tar.gz


echo
echo -e '\e[92m =========================================='
echo -e '   Step 4: Update the Raspbian repositories'
echo -e ' =========================================='
echo -e '\e[39m'
echo -e '\e[93m The Advanced Packaging Tool (or APT) works with core libraries'
echo -e ' to handle the installation and removal of software'
echo -e ' Updating the Raspbian repositories resynchronizes the package index'
echo -e ' This does not effect any currently installed packages. Those packages'
echo -e ' will be updated in Step 5.'
echo -e ' This may take a few minutes.'
echo -e '\e[39m'
read -p " Press Enter to continue . . . " Pressenter
echo
sudo apt-get update -y

echo
echo -e '\e[92m ============================================================='
echo -e '   Step 5: Update any installed package using the repositories'
echo -e ' ============================================================='
echo -e '\e[39m'
echo -e '\e[93m Now that the package list has been updated from the repositories'
echo -e ' it is time to update any packages currently installed using'
echo -e ' the available packages online'
echo -e ' This process can take some time.'
echo -e '\e[39m'
read -p " Press Enter to continue . . . " Pressenter
sudo apt-get upgrade -y

echo
echo -e '\e[92m ================================================'
echo -e '   Step 6: Install and Configure Tight VNC Server'
echo -e ' ================================================'
echo -e '\e[39m'
echo -e '\e[93m Tight VNC Server will allow the Raspberry Pi'
echo -e ' to be accessed remotely using the Graphical User Interface.'
echo -e '\e[39m'
read -p " Press Enter to continue . . . " Pressenter
sudo apt-get install tightvncserver -y
wget http://$ServerIPAddress/vncserver.txt
mv vncserver.txt vncserver
sudo mv ./vncserver /etc/init.d/vncserver
sudo chmod 755 /etc/init.d/vncserver
sudo update-rc.d vncserver defaults

#Setup startup script and enable printing of hostname and ip to Grove Pi LCD connected to I2C port
echo
echo -e '\e[92m ============================================================'
echo -e '   Step 7: Setup LCD display script for displaying IP address'
echo -e ' ============================================================'
echo -e '\e[39m'
echo -e "\e[93m This script will display the Pi's IP address"
echo -e ' on the LCD display connected to the Grove Pi'
echo -e ' This script was initially created by Chris Soukup'
echo -e '\e[39m'
read -p " Press Enter to continue . . . " Pressenter

cat <<EOT >> grove-get-ip.py
import time,sys
import RPi.GPIO as GPIO
import smbus
import socket
import fcntl
import struct

# this device has two I2C addresses
DISPLAY_RGB_ADDR = 0x62
DISPLAY_TEXT_ADDR = 0x3e

# use the bus that matches your raspi version
rev = GPIO.RPI_REVISION
if rev == 2 or rev == 3:
    bus = smbus.SMBus(1)
else:
    bus = smbus.SMBus(0)

# set backlight to (R,G,B) (values from 0..255 for each)
def setRGB(r,g,b):
    bus.write_byte_data(DISPLAY_RGB_ADDR,0,0)
    bus.write_byte_data(DISPLAY_RGB_ADDR,1,0)
    bus.write_byte_data(DISPLAY_RGB_ADDR,0x08,0xaa)
    bus.write_byte_data(DISPLAY_RGB_ADDR,4,r)
    bus.write_byte_data(DISPLAY_RGB_ADDR,3,g)
    bus.write_byte_data(DISPLAY_RGB_ADDR,2,b)

# send command to display (no need for external use)    
def textCommand(cmd):
    bus.write_byte_data(DISPLAY_TEXT_ADDR,0x80,cmd)

# set display text \n for second line(or auto wrap)     
def setText(text):
    textCommand(0x01) # clear display
    time.sleep(.05)
    textCommand(0x08 | 0x04) # display on, no cursor
    textCommand(0x28) # 2 lines
    time.sleep(.05)
    count = 0
    row = 0
    for c in text:
        if c == '\n' or count == 16:
            count = 0
            row += 1
            if row == 2:
                break
            textCommand(0xc0)
            if c == '\n':
                continue
        count += 1
        bus.write_byte_data(DISPLAY_TEXT_ADDR,0x40,ord(c))

def get_ip_address(ifname):
    s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
    return socket.inet_ntoa(fcntl.ioctl(
        s.fileno(),
        0x8915,  # SIOCGIFADDR
        struct.pack('256s', ifname[:15])
    )[20:24])


# example code
if __name__=="__main__":
    hostname = socket.gethostname()
    wlan0_ipaddr = get_ip_address('wlan0')
    setText('IP:\n%s' % (wlan0_ipaddr))
#    setText('%s\n%s' % (hostname, wlan0_ipaddr))
    setRGB(0,128,64)
    #for c in range(0,255):
    #    setRGB(c,255-c,0)
    #    time.sleep(0.01)
    #setRGB(0,255,0)

EOT

mv ./grove-get-ip.py /home/pi/

if [ ! -f /etc/init.d/print_ip ]; then

cat <<EOT >> print_ip
#!/bin/sh
# /etc/init.d/print_ip

### BEGIN INIT INFO
# Provides:          print_ip
# Required-Start:    \$remote_fs x11-common
# Required-Stop:     \$remote_fs
# Default-Start:     2 3 4 5
# Default-Stop:      0 1 6
# X-Interactive:     true
# Short-Description: Print Hostname and IP to Grove LCD connected to I2C at boot
# Description:       Print Hostname and IP to Grove LCD connected to I2C at boot
### END INIT INFO

USER=pi
HOME=/home/pi

export USER HOME

case "\$1" in
  start)
    echo "Printing Hostname and IP to Grove LCD Display."
    sleep 30
    /usr/bin/python \$HOME/grove-get-ip.py
    ;;

  stop)
    echo "Nothing to stop."
    ;;

  *)
    echo "Usage: /etc/init.d/print_ip {start|stop}"
    exit 1
    ;;
esac

exit 0
EOT

mv ./print_ip /etc/init.d/print_ip
chmod 755 /etc/init.d/print_ip
update-rc.d print_ip defaults
echo dtparam=i2c_arm=on >> /boot/config.txt
fi

#Clone required projects from github to ~pi
echo
echo -e '\e[92m ================================================='
echo -e " Step 8: Download and Replace IoT Dev Labs scripts"
echo -e ' ================================================='
echo -e '\e[39m'
echo -e "\e[93m This will download anything required for the IoT Dev Labs"
echo -e '\e[39m'
read -p " Press Enter to continue . . . " Pressenter

cd ~pi
/usr/bin/git clone https://github.com/IoTDevLabs/iot-educ.git
cd ~pi/iot-educ/rpi
./install-python-packages.sh

#Copy startup script and enable printing of hostname and ip to Grove Pi LCD connected to I2C port
echo
echo -e '\e[92m ============================================'
echo -e " Step 9: Download and Replace GrovePi scripts"
echo -e ' ============================================'
echo -e '\e[39m'
echo -e "\e[93m This will download anything required for the GrovePi."
echo -e '\e[39m'
read -p " Press Enter to continue . . . " Pressenter

cd ~pi
/usr/bin/git clone https://github.com/DexterInd/GrovePi
cd GrovePi/Script
sudo chmod +x install.sh
sudo ./install.sh
cd ~pi/GrovePi/Software/Python
sudo python setup.py install

#Finishing up
echo
echo -e '\e[92m =========================================================='
echo -e " Step 10: Finish up and Reboot"
echo -e ' =========================================================='
echo -e '\e[39m'
echo -e "\e[93m This portion will reset any permissions on Pi's files, setup"
echo -e ' the wireless to connect to LSSD_Handheld, set the time zone to'
echo -e ' America/Chicago, and reboot the system.'
echo -e '\e[39m'
read -p ' Press Enter to continue . . . ' Pressenter
chown -R pi:pi /home/pi
cat <<EOT >> wpa_supplicant.conf
ctrl_interface=DIR=/var/run/wpa_supplicant GROUP=netdev
update_config=1

network={
	ssid="LSSD_HANDHELD"
	key_mgmt=NONE
}
EOT
mv wpa_supplicant.conf /etc/wpa_supplicant/
cp /usr/share/zoneinfo/America/Chicago /etc/localtime
read -p " Press Enter to Reboot . . . " Pressenter
reboot
