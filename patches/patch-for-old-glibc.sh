#!/usr/bin/env bash

WORK_DIR=$(pwd)
cd "$HOME" || exit
echo "Downloading patchelf binary from ArchLinux repos"
mkdir -p patchelf-temp
#curl -L https://github.com/Jebaitedneko/docker/raw/ubuntu/patchelf | bsdtar -C patchelf-temp -xf -
curl -L https://archlinux.org/packages/community/x86_64/patchelf/download | bsdtar -C patchelf-temp -xf -
mv "$HOME"/patchelf-temp/usr/bin/patchelf "$HOME"/
rm -rf "$HOME"/patchelf-temp
echo "Downloading latest glibc from ArchLinux repos"
mkdir -p glibc
curl -L https://archlinux.org/packages/core/x86_64/glibc/download | bsdtar -C glibc -xf -
curl -L https://archlinux.org/packages/core/x86_64/lib32-glibc/download | bsdtar -C glibc -xf -
ln -svf "$HOME"/glibc/usr/lib "$HOME"/glibc/usr/lib64

echo "Patching glibc"
for bin in $(find "$HOME"/glibc -type f -exec file {} \; | grep 'ELF .* interpreter' | awk '{print $1}'); do
    bin="${bin::-1}"
    echo "Patching: $bin"
    "$HOME"/patchelf --set-rpath "$HOME"/glibc/usr/lib --force-rpath --set-interpreter "$HOME"/glibc/usr/lib/ld-linux-x86-64.so.2 "$bin"
done

echo "Patching Toolchain"
for bin in $(find "$WORK_DIR" -type f -exec file {} \; | grep 'ELF .* interpreter' | awk '{print $1}'); do
    bin="${bin::-1}"
    echo "Patching: $bin"
    "$HOME"/patchelf --add-rpath "$HOME"/glibc/usr/lib --force-rpath --set-interpreter "$HOME"/glibc/usr/lib/ld-linux-x86-64.so.2 "$bin"
done

echo "Cleaning"
rm -rf "$HOME"/patchelf
