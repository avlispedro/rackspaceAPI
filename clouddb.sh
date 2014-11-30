#!/bin/bash
#Pedro Silva
#pedro.silva@rackspace.co.uk

read -p "Whats your username?:" username
read -p "Whats your APIkey?:" APIkey
echo "$username"
echo "$APIkey"

curl -s https://identity.api.rackspacecloud.com/v2.0/tokens -X POST \
-d '{"auth":{"RAX-KSKEY:apiKeyCredentials":{"username":"'$username'", "apiKey":"'$APIkey'"}}}' \
-H "Content-Type: application/json" | python -m json.tool

read -p "ddi:" ddi
read -p "datacenter:" dc
read -p "api token:" token

while true; do
	read -p "1 - list instances    2 - test if root enable     3 - enable root    4 - EXIT : " response
	if [ $response = 1 ]; then
		curl -s  --ciphers RC4-SHA:RC4-MD5 -i -H 'X-Auth-Token: '$token'' -H 'Content-Type: application/json' 'https://'$dc'.databases.api.rackspacecloud.com/v1.0/'$ddi'/instances'

	elif [ $response = 2 ]; then
		read -p "database id:" dbid
		curl -s  --ciphers RC4-SHA:RC4-MD5 -X GET -i -H 'X-Auth-Token: '$token'' -H 'Content-Type: application/json' 'https://'$dc'.databases.api.rackspacecloud.com/v1.0/'$ddi'/instances/'$dbid'/root'

	elif [ $response = 3 ]; then
		read -p "database id:" dbid
		curl -s  --ciphers RC4-SHA:RC4-MD5 -X POST -i -H 'X-Auth-Token: '$token'' -H 'Content-Type: application/json' 'https://'$dc'.databases.api.rackspacecloud.com/v1.0/'$ddi'/instances/'$dbid'/root'
	else
		break
	fi
done
