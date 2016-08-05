board=$1

case $board in

	bbw)
		;;
	bbb)
		minicom -wD /dev/bbb
		;;
	572-idk)
		minicom -wD /dev/572-idk
		;;
	335-ice)
		minicom -wD /dev/335-ice
		;;
	335-gp)
		minicom -wD /dev/335-gp
		;;
	335-sk)
		;;
	437-gp)
		minicom -wD /dev/437-gp
		;;
	437-sk)
		minicom -wD /dev/437-sk
		;;
	37-gp)
		minicom -wD /dev/37-gp
		;;
	k2e)
		minicom -wD /dev/k2e
		;;
	k2g)
		minicom -wD /dev/k2g
		;;
	x15)
		minicom -wD /dev/x15
		;;
	dra7)
		minicom -wD /dev/dra7	
		;;
	dra72-gp)
		;;
	pandaboard)
		minicom -wD /dev/pandaboard
		;;
	*)
		echo "Invalid board"
		exit
esac
