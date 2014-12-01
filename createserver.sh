#!/bin/bash
#Pedro Silva 


auth() {
	read -p "Whats your username:  " username
	read -p "Whats your APIkey:  " APIkey
	curl -s https://identity.api.rackspacecloud.com/v2.0/tokens -X POST -d '{"auth":{"RAX-KSKEY:apiKeyCredentials":{"username":"'$username'", "apiKey":"'$APIkey'"}}}' -H "Content-Type: application/json" | python -m json.tool

}

flavors(){
	read -p "DDI:  " ddi
	read -p "Token:  " token
	curl -s https://servers.api.rackspacecloud.com/v1.0/$ddi/flavors -H "X-Auth-Token:$token" | python -m json.tool	
	read -p "What flavor ID would you like:" flavor
}

images(){
	curl -s -H "X-Auth-Token: $token" https://lon.images.api.rackspacecloud.com/v2/images | python -m json.tool | egrep "name|id\"" | grep -v _id| tr -d "\"" | tr -d "," | sed 's/id/\n id/g' | sed 's/           name/name/g'
	read -p "What image would you like:" image
}

server (){
	read -p "Server Name: " name
	read -p "Server password: " password

	curl -s -X POST https://lon.servers.api.rackspacecloud.com/v2/$ddi/servers -H "X-Auth-Token: $token" -H "Content-Type: application/json" -d '{ "server" : { "name" : "'$name'", "imageRef" : "'$image'", "flavorRef" : "'$flavor'",  "adminPass" : "'$password'" } }' | python -m json.tool
}

auth
flavors
images
server
