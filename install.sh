read -p 'Container ID Number: ' number
read -p 'Container Name: ' name
read -p ' CPU Cores:' cpu
read -p ' Static IP Address Of container (/CIDR) eg 192.168.1.20/24: ' ip
read -p ' Default Gateway eg 192.168.1.1: ' gw
pveam update
pveam download local alpine-3.14-default_20210623_amd64.tar.xz

pct create $number local:vztmpl/alpine-3.14-default_20210623_amd64.tar.xz --ostype alpine --hostname $name --net0 name=eth0,ip=$ip,gw=$gw,bridge=vmbr0 --memory 512 --cores $cpu --unprivileged 1 --nameserver 9.9.9.9 --cmode shell
pct start $number

pct exec $number apk update
pct exec $number apk upgrade
pct exec $number apk add curl
pct exec $number apk add sudo
pct exec $number apk add bash

pct exec $number -- bash -c 'curl -s -S -L https://raw.githubusercontent.com/AdguardTeam/AdGuardHome/master/scripts/install.sh | sh -s -- -v'
pct exec $number -- bash -c 'wget https://raw.githubusercontent.com/haris2887/Adguardd-Proxomx/MainBranch/AdguardHome -O /etc/init.d/AdGuardHome'

pct exec $number chmod +x /etc/init.d/AdGuardHome

pct exec $number rc-update add AdGuardHome
pct exec $number rc-update add AdGuardHome boot
pct exec $number reboot

echo You can now browse to $ip:3000 to resume the rest of the configuration.
