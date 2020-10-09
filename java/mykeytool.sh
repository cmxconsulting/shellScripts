#!/bin/sh
#
# SCRIPT: mykeytool.sh
# AUTHOR: Christophe MICHAUX <chris@cmxconsulting.fr>
# CREATION DATE : 2020-10-09
# WEBSITE : https://www.cmxconsulting.fr
#
# DESCRIPTION : Display information about java and certificates
#
# Copyright 2020 CMX Consulting
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


CRED='\033[1;31m'
CGREEN='\033[1;32m'
CCYAN='\033[1;36m'
CNC='\033[0m' # No Color

echo $CCYAN
echo "Display information about java and certificates"
echo "Author : Christophe MICHAUX <chris@cmxconsulting.fr>"
echo "Copyright 2020 CMX Consulting"

echo $CNC

 
display_usage() { 
    echo "This script allows to display information about java and certificates" 
    echo " "
    echo "Usage:"
    echo "$CGREEN $0 [options] "
    echo $CNC
    echo " "
    echo "Options : "
    echo "-h/--help : display this message"
    echo " "
} 


JAVA_PATH=$(/usr/libexec/java_home)
JAVA_BIN=${JAVA_PATH}/bin

echo "Java detected at : ${JAVA_PATH}"

${JAVA_BIN}/java -version

CACERTS=${JAVA_PATH}/lib/security/cacerts

if [ ! -f "$CACERTS" ]; then
	# CACERTS not found. Try if this is a JDK
	CACERTS=${JAVA_PATH}/jre/lib/security/cacerts
fi

if [ ! -f "$CACERTS" ]; then

    echo $CRED
    echo "Error : cacerts file not found inside $JAVA_PATH"
    echo $CNC
    exit 2
fi

KEYTOOL_LIST="${JAVA_BIN}/keytool -list -keystore $CACERTS -storepass changeit"

# First we count
CERTIF_COUNT=$(${KEYTOOL_LIST} | wc -l)

echo ${CGREEN}
echo "Number of certificates found : ${CERTIF_COUNT}"
echo " "



read -p "Do you want to display certificates ? (Y/n)" -n 1 -r DISPLAY_CERTS
echo " "


if [[ $DISPLAY_CERTS =~ ^[Yy]$ ]]
then

	read -p "Do you want to filter the results ? (Y/n)" -n 1 -r DISPLAY_FILTER
	echo " "


	if [[ $DISPLAY_FILTER =~ ^[Yy]$ ]]
	then
		read -p "Please give the filter to use : " FILTER
		echo " "

		echo "Please find the certificates matching ${FILTER} (case insensitive):$CNC"
		${KEYTOOL_LIST} | grep -i ${FILTER}
	else

		echo "Please find the certificates:$CNC"
		${KEYTOOL_LIST}
	fi
fi


echo ${CGREEN}
echo "Operation complete.$CNC"
echo " "
echo "If you are searching for other useful scripts, be free to go to https://github.com/cmxconsulting/"
echo " "
echo "End."
