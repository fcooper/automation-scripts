source /usr/local/bin/config

valid_machines=(bbw bbb 335-gp 335-sk 437-gp 437-sk 37x-gp k2e k2g x15 dra7-gp dra72-gp k2hk x15 572-gp)

kernel_path=`git rev-parse --show-toplevel`

kernel_files=(MAINTAINERS REPORTING-BUGS Kconfig scripts/checkpatch.pl)
function  is_Kernel_dir () {
	a=1
	for element in "${kernel_files[@]}"
	do
		if [ -f "$kernel_path/$element" ]
		then
			a=2
		else
			echo "Directory $kernel_path is not a valid kernel directory"
			exit 1
		fi
	done 
	
	echo "You are currently based in kernel directory: $kernel_path"
}

function ccachemake () {
    echo "ccachemake -sj $num_jobs $@"
    ARCH=arm CROSS_COMPILE="ccache $toolchain_dir/$toolchain_prefix" make -sj $num_jobs $@ > /dev/null

    if [ "$?" != 0 ]; then
        echo "Command make -sj $num_jobs $@ failed"
        exit
    fi
}

function board_list () {
         for element in "${valid_machines[@]}"
         do
		echo "$element"
	done
}
