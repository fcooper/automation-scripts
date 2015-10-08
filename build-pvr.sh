source /usr/local/bin/common.sh

NULL_DRM=1
SUB_DIR=""
board=$1
fs=$2
action="$3"
SRC_REV=""

echo $board
case $action in
	build)
		action=$action
		;;
	install)
		action=$action
		;;
	*)
		echo "Invalid build/install action"
		exit 1
esac

case $board in
	am335x)
		SUB_DIR="omap335x"
		SRC_REV="ad7c4fa37897b59b6d9ddabb9aba03fd515ffa29"
		;;
	am437x)
		SUB_DIR="omap437x"
		SRC_REV="ad7c4fa37897b59b6d9ddabb9aba03fd515ffa29"
		;;
	dra7)
		SUB_DIR="omap5430"
		SRC_REV="e06c0a4e11401534b938b9a7b1c3f27a65db871f"
		NULL_DRM=0
		;;
	
	*)
		echo "Invalid board for PVR $board"
		exit 1
esac


cd /home/franklin/repositories/git/omap5-sgx-ddk-linux/
 
git checkout $SRC_REV

cd -

if [ "$action" = "build" ]; then
	echo "Building PVR Driver"
	ccachemake -C /home/franklin/repositories/git/omap5-sgx-ddk-linux/eurasia_km/eurasiacon/build/linux2/${SUB_DIR}_linux KERNELDIR="/home/franklin/repositories/git/linux/" PVR_NULLDRM=$NULL_DRM > /dev/null

	echo "make -C /home/franklin/repositories/git/omap5-sgx-ddk-linux/eurasia_km/eurasiacon/build/linux2/${SUB_DIR}_linux KERNELDIR='/home/franklin/repositories/git/linux/' PVR_NULLDRM=$NULL_DRM"
	if [ "$?" != "0" ]; then
		echo "Building PVR Failed"
		exit 1
	fi
fi

if [ "$action" = "install" ]; then
	echo "Installing PVR Driver"
	sudo make -C /home/franklin/repositories/git/linux SUBDIRS=/home/franklin/repositories/git/omap5-sgx-ddk-linux/eurasia_km/eurasiacon/binary2_${SUB_DIR}_linux_release/target/kbuild INSTALL_MOD_PATH=$fs  modules_install > /dev/null

	echo "make -C /home/franklin/repositories/git/linux SUBDIRS=/home/franklin/repositories/git/omap5-sgx-ddk-linux/eurasia_km/eurasiacon/binary2_${SUB_DIR}_linux_release/target/kbuild INSTALL_MOD_PATH=$fs  modules_install"	
	if [ "$?" != "0" ]; then
		echo "Installing PVR Failed"
		exit 1
	fi
fi
