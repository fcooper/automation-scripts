#!/bin/bash 

source /usr/local/bin/common.sh

declare -A dtb     # Create an associative array
declare -A fs
declare -A pwr
declare -A pvr

dtb[dra7-gp]=dra7-evm-lcd-osd.dtb
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


dtb[k2e]=k2e-evm.dtb
fs[k2e]=k2e
pwr[k2e]=k2e

dtb[k2g]=k2g-evm.dtb
fs[k2g]=k2g
pwr[k2g]=k2g


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


while getopts ":b:m:a:f:p:" opt; do
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

if [ ":$selected_dtb:" = "::" -o ":$selected_fs:" = "::" ]; then
    	echo "Script configuration error"
	echo "Error: No valid dtb or filesystem selected for $machine"
    exit 1

fi

if [ "$action" = "b" -o "$action" = "bi" ]; then
    for element in "${build[@]}"
    do
        if [ "$element" = "k" ]; then
	        echo "Building Kernel"
	        ccachemake zImage

            if [ "$?" != "0" ]; then
                echo "Error building kernel"
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
	        echo "Installing Modules"
	        sudo ARCH=arm INSTALL_MOD_PATH=$nfs_path/$selected_fs make modules_install > /dev/null

	        if [ "$?" != "0" ]; then
		        echo "Failed to Install Modules"
	        fi

	        echo "Deleting CPU Freq"
	        echo ""
	        # Don't want to risk deleting stuff on my fs
	        sudo rm $nfs_path/$selected_fs/lib/modules/*/kernel/drivers/cpufreq/*
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
