current_dir=`echo $PWD`
cd $1
sudo ln -s sbin/init init
find . | sudo cpio -H newc -o | gzip > $current_dir/$2.gz
