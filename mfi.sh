source /usr/local/bin/common.sh

#mFI
#192.168.1.3

ip=$1
relay=$2
action=$3

turn_off() {
	echo "Turning Off Relay $relay"
	sshpass -pubnt ssh -o StrictHostKeyChecking=no ubnt@$ip "echo 0 > /proc/power/relay$relay"
}

turn_on() {
	echo "Turning On Relay $relay"
	sshpass -pubnt ssh -o StrictHostKeyChecking=no ubnt@$ip "echo 1 > /proc/power/relay$relay"
}

if [ "$action" == "off" ]; then
	turn_off  $relay
elif [ "$action" == "on" ]; then
	turn_on  $relay
fi
