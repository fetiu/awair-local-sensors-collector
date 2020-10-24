usage() {
	echo -e "usage: \033[1m$0\033[0m [\033[4mip\033[0m \033[4m...\033[0m]"
	exit
}


if [ $# == 0 ];
then
	usage
fi

for ip in $@
do
	ping -o -t 1 $ip 2>&1 >/dev/null
done

if [ $? != 0 ]; 
then
	echo "error: invalid ip provided"
	usage
fi


get_airdata() {
	url=$1
	query=current_time=`gdate +%FT%T.%3NZ`
	curl -s $url/air-data/latest?$query | jq
}

get_config() {
	url=$1
	opt=$2
	curl -s $url/settings/config/data | jq .$opt
}

rm -rf output
mkdir output
echo "Local Sensors collector started. check ./output to get output files"

while :
do
	for ip in $@
	do
		uuid=`get_config $ip device_uuid | tr -d '"'`
		path=output/$uuid.json
		get_airdata $ip | tee -a $path
		echo , | tee -a $path
	done

	sleep 10
done
