#!/bin/sh
#
# SCRIPT:JWT Encoder Bash Script
# AUTHOR: Christophe MICHAUX <chris@cmxconsulting.fr>
# CREATION DATE : 2022-02-07
# WEB : https://www.cmxconsulting.fr
#
# DESCRIPTION : Creates a JWT token to log into PowerBI API (using Azure) using a certificate
# USE : ./jwtencode.sh PATH_TO_PFX_FILE PASSWORD_OF_PFX_FILE
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


PRIVATE_KEY_FILE="key_private.pem"
PUBLIC_KEY_FILE="key_public.pem"
CERTIFICATE_PFX="$1"
CERTIFICATE_PASS="$2"

AZURE_APPID="PUT_AZURE_APP_ID_HERE"
AZURE_TENANTID="PUT_AZURE_TENANT_ID_HERE"

# Extract public key from PFX
openssl pkcs12 -in ${CERTIFICATE_PFX}  -clcerts -nokeys -passin pass:${CERTIFICATE_PASS} | sed -ne '/-BEGIN CERTIFICATE-/,/-END CERTIFICATE-/p' > ${PUBLIC_KEY_FILE}


# Extract private key from PFX
openssl pkcs12 -in ${CERTIFICATE_PFX} -nocerts -nodes  -passin pass:${CERTIFICATE_PASS} | sed -ne '/-BEGIN PRIVATE KEY-/,/-END PRIVATE KEY-/p' > ${PRIVATE_KEY_FILE}

CERTIF_SHA1=$(openssl x509 -in ${PUBLIC_KEY_FILE} -fingerprint -noout) 
CERTIF_BASE64=`echo $CERTIF_SHA1 | sed 's/SHA1 Fingerprint=//g' | sed 's/://g' | xxd -r -ps | base64`
PUBLIC_KEY=`openssl x509 -pubkey -inform pem -in ${PUBLIC_KEY_FILE} -noout | tail -n+2 | sed '$d'`

uuid=$(uuidgen)
secret=${uuid}
timestamp=$(date +%s)
expiration=$(date  -v +5H +%s)


# Build HEADER
# X5T is the Certificate fingerprint encoded specially in base64
header="{
  \"typ\": \"JWT\",
  \"alg\": \"RS256\",
  \"x5t\": \"${CERTIF_BASE64}\"
}"


payload="{
  \"aud\": \"https://login.microsoftonline.com/$AZURE_TENANTID/v2.0\",
  \"iss\": \"$AZURE_APPID\",
  \"sub\": \"$AZURE_APPID\",
  \"jti\": \"$uuid\",
  \"nbf\": $timestamp,
  \"exp\": $expiration
}"



# Generate Payload and header in base 64
header_base64=$(echo "${header}" | openssl base64 -e -A)
payload_base64=$(echo "${payload}" | openssl base64 -e -A)
header_payload=$(echo "${header_base64}.${payload_base64}")

# We generate PEM content with private and public key
PEM=$( cat ${PRIVATE_KEY_FILE} ${PUBLIC_KEY_FILE})

signature=$( openssl dgst -sha256 -sign <(echo -n "${PEM}") <(echo -n "${header_payload}") | openssl base64 | tr -d '=' | tr '/+' '_-' | tr -d '\n' )

#echo "Signature : $signature"
#echo "---"
#echo "Result : "
echo "${header_payload}.${signature}"

