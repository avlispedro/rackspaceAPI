#!/bin/bash

read -p "Whats your username?: " username
read -p "Whats your APIkey?: " APIkey

curl -s https://identity.api.rackspacecloud.com/v2.0/tokens -X POST \
-d '{"auth":{"RAX-KSKEY:apiKeyCredentials":{"username":"'$username'", "apiKey":"'$APIkey'"}}}' \
-H "Content-Type: application/json" | python -m json.tool > /tmp/auth.temp

ddi=`cat /tmp/auth.temp | grep -m 1 "tenantId" | sed 's/tenantId//g' | tr -d "\"" | tr -d ":"| sed 's/                         //g'`
dc=`cat /tmp/auth.temp | grep "RAX-AUTH:defaultRegion" | sed 's/RAX\-AUTH\:defaultRegion//g' | tr '[:upper:]' '[:lower:]'| sed 's/rax\-auth\:defaultregion//g' | tr -d "\"" | tr -d ":" | tr -d "," | sed 's/             //g'`
token=`cat /tmp/auth.temp | grep -A 1  "expires" | grep -v "expires" | sed 's/id//g' | tr -d "\"" | tr -d ":" | tr -d "," | sed 's/             //g'`

while true; do
	read -p "1 - List  loadbalancers  2 - Change timeout  3 - List all details  4 - EXIT : " response
	if [ $response = 1 ]; then
		curl -s -H 'X-Auth-Token: '$token'' 'https://'$dc'.loadbalancers.api.rackspacecloud.com/v1.0/'$ddi'/loadbalancers' -H 'Content-Type: application/json' | python -m json.tool | egrep "id|name" | tr -d "\"" | tr -d ","
	elif [ $response = 2 ]; then
		read -p "loadbalancer ID: " lbid
		read -p "How many seconds, the limit is 120: " timeout
		curl -i -s -d '{"loadBalancer":{"timeout": "'$timeout'"}}' -H 'X-Auth-Token: '$token'' -H 'Content-Type: application/json' -X PUT 'https://'$dc'.loadbalancers.api.rackspacecloud.com/v1.0/'$ddi'/loadbalancers/'$lbid''
	elif [ $response = 3 ]; then
		curl -s -H 'X-Auth-Token: '$token'' 'https://'$dc'.loadbalancers.api.rackspacecloud.com/v1.0/'$ddi'/loadbalancers' -H 'Content-Type: application/json' | python -m json.tool 

	else 
		break
	fi
#delete temporary file used to auth
done
rm /tmp/auth.temp
