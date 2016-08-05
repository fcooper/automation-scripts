#!/bin/bash 

source /usr/local/bin/common.sh

is_Kernel_dir

declare -A dtb     # Create an associative array
declare -A fs
declare -A pwr
declare -A pvr

dtb[335-ice]='am335x-icev2.dtb'
fs[335-ice]=335-ice
pwr[335-ice]=335-ice

dtb[bbb]='am335x-boneblack.dtb am335x-bone.dtb'
fs[bbb]=bbb
pwr[bbb]=bbb

#dtb[dra7-gp]=dra7-evm-lcd-osd.dtb
dtb[dra7-gp]=dra7-evm.dtb
fs[dra7-gp]=dra7x
pwr[dra7-gp]=dra7-gp
pvr[dra7-gp]=dra7

dtb[437-sk]=am437x-sk-evm.dtb
fs[437-sk]=am437x
pwr[437-sk]=437x-sk
pvr[437-sk]=am437x

dtb[437-gp]=am437x-gp-evm.dtb
fs[437-gp]=am437x
pwr[437-gp]=437x-gp
pvr[437-gp]=am437x

dtb[335-gp]=am335x-evm.dtb
fs[335-gp]=am335x
pwr[335-gp]=335-gp


dtb[37x-gp]=omap3-evm-37xx.dtb
fs[37x-gp]=am37x

dtb[k2e]='keystone-k2e-evm.dtb'
fs[k2e]=k2e
pwr[k2e]=k2e

dtb[k2g]='keystone-k2g-evm.dtb'
fs[k2g]=k2g
pwr[k2g]=k2g


dtb[k2hk]=k2hk-evm.dtb
fs[k2hk]=k2hk
pwr[k2hk]=k2e

dtb[x15]=am57xx-beagle-x15.dtb
fs[x15]=x15
pwr[x15]=x15

dtb[572-gp]=am57xx-evm.dtb
fs[572-gp]=am57x

dtb[572-idk]=am572x-idk.dtb
fs[572-idk]=am57x-idk
pwr[572-idk]=am57-idk

supported_machines=()
function supported_machines() {
	for element in "${valid_machines[@]}"
	do
		match_fs=false
		match_dtb=false
		for i in "${!fs[@]}"
		do   
            if [ "$element" = "$i" ]; then
                match_fs=true
            fi
        done

        for i in "${!dtb[@]}"
        do   
            if [ "$element" = "$i" ]; then
                match_dtb=true
            fi
        done

        if [ "$match_fs" = "true" -a "$match_dtb" = "true" ]; then
            supported_machines+=($element)
        fi
    done
}


selected_dtb=""

file=""
machine=""
build=""
action=""
power=""
remote=""

while getopts ":b:m:a:f:p:r" opt; do
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
    	a)
			action=$OPTARG
			;;
	p)
			power=$OPTARG
			;;
	r)
			remote="yes"
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


if [ "$build" = "" -o "$action" = "" ]; then

	if [ "$build" != "" -o "$action" != "" ]; then
		echo "Error build or action parameter blank"
		echo "Build: $build"
		echo "Action: $action"
		exit 1
	fi
	
	if [ "$power" = "" ]; then
		echo "You didn't pass in anything to be done for $machine"
		exit 1
	fi
fi

load_addr=
append_dtb=false
machine_match=false

for element in "${valid_machines[@]}"
do
    if [ "$element" = "$machine" ]; then
        machine_match=true
    fi
done

if [ "$machine_match" = "false" -o "$machine" = "" ]; then
	if [ "$machine" = "" ]; then
		echo "Must pass a machine parameter"
	else
		echo "Invalid board: $machine"
	fi

    echo "List of valid boards:"
    for element in "${valid_machines[@]}"
    do
        echo "  $element"
    done

    exit 1

fi

if [ "$machine" == "37x-gp" ]; then
	append_dtb=true
	load_addr=0x80008000
fi

if [ "$file" != "" ]; then

    if [ -f "$file" ]; then
		echo "Reading from a file"
        source $file

		selected_dtb="$dtb"
		echo "$selected_dtb"
		echo ""
    fi  
fi

if [ "$build" != "" ]; then

    # Trim spaces from string
    build=`echo $build | sed -e 's/^[ \t]*//'`

    # Convert string to array of characters
    build=($(echo "$build"|sed  's/\(.\)/\1 /g'))


    for element in "${build[@]}"
    do
        if [ "$element" != "k" -a "$element" != "m" -a "$element" != "d" -a "$element" != "p" ]; then

            echo "Invalid build command: $build"

            echo "Supported commands:"
            echo "k - for kernel"
            echo "m - for module"
            echo "d - for dtb"
            echo "p - for pvr"

            exit 1
        fi
    done
fi

if [ "$action" != "" ]; then
	case $action in
		b)
			action=$action
			;;
		i)
			action=$action
			;;
		bi)
			action="bi"
			;;
		ib)
			action="bi"
			;;
		*)
			echo "Invalid action $action"
			echo ""
			echo "Valid arguments are:"
			echo "	 b - for build"
			echo "	 i - for install"
			echo "	bi - for build and install"
			exit 1
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
			echo ""
			echo "Valid arguments are:"
			echo "	on"
			echo "	off"
			echo "	reboot"
            exit 1
    esac
