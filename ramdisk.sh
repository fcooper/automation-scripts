#!/bin/bash
echo "NOTE: This script runs as superuser and does several wacky things that can really break your machine, proceed at your own risk!"

if [ "$1" == "" ]; then
	echo "You just specify a path to create ramdisk from!"
	exit
fi 	

if [ ! -d $1 ]; then
	echo "Specified directory does not exist!"
	exit
fi

if [ ! -d /mnt/ramdisk ]; then
	mkdir /mnt/ramdisk
fi

sudo rm /home/franklin/nfs/k2g/ramdisk.gz
#gets the size of the directory you picked and adds a 5MB extra space

RD_SIZE=$(du $1 --max-depth=0 | awk '{ print ($1 + 10240) }')

RD_SIZE_H=$(du $1 -h --max-depth=0 | awk '{ print ($1 + 8) }')

dd if=/dev/zero of=/dev/ram bs=1k count=$RD_SIZE
mke2fs -vm0 /dev/ram $RD_SIZE <<-EOF
yes
EOF
mount -t ext2 /dev/ram /mnt/ramdisk
cp -avr $1/* /mnt/ramdisk
umount /mnt/ramdisk
dd if=/dev/ram bs=1k count=$RD_SIZE of=ramdisk
rm ramdisk.gz
gzip -v9 ramdisk <<-EOF
yes
EOF

sudo cp ramdisk.gz /home/franklin/nfs/k2g/ramdisk.gz

echo ""
echo "Bootargs line for u-boot will be: "
echo ""
echo "setenv bootargs console=ttyO0,115200n8 mem=256M root=/dev/ram rw initrd=0x82000000,"$RD_SIZE_H"MB ramdisk_size=$RD_SIZE earlyprintk=serial"
echo ""
