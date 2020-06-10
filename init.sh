#!/bin/bash
clear

# Where your config start here

## Enable CDN on apt source
cat >> /etc/apt/sources.list <<EOL 
deb http://cdn-aws.deb.debian.org/debian/ sid main
deb http://cdn-aws.deb.debian.org/debian/ buster main
EOL

## Install common package
apt update && apt install build-essential module-assistant dkms htop nload iftop ncdu knot-dnsutils tcpdump mtr sudo locales net-tools dnsutils wget curl rsync git jq unzip netcat socat ca-certificates apt-transport-https gnupg2 gnupg-agent haveged
## apt search linux-headers 
uname -r
hostnamectl
lsb_release -a
apt install linux-image-5.6.0-2-amd64 
apt install linux-headers-5.6.0-2-amd64 linux-headers-5.6.0-2-common linux-compiler-gcc-9-x86 
## List current installed linux kernerl
dpkg -l *linux-image*|grep ii

source /etc/profile
systemctl enable --now haveged > /dev/null 2>&1

## DNS resolver
systemctl mask --now systemd-resolved > /dev/null 2>&1
systemctl daemon-reload > /dev/null 2>&1

rm -rf /etc/resolv.conf
cat << EOF > /etc/resolv.conf
nameserver 1.0.0.2
nameserver 2606:4700:4700::1002
nameserver 9.9.9.9
nameserver 2620:fe::9
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

## Force SSH enable Color
cat >> ~/.bashrc <<EOL
force_color_prompt=yes

if [ -n "$force_color_prompt" ]; then
    if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
        # We have color support; assume it's compliant with Ecma-48
        # (ISO/IEC-6429). (Lack of such support is extremely rare, and such
        # a case would tend to support setf rather than setaf.)
        color_prompt=yes
    else
        color_prompt=
    fi
fi

if [ "$color_prompt" = yes ]; then
    #PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
    PS1='${debian_chroot:+($debian_chroot)}\[\033[01;31m\]\u\[\033[01;33m\]@\[\033[01;36m\]\h \[\033[01;33m\]\w \[\033[01;35m\]\$ \[\033\[\033[00m\]'
else
    PS1='${debian_chroot:+($debian_chroot)}\u@\h:\w\$ '
fi
unset color_prompt force_color_prompt

# If this is an xterm set the title to user@host:dir
case "$TERM" in
xterm*|rxvt*)
    PS1="\[\e]0;${debian_chroot:+($debian_chroot)}\u@\h: \w\a\]$PS1"
    ;;
*)
    ;;
esac
# enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
    #alias dir='dir --color=auto'
    #alias vdir='vdir --color=auto'

    #alias grep='grep --color=auto'
    #alias fgrep='fgrep --color=auto'
    #alias egrep='egrep --color=auto'
fi

if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi

if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
  fi
fi

EOL

source ~/.bashrc

## Yggdrasil debian gpg
gpg --fetch-keys https://neilalexander.s3.dualstack.eu-west-2.amazonaws.com/deb/key.txt
gpg --export 569130E8CA20FBC4CB3FDE555898470A764B32C9 | sudo apt-key add -
echo 'deb http://neilalexander.s3.dualstack.eu-west-2.amazonaws.com/deb/ debian yggdrasil' | sudo tee /etc/apt/sources.list.d/yggdrasil.list
apt-get update

## I2pd
wget -q -O - https://repo.i2pd.xyz/.help/add_repo | sudo bash -s -
apt-get update
apt-get install i2pd

## Install docker CE
curl -fsSL https://download.docker.com/linux/debian/gpg | sudo apt-key add -
add-apt-repository \
   "deb [arch=amd64] https://download.docker.com/linux/debian \
   $(lsb_release -cs) \
   stable"
apt -y update && apt install docker-ce docker-ce-cli containerd.io

## Knot-resolver Debian
echo 'deb http://download.opensuse.org/repositories/home:/CZ-NIC:/knot-resolver-latest/Debian_Next/ /' > /etc/apt/sources.list.d/home:CZ-NIC:knot-resolver-latest.list
wget -nv https://download.opensuse.org/repositories/home:CZ-NIC:knot-resolver-latest/Debian_Next/Release.key -O Release.key
apt-key add - < Release.key
apt-get -y update && apt-get install knot-resolver

