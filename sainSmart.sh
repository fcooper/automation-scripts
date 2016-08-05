source /usr/local/bin/common.sh

#SainSmart Relay
#192.168.1.251

ip=$1
relay=$2
action=$3

turn_off() {
   relay=$1
   let value="($relay - 1) * 2"
   value=$(printf %02d $value)
   echo "Turning off SW $relay"
   curl -s $ip/30000/$value &> /dev/null
}

turn_on() {
    relay_num=$1
    let value="($relay - 1) * 2 + 1"
    value=$(printf %02d $value)
    echo "Turning on SW $relay"
    curl -s $ip/30000/$value &> /dev/null
}

if [ "$action" == "off" ]; then
	turn_off  $relay
elif [ "$action" == "on" ]; then
	turn_on  $relay
fi