fi

cd $kernel_path

selected_dtb="${dtb[$machine]}"
selected_fs="${fs[$machine]}"
selected_pwr="${pwr[$machine]}"
selected_pvr="${pvr[$machine]}"

if [ "$remote" = "yes" ]; then
	selected_fs="remote"
fi
if [ ":$selected_dtb:" = "::" -o ":$selected_fs:" = "::" ]; then
    	echo "Script configuration error"
	echo "Error: No valid dtb or filesystem selected for $machine"
    exit 1

fi

if [ "$action" = "b" -o "$action" = "bi" ]; then
    for element in "${build[@]}"
    do
        if [ "$element" = "k" -a "$append_dtb" = false ]; then
	        echo "Building Kernel"
	        ccachemake zImage

            if [ "$?" != "0" ]; then
                echo "Error building kernel"
                exit 1
            fi

	        echo ""
        fi
	
	if [ "$element" = "k" -a "$append_dtb" = true ] || [ "$element" = "d" -a "$append_dtb" = true ]
	then
		echo "Building appended uImage"
		ccachemake LOADADDR=$load_addr uImage
		ccachemake $selected_dtb	
		if [ "$?" != "0" ]; then
			echo "Error building appended kernel"
			exit 1
		fi
			echo ""
	fi
		

        if [ "$element" = "m" ]; then
	        echo "Building Modules"
	        ccachemake modules

            if [ "$?" != "0" ]; then
                echo "Error building modules"
                exit 1
            fi

	        echo ""
        fi

        if [ "$element" = "d" ]; then
	        echo "Building DTB: $selected_dtb"
	        ccachemake "$selected_dtb"

            if [ "$?" != "0" ]; then
                echo "Error building dtb"
                exit 1
            fi

	        echo ""
        fi

        if [ "$element" = "p" ]; then

            if [ ":$selected_pvr" = "" ]; then
				echo "Error: Nothing passed to build pvr"
                exit 1
            fi
	        echo "Building pvr"
	        echo ""
	        build-pvr.sh $selected_pvr $nfs_path/$selected_fs/ build

            if [ "$?" != "0" ]; then
                echo "Error building SGX modules"
                exit 1
            fi

        fi
    done
fi


if [ "$action" = "i" -o "$action" = "bi" ]; then
    for element in "${build[@]}"
    do
        if [ "$element" = "k" ]; then
	        echo "Installing Kernel"
	        echo ""
	        sudo cp arch/arm/boot/zImage $nfs_path/$selected_fs/boot

	        if [ "$?" != "0" ]; then
		        echo "Failed to Install Kernel"
		        exit
	        fi
        fi

        if [ "$element" = "m" ]; then

		echo "Deleting Old Modules"
		sudo rm -r $nfs_path/$selected_fs/lib/modules/*
	        echo "Installing Modules"
	        sudo ARCH=arm INSTALL_MOD_PATH=$nfs_path/$selected_fs make modules_install > /dev/null

	        if [ "$?" != "0" ]; then
		        echo "Failed to Install Modules"
	        fi

	        #echo "Deleting CPU Freq"
	        #echo ""
	        # Don't want to risk deleting stuff on my fs
	        #sudo rm $nfs_path/$selected_fs/lib/modules/*/kernel/drivers/cpufreq/*
        fi

	if [ "$element" = "k" -a "$append_dtb" = true ] || [ "$element" = "d" -a "$append_dtb" = true ]
	then
		echo "Installing Appended uImage"

		cat arch/arm/boot/zImage arch/arm/boot/dts/$selected_dtb > arch/arm/boot/zImage.dtb
		cp arch/arm/boot/zImage.dtb arch/arm/boot/zImage
		$(cut -f 3- -d ' ' < arch/arm/boot/.uImage.cmd)
		sudo cp arch/arm/boot/uImage $nfs_path/$selected_fs/boot/uImage-dtb.$selected_dtb
	fi

        if [ "$element" = "d" ]; then
	        echo "Installing DTB: $selected_dtb"
	        echo ""
	        sudo cp arch/arm/boot/dts/$selected_dtb $nfs_path/$selected_fs/boot

	        if [ "$?" != "0" ]; then
		        echo "Failed to Install DTB"
	        fi
        fi

        if [ "$element" = "p" ]; then
            if [ ":$selected_pvr" = "" ]; then
				echo "Error: Nothing passed to build pvr"
                exit 1
            fi
	        echo "Installing PVR"
	        build-pvr.sh $selected_pvr $nfs_path/$selected_fs/ install

            if [ "$?" != "0" ]; then
                echo "Failed to Install SGX Modules"
                exit 1
            fi

        fi
    done

	if [ "$remote" = "yes" ]; then
		echo "Tar up remote fs"
		cd $nfs_path/$selected_fs/
		sudo tar -czf ../remote-fs.tar.gz *
		cd -
	fi
fi

if [ "$power" != "" ]; then

	if [ "$power" = "reboot"  ]; then
		echo "Power Reboot"
		echo ""
		power-board.sh $machine reboot
	elif [ "$power" = "on"  ]; then
		echo "Power On"
		echo ""
		power-board.sh $machine on
	elif [ "$power" = "off"  ]; then
		echo "Power Off"
		echo ""
		power-board.sh $machine off
	fi
fi
