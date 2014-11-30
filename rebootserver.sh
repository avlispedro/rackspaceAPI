#!/bin/bash

read -p "DDI?" DDI
read -p "Token?" Token
read -p "datacenter (dfw ord iad syd lon hkg)" DC
read -p "Server ID" ID
curl -i -X POST https://$DC.servers.api.rackspacecloud.com/v2/$DDI/servers/$ID/action -H "X-Auth-Token: $Token" -H "Content-Type: application/json" \
  -d '{"reboot" : {"type" : "HARD"}}'
