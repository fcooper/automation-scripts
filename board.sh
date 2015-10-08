declare -A relay     # Create an associative array
relay[335x-gp]=6
relay[dra7-gp]=8
relay[37x-gp]=5
relay[437-sk]=7
relay[437-gp]=4
relay[k2e]=3

declare -A sw     # Create an associative array
sw[dra7-gp]=1
sw[437-sk]=2



turn_off_sw () {
   relay_num=$1
   let value="($relay_num - 1) * 2"
   value=$(printf %02d $value)
   echo "Turning off SW $relay_num"
   curl -s 192.168.1.251/30000/$value &> /dev/null
}

turn_on_sw () {
    relay_num=$1
    let value="($relay_num - 1) * 2 + 1"
    value=$(printf %02d $value)
    echo "Turning on SW $relay_num"
    curl -s 192.168.1.251/30000/$value &> /dev/null
}

turn_off_relay () {
    relay_num=$1

    echo "Turning Off Relay $relay_num"
    the="/proc/power/relay$relay_num"
    ssh ubnt@192.168.1.243 "echo 0 > /proc/power/relay$relay_num"
}

turn_on_relay () {
    relay_num=$1
    echo "Turning On Relay $relay_num"
    ssh ubnt@192.168.1.243 "echo 1 > /proc/power/relay$relay_num"
}

command=""
board=""

arg=$2

all="no"


    
arg=$1
case $arg in
    335x-gp)
        board="335x-gp"
    ;;
    437x-sk)
        board="437-sk"
    ;;
    37x-gp)
        board="37x-gp"
    ;;
    dra7-gp)
        board="dra7-gp"
    ;;
    437-gp)
        board="437-gp"
    ;;
    k2e)
	board="k2e"
    ;;
    alloff)
        command="off"
        all="yes"
    ;;
    allon)
        command="on"
        all="yes"
    ;;
    *)
        echo "Invalid Board"
        exit
    ;;
esac

arg=$2
if [ "$all" = "no" ]; then
    case $arg in
        off)
            command="off"
        ;;
        on)
            command="on"
        ;;
        reboot)
            command="reboot"
        ;;
        *)
            echo "Invalid Option"
            exit
        ;;
    esac
fi


if [ "$board" = "437-sk" -o "$all" = "yes" ]; then
    relay_num=${relay[437-sk]}
    sw_num=${sw[437-sk]}

    if [ $command = "off" ]; then
        turn_off_relay $relay_num
    elif [ $command = "on" ]; then
       turn_on_relay $relay_num ; turn_off_sw $sw_num ; sleep .5 ; turn_on_sw $sw_num ; sleep .5 ; turn_off_sw $sw_num
    elif [ $command = "reboot" ]; then
        turn_off_relay $relay_num ; sleep 1 ; turn_on_relay $relay_num ; sleep 1; turn_off_sw $sw_num ; sleep 1 ; turn_on_sw $sw_num ; sleep 1 ; turn_off_sw $sw_num
    fi

fi

if [ "$board" = "437-gp" -o "$all" = "yes" ]; then
    relay_num=${relay[437-gp]}
    sw_num=${sw[437-gp]}

    if [ $command = "off" ]; then
        turn_off_relay $relay_num
    elif [ $command = "on" ]; then
       turn_on_relay $relay_num
    elif [ $command = "reboot" ]; then
        turn_off_relay $relay_num ; turn_on_relay $relay_num
    fi

fi


if [ "$board" = "dra7-gp" -o "$all" = "yes" ]; then
    relay_num=${relay[dra7-gp]}
    sw_num=${sw[dra7-gp]}

    if [ "$command" = "off" ]; then
        turn_off_relay $relay_num
    elif [ "$command" = "on" ]; then
        turn_off_relay $relay_num ; sleep .5 ; turn_on_relay $relay_num ; sleep .5 ; turn_off_sw $sw_num ; sleep .5 ; turn_on_sw $sw_num ; sleep .5 ; turn_off_sw $sw_num
    elif [ "$command" = "reboot" ]; then
        turn_off_relay $relay_num ; sleep .5 ; turn_on_relay $relay_num ; sleep .5 ; turn_off_sw $sw_num ; sleep .5 ; turn_on_sw $sw_num ; sleep .5 ; turn_off_sw $sw_num
    fi
fi

if [ "$board" = "335x-gp" -o "$all" = "yes" ]; then
    relay_num=${relay[335x-gp]}


    if [ $command = "off" ]; then
        turn_off_relay $relay_num
    elif [ $command = "on" ]; then
       turn_on_relay $relay_num
    elif [ $command = "reboot" ]; then
        turn_off_relay $relay_num ; sleep .5 ; turn_on_relay $relay_num
    fi
fi

if [ "$board" = "k2e" -o "$all" = "yes" ]; then
    relay_num=${relay[k2e]}


    if [ $command = "off" ]; then
        turn_off_relay $relay_num
    elif [ $command = "on" ]; then
       turn_on_relay $relay_num
    elif [ $command = "reboot" ]; then
        turn_off_relay $relay_num ; sleep .5 ; turn_on_relay $relay_num
    fi
fi


if [ "$board" = "37x-gp" -o "$all" = "yes" ]; then
    relay_num=${relay[37x-gp]}


    if [ $command = "off" ]; then
        turn_off_relay $relay_num
    elif [ $command = "on" ]; then
       turn_on_relay $relay_num
    elif [ $command = "reboot" ]; then
        turn_off_relay $relay_num ; sleep .5 ; turn_on_relay $relay_num
    fi

fi







