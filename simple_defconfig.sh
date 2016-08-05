#!/bin/bash -x
source /usr/local/bin/common.sh


fragment=$1

is_Kernel_dir

cd $kernel_path
ccachemake distclean

log=`$kernel_path/ti_config_fragments/defconfig_merge.sh  -c $toolchain_dir/arm-linux-gnueabihf- -o . -f $kernel_path/ti_config_fragments/$fragment -w ${PWD} | egrep -o -m 1 appended.*_defconfig`

echo "Config $log"
ccachemake $log


cd -
