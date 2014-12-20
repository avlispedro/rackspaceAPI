#!/bin/bash
#Pedro Silva

configurationfunction(){
		array=()
                echo "How MANY parameters do you want to use in you configuration:  "
                read numparam

                index=0
                        for temp in $(seq 1 $numparam)
                        do
                                echo "What is the parameter name:  "
                                read parametername
				echo "The value is a string or integer, str or int:  "
	                        read stringint
                                echo "What is the parameter value:  "
                                read parametervalue
                                echo "------------------------------"
                                let "index++"
                                if [ $index = $numparam ]; then
					if [ $stringint = int ]; then
						array[$temp]="\""$parametername"\""":"$parametervalue
					else
	                                        array[$temp]="\""$parametername"\""":""\""$parametervalue"\""
					fi
                                else
					if [ $stringint = str ]; then
	                                        array[$temp]="\""$parametername"\""":""\""$parametervalue"\""","
					else
						array[$temp]="\""$parametername"\""":"$parametervalue","
					fi
                                fi
                        done
			#echo "DEBUG"
			#echo "${array[@]}"
			#echo "DEBUG"
                        read -p "What will be the Description: " description
                        read -p "What will be the configuration name:  " configname
			allvalues="${array[@]}"
                        curl -s --ciphers RC4-SHA:RC4-MD5 -X POST -H "X-Auth-Token: $token" -d "{\"configuration\":{\"datastore\":{\"type\":\"$databasetype\",\"version\":\"$databaseversion\"},\"description\":\"$description\",\"name\":\"$configname\",\"values\":{$allvalues}}}" "https://$dc.databases.api.rackspacecloud.com/v1.0/$ddi/configurations" -H "Content-Type: application/json" | python -m json.tool

#echo "DEBUG"
#echo ${array[@]}
#echo $allvalues
#echo $token
#echo $databasetype
#echo $databaseversion
#echo $description
#echo $configname
#echo $dc
#echo $ddi
#echo "DEBUG"
}



#read -p "Whats your username?:  " username
#read -p "Whats your APIkey?:  " APIkey

username=avlispedro
APIkey=5d74894546dfdfbee9a72af7e3fce54f


curl -s https://identity.api.rackspacecloud.com/v2.0/tokens -X POST -d '{"auth":{"RAX-KSKEY:apiKeyCredentials":{"username":"'$username'", "apiKey":"'$APIkey'"}}}' -H "Content-Type: application/json" | python -m json.tool > /tmp/auth.temp

dditemp=`cat /tmp/auth.temp | grep "tenantId" | tail -1 | sed 's/tenantId//g' | tr -d "\"" | tr -d ":" |  sed 's/                     //g'`
dctemp=`cat /tmp/auth.temp | grep "RAX-AUTH:defaultRegion" | sed 's/RAX\-AUTH\:defaultRegion//g' | tr '[:upper:]' '[:lower:]'| sed 's/rax\-auth\:defaultregion//g' | tr -d "\"" | tr -d ":" | tr -d "," | sed 's/             //g'`
tokentemp=`cat /tmp/auth.temp | grep -A 1  "expires" | grep -v "expires" | sed 's/id//g' | tr -d "\"" | tr -d ":" | tr -d "," | sed 's/             //g'`

#echo "I think this is the information that you require, can you confirm:"
#echo $dditemp
#echo $dctemp
#echo $tokentemp
#echo "--------"

#read -p "Can you please paste DDI: " ddi
#read -p "Can you plese paste Datacenter: " dc
#read -p "Can you please paste the token: " token
ddi=$dditemp
dc=$dctemp
token=$tokentemp


