
GREEN="\\033[1;32m" 
YELLOW="\\033[1;33m"
RED="\\033[1;31m" 
NORMAL="\\033[0;39m"
#rm -rf u-boot-sunxi
echo -e "$RED ensure that you did:\n sudo apt get update"
echo -e "$RED sudo apt-get install gcc-4.6-arm-linux-gnueabihf ncurses-dev uboot-mkimage build-essential"
echo -e "$YELLOW"
#git rev-parse --verify HEAD 3d2fc4e8ff764209a8249c3b52dc937f3a106a7f
#git clone -b sunxi https://github.com/linux-sunxi/u-boot-sunxi.git
cd u-boot-sunxi/
make A20-OLinuXino_MICRO_config
make  CROSS_COMPILE=arm-linux-gnueabihf-
export card=/dev/mmcblk0p1
sudo dd if=/dev/zero of=${card} bs=1M count=1
sudo dd if=u-boot-sunxi-with-spl.bin of=${card} bs=1024 seek=8

cd ..
#git clone https://github.com/linux-sunxi/linux-sunxi -b stage/sunxi-3.4
cd linux-sunxi/

cp ../olinuxinoa20_defconfig arch/arm/configs/.config
cp ../olinuxinoa20_defconfig arch/arm/configs/
make ARCH=arm olinuxinoa20_defconfig

patch -p0 < ../sunxi-pwm.patch
patch -p0 < ../sunxi-i2c.patch
make ARCH=arm CROSS_COMPILE=arm-linux-gnueabihf- -j4 uImage
make ARCH=arm CROSS_COMPILE=arm-linux-gnueabihf- -j4 INSTALL_MOD_PATH=out modules
echo -e "$GREEN end of script, evrything ok"
echo -e "$NORMAL"

