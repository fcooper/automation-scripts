#! /bin/bash
# full_appended_keystone_defconfig no_baseport_appended_keystone_defconfig no_connectivity_appended_keystone_defconfig no_ipc_appended_keystone_defconfig keystone_defconfig

commits=(ti2015.01 ti2015.02 ti-lsk-linux-4.1.y)
defconfigs=(fullfragment no_baseport_appended_keystone_defconfig no_connectivity_appended_keystone_defconfig no_ipc_appended_keystone_defconfig keystone_defconfig)
file='/home/franklin/k2hk-log/capture.txt'
problem="Using K2HK_EMAC device"
kernel_path="/home/franklin/repositories/git/linux-k2hk"
seconds=0
minutes=0
hours=1
mytime=$(expr $seconds + $minutes \* 60 + $hours \* 60 \* 60)

read -s -p "Password: " PASS

cd $kernel_path

for commit in "${commits[@]}"
do
	for element in "${defconfigs[@]}"
	do

		date
		ARCH=arm CROSS_COMPILE='ccache /home/franklin/toolchain/gcc-linaro-arm-linux-gnueabihf-4.7-2013.03-20130313_linux/bin/arm-linux-gnueabihf-' make -sj 9 distclean
		if [ "$element" = "fullfragment" ]
		then
			rm arch/arm/configs/appended_keystone_defconfig
			
			echo "Creating full fragment based defconfig"
			simple_defconfig.sh
			element="appended_keystone_defconfig"
		fi

		echo "Now using this defconfig $element with commit $commit"

		ARCH=arm CROSS_COMPILE='ccache /home/franklin/toolchain/gcc-linaro-arm-linux-gnueabihf-4.7-2013.03-20130313_linux/bin/arm-linux-gnueabihf-' make -sj 9 $element 

		echo "Building Kernel modules and device tree"
		build.sh -m k2hk -b kmd -a b

		echo "Installing kernel modules and device tree and rebooting board"
		echo $PASS | build.sh -m k2hk -b kmd -a i  -p reboot

		cat /dev/null > $file

		good="no"
		end=$((SECONDS+$mytime))

		echo "Started now $end"
		data
		while [ $SECONDS -lt $end ]; do
		    # Do what you want.
		    cat $file | grep "end trace"

		    if [ "$?" = "0" ]
		    then
			echo "Got the error"
			good="yes"
			break
		    fi

		    :
		done

		echo "Sleeping for a bit"
		sleep 5
		cat $file > /home/franklin/k2hk-log/$commit-$element-log.txt

		if [ "$good" = "yes" ]
		then
			echo "Saw failure with config $element for commit $commit"
		else
			echo "Saw nothing with config $element for commit $commit"
		fi
	done
done