while true; do
	echo "1 - List all the Configurations"
	echo "2 - List the cloud DataBase parameters"
	echo "3 - Create a configuration"
	echo "4 - Apply a Configurations"
	echo "5 - List the datastores"
	echo "6 - Delete configuration"
	echo "7 - Check which Database the configuration was applied"
	echo "8 - List a configuration details"
	echo "9 - Unload a Configurations from a DB"
	echo "10 - EXIT" 
	read  response
	
	if [ $response = 1 ]; then
		curl -s --ciphers RC4-SHA:RC4-MD5 -H 'X-Auth-Token: '$token'' https://"$dc".databases.api.rackspacecloud.com/v1.0/"$ddi"/configurations -H 'Content-Type: application/json' | python -m json.tool

	elif [ $response = 2 ]; then
		read -p "DataBase Type, mariadb, mysql, percona:  " databasetype
			if [ $databasetype = mariadb ]; then
				echo "MARIADB NOT AVAILABLE YET...."
				echo "-----------------------------"				
			elif [ $databasetype = percona ]; then
                                echo "Percona NOT AVAILABLE YET...."
				echo "-----------------------------"
			elif [ $databasetype = mysql ]; then 
                                mysql="10000000-0000-0000-0000-000000000001"
				read -p "DataBase Version, 5.1 or 5.6   :" databaseversion			
					if [ $databaseversion = "5.1" ]; then
					  	databaseversion="20000000-0000-0000-0000-000000000002"
						curl -s --ciphers RC4-SHA:RC4-MD5 -H 'X-Auth-Token: '$token'' https://"$dc".databases.api.rackspacecloud.com/v1.0/"$ddi"/datastores/"$databasetype"/versions/"$databaseversion"/parameters -H 'Content-Type: application/json' | python -m json.tool | more
					elif [ $databaseversion = "5.6" ]; then
						databaseversion="b34a2076-c426-4ce0-8775-52b666c06c4d"
						curl -s --ciphers RC4-SHA:RC4-MD5 -H 'X-Auth-Token: '$token'' https://"$dc".databases.api.rackspacecloud.com/v1.0/"$ddi"/datastores/"$databasetype"/versions/"$databaseversion"/parameters -H 'Content-Type: application/json' | python -m json.tool | more
					else
						echo "Please select one of the availavle optiobs."
						echo "-----------------------------"
					fi
			else
				break
			fi
	elif [ $response = 3 ]; then
		read -p "DataBase Type, mariadb, mysql, percona:  " databasetype
                        if [ $databasetype = mariadb ]; then
                                echo "MARIADB NOT AVAILABLE YET...."
                                echo "-----------------------------"                            
                        elif [ $databasetype = percona ]; then
                                echo "Percona NOT AVAILABLE YET...."
                                echo "-----------------------------"
                        elif [ $databasetype = mysql ]; then 
                                #databasetype="10000000-0000-0000-0000-000000000001"
				 databasetype="mysql"
                                read -p "DataBase Version, 5.1 or 5.6   :" databaseversion                      
                                        if [ $databaseversion = "5.1" ]; then
                                                #databaseversion="20000000-0000-0000-0000-000000000002"
						 databaseversion="5.1"
						configurationfunction databasetype databaseversion dc ddi
                                        elif [ $databaseversion = "5.6" ]; then
                                                #databaseversion="b34a2076-c426-4ce0-8775-52b666c06c4d"
						 databaseversion="5.6"
						configurationfunction databasetype databaseversion dc ddi
                                        else
                                                echo "Please select one of the availavle optiobs."
                                                echo "-----------------------------"
                                        fi
                        else
                                break
                        fi
	elif [ $response = 5 ]; then
		curl -s --ciphers RC4-SHA:RC4-MD5 -H 'X-Auth-Token: '$token'' 'https://'$dc'.databases.api.rackspacecloud.com/v1.0/'$ddi'/datastores' -H 'Content-Type: application/json' | python -m json.tool
	elif [ $response = 4 ]; then
		read -p "What is the configuration ID that you want to apply:  " confID
		curl -s --ciphers RC4-SHA:RC4-MD5 -H 'X-Auth-Token: '$token'' 'https://'$dc'.databases.api.rackspacecloud.com/v1.0/'$ddi'/instances' -H 'Content-Type: application/json' | python -m json.tool
		read -p "What is the DATABASE ID that you want to use:  " databaseID
		curl --ciphers RC4-SHA:RC4-MD5 -i -X PUT -H "X-Auth-Token: $token" -H "Content-Type: application/json" https://$dc.databases.api.rackspacecloud.com/v1.0/$ddi/instances/$databaseID -d "{\"instance\":{\"configuration\":\"$confID\"}}"
	elif [ $response = 6 ]; then
		read -p "What is the configuration ID that you want to delete:  " deleteconfig	
		curl -s -i  --ciphers RC4-SHA:RC4-MD5 -X DELETE -H 'X-Auth-Token: '$token'' "https://"$dc".databases.api.rackspacecloud.com/v1.0/"$ddi"/configurations/"$deleteconfig""
	elif [ $response = 7 ]; then
		read -p "What is the configuration ID that you want to check:  " checkconfig	
		curl -s --ciphers RC4-SHA:RC4-MD5 -H "X-Auth-Token: $token" https://$dc.databases.api.rackspacecloud.com/v1.0/$ddi/configurations/$checkconfig/instances -H "Content-Type: application/json" | python -m json.tool
	elif [ $response = 8 ]; then
		read -p "What is the configuration ID that you want to check:  " checkconfig  
		curl -s --ciphers RC4-SHA:RC4-MD5 -H "X-Auth-Token: $token" https://$dc.databases.api.rackspacecloud.com/v1.0/$ddi/configurations/$checkconfig -H "Content-Type: application/json" | python -m json.tool
	elif [ $response = 9 ]; then
                read -p "What is the configuration ID that you want to USE:  " confID
                curl -s --ciphers RC4-SHA:RC4-MD5 -H 'X-Auth-Token: '$token'' 'https://'$dc'.databases.api.rackspacecloud.com/v1.0/'$ddi'/instances' -H 'Content-Type: application/json' | python -m json.tool
                read -p "What is the DATABASE ID that you want to use:  " databaseID
                curl --ciphers RC4-SHA:RC4-MD5 -i -X DELETE -H "X-Auth-Token: $token" -H "Content-Type: application/json" https://$dc.databases.api.rackspacecloud.com/v1.0/$ddi/instances/$databaseID -d "{\"instance\":{\"configuration\":\"$confID\"}}"
	else
		break
	fi
done

#delete temporary file used to auth
auth="/tmp/auth.temp"
#dbfile="/tmp/db.temp"
if [ -f $auth ]; then
	rm $auth
else
	echo ""
fi
