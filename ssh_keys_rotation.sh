#!/bin/bash
PRIVATE_IP=$1
if [[ $# -eq 1 ]]; then
	if [[ -f /home/ubuntu/key_change ]]; then
		cd /home/ubuntu/
		rm key_change
		rm key_change.pub
		#GENERATE SSH_KEY ON THE PUBLIC INSTANCE
		ssh-keygen -t rsa -b 4096 -f /home/ubuntu/key_change -P "" -q
	else
		#GENERATE SSH_KEY ON THE PUBLIC INSTANCE
		ssh-keygen -t rsa -b 4096 -f /home/ubuntu/key_change -P "" -q
	fi

	#FORWARD PUBLIC KEY TO PRIVATE INSTANCE
	scp -i /home/ubuntu/private_key_git ubuntu@localhost:/home/ubuntu/key_change.pub ubuntu@"${PRIVATE_IP}":/home/ubuntu/

	#APPEND THE NEW KEYS TO authorized_keys FILE
	ssh -i /home/ubuntu/private_key_git ubuntu@"${PRIVATE_IP}" "cat key_change.pub >> .ssh/authorized_keys"

	#CHCEK IF CAN I CONNECT TO THE MESHIN WITH THE NEW KEY
	if [[ $(ssh -i /home/ubuntu/key_change ubuntu@"${PRIVATE_IP}" "cat key_change.pub > .ssh/authorized_keys") ]]; then
		echo "Now you can connect to the private machine only with this key"
	else
		echo "The key you created is not good"
	fi
else
	echo "Please insert the private ip of your instance"
	exit 1
fi

