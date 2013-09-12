#!/bin/bash -x

#
# ruslantrachuk/VPN
#
# Installs a PPTP VPN-only system for Ubuntu
#

(

SSH_USER="vpn"
SSH_PASS="vpn"

VPN_IP=`curl ipv4.icanhazip.com>/dev/null 2>&1`

VPN_USER="myuser"
VPN_PASS="myuser"

VPN_LOCAL="192.168.244.1"
VPN_REMOTE="192.168.244.2-20"

# pptd installation & configuration
apt-get -y install pptpd
echo "localip $VPN_LOCAL" >> /etc/pptpd.conf # Local IP address of your VPN server
echo "remoteip $VPN_REMOTE" >> /etc/pptpd.conf # Scope for your home network

echo "ms-dns 8.8.8.8" >> /etc/ppp/pptpd-options # Google DNS Primary
echo "ms-dns 4.4.4.4" >> /etc/ppp/pptpd-options # Google DNS Primary


echo "$VPN_USER pptpd $VPN_PASS *" >> /etc/ppp/chap-secrets

/etc/init.d/pptpd restart


# ip_forward & iptables configuration
## ip_forward
echo "1" > /proc/sys/net/ipv4/ip_forward
sed -i 's/#net.ipv4.ip_forward=1/net.ipv4.ip_forward = 1/g' /etc/sysctl.conf
sysctl -p /etc/sysctl.conf

## iptables
echo "iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE" >> /etc/rc.local
iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE

### save iptables
iptables-save > /etc/iptables.conf
 
### enables iptables on boot
cat > /etc/network/if-pre-up.d/iptables <<END
#!/bin/sh
iptables-restore < /etc/iptables.conf
END
 
chmod +x /etc/network/if-pre-up.d/iptables
cat >> /etc/ppp/ip-up <<END
ifconfig ppp0 mtu 1400
END

# configure SSH
## create new SSH user to be used to access the system
egrep "^$SSH_USER" /etc/passwd >/dev/null
if [ $? -eq 0 ]; then
	echo "$SSH_USER exists!"
	exit 1
else
	pass=$(perl -e 'print crypt($ARGV[0], "password")' $SSH_PASS)
	useradd -m -p "$pass" "$SSH_USER" 
	[ $? -eq 0 ] && echo "User has been added to system!" || echo "Failed to add a user!"
	usermod -aG sudo "$SSH_USER"
fi


## change ssh access policy 
sed -i 's/Port 22/Port 102/g' /etc/ssh/sshd_config # Use port 102 instead of 22 for SSH
sed -i 's/PermitRootLogin yes/PermitRootLogin no/g' /etc/ssh/sshd_config # Disable root access via SSH

## prevent IP spoofing
echo "nospoof on" >> //etc/host.conf

# install fail2ban
apt-get -y install denyhosts fail2ban
sed -i 's/port = ssh/port = 102/g' /etc/fail2ban/jail.conf # configure new SSH port 102

) 2>&1 | tee /var/log/vpn-installer.log
