stty -F /dev/dra7 115200 cs8
automation=/home/franklin/repositories/git/scripts/serial-automate.sh
file="/home/franklin/dra7.txt"

function sendCommand {
	echo "$1" > /dev/dra7
}

function waitFor {

	$automation  -l "$file" $*

	if [ "$?" = "1" ]
	then
		return 1
	fi
}

cat /dev/null > $file

waitFor -m 3  -p "dra7xx-evm login:"

if [ "$?" = "1" ]
then
 echo "Failed to login"
 exit 1
fi

sendCommand "root"
echo "Logged in successfully"

sendCommand "./uart-test.sh"

waitFor -m 3 -p "ERROR"
if [ "$?" = "1" ]
then
	echo "Test failed"
else
	echo "No error seen"
fi

