auth() {
    read -p "Whats your username:  " username
    read -p "Whats your APIkey:  " APIkey

    curl -s https://identity.api.rackspacecloud.com/v2.0/tokens -X POST -d '{"auth":{"RAX-KSKEY:apiKeyCredentials":{"username":"'$username'", "apiKey":"'$APIkey'"}}}' -H "Content-Type: application/json" | python -m json.tool

}

flavors(){
    read -p "DDI:  " ddi
    read -p "Token:  " token
    curl -s https://servers.api.rackspacecloud.com/v1.0/$ddi/flavors -H "X-Auth-Token:$token" | python -m json.tool
}

auth
flavors
