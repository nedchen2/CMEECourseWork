#! /bin/bash
while true do
	monitor=`qstat | grep myTest | grep -v grep | wc -l ` 
	if [ $monitor -eq 0 ] 
	then
		echo "Program is not running, restart myTest"
		./root/myTest &
	else
		echo "Program is running"
	fi
	sleep 30
done