curl -s -H 'X-Auth-Token:  asdasdasdasdasd648f' 'https://lon.networks.api.rackspacecloud.com/v2.0/security-groups' | python -m json.tool

curl -s -X POST -H 'X-Auth-Token:  aasdasdasdasd' -d '{"security_group":{"name":"new-webservers","description":"security group for webservers"}}' 'https://lon.networks.api.rackspacecloud.com/v2.0/security-groups'  -H 'Content-Type: application/json' | python -m json.tool


