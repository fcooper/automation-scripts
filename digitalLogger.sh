source /usr/local/bin/common.sh

#Digital Logger
#192.168.1.252

ip=$1
relay=$2
action=$3

turn_off() {
    echo "Turning Off Relay Power Switch $relay"
    curl --silent http://admin:1234@$ip/outlet?$relay=OFF > /dev/null
}

turn_on() {
    echo "Turning On Relay Power Switch $relay_num"
    curl --silent http://admin:1234@$ip/outlet?$relay=ON > /dev/null
}

if [ "$action" == "off" ]; then
	turn_off  $relay
elif [ "$action" == "on" ]; then
	turn_on  $relay
fi
