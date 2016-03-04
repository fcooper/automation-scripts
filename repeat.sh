#! /bin/bash
# full_appended_keystone_defconfig no_baseport_appended_keystone_defconfig no_connectivity_appended_keystone_defconfig no_ipc_appended_keystone_defconfig keystone_defconfig

file='/home/franklin/am437-test/capture.txt'
problem="File:FATAL: TEST FAILED"
seconds=0
minutes=2
hours=0
mytime=$(expr $seconds + $minutes \* 60 + $hours \* 60 \* 60)


COUNTER=0

while [ $COUNTER -lt 100000000000 ]
do

		power-board.sh 437-gp reboot

		cat /dev/null > $file

		good="no"
		end=$((SECONDS+$mytime))

		echo "Counter: $COUNTER"
		echo "Started now $end"
		while [ $SECONDS -lt $end ]; do
		    # Do what you want.
		    cat $file | grep "File:FATAL: TEST FAILED"

		    if [ "$?" = "0" ]
		    then
			echo "Got the error"
			good="yes"
			break
		    fi

		    :
		done


		cat $file > "/home/franklin/am437-test/${COUNTER}.txt"
		if [ "$good" = "yes" ]
		then
			echo "Saw error after $COUNTER iterations"
			break
		fi
		let COUNTER++
done
