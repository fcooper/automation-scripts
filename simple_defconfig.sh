kernel_dir=/home/franklin/repositories/git/linux/
toolchain_dir=/home/franklin/toolchain/gcc-linaro-arm-linux-gnueabihf-4.9-2015.05_linux/bin/
$kernel_dir/ti_config_fragments/defconfig_merge.sh  -c $toolchain_dir/arm-linux-gnueabihf- -o . -f $kernel_dir/ti_config_fragments/multi_core_defconfig_fragment -w ${PWD} -d keystone_defconfig 
