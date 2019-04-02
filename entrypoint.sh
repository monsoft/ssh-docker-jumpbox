#!/bin/bash

for USRN in $USERS; do
  	echo "Creating user $USRN"
	useradd -m -s /bin/bash $USRN
done

exec /usr/sbin/sshd -D -e
