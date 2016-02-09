current_dir=`echo $PWD`
echo $current_dir
cd $1

echo "Filesystem Directory: $1"
if [ -f $1/init -o -L $1/init ]
then
	echo "Found init"
else
	echo "Couldn't find init"
	sudo ln -s sbin/init init
fi

#find . | sudo cpio -H newc -o | gzip > $current_dir/$2.gz
find . | sudo cpio -H newc -o > $current_dir/$2.cpio
