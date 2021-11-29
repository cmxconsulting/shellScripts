#!/bin/sh
#
# SCRIPT: git_delete_branch.sh
# AUTHOR: Christophe MICHAUX <chris@cmxconsulting.fr>
# CREATION DATE : 2020-10-07
# WEBSITE : https://www.cmxconsulting.fr
#
# DESCRIPTION : Delete a git branch, locally and on remote repository.
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

echo "Delete a git branch, locally and on remote repository."
echo " "
display_usage() { 
    echo " "
    echo "Usage:"
    echo "    $CGREEN $0 [options] GIT_BRANCH"
    echo $CNC
    echo "Arguments : "
    echo "  -h : display this message"
    echo "  GIT_BRANCH : the branch to delete" 
    echo " "
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

BRANCH=$1

# if less than two arguments supplied, display usage 
if [  $# -gt 1 ] 
then 
	echo "${CRED}Error : Too much arguments ($#)$CNC"
    
	display_usage
	exit 2
fi 


# Checks if file exists
if [ -z "$BRANCH" ]; then
    echo $CRED
    echo "Branch not specified. Please choose an existing branch and try again"
    echo $CNC
    display_usage
    exit 3
fi

echo "Ask to remove git branch : ${CRED}${BRANCH}${CNC}"


echo $CRED
echo "Be carreful, this operation cannot be undone."
read -p "Do you really want to remove branch $1 ? (Y/n)" -n 1 -r
echo $CNC

if [[ $REPLY =~ ^[Yy]$ ]]
then

    git branch -D $1
    git push origin :$1 --no-verify
fi


echo " "
echo "Operation complete."
echo " "
echo "If you are searching for other useful scripts, be free to go to https://github.com/cmxconsulting/"
echo " "
echo "End."


