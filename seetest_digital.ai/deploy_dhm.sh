#!/bin/sh
#
# SCRIPT: deploy_dhm.sh
# AUTHOR: Christophe MICHAUX <chris@cmxconsulting.fr>
# CREATION DATE : 2021-11-29
# WEBSITE : https://www.cmxconsulting.fr
#
# DESCRIPTION : Deploy Seetest binaries on mac machines
#
# Copyright 2021 CMX Consulting
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

# PLEASE SPECIFY IP OF MAC MACHINES HERE
SERVERS=(
"100.118.35.219"
"mac427mr.itgce.caisse-epargne.fr"
"51.1.106.126"
"51.64.3.177"
"100.118.35.87"
"51.1.106.29"
"126.37.3.23"
"100.118.35.0"
"51.64.3.185"
"51.1.105.63"
"51.1.104.254"
"100.118.35.243"
)
MAC_USERNAME="experitest"
CURRENT_DIR=`pwd`


CRED='\033[1;31m'
CGREEN='\033[1;32m'
CCYAN='\033[1;36m'
CNC='\033[0m' # No Color

echo "Deploy SeeTest MacOS package on mac machines."
echo " "
display_usage() { 
    echo " "
    echo "Usage:"
    echo "    $CGREEN $0 [options]"
    echo $CNC
    echo "Arguments : "
    echo "  -h : display this message"
    echo " "
    echo "${CRED}Before launching this screen you need to set SSH public key to the machines${CNC}"
    echo "In order to do that, please launch following commands and type password each time${CGREEN}"

  	for SERVER in "${SERVERS[@]}"; do
  		echo "ssh-copy-id $MAC_USERNAME@$SERVER"
  	done
  	echo ${CNC}
}

while getopts ":h" opt; do
  case ${opt} in
    h )
      display_usage
      exit 0
      ;;
    \? )
      echo $CRED
      echo "Invalid Option: -$OPTARG" 1>&2
      echo $CNC
      exit 1
      ;;
  esac
done
shift $((OPTIND -1))


SOURCE_DIR=~/Downloads 
SEETEST_FILENAME_PREFIX="Cloud_macos"
SEETEST_FILENAME_SUFFIX=".zip"

echo "Scan des binaires SeeTest Continuous Testing dans $SOURCE_DIR"
for i in $(find $SOURCE_DIR -name $SEETEST_FILENAME_PREFIX\*$SEETEST_FILENAME_SUFFIX); do 

  BINARY=$(basename $i)
  echo "Found binary ${CCYAN}$i${CNC}"
  # Read the array values with space
  for SERVER in "${SERVERS[@]}"; do
    echo Deploy tools to ${CGREEN}$SERVER${CNC}
  	scp -r $CURRENT_DIR/bundle/* $MAC_USERNAME@$SERVER:~/Documents/

    echo Deploy Seetest binary ${CCYAN}$BINARY${CNC} to ${CGREEN}$SERVER${CNC}
  	scp $i $MAC_USERNAME@$SERVER:~/Documents/

  done

done


