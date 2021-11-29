#!/bin/sh
#
# SCRIPT:Get a PowerBI access token from a JWT token
# AUTHOR: Christophe MICHAUX <chris@cmxconsulting.fr>
# CREATION DATE : 2022-02-07
# WEB : https://www.cmxconsulting.fr
#
# DESCRIPTION : Returns an access token from the JWT token set by the jwtencode.sh script
#
# Copyright 2022 CMX Consulting
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
# If you are searching for other useful scripts, be free to go to https://github.com/cmxconsulting/
#

JWT=$(./jwtencode.sh)


AZURE_TENANTID="PUT_THE_AZURE_TENANT_ID_HERE"


#echo "JWT : ${JWT}"

#echo "Call Microsoft WS"
JSON=`curl -s -L -X POST 'https://login.microsoftonline.com/${AZURE_TENANTID}/oauth2/v2.0/token' \
-F 'scope="openid profile email https://analysis.windows.net/powerbi/api/.default"' \
-F 'grant_type="client_credentials"' \
-F 'client_assertion_type="urn:ietf:params:oauth:client-assertion-type:jwt-bearer"' \
-F "client_assertion=\"${JWT}\""`	

#echo $JSON
ACCESS_TOKEN=`echo $JSON | python3 -c "import sys, json; print(json.load(sys.stdin)['access_token'])"`

echo "$ACCESS_TOKEN"

