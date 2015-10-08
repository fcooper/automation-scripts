function ccachemake () {

    echo "ccachemake -sj 4 $@"
    ARCH=arm CROSS_COMPILE='ccache /home/franklin/toolchain/gcc-linaro-arm-linux-gnueabihf-4.7-2013.03-20130313_linux/bin/arm-linux-gnueabihf-' make -sj 4 $@ > /dev/null

    if [ "$?" != 0 ]; then
        echo "Command make -sj 4 $@ failed"
        exit
    fi
}

