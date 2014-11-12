
GREEN="\\033[1;32m" 
YELLOW="\\033[1;33m"
RED="\\033[1;31m" 
NORMAL="\\033[0;39m"

sudo apt-get install qemu-user-static debootstrap binfmt-support
targetdir=rootfs
distro=wheezy
mkdir -p $targetdir
#sudo debootstrap --arch=armhf --foreign $distro $targetdir
sudo cp /usr/bin/qemu-arm-static $targetdir/usr/bin/
sudo cp /etc/resolv.conf $targetdir/etc
sudo cp second_stage.sh $targetdir


git clone https://github.com/linux-sunxi/libump.git
#cp control libump/debian/libump/DEBIAN
cd libump
#export $(dpkg-architecture -aarmhf) && export CROSS_COMPILE=arm-linux-gnueabi-&&export DEB_BUILD_ARCH=$DEB_HOST_ARCH&&export DEB_BUILD_ARCH_CPU=DEB_HOST_ARCH_CPU&&export DEB_BUILD_ARCH_BITS=32&&exportDEB_BUILD_GNU_CPU=arm &&DEB_HOST_GNU_SYSTEM=linux-gnueabihf&&DEB_BUILD_GNU_SYSTEM=linux-gnueabihf  &&  debian/rules clean && debian/rules && dpkg-buildpackage -b -d -aarmhf -tarm-linux-gnueabihf 
#export $(dpkg-architecture -aarmhf) && export CROSS_COMPILE=arm-linux-gnueabi-&&export DEB_BUILD_ARCH=$DEB_HOST_ARCH&&export DEB_BUILD_ARCH_CPU=DEB_HOST_ARCH_CPU&&export DEB_BUILD_ARCH_BITS=32&&exportDEB_BUILD_GNU_CPU=arm &&DEB_HOST_GNU_SYSTEM=linux-gnueabihf&&DEB_BUILD_GNU_SYSTEM=linux-gnueabihf  &&  CC=arm-linux-gnueabi- autoreconf -i&&  ./configure --prefix=$PWD../rootfs --host=arm-linux-gnueabihf&& make&& sudo make install 

export $(dpkg-architecture -aarmhf) &&export ABI=armhf &&export VERSION="r3p0"&&EGL_TYPE="x11"&& export CROSS_COMPILE=arm-linux-gnueabi-&&export DEB_BUILD_ARCH=$DEB_HOST_ARCH&&export DEB_BUILD_ARCH_CPU=DEB_HOST_ARCH_CPU&&export DEB_BUILD_ARCH_BITS=32&&exportDEB_BUILD_GNU_CPU=arm &&DEB_HOST_GNU_SYSTEM=linux-gnueabihf&&DEB_BUILD_GNU_SYSTEM=linux-gnueabihf  &&  CC=arm-linux-gnueabi- autoreconf -i&&  ./configure --prefix=$PWD/../rootfs --host=arm-linux&& make&& sudo make install 










#dpkg-buildpackage -b -d -aarmhf -tarm-linux-gnueabihf 
cd ..
#cp  libump/ $targetdir
#sudo cp libump_3.0-0sunxi1_armhf.deb $targetdir

git clone https://github.com/linux-sunxi/sunxi-mali.git
cd sunxi-mali
git submodule init
git submodule update
#make config

export $(dpkg-architecture -aarmhf) && export CROSS_COMPILE=arm-linux-gnueabi-&&export DEB_BUILD_ARCH=$DEB_HOST_ARCH&&export DEB_BUILD_ARCH_CPU=DEB_HOST_ARCH_CPU&&export DEB_BUILD_ARCH_BITS=32&&exportDEB_BUILD_GNU_CPU=arm &&DEB_HOST_GNU_SYSTEM=linux-gnueabihf&&DEB_BUILD_GNU_SYSTEM=linux-gnueabihf  &&make config VERSION=r3p0 ABI=armhf EGL_TYPE=x11&&make
cd ..

sudo chroot $targetdir /second_stage.sh


sudo rm $targetdir/etc/resolv.conf
sudo rm $targetdir/usr/bin/qemu-arm-static

 
