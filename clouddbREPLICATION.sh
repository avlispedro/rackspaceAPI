#!/bin/bash
#Pedro Silva


read -p "Whats your username?:  " username
read -p "Whats your APIkey?:  " APIkey

curl -s https://identity.api.rackspacecloud.com/v2.0/tokens -X POST \
-d '{"auth":{"RAX-KSKEY:apiKeyCredentials":{"username":"'$username'", "apiKey":"'$APIkey'"}}}' \
-H "Content-Type: application/json" | python -m json.tool > /tmp/auth.temp

ddi=`cat /tmp/auth.temp | grep "tenantId" | tail -1 | sed 's/tenantId//g' | tr -d "\"" | tr -d ":" |  sed 's/                     //g'`
dc=`cat /tmp/auth.temp | grep "RAX-AUTH:defaultRegion" | sed 's/RAX\-AUTH\:defaultRegion//g' | tr '[:upper:]' '[:lower:]'| sed 's/rax\-auth\:defaultregion//g' | tr -d "\"" | tr -d ":" | tr -d "," | sed 's/             //g'`
token=`cat /tmp/auth.temp | grep -A 1  "expires" | grep -v "expires" | sed 's/id//g' | tr -d "\"" | tr -d ":" | tr -d "," | sed 's/             //g'`

#echo "--------"
#echo $ddi
#echo $dc
#echo $token
#echo "--------"

while true; do
	read -p "1 - list instances    2 - test if root enable     3 - enable root   4 - Replication 5 - EXIT : " response
	if [ $response = 1 ]; then
		curl -s --ciphers RC4-SHA:RC4-MD5 -H 'X-Auth-Token: '$token'' 'https://'$dc'.databases.api.rackspacecloud.com/v1.0/'$ddi'/instances' -H 'Content-Type: application/json' | python -m json.tool

	elif [ $response = 2 ]; then
		read -p "database id: " dbid
		curl -s  --ciphers RC4-SHA:RC4-MD5 -X POST -H 'X-Auth-Token: '$token''  'https://'$dc'.databases.api.rackspacecloud.com/v1.0/'$ddi'/instances/'$dbid'/root' -H 'Content-Type: application/json' | python -m json.tool

	elif [ $response = 3 ]; then
		read -p "database id: " dbid
		curl -s  --ciphers RC4-SHA:RC4-MD5 -X POST -H 'X-Auth-Token: '$token'' 'https://'$dc'.databases.api.rackspacecloud.com/v1.0/'$ddi'/instances/'$dbid'/root' -H 'Content-Type: application/json' | python -m json.tool

	elif [ $response = 4 ]; then
		echo "----------------------------"		
		echo "If you you intend to continue, you should know the MASTER INSTANCE ID and VERY VERY IMPORTANT, the master db will be automatically RESTARTED."
		echo "\n"
		read -p "Write YES you know the MASTER ID, and the customer accepted to have the instance restarted, or NO to return to the main menu: " reprepon
		if [ $reprepon = yes ]; then 
	                read -p "What is the Master cloud database id: " dbid
			echo "----------------------------"
			curl -s --ciphers RC4-SHA:RC4-MD5 -H 'X-Auth-Token:  '$token'' 'https://'$dc'.databases.api.rackspacecloud.com/v1.0/'$ddi'/instances/'$dbid'' -H 'Content-Type: application/json' | python -m json.tool > /tmp/db.temp 

size=`cat /tmp/db.temp | grep -m 1 "size" | sed 's/size//g' | tr -d "\"" | tr -d ":" |tr -d "," | sed 's/             //g'`
version=`cat /tmp/db.temp |  grep -m 1 "version" | sed 's/version//g' | tr -d "\"" | tr -d ":" |tr -d "," | sed 's/             //g'`
madversion="5.1"
flavorID=`cat /tmp/db.temp | grep -m 1 -A 1 "flavor" | grep id | sed 's/id//g' | tr -d "\"" | tr -d ":" | tr -d "," | sed 's/             //g'`
slaveflavor=0
			if [ $version = $madversion ]; then
				echo "----------------------------"
				echo "The mysql version that you intend to use to replicated is not valid, you should upgrade to 5.6."
				break
			fi

			read -p "What will be the name that you want to have on the slave instance: " slaveinstance

			curl -s --ciphers RC4-SHA:RC4-MD5 -H 'X-Auth-Token:  '$token'' 'https://'$dc'.databases.api.rackspacecloud.com/v1.0/'$ddi'/flavors' -H 'Content-Type: application/json' | python -m json.tool | egrep "id|name" | tr -d "\""| tr -d ","
			echo "----------------------------"
			read -p "What will be the slave flavor, bear in mind that must be equal or greater than the master, the master flavor is '$flavorID' : " slaveflavor
			if [ $slaveflavor -lt $flavorID ]; then
				echo "----------------------------"
                                echo "The flavor is smaller than the master."
                                break
			fi
		
			curl -s --ciphers RC4-SHA:RC4-MD5  -X POST -H 'X-Auth-Token: '$token'' -d '{"instance":{"volume":{"size":'$size'},"flavorRef":"'$slaveflavor'","name":"'$slaveinstance'","replica_of":"'$dbid'"}}' 'https://'$dc'.databases.api.rackspacecloud.com/v1.0/'$ddi'/instances' -H 'Content-Type: application/json' | python -m json.tool
		else
			echo "Good choise!"
		fi
		
	else
		break
	fi
#delete temporary file used to auth
done
rm /tmp/auth.temp
rm /tmp/db.temp
