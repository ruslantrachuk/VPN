#!/bin/bash -x

#
# ruslantrachuk/VPN
#
# Installs a PPTP VPN-only system for Ubuntu
#

(

VPN_USER="myuser"
VPN_PASS="mypass"

VPN_LOCAL="192.168.244.1"
VPN_REMOTE="192.168.244.2-20"

# pptd installation & configuration
apt-get -y install pptpd
echo "localip $VPN_LOCAL" >> /etc/pptpd.conf # Local IP address of your VPN server
echo "remoteip $VPN_REMOTE" >> /etc/pptpd.conf # Scope for your home network

echo "ms-dns 8.8.8.8" >> /etc/ppp/pptpd-options # Google DNS Primary pptpd-options
echo "ms-dns 4.4.4.4" >> /etc/ppp/pptpd-options # Google DNS Primary pptpd-options

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


) 2>&1 | tee /var/log/vpn-installer.log