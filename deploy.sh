#!/bin/bash
# store the whole response with the status at the and
HTTP_RESPONSE=$(curl --silent --write-out "HTTPSTATUS:%{http_code}" -X POST --header "Authorization: Basic cHJhdHl1c2gubW9oYXBhdHJhMUB0Y3MuY29tOk1hdmVyaWNrQDE=" -F "file=@CI_CD_PROXY.zip" "https://api.enterprise.apigee.com/v1/organizations/pratyush91/apis?action=import&name=CI_CD_DEMO")

echo "first one executed" $HTTP_RESPONSE
# extract the body
HTTP_BODY=$(echo $HTTP_RESPONSE | sed -e 's/HTTPSTATUS\:.*//g')
echo "second one executed" $HTTP_BODY
# extract the status
HTTP_STATUS=$(echo $HTTP_RESPONSE | tr -d '\n' | sed -e 's/.*HTTPSTATUS://')
echo "third one executed" $HTTP_STATUS
# print the body
echo "$HTTP_BODY" > temp.json
REVISION=$( grep -o '"revision" : *"[^"]*"' temp.json | grep -o '"[^"]*"$' | sed 's/"//g')
# example using the status
if [ $HTTP_STATUS -eq 201  ]
        then
        echo "Proxy is uploaded successfully [HTTP status: $HTTP_STATUS]"
        echo "$REVISION"
        
        else
         exit 1
fi
DEPLOY_HTTP_RESPONSE=$(curl --silent --write-out "HTTPSTATUS:%{http_code}" -X POST --header "Content-Type: application/x-www-form-urlencoded" --header "Authorization: Basic cHJhdHl1c2gubW9oYXBhdHJhMUB0Y3MuY29tOk1hdmVyaWNrQDE=" "https://api.enterprise.apigee.com/v1/organizations/pratyush91/environments/test/apis/CI_CD_DEMO/revisions/$REVISION/deployments?override=true")
# extract the status
DEPLOY_HTTP_STATUS=$(echo $DEPLOY_HTTP_RESPONSE | tr -d '\n' | sed -e 's/.*HTTPSTATUS://')
echo "third one executed" $DEPLOY_HTTP_STATUS
if [ $DEPLOY_HTTP_STATUS -eq 200  ]
        then
        echo "Proxy is deployed successfully [HTTP status: $HTTP_STATUS]"
        
        else
         exit 1
fi