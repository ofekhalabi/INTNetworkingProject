#!/bin/bash

BASTION_IP=$1
PRIVATE_IP=$2
COMMAND_PRIVATE=$3

KEY_PATH_2=/home/ubuntu/key_change

# Function to check if an IP address is reachable
check_ip() {
	local ip=$1
	if ping -c 1 "$ip" &> /dev/null; then
		echo "The IP address of public instance is $ip"
	else
		echo "The IP address $ip is not reachable or your machine is down."
		exit 1 # Exit the script if the IP is not reachable
	fi
}

# Check if the environment variable `KEY_PATH` is set
if [[ -z "${KEY_PATH}" ]]; then
	echo "The environment variable 'KEY_PATH' does not exist."
	exit 5
else
	echo "The environment variable 'KEY_PATH' exists."
	# Check the number of arguments if the num = 1 is connect the Public instance , if the num = 2 is connect to Private instance, if the num = 3 is to command on Private instance. 
	if [[ "$#" -eq 1 ]]; then
		check_ip "$BASTION_IP"                   # Validate the IP address before attempting to SSH
		ssh -i "${KEY_PATH}" ubuntu@$BASTION_IP        # Connect to the remote server using SSH
	elif [[ "$#" -eq 2 || "$#" -eq 3 ]]; then
		#ssh-add -q ${KEY_PATH}
		#ssh -J ubuntu@${BASTION_IP} ubuntu@${PRIVATE_IP} "${COMMAND_PRIVATE}"
		ssh -t -i "${KEY_PATH}" ubuntu@"${BASTION_IP}" "ssh -i ${KEY_PATH_2} ubuntu@${PRIVATE_IP} ${COMMAND_PRIVATE}"

	else
		echo "Please enter one , two or three parameters."
	fi
fi

