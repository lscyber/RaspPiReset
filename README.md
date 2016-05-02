# Raspberry Pi Reset Script

## Introduction
This script will do the following:'
  1.  Change the hostname to the specified hostname'
	2.  Extend the file system to maximize storage space'
	3.  **RESET PI'S USER TO DEFAULT**"
	4.  Update the Raspbian repositories'
	5.  Update any installed packages using the repositories'
	6.  Install and Configure Tight VNC Server'
	7.  Setup LCD display script for displaying IP address'
	8.  Download and Replace IoT Dev Labs scripts'
	9.  Download and Replace GrovePi scripts'
	10. Finish up and Reboot'

## Instructions
1. On your Raspberry Pi, open a terminal window.
2. Type the following commands to download and run the reset script:
```
sudo git clone https://github.com/lscyber/RaspPiReset
cd RaspPiReset/
sudo chmod 775 reset.sh
sudo ./reset.sh
```
3. Follow the on-screen instructions.
