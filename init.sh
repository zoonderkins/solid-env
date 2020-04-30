#!/bin/bash
clear

# Where your config start here

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
