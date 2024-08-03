#!/bin/bash

BASTION_IP=$1
PRIVATE_IP=$2
COMMAND_PRIVATE=$3
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
		ssh -i "$KEY_PATH" ubuntu@$BASTION_IP        # Connect to the remote server using SSH
	elif [[ "$#" -eq 2 || "$#" -eq 3 ]]; then
		# Establish SSH tunnel to the private instance via the bastion host
		echo "Creating SSH tunnel from local port 2222 to private instance via bastion host..."
		ssh -i "$KEY_PATH" -L 2222:"$PRIVATE_IP":22 ubuntu@"$BASTION_IP" -N &
		SSH_TUNNEL_PID=$! # take the process number for the kill after logout to private instance
		sleep 5 # wait a moment to ensure the tunnel is established

		# Connect to the private instance via the SSH tunnel
		echo "Connecting to the private instance $PRIVATE_IP..."
		ssh -i /home/ofekh/AWS/Instances/ofekh-private-ec2/keys/private_vpcPV.keys.pem -p 2222 ubuntu@localhost $COMMAND_PRIVATE
		
		echo "Cleaning up SSH tunnel..." # Clean up: kill the SSH tunnel process
		kill $SSH_TUNNEL_PID

	else
		echo "Please enter one , two or three parameters."
	fi
fi

