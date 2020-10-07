#!/bin/sh
#
# SCRIPT: installProvisioningProfiles.sh
# AUTHOR: Christophe MICHAUX <chris@cmxconsulting.fr>
# CREATION DATE : 2020-10-07
# WEB : https://www.cmxconsulting.fr
#
# DESCRIPTION : Copy provisioning profiles from current directory to servers
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

# PLEASE UPDATE THE FOLLOWING LINE !
servers=("username@10.0.0.1" "username@10.0.0.2")

echo " "
echo "Copy provisioning profiles from current directory to servers"
echo "Do not forget to change this script in order to specify the servers"
echo " "

display_usage() {
    echo " "
    echo "Usage:"
    echo "$CCYAN $0 [arguments]"
    echo $CNC
    echo " "
    echo "Arguments : "
    echo "-h/--help : display this message"
    echo "-l/--local : also copy file to the local machine (if macOS)"
    echo "-v/--verbose : verbose the copy outputs"
    echo " "
}


LOCAL_COPY=0
VERBOSE=0

for i in "$@"
do
case $i in
    -l|--local)
    LOCAL_COPY=1
    ;;
    -v|--verbose)
    VERBOSE=1
    ;;
    -h|--help)
    display_usage
    exit 0
    ;;
    *)
    # unknown option
    display_usage
    exit 1
    ;;
esac
done
CRED='\033[1;31m'
CGREEN='\033[1;32m'
CCYAN='\033[1;36m'
CNC='\033[0m' # No Color


files=(`ls *.mobileprovision`)
echo "Number of provisioning files found :  ${#files[@]}"
if [ ${#files[@]} -eq 0 ]; then
  echo $CRED
  echo "Error, there is no *.mobileprovision files in this directory"
  echo $CNC
  display_usage
  exit 2
fi

VERBCP=""
VERBSCP="-q"
if [[ $VERBOSE -eq "1" ]]; then
    VERBCP="-v"
    VERBSCP=""
fi

for file in $files; do
    uuid=`grep UUID -A1 -a "$file" | grep -io "[-A-F0-9]\{36\}"`
    extension="${file##*.}"
    echo $CCYAN
    echo "Copy $file (uuid $uuid) $CNC"
    if [[ $LOCAL_COPY -eq "1" ]]; then    
        echo "    - to local machine"
        cp $VERBCP "$file" ~/Library/MobileDevice/Provisioning\ Profiles/$uuid.$extension
    fi

    for server in "${servers[@]}"; do
        echo "    - to $server"
        scp -r $VERBSCP "$file" "$server:~/Library/MobileDevice/Provisioning\\ Profiles/$uuid.$extension"

    done
    echo " "
done


echo "Your files were copied successfully"
echo " "
echo "If you are searching for other useful scripts, be free to go to https://github.com/cmxconsulting/"
echo " "
echo "End."


