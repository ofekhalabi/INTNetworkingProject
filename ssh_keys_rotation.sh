#!/bin/bash


# Paths
PRIVATE_IP=$1
KEY_DIR="/home/ubuntu"
OLD_KEY="${KEY_DIR}/old_key"
NEW_KEY="${KEY_DIR}/key_change"
NEW_KEY_PUB="${NEW_KEY}.pub"

if [[ $# -eq 1 ]]; then
	if [[ -f "${KEY_DIR}/key_change" ]]; then
		cd /home/ubuntu/
		if [[ -f "${OLD_KEY}" ]]; then
			rm -f old_key
		fi
		mv "${KEY_DIR}/key_change" "${OLD_KEY}" #CHANGE THE NAME TO THE OLD KEY
		rm  -f "${KEY_DIR}/key_change.pub"
	fi

	#GENERATE SSH_KEY ON THE PUBLIC INSTANCE
	ssh-keygen -t rsa -b 4096 -f /home/ubuntu/key_change -P "" -q

	#FORWARD PUBLIC KEY TO PRIVATE INSTANCE
	scp -i  /home/ubuntu/old_key /home/ubuntu/key_change.pub ubuntu@"${PRIVATE_IP=}":/home/ubuntu

	#APPEND THE NEW KEYS TO authorized_keys FILE
	ssh -i /home/ubuntu/old_key ubuntu@"${PRIVATE_IP}" "cat key_change.pub >> .ssh/authorized_keys"

	#CHCEK IF CAN I CONNECT TO THE MESHIN WITH THE NEW KEY
	ssh -i /home/ubuntu/key_change ubuntu@"${PRIVATE_IP}" "cat key_change.pub > .ssh/authorized_keys"
	if [[ $? -eq 0 ]]; then
		echo "Now you can connect to the private machine only with this key: ${NEW_KEY}"
		rm old_key
	else
		echo "The key you created is not good"
	fi
else
	echo "Please insert the private ip of your instance"
	exit 1
fi