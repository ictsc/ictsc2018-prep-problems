echo post-up ip route add 172.20.0.0/16 via 192.168.0.1 dev eth1 >> /etc/network/interfaces
systemctl restart networking
