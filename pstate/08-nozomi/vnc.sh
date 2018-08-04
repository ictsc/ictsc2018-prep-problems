## webrtc用s

iptables -t nat -A PREROUTING -p tcp --dport 80 -j DNAT --to-destination 192.168.0.100
iptables -t nat -A PREROUTING -p tcp --dport 443 -j DNAT --to-destination 192.168.0.100



iptables-save > iptables.dat
echo 'iptables-restore < /root/iptables.dat' >> /etc/rc.local
