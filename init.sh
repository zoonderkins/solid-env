#!/bin/bash
clear

# Where your config start here

## Enable CDN on apt source
cat >> /etc/apt/sources.list <<EOL 
deb http://cdn-aws.deb.debian.org/debian/ sid main
deb http://cdn-aws.deb.debian.org/debian/ buster main
EOL

## Install common package
apt update && apt install build-essential module-assistant dkms htop nload iftop ncdu knot-dnsutils tcpdump mtr sudo locales net-tools dnsutils wget curl rsync git jq unzip netcat socat ca-certificates apt-transport-https gnupg2 haveged
source /etc/profile
systemctl enable --now haveged > /dev/null 2>&1

## DNS resolver
systemctl mask --now systemd-resolved > /dev/null 2>&1
systemctl daemon-reload > /dev/null 2>&1

rm -rf /etc/resolv.conf
cat << EOF > /etc/resolv.conf
nameserver 1.0.0.2
nameserver 9.9.9.9
EOF

## Enable Swap 1G 

checkSWAP=`swapon --show`
if [[ -z "$checkSWAP" ]]; then
fallocate -l 1G /swapfile
dd if=/dev/zero of=/swapfile bs=1k count=1024k status=progress
chmod 600 /swapfile
mkswap /swapfile
swapon /swapfile
sed -i "/swapfile/d" /etc/fstab
echo "/swapfile swap swap defaults 0 0" >> /etc/fstab
echo "RESUME=" > /etc/initramfs-tools/conf.d/resume
update-initramfs -u
fi

## Fix Error for
## perl: warning: Setting locale failed.

echo "en_US.UTF-8 UTF-8" > /etc/locale.gen
cat << EOF > /etc/default/locale
LANG=en_US.UTF-8
LANGUAGE=en_US.UTF-8
LC_CTYPE="en_US.UTF-8"
LC_NUMERIC="en_US.UTF-8"
LC_TIME="en_US.UTF-8"
LC_COLLATE="en_US.UTF-8"
LC_MONETARY="en_US.UTF-8"
LC_MESSAGES="en_US.UTF-8"
LC_PAPER="en_US.UTF-8"
LC_NAME="en_US.UTF-8"
LC_ADDRESS="en_US.UTF-8"
LC_TELEPHONE="en_US.UTF-8"
LC_MEASUREMENT="en_US.UTF-8"
LC_IDENTIFICATION="en_US.UTF-8"
LC_ALL=en_US.UTF-8
EOF
locale-gen en_US.UTF-8

## Set time zone to Asia/Taipei
echo "Asia/Taipei" > /etc/timezone
ln -sf /usr/share/zoneinfo/Asia/Taipei /etc/localtime

date -s "$(wget -qSO- --max-redirect=0 google.com 2>&1 | grep Date: | cut -d' ' -f5-8)Z"
hwclock -w
}

## Enable BBR and tune sysctl.conf

cat << EOF > /etc/security/limits.conf
* soft nofile 1000000
* hard nofile 1000000
* soft nproc 64000
* hard nproc 64000
EOF
echo "ulimit -n 1000000" > ~/.bash_profile

cat << EOF > /etc/sysctl.conf
vm.overcommit_memory = 1
vm.swappiness = 10
fs.file-max = 1000000
fs.inotify.max_user_instances = 1000000
fs.inotify.max_user_watches = 1000000
net.core.default_qdisc= fq
net.ipv4.tcp_congestion_control= bbr
net.core.netdev_max_backlog = 32768
net.core.optmem_max = 8388608
net.core.rmem_max = 8388608
net.core.rmem_default = 8388608
net.core.wmem_max = 8388608
net.core.wmem_default = 8388608
net.core.somaxconn = 32768
net.netfilter.nf_conntrack_checksum = 0
net.netfilter.nf_conntrack_max = 1000000
net.nf_conntrack_max = 1000000
net.ipv6.ip_forward = 1
net.ipv6.conf.all.forwarding = 1
net.ipv6.conf.all.proxy_ndp = 1
net.ipv6.route.max_size = 16384
net.ipv6.conf.all.autoconf = 1
net.ipv6.conf.all.accept_ra = 2
net.ipv4.icmp_echo_ignore_broadcasts = 1
net.ipv4.icmp_ignore_bogus_error_responses = 1
net.ipv4.conf.all.arp_ignore = 1
net.ipv4.conf.default.arp_ignore = 1
net.ipv4.conf.all.rp_filter = 2
net.ipv4.conf.default.rp_filter = 2
net.ipv4.ip_local_port_range = 1025 65535
net.ipv4.tcp_window_scaling = 1
net.ipv4.tcp_fastopen = 3
net.ipv4.tcp_timestamps = 1
net.ipv4.tcp_tw_reuse = 1
net.ipv4.tcp_syncookies = 1
net.ipv4.tcp_mtu_probing = 1
net.ipv4.tcp_fin_timeout = 15
net.ipv4.tcp_orphan_retries = 2
net.ipv4.tcp_syn_retries = 2
net.ipv4.tcp_synack_retries = 2
net.ipv4.tcp_sack = 1
net.ipv4.tcp_max_syn_backlog = 32768
net.ipv4.tcp_max_tw_buckets = 6000
net.ipv4.tcp_max_orphans = 32768
net.ipv4.tcp_mem = 25600 51200 102400
net.ipv4.tcp_rmem = 4096 87380 8388608
net.ipv4.tcp_wmem = 4096 87380 8388608
net.ipv4.tcp_keepalive_time = 1800
net.ipv4.tcp_keepalive_intvl = 15
net.ipv4.tcp_keepalive_probes = 3
net.ipv4.tcp_rfc1337 = 1
EOF
sysctl -p

## Force SSH enable Color [TODO]

