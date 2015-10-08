#!/bin/bash 

source /usr/local/bin/common.sh

declare -A dtb     # Create an associative array
declare -A filesystem
declare -A power
declare -A pvr

dtb[dra7-gp]=dra7-evm-lcd-osd.dtb
filesystem[dra7-gp]=dra7x
power[dra7-gp]=dra7-gp
pvr[dra7-gp]=dra7

dtb[am437-sk]=am437x-sk-evm.dtb
filesystem[am437-sk]=am437x
power[am437-sk]=437x-sk
pvr[am437-sk]=am437x

choosedtb=""
choosefs=""
choosepower=""
choosepvr=""
buildkernel="n"
builddtb="n"
buildmodules="n"
buildpvr="n"
build=n
install=n
soc=""

power=""
machine=""
board=""
build=""
do=""
file=""

while getopts ":b:m:d:f:p:" opt; do
	case $opt in
		f)
			file=$OPTARG
			;;
    	m)
			machine=$OPTARG
			;;
    	b)
			build=$OPTARG
			;;
    	d)
			do=$OPTARG
			;;
		p)
			power=$OPTARG
			;;
    	\?)
			echo "Invalid option: -$OPTARG" >&2
			exit 1
			;;
    	:)
			echo "Option -$OPTARG requires an argument." >&2
			exit 1
			;;
	esac
done

case $machine in
	dra7)
		board="dra7"
		choosedtb="${dtb[dra7-gp]}"
		choosefs="${filesystem[dra7-gp]}"
		choosepower="${power[dra7-gp]}"
		choosepvr="${pvr[dra7-gp]}"
		soc="dra7x"
		;;
    437-sk)
        board="am437-sk"
        choosedtb="${dtb[am437-sk]}"
        choosefs="${filesystem[am437-sk]}"
        choosepower="${power[am437-sk]}"
		choosepvr="${pvr[am437-sk]}"
		soc="437x"
        ;;

	*)
		echo "Invalid board: $machine"
		exit
esac

if [ "$file" != "" ]; then

    if [ -f "$file" ]; then
		echo "Reading from a file"
        source $file

		choosedtb="$dtb"
		echo "$choosedtb"
		echo ""
    fi  
fi

if [ "$build" != "" ]; then
build=`echo $build | sed -e 's/^[ \t]*//'`


IFS=', ' read -a array <<< "$build"

for element in "${array[@]}"
do
	case $element in
		kernel)
			buildkernel="y"
			;;
		modules)
			buildmodules="y"
			;;
		dtb)
			builddtb="y"
			;;
		pvr)
			buildpvr="y"
			;;
		*)
			echo "Invalid build argument: $element"
			exit
	esac
done

case $do in
	build)
		build=y
		;;
	install)
		install=y
		;;
	buildinstall)
		build=y
		install=y
		;;
	*)
		echo "Invalid do argument"
		exit
esac

fi

if [ "$power" != "" ]; then
case $power in
    off)
        power="off"
        ;;
    on)
        power="on"
        ;;
	reboot)
		power="reboot"
		;;
    *)
        echo "Invalid power argument: $power"
        exit
esac
fi

cd /home/franklin/repositories/git/linux

if [ "$buildkernel" = "y" -a "$build" = "y" ]; then
	echo "Building Kernel"
	ccachemake zImage
	echo ""
fi

if [ "$buildmodules" = "y" -a "$build" = "y"  ]; then
	echo "Building Modules"
	ccachemake modules
	echo ""
fi

if [ "$builddtb" = "y" -a "$build" = "y"  ]; then
	echo "Building DTB: $choosedtb"
	ccachemake "$choosedtb"
	echo ""
fi

if [ "$buildpvr" = "y" -a "$build" = "y"  ]; then
	echo "Building pvr"
	echo ""
	build-pvr.sh $choosepvr /home/franklin/nfs/$choosefs/ build
fi

if [ "$buildkernel" = "y"  -a "$install" = "y" ]; then
	echo "Installing Kernel"
	echo ""
	sudo cp arch/arm/boot/zImage /home/franklin/nfs/$choosefs/boot

	if [ "$?" != "0" ]; then
		echo "Failed to Install Kernel"
		exit
	fi
fi

if [ "$buildmodules" = "y"  -a "$install" = "y"  ]; then
	echo "Installing Modules"
	sudo ARCH=arm INSTALL_MOD_PATH=/home/franklin/nfs/$choosefs make modules_install > /dev/null

	if [ "$?" != "0" ]; then
		echo "Failed to Install Modules"
	fi

	echo "Deleting CPU Freq"
	echo ""
	# Don't want to risk deleting stuff on my fs
	sudo rm /home/franklin/nfs/$choosefs/lib/modules/*/kernel/drivers/cpufreq/*
fi

if [ "$builddtb" = "y"  -a "$install" = "y"  ]; then
	echo "Installing DTB: $choosedtb"
	echo ""
	sudo cp arch/arm/boot/dts/$choosedtb /home/franklin/nfs/$choosefs/boot

	if [ "$?" != "0" ]; then
		echo "Failed to Install DTB"
	fi
fi

if [ "$buildpvr" = "y"  -a "$install" = "y"  ]; then
	echo "Installing PVR"
	build-pvr.sh $choosepvr /home/franklin/nfs/$choosefs/ install
fi


if [ "$power" = "reboot"  ]; then
    echo "Power Reboot"
    echo ""
	board.sh $choosepower reboot
fi

if [ "$power" = "on"  ]; then
    echo "Power On"
    echo ""
    board.sh $choosepower on
fi

if [ "$power" = "off"  ]; then
    echo "Power Off"
    echo ""
    board.sh $choosepower off
fi

