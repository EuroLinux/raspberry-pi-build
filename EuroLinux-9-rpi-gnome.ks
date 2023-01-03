url --url="https://fbi.cdn.euro-linux.com/dist/eurolinux/server/9/aarch64/BaseOS/os/"
rootpw --plaintext raspberry

# Repositories to use
repo --name="baseos"    --baseurl=https://fbi.cdn.euro-linux.com/dist/eurolinux/server/9/aarch64/BaseOS/os/
repo --name="appstream" --baseurl=https://fbi.cdn.euro-linux.com/dist/eurolinux/server/9/aarch64/AppStream/os/
repo --name="raspberrypi" --baseurl=https://fbi.cdn.euro-linux.com/dist/eurolinux/server/9/aarch64/RPI/all/ --cost=1000 --install

# install
keyboard us --xlayouts=us --vckeymap=us
timezone --isUtc --nontp UTC
selinux --enforcing
firewall --enabled --port=22:tcp
network --bootproto=dhcp --device=link --activate --onboot=on
services --enabled=sshd,NetworkManager,chronyd
shutdown
bootloader --location=mbr
lang en_US.UTF-8

# Disk setup
clearpart --initlabel --all
part /boot --asprimary --fstype=vfat --size=512 --label=boot
part swap --asprimary --fstype=swap --size=256 --label=swap
part / --asprimary --fstype=ext4 --size=4400 --label=rootfs

# Package setup
%packages
@core
@gnome-desktop
firefox
bash-completion
dejavu-sans-fonts
dejavu-sans-mono-fonts
dejavu-serif-fonts
aajohan-comfortaa-fonts
abattis-cantarell-fonts
-caribou*
-gnome-shell-browser-plugin
-java-1.6.0-*
-java-1.7.0-*
-java-11-*
-python*-caribou*
NetworkManager-wifi
el-release
chrony
cloud-utils-growpart
e2fsprogs
net-tools
raspberrypi2-firmware
raspberrypi2-kernel4
nano
%end

%post
## Add rpi repository
cat > /etc/yum.repos.d/rpi.repo <<EOF
[rpi-eurolinux-9]
name=Raspberry PI for EuroLinux 9
baseurl=https://fbi.cdn.euro-linux.com/dist/eurolinux/server/9/aarch64/RPI/all/
enabled=1
gpgcheck=1
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-eurolinux9
EOF
## rootfs-expand that allows to easily fix partition size
cat > /usr/sbin/rootfs-expand << EOF
#!/bin/bash

clear
part=\$(mount |grep '^/dev.* / ' |awk '{print \$1}')
if [ -z "\$part" ];then
    echo "Error detecting rootfs"
    exit -1
fi
dev=\$(echo \$part|sed 's/[0-9]*\$//g')
devlen=\${#dev}
num=\${part:\$devlen}
if [[ "\$dev" =~ ^/dev/mmcblk[0-9]*p\$ ]];then
    dev=\${dev:0:-1}
fi
if [ ! -x /usr/bin/growpart ];then
    echo "Please install cloud-utils-growpart (sudo yum install cloud-utils-growpart)"
    exit -2
fi
if [ ! -x /usr/sbin/resize2fs ];then
    echo "Please install e2fsprogs (sudo yum install e2fsprogs)"
    exit -3
fi
echo \$part \$dev \$num

echo "Extending partition \$num to max size ...."
growpart \$dev \$num
echo "Resizing ext4 filesystem ..."
resize2fs \$part
echo "Done."
df -h |grep \$part
EOF

chmod 755 /usr/sbin/rootfs-expand

# MOTD
cat << EOF > /etc/motd
Welcome to EuroLinux for Raspberry Pi!

Any suggestions are welcome at https://github.com/EuroLinux/raspberry-pi-build

Happy using.
To delete this message use:
echo '' > /etc/motd
EOF


# README
cat >/root/README << EOF
== EuroLinux 9 ==
If you want to resize your / partition, just type the following (as superuser):

rootfs-expand

Any suggestions are welcome at https://github.com/EuroLinux/raspberry-pi-build
EOF


cat > /boot/config.txt << EOF
# This file is provided as a placeholder for user options
# defaults for better graphic support
disable_overscan=1
dtoverlay=vc4-kms-v3d
camera_auto_detect=0
gpu_mem=64
#max_framebuffers=2


# Uncomment to enable SPI
#dtparam=spi=on
# Uncomment to enable I2C
#dtparam=i2c_arm=on
# Overclocking - CHECK DOCS!!!!
#over_voltage=8
#arm_freq=2300
EOF

# Specific cmdline.txt files needed for raspberrypi2/3
cat > /boot/cmdline.txt << EOF
console=ttyAMA0,115200 console=tty1 root=/dev/mmcblk0p3 rootfstype=ext4 elevator=deadline rootwait
EOF

# Remove ifcfg-link on pre generated images
rm -f /etc/sysconfig/network-scripts/ifcfg-link

# rebuild dnf cache 
dnf clean all
/bin/date +%Y%m%d_%H%M > /etc/BUILDTIME
echo '%_install_langs C.utf8' > /etc/rpm/macros.image-language-conf
echo 'LANG="C.utf8"' >  /etc/locale.conf
rpm --rebuilddb

# activate gui
systemct set-default graphical.target

# Remove machine-id on pre generated images
rm -f /etc/machine-id
touch /etc/machine-id
# print disk usage
df
#
%end

%post --nochroot --erroronfail

/usr/sbin/blkid
LOOPPART=$(cat /proc/self/mounts |/usr/bin/grep '^\/dev\/mapper\/loop[0-9]p[0-9] '"$INSTALL_ROOT " | /usr/bin/sed 's/ .*//g')
echo "Found loop part for PARTUUID $LOOPPART"
BOOTDEV=$(/usr/sbin/blkid $LOOPPART|grep 'PARTUUID="........-03"'|sed 's/.*PARTUUID/PARTUUID/g;s/ .*//g;s/"//g')
echo "no chroot selected bootdev=$BOOTDEV"
if [ -n "$BOOTDEV" ];then
    cat $INSTALL_ROOT/boot/cmdline.txt
    echo sed -i "s|root=/dev/mmcblk0p3|root=${BOOTDEV}|g" $INSTALL_ROOT/boot/cmdline.txt
    sed -i "s|root=/dev/mmcblk0p3|root=${BOOTDEV}|g" $INSTALL_ROOT/boot/cmdline.txt
fi
cat $INSTALL_ROOT/boot/cmdline.txt

# Fix swap partition
UUID_SWAP=$(/bin/grep 'swap'  $INSTALL_ROOT/etc/fstab  | awk '{print $1}' | awk -F '=' '{print $2}')
/usr/sbin/mkswap -L "_swap" -p 4096  -U "${UUID_SWAP}"  /dev/disk/by-uuid/${UUID_SWAP}

%end
