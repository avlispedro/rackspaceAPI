#!/bin/bash
#Pedro Silva

read -p "Whats your username?:  " username
read -p "Whats your APIkey?:  " APIkey

curl -s https://identity.api.rackspacecloud.com/v2.0/tokens -X POST \
-d '{"auth":{"RAX-KSKEY:apiKeyCredentials":{"username":"'$username'", "apiKey":"'$APIkey'"}}}' \
-H "Content-Type: application/json" | python -m json.tool > /tmp/auth.temp

ddi=`cat /tmp/auth.temp | grep -m 1 "tenantId" | sed 's/tenantId//g' | tr -d "\"" | tr -d ":"| sed 's/                         //g'`
dc=`cat /tmp/auth.temp | grep "RAX-AUTH:defaultRegion" | sed 's/RAX\-AUTH\:defaultRegion//g' | tr '[:upper:]' '[:lower:]'| sed 's/rax\-auth\:defaultregion//g' | tr -d "\"" | tr -d ":" | tr -d "," | sed 's/             //g'`
token=`cat /tmp/auth.temp | grep -A 1  "expires" | grep -v "expires" | sed 's/id//g' | tr -d "\"" | tr -d ":" | tr -d "," | sed 's/             //g'`

echo "--------"
echo $ddi
echo $dc
echo $token
echo "--------"

while true; do
	read -p "1 - list instances    2 - test if root enable     3 - enable root    4 - EXIT : " response
	if [ $response = 1 ]; then
		curl -s --ciphers RC4-SHA:RC4-MD5 -H 'X-Auth-Token: '$token'' 'https://'$dc'.databases.api.rackspacecloud.com/v1.0/'$ddi'/instances' -H 'Content-Type: application/json' | python -m json.tool

	elif [ $response = 2 ]; then
		read -p "database id: " dbid
		curl -s  --ciphers RC4-SHA:RC4-MD5 -X POST -H 'X-Auth-Token: '$token''  'https://'$dc'.databases.api.rackspacecloud.com/v1.0/'$ddi'/instances/'$dbid'/root' -H 'Content-Type: application/json' | python -m json.tool

	elif [ $response = 3 ]; then
		read -p "database id: " dbid
		curl -s  --ciphers RC4-SHA:RC4-MD5 -X POST -H 'X-Auth-Token: '$token'' 'https://'$dc'.databases.api.rackspacecloud.com/v1.0/'$ddi'/instances/'$dbid'/root' -H 'Content-Type: application/json' | python -m json.tool
	else
		break
	fi
#delete temporary file used to auth
done
rm /tmp/auth.temp
