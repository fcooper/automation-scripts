declare -A relay
declare -A sw
declare -A onCommands
declare -A offCommands
declare -A rebootCommands

source /usr/local/bin/common.sh

# K2HK 
relay[k2hk]=6
onCommands[k2hk]="pw_relay_on"
offCommands[k2hk]="pw_relay_off"
rebootCommands[k2hk]="${offCommands[k2hk]} ${onCommands[k2hk]}"

# X15 
relay[x15]=5
sw[x15]=15
onCommands[x15]="pw_relay_on sw_on"
offCommands[x15]="pw_relay_off sw_off"
rebootCommands[x15]="${offCommands[x15]} ${onCommands[x15]}"

# BBB
relay[bbb]=1
onCommands[bbb]="pw_relay_on"
offCommands[bbb]="pw_relay_off"
rebootCommands[bbb]="${offCommands[bbb]} ${onCommands[bbb]}"

# AM335x GP
relay[335-gp]=7
onCommands[335-gp]="relay_on"
offCommands[335-gp]="relay_off"
rebootCommands[335-gp]="${offCommands[335-gp]} ${onCommands[335-gp]}"

# DRA7 GP
relay[dra7-gp]=5
onCommands[dra7-gp]="relay_on"
offCommands[dra7-gp]="relay_off"
rebootCommands[dra7-gp]="${offCommands[dra7-gp]} ${onCommands[dra7-gp]}"

# pandaboard
relay[pandaboard]=1
onCommands[pandaboard]="relay_on"
offCommands[pandaboard]="relay_off"
rebootCommands[pandaboard]="${offCommands[pandaboard]} ${onCommands[pandaboard]}"

# AM37 GP
relay[37x-gp]=3
onCommands[37x-gp]="relay_on"
offCommands[37x-gp]="relay_off"
rebootCommands[37x-gp]="${offCommands[37x-gp]} ${onCommands[37x-gp]}"

# Relay 4 - Josh BB
# AM437 SK
#relay[437-sk]=4
#sw[437-sk]=1
#onCommands[437-sk]="relay_on sw_off sw_on sw_off"
#offCommands[437-sk]="relay_off"
#rebootCommands[437-sk]="${offCommands[437-sk]} ${onCommands[437-sk]}"

# AM437 GP
relay[437-gp]=8
onCommands[437-gp]="relay_on"
offCommands[437-gp]="relay_off"
rebootCommands[437-gp]="${offCommands[437-gp]} ${onCommands[437-gp]}"

# K2E
relay[k2e]=6
onCommands[k2e]="relay_on"
offCommands[k2e]="relay_off"
rebootCommands[k2e]="${offCommands[k2e]} ${onCommands[k2e]}"

# K2G
relay[k2g]=2
onCommands[k2g]="relay_on"
offCommands[k2g]="relay_off"
rebootCommands[k2g]="${offCommands[k2g]} ${onCommands[k2g]}"

# AM57 IDK
relay[am57-idk]=2
onCommands[am57-idk]="relay_on"
offCommands[am57-idk]="relay_off"
rebootCommands[am57-idk]="${offCommands[am57-idk]} ${onCommands[am57-idk]}"

turn_off_sw () {
   relay_num=$1
   let value="($relay_num - 1) * 2"
   value=$(printf %02d $value)
   echo "Turning off SW $relay_num"
   curl -s $switch_one_ip/30000/$value &> /dev/null
}

turn_on_sw () {
    relay_num=$1
    let value="($relay_num - 1) * 2 + 1"
    value=$(printf %02d $value)
    echo "Turning on SW $relay_num"
    curl -s $switch_one_ip/30000/$value &> /dev/null
}

turn_off_relay () {
    relay_num=$1

    echo "Turning Off Relay $relay_num"
    the="/proc/power/relay$relay_num"
	sshpass -pubnt ssh -o StrictHostKeyChecking=no ubnt@$relay_one_ip "echo 0 > /proc/power/relay$relay_num"
}

turn_on_relay () {
    relay_num=$1
    echo "Turning On Relay $relay_num"
	sshpass -pubnt ssh -o StrictHostKeyChecking=no ubnt@$relay_one_ip "echo 1 > /proc/power/relay$relay_num"
}

turn_off_pw_relay () {
    relay_num=$1
	echo "test off"
    echo "Turning Off Relay Power Switch $relay_num"
    curl --silent http://admin:1234@$pw_relay_ip/outlet?$relay_num=OFF > /dev/null
}

turn_on_pw_relay () {
    relay_num=$1
	echo "test on"
    echo "Turning On Relay Power Switch $relay_num"
    curl --silent http://admin:1234@$pw_relay_ip/outlet?$relay_num=ON > /dev/null
}

process_command () {
    machine=$1
    commands=$2

    relay_num=${relay[$machine]}
    sw_num=${sw[$machine]}

    # Remove extra spaces
    commands=`echo $commands | sed -e 's/^[ \t]*//'`

    IFS=', ' read -a array <<< "$commands"

    for element in "${array[@]}"
    do
	    case $element in
		    sw_on)
			    turn_on_sw $sw_num
			    ;;
		    sw_off)
			    turn_off_sw $sw_num
			    ;;
		    relay_on)
			    turn_on_relay $relay_num
			    ;;
		    relay_off)
			    turn_off_relay $relay_num
			    ;;
		    pw_relay_on)
			    turn_on_pw_relay $relay_num
			    ;;
		    pw_relay_off)
			    turn_off_pw_relay $relay_num
			    ;;
		    *)
			    echo "Invalid build argument: $element"
			    exit
	    esac
        sleep 1
    done
}

arg=$1

if [ "$arg" != "all" ]; then
    if [ "${offCommands[$arg]}" = "" -o "${onCommands[$arg]}" = "" -o  "${relay[$arg]}" = "" ]; then

        if [ ":$arg:" != "::" ]; then
            echo "Invalid board $arg or incomplete board commands"
        fi

        echo "List of valid boards:"
        for i in "${!relay[@]}"
        do   
            echo "  $i"
        done

        exit 1
    fi
fi

board=$arg


arg=$2
case $arg in
    off)
        command=$arg
    ;;
    on)
        command=$arg
    ;;
    reboot)
        command=$arg
    ;;
    *)
        echo "Invalid power options for board $board"
        exit 1
    ;;
esac


if [ "$board" = "all" ]; then
    echo "Execute commands for all board"
    for i in "${!relay[@]}"
    do   
        #echo "key  : $i"
        #echo "value: ${board[$i]}"

        if [ "$command" = "on" ]; then
            echo "Turning $i on"
            process_command $i "${onCommands[$i]}"
        elif [ "$command" = "off" ]; then
            echo "Turning $i off"
            process_command $i "${offCommands[$i]}"
        elif [ "$command" = "reboot" ]; then
            echo "Turning $i reboot"
            process_command $i "${rebootCommands[$i]}"
        fi
	sleep 1
    done
else
    if [ "$command" = "on" ]; then
        echo "Turning $board on"
        process_command $board "${onCommands[$board]}"
    elif [ "$command" = "off" ]; then
        echo "Turning $board off"
        process_command $board "${offCommands[$board]}"
    elif [ "$command" = "reboot" ]; then
        echo "Turning $board reboot"
        process_command $board "${rebootCommands[$board]}"
    fi
fi
