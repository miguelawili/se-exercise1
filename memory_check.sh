#!/bin/bash
# Argument = -c criticalthreshold -w warningthreshold -e emailaddress

usage()
{
cat << EOF
usage: $0 options

This script will check the memory usage and tell if it's over the critical/warning threshold.

OPTIONS:
 -h Show this message
REQUIRED PARAMETERS:
 -c Critical Threshold (Percentage)
 -w Warning Threshold (Percentage)
 -e Email Address to send the report

EOF
}

MEM_USAGE=$(free | awk 'FNR == 3 {printf "%.2f", $3/($3+$4)*100}' )
DATE=$(date +'%Y%m%d %H:%M')
CRITICAL_THRESHOLD=
WARNING_THRESHOLD=
EMAIL_ADDRESS=
while getopts "hc:w:e:" OPTION
do
	case $OPTION in
	h)
		usage
		exit 1
		;;
	c)
		CRITICAL_THRESHOLD=${OPTARG}
		;;
	w)
		WARNING_THRESHOLD=${OPTARG}
		;;
	e)
		EMAIL_ADDRESS=${OPTARG}
		;;
	?)
		usage
		exit
		;;
	esac
done
echo "Critical Threshold is set to: $CRITICAL_THRESHOLD%"
echo "Warning Threshold is set to: $WARNING_THRESHOLD%"
echo "Email address is set to: $EMAIL_ADDRESS"
echo "You are currently using $MEM_USAGE% of your memory."
echo "The date is $DATE"

if [ -z "$CRITICAL_THRESHOLD" ]
then
	echo "Please input a value for critical threshold!"
	exit
fi

if [ -z "$WARNING_THRESHOLD" ]
then
	echo "Please input a value for warning threshold!"
	exit
fi

if [ -z "$EMAIL_ADDRESS" ]
then
	echo "Please input an email address!"
	exit
fi

if (( $(echo "$CRITICAL_THRESHOLD <= $WARNING_THRESHOLD" | bc -l) ))
then
	echo "Critical Threshold cannot be less than the Warning Threshold!"
	echo "Exiting script now..."
	exit
fi

if (( $(echo "$MEM_USAGE >= $CRITICAL_THRESHOLD" | bc -l) ))
then
	echo "Memory usage is at $MEM_USAGE% and is above the critical threshold!!!"
	exit 2
elif (( $(echo "$MEM_USAGE >= $WARNING_THRESHOLD" | bc -l) ))
then
	if (( $(echo "$MEM_USAGE < $CRITICAL_THRESHOLD" | bc -l) ))
	then
		echo "Memory usage is at $MEM_USAGE% which is between the warning threshold and the critical threshold."
	exit 1
	fi
else
	echo "Memory usage is at $MEM_USAGE% which is below the warning threshold."
	exit 0
fi
