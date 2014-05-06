#!/bin/bash
export LFS=$PWD
echo $PWD
mkdir -v $LFS/sources
chmod -v a+wt $LFS/sources
rm  -rf $LFS/sources/*
rm -rf $LFS/tools
rm -rf $LFS/binutils-build/*
wget -i http://www.linuxfromscratch.org/lfs/view/stable/wget-list -P  $LFS/sources
wget -i http://www.linuxfromscratch.org/lfs/view/stable/md5sums  -P  $LFS/sources
pushd $LFS/sources
#md5sum -c md5sums
popd
mkdir -pv $LFS/tools
ln -sv $LFS/tools /


set +h
umask 022

LC_ALL=POSIX
LFS_TGT=$(uname -m)-lfs-linux-gnu
PATH=$LFS/tools/bin:$LFS/bin:$LFS/usr/bin:$PATH
export LFS LC_ALL LFS_TGT PATH
cd $LFS/sources

tar jxvf binutils-2.24.tar.bz2
rm -rf ../binutils-build
mkdir -vp ../binutils-build

cd ../binutils-build

../sources/binutils-2.24/configure --prefix=$LFS/tools --with-sysroot=$LFS --with-lib-path=$LFS/tools/lib --target=$LFS_TGT --disable-nls --disable-werror
make -j2
make install


cd $LFS/sources
tar -jvxf gcc-4.8.2.tar.bz2
cd  gcc-4.8.2
tar -Jxf ../mpfr-3.1.2.tar.xz
mv -v mpfr-3.1.2 mpfr
tar -Jxf ../gmp-5.1.3.tar.xz
mv -v gmp-5.1.3 gmp
tar -zxf ../mpc-1.0.2.tar.gz
mv -v mpc-1.0.2 mpc

for file in \
 $(find gcc/config -name linux64.h -o -name linux.h -o -name sysv4.h)
do
  cp -uv $file{,.orig}
  sed -e 's@/lib\(64\)\?\(32\)\?/ld@/tools&@g' \
      -e 's@/usr@/tools@g' $file.orig > $file
  echo '
#undef STANDARD_STARTFILE_PREFIX_1
#undef STANDARD_STARTFILE_PREFIX_2
#define STANDARD_STARTFILE_PREFIX_1 "'$LFS'/tools/lib/"
#define STANDARD_STARTFILE_PREFIX_2 ""' >> $file
  touch $file.orig
done

sed -i '/k prot/agcc_cv_libc_provides_ssp=yes' gcc/configure
mkdir -v ../gcc-build
cd ../gcc-build


../gcc-4.8.2/configure                               \
    --target=$LFS_TGT                                \
    --prefix=$LFS/tools                                  \
    --with-sysroot=$LFS                              \
    --with-newlib                                    \
    --without-headers                                \
    --with-local-prefix=$LFS/tools                       \
    --with-native-system-header-dir=$LFS/tools/include   \
    --disable-nls                                    \
    --disable-shared                                 \
    --disable-multilib                               \
    --disable-decimal-float                          \
    --disable-threads                                \
    --disable-libatomic                              \
    --disable-libgomp                                \
    --disable-libitm                                 \
    --disable-libmudflap                             \
    --disable-libquadmath                            \
    --disable-libsanitizer                           \
    --disable-libssp                                 \
    --disable-libstdc++-v3                           \
    --enable-languages=c,c++                         \
    --with-mpfr-include=$(pwd)/../gcc-4.8.2/mpfr/src \
    --with-mpfr-lib=$(pwd)/mpfr/src/.libs

make
make install
ln -sv libgcc.a `$LFS_TGT-gcc -print-libgcc-file-name | sed 's/libgcc/&_eh/'`

cd $LFS/sources
tar xvf linux-3.13.3.tar.xz
cd linux-3.13.3
make mrproper
make headers_check
make INSTALL_HDR_PATH=dest headers_install
cp -rv dest/include/* $LFS/tools/include

cd $LFS/sources
tar Jxvf glibc-2.19.tar.xz
cd glibc-2.19
mkdir -v ../glibc-build

cd ../glibc-build
../glibc-2.19/configure                             \
--with-lib-path=$LFS/tools/lib \
      --prefix=$LFS/tools                               \
      --host=$LFS_TGT                               \
      --build=$(../glibc-2.19/scripts/config.guess) \
      --disable-profile                             \
      --enable-kernel=2.6.32                        \
      --with-headers=$LFS/tools/include                 \
      libc_cv_forced_unwind=yes                     \
      libc_cv_ctors_header=yes                      \
      libc_cv_c_cleanup=yes
make 
#make install

#test
echo 'main(){}' > dummy.c
$LFS_TGT-gcc dummy.c
readelf -l a.out | grep ': /tools'