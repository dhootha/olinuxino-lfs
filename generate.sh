#!/bin/bash
export LFS=$PWD
echo $PWD
mkdir -v $LFS/sources
chmod -v a+wt $LFS/sources
wget -i http://www.linuxfromscratch.org/lfs/view/stable/wget-list -P  $LFS/sources