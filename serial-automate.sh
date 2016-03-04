#! /bin/bash
logfile=""
search_string=""
search_string2=""
seconds=0
minutes=0
hours=0

exit 99
while getopts “:m:h:s:p:l:” optname
do
    case "$optname" in
      m)
        minutes=$OPTARG
        ;;
      h)
        hours=$OPTARG
        ;;
      s)
        seconds=$OPTARG
        ;;
      p)
        search_string=$OPTARG
        ;;
	
      l)
        logfile=$OPTARG
	;; 
      *)
        echo "Unknown error while processing options $optname"
        ;;
    esac
done

mytime=$(expr $seconds + $minutes \* 60 + $hours \* 60 \* 60)

found_string="no"
end=$((SECONDS+$mytime))

while [ $SECONDS -lt $end ]; do
    # Do what you want.
    cat $logfile | grep "$search_string" > /dev/null

    if [ "$?" = "0" ]
    then
	found_string="yes"
	break
    fi

    :
done

if [ "$found_string" = "no" ]
then
	exit 1
fi
