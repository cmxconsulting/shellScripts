#!/bin/sh
#
# SCRIPT: sh_add_comment_headers.sh
# AUTHOR: Christophe MICHAUX <chris@cmxconsulting.fr>
# CREATION DATE : 2020-10-07
# WEB : https://www.cmxconsulting.fr
#
# DESCRIPTION : Description header generator for shell script
# USAGE : 
# ./sh_add_comments_headers.sh filename
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

TARGET=$1
# You can change the followings
AUTHOR="Christophe MICHAUX <chris@cmxconsulting.fr>"
COPYRIGHT_OWNER="CMX Consulting"
WEBSITE="https://www.cmxconsulting.fr"

GIT_USER=$(git config user.name)
RESULT=$?
if [ $RESULT -eq 0 ]; then
  GIT_EMAIL=$(git config user.email)
  #AUTHOR="${GIT_USER} <${GIT_EMAIL}>"
fi


TMP=.outheader.tmp
CURDATE=$(date +"%Y-%m-%d")
CURYEAR=$(date +"%Y")

CRED='\033[1;31m'
CGREEN='\033[1;32m'
CCYAN='\033[1;36m'
CNC='\033[0m' # No Color

echo $CCYAN
echo " ██████ ███    ███ ██   ██      ██████  ██████  ███    ██ ███████ ██    ██ ██   ████████ ██ ███    ██  ██████  ";
echo "██      ████  ████  ██ ██      ██      ██    ██ ████   ██ ██      ██    ██ ██      ██    ██ ████   ██ ██       ";
echo "██      ██ ████ ██   ███       ██      ██    ██ ██ ██  ██ ███████ ██    ██ ██      ██    ██ ██ ██  ██ ██   ███ ";
echo "██      ██  ██  ██  ██ ██      ██      ██    ██ ██  ██ ██      ██ ██    ██ ██      ██    ██ ██  ██ ██ ██    ██ ";
echo " ██████ ██      ██ ██   ██      ██████  ██████  ██   ████ ███████  ██████  ███████ ██    ██ ██   ████  ██████  ";
echo "                                                                                                               ";
echo "                                                                                                               ";

echo "Description header generator for shell script"
echo $CNC
echo "Author : Christophe MICHAUX <chris@cmxconsulting.fr>"
echo "Copyright 2020 CMX Consulting"


 
display_usage() { 
    echo "This script will add documentation header on your shell script files." 
    echo " "
    echo "Usage:"
    echo "$CGREEN $0 [arguments] YOUR_SHELL_SCRIPT"
    echo $CNC
    echo " "
    echo "Arguments : "
    echo "-h/--help : display this message"
    echo "YOUR_SHELL_SCRIPT : your script file (.sh / .bash...)" 
    echo " "
} 

# if less than two arguments supplied, display usage 
if [  $# -le 0 ] 
then 
	display_usage
	exit 1
fi 
 
# check whether user had supplied -h or --help . If yes display usage 
if [[ ( $# == "--help") ||  $# == "-h" ]] 
then 
	display_usage
	exit 0
fi 

# Checks if file exists
if [ ! -f "$TARGET" ]; then
    echo $CRED
    echo "$TARGET does not exist. Please choose an existing file and try again"
    echo $CNC
    display_usage
    exit 2
fi

read -p "Please give a short description for this file in one line: " DESCRIPTION

read -p "Please specify the author of this file. Leave empty for [${AUTHOR}]:" REAL_AUTHOR
REAL_AUTHOR="${REAL_AUTHOR:-$AUTHOR}"

read -p "Please specify the copyright owner of this file. Leave empty for [${COPYRIGHT_OWNER}]: " REAL_COPYRIGHT
REAL_COPYRIGHT="${REAL_COPYRIGHT:-$COPYRIGHT_OWNER}"
echo " "

echo "Generating file..."

cat <<EOF > $TMP
#
# SCRIPT: ${TARGET}
# AUTHOR: ${REAL_AUTHOR}
# CREATION DATE : ${CURDATE}
# WEBSITE : ${WEBSITE}
#
# DESCRIPTION : ${DESCRIPTION}
#
# Copyright ${CURYEAR} ${REAL_COPYRIGHT}
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

echo " "
echo "$DESCRIPTION"
echo " "


EOF

sed -i '' -e "/#\!.*/ r $TMP" $TARGET

rm -f $TMP

echo $CGREEN
echo "Your file was updated successfully"
echo $CNC
echo " "
echo "If you are searching for other useful scripts, be free to go to https://github.com/cmxconsulting/"
echo " "
echo "End."



