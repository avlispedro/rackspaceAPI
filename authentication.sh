#!/bin/bash

read -p "Whats your username?: " username
read -p "Whats your APIkey?: " APIkey
echo "$username"
echo "$APIkey"

curl -s https://identity.api.rackspacecloud.com/v2.0/tokens -X POST \
-d '{"auth":{"RAX-KSKEY:apiKeyCredentials":{"username":"'$username'", "apiKey":"'$APIkey'"}}}' \
-H "Content-Type: application/json" | python -m json.tool


