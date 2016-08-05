source /usr/local/bin/common.sh

machine=$1
action=$2

if [ "$action" == "off" ]; then
	eval ${pwrOff[$machine]}
elif [ "$action" == "on" ]; then
	eval ${pwrOn[$machine]}
elif [ "$action" == "reboot" ]; then
	eval ${pwrOff[$machine]}
	eval ${pwrOn[$machine]}
fi
