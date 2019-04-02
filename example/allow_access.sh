#!/bin/bash
#
# Find IP address of container in stack connected to Docker Swarm local docker_gwbridge network.
#
# ./allow_access container_short_id "IP1 IP2 ..."

# Check if enough parameters
if [ $# -ne 2 ]
then
	echo -e "\nUsage: ./allow_access container_short_id 'IP1 IP2 ...'"
	exit 0
fi

ConShortID=$1
AllowedNetworks=$2
ConFulID=$(docker ps --no-trunc|grep ${ConShortID}|cut -d " " -f1)
if [ -z $ConFulID ]; then
	echo "No container found ..."
	exit 1
fi

ConBridgeIP=$(docker inspect -f "{{ .Containers.${ConFulID}.IPv4Address }}" docker_gwbridge|awk -F"/" '{ print $1 }')

echo "Container's IP in gwbridge network: ${ConBridgeIP}"

## Add rule to iptables
iptables -I DOCKER-USER -i docker_gwbridge ! -o docker_gwbridge -s ${ConBridgeIP} -j REJECT --reject-with icmp-port-unreachable

for Network in $AllowedNetworks; do
	iptables -I DOCKER-USER -d ${Network}  -i docker_gwbridge ! -o docker_gwbridge -s ${ConBridgeIP} -j ACCEPT
done
