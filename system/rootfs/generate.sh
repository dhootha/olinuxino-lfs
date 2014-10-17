
GREEN="\\033[1;32m" 
YELLOW="\\033[1;33m"
RED="\\033[1;31m" 
NORMAL="\\033[0;39m"

sudo apt-get install qemu-user-static debootstrap binfmt-support
targetdir=rootfs
distro=wheezy
mkdir -p $targetdir
sudo debootstrap --arch=armhf --foreign $distro $targetdir
sudo cp /usr/bin/qemu-arm-static $targetdir/usr/bin/
sudo cp /etc/resolv.conf $targetdir/etc
sudo cp second_stage.sh $targetdir
sudo chroot $targetdir /second_stage.sh


sudo rm $targetdir/etc/resolv.conf
sudo rm $targetdir/usr/bin/qemu-arm-static

 
