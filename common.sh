num_jobs=8

valid_machines=(bbw bbb 335-gp 335-sk 437-gp 437-sk 37x-gp k2e k2g x15 dra7-gp dra72-gp k2hk x15)

function ccachemake () {

    echo "ccachemake -sj $num_jobs $@"
    ARCH=arm CROSS_COMPILE='ccache /home/franklin/toolchain/gcc-linaro-arm-linux-gnueabihf-4.7-2013.03-20130313_linux/bin/arm-linux-gnueabihf-' make -sj $num_jobs $@ > /dev/null

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

nfs_path="/home/franklin/nfs/"
kernel_path="/home/franklin/repositories/git/linux"
