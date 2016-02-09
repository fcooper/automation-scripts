#!/bin/bash -x

nfs_dir='/home/franklin/nfs/'
board='k2g'

nfs='/home/franklin/nfs/k2g/'
ramdisk_tmp='/home/franklin/nfs/k2g-ram/'


echo "NOTE: This script runs as superuser and does several wacky things that can really break your machine, proceed at your own risk!"

if [ "$nfs" == "" ]; then
	echo "You just specify a path to create ramdisk from!"
	exit
fi

if [ ! -d $nfs ]; then
	echo "Specified directory does not exist!"
	exit
fi

if [ ! -d /mnt/ramdisk ]; then
	mkdir /mnt/ramdisk
fi

sudo rsync -avv --delete --exclude={boot/ramdisk.gz,boot/zImage,boot/skern-k2g.bin,boot/k2g-evm.dtb} $nfs/ $ramdisk_tmp/ > /dev/null



sudo rm $nfs/boot/ramdisk.gz

cd $nfs_dir



#gets the size of the directory you picked and adds a 5MB extra space

RD_SIZE=$(sudo du $ramdisk_tmp --max-depth=0 | awk '{ print ($ramdisk_tmp + 10240) }')

RD_SIZE_H=$(sudo du $ramdisk_tmp -h --max-depth=0 | awk '{ print ($ramdisk_tmp + 8) }')

dd if=/dev/zero of=/dev/ram bs=1k count=$RD_SIZE
mke2fs -vm0 /dev/ram $RD_SIZE <<-EOF
yes
EOF
sudo mount -t ext2 /dev/ram /mnt/ramdisk
sudo cp -avr $ramdisk_tmp/* /mnt/ramdisk
sudo umount /mnt/ramdisk
dd if=/dev/ram bs=1k count=$RD_SIZE of=ramdisk
rm ramdisk.gz
gzip -v9 ramdisk <<-EOF
yes
EOF

sudo mv ramdisk.gz $nfs/boot/ramdisk.gz

sudo rm $nfs_dir/uEnv.txt
cat <<EOT >> $nfs_dir/uEnv.txt
ramdisk_size=${RD_SIZE}
ramdisk_size_mb=${RD_SIZE_H}MB
EOT

sudo mv $nfs_dir/uEnv.txt $nfs/boot/uEnv.txt

echo ""
echo "Bootargs line for u-boot will be: "
echo ""
echo "setenv bootargs console=ttyO0,115200n8 mem=256M root=/dev/ram rw initrd=0x82000000,"$RD_SIZE_H"MB ramdisk_size=$RD_SIZE earlyprintk=serial"
echo ""

