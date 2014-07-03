
GREEN="\\033[1;32m" 
YELLOW="\\033[1;33m"
RED="\\033[1;31m" 
NORMAL="\\033[0;39m"
rm -rf u-boot-sunxi
rm -rf linux-sunxi

echo -e "$RED ensure that you did:\n sudo apt-get update"
echo -e "$RED sudo apt-get install gcc-4.6-arm-linux-gnueabihf ncurses-dev uboot-mkimage build-essential"
echo -e "$YELLOW"
echo "first sudo to initialize password"
sudo ls

#git rev-parse --verify HEAD 3d2fc4e8ff764209a8249c3b52dc937f3a106a7f
git clone -b sunxi https://github.com/linux-sunxi/u-boot-sunxi.git

cd u-boot-sunxi/
make A20-OLinuXino_MICRO_config
make  CROSS_COMPILE=arm-linux-gnueabihf-

cd ..
git clone https://github.com/linux-sunxi/linux-sunxi -b stage/sunxi-3.4
cd linux-sunxi/

cp ../olinuxinoa20_defconfig arch/arm/configs/.config
cp ../olinuxinoa20_defconfig arch/arm/configs/
make ARCH=arm olinuxinoa20_defconfig

#patch -p0 < ../sunxi-pwm.patch
patch -p0 < ../sunxi-i2c.patch
make ARCH=arm CROSS_COMPILE=arm-linux-gnueabihf- -j4 uImage
make ARCH=arm CROSS_COMPILE=arm-linux-gnueabihf- -j4 INSTALL_MOD_PATH=out modules

echo -e "$REDassuming that our SD card is in /dev/mmcblk"
echo -e "and 2 partitons are available" 
echo -e "To ensure do: sudo fdisk /dev/mmcblk and type p"
echo -e "You should sse something like that:\n $NORMAL"
echo -e "Disk /dev/mmcblk0: 15.7 GB, 15719727104 bytes"
echo -e "4 têtes, 16 secteurs/piste, 479728 cylindres, total 30702592 secteurs"
echo -e "Unités = secteurs de 1 * 512 = 512 octets"
echo -e "Taille de secteur (logique / physique) : 512 octets / 512 octets"
echo -e "taille d'E/S (minimale / optimale) : 512 octets / 512 octets"
echo -e "Identifiant de disque : 0x00000000 $RED"
echo -e "Périphérique Amorçage  Début         Fin      Blocs    Id. Système"
echo -e "/dev/mmcblk0p1            2048       34815       16384   83  Linux"
echo -e "/dev/mmcblk0p2           34816    30702591    15333888   83  Linux$NORMAL\n"

read -p "Press [Enter] key to continue..."

#sudo mkfs.vfat /dev/mmcblk0p1
#sudo mkfs.ext3 /dev/mmcblk0p2

cd ../u-boot-sunxi/
export card=/dev/mmcblk0
sudo dd if=/dev/zero of=${card} bs=1M count=1
sudo dd if=u-boot-sunxi-with-spl.bin of=${card} bs=1024 seek=8
cd ../linux-sunxi/
sudo mkdir -p /mnt/sdmedia
sudo mount /dev/mmcblk0p1 /mnt/sdmedia
sudo cp arch/arm/boot/uImage  /mnt/sdmedia
sudo cp script.bin /mnt/sdmedia
sudo sync 
sudo umount /mnt/sdmedia
sudo rmdir /mnt/sdmedia

echo -e "$GREEN end of script, evrything ok"
echo -e "$NORMAL"
