# VPN node 

PPTP VPN Installer for Ubuntu 13.04 droplet on Digital Ocean
In addition to PPTP instatlation and configuration the script does the following
- change ssh access policy 
	- switch ssh to port 102
	- create new sudoer user 
	- disable ssh access for root user
- install fail2ban

Based on git://github.com/drewsymo/VPN.git

## Installation

To get started with your own secure VPN, simply execute the following commands at your servers command-line:

	$ apt-get -y install git
	$ cd /opt && git clone git://github.com/ruslantrachuk/VPN.git
	$ cd VPN && chmod +x complete-setup-ubuntu.sh
	$ bash complete-setup-ubuntu.sh

You can change cridentionals in vpn-setup.sh if it's needed.

Use vpn-setup-ubuntu.sh if you need to install & configure pptpd only

